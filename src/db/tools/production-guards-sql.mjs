const BUILDING_DETAIL_TABLES = Object.freeze(
  Array.from({ length: 8 }, (_, index) => `BuildingHOMM${index + 1}`),
);

function requireSchemaObjects(schema) {
  const tables = new Map(schema.tables.map((table) => [table.name, table]));
  const required = {
    AstrologyHOMM8: ["Game_id", "AstrologyPointResource_id", "InsightResource_id"],
    Building: ["Building_id"],
    Faction: ["Faction_id", "Game_id"],
    FactionHOMM8: ["Faction_id", "SignatureResource_id"],
    GameResource: ["Game_id", "Resource_id"],
    ResourceHOMM8: ["Resource_id"],
    TownScreen: ["TownScreen_id", "Faction_id"],
    TownScreenBuilding: ["TownScreenBuilding_cid", "TownScreen_id", "Building_id"],
    ...Object.fromEntries(BUILDING_DETAIL_TABLES.map((name) => [name, ["Building_id", "Faction_id"]])),
  };
  for (const [tableName, columns] of Object.entries(required)) {
    const table = tables.get(tableName);
    if (!table) throw new Error(`Production guards require table ${tableName}`);
    const names = new Set(table.columns.map((column) => column.name));
    for (const column of columns) {
      if (!names.has(column)) throw new Error(`Production guards require ${tableName}.${column}`);
    }
  }
}

export function productionGuardsSql(schema, quoteIdent, quoteLiteral, { replace = true } = {}) {
  requireSchemaObjects(schema);
  const q = quoteIdent;
  const l = quoteLiteral;
  const ns = q(schema.postgresSchema);
  const create = replace ? "CREATE OR REPLACE FUNCTION" : "CREATE FUNCTION";
  const detailUnion = BUILDING_DETAIL_TABLES.map((table) =>
    `SELECT "Faction_id" FROM ${ns}.${q(table)} WHERE "Building_id" = building_key AND "Faction_id" IS NOT NULL`,
  ).join("\n    UNION ALL\n    ");

  return `-- Cross-row production guards which cannot be represented by ordinary foreign keys.
-- Checks are deferred so a transaction may repair temporary intermediate states.
-- The relevant parent rows are locked, preventing write skew at READ COMMITTED
-- and SERIALIZABLE. Relevant writes at REPEATABLE READ are rejected because an
-- older snapshot could otherwise hide a dependent row committed after a wait.
-- Replace the v2 helper with the intended detail-title fallback. Resource and
-- MediaAsset are genuinely global parents; their HOMM detail bands inherit the
-- title named by the detail table, not NULL ownership from the parent row.
CREATE OR REPLACE FUNCTION ${ns}."_scope_owner"(table_name text, row_key text) RETURNS bigint
LANGUAGE plpgsql VOLATILE AS $function$
DECLARE m jsonb; r jsonb; result bigint; inherited bigint;
BEGIN
  IF row_key IS NULL THEN RETURN NULL; END IF;
  m := ${ns}."_scope_metadata"(table_name);
  r := ${ns}."_scope_row"(table_name, row_key);
  IF r IS NULL THEN RETURN NULL; END IF;
  IF (m->>'direct')::boolean THEN RETURN (r->>'Game_id')::bigint; END IF;
  IF m->'owner' <> 'null'::jsonb AND r->>(m->'owner'->>'column') IS NOT NULL THEN
    inherited := ${ns}."_scope_owner"(m->'owner'->>'table', r->>(m->'owner'->>'column'));
    IF inherited IS NOT NULL THEN RETURN inherited; END IF;
  END IF;
  IF m->>'expected' IS NOT NULL THEN
    SELECT "Game_id" INTO result FROM ${ns}."Game" WHERE "SeriesCode" = m->>'expected' FOR SHARE;
    RETURN result;
  END IF;
  RETURN NULL;
END
$function$;

${create} ${ns}."_require_game_resource"(expected_game bigint, resource_key bigint, context_name text) RETURNS void
LANGUAGE plpgsql VOLATILE AS $function$
BEGIN
  IF expected_game IS NULL OR resource_key IS NULL THEN
    RAISE EXCEPTION '% has no resolvable game or resource', context_name USING ERRCODE = '23514';
  END IF;
  PERFORM 1 FROM ${ns}."GameResource"
    WHERE "Game_id" = expected_game AND "Resource_id" = resource_key
    FOR KEY SHARE;
  IF NOT FOUND THEN
    RAISE EXCEPTION '% resource % is not available in game %', context_name, resource_key, expected_game
      USING ERRCODE = '23514';
  END IF;
END
$function$;

${create} ${ns}."_check_homm8_resource_row"(table_name text, row_key text) RETURNS void
LANGUAGE plpgsql VOLATILE AS $function$
DECLARE row_data jsonb; owner_game bigint;
BEGIN
  row_data := ${ns}."_scope_row"(table_name, row_key);
  IF row_data IS NULL THEN RETURN; END IF;
  owner_game := ${ns}."_scope_owner"(table_name, row_key);
  IF table_name = 'FactionHOMM8' THEN
    PERFORM ${ns}."_require_game_resource"(
      owner_game, (row_data->>'SignatureResource_id')::bigint,
      'FactionHOMM8(' || row_key || ').SignatureResource_id');
  ELSIF table_name = 'AstrologyHOMM8' THEN
    PERFORM ${ns}."_require_game_resource"(
      owner_game, (row_data->>'AstrologyPointResource_id')::bigint,
      'AstrologyHOMM8(' || row_key || ').AstrologyPointResource_id');
    PERFORM ${ns}."_require_game_resource"(
      owner_game, (row_data->>'InsightResource_id')::bigint,
      'AstrologyHOMM8(' || row_key || ').InsightResource_id');
  ELSIF table_name = 'ResourceHOMM8' THEN
    PERFORM ${ns}."_require_game_resource"(
      owner_game, (row_data->>'Resource_id')::bigint,
      'ResourceHOMM8(' || row_key || ').Resource_id');
  ELSE
    RAISE EXCEPTION 'Unknown HOMM8 resource consumer: %', table_name;
  END IF;
END
$function$;

${create} ${ns}."_production_resource_consumer_constraint"() RETURNS trigger
LANGUAGE plpgsql VOLATILE AS $function$
DECLARE row_key text; row_data jsonb; new_data jsonb; old_data jsonb;
BEGIN
  new_data := to_jsonb(NEW);
  IF TG_OP = 'UPDATE' THEN old_data := to_jsonb(OLD); END IF;
  IF TG_OP = 'UPDATE' AND TG_TABLE_NAME = 'FactionHOMM8'
     AND new_data->'Faction_id' IS NOT DISTINCT FROM old_data->'Faction_id'
     AND new_data->'SignatureResource_id' IS NOT DISTINCT FROM old_data->'SignatureResource_id' THEN
    RETURN NULL;
  ELSIF TG_OP = 'UPDATE' AND TG_TABLE_NAME = 'AstrologyHOMM8'
     AND new_data->'Game_id' IS NOT DISTINCT FROM old_data->'Game_id'
     AND new_data->'AstrologyPointResource_id' IS NOT DISTINCT FROM old_data->'AstrologyPointResource_id'
     AND new_data->'InsightResource_id' IS NOT DISTINCT FROM old_data->'InsightResource_id' THEN
    RETURN NULL;
  ELSIF TG_OP = 'UPDATE' AND TG_TABLE_NAME = 'ResourceHOMM8'
     AND new_data->'Resource_id' IS NOT DISTINCT FROM old_data->'Resource_id' THEN
    RETURN NULL;
  END IF;
  IF TG_TABLE_NAME = 'FactionHOMM8' THEN
    row_key := new_data->>'Faction_id';
  ELSIF TG_TABLE_NAME = 'ResourceHOMM8' THEN
    row_key := new_data->>'Resource_id';
  ELSE
    row_key := new_data->>'Game_id';
  END IF;
  row_data := ${ns}."_scope_row"(TG_TABLE_NAME, row_key);
  IF row_data IS NULL THEN RETURN NULL; END IF;
  IF current_setting('transaction_isolation') = 'repeatable read' THEN
    RAISE EXCEPTION 'HOMM8 resource-membership writes require READ COMMITTED or SERIALIZABLE'
      USING ERRCODE = '0A000', HINT = 'Retry the whole transaction using READ COMMITTED or SERIALIZABLE.';
  END IF;
  PERFORM ${ns}."_check_homm8_resource_row"(TG_TABLE_NAME, row_key);
  RETURN NULL;
END
$function$;

${create} ${ns}."_production_game_resource_reverse_constraint"() RETURNS trigger
LANGUAGE plpgsql VOLATILE AS $function$
BEGIN
  IF TG_OP = 'UPDATE'
     AND NEW."Game_id" IS NOT DISTINCT FROM OLD."Game_id"
     AND NEW."Resource_id" IS NOT DISTINCT FROM OLD."Resource_id" THEN
    RETURN NULL;
  END IF;
  -- Replacing a physical GameResource row with the same business key is valid.
  PERFORM 1 FROM ${ns}."GameResource"
    WHERE "Game_id" = OLD."Game_id" AND "Resource_id" = OLD."Resource_id"
    FOR KEY SHARE;
  IF FOUND THEN RETURN NULL; END IF;
  IF current_setting('transaction_isolation') = 'repeatable read' THEN
    RAISE EXCEPTION 'Removing or re-keying GameResource membership requires READ COMMITTED or SERIALIZABLE'
      USING ERRCODE = '0A000', HINT = 'Retry the whole transaction using READ COMMITTED or SERIALIZABLE.';
  END IF;
  IF EXISTS (
    SELECT 1 FROM ${ns}."FactionHOMM8" detail
      JOIN ${ns}."Faction" owner ON owner."Faction_id" = detail."Faction_id"
      WHERE owner."Game_id" = OLD."Game_id" AND detail."SignatureResource_id" = OLD."Resource_id"
  ) OR EXISTS (
    SELECT 1 FROM ${ns}."AstrologyHOMM8"
      WHERE "Game_id" = OLD."Game_id"
        AND ("AstrologyPointResource_id" = OLD."Resource_id" OR "InsightResource_id" = OLD."Resource_id")
  ) OR EXISTS (
    SELECT 1 FROM ${ns}."ResourceHOMM8"
      WHERE "Resource_id" = OLD."Resource_id"
        AND ${ns}."_scope_owner"('ResourceHOMM8', "Resource_id"::text) = OLD."Game_id"
  ) THEN
    RAISE EXCEPTION 'GameResource(%, %) is still required by a HOMM8 resource consumer', OLD."Game_id", OLD."Resource_id"
      USING ERRCODE = '23514';
  END IF;
  RETURN NULL;
END
$function$;

${create} ${ns}."_production_game_resource_truncate_guard"() RETURNS trigger
LANGUAGE plpgsql VOLATILE AS $function$
BEGIN
  RAISE EXCEPTION 'GameResource cannot be truncated because HOMM8 resource membership requires checked row deletion'
    USING ERRCODE = '23514',
      HINT = 'Use DELETE so deferred resource-membership and reverse-reference safeguards can validate every removed row.';
END
$function$;

${create} ${ns}."_production_faction_owner_constraint"() RETURNS trigger
LANGUAGE plpgsql VOLATILE AS $function$
DECLARE current_game bigint;
BEGIN
  IF NEW."Game_id" IS NOT DISTINCT FROM OLD."Game_id"
     AND NEW."Faction_id" IS NOT DISTINCT FROM OLD."Faction_id" THEN RETURN NULL; END IF;
  SELECT "Game_id" INTO current_game FROM ${ns}."Faction"
    WHERE "Faction_id" = NEW."Faction_id" FOR SHARE;
  IF NOT FOUND OR NOT EXISTS (
    SELECT 1 FROM ${ns}."FactionHOMM8" WHERE "Faction_id" = NEW."Faction_id"
  ) THEN RETURN NULL; END IF;
  IF current_setting('transaction_isolation') = 'repeatable read' THEN
    RAISE EXCEPTION 'Changing the owner of a FactionHOMM8 row requires READ COMMITTED or SERIALIZABLE'
      USING ERRCODE = '0A000', HINT = 'Retry the whole transaction using READ COMMITTED or SERIALIZABLE.';
  END IF;
  PERFORM ${ns}."_check_homm8_resource_row"('FactionHOMM8', NEW."Faction_id"::text);
  RETURN NULL;
END
$function$;

${create} ${ns}."_production_homm8_game_owner_constraint"() RETURNS trigger
LANGUAGE plpgsql VOLATILE AS $function$
DECLARE resource_key bigint;
BEGIN
  IF NEW."Game_id" IS NOT DISTINCT FROM OLD."Game_id"
     AND NEW."SeriesCode" IS NOT DISTINCT FROM OLD."SeriesCode" THEN RETURN NULL; END IF;
  IF OLD."SeriesCode" IS DISTINCT FROM 'HOMM8'
     AND NEW."SeriesCode" IS DISTINCT FROM 'HOMM8' THEN RETURN NULL; END IF;
  IF NOT EXISTS (SELECT 1 FROM ${ns}."ResourceHOMM8") THEN RETURN NULL; END IF;
  IF current_setting('transaction_isolation') = 'repeatable read' THEN
    RAISE EXCEPTION 'Changing the HOMM8 game identity while ResourceHOMM8 exists requires READ COMMITTED or SERIALIZABLE'
      USING ERRCODE = '0A000', HINT = 'Retry the whole transaction using READ COMMITTED or SERIALIZABLE.';
  END IF;
  FOR resource_key IN SELECT "Resource_id" FROM ${ns}."ResourceHOMM8" ORDER BY "Resource_id" LOOP
    PERFORM ${ns}."_check_scope_row"('ResourceHOMM8', resource_key::text);
    PERFORM ${ns}."_check_homm8_resource_row"('ResourceHOMM8', resource_key::text);
  END LOOP;
  RETURN NULL;
END
$function$;

${create} ${ns}."_known_building_factions"(building_key bigint) RETURNS SETOF bigint
LANGUAGE sql VOLATILE AS $function$
  ${detailUnion};
$function$;

${create} ${ns}."_assert_town_building_faction"(screen_key bigint, building_key bigint, lock_screen boolean DEFAULT true) RETURNS void
LANGUAGE plpgsql VOLATILE AS $function$
DECLARE screen_faction bigint; anchor bigint; detail_faction bigint;
BEGIN
  IF lock_screen THEN
    SELECT "Faction_id" INTO screen_faction FROM ${ns}."TownScreen"
      WHERE "TownScreen_id" = screen_key FOR SHARE;
  ELSE
    SELECT "Faction_id" INTO screen_faction FROM ${ns}."TownScreen"
      WHERE "TownScreen_id" = screen_key;
  END IF;
  IF NOT FOUND THEN RETURN; END IF;
  SELECT "Building_id" INTO anchor FROM ${ns}."Building"
    WHERE "Building_id" = building_key FOR UPDATE;
  IF NOT FOUND THEN RETURN; END IF;
  SELECT known."Faction_id" INTO detail_faction
    FROM ${ns}."_known_building_factions"(building_key) AS known("Faction_id")
    WHERE known."Faction_id" <> screen_faction LIMIT 1;
  IF FOUND THEN
    RAISE EXCEPTION 'TownScreen % faction % cannot display Building % faction %',
      screen_key, screen_faction, building_key, detail_faction USING ERRCODE = '23514';
  END IF;
END
$function$;

${create} ${ns}."_check_building_town_screens"(building_key bigint) RETURNS void
LANGUAGE plpgsql VOLATILE AS $function$
DECLARE anchor bigint; link record; detail_faction bigint;
BEGIN
  SELECT "Building_id" INTO anchor FROM ${ns}."Building"
    WHERE "Building_id" = building_key FOR UPDATE;
  IF NOT FOUND THEN RETURN; END IF;
  FOR link IN
    SELECT junction."TownScreen_id", screen."Faction_id"
      FROM ${ns}."TownScreenBuilding" junction
      JOIN ${ns}."TownScreen" screen ON screen."TownScreen_id" = junction."TownScreen_id"
      WHERE junction."Building_id" = building_key
      ORDER BY junction."TownScreen_id"
  LOOP
    SELECT known."Faction_id" INTO detail_faction
      FROM ${ns}."_known_building_factions"(building_key) AS known("Faction_id")
      WHERE known."Faction_id" <> link."Faction_id" LIMIT 1;
    IF FOUND THEN
      RAISE EXCEPTION 'TownScreen % faction % cannot display Building % faction %',
        link."TownScreen_id", link."Faction_id", building_key, detail_faction USING ERRCODE = '23514';
    END IF;
  END LOOP;
END
$function$;

${create} ${ns}."_check_town_screen_buildings"(screen_key bigint) RETURNS void
LANGUAGE plpgsql VOLATILE AS $function$
DECLARE screen_faction bigint; building_key bigint; detail_faction bigint; anchor bigint;
BEGIN
  SELECT "Faction_id" INTO screen_faction FROM ${ns}."TownScreen"
    WHERE "TownScreen_id" = screen_key FOR SHARE;
  IF NOT FOUND THEN RETURN; END IF;
  FOR building_key IN
    SELECT "Building_id" FROM ${ns}."TownScreenBuilding"
      WHERE "TownScreen_id" = screen_key ORDER BY "Building_id"
  LOOP
    SELECT "Building_id" INTO anchor FROM ${ns}."Building"
      WHERE "Building_id" = building_key FOR UPDATE;
    SELECT known."Faction_id" INTO detail_faction
      FROM ${ns}."_known_building_factions"(building_key) AS known("Faction_id")
      WHERE known."Faction_id" <> screen_faction LIMIT 1;
    IF FOUND THEN
      RAISE EXCEPTION 'TownScreen % faction % cannot display Building % faction %',
        screen_key, screen_faction, building_key, detail_faction USING ERRCODE = '23514';
    END IF;
  END LOOP;
END
$function$;

${create} ${ns}."_production_town_link_constraint"() RETURNS trigger
LANGUAGE plpgsql VOLATILE AS $function$
DECLARE current_screen bigint; current_building bigint;
BEGIN
  IF TG_OP = 'UPDATE'
     AND NEW."TownScreenBuilding_cid" IS NOT DISTINCT FROM OLD."TownScreenBuilding_cid"
     AND NEW."TownScreen_id" IS NOT DISTINCT FROM OLD."TownScreen_id"
     AND NEW."Building_id" IS NOT DISTINCT FROM OLD."Building_id" THEN RETURN NULL; END IF;
  SELECT "TownScreen_id", "Building_id" INTO current_screen, current_building
    FROM ${ns}."TownScreenBuilding"
    WHERE "TownScreenBuilding_cid" = NEW."TownScreenBuilding_cid" FOR SHARE;
  IF NOT FOUND THEN RETURN NULL; END IF;
  IF current_setting('transaction_isolation') = 'repeatable read' THEN
    RAISE EXCEPTION 'Town-screen building links require READ COMMITTED or SERIALIZABLE'
      USING ERRCODE = '0A000', HINT = 'Retry the whole transaction using READ COMMITTED or SERIALIZABLE.';
  END IF;
  PERFORM ${ns}."_assert_town_building_faction"(current_screen, current_building, true);
  RETURN NULL;
END
$function$;

${create} ${ns}."_production_building_detail_constraint"() RETURNS trigger
LANGUAGE plpgsql VOLATILE AS $function$
DECLARE current_faction bigint; matched_rows bigint;
BEGIN
  IF TG_OP = 'UPDATE'
     AND NEW."Building_id" IS NOT DISTINCT FROM OLD."Building_id"
     AND NEW."Faction_id" IS NOT DISTINCT FROM OLD."Faction_id" THEN RETURN NULL; END IF;
  EXECUTE format('SELECT "Faction_id" FROM %I.%I WHERE "Building_id" = $1',
    ${l(schema.postgresSchema)}, TG_TABLE_NAME) INTO current_faction USING NEW."Building_id";
  GET DIAGNOSTICS matched_rows = ROW_COUNT;
  IF matched_rows = 0 OR current_faction IS NULL THEN RETURN NULL; END IF;
  IF current_setting('transaction_isolation') = 'repeatable read' THEN
    RAISE EXCEPTION 'Building faction-detail writes require READ COMMITTED or SERIALIZABLE'
      USING ERRCODE = '0A000', HINT = 'Retry the whole transaction using READ COMMITTED or SERIALIZABLE.';
  END IF;
  PERFORM ${ns}."_check_building_town_screens"(NEW."Building_id");
  RETURN NULL;
END
$function$;

${create} ${ns}."_production_town_screen_constraint"() RETURNS trigger
LANGUAGE plpgsql VOLATILE AS $function$
DECLARE current_faction bigint;
BEGIN
  IF NEW."TownScreen_id" IS NOT DISTINCT FROM OLD."TownScreen_id"
     AND NEW."Faction_id" IS NOT DISTINCT FROM OLD."Faction_id" THEN RETURN NULL; END IF;
  SELECT "Faction_id" INTO current_faction FROM ${ns}."TownScreen"
    WHERE "TownScreen_id" = NEW."TownScreen_id" FOR SHARE;
  IF NOT FOUND THEN RETURN NULL; END IF;
  IF current_setting('transaction_isolation') = 'repeatable read' THEN
    RAISE EXCEPTION 'Town-screen faction writes require READ COMMITTED or SERIALIZABLE'
      USING ERRCODE = '0A000', HINT = 'Retry the whole transaction using READ COMMITTED or SERIALIZABLE.';
  END IF;
  PERFORM ${ns}."_check_town_screen_buildings"(NEW."TownScreen_id");
  RETURN NULL;
END
$function$;

CREATE CONSTRAINT TRIGGER ${q("ct_production_resource__FactionHOMM8")}
AFTER INSERT OR UPDATE ON ${ns}."FactionHOMM8"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION ${ns}."_production_resource_consumer_constraint"();

CREATE CONSTRAINT TRIGGER ${q("ct_production_resource__AstrologyHOMM8")}
AFTER INSERT OR UPDATE ON ${ns}."AstrologyHOMM8"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION ${ns}."_production_resource_consumer_constraint"();

CREATE CONSTRAINT TRIGGER ${q("ct_production_resource__ResourceHOMM8")}
AFTER INSERT OR UPDATE ON ${ns}."ResourceHOMM8"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION ${ns}."_production_resource_consumer_constraint"();

CREATE CONSTRAINT TRIGGER ${q("ct_production_resource_reverse__GameResource")}
AFTER DELETE OR UPDATE ON ${ns}."GameResource"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION ${ns}."_production_game_resource_reverse_constraint"();

CREATE TRIGGER ${q("tr_production_resource_truncate__GameResource")}
BEFORE TRUNCATE ON ${ns}."GameResource"
FOR EACH STATEMENT EXECUTE FUNCTION ${ns}."_production_game_resource_truncate_guard"();

CREATE CONSTRAINT TRIGGER ${q("ct_production_resource_owner__Faction")}
AFTER UPDATE ON ${ns}."Faction"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION ${ns}."_production_faction_owner_constraint"();

CREATE CONSTRAINT TRIGGER ${q("ct_production_resource_owner__Game")}
AFTER UPDATE ON ${ns}."Game"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION ${ns}."_production_homm8_game_owner_constraint"();

CREATE CONSTRAINT TRIGGER ${q("ct_production_town_link__TownScreenBuilding")}
AFTER INSERT OR UPDATE ON ${ns}."TownScreenBuilding"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION ${ns}."_production_town_link_constraint"();

${BUILDING_DETAIL_TABLES.map((table) => `CREATE CONSTRAINT TRIGGER ${q(`ct_production_town_detail__${table}`)}
AFTER INSERT OR UPDATE ON ${ns}.${q(table)}
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION ${ns}."_production_building_detail_constraint"();`).join("\n\n")}

CREATE CONSTRAINT TRIGGER ${q("ct_production_town_screen__TownScreen")}
AFTER UPDATE ON ${ns}."TownScreen"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION ${ns}."_production_town_screen_constraint"();`;
}

export function validateExistingProductionGuardsSql(schema, quoteIdent, quoteLiteral) {
  requireSchemaObjects(schema);
  const q = quoteIdent;
  const l = quoteLiteral;
  const ns = q(schema.postgresSchema);
  const lockTables = [
    "AstrologyHOMM8", "Building", ...BUILDING_DETAIL_TABLES, "Faction", "FactionHOMM8",
    "GameResource", "ResourceHOMM8", "TownScreen", "TownScreenBuilding",
  ].sort();
  return `-- Block affected writers while the upgrade validates every existing cross-row relationship.
LOCK TABLE ${lockTables.map((table) => `${ns}.${q(table)}`).join(", ")} IN SHARE ROW EXCLUSIVE MODE;

DO $validate_production_guards$
DECLARE row_key text; link record;
BEGIN
  FOR row_key IN SELECT "Faction_id"::text FROM ${ns}."FactionHOMM8" LOOP
    PERFORM ${ns}."_check_homm8_resource_row"('FactionHOMM8', row_key);
  END LOOP;
  FOR row_key IN SELECT "Game_id"::text FROM ${ns}."AstrologyHOMM8" LOOP
    PERFORM ${ns}."_check_homm8_resource_row"('AstrologyHOMM8', row_key);
  END LOOP;
  FOR row_key IN SELECT "Resource_id"::text FROM ${ns}."ResourceHOMM8" LOOP
    PERFORM ${ns}."_check_homm8_resource_row"('ResourceHOMM8', row_key);
  END LOOP;
  FOR link IN SELECT "TownScreen_id", "Building_id" FROM ${ns}."TownScreenBuilding" ORDER BY "TownScreenBuilding_cid" LOOP
    PERFORM ${ns}."_assert_town_building_faction"(link."TownScreen_id", link."Building_id", false);
  END LOOP;
END
$validate_production_guards$;`;
}

export { BUILDING_DETAIL_TABLES };
