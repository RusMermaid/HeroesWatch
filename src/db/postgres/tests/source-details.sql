-- Isolated database only, after importing the current catalog.
BEGIN;
DO $checks$
DECLARE h6 bigint; h7 bigint;
BEGIN
  SELECT min("Creature_id") INTO h6 FROM heroes_watch."CreatureHOMM6" WHERE "CreatureKind"='Town';
  SELECT min("Creature_id") INTO h7 FROM heroes_watch."CreatureHOMM7" WHERE "CreatureKind"='Town';
  IF h6 IS NULL OR h7 IS NULL THEN RAISE EXCEPTION 'Source detail probes require ordinary creatures'; END IF;
  BEGIN
    UPDATE heroes_watch."CreatureHOMM6" SET "MagicDefense"=NULL WHERE "Creature_id"=h6;
    RAISE EXCEPTION 'Ordinary H6 statistics accepted NULL';
  EXCEPTION WHEN check_violation THEN NULL; END;
  BEGIN
    UPDATE heroes_watch."CreatureHOMM7" SET "Health"=NULL WHERE "Creature_id"=h7;
    RAISE EXCEPTION 'Ordinary H7 statistics accepted NULL';
  EXCEPTION WHEN check_violation THEN NULL; END;
  BEGIN
    UPDATE heroes_watch."CreatureHOMM6" SET "MightResistancePercent"=101 WHERE "Creature_id"=h6;
    RAISE EXCEPTION 'Invalid resistance accepted';
  EXCEPTION WHEN check_violation THEN NULL; END;
  BEGIN
    UPDATE heroes_watch."CreatureHOMM7" SET "WarfareStats"='{}'::jsonb WHERE "Creature_id"=h7;
    RAISE EXCEPTION 'Warfare profile accepted on ordinary creature';
  EXCEPTION WHEN check_violation THEN NULL; END;
  UPDATE heroes_watch."CreatureHOMM7" SET "CreatureKind"='Warfare', "WarfareRole"='AttackAndSupport',
    "Attack"=NULL, "Defense"=NULL, "DamageMin"=NULL, "DamageMax"=NULL, "Health"=NULL,
    "Speed"=NULL, "CombatSize"=NULL, "Movement"=NULL WHERE "Creature_id"=h7;
END
$checks$;
ROLLBACK;
