-- Generated forward migration from overlay version 4 to version 5.
-- Apply once after 0004_creature_tier_terminology.sql.
-- Numeric Speed is the source of truth; SpeedName is derived and Movement remains separate.
BEGIN;

LOCK TABLE "heroes_watch"."CreatureHOMM1", "heroes_watch"."CreatureHOMM2" IN ACCESS EXCLUSIVE MODE;

DO $validate_creature_speed$
BEGIN
  IF EXISTS (SELECT 1 FROM "heroes_watch"."CreatureHOMM1" WHERE "Speed" IS NULL OR "Speed"::text NOT IN ('Slow', 'Medium', 'Fast')) THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'CreatureHOMM1.Speed contains an unsupported legacy label; migration aborted';
  END IF;
  IF EXISTS (SELECT 1 FROM "heroes_watch"."CreatureHOMM2" WHERE "Speed" IS NULL OR "Speed" NOT IN (2, 3, 4, 5, 6, 7)) THEN
    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'CreatureHOMM2.Speed contains a value outside the reviewed base domain 2..7; migration aborted';
  END IF;
END
$validate_creature_speed$;

ALTER TABLE "heroes_watch"."CreatureHOMM1" ALTER COLUMN "Speed" TYPE SMALLINT USING (CASE "Speed"::text WHEN 'Slow' THEN 1 WHEN 'Medium' THEN 2 WHEN 'Fast' THEN 3 END);
DROP TYPE "heroes_watch"."Enum__CreatureHOMM1__Speed";

ALTER TABLE "heroes_watch"."CreatureHOMM1" ADD CONSTRAINT "ck__CreatureHOMM1__Speed_base_domain" CHECK ("Speed" IN (1, 2, 3));
ALTER TABLE "heroes_watch"."CreatureHOMM2" ADD CONSTRAINT "ck__CreatureHOMM2__Speed_base_domain" CHECK ("Speed" IN (2, 3, 4, 5, 6, 7));

ALTER TABLE "heroes_watch"."CreatureHOMM1" ADD COLUMN "SpeedName" TEXT GENERATED ALWAYS AS (CASE "Speed" WHEN 1 THEN 'Slow' WHEN 2 THEN 'Medium' WHEN 3 THEN 'Fast' END) STORED NOT NULL;
ALTER TABLE "heroes_watch"."CreatureHOMM2" ADD COLUMN "SpeedName" TEXT GENERATED ALWAYS AS (CASE "Speed" WHEN 2 THEN 'Very Slow' WHEN 3 THEN 'Slow' WHEN 4 THEN 'Average' WHEN 5 THEN 'Fast' WHEN 6 THEN 'Very Fast' WHEN 7 THEN 'Ultra Fast' END) STORED NOT NULL;

COMMIT;
