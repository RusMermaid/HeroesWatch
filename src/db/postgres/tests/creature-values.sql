-- Run only in an isolated test database after the full catalog import.
BEGIN;
DO $verify$
DECLARE creature_id BIGINT; changed_count INTEGER;
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'heroes_watch' AND table_name IN
      ('CreatureHOMM1','CreatureHOMM2','CreatureHOMM3','CreatureHOMM4') AND column_name = 'Level') THEN
    RAISE EXCEPTION 'Creature Level column remains';
  END IF;
  IF EXISTS (SELECT 1 FROM heroes_watch."CreatureHOMM1"
    WHERE "SpeedName" IS DISTINCT FROM CASE "Speed" WHEN 1 THEN 'Slow' WHEN 2 THEN 'Medium' WHEN 3 THEN 'Fast' END) THEN
    RAISE EXCEPTION 'H1 numeric Speed/SpeedName mismatch';
  END IF;
  IF EXISTS (SELECT 1 FROM heroes_watch."CreatureHOMM2"
    WHERE "SpeedName" IS DISTINCT FROM CASE "Speed" WHEN 2 THEN 'Very Slow' WHEN 3 THEN 'Slow' WHEN 4 THEN 'Average' WHEN 5 THEN 'Fast' WHEN 6 THEN 'Very Fast' WHEN 7 THEN 'Ultra Fast' END) THEN
    RAISE EXCEPTION 'H2 numeric Speed/SpeedName mismatch';
  END IF;
  SELECT count(*) INTO changed_count
  FROM heroes_watch."CreatureHOMM3" d JOIN heroes_watch."Creature" c USING ("Creature_id")
  JOIN heroes_watch."Game" g USING ("Game_id")
  JOIN (VALUES ('FAERIE_DRAGON',8),('RUST_DRAGON',8),('CRYSTAL_DRAGON',9),('AZURE_DRAGON',10)) expected(code,tier)
    ON c."Code" = expected.code AND d."Tier" = expected.tier
  WHERE g."SeriesCode" = 'HOMM3';
  IF changed_count <> 4 THEN RAISE EXCEPTION 'Dragon tiers differ from reviewed values'; END IF;
  SELECT min("Creature_id") INTO creature_id FROM heroes_watch."CreatureHOMM1";
  IF creature_id IS NULL THEN RAISE EXCEPTION 'H1 test needs real catalog rows'; END IF;
  BEGIN
    UPDATE heroes_watch."CreatureHOMM1" SET "SpeedName" = 'Fast' WHERE "Creature_id" = creature_id;
    RAISE EXCEPTION 'Generated SpeedName accepted an explicit write';
  EXCEPTION WHEN SQLSTATE '428C9' THEN NULL;
  END;
  BEGIN
    UPDATE heroes_watch."CreatureHOMM1" SET "Speed" = 0 WHERE "Creature_id" = creature_id;
    RAISE EXCEPTION 'H1 accepted invalid base speed';
  EXCEPTION WHEN check_violation OR not_null_violation THEN NULL;
  END;
  SELECT min("Creature_id") INTO creature_id FROM heroes_watch."CreatureHOMM2";
  BEGIN
    UPDATE heroes_watch."CreatureHOMM2" SET "Speed" = 8 WHERE "Creature_id" = creature_id;
    RAISE EXCEPTION 'H2 accepted transient speed as base speed';
  EXCEPTION WHEN check_violation OR not_null_violation THEN NULL;
  END;
END
$verify$;
ROLLBACK;
