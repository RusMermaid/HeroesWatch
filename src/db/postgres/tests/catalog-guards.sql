-- Isolated empty-schema tests. Every fixture is rolled back.
BEGIN;
SET LOCAL search_path = heroes_watch, pg_temp;
DO $empty$ BEGIN
  IF EXISTS (SELECT 1 FROM "Game") THEN RAISE EXCEPTION 'Use an empty test schema'; END IF;
END $empty$;
CREATE FUNCTION pg_temp.reject_catalog(statement TEXT) RETURNS VOID LANGUAGE plpgsql AS $fn$
BEGIN
  BEGIN
    EXECUTE statement;
    SET CONSTRAINTS ALL IMMEDIATE;
    RAISE EXCEPTION 'Invalid catalog write accepted: %', statement;
  EXCEPTION WHEN check_violation THEN NULL;
  END;
  SET CONSTRAINTS ALL DEFERRED;
END $fn$;
INSERT INTO "Game" ("Game_id","SeriesCode","DisplayOrder","Name") VALUES (-401,'HOMM3',3,'Fixture');
INSERT INTO "Creature" ("Creature_id","Game_id","Code","Name") VALUES
  (-401,-401,'A','A'),(-402,-401,'B','B'),(-403,-401,'C','C');
INSERT INTO "Resource" ("Resource_id","Code","Name") VALUES (-401,'FIXTURE','Fixture');
INSERT INTO "GameResource" ("GameResource_cid","Game_id","Resource_id") VALUES ('fixture.resource',-401,-401);
SELECT pg_temp.reject_catalog('INSERT INTO "CreatureResourceCost" ("CreatureResourceCost_cid","Game_id","Creature_id","Resource_id","Amount") VALUES (''bad.cost'',-401,-401,-401,-1)');
INSERT INTO "CreatureResourceCost" ("CreatureResourceCost_cid","Game_id","Creature_id","Resource_id","Amount") VALUES ('zero.cost',-401,-401,-401,0);
INSERT INTO "CreatureUpgrade" ("CreatureUpgrade_cid","Game_id","BaseCreature_id","UpgradedCreature_id") VALUES
  ('a.b',-401,-401,-402),('b.c',-401,-402,-403);
SET CONSTRAINTS ALL IMMEDIATE;
SET CONSTRAINTS ALL DEFERRED;
SELECT pg_temp.reject_catalog('INSERT INTO "CreatureUpgrade" ("CreatureUpgrade_cid","Game_id","BaseCreature_id","UpgradedCreature_id") VALUES (''c.a'',-401,-403,-401)');
SELECT pg_temp.reject_catalog('INSERT INTO "CreatureUpgrade" ("CreatureUpgrade_cid","Game_id","BaseCreature_id","UpgradedCreature_id") VALUES (''a.a'',-401,-401,-401)');
INSERT INTO "Faction" ("Faction_id","Game_id","Code","Name") VALUES (-401,-401,'A','A');
INSERT INTO "Hero" ("Hero_id","Game_id","Code","Name") VALUES (-401,-401,'A','A');
INSERT INTO "Lore" ("Lore_id","Game_id","Code","Title","LoreKind","Body") VALUES (-401,-401,'A','A','Other','Fixture');
SELECT pg_temp.reject_catalog('INSERT INTO "LoreFull" ("LoreFull_cid","Game_id","Lore_id") VALUES (''empty.subject'',-401,-401)');
INSERT INTO "LoreFull" ("LoreFull_cid","Game_id","Lore_id","Hero_id","Faction_id") VALUES ('context.lore',-401,-401,-401,-401);
INSERT INTO "Artifact" ("Artifact_id","Game_id","Code","Name") VALUES (-401,-401,'A','A'),(-402,-401,'B','B'),(-403,-401,'C','C');
INSERT INTO "Building" ("Building_id","Game_id","Code","Name") VALUES (-401,-401,'A','A'),(-402,-401,'B','B'),(-403,-401,'C','C');
INSERT INTO "Map" ("Map_id","Game_id","Code","Name") VALUES (-401,-401,'A','A');
INSERT INTO "Scenario" ("Scenario_id","Game_id","Map_id","Code","Name") VALUES (-401,-401,-401,'A','A'),(-402,-401,-401,'B','B'),(-403,-401,-401,'C','C');
DO $graphs$
DECLARE entry RECORD; prefix TEXT;
BEGIN
  FOR entry IN SELECT * FROM (VALUES
    ('ArtifactComponent','CompositeArtifact_id','ComponentArtifact_id'),
    ('BuildingRequirement','Building_id','RequiredBuilding_id'),
    ('BuildingUpgrade','BaseBuilding_id','UpgradedBuilding_id'),
    ('ScenarioConnection','FromScenario_id','ToScenario_id')
  ) rules(tab,l,r) LOOP
    prefix := format('INSERT INTO %I (%I,"Game_id",%I,%I) VALUES ', entry.tab, entry.tab || '_cid', entry.l, entry.r);
    EXECUTE prefix || format('(%L,-401,-401,-402),(%L,-401,-402,-403)', entry.tab||'.ab',entry.tab||'.bc');
    SET CONSTRAINTS ALL IMMEDIATE;
    SET CONSTRAINTS ALL DEFERRED;
    PERFORM pg_temp.reject_catalog(prefix || format('(%L,-401,-403,-401)',entry.tab||'.cycle'));
    PERFORM pg_temp.reject_catalog(prefix || format('(%L,-401,-401,-401)',entry.tab||'.self'));
  END LOOP;
END
$graphs$;
SELECT pg_temp.reject_catalog('INSERT INTO "ArtifactResourceCost" ("ArtifactResourceCost_cid","Game_id","Artifact_id","Resource_id","Amount") VALUES (''bad.artifact.cost'',-401,-401,-401,-1)');
SELECT pg_temp.reject_catalog('INSERT INTO "BuildingResourceCost" ("BuildingResourceCost_cid","Game_id","Building_id","Resource_id","Amount") VALUES (''bad.building.cost'',-401,-401,-401,-1)');
INSERT INTO "Game" ("Game_id","SeriesCode","DisplayOrder","Name") VALUES (-501,'HOMM5',5,'Fixture H5');
INSERT INTO "Spell" ("Spell_id","Game_id","Code","Name") VALUES (-501,-501,'A','A');
INSERT INTO "GameResource" ("GameResource_cid","Game_id","Resource_id") VALUES ('fixture.resource.h5',-501,-401);
SELECT pg_temp.reject_catalog('INSERT INTO "SpellResourceCostHOMM5" ("SpellResourceCostHOMM5_cid","Game_id","Spell_id","Resource_id","Amount","Ruleset") VALUES (''bad.spell.cost'',-501,-501,-401,-1,''BaseGame'')');
-- A temporarily cyclic transaction may repair itself before constraint time.
INSERT INTO "CreatureUpgrade" ("CreatureUpgrade_cid","Game_id","BaseCreature_id","UpgradedCreature_id") VALUES ('c.a.temp',-401,-403,-401);
DELETE FROM "CreatureUpgrade" WHERE "CreatureUpgrade_cid"='b.c';
SET CONSTRAINTS ALL IMMEDIATE;
ROLLBACK;
