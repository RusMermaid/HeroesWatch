import {catalogGuardRules} from './catalog-guard-rules.mjs';

// Each graph remains a normal _cid junction. No auxiliary catalog or edge
// cache is introduced. Writers serialize only within one game + graph family.
export function graphGuardsSql(schema, q, literal) {
  const ns = q(schema.postgresSchema);
  const metadata = Object.fromEntries(catalogGuardRules.noSelfEdges.map(rule => {
    const table = schema.tables.find(table => table.name === rule.table);
    if (!table || !table.columns.some(column => column.name === 'Game_id')) throw new Error(`Missing graph table ${rule.table}`);
    return [rule.table, {...rule, pk: table.primaryKey[0]}];
  }));
  const sql = `-- Catalog dependency/progression graphs are directed acyclic graphs.
-- The existing conditions and cross-campaign edges remain valid; only cycles fail.
CREATE OR REPLACE FUNCTION ${ns}."_catalog_graph_metadata"(table_name TEXT) RETURNS JSONB
LANGUAGE sql IMMUTABLE STRICT AS $function$
  SELECT ${literal(JSON.stringify(metadata))}::jsonb -> table_name
$function$;

CREATE OR REPLACE FUNCTION ${ns}."_catalog_graph_write_lock"() RETURNS TRIGGER
LANGUAGE plpgsql VOLATILE AS $function$
DECLARE m JSONB; old_row JSONB; new_row JSONB; lock_id BIGINT; game_ids TEXT[];
BEGIN
  m := ${ns}."_catalog_graph_metadata"(TG_TABLE_NAME);
  IF TG_OP <> 'INSERT' THEN old_row := to_jsonb(OLD); END IF;
  IF TG_OP <> 'DELETE' THEN new_row := to_jsonb(NEW); END IF;
  IF TG_OP = 'UPDATE' AND old_row->'Game_id' IS NOT DISTINCT FROM new_row->'Game_id'
      AND old_row->(m->>'left') IS NOT DISTINCT FROM new_row->(m->>'left')
      AND old_row->(m->>'right') IS NOT DISTINCT FROM new_row->(m->>'right') THEN
    RETURN NEW;
  END IF;
  IF TG_OP <> 'DELETE' AND current_setting('transaction_isolation') = 'repeatable read' THEN
    RAISE EXCEPTION 'Graph topology writes on % require READ COMMITTED or SERIALIZABLE', TG_TABLE_NAME
      USING ERRCODE = '0A000', HINT = 'Retry the whole transaction at a supported isolation level. Notes-only edits and deletes remain allowed.';
  END IF;
  game_ids := ARRAY[old_row->>'Game_id', new_row->>'Game_id'];
  FOR lock_id IN SELECT DISTINCT hashtextextended('heroes_watch:graph:' || TG_TABLE_NAME || ':' || value, 0)
      FROM unnest(game_ids) AS games(value) WHERE value IS NOT NULL ORDER BY 1 LOOP
    PERFORM pg_advisory_xact_lock(lock_id);
  END LOOP;
  IF TG_OP = 'DELETE' THEN RETURN OLD; END IF;
  RETURN NEW;
END
$function$;

CREATE OR REPLACE FUNCTION ${ns}."_check_catalog_graph_edge"(table_name TEXT, row_key TEXT) RETURNS VOID
LANGUAGE plpgsql VOLATILE AS $function$
DECLARE m JSONB; r JSONB; cyclic BOOLEAN;
BEGIN
  m := ${ns}."_catalog_graph_metadata"(table_name);
  IF m IS NULL THEN RAISE EXCEPTION 'Unknown catalog graph %', table_name; END IF;
  EXECUTE format('SELECT to_jsonb(edge) FROM %I.%I edge WHERE %I::text = $1',
    ${literal(schema.postgresSchema)}, table_name, m->>'pk') INTO r USING row_key;
  IF r IS NULL THEN RETURN; END IF;
  -- UNION deduplicates visited nodes: malformed existing cycles cannot recurse forever.
  EXECUTE format('WITH RECURSIVE reachable(node) AS (
      SELECT $1::bigint
      UNION SELECT edge.%I FROM %I.%I edge JOIN reachable ON edge.%I = reachable.node
      WHERE edge."Game_id" = $2::bigint
    ) SELECT EXISTS (SELECT 1 FROM reachable WHERE node = $3::bigint)',
    m->>'right', ${literal(schema.postgresSchema)}, table_name, m->>'left')
    INTO cyclic USING r->>(m->>'right'), r->>'Game_id', r->>(m->>'left');
  IF cyclic THEN
    RAISE EXCEPTION 'Cycle in % for game %, edge %', table_name, r->>'Game_id', row_key
      USING ERRCODE = '23514';
  END IF;
END
$function$;

CREATE OR REPLACE FUNCTION ${ns}."_catalog_graph_constraint"() RETURNS TRIGGER
LANGUAGE plpgsql VOLATILE AS $function$
DECLARE m JSONB;
BEGIN
  m := ${ns}."_catalog_graph_metadata"(TG_TABLE_NAME);
  PERFORM ${ns}."_check_catalog_graph_edge"(TG_TABLE_NAME, to_jsonb(NEW)->>(m->>'pk'));
  RETURN NULL;
END
$function$;
`;
  return sql + catalogGuardRules.noSelfEdges.map(({table}) => `
CREATE TRIGGER ${q(`tr_graph_write__${table}`)} BEFORE INSERT OR UPDATE OR DELETE ON ${ns}.${q(table)}
FOR EACH ROW EXECUTE FUNCTION ${ns}."_catalog_graph_write_lock"();
CREATE CONSTRAINT TRIGGER ${q(`ct_graph_cycle__${table}`)} AFTER INSERT OR UPDATE ON ${ns}.${q(table)}
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION ${ns}."_catalog_graph_constraint"();
`).join('\n');
}

export function validateExistingGraphsSql(schema, q, literal) {
  const ns = q(schema.postgresSchema);
  return `DO $validate_graphs$
DECLARE graph_name TEXT; edge_key TEXT; m JSONB;
BEGIN
  FOREACH graph_name IN ARRAY ARRAY[${catalogGuardRules.noSelfEdges.map(rule => literal(rule.table)).join(', ')}] LOOP
    m := ${ns}."_catalog_graph_metadata"(graph_name);
    FOR edge_key IN EXECUTE format('SELECT %I::text FROM %I.%I', m->>'pk', ${literal(schema.postgresSchema)}, graph_name) LOOP
      PERFORM ${ns}."_check_catalog_graph_edge"(graph_name, edge_key);
    END LOOP;
  END LOOP;
END
$validate_graphs$;`;
}
