-- Run only against an isolated, empty current schema after explicit approval.
-- psql --no-psqlrc --set ON_ERROR_STOP=1 --file relational-guards.sql <test database>
-- The transaction rolls back every fixture. This file does not start a server.
BEGIN;
SET LOCAL search_path = heroes_watch, pg_temp;
DO $empty$
BEGIN
  IF EXISTS (SELECT FROM "Game") THEN
    RAISE EXCEPTION 'Relational-guard fixtures require an empty isolated schema';
  END IF;
END
$empty$;

CREATE FUNCTION pg_temp.expect_rejected(label text, statement text, expected_codes text[])
RETURNS void LANGUAGE plpgsql AS $function$
DECLARE actual_code text;
BEGIN
  BEGIN
    EXECUTE statement;
    SET CONSTRAINTS ALL IMMEDIATE;
    RAISE EXCEPTION 'Unexpectedly accepted: %', label USING ERRCODE = 'P0001';
  EXCEPTION WHEN OTHERS THEN
    GET STACKED DIAGNOSTICS actual_code = RETURNED_SQLSTATE;
    IF NOT actual_code = ANY(expected_codes) THEN
      RAISE EXCEPTION '%: expected %, got % (%)', label, expected_codes, actual_code, SQLERRM;
    END IF;
  END;
  SET CONSTRAINTS ALL DEFERRED;
END
$function$;

INSERT INTO "Game" ("Game_id", "SeriesCode", "DisplayOrder", "Name") VALUES
  (-300, 'HOMM3', 3, 'Guard fixture III'),
  (-800, 'HOMM8', 8, 'Guard fixture VIII');
INSERT INTO "Resource" ("Resource_id", "Code", "Name") VALUES
  (-1, 'GUARD_RESOURCE_A', 'Guard resource A'),
  (-2, 'GUARD_RESOURCE_B', 'Guard resource B'),
  (-3, 'GUARD_RESOURCE_UNAVAILABLE', 'Guard unavailable resource');
INSERT INTO "GameResource" ("GameResource_cid", "Game_id", "Resource_id") VALUES
  ('guard.h8.resource.a', -800, -1),
  ('guard.h8.resource.b', -800, -2);
SET CONSTRAINTS ALL IMMEDIATE;
SET CONSTRAINTS ALL DEFERRED;
SELECT pg_temp.expect_rejected('GameResource truncate must use checked row deletion',
  'TRUNCATE "GameResource" CASCADE', ARRAY['23514']);
SELECT pg_temp.expect_rejected('cascaded parent truncate cannot bypass GameResource checks',
  'TRUNCATE "Resource" CASCADE', ARRAY['23514']);
INSERT INTO "Terrain" ("Terrain_id", "Game_id", "Code", "Name", "Kind")
VALUES (-801, -800, 'GUARD_TERRAIN', 'Guard terrain', 'Basic');
INSERT INTO "Skill" ("Skill_id", "Game_id", "Code", "Name")
VALUES (-801, -800, 'GUARD_SKILL', 'Guard skill');
INSERT INTO "Faction" ("Faction_id", "Game_id", "Code", "Name") VALUES
  (-301, -300, 'GUARD_TOWN_A', 'Guard town A'),
  (-302, -300, 'GUARD_TOWN_B', 'Guard town B'),
  (-801, -800, 'GUARD_H8', 'Guard H8 faction');

SELECT pg_temp.expect_rejected('HOMM8 signature resource must be a member of its game',
  'INSERT INTO "FactionHOMM8" ("Faction_id", "NativeTerrain_id", "SignatureResource_id", "FactionSkill_id", "NativeTerrainInitiativeBonus", "HasFactionLaw") VALUES (-801, -801, -3, -801, 0, false)',
  ARRAY['23514']);
INSERT INTO "FactionHOMM8" ("Faction_id", "NativeTerrain_id", "SignatureResource_id", "FactionSkill_id", "NativeTerrainInitiativeBonus", "HasFactionLaw")
VALUES (-801, -801, -1, -801, 0, false);
SET CONSTRAINTS ALL IMMEDIATE;
SET CONSTRAINTS ALL DEFERRED;
SELECT pg_temp.expect_rejected('used signature membership cannot be deleted',
  'DELETE FROM "GameResource" WHERE "Game_id" = -800 AND "Resource_id" = -1', ARRAY['23514']);
SELECT pg_temp.expect_rejected('used signature membership cannot be re-keyed',
  'UPDATE "GameResource" SET "Resource_id" = -3 WHERE "Game_id" = -800 AND "Resource_id" = -1', ARRAY['23514']);

INSERT INTO "MagicSchool" ("MagicSchool_id", "Game_id", "Code", "Name")
VALUES (-801, -800, 'GUARD_MAGIC', 'Guard magic');
SELECT pg_temp.expect_rejected('astrology resources must both be members of its game',
  'INSERT INTO "AstrologyHOMM8" ("Game_id", "NeutralMagicSchool_id", "AstrologyPointResource_id", "InsightResource_id", "MaximumSpellLevel", "UnlockRule", "UpgradeRule") VALUES (-800, -801, -2, -3, 5, ''Fixture unlock'', ''Fixture upgrade'')',
  ARRAY['23514']);
INSERT INTO "AstrologyHOMM8" ("Game_id", "NeutralMagicSchool_id", "AstrologyPointResource_id", "InsightResource_id", "MaximumSpellLevel", "UnlockRule", "UpgradeRule")
VALUES (-800, -801, -2, -1, 5, 'Fixture unlock', 'Fixture upgrade');
SET CONSTRAINTS ALL IMMEDIATE;
SET CONSTRAINTS ALL DEFERRED;
SELECT pg_temp.expect_rejected('used astrology membership cannot be deleted',
  'DELETE FROM "GameResource" WHERE "Game_id" = -800 AND "Resource_id" = -2', ARRAY['23514']);
SELECT pg_temp.expect_rejected('HOMM8 resource detail requires game membership',
  'INSERT INTO "ResourceHOMM8" ("Resource_id", "ResourceRole", "Scope", "IsTradeable", "IsMineProduced", "IsPersistent") VALUES (-3, ''Meter'', ''Combat'', false, false, false)',
  ARRAY['23514']);
INSERT INTO "ResourceHOMM8" ("Resource_id", "ResourceRole", "Scope", "IsTradeable", "IsMineProduced", "IsPersistent")
VALUES (-2, 'Meter', 'Combat', false, false, false);
SET CONSTRAINTS ALL IMMEDIATE;
SET CONSTRAINTS ALL DEFERRED;
DELETE FROM "FactionHOMM8";
DELETE FROM "AstrologyHOMM8";
SET CONSTRAINTS ALL IMMEDIATE;
SET CONSTRAINTS ALL DEFERRED;
SELECT pg_temp.expect_rejected('HOMM8 game identity cannot orphan ResourceHOMM8 detail rows',
  'UPDATE "Game" SET "SeriesCode" = ''HOMM7'' WHERE "Game_id" = -800', ARRAY['23514']);

INSERT INTO "Building" ("Building_id", "Game_id", "Code", "Name") VALUES
  (-311, -300, 'GUARD_KNOWN_A', 'Known building A'),
  (-312, -300, 'GUARD_KNOWN_B', 'Known building B'),
  (-313, -300, 'GUARD_GENERIC', 'Generic building'),
  (-314, -300, 'GUARD_UNKNOWN', 'Unknown-faction building');
INSERT INTO "BuildingHOMM3" ("Building_id", "Faction_id") VALUES
  (-311, -301), (-312, -302), (-314, NULL);
INSERT INTO "TownScreen" ("TownScreen_id", "Game_id", "Faction_id", "Code", "Name")
VALUES (-301, -300, -301, 'GUARD_SCREEN_A', 'Guard screen A');
INSERT INTO "TownScreenBuilding" ("TownScreenBuilding_cid", "Game_id", "TownScreen_id", "Building_id") VALUES
  ('guard.screen.known', -300, -301, -311),
  ('guard.screen.generic', -300, -301, -313),
  ('guard.screen.unknown', -300, -301, -314);
SET CONSTRAINTS ALL IMMEDIATE;
SET CONSTRAINTS ALL DEFERRED;

SELECT pg_temp.expect_rejected('known cross-faction building cannot be linked',
  'INSERT INTO "TownScreenBuilding" ("TownScreenBuilding_cid", "Game_id", "TownScreen_id", "Building_id") VALUES (''guard.screen.wrong'', -300, -301, -312)',
  ARRAY['23514']);
SELECT pg_temp.expect_rejected('building faction changes validate existing screen links',
  'UPDATE "BuildingHOMM3" SET "Faction_id" = -302 WHERE "Building_id" = -311', ARRAY['23514']);
SELECT pg_temp.expect_rejected('creating a detail validates links made while the building was generic',
  'INSERT INTO "BuildingHOMM3" ("Building_id", "Faction_id") VALUES (-313, -302)', ARRAY['23514']);
SELECT pg_temp.expect_rejected('town faction changes validate all existing building links',
  'UPDATE "TownScreen" SET "Faction_id" = -302 WHERE "TownScreen_id" = -301', ARRAY['23514']);

-- Optional/unknown building ownership remains representable, and unrelated edits remain ordinary writes.
UPDATE "TownScreenBuilding" SET "Hotspot" = '{"x":0,"y":0}'::jsonb
WHERE "TownScreenBuilding_cid" = 'guard.screen.unknown';
UPDATE "BuildingHOMM3" SET "Effect" = '{"verified":false}'::jsonb WHERE "Building_id" = -314;
SET CONSTRAINTS ALL IMMEDIATE;

ROLLBACK;
