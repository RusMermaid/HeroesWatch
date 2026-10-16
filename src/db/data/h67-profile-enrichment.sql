-- Guarded source-supported additions to existing Heroes VII warfare profiles.
-- Apply after migration 0008 and before research-gaps-import.sql when upgrading the 45,560-row catalog.
-- Unknown local changes abort. Repeated execution preserves the recorded result.
BEGIN;
SET LOCAL standard_conforming_strings = on;
SET LOCAL lock_timeout = '15s';
LOCK TABLE heroes_watch."Creature", heroes_watch."CreatureHOMM7", heroes_watch."Game" IN SHARE ROW EXCLUSIVE MODE;
DO $enrichment$
DECLARE target_id bigint; matches bigint; changed integer; previous jsonb;
BEGIN
  SELECT count(*), min(d."Creature_id") INTO matches, target_id
    FROM heroes_watch."CreatureHOMM7" d, heroes_watch."Creature" c, heroes_watch."Game" g WHERE c."Creature_id"=d."Creature_id" AND g."Game_id"=c."Game_id" AND g."SeriesCode"='HOMM7' AND c."Code"=E'BALLISTA';
  IF matches <> 1 THEN RAISE EXCEPTION 'Expected exactly one creature profile: BALLISTA; found %', matches; END IF;
  SELECT d."WarfareStats" INTO STRICT previous FROM heroes_watch."CreatureHOMM7" d WHERE d."Creature_id"=target_id;
  IF previous IS DISTINCT FROM E'{"profileOrder":"source-listed","profiles":[{"index":1,"attack":5,"defense":10,"health":250,"damageMin":16,"damageMax":24},{"index":2,"attack":10,"defense":15,"health":350,"damageMin":29,"damageMax":41},{"index":3,"attack":15,"health":450,"damageMin":38,"damageMax":52},{"index":4,"attack":20,"health":550,"damageMin":42,"damageMax":58},{"index":5,"attack":25,"health":700,"damageMin":60,"damageMax":80}]}'::jsonb AND previous IS DISTINCT FROM E'{"profileOrder":"source-listed","profiles":[{"index":1,"attack":5,"defense":10,"health":250,"damageMin":16,"damageMax":24},{"index":2,"attack":10,"defense":15,"health":350,"damageMin":29,"damageMax":41},{"index":3,"attack":15,"health":450,"damageMin":38,"damageMax":52,"defense":25},{"index":4,"attack":20,"health":550,"damageMin":42,"damageMax":58,"defense":30},{"index":5,"attack":25,"health":700,"damageMin":60,"damageMax":80,"defense":40}]}'::jsonb THEN
    RAISE EXCEPTION 'Unexpected existing profile: BALLISTA';
  END IF;
  IF previous IS DISTINCT FROM E'{"profileOrder":"source-listed","profiles":[{"index":1,"attack":5,"defense":10,"health":250,"damageMin":16,"damageMax":24},{"index":2,"attack":10,"defense":15,"health":350,"damageMin":29,"damageMax":41},{"index":3,"attack":15,"health":450,"damageMin":38,"damageMax":52,"defense":25},{"index":4,"attack":20,"health":550,"damageMin":42,"damageMax":58,"defense":30},{"index":5,"attack":25,"health":700,"damageMin":60,"damageMax":80,"defense":40}]}'::jsonb THEN
    UPDATE heroes_watch."CreatureHOMM7" d SET "WarfareStats"=E'{"profileOrder":"source-listed","profiles":[{"index":1,"attack":5,"defense":10,"health":250,"damageMin":16,"damageMax":24},{"index":2,"attack":10,"defense":15,"health":350,"damageMin":29,"damageMax":41},{"index":3,"attack":15,"health":450,"damageMin":38,"damageMax":52,"defense":25},{"index":4,"attack":20,"health":550,"damageMin":42,"damageMax":58,"defense":30},{"index":5,"attack":25,"health":700,"damageMin":60,"damageMax":80,"defense":40}]}'::jsonb
      WHERE d."Creature_id"=target_id AND d."WarfareStats" IS NOT DISTINCT FROM previous;
    GET DIAGNOSTICS changed = ROW_COUNT;
    IF changed <> 1 THEN RAISE EXCEPTION 'Creature profile update count changed: BALLISTA; updated %', changed; END IF;
  END IF;
  SELECT count(*), min(d."Creature_id") INTO matches, target_id
    FROM heroes_watch."CreatureHOMM7" d, heroes_watch."Creature" c, heroes_watch."Game" g WHERE c."Creature_id"=d."Creature_id" AND g."Game_id"=c."Game_id" AND g."SeriesCode"='HOMM7' AND c."Code"=E'HEALING_SISTER';
  IF matches <> 1 THEN RAISE EXCEPTION 'Expected exactly one creature profile: HEALING_SISTER; found %', matches; END IF;
  SELECT d."WarfareStats" INTO STRICT previous FROM heroes_watch."CreatureHOMM7" d WHERE d."Creature_id"=target_id;
  IF previous IS DISTINCT FROM E'{"profileOrder":"source-listed","profiles":[{"index":1,"health":300,"effectAmount":30},{"index":2,"health":400,"effectAmount":50},{"index":3,"health":500,"effectAmount":100},{"index":4,"health":600,"effectAmount":150},{"index":5,"health":700,"effectAmount":250}],"supportEffect":"Healing"}'::jsonb AND previous IS DISTINCT FROM E'{"profileOrder":"source-listed","profiles":[{"index":1,"health":300,"effectAmount":30,"defense":5},{"index":2,"health":400,"effectAmount":50,"defense":10},{"index":3,"health":500,"effectAmount":100,"defense":15},{"index":4,"health":600,"effectAmount":150,"defense":20},{"index":5,"health":700,"effectAmount":250,"defense":25}],"supportEffect":"Healing"}'::jsonb THEN
    RAISE EXCEPTION 'Unexpected existing profile: HEALING_SISTER';
  END IF;
  IF previous IS DISTINCT FROM E'{"profileOrder":"source-listed","profiles":[{"index":1,"health":300,"effectAmount":30,"defense":5},{"index":2,"health":400,"effectAmount":50,"defense":10},{"index":3,"health":500,"effectAmount":100,"defense":15},{"index":4,"health":600,"effectAmount":150,"defense":20},{"index":5,"health":700,"effectAmount":250,"defense":25}],"supportEffect":"Healing"}'::jsonb THEN
    UPDATE heroes_watch."CreatureHOMM7" d SET "WarfareStats"=E'{"profileOrder":"source-listed","profiles":[{"index":1,"health":300,"effectAmount":30,"defense":5},{"index":2,"health":400,"effectAmount":50,"defense":10},{"index":3,"health":500,"effectAmount":100,"defense":15},{"index":4,"health":600,"effectAmount":150,"defense":20},{"index":5,"health":700,"effectAmount":250,"defense":25}],"supportEffect":"Healing"}'::jsonb
      WHERE d."Creature_id"=target_id AND d."WarfareStats" IS NOT DISTINCT FROM previous;
    GET DIAGNOSTICS changed = ROW_COUNT;
    IF changed <> 1 THEN RAISE EXCEPTION 'Creature profile update count changed: HEALING_SISTER; updated %', changed; END IF;
  END IF;
  SELECT count(*), min(d."Creature_id") INTO matches, target_id
    FROM heroes_watch."CreatureHOMM7" d, heroes_watch."Creature" c, heroes_watch."Game" g WHERE c."Creature_id"=d."Creature_id" AND g."Game_id"=c."Game_id" AND g."SeriesCode"='HOMM7' AND c."Code"=E'DREAMWALKER';
  IF matches <> 1 THEN RAISE EXCEPTION 'Expected exactly one creature profile: DREAMWALKER; found %', matches; END IF;
  SELECT d."WarfareStats" INTO STRICT previous FROM heroes_watch."CreatureHOMM7" d WHERE d."Creature_id"=target_id;
  IF previous IS DISTINCT FROM E'{"profileOrder":"source-listed","profiles":[{"index":1,"attack":5,"defense":5,"health":600,"effectAmount":20,"damageMin":20,"damageMax":28},{"index":2,"attack":10,"defense":10,"health":700,"effectAmount":40,"damageMin":35,"damageMax":48},{"index":3,"attack":15,"defense":15,"health":800,"effectAmount":60,"damageMin":45,"damageMax":62},{"index":4,"attack":20,"defense":20,"health":900,"effectAmount":120,"damageMin":50,"damageMax":68},{"index":5,"attack":25,"defense":25,"health":1000,"damageMin":70,"damageMax":95}],"supportEffect":"Healing"}'::jsonb AND previous IS DISTINCT FROM E'{"profileOrder":"source-listed","profiles":[{"index":1,"attack":5,"defense":5,"health":600,"effectAmount":20,"damageMin":20,"damageMax":28},{"index":2,"attack":10,"defense":10,"health":700,"effectAmount":40,"damageMin":35,"damageMax":48},{"index":3,"attack":15,"defense":15,"health":800,"effectAmount":60,"damageMin":45,"damageMax":62},{"index":4,"attack":20,"defense":20,"health":900,"effectAmount":120,"damageMin":50,"damageMax":68},{"index":5,"attack":25,"defense":25,"health":1000,"damageMin":70,"damageMax":95,"effectAmount":600}],"supportEffect":"Healing"}'::jsonb THEN
    RAISE EXCEPTION 'Unexpected existing profile: DREAMWALKER';
  END IF;
  IF previous IS DISTINCT FROM E'{"profileOrder":"source-listed","profiles":[{"index":1,"attack":5,"defense":5,"health":600,"effectAmount":20,"damageMin":20,"damageMax":28},{"index":2,"attack":10,"defense":10,"health":700,"effectAmount":40,"damageMin":35,"damageMax":48},{"index":3,"attack":15,"defense":15,"health":800,"effectAmount":60,"damageMin":45,"damageMax":62},{"index":4,"attack":20,"defense":20,"health":900,"effectAmount":120,"damageMin":50,"damageMax":68},{"index":5,"attack":25,"defense":25,"health":1000,"damageMin":70,"damageMax":95,"effectAmount":600}],"supportEffect":"Healing"}'::jsonb THEN
    UPDATE heroes_watch."CreatureHOMM7" d SET "WarfareStats"=E'{"profileOrder":"source-listed","profiles":[{"index":1,"attack":5,"defense":5,"health":600,"effectAmount":20,"damageMin":20,"damageMax":28},{"index":2,"attack":10,"defense":10,"health":700,"effectAmount":40,"damageMin":35,"damageMax":48},{"index":3,"attack":15,"defense":15,"health":800,"effectAmount":60,"damageMin":45,"damageMax":62},{"index":4,"attack":20,"defense":20,"health":900,"effectAmount":120,"damageMin":50,"damageMax":68},{"index":5,"attack":25,"defense":25,"health":1000,"damageMin":70,"damageMax":95,"effectAmount":600}],"supportEffect":"Healing"}'::jsonb
      WHERE d."Creature_id"=target_id AND d."WarfareStats" IS NOT DISTINCT FROM previous;
    GET DIAGNOSTICS changed = ROW_COUNT;
    IF changed <> 1 THEN RAISE EXCEPTION 'Creature profile update count changed: DREAMWALKER; updated %', changed; END IF;
  END IF;
END
$enrichment$;
COMMIT;
