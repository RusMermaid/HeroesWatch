// Shared primary-key details deliberately do not repeat Game_id. These deferred
// checks cover their inherited game, nullable global media, and reverse edits.
export function gameIntegritySql(schema, quoteIdent, quoteLiteral) {
  const q = quoteIdent;
  const ns = q(schema.postgresSchema);
  const metadata = {};
  for (const table of schema.tables) {
    const pk = table.primaryKey[0];
    const refs = table.foreignKeys.filter(fk => fk.columns.length === 1).map(fk => ({
      column: fk.columns[0], table: fk.referencedTable, target: fk.referencedColumns[0] }));
    const shared = table.kind === "game-detail" ? refs.find(fk => fk.column === pk) : null;
    const ownerColumn = schema.integrity.inheritedOwners[table.name];
    const owner = shared ?? refs.find(fk => fk.column === ownerColumn) ?? null;
    metadata[table.name] = { pk, type: table.columns.find(c => c.name === pk).postgresType,
      direct: table.columns.some(c => c.name === "Game_id"), owner,
      expected: table.name === "FactionLaw" ? "HOMM8" : table.name.match(/HOMM[1-8]$/)?.[0] ?? null,
      refs, incoming: [] };
  }
  for (const [name, meta] of Object.entries(metadata)) {
    for (const reference of meta.refs) {
      metadata[reference.table].incoming.push({ table: name, column: reference.column });
    }
  }
  const lines = [`-- Ownership checks use final row state and lock referenced parents.
-- Reverse checks run on ownership changes, including Game.SeriesCode changes.
-- Native composite FKs handle direct ownership and resource membership.
-- REPEATABLE READ ownership changes are rejected: an older snapshot can hide
-- a child committed while this transaction waited for the parent's row lock.
CREATE FUNCTION ${ns}."_scope_metadata"(table_name text) RETURNS jsonb
LANGUAGE sql IMMUTABLE STRICT AS $function$
  SELECT ${quoteLiteral(JSON.stringify(metadata))}::jsonb -> table_name
$function$;

CREATE FUNCTION ${ns}."_scope_row"(table_name text, row_key text) RETURNS jsonb
LANGUAGE plpgsql VOLATILE AS $function$
DECLARE m jsonb; result jsonb;
BEGIN
  m := ${ns}."_scope_metadata"(table_name);
  IF m IS NULL THEN RAISE EXCEPTION 'Unknown integrity table: %', table_name; END IF;
  EXECUTE format('SELECT to_jsonb(r) FROM %I.%I r WHERE %I = $1::%s FOR SHARE',
    ${quoteLiteral(schema.postgresSchema)}, table_name, m->>'pk', m->>'type') INTO result USING row_key;
  RETURN result;
END
$function$;

CREATE FUNCTION ${ns}."_scope_owner"(table_name text, row_key text) RETURNS bigint
LANGUAGE plpgsql VOLATILE AS $function$
DECLARE m jsonb; r jsonb; result bigint;
BEGIN
  IF row_key IS NULL THEN RETURN NULL; END IF;
  m := ${ns}."_scope_metadata"(table_name);
  r := ${ns}."_scope_row"(table_name, row_key);
  IF r IS NULL THEN RETURN NULL; END IF;
  IF (m->>'direct')::boolean THEN RETURN (r->>'Game_id')::bigint; END IF;
  IF m->'owner' <> 'null'::jsonb AND r->>(m->'owner'->>'column') IS NOT NULL THEN
    RETURN ${ns}."_scope_owner"(m->'owner'->>'table', r->>(m->'owner'->>'column'));
  END IF;
  -- Artifact sets can have no introduction release; their title still scopes them.
  IF m->>'expected' IS NOT NULL THEN
    SELECT "Game_id" INTO result FROM ${ns}."Game" WHERE "SeriesCode" = m->>'expected' FOR SHARE;
    RETURN result;
  END IF;
  RETURN NULL;
END
$function$;

CREATE FUNCTION ${ns}."_check_scope_row"(table_name text, row_key text) RETURNS void
LANGUAGE plpgsql VOLATILE AS $function$
DECLARE m jsonb; r jsonb; reference jsonb; owned bigint; target_game bigint; series text;
BEGIN
  m := ${ns}."_scope_metadata"(table_name);
  r := ${ns}."_scope_row"(table_name, row_key);
  IF r IS NULL THEN RETURN; END IF; -- Row was removed later in this transaction.
  owned := ${ns}."_scope_owner"(table_name, row_key);
  IF m->>'expected' IS NOT NULL THEN
    SELECT "SeriesCode" INTO series FROM ${ns}."Game" WHERE "Game_id" = owned FOR SHARE;
    IF series IS DISTINCT FROM m->>'expected' THEN
      RAISE EXCEPTION 'Game ownership: %(%) requires %, found %', table_name, row_key, m->>'expected', series USING ERRCODE = '23514';
    END IF;
  END IF;
  IF owned IS NULL THEN RETURN; END IF; -- Genuinely global Resource / MediaAsset.
  FOR reference IN SELECT value FROM jsonb_array_elements(m->'refs') LOOP
    IF r->>(reference->>'column') IS NULL THEN CONTINUE; END IF;
    target_game := ${ns}."_scope_owner"(reference->>'table', r->>(reference->>'column'));
    IF target_game IS NOT NULL AND target_game <> owned THEN
      RAISE EXCEPTION 'Game ownership: %(%) field % belongs to game %, expected %', table_name, row_key, reference->>'column', target_game, owned USING ERRCODE = '23514';
    END IF;
  END LOOP;
END
$function$;

CREATE FUNCTION ${ns}."_check_scope_descendants"(table_name text, row_key text, visited text[] DEFAULT ARRAY[]::text[]) RETURNS void
LANGUAGE plpgsql VOLATILE AS $function$
DECLARE m jsonb; incoming jsonb; child_meta jsonb; child_key text; marker text;
BEGIN
  marker := table_name || ':' || row_key;
  IF marker = ANY(visited) THEN RETURN; END IF;
  visited := array_append(visited, marker);
  m := ${ns}."_scope_metadata"(table_name);
  PERFORM ${ns}."_check_scope_row"(table_name, row_key);
  FOR incoming IN SELECT value FROM jsonb_array_elements(m->'incoming') LOOP
    child_meta := ${ns}."_scope_metadata"(incoming->>'table');
    FOR child_key IN EXECUTE format('SELECT %I::text FROM %I.%I WHERE %I = $1::%s FOR SHARE',
      child_meta->>'pk', ${quoteLiteral(schema.postgresSchema)}, incoming->>'table', incoming->>'column', m->>'type') USING row_key LOOP
      -- A referenced row may be affected without inheriting its owner's game.
      -- Traverse only ownership edges; check other direct dependants once.
      IF child_meta->'owner'->>'column' = incoming->>'column'
         OR ((child_meta->>'direct')::boolean AND incoming->>'column' = 'Game_id') THEN
        PERFORM ${ns}."_check_scope_descendants"(incoming->>'table', child_key, visited);
      ELSE
        PERFORM ${ns}."_check_scope_row"(incoming->>'table', child_key);
      END IF;
    END LOOP;
  END LOOP;
END
$function$;

CREATE FUNCTION ${ns}."_game_scope_constraint"() RETURNS trigger
LANGUAGE plpgsql VOLATILE AS $function$
DECLARE m jsonb; r jsonb; old_r jsonb; row_key text; owner_column text;
BEGIN
  m := ${ns}."_scope_metadata"(TG_TABLE_NAME);
  r := to_jsonb(NEW);
  row_key := r->>(m->>'pk');
  PERFORM ${ns}."_check_scope_row"(TG_TABLE_NAME, row_key);
  IF TG_OP = 'UPDATE' THEN
    old_r := to_jsonb(OLD);
    owner_column := CASE WHEN (m->>'direct')::boolean THEN 'Game_id' ELSE m->'owner'->>'column' END;
    IF r->(m->>'pk') IS DISTINCT FROM old_r->(m->>'pk')
       OR (owner_column IS NOT NULL AND r->owner_column IS DISTINCT FROM old_r->owner_column)
       OR (TG_TABLE_NAME = 'Game' AND r->'SeriesCode' IS DISTINCT FROM old_r->'SeriesCode') THEN
      IF current_setting('transaction_isolation') = 'repeatable read' THEN
        RAISE EXCEPTION 'Ownership-changing updates on % require READ COMMITTED or SERIALIZABLE', TG_TABLE_NAME
          USING ERRCODE = '0A000',
            HINT = 'Retry the whole transaction using READ COMMITTED or SERIALIZABLE. REPEATABLE READ can hide a recently committed dependent row.';
      END IF;
      PERFORM ${ns}."_check_scope_descendants"(TG_TABLE_NAME, row_key);
    END IF;
  END IF;
  RETURN NULL;
END
$function$;
`];
  for (const table of schema.tables) {
    lines.push(`CREATE CONSTRAINT TRIGGER ${q(`ct_game_scope__${table.name}`)}
AFTER INSERT OR UPDATE ON ${ns}.${q(table.name)}
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION ${ns}."_game_scope_constraint"();`);
  }
  return lines.join("\n\n");
}

export function validateExistingScopeSql(schema, quoteIdent, quoteLiteral) {
  const ns = quoteIdent(schema.postgresSchema);
  return `-- Check existing rows before committing the upgrade. New triggers only see future edits.
DO $validate_scope$
DECLARE table_name text; meta jsonb; row_key text;
BEGIN
  FOREACH table_name IN ARRAY ARRAY[${schema.tables.map(t => quoteLiteral(t.name)).join(", ")}] LOOP
    meta := ${ns}."_scope_metadata"(table_name);
    FOR row_key IN EXECUTE format('SELECT %I::text FROM %I.%I', meta->>'pk', ${quoteLiteral(schema.postgresSchema)}, table_name) LOOP
      PERFORM ${ns}."_check_scope_row"(table_name, row_key);
    END LOOP;
  END LOOP;
END
$validate_scope$;`;
}
