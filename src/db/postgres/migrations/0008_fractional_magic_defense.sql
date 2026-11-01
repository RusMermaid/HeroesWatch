-- Preserve published fractional Heroes VI magic-defense points.
-- Migration 0008 changes representation only; it does not replace game facts.
BEGIN;
ALTER TABLE "heroes_watch"."CreatureHOMM6" ALTER COLUMN "MagicDefense" TYPE NUMERIC USING "MagicDefense"::numeric;
ALTER TABLE "heroes_watch"."CreatureHOMM6" ADD CONSTRAINT "ck_h6_magic_defense_finite" CHECK ("MagicDefense" BETWEEN -32768 AND 32767);
COMMIT;
