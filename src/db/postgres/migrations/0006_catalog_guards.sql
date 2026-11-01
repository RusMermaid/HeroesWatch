-- Generated forward migration from overlay version 5 to version 6.
-- Apply once after 0005_creature_numeric_speed.sql.
-- Adds static catalog guards without deleting, rewriting, or deduplicating content.
BEGIN;

LOCK TABLE "heroes_watch"."ArtifactComponent", "heroes_watch"."ArtifactResourceCost", "heroes_watch"."BuildingRequirement", "heroes_watch"."BuildingResourceCost", "heroes_watch"."BuildingUpgrade", "heroes_watch"."CreatureResourceCost", "heroes_watch"."CreatureUpgrade", "heroes_watch"."LoreFull", "heroes_watch"."ScenarioConnection", "heroes_watch"."SpellResourceCostHOMM5" IN ACCESS EXCLUSIVE MODE;

ALTER TABLE "heroes_watch"."ArtifactResourceCost" ADD CONSTRAINT "ck__ArtifactResourceCost__Amount_nonnegative" CHECK ("Amount" >= 0);
ALTER TABLE "heroes_watch"."BuildingResourceCost" ADD CONSTRAINT "ck__BuildingResourceCost__Amount_nonnegative" CHECK ("Amount" >= 0);
ALTER TABLE "heroes_watch"."CreatureResourceCost" ADD CONSTRAINT "ck__CreatureResourceCost__Amount_nonnegative" CHECK ("Amount" >= 0);
ALTER TABLE "heroes_watch"."SpellResourceCostHOMM5" ADD CONSTRAINT "ck__SpellResourceCostHOMM5__Amount_nonnegative" CHECK ("Amount" >= 0);
ALTER TABLE "heroes_watch"."LoreFull" ADD CONSTRAINT "ck__LoreFull__has_subject" CHECK (num_nonnulls("Hero_id", "CampaignHero_cid", "Campaign_id", "Scenario_id", "Map_id", "Faction_id") >= 1);
ALTER TABLE "heroes_watch"."ArtifactComponent" ADD CONSTRAINT "ck__ArtifactComponent__no_self_edge" CHECK ("CompositeArtifact_id" <> "ComponentArtifact_id");
ALTER TABLE "heroes_watch"."BuildingRequirement" ADD CONSTRAINT "ck__BuildingRequirement__no_self_edge" CHECK ("Building_id" <> "RequiredBuilding_id");
ALTER TABLE "heroes_watch"."BuildingUpgrade" ADD CONSTRAINT "ck__BuildingUpgrade__no_self_edge" CHECK ("BaseBuilding_id" <> "UpgradedBuilding_id");
ALTER TABLE "heroes_watch"."CreatureUpgrade" ADD CONSTRAINT "ck__CreatureUpgrade__no_self_edge" CHECK ("BaseCreature_id" <> "UpgradedCreature_id");
ALTER TABLE "heroes_watch"."ScenarioConnection" ADD CONSTRAINT "ck__ScenarioConnection__no_self_edge" CHECK ("FromScenario_id" <> "ToScenario_id");

-- Cross-row production guards which cannot be represented by ordinary foreign keys.
-- Checks are deferred so a transaction may repair temporary intermediate states.
-- The relevant parent rows are locked, preventing write skew at READ COMMITTED
-- and SERIALIZABLE. Relevant writes at REPEATABLE READ are rejected because an
-- older snapshot could otherwise hide a dependent row committed after a wait.
-- Replace the v2 helper with the intended detail-title fallback. Resource and
-- MediaAsset are genuinely global parents; their HOMM detail bands inherit the
-- title named by the detail table, not NULL ownership from the parent row.
CREATE OR REPLACE FUNCTION "heroes_watch"."_scope_owner"(table_name text, row_key text) RETURNS bigint
LANGUAGE plpgsql VOLATILE AS $function$
DECLARE m jsonb; r jsonb; result bigint; inherited bigint;
BEGIN
  IF row_key IS NULL THEN RETURN NULL; END IF;
  m := "heroes_watch"."_scope_metadata"(table_name);
  r := "heroes_watch"."_scope_row"(table_name, row_key);
  IF r IS NULL THEN RETURN NULL; END IF;
  IF (m->>'direct')::boolean THEN RETURN (r->>'Game_id')::bigint; END IF;
  IF m->'owner' <> 'null'::jsonb AND r->>(m->'owner'->>'column') IS NOT NULL THEN
    inherited := "heroes_watch"."_scope_owner"(m->'owner'->>'table', r->>(m->'owner'->>'column'));
    IF inherited IS NOT NULL THEN RETURN inherited; END IF;
  END IF;
  IF m->>'expected' IS NOT NULL THEN
    SELECT "Game_id" INTO result FROM "heroes_watch"."Game" WHERE "SeriesCode" = m->>'expected' FOR SHARE;
    RETURN result;
  END IF;
  RETURN NULL;
END
$function$;

CREATE OR REPLACE FUNCTION "heroes_watch"."_require_game_resource"(expected_game bigint, resource_key bigint, context_name text) RETURNS void
LANGUAGE plpgsql VOLATILE AS $function$
BEGIN
  IF expected_game IS NULL OR resource_key IS NULL THEN
    RAISE EXCEPTION '% has no resolvable game or resource', context_name USING ERRCODE = '23514';
  END IF;
  PERFORM 1 FROM "heroes_watch"."GameResource"
    WHERE "Game_id" = expected_game AND "Resource_id" = resource_key
    FOR KEY SHARE;
  IF NOT FOUND THEN
    RAISE EXCEPTION '% resource % is not available in game %', context_name, resource_key, expected_game
      USING ERRCODE = '23514';
  END IF;
END
$function$;

CREATE OR REPLACE FUNCTION "heroes_watch"."_check_homm8_resource_row"(table_name text, row_key text) RETURNS void
LANGUAGE plpgsql VOLATILE AS $function$
DECLARE row_data jsonb; owner_game bigint;
BEGIN
  row_data := "heroes_watch"."_scope_row"(table_name, row_key);
  IF row_data IS NULL THEN RETURN; END IF;
  owner_game := "heroes_watch"."_scope_owner"(table_name, row_key);
  IF table_name = 'FactionHOMM8' THEN
    PERFORM "heroes_watch"."_require_game_resource"(
      owner_game, (row_data->>'SignatureResource_id')::bigint,
      'FactionHOMM8(' || row_key || ').SignatureResource_id');
  ELSIF table_name = 'AstrologyHOMM8' THEN
    PERFORM "heroes_watch"."_require_game_resource"(
      owner_game, (row_data->>'AstrologyPointResource_id')::bigint,
      'AstrologyHOMM8(' || row_key || ').AstrologyPointResource_id');
    PERFORM "heroes_watch"."_require_game_resource"(
      owner_game, (row_data->>'InsightResource_id')::bigint,
      'AstrologyHOMM8(' || row_key || ').InsightResource_id');
  ELSIF table_name = 'ResourceHOMM8' THEN
    PERFORM "heroes_watch"."_require_game_resource"(
      owner_game, (row_data->>'Resource_id')::bigint,
      'ResourceHOMM8(' || row_key || ').Resource_id');
  ELSE
    RAISE EXCEPTION 'Unknown HOMM8 resource consumer: %', table_name;
  END IF;
END
$function$;

CREATE OR REPLACE FUNCTION "heroes_watch"."_production_resource_consumer_constraint"() RETURNS trigger
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
  row_data := "heroes_watch"."_scope_row"(TG_TABLE_NAME, row_key);
  IF row_data IS NULL THEN RETURN NULL; END IF;
  IF current_setting('transaction_isolation') = 'repeatable read' THEN
    RAISE EXCEPTION 'HOMM8 resource-membership writes require READ COMMITTED or SERIALIZABLE'
      USING ERRCODE = '0A000', HINT = 'Retry the whole transaction using READ COMMITTED or SERIALIZABLE.';
  END IF;
  PERFORM "heroes_watch"."_check_homm8_resource_row"(TG_TABLE_NAME, row_key);
  RETURN NULL;
END
$function$;

CREATE OR REPLACE FUNCTION "heroes_watch"."_production_game_resource_reverse_constraint"() RETURNS trigger
LANGUAGE plpgsql VOLATILE AS $function$
BEGIN
  IF TG_OP = 'UPDATE'
     AND NEW."Game_id" IS NOT DISTINCT FROM OLD."Game_id"
     AND NEW."Resource_id" IS NOT DISTINCT FROM OLD."Resource_id" THEN
    RETURN NULL;
  END IF;
  -- Replacing a physical GameResource row with the same business key is valid.
  PERFORM 1 FROM "heroes_watch"."GameResource"
    WHERE "Game_id" = OLD."Game_id" AND "Resource_id" = OLD."Resource_id"
    FOR KEY SHARE;
  IF FOUND THEN RETURN NULL; END IF;
  IF current_setting('transaction_isolation') = 'repeatable read' THEN
    RAISE EXCEPTION 'Removing or re-keying GameResource membership requires READ COMMITTED or SERIALIZABLE'
      USING ERRCODE = '0A000', HINT = 'Retry the whole transaction using READ COMMITTED or SERIALIZABLE.';
  END IF;
  IF EXISTS (
    SELECT 1 FROM "heroes_watch"."FactionHOMM8" detail
      JOIN "heroes_watch"."Faction" owner ON owner."Faction_id" = detail."Faction_id"
      WHERE owner."Game_id" = OLD."Game_id" AND detail."SignatureResource_id" = OLD."Resource_id"
  ) OR EXISTS (
    SELECT 1 FROM "heroes_watch"."AstrologyHOMM8"
      WHERE "Game_id" = OLD."Game_id"
        AND ("AstrologyPointResource_id" = OLD."Resource_id" OR "InsightResource_id" = OLD."Resource_id")
  ) OR EXISTS (
    SELECT 1 FROM "heroes_watch"."ResourceHOMM8"
      WHERE "Resource_id" = OLD."Resource_id"
        AND "heroes_watch"."_scope_owner"('ResourceHOMM8', "Resource_id"::text) = OLD."Game_id"
  ) THEN
    RAISE EXCEPTION 'GameResource(%, %) is still required by a HOMM8 resource consumer', OLD."Game_id", OLD."Resource_id"
      USING ERRCODE = '23514';
  END IF;
  RETURN NULL;
END
$function$;

CREATE OR REPLACE FUNCTION "heroes_watch"."_production_game_resource_truncate_guard"() RETURNS trigger
LANGUAGE plpgsql VOLATILE AS $function$
BEGIN
  RAISE EXCEPTION 'GameResource cannot be truncated because HOMM8 resource membership requires checked row deletion'
    USING ERRCODE = '23514',
      HINT = 'Use DELETE so deferred resource-membership and reverse-reference safeguards can validate every removed row.';
END
$function$;

CREATE OR REPLACE FUNCTION "heroes_watch"."_production_faction_owner_constraint"() RETURNS trigger
LANGUAGE plpgsql VOLATILE AS $function$
DECLARE current_game bigint;
BEGIN
  IF NEW."Game_id" IS NOT DISTINCT FROM OLD."Game_id"
     AND NEW."Faction_id" IS NOT DISTINCT FROM OLD."Faction_id" THEN RETURN NULL; END IF;
  SELECT "Game_id" INTO current_game FROM "heroes_watch"."Faction"
    WHERE "Faction_id" = NEW."Faction_id" FOR SHARE;
  IF NOT FOUND OR NOT EXISTS (
    SELECT 1 FROM "heroes_watch"."FactionHOMM8" WHERE "Faction_id" = NEW."Faction_id"
  ) THEN RETURN NULL; END IF;
  IF current_setting('transaction_isolation') = 'repeatable read' THEN
    RAISE EXCEPTION 'Changing the owner of a FactionHOMM8 row requires READ COMMITTED or SERIALIZABLE'
      USING ERRCODE = '0A000', HINT = 'Retry the whole transaction using READ COMMITTED or SERIALIZABLE.';
  END IF;
  PERFORM "heroes_watch"."_check_homm8_resource_row"('FactionHOMM8', NEW."Faction_id"::text);
  RETURN NULL;
END
$function$;

CREATE OR REPLACE FUNCTION "heroes_watch"."_production_homm8_game_owner_constraint"() RETURNS trigger
LANGUAGE plpgsql VOLATILE AS $function$
DECLARE resource_key bigint;
BEGIN
  IF NEW."Game_id" IS NOT DISTINCT FROM OLD."Game_id"
     AND NEW."SeriesCode" IS NOT DISTINCT FROM OLD."SeriesCode" THEN RETURN NULL; END IF;
  IF OLD."SeriesCode" IS DISTINCT FROM 'HOMM8'
     AND NEW."SeriesCode" IS DISTINCT FROM 'HOMM8' THEN RETURN NULL; END IF;
  IF NOT EXISTS (SELECT 1 FROM "heroes_watch"."ResourceHOMM8") THEN RETURN NULL; END IF;
  IF current_setting('transaction_isolation') = 'repeatable read' THEN
    RAISE EXCEPTION 'Changing the HOMM8 game identity while ResourceHOMM8 exists requires READ COMMITTED or SERIALIZABLE'
      USING ERRCODE = '0A000', HINT = 'Retry the whole transaction using READ COMMITTED or SERIALIZABLE.';
  END IF;
  FOR resource_key IN SELECT "Resource_id" FROM "heroes_watch"."ResourceHOMM8" ORDER BY "Resource_id" LOOP
    PERFORM "heroes_watch"."_check_scope_row"('ResourceHOMM8', resource_key::text);
    PERFORM "heroes_watch"."_check_homm8_resource_row"('ResourceHOMM8', resource_key::text);
  END LOOP;
  RETURN NULL;
END
$function$;

CREATE OR REPLACE FUNCTION "heroes_watch"."_known_building_factions"(building_key bigint) RETURNS SETOF bigint
LANGUAGE sql VOLATILE AS $function$
  SELECT "Faction_id" FROM "heroes_watch"."BuildingHOMM1" WHERE "Building_id" = building_key AND "Faction_id" IS NOT NULL
    UNION ALL
    SELECT "Faction_id" FROM "heroes_watch"."BuildingHOMM2" WHERE "Building_id" = building_key AND "Faction_id" IS NOT NULL
    UNION ALL
    SELECT "Faction_id" FROM "heroes_watch"."BuildingHOMM3" WHERE "Building_id" = building_key AND "Faction_id" IS NOT NULL
    UNION ALL
    SELECT "Faction_id" FROM "heroes_watch"."BuildingHOMM4" WHERE "Building_id" = building_key AND "Faction_id" IS NOT NULL
    UNION ALL
    SELECT "Faction_id" FROM "heroes_watch"."BuildingHOMM5" WHERE "Building_id" = building_key AND "Faction_id" IS NOT NULL
    UNION ALL
    SELECT "Faction_id" FROM "heroes_watch"."BuildingHOMM6" WHERE "Building_id" = building_key AND "Faction_id" IS NOT NULL
    UNION ALL
    SELECT "Faction_id" FROM "heroes_watch"."BuildingHOMM7" WHERE "Building_id" = building_key AND "Faction_id" IS NOT NULL
    UNION ALL
    SELECT "Faction_id" FROM "heroes_watch"."BuildingHOMM8" WHERE "Building_id" = building_key AND "Faction_id" IS NOT NULL;
$function$;

CREATE OR REPLACE FUNCTION "heroes_watch"."_assert_town_building_faction"(screen_key bigint, building_key bigint, lock_screen boolean DEFAULT true) RETURNS void
LANGUAGE plpgsql VOLATILE AS $function$
DECLARE screen_faction bigint; anchor bigint; detail_faction bigint;
BEGIN
  IF lock_screen THEN
    SELECT "Faction_id" INTO screen_faction FROM "heroes_watch"."TownScreen"
      WHERE "TownScreen_id" = screen_key FOR SHARE;
  ELSE
    SELECT "Faction_id" INTO screen_faction FROM "heroes_watch"."TownScreen"
      WHERE "TownScreen_id" = screen_key;
  END IF;
  IF NOT FOUND THEN RETURN; END IF;
  SELECT "Building_id" INTO anchor FROM "heroes_watch"."Building"
    WHERE "Building_id" = building_key FOR UPDATE;
  IF NOT FOUND THEN RETURN; END IF;
  SELECT known."Faction_id" INTO detail_faction
    FROM "heroes_watch"."_known_building_factions"(building_key) AS known("Faction_id")
    WHERE known."Faction_id" <> screen_faction LIMIT 1;
  IF FOUND THEN
    RAISE EXCEPTION 'TownScreen % faction % cannot display Building % faction %',
      screen_key, screen_faction, building_key, detail_faction USING ERRCODE = '23514';
  END IF;
END
$function$;

CREATE OR REPLACE FUNCTION "heroes_watch"."_check_building_town_screens"(building_key bigint) RETURNS void
LANGUAGE plpgsql VOLATILE AS $function$
DECLARE anchor bigint; link record; detail_faction bigint;
BEGIN
  SELECT "Building_id" INTO anchor FROM "heroes_watch"."Building"
    WHERE "Building_id" = building_key FOR UPDATE;
  IF NOT FOUND THEN RETURN; END IF;
  FOR link IN
    SELECT junction."TownScreen_id", screen."Faction_id"
      FROM "heroes_watch"."TownScreenBuilding" junction
      JOIN "heroes_watch"."TownScreen" screen ON screen."TownScreen_id" = junction."TownScreen_id"
      WHERE junction."Building_id" = building_key
      ORDER BY junction."TownScreen_id"
  LOOP
    SELECT known."Faction_id" INTO detail_faction
      FROM "heroes_watch"."_known_building_factions"(building_key) AS known("Faction_id")
      WHERE known."Faction_id" <> link."Faction_id" LIMIT 1;
    IF FOUND THEN
      RAISE EXCEPTION 'TownScreen % faction % cannot display Building % faction %',
        link."TownScreen_id", link."Faction_id", building_key, detail_faction USING ERRCODE = '23514';
    END IF;
  END LOOP;
END
$function$;

CREATE OR REPLACE FUNCTION "heroes_watch"."_check_town_screen_buildings"(screen_key bigint) RETURNS void
LANGUAGE plpgsql VOLATILE AS $function$
DECLARE screen_faction bigint; building_key bigint; detail_faction bigint; anchor bigint;
BEGIN
  SELECT "Faction_id" INTO screen_faction FROM "heroes_watch"."TownScreen"
    WHERE "TownScreen_id" = screen_key FOR SHARE;
  IF NOT FOUND THEN RETURN; END IF;
  FOR building_key IN
    SELECT "Building_id" FROM "heroes_watch"."TownScreenBuilding"
      WHERE "TownScreen_id" = screen_key ORDER BY "Building_id"
  LOOP
    SELECT "Building_id" INTO anchor FROM "heroes_watch"."Building"
      WHERE "Building_id" = building_key FOR UPDATE;
    SELECT known."Faction_id" INTO detail_faction
      FROM "heroes_watch"."_known_building_factions"(building_key) AS known("Faction_id")
      WHERE known."Faction_id" <> screen_faction LIMIT 1;
    IF FOUND THEN
      RAISE EXCEPTION 'TownScreen % faction % cannot display Building % faction %',
        screen_key, screen_faction, building_key, detail_faction USING ERRCODE = '23514';
    END IF;
  END LOOP;
END
$function$;

CREATE OR REPLACE FUNCTION "heroes_watch"."_production_town_link_constraint"() RETURNS trigger
LANGUAGE plpgsql VOLATILE AS $function$
DECLARE current_screen bigint; current_building bigint;
BEGIN
  IF TG_OP = 'UPDATE'
     AND NEW."TownScreenBuilding_cid" IS NOT DISTINCT FROM OLD."TownScreenBuilding_cid"
     AND NEW."TownScreen_id" IS NOT DISTINCT FROM OLD."TownScreen_id"
     AND NEW."Building_id" IS NOT DISTINCT FROM OLD."Building_id" THEN RETURN NULL; END IF;
  SELECT "TownScreen_id", "Building_id" INTO current_screen, current_building
    FROM "heroes_watch"."TownScreenBuilding"
    WHERE "TownScreenBuilding_cid" = NEW."TownScreenBuilding_cid" FOR SHARE;
  IF NOT FOUND THEN RETURN NULL; END IF;
  IF current_setting('transaction_isolation') = 'repeatable read' THEN
    RAISE EXCEPTION 'Town-screen building links require READ COMMITTED or SERIALIZABLE'
      USING ERRCODE = '0A000', HINT = 'Retry the whole transaction using READ COMMITTED or SERIALIZABLE.';
  END IF;
  PERFORM "heroes_watch"."_assert_town_building_faction"(current_screen, current_building, true);
  RETURN NULL;
END
$function$;

CREATE OR REPLACE FUNCTION "heroes_watch"."_production_building_detail_constraint"() RETURNS trigger
LANGUAGE plpgsql VOLATILE AS $function$
DECLARE current_faction bigint; matched_rows bigint;
BEGIN
  IF TG_OP = 'UPDATE'
     AND NEW."Building_id" IS NOT DISTINCT FROM OLD."Building_id"
     AND NEW."Faction_id" IS NOT DISTINCT FROM OLD."Faction_id" THEN RETURN NULL; END IF;
  EXECUTE format('SELECT "Faction_id" FROM %I.%I WHERE "Building_id" = $1',
    'heroes_watch', TG_TABLE_NAME) INTO current_faction USING NEW."Building_id";
  GET DIAGNOSTICS matched_rows = ROW_COUNT;
  IF matched_rows = 0 OR current_faction IS NULL THEN RETURN NULL; END IF;
  IF current_setting('transaction_isolation') = 'repeatable read' THEN
    RAISE EXCEPTION 'Building faction-detail writes require READ COMMITTED or SERIALIZABLE'
      USING ERRCODE = '0A000', HINT = 'Retry the whole transaction using READ COMMITTED or SERIALIZABLE.';
  END IF;
  PERFORM "heroes_watch"."_check_building_town_screens"(NEW."Building_id");
  RETURN NULL;
END
$function$;

CREATE OR REPLACE FUNCTION "heroes_watch"."_production_town_screen_constraint"() RETURNS trigger
LANGUAGE plpgsql VOLATILE AS $function$
DECLARE current_faction bigint;
BEGIN
  IF NEW."TownScreen_id" IS NOT DISTINCT FROM OLD."TownScreen_id"
     AND NEW."Faction_id" IS NOT DISTINCT FROM OLD."Faction_id" THEN RETURN NULL; END IF;
  SELECT "Faction_id" INTO current_faction FROM "heroes_watch"."TownScreen"
    WHERE "TownScreen_id" = NEW."TownScreen_id" FOR SHARE;
  IF NOT FOUND THEN RETURN NULL; END IF;
  IF current_setting('transaction_isolation') = 'repeatable read' THEN
    RAISE EXCEPTION 'Town-screen faction writes require READ COMMITTED or SERIALIZABLE'
      USING ERRCODE = '0A000', HINT = 'Retry the whole transaction using READ COMMITTED or SERIALIZABLE.';
  END IF;
  PERFORM "heroes_watch"."_check_town_screen_buildings"(NEW."TownScreen_id");
  RETURN NULL;
END
$function$;

CREATE CONSTRAINT TRIGGER "ct_production_resource__FactionHOMM8"
AFTER INSERT OR UPDATE ON "heroes_watch"."FactionHOMM8"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_production_resource_consumer_constraint"();

CREATE CONSTRAINT TRIGGER "ct_production_resource__AstrologyHOMM8"
AFTER INSERT OR UPDATE ON "heroes_watch"."AstrologyHOMM8"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_production_resource_consumer_constraint"();

CREATE CONSTRAINT TRIGGER "ct_production_resource__ResourceHOMM8"
AFTER INSERT OR UPDATE ON "heroes_watch"."ResourceHOMM8"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_production_resource_consumer_constraint"();

CREATE CONSTRAINT TRIGGER "ct_production_resource_reverse__GameResource"
AFTER DELETE OR UPDATE ON "heroes_watch"."GameResource"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_production_game_resource_reverse_constraint"();

CREATE TRIGGER "tr_production_resource_truncate__GameResource"
BEFORE TRUNCATE ON "heroes_watch"."GameResource"
FOR EACH STATEMENT EXECUTE FUNCTION "heroes_watch"."_production_game_resource_truncate_guard"();

CREATE CONSTRAINT TRIGGER "ct_production_resource_owner__Faction"
AFTER UPDATE ON "heroes_watch"."Faction"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_production_faction_owner_constraint"();

CREATE CONSTRAINT TRIGGER "ct_production_resource_owner__Game"
AFTER UPDATE ON "heroes_watch"."Game"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_production_homm8_game_owner_constraint"();

CREATE CONSTRAINT TRIGGER "ct_production_town_link__TownScreenBuilding"
AFTER INSERT OR UPDATE ON "heroes_watch"."TownScreenBuilding"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_production_town_link_constraint"();

CREATE CONSTRAINT TRIGGER "ct_production_town_detail__BuildingHOMM1"
AFTER INSERT OR UPDATE ON "heroes_watch"."BuildingHOMM1"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_production_building_detail_constraint"();

CREATE CONSTRAINT TRIGGER "ct_production_town_detail__BuildingHOMM2"
AFTER INSERT OR UPDATE ON "heroes_watch"."BuildingHOMM2"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_production_building_detail_constraint"();

CREATE CONSTRAINT TRIGGER "ct_production_town_detail__BuildingHOMM3"
AFTER INSERT OR UPDATE ON "heroes_watch"."BuildingHOMM3"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_production_building_detail_constraint"();

CREATE CONSTRAINT TRIGGER "ct_production_town_detail__BuildingHOMM4"
AFTER INSERT OR UPDATE ON "heroes_watch"."BuildingHOMM4"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_production_building_detail_constraint"();

CREATE CONSTRAINT TRIGGER "ct_production_town_detail__BuildingHOMM5"
AFTER INSERT OR UPDATE ON "heroes_watch"."BuildingHOMM5"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_production_building_detail_constraint"();

CREATE CONSTRAINT TRIGGER "ct_production_town_detail__BuildingHOMM6"
AFTER INSERT OR UPDATE ON "heroes_watch"."BuildingHOMM6"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_production_building_detail_constraint"();

CREATE CONSTRAINT TRIGGER "ct_production_town_detail__BuildingHOMM7"
AFTER INSERT OR UPDATE ON "heroes_watch"."BuildingHOMM7"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_production_building_detail_constraint"();

CREATE CONSTRAINT TRIGGER "ct_production_town_detail__BuildingHOMM8"
AFTER INSERT OR UPDATE ON "heroes_watch"."BuildingHOMM8"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_production_building_detail_constraint"();

CREATE CONSTRAINT TRIGGER "ct_production_town_screen__TownScreen"
AFTER UPDATE ON "heroes_watch"."TownScreen"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_production_town_screen_constraint"();

-- Catalog dependency/progression graphs are directed acyclic graphs.
-- The existing conditions and cross-campaign edges remain valid; only cycles fail.
CREATE OR REPLACE FUNCTION "heroes_watch"."_catalog_graph_metadata"(table_name TEXT) RETURNS JSONB
LANGUAGE sql IMMUTABLE STRICT AS $function$
  SELECT '{"ArtifactComponent":{"table":"ArtifactComponent","left":"CompositeArtifact_id","right":"ComponentArtifact_id","pk":"ArtifactComponent_cid"},"BuildingRequirement":{"table":"BuildingRequirement","left":"Building_id","right":"RequiredBuilding_id","pk":"BuildingRequirement_cid"},"BuildingUpgrade":{"table":"BuildingUpgrade","left":"BaseBuilding_id","right":"UpgradedBuilding_id","pk":"BuildingUpgrade_cid"},"CreatureUpgrade":{"table":"CreatureUpgrade","left":"BaseCreature_id","right":"UpgradedCreature_id","pk":"CreatureUpgrade_cid"},"ScenarioConnection":{"table":"ScenarioConnection","left":"FromScenario_id","right":"ToScenario_id","pk":"ScenarioConnection_cid"}}'::jsonb -> table_name
$function$;

CREATE OR REPLACE FUNCTION "heroes_watch"."_catalog_graph_write_lock"() RETURNS TRIGGER
LANGUAGE plpgsql VOLATILE AS $function$
DECLARE m JSONB; old_row JSONB; new_row JSONB; lock_id BIGINT; game_ids TEXT[];
BEGIN
  m := "heroes_watch"."_catalog_graph_metadata"(TG_TABLE_NAME);
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

CREATE OR REPLACE FUNCTION "heroes_watch"."_check_catalog_graph_edge"(table_name TEXT, row_key TEXT) RETURNS VOID
LANGUAGE plpgsql VOLATILE AS $function$
DECLARE m JSONB; r JSONB; cyclic BOOLEAN;
BEGIN
  m := "heroes_watch"."_catalog_graph_metadata"(table_name);
  IF m IS NULL THEN RAISE EXCEPTION 'Unknown catalog graph %', table_name; END IF;
  EXECUTE format('SELECT to_jsonb(edge) FROM %I.%I edge WHERE %I::text = $1',
    'heroes_watch', table_name, m->>'pk') INTO r USING row_key;
  IF r IS NULL THEN RETURN; END IF;
  -- UNION deduplicates visited nodes: malformed existing cycles cannot recurse forever.
  EXECUTE format('WITH RECURSIVE reachable(node) AS (
      SELECT $1::bigint
      UNION SELECT edge.%I FROM %I.%I edge JOIN reachable ON edge.%I = reachable.node
      WHERE edge."Game_id" = $2::bigint
    ) SELECT EXISTS (SELECT 1 FROM reachable WHERE node = $3::bigint)',
    m->>'right', 'heroes_watch', table_name, m->>'left')
    INTO cyclic USING r->>(m->>'right'), r->>'Game_id', r->>(m->>'left');
  IF cyclic THEN
    RAISE EXCEPTION 'Cycle in % for game %, edge %', table_name, r->>'Game_id', row_key
      USING ERRCODE = '23514';
  END IF;
END
$function$;

CREATE OR REPLACE FUNCTION "heroes_watch"."_catalog_graph_constraint"() RETURNS TRIGGER
LANGUAGE plpgsql VOLATILE AS $function$
DECLARE m JSONB;
BEGIN
  m := "heroes_watch"."_catalog_graph_metadata"(TG_TABLE_NAME);
  PERFORM "heroes_watch"."_check_catalog_graph_edge"(TG_TABLE_NAME, to_jsonb(NEW)->>(m->>'pk'));
  RETURN NULL;
END
$function$;

CREATE TRIGGER "tr_graph_write__ArtifactComponent" BEFORE INSERT OR UPDATE OR DELETE ON "heroes_watch"."ArtifactComponent"
FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_catalog_graph_write_lock"();
CREATE CONSTRAINT TRIGGER "ct_graph_cycle__ArtifactComponent" AFTER INSERT OR UPDATE ON "heroes_watch"."ArtifactComponent"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_catalog_graph_constraint"();


CREATE TRIGGER "tr_graph_write__BuildingRequirement" BEFORE INSERT OR UPDATE OR DELETE ON "heroes_watch"."BuildingRequirement"
FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_catalog_graph_write_lock"();
CREATE CONSTRAINT TRIGGER "ct_graph_cycle__BuildingRequirement" AFTER INSERT OR UPDATE ON "heroes_watch"."BuildingRequirement"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_catalog_graph_constraint"();


CREATE TRIGGER "tr_graph_write__BuildingUpgrade" BEFORE INSERT OR UPDATE OR DELETE ON "heroes_watch"."BuildingUpgrade"
FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_catalog_graph_write_lock"();
CREATE CONSTRAINT TRIGGER "ct_graph_cycle__BuildingUpgrade" AFTER INSERT OR UPDATE ON "heroes_watch"."BuildingUpgrade"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_catalog_graph_constraint"();


CREATE TRIGGER "tr_graph_write__CreatureUpgrade" BEFORE INSERT OR UPDATE OR DELETE ON "heroes_watch"."CreatureUpgrade"
FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_catalog_graph_write_lock"();
CREATE CONSTRAINT TRIGGER "ct_graph_cycle__CreatureUpgrade" AFTER INSERT OR UPDATE ON "heroes_watch"."CreatureUpgrade"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_catalog_graph_constraint"();


CREATE TRIGGER "tr_graph_write__ScenarioConnection" BEFORE INSERT OR UPDATE OR DELETE ON "heroes_watch"."ScenarioConnection"
FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_catalog_graph_write_lock"();
CREATE CONSTRAINT TRIGGER "ct_graph_cycle__ScenarioConnection" AFTER INSERT OR UPDATE ON "heroes_watch"."ScenarioConnection"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_catalog_graph_constraint"();


-- Block affected writers while the upgrade validates every existing cross-row relationship.
LOCK TABLE "heroes_watch"."AstrologyHOMM8", "heroes_watch"."Building", "heroes_watch"."BuildingHOMM1", "heroes_watch"."BuildingHOMM2", "heroes_watch"."BuildingHOMM3", "heroes_watch"."BuildingHOMM4", "heroes_watch"."BuildingHOMM5", "heroes_watch"."BuildingHOMM6", "heroes_watch"."BuildingHOMM7", "heroes_watch"."BuildingHOMM8", "heroes_watch"."Faction", "heroes_watch"."FactionHOMM8", "heroes_watch"."GameResource", "heroes_watch"."ResourceHOMM8", "heroes_watch"."TownScreen", "heroes_watch"."TownScreenBuilding" IN SHARE ROW EXCLUSIVE MODE;

DO $validate_production_guards$
DECLARE row_key text; link record;
BEGIN
  FOR row_key IN SELECT "Faction_id"::text FROM "heroes_watch"."FactionHOMM8" LOOP
    PERFORM "heroes_watch"."_check_homm8_resource_row"('FactionHOMM8', row_key);
  END LOOP;
  FOR row_key IN SELECT "Game_id"::text FROM "heroes_watch"."AstrologyHOMM8" LOOP
    PERFORM "heroes_watch"."_check_homm8_resource_row"('AstrologyHOMM8', row_key);
  END LOOP;
  FOR row_key IN SELECT "Resource_id"::text FROM "heroes_watch"."ResourceHOMM8" LOOP
    PERFORM "heroes_watch"."_check_homm8_resource_row"('ResourceHOMM8', row_key);
  END LOOP;
  FOR link IN SELECT "TownScreen_id", "Building_id" FROM "heroes_watch"."TownScreenBuilding" ORDER BY "TownScreenBuilding_cid" LOOP
    PERFORM "heroes_watch"."_assert_town_building_faction"(link."TownScreen_id", link."Building_id", false);
  END LOOP;
END
$validate_production_guards$;

DO $validate_graphs$
DECLARE graph_name TEXT; edge_key TEXT; m JSONB;
BEGIN
  FOREACH graph_name IN ARRAY ARRAY['ArtifactComponent', 'BuildingRequirement', 'BuildingUpgrade', 'CreatureUpgrade', 'ScenarioConnection'] LOOP
    m := "heroes_watch"."_catalog_graph_metadata"(graph_name);
    FOR edge_key IN EXECUTE format('SELECT %I::text FROM %I.%I', m->>'pk', 'heroes_watch', graph_name) LOOP
      PERFORM "heroes_watch"."_check_catalog_graph_edge"(graph_name, edge_key);
    END LOOP;
  END LOOP;
END
$validate_graphs$;

COMMIT;
