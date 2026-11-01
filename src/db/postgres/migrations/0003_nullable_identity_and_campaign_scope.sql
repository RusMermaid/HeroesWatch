-- Generated forward migration from overlay version 2 to version 3.
-- Apply once after 0002_relationship_integrity.sql.
-- PostgreSQL 15+ is required for NULLS NOT DISTINCT identity constraints.
BEGIN;

LOCK TABLE "heroes_watch"."CampaignHero", "heroes_watch"."CampaignScenario", "heroes_watch"."GameResource", "heroes_watch"."LoreFull", "heroes_watch"."MediaAsset", "heroes_watch"."Patch", "heroes_watch"."SpellResourceCostHOMM5" IN SHARE ROW EXCLUSIVE MODE;

ALTER TABLE "heroes_watch"."LoreFull" DROP CONSTRAINT "uq__LoreFull__Game_id__Lore_id__Hero_id__CampaignHer_62d47efc94";
ALTER TABLE "heroes_watch"."LoreFull" ADD CONSTRAINT "uq__LoreFull__Game_id__Lore_id__Hero_id__CampaignHer_62d47efc94" UNIQUE NULLS NOT DISTINCT ("Game_id", "Lore_id", "Hero_id", "CampaignHero_cid", "Campaign_id", "Scenario_id", "Map_id", "LinkRole", "Faction_id");
ALTER TABLE "heroes_watch"."MediaAsset" DROP CONSTRAINT "uq__MediaAsset__Game_id__Code";
ALTER TABLE "heroes_watch"."MediaAsset" ADD CONSTRAINT "uq__MediaAsset__Game_id__Code" UNIQUE NULLS NOT DISTINCT ("Game_id", "Code");
ALTER TABLE "heroes_watch"."Patch" DROP CONSTRAINT "uq__Patch__Game_id__Version__Platform";
ALTER TABLE "heroes_watch"."Patch" ADD CONSTRAINT "uq__Patch__Game_id__Version__Platform" UNIQUE NULLS NOT DISTINCT ("Game_id", "Version", "Platform");

ALTER TABLE "heroes_watch"."CampaignHero"
    ADD CONSTRAINT "fk_campaign_scenario__CampaignHero__StartingScenario_id"
    FOREIGN KEY ("Game_id", "Campaign_id", "StartingScenario_id")
    REFERENCES "heroes_watch"."CampaignScenario" ("Game_id", "Campaign_id", "Scenario_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;
CREATE INDEX IF NOT EXISTS "ix__CampaignHero__Game_id__Campaign_id__StartingScenario_id" ON "heroes_watch"."CampaignHero" ("Game_id", "Campaign_id", "StartingScenario_id");

ALTER TABLE "heroes_watch"."SpellResourceCostHOMM5"
    ADD CONSTRAINT "fk_resource__SpellResourceCostHOMM5"
    FOREIGN KEY ("Game_id", "Resource_id")
    REFERENCES "heroes_watch"."GameResource" ("Game_id", "Resource_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;
CREATE INDEX IF NOT EXISTS "ix__SpellResourceCostHOMM5__Game_id__Resource_id" ON "heroes_watch"."SpellResourceCostHOMM5" ("Game_id", "Resource_id");

COMMIT;
