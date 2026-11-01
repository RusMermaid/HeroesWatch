-- Generated forward migration from overlay version 3 to version 4.
-- Apply once after 0003_nullable_identity_and_campaign_scope.sql.
-- Renames creature rank terminology only; all values, nullability, and physical IDs are preserved.
BEGIN;

LOCK TABLE "heroes_watch"."CreatureHOMM1", "heroes_watch"."CreatureHOMM2", "heroes_watch"."CreatureHOMM3", "heroes_watch"."CreatureHOMM4" IN ACCESS EXCLUSIVE MODE;

ALTER TABLE "heroes_watch"."CreatureHOMM1" RENAME COLUMN "Level" TO "Tier";
ALTER TABLE "heroes_watch"."CreatureHOMM2" RENAME COLUMN "Level" TO "Tier";
ALTER TABLE "heroes_watch"."CreatureHOMM3" RENAME COLUMN "Level" TO "Tier";
ALTER TABLE "heroes_watch"."CreatureHOMM4" RENAME COLUMN "Level" TO "Tier";

COMMIT;
