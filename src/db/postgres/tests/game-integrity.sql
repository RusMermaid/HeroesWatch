-- Run only against an isolated, empty current schema after explicit approval.
-- psql --no-psqlrc --set ON_ERROR_STOP=1 --file game-integrity.sql <test database>
-- The transaction rolls back every fixture. This file does not start a server.
BEGIN;
SET LOCAL search_path = heroes_watch, pg_temp;
DO $empty$
BEGIN
  IF EXISTS (SELECT FROM "Game") THEN
    RAISE EXCEPTION 'Integrity fixtures require an empty isolated schema';
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
  (-200, 'HOMM2', 2, 'Integrity fixture II'),
  (-300, 'HOMM3', 3, 'Integrity fixture III'),
  (-500, 'HOMM5', 5, 'Integrity fixture V');
INSERT INTO "MediaAsset" ("MediaAsset_id", "Game_id", "Code", "Kind", "Name", "Uri") VALUES
  (-1, NULL, 'FIXTURE_GLOBAL', 'File', 'Global fixture source', 'fixture/global.pdf'),
  (-2, -200, 'FIXTURE_II', 'File', 'Game II fixture source', 'fixture/ii.pdf');
INSERT INTO "Creature" ("Creature_id", "Game_id", "Code", "Name", "MediaAsset_id") VALUES
  (-21, -200, 'FIXTURE_II', 'Game II creature', NULL),
  (-31, -300, 'FIXTURE_III', 'Game III creature', -1),
  (-32, -300, 'FIXTURE_FREE', 'Game III creature without details', NULL);
INSERT INTO "CreatureHOMM3" ("Creature_id", "DoubleUpgrade", "AlternativeUpgrade") VALUES (-31, false, false);
SET CONSTRAINTS ALL IMMEDIATE;
SET CONSTRAINTS ALL DEFERRED;

SELECT pg_temp.expect_rejected('wrong detail title',
  'INSERT INTO "CreatureHOMM3" ("Creature_id", "DoubleUpgrade", "AlternativeUpgrade") VALUES (-21, false, false)', ARRAY['23514']);
SELECT pg_temp.expect_rejected('wrong media game',
  'UPDATE "Creature" SET "MediaAsset_id" = -2 WHERE "Creature_id" = -31', ARRAY['23514']);
SELECT pg_temp.expect_rejected('parent reassignment checks inherited details',
  'UPDATE "Creature" SET "Game_id" = -200 WHERE "Creature_id" = -31', ARRAY['23514']);
SELECT pg_temp.expect_rejected('global media reassignment checks consumers',
  'UPDATE "MediaAsset" SET "Game_id" = -200 WHERE "MediaAsset_id" = -1', ARRAY['23514']);
SELECT pg_temp.expect_rejected('series rename checks inherited details',
  'UPDATE "Game" SET "SeriesCode" = ''FIXTURE_OTHER'' WHERE "Game_id" = -300', ARRAY['23514']);

-- A pending detail is judged by final state; removing it before the check is valid.
INSERT INTO "CreatureHOMM3" ("Creature_id", "DoubleUpgrade", "AlternativeUpgrade") VALUES (-21, false, false);
DELETE FROM "CreatureHOMM3" WHERE "Creature_id" = -21;
SET CONSTRAINTS ALL IMMEDIATE;
SET CONSTRAINTS ALL DEFERRED;

-- A transient owner mismatch that is repaired inside the transaction is valid.
UPDATE "Creature" SET "Game_id" = -200 WHERE "Creature_id" = -31;
UPDATE "Creature" SET "Game_id" = -300 WHERE "Creature_id" = -31;
SET CONSTRAINTS ALL IMMEDIATE;
SET CONSTRAINTS ALL DEFERRED;

-- Delete/reinsert with the same identity must validate the replacement row.
INSERT INTO "CreatureHOMM3" ("Creature_id", "DoubleUpgrade", "AlternativeUpgrade") VALUES (-32, false, false);
DELETE FROM "CreatureHOMM3" WHERE "Creature_id" = -32;
INSERT INTO "CreatureHOMM3" ("Creature_id", "DoubleUpgrade", "AlternativeUpgrade") VALUES (-32, false, false);
SET CONSTRAINTS ALL IMMEDIATE;
SELECT pg_temp.expect_rejected('later edit after immediate checks is still checked',
  'UPDATE "Creature" SET "MediaAsset_id" = -2 WHERE "Creature_id" = -32', ARRAY['23514']);

INSERT INTO "Resource" ("Resource_id", "Code", "Name") VALUES (-1, 'FIXTURE_RESOURCE', 'Fixture resource');
SELECT pg_temp.expect_rejected('resource exists but is unavailable in this game',
  'INSERT INTO "CreatureResourceCost" ("CreatureResourceCost_cid", "Game_id", "Creature_id", "Resource_id", "Amount") VALUES (''fixture.cost'', -300, -31, -1, 1)', ARRAY['23503']);

INSERT INTO "HeroClass" ("HeroClass_id", "Game_id", "Code", "Name") VALUES (-1, -500, 'FIXTURE_CLASS', 'Fixture class');
INSERT INTO "Ability" ("Ability_id", "Game_id", "Code", "Name") VALUES
  (-1, -500, 'FIXTURE_GRANTED', 'Granted ability'), (-2, -500, 'FIXTURE_A', 'Prerequisite A'), (-3, -500, 'FIXTURE_B', 'Prerequisite B');
INSERT INTO "HeroClassAbilityRequirementGroup" ("HeroClassAbilityRequirementGroup_cid", "Game_id", "HeroClass_id", "Ability_id", "RequirementSet", "RequirementMode")
VALUES ('fixture.group.1', -500, -1, -1, 1, 'All'), ('fixture.group.2', -500, -1, -1, 2, 'Any');
INSERT INTO "HeroClassAbility" ("HeroClassAbility_cid", "Game_id", "HeroClass_id", "Ability_id", "RequiredAbility_id", "RequirementSet", "RequirementMode") VALUES
  ('fixture.atom.a', -500, -1, -1, -2, 1, 'All'),
  ('fixture.atom.b', -500, -1, -1, -3, 1, 'All'),
  ('fixture.alternative.a', -500, -1, -1, -2, 2, 'Any');
SET CONSTRAINTS ALL IMMEDIATE;
SET CONSTRAINTS ALL DEFERRED;
SELECT pg_temp.expect_rejected('duplicate prerequisite atom with nullable fields',
  'INSERT INTO "HeroClassAbility" ("HeroClassAbility_cid", "Game_id", "HeroClass_id", "Ability_id", "RequiredAbility_id", "RequirementSet", "RequirementMode") VALUES (''fixture.duplicate'', -500, -1, -1, -2, 1, ''All'')', ARRAY['23505']);
SELECT pg_temp.expect_rejected('an atom cannot change its group mode',
  'UPDATE "HeroClassAbility" SET "RequirementMode" = ''Any'' WHERE "HeroClassAbility_cid" = ''fixture.atom.a''', ARRAY['23503']);
SELECT pg_temp.expect_rejected('a mode cannot exist without a numbered group',
  'UPDATE "HeroClassAbility" SET "RequirementSet" = NULL WHERE "HeroClassAbility_cid" = ''fixture.atom.a''', ARRAY['23514']);

INSERT INTO "ArtifactSetHOMM5" ("ArtifactSetHOMM5_id", "Code", "Name") VALUES (-1, 'FIXTURE_SET', 'Fixture set');
INSERT INTO "ArtifactSetBonusHOMM5" ("ArtifactSetBonusHOMM5_id", "ArtifactSetHOMM5_id", "RequiredPieceCount", "HeroClass_id", "Effect")
VALUES (-1, -1, 2, NULL, '{}');
SELECT pg_temp.expect_rejected('null class bonus identity is unique',
  'INSERT INTO "ArtifactSetBonusHOMM5" ("ArtifactSetBonusHOMM5_id", "ArtifactSetHOMM5_id", "RequiredPieceCount", "HeroClass_id", "Effect") VALUES (-2, -1, 2, NULL, ''{}'')', ARRAY['23505']);

SET CONSTRAINTS ALL IMMEDIATE;
ROLLBACK;
