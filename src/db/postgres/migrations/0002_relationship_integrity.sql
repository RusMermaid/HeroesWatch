-- Generated forward migration from the immutable 0001 contract.
-- Apply once to an existing heroes_watch schema before importing current content.
-- PostgreSQL 15+ is required for NULLS NOT DISTINCT identity constraints.
BEGIN;

LOCK TABLE "heroes_watch"."Ability", "heroes_watch"."AbilityHOMM1", "heroes_watch"."AbilityHOMM2", "heroes_watch"."AbilityHOMM3", "heroes_watch"."AbilityHOMM4", "heroes_watch"."AbilityHOMM5", "heroes_watch"."AbilityHOMM6", "heroes_watch"."AbilityHOMM7", "heroes_watch"."AbilityHOMM8", "heroes_watch"."AdventureObject", "heroes_watch"."AdventureObjectHOMM1", "heroes_watch"."AdventureObjectHOMM2", "heroes_watch"."AdventureObjectHOMM3", "heroes_watch"."AdventureObjectHOMM4", "heroes_watch"."AdventureObjectHOMM5", "heroes_watch"."AdventureObjectHOMM6", "heroes_watch"."AdventureObjectHOMM7", "heroes_watch"."AdventureObjectHOMM8", "heroes_watch"."Artifact", "heroes_watch"."ArtifactComponent", "heroes_watch"."ArtifactHOMM1", "heroes_watch"."ArtifactHOMM2", "heroes_watch"."ArtifactHOMM3", "heroes_watch"."ArtifactHOMM4", "heroes_watch"."ArtifactHOMM5", "heroes_watch"."ArtifactHOMM6", "heroes_watch"."ArtifactHOMM7", "heroes_watch"."ArtifactHOMM8", "heroes_watch"."ArtifactResourceCost", "heroes_watch"."ArtifactSetBonusHOMM5", "heroes_watch"."ArtifactSetHOMM5", "heroes_watch"."AstrologyHOMM8", "heroes_watch"."Building", "heroes_watch"."BuildingCreature", "heroes_watch"."BuildingHOMM1", "heroes_watch"."BuildingHOMM2", "heroes_watch"."BuildingHOMM3", "heroes_watch"."BuildingHOMM4", "heroes_watch"."BuildingHOMM5", "heroes_watch"."BuildingHOMM6", "heroes_watch"."BuildingHOMM7", "heroes_watch"."BuildingHOMM8", "heroes_watch"."BuildingRequirement", "heroes_watch"."BuildingResourceCost", "heroes_watch"."BuildingUpgrade", "heroes_watch"."Campaign", "heroes_watch"."CampaignHero", "heroes_watch"."CampaignHOMM1", "heroes_watch"."CampaignHOMM2", "heroes_watch"."CampaignHOMM4", "heroes_watch"."CampaignHOMM8", "heroes_watch"."CampaignScenario", "heroes_watch"."Creature", "heroes_watch"."CreatureAbility", "heroes_watch"."CreatureHOMM1", "heroes_watch"."CreatureHOMM2", "heroes_watch"."CreatureHOMM3", "heroes_watch"."CreatureHOMM4", "heroes_watch"."CreatureHOMM5", "heroes_watch"."CreatureHOMM6", "heroes_watch"."CreatureHOMM7", "heroes_watch"."CreatureHOMM8", "heroes_watch"."CreatureResourceCost", "heroes_watch"."CreatureSpell", "heroes_watch"."CreatureUpgrade", "heroes_watch"."Expansion", "heroes_watch"."Faction", "heroes_watch"."FactionHOMM1", "heroes_watch"."FactionHOMM2", "heroes_watch"."FactionHOMM3", "heroes_watch"."FactionHOMM4", "heroes_watch"."FactionHOMM5", "heroes_watch"."FactionHOMM6", "heroes_watch"."FactionHOMM7", "heroes_watch"."FactionHOMM8", "heroes_watch"."FactionLaw", "heroes_watch"."FactionMagicSchoolHOMM5", "heroes_watch"."FactionNativeTerrainHOMM5", "heroes_watch"."FactionSpell", "heroes_watch"."Game", "heroes_watch"."GameHOMM8", "heroes_watch"."GameResource", "heroes_watch"."Hero", "heroes_watch"."HeroClass", "heroes_watch"."HeroClassAbility", "heroes_watch"."HeroClassHOMM1", "heroes_watch"."HeroClassHOMM2", "heroes_watch"."HeroClassHOMM3", "heroes_watch"."HeroClassHOMM4", "heroes_watch"."HeroClassHOMM5", "heroes_watch"."HeroClassHOMM6", "heroes_watch"."HeroClassHOMM7", "heroes_watch"."HeroClassHOMM8", "heroes_watch"."HeroClassPrimarySkillHOMM4", "heroes_watch"."HeroHOMM2", "heroes_watch"."HeroHOMM3", "heroes_watch"."HeroHOMM5", "heroes_watch"."HeroHOMM6", "heroes_watch"."HeroHOMM7", "heroes_watch"."HeroHOMM8", "heroes_watch"."HeroSkill", "heroes_watch"."Lore", "heroes_watch"."LoreFull", "heroes_watch"."MagicSchool", "heroes_watch"."MagicSchoolHOMM4", "heroes_watch"."MagicSchoolHOMM5", "heroes_watch"."MagicSchoolHOMM6", "heroes_watch"."MagicSchoolHOMM7", "heroes_watch"."MagicSchoolHOMM8", "heroes_watch"."Map", "heroes_watch"."MapHOMM1", "heroes_watch"."MapHOMM2", "heroes_watch"."MapHOMM3", "heroes_watch"."MapHOMM4", "heroes_watch"."MapHOMM5", "heroes_watch"."MapHOMM6", "heroes_watch"."MapHOMM7", "heroes_watch"."MapHOMM8", "heroes_watch"."MapObjectPresence", "heroes_watch"."MapTerrain", "heroes_watch"."MediaAsset", "heroes_watch"."Patch", "heroes_watch"."Resource", "heroes_watch"."ResourceHOMM1To5", "heroes_watch"."ResourceHOMM8", "heroes_watch"."Scenario", "heroes_watch"."ScenarioConnection", "heroes_watch"."ScenarioHOMM1", "heroes_watch"."ScenarioHOMM2", "heroes_watch"."ScenarioHOMM3", "heroes_watch"."ScenarioHOMM4", "heroes_watch"."ScenarioHOMM5", "heroes_watch"."ScenarioHOMM6", "heroes_watch"."ScenarioHOMM7", "heroes_watch"."ScenarioHOMM8", "heroes_watch"."Screenshot", "heroes_watch"."Skill", "heroes_watch"."SkillHOMM2", "heroes_watch"."SkillHOMM3", "heroes_watch"."SkillHOMM4", "heroes_watch"."SkillHOMM5", "heroes_watch"."SkillHOMM7", "heroes_watch"."SkillHOMM8", "heroes_watch"."Soundtrack", "heroes_watch"."SoundtrackHOMM1", "heroes_watch"."SoundtrackHOMM2", "heroes_watch"."SoundtrackHOMM3", "heroes_watch"."SoundtrackHOMM4", "heroes_watch"."SoundtrackHOMM5", "heroes_watch"."SoundtrackHOMM6", "heroes_watch"."SoundtrackHOMM7", "heroes_watch"."Spell", "heroes_watch"."SpellHOMM1", "heroes_watch"."SpellHOMM2", "heroes_watch"."SpellHOMM3", "heroes_watch"."SpellHOMM4", "heroes_watch"."SpellHOMM5", "heroes_watch"."SpellHOMM6", "heroes_watch"."SpellHOMM7", "heroes_watch"."SpellHOMM8", "heroes_watch"."SpellMagicSchool", "heroes_watch"."SpellResourceCostHOMM5", "heroes_watch"."Terrain", "heroes_watch"."TerrainHOMM1", "heroes_watch"."TerrainHOMM2", "heroes_watch"."TerrainHOMM3", "heroes_watch"."TerrainHOMM4", "heroes_watch"."TerrainHOMM5", "heroes_watch"."TerrainHOMM6", "heroes_watch"."TerrainHOMM7", "heroes_watch"."TownScreen", "heroes_watch"."TownScreenBuilding", "heroes_watch"."Video" IN SHARE ROW EXCLUSIVE MODE;

CREATE TYPE "heroes_watch"."Enum__AdventureObjectCreature__Relation" AS ENUM ('Recruits', 'Guards', 'Transforms');

ALTER TABLE "heroes_watch"."Ability" ADD CONSTRAINT "uq__Ability__Game_id__Ability_id" UNIQUE ("Game_id", "Ability_id");
ALTER TABLE "heroes_watch"."AdventureObject" ADD CONSTRAINT "uq__AdventureObject__Game_id__AdventureObject_id" UNIQUE ("Game_id", "AdventureObject_id");
CREATE TABLE "heroes_watch"."AdventureObjectCreature" (
    "AdventureObjectCreature_cid" TEXT NOT NULL,
    "Game_id" BIGINT NOT NULL,
    "AdventureObject_id" BIGINT NOT NULL,
    "Creature_id" BIGINT NOT NULL,
    "Relation" "heroes_watch"."Enum__AdventureObjectCreature__Relation" NOT NULL,
    "Notes" TEXT,
    CONSTRAINT "pk__AdventureObjectCreature" PRIMARY KEY ("AdventureObjectCreature_cid"),
    CONSTRAINT "uq__AdventureObjectCreature__Game_id__AdventureObjec_dfefbe6fb7" UNIQUE ("Game_id", "AdventureObject_id", "Creature_id", "Relation")
);

CREATE TABLE "heroes_watch"."AdventureObjectFaction" (
    "AdventureObjectFaction_cid" TEXT NOT NULL,
    "Game_id" BIGINT NOT NULL,
    "AdventureObject_id" BIGINT NOT NULL,
    "Faction_id" BIGINT NOT NULL,
    "Notes" TEXT,
    CONSTRAINT "pk__AdventureObjectFaction" PRIMARY KEY ("AdventureObjectFaction_cid"),
    CONSTRAINT "uq__AdventureObjectFaction__Game_id__AdventureObject_64d659dd6b" UNIQUE ("Game_id", "AdventureObject_id", "Faction_id")
);

ALTER TABLE "heroes_watch"."Artifact" ADD CONSTRAINT "uq__Artifact__Game_id__Artifact_id" UNIQUE ("Game_id", "Artifact_id");
ALTER TABLE "heroes_watch"."ArtifactSetBonusHOMM5" ADD CONSTRAINT "uq__ArtifactSetBonusHOMM5__ArtifactSetHOMM5_id__Requ_eb777c60c4" UNIQUE NULLS NOT DISTINCT ("ArtifactSetHOMM5_id", "RequiredPieceCount", "HeroClass_id");
ALTER TABLE "heroes_watch"."Building" ADD CONSTRAINT "uq__Building__Game_id__Building_id" UNIQUE ("Game_id", "Building_id");
ALTER TABLE "heroes_watch"."Campaign" ADD CONSTRAINT "uq__Campaign__Game_id__Campaign_id" UNIQUE ("Game_id", "Campaign_id");
ALTER TABLE "heroes_watch"."CampaignHero" ADD CONSTRAINT "uq__CampaignHero__Game_id__CampaignHero_cid" UNIQUE ("Game_id", "CampaignHero_cid");
ALTER TABLE "heroes_watch"."Creature" ADD CONSTRAINT "uq__Creature__Game_id__Creature_id" UNIQUE ("Game_id", "Creature_id");
ALTER TABLE "heroes_watch"."Expansion" ADD CONSTRAINT "uq__Expansion__Game_id__Expansion_id" UNIQUE ("Game_id", "Expansion_id");
ALTER TABLE "heroes_watch"."Faction" ADD CONSTRAINT "uq__Faction__Game_id__Faction_id" UNIQUE ("Game_id", "Faction_id");
ALTER TABLE "heroes_watch"."FactionSpell" ADD COLUMN "SelectionWeight" INTEGER;
ALTER TABLE "heroes_watch"."FactionSpell" ADD CONSTRAINT "ck__FactionSpell__SelectionWeight" CHECK ("SelectionWeight" >= 0);
ALTER TABLE "heroes_watch"."Hero" ADD CONSTRAINT "uq__Hero__Game_id__Hero_id" UNIQUE ("Game_id", "Hero_id");
ALTER TABLE "heroes_watch"."HeroClass" ADD CONSTRAINT "uq__HeroClass__Game_id__HeroClass_id" UNIQUE ("Game_id", "HeroClass_id");
ALTER TABLE "heroes_watch"."HeroClassAbility" ADD CONSTRAINT "uq__HeroClassAbility__Game_id__HeroClass_id__Ability_5ae418e5e4" UNIQUE NULLS NOT DISTINCT ("Game_id", "HeroClass_id", "Ability_id", "RequirementSet", "RequiredAbility_id", "Skill_id", "MinimumMastery");
ALTER TABLE "heroes_watch"."HeroClassAbility" ADD CONSTRAINT "ck__HeroClassAbility__requirement_group" CHECK (("RequirementSet" IS NULL AND "RequirementMode" IS NULL) OR ("RequirementSet" IS NOT NULL AND "RequirementSet" > 0 AND "RequirementMode" IS NOT NULL));
CREATE TABLE "heroes_watch"."HeroClassAbilityRequirementGroup" (
    "HeroClassAbilityRequirementGroup_cid" TEXT NOT NULL,
    "Game_id" BIGINT NOT NULL,
    "HeroClass_id" BIGINT NOT NULL,
    "Ability_id" BIGINT NOT NULL,
    "RequirementSet" SMALLINT NOT NULL,
    "RequirementMode" "heroes_watch"."Enum__HeroClassAbility__RequirementMode" NOT NULL,
    CONSTRAINT "pk__HeroClassAbilityRequirementGroup" PRIMARY KEY ("HeroClassAbilityRequirementGroup_cid"),
    CONSTRAINT "uq__HeroClassAbilityRequirementGroup__Game_id__HeroC_94f948057c" UNIQUE ("Game_id", "HeroClass_id", "Ability_id", "RequirementSet"),
    CONSTRAINT "uq__HeroClassAbilityRequirementGroup__Game_id__HeroC_1021c37fd3" UNIQUE ("Game_id", "HeroClass_id", "Ability_id", "RequirementSet", "RequirementMode"),
    CONSTRAINT "ck__HeroClassAbilityRequirementGroup__positive_set" CHECK ("RequirementSet" > 0)
);

ALTER TABLE "heroes_watch"."Lore" ADD CONSTRAINT "uq__Lore__Game_id__Lore_id" UNIQUE ("Game_id", "Lore_id");
ALTER TABLE "heroes_watch"."LoreFull" ADD COLUMN "Faction_id" BIGINT;
ALTER TABLE "heroes_watch"."LoreFull" DROP CONSTRAINT "uq__LoreFull__Game_id__Lore_id__Hero_id__CampaignHer_3d6878bf2a";
ALTER TABLE "heroes_watch"."LoreFull" ADD CONSTRAINT "uq__LoreFull__Game_id__Lore_id__Hero_id__CampaignHer_62d47efc94" UNIQUE ("Game_id", "Lore_id", "Hero_id", "CampaignHero_cid", "Campaign_id", "Scenario_id", "Map_id", "LinkRole", "Faction_id");
ALTER TABLE "heroes_watch"."MagicSchool" ADD CONSTRAINT "uq__MagicSchool__Game_id__MagicSchool_id" UNIQUE ("Game_id", "MagicSchool_id");
ALTER TABLE "heroes_watch"."Map" ADD CONSTRAINT "uq__Map__Game_id__Map_id" UNIQUE ("Game_id", "Map_id");
ALTER TABLE "heroes_watch"."Patch" ADD CONSTRAINT "uq__Patch__Game_id__Patch_id" UNIQUE ("Game_id", "Patch_id");
ALTER TABLE "heroes_watch"."Scenario" ADD CONSTRAINT "uq__Scenario__Game_id__Scenario_id" UNIQUE ("Game_id", "Scenario_id");
ALTER TABLE "heroes_watch"."Skill" ADD CONSTRAINT "uq__Skill__Game_id__Skill_id" UNIQUE ("Game_id", "Skill_id");
ALTER TABLE "heroes_watch"."Spell" ADD CONSTRAINT "uq__Spell__Game_id__Spell_id" UNIQUE ("Game_id", "Spell_id");
ALTER TABLE "heroes_watch"."Terrain" ADD CONSTRAINT "uq__Terrain__Game_id__Terrain_id" UNIQUE ("Game_id", "Terrain_id");
ALTER TABLE "heroes_watch"."TownScreen" ADD CONSTRAINT "uq__TownScreen__Game_id__TownScreen_id" UNIQUE ("Game_id", "TownScreen_id");
ALTER TABLE "heroes_watch"."AdventureObject"
    ADD CONSTRAINT "fk_game__AdventureObject__IntroducedInExpansion_id__Expansion"
    FOREIGN KEY ("Game_id", "IntroducedInExpansion_id")
    REFERENCES "heroes_watch"."Expansion" ("Game_id", "Expansion_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__AdventureObject__Game_id__IntroducedInExpansion_id" ON "heroes_watch"."AdventureObject" ("Game_id", "IntroducedInExpansion_id");
ALTER TABLE "heroes_watch"."AdventureObjectCreature"
    ADD CONSTRAINT "fk__AdventureObjectCreature__AdventureObject_id__Adv_da27d54440"
    FOREIGN KEY ("AdventureObject_id")
    REFERENCES "heroes_watch"."AdventureObject" ("AdventureObject_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__AdventureObjectCreature__AdventureObject_id" ON "heroes_watch"."AdventureObjectCreature" ("AdventureObject_id");
ALTER TABLE "heroes_watch"."AdventureObjectCreature"
    ADD CONSTRAINT "fk__AdventureObjectCreature__Creature_id__Creature"
    FOREIGN KEY ("Creature_id")
    REFERENCES "heroes_watch"."Creature" ("Creature_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__AdventureObjectCreature__Creature_id" ON "heroes_watch"."AdventureObjectCreature" ("Creature_id");
ALTER TABLE "heroes_watch"."AdventureObjectCreature"
    ADD CONSTRAINT "fk__AdventureObjectCreature__Game_id__Game"
    FOREIGN KEY ("Game_id")
    REFERENCES "heroes_watch"."Game" ("Game_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__AdventureObjectCreature__Game_id" ON "heroes_watch"."AdventureObjectCreature" ("Game_id");
ALTER TABLE "heroes_watch"."AdventureObjectCreature"
    ADD CONSTRAINT "fk_game__AdventureObjectCreature__AdventureObject_id_ec25487e4f"
    FOREIGN KEY ("Game_id", "AdventureObject_id")
    REFERENCES "heroes_watch"."AdventureObject" ("Game_id", "AdventureObject_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__AdventureObjectCreature__Game_id__AdventureObject_id" ON "heroes_watch"."AdventureObjectCreature" ("Game_id", "AdventureObject_id");
ALTER TABLE "heroes_watch"."AdventureObjectCreature"
    ADD CONSTRAINT "fk_game__AdventureObjectCreature__Creature_id__Creature"
    FOREIGN KEY ("Game_id", "Creature_id")
    REFERENCES "heroes_watch"."Creature" ("Game_id", "Creature_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__AdventureObjectCreature__Game_id__Creature_id" ON "heroes_watch"."AdventureObjectCreature" ("Game_id", "Creature_id");
ALTER TABLE "heroes_watch"."AdventureObjectFaction"
    ADD CONSTRAINT "fk__AdventureObjectFaction__AdventureObject_id__AdventureObject"
    FOREIGN KEY ("AdventureObject_id")
    REFERENCES "heroes_watch"."AdventureObject" ("AdventureObject_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__AdventureObjectFaction__AdventureObject_id" ON "heroes_watch"."AdventureObjectFaction" ("AdventureObject_id");
ALTER TABLE "heroes_watch"."AdventureObjectFaction"
    ADD CONSTRAINT "fk__AdventureObjectFaction__Faction_id__Faction"
    FOREIGN KEY ("Faction_id")
    REFERENCES "heroes_watch"."Faction" ("Faction_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__AdventureObjectFaction__Faction_id" ON "heroes_watch"."AdventureObjectFaction" ("Faction_id");
ALTER TABLE "heroes_watch"."AdventureObjectFaction"
    ADD CONSTRAINT "fk__AdventureObjectFaction__Game_id__Game"
    FOREIGN KEY ("Game_id")
    REFERENCES "heroes_watch"."Game" ("Game_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__AdventureObjectFaction__Game_id" ON "heroes_watch"."AdventureObjectFaction" ("Game_id");
ALTER TABLE "heroes_watch"."AdventureObjectFaction"
    ADD CONSTRAINT "fk_game__AdventureObjectFaction__AdventureObject_id__63f7f5d800"
    FOREIGN KEY ("Game_id", "AdventureObject_id")
    REFERENCES "heroes_watch"."AdventureObject" ("Game_id", "AdventureObject_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__AdventureObjectFaction__Game_id__AdventureObject_id" ON "heroes_watch"."AdventureObjectFaction" ("Game_id", "AdventureObject_id");
ALTER TABLE "heroes_watch"."AdventureObjectFaction"
    ADD CONSTRAINT "fk_game__AdventureObjectFaction__Faction_id__Faction"
    FOREIGN KEY ("Game_id", "Faction_id")
    REFERENCES "heroes_watch"."Faction" ("Game_id", "Faction_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__AdventureObjectFaction__Game_id__Faction_id" ON "heroes_watch"."AdventureObjectFaction" ("Game_id", "Faction_id");
ALTER TABLE "heroes_watch"."Artifact"
    ADD CONSTRAINT "fk_game__Artifact__IntroducedInExpansion_id__Expansion"
    FOREIGN KEY ("Game_id", "IntroducedInExpansion_id")
    REFERENCES "heroes_watch"."Expansion" ("Game_id", "Expansion_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__Artifact__Game_id__IntroducedInExpansion_id" ON "heroes_watch"."Artifact" ("Game_id", "IntroducedInExpansion_id");
ALTER TABLE "heroes_watch"."ArtifactComponent"
    ADD CONSTRAINT "fk_game__ArtifactComponent__ComponentArtifact_id__Artifact"
    FOREIGN KEY ("Game_id", "ComponentArtifact_id")
    REFERENCES "heroes_watch"."Artifact" ("Game_id", "Artifact_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__ArtifactComponent__Game_id__ComponentArtifact_id" ON "heroes_watch"."ArtifactComponent" ("Game_id", "ComponentArtifact_id");
ALTER TABLE "heroes_watch"."ArtifactComponent"
    ADD CONSTRAINT "fk_game__ArtifactComponent__CompositeArtifact_id__Artifact"
    FOREIGN KEY ("Game_id", "CompositeArtifact_id")
    REFERENCES "heroes_watch"."Artifact" ("Game_id", "Artifact_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__ArtifactComponent__Game_id__CompositeArtifact_id" ON "heroes_watch"."ArtifactComponent" ("Game_id", "CompositeArtifact_id");
ALTER TABLE "heroes_watch"."ArtifactResourceCost"
    ADD CONSTRAINT "fk_game__ArtifactResourceCost__Artifact_id__Artifact"
    FOREIGN KEY ("Game_id", "Artifact_id")
    REFERENCES "heroes_watch"."Artifact" ("Game_id", "Artifact_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__ArtifactResourceCost__Game_id__Artifact_id" ON "heroes_watch"."ArtifactResourceCost" ("Game_id", "Artifact_id");
ALTER TABLE "heroes_watch"."ArtifactResourceCost"
    ADD CONSTRAINT "fk_resource__ArtifactResourceCost"
    FOREIGN KEY ("Game_id", "Resource_id")
    REFERENCES "heroes_watch"."GameResource" ("Game_id", "Resource_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__ArtifactResourceCost__Game_id__Resource_id" ON "heroes_watch"."ArtifactResourceCost" ("Game_id", "Resource_id");
ALTER TABLE "heroes_watch"."AstrologyHOMM8"
    ADD CONSTRAINT "fk_game__AstrologyHOMM8__NeutralMagicSchool_id__MagicSchool"
    FOREIGN KEY ("Game_id", "NeutralMagicSchool_id")
    REFERENCES "heroes_watch"."MagicSchool" ("Game_id", "MagicSchool_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__AstrologyHOMM8__Game_id__NeutralMagicSchool_id" ON "heroes_watch"."AstrologyHOMM8" ("Game_id", "NeutralMagicSchool_id");
ALTER TABLE "heroes_watch"."Building"
    ADD CONSTRAINT "fk_game__Building__IntroducedInExpansion_id__Expansion"
    FOREIGN KEY ("Game_id", "IntroducedInExpansion_id")
    REFERENCES "heroes_watch"."Expansion" ("Game_id", "Expansion_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__Building__Game_id__IntroducedInExpansion_id" ON "heroes_watch"."Building" ("Game_id", "IntroducedInExpansion_id");
ALTER TABLE "heroes_watch"."BuildingCreature"
    ADD CONSTRAINT "fk_game__BuildingCreature__Building_id__Building"
    FOREIGN KEY ("Game_id", "Building_id")
    REFERENCES "heroes_watch"."Building" ("Game_id", "Building_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__BuildingCreature__Game_id__Building_id" ON "heroes_watch"."BuildingCreature" ("Game_id", "Building_id");
ALTER TABLE "heroes_watch"."BuildingCreature"
    ADD CONSTRAINT "fk_game__BuildingCreature__Creature_id__Creature"
    FOREIGN KEY ("Game_id", "Creature_id")
    REFERENCES "heroes_watch"."Creature" ("Game_id", "Creature_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__BuildingCreature__Game_id__Creature_id" ON "heroes_watch"."BuildingCreature" ("Game_id", "Creature_id");
ALTER TABLE "heroes_watch"."BuildingRequirement"
    ADD CONSTRAINT "fk_game__BuildingRequirement__Building_id__Building"
    FOREIGN KEY ("Game_id", "Building_id")
    REFERENCES "heroes_watch"."Building" ("Game_id", "Building_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__BuildingRequirement__Game_id__Building_id" ON "heroes_watch"."BuildingRequirement" ("Game_id", "Building_id");
ALTER TABLE "heroes_watch"."BuildingRequirement"
    ADD CONSTRAINT "fk_game__BuildingRequirement__RequiredBuilding_id__Building"
    FOREIGN KEY ("Game_id", "RequiredBuilding_id")
    REFERENCES "heroes_watch"."Building" ("Game_id", "Building_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__BuildingRequirement__Game_id__RequiredBuilding_id" ON "heroes_watch"."BuildingRequirement" ("Game_id", "RequiredBuilding_id");
ALTER TABLE "heroes_watch"."BuildingResourceCost"
    ADD CONSTRAINT "fk_game__BuildingResourceCost__Building_id__Building"
    FOREIGN KEY ("Game_id", "Building_id")
    REFERENCES "heroes_watch"."Building" ("Game_id", "Building_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__BuildingResourceCost__Game_id__Building_id" ON "heroes_watch"."BuildingResourceCost" ("Game_id", "Building_id");
ALTER TABLE "heroes_watch"."BuildingResourceCost"
    ADD CONSTRAINT "fk_resource__BuildingResourceCost"
    FOREIGN KEY ("Game_id", "Resource_id")
    REFERENCES "heroes_watch"."GameResource" ("Game_id", "Resource_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__BuildingResourceCost__Game_id__Resource_id" ON "heroes_watch"."BuildingResourceCost" ("Game_id", "Resource_id");
ALTER TABLE "heroes_watch"."BuildingUpgrade"
    ADD CONSTRAINT "fk_game__BuildingUpgrade__BaseBuilding_id__Building"
    FOREIGN KEY ("Game_id", "BaseBuilding_id")
    REFERENCES "heroes_watch"."Building" ("Game_id", "Building_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__BuildingUpgrade__Game_id__BaseBuilding_id" ON "heroes_watch"."BuildingUpgrade" ("Game_id", "BaseBuilding_id");
ALTER TABLE "heroes_watch"."BuildingUpgrade"
    ADD CONSTRAINT "fk_game__BuildingUpgrade__UpgradedBuilding_id__Building"
    FOREIGN KEY ("Game_id", "UpgradedBuilding_id")
    REFERENCES "heroes_watch"."Building" ("Game_id", "Building_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__BuildingUpgrade__Game_id__UpgradedBuilding_id" ON "heroes_watch"."BuildingUpgrade" ("Game_id", "UpgradedBuilding_id");
ALTER TABLE "heroes_watch"."Campaign"
    ADD CONSTRAINT "fk_game__Campaign__Expansion_id__Expansion"
    FOREIGN KEY ("Game_id", "Expansion_id")
    REFERENCES "heroes_watch"."Expansion" ("Game_id", "Expansion_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__Campaign__Game_id__Expansion_id" ON "heroes_watch"."Campaign" ("Game_id", "Expansion_id");
ALTER TABLE "heroes_watch"."CampaignHero"
    ADD CONSTRAINT "fk_game__CampaignHero__Campaign_id__Campaign"
    FOREIGN KEY ("Game_id", "Campaign_id")
    REFERENCES "heroes_watch"."Campaign" ("Game_id", "Campaign_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__CampaignHero__Game_id__Campaign_id" ON "heroes_watch"."CampaignHero" ("Game_id", "Campaign_id");
ALTER TABLE "heroes_watch"."CampaignHero"
    ADD CONSTRAINT "fk_game__CampaignHero__Hero_id__Hero"
    FOREIGN KEY ("Game_id", "Hero_id")
    REFERENCES "heroes_watch"."Hero" ("Game_id", "Hero_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__CampaignHero__Game_id__Hero_id" ON "heroes_watch"."CampaignHero" ("Game_id", "Hero_id");
ALTER TABLE "heroes_watch"."CampaignHero"
    ADD CONSTRAINT "fk_game__CampaignHero__StartingScenario_id__Scenario"
    FOREIGN KEY ("Game_id", "StartingScenario_id")
    REFERENCES "heroes_watch"."Scenario" ("Game_id", "Scenario_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__CampaignHero__Game_id__StartingScenario_id" ON "heroes_watch"."CampaignHero" ("Game_id", "StartingScenario_id");
ALTER TABLE "heroes_watch"."CampaignScenario"
    ADD CONSTRAINT "fk_game__CampaignScenario__Campaign_id__Campaign"
    FOREIGN KEY ("Game_id", "Campaign_id")
    REFERENCES "heroes_watch"."Campaign" ("Game_id", "Campaign_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__CampaignScenario__Game_id__Campaign_id" ON "heroes_watch"."CampaignScenario" ("Game_id", "Campaign_id");
ALTER TABLE "heroes_watch"."CampaignScenario"
    ADD CONSTRAINT "fk_game__CampaignScenario__Scenario_id__Scenario"
    FOREIGN KEY ("Game_id", "Scenario_id")
    REFERENCES "heroes_watch"."Scenario" ("Game_id", "Scenario_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__CampaignScenario__Game_id__Scenario_id" ON "heroes_watch"."CampaignScenario" ("Game_id", "Scenario_id");
ALTER TABLE "heroes_watch"."Creature"
    ADD CONSTRAINT "fk_game__Creature__IntroducedInExpansion_id__Expansion"
    FOREIGN KEY ("Game_id", "IntroducedInExpansion_id")
    REFERENCES "heroes_watch"."Expansion" ("Game_id", "Expansion_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__Creature__Game_id__IntroducedInExpansion_id" ON "heroes_watch"."Creature" ("Game_id", "IntroducedInExpansion_id");
ALTER TABLE "heroes_watch"."CreatureAbility"
    ADD CONSTRAINT "fk_game__CreatureAbility__Ability_id__Ability"
    FOREIGN KEY ("Game_id", "Ability_id")
    REFERENCES "heroes_watch"."Ability" ("Game_id", "Ability_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__CreatureAbility__Game_id__Ability_id" ON "heroes_watch"."CreatureAbility" ("Game_id", "Ability_id");
ALTER TABLE "heroes_watch"."CreatureAbility"
    ADD CONSTRAINT "fk_game__CreatureAbility__Creature_id__Creature"
    FOREIGN KEY ("Game_id", "Creature_id")
    REFERENCES "heroes_watch"."Creature" ("Game_id", "Creature_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__CreatureAbility__Game_id__Creature_id" ON "heroes_watch"."CreatureAbility" ("Game_id", "Creature_id");
ALTER TABLE "heroes_watch"."CreatureResourceCost"
    ADD CONSTRAINT "fk_game__CreatureResourceCost__Creature_id__Creature"
    FOREIGN KEY ("Game_id", "Creature_id")
    REFERENCES "heroes_watch"."Creature" ("Game_id", "Creature_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__CreatureResourceCost__Game_id__Creature_id" ON "heroes_watch"."CreatureResourceCost" ("Game_id", "Creature_id");
ALTER TABLE "heroes_watch"."CreatureResourceCost"
    ADD CONSTRAINT "fk_resource__CreatureResourceCost"
    FOREIGN KEY ("Game_id", "Resource_id")
    REFERENCES "heroes_watch"."GameResource" ("Game_id", "Resource_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__CreatureResourceCost__Game_id__Resource_id" ON "heroes_watch"."CreatureResourceCost" ("Game_id", "Resource_id");
ALTER TABLE "heroes_watch"."CreatureSpell"
    ADD CONSTRAINT "fk_game__CreatureSpell__Creature_id__Creature"
    FOREIGN KEY ("Game_id", "Creature_id")
    REFERENCES "heroes_watch"."Creature" ("Game_id", "Creature_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__CreatureSpell__Game_id__Creature_id" ON "heroes_watch"."CreatureSpell" ("Game_id", "Creature_id");
ALTER TABLE "heroes_watch"."CreatureSpell"
    ADD CONSTRAINT "fk_game__CreatureSpell__Spell_id__Spell"
    FOREIGN KEY ("Game_id", "Spell_id")
    REFERENCES "heroes_watch"."Spell" ("Game_id", "Spell_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__CreatureSpell__Game_id__Spell_id" ON "heroes_watch"."CreatureSpell" ("Game_id", "Spell_id");
ALTER TABLE "heroes_watch"."CreatureUpgrade"
    ADD CONSTRAINT "fk_game__CreatureUpgrade__BaseCreature_id__Creature"
    FOREIGN KEY ("Game_id", "BaseCreature_id")
    REFERENCES "heroes_watch"."Creature" ("Game_id", "Creature_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__CreatureUpgrade__Game_id__BaseCreature_id" ON "heroes_watch"."CreatureUpgrade" ("Game_id", "BaseCreature_id");
ALTER TABLE "heroes_watch"."CreatureUpgrade"
    ADD CONSTRAINT "fk_game__CreatureUpgrade__UpgradedCreature_id__Creature"
    FOREIGN KEY ("Game_id", "UpgradedCreature_id")
    REFERENCES "heroes_watch"."Creature" ("Game_id", "Creature_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__CreatureUpgrade__Game_id__UpgradedCreature_id" ON "heroes_watch"."CreatureUpgrade" ("Game_id", "UpgradedCreature_id");
ALTER TABLE "heroes_watch"."Faction"
    ADD CONSTRAINT "fk_game__Faction__IntroducedInExpansion_id__Expansion"
    FOREIGN KEY ("Game_id", "IntroducedInExpansion_id")
    REFERENCES "heroes_watch"."Expansion" ("Game_id", "Expansion_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__Faction__Game_id__IntroducedInExpansion_id" ON "heroes_watch"."Faction" ("Game_id", "IntroducedInExpansion_id");
ALTER TABLE "heroes_watch"."FactionMagicSchoolHOMM5"
    ADD CONSTRAINT "fk_game__FactionMagicSchoolHOMM5__Faction_id__Faction"
    FOREIGN KEY ("Game_id", "Faction_id")
    REFERENCES "heroes_watch"."Faction" ("Game_id", "Faction_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__FactionMagicSchoolHOMM5__Game_id__Faction_id" ON "heroes_watch"."FactionMagicSchoolHOMM5" ("Game_id", "Faction_id");
ALTER TABLE "heroes_watch"."FactionMagicSchoolHOMM5"
    ADD CONSTRAINT "fk_game__FactionMagicSchoolHOMM5__MagicSchool_id__MagicSchool"
    FOREIGN KEY ("Game_id", "MagicSchool_id")
    REFERENCES "heroes_watch"."MagicSchool" ("Game_id", "MagicSchool_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__FactionMagicSchoolHOMM5__Game_id__MagicSchool_id" ON "heroes_watch"."FactionMagicSchoolHOMM5" ("Game_id", "MagicSchool_id");
ALTER TABLE "heroes_watch"."FactionNativeTerrainHOMM5"
    ADD CONSTRAINT "fk_game__FactionNativeTerrainHOMM5__Faction_id__Faction"
    FOREIGN KEY ("Game_id", "Faction_id")
    REFERENCES "heroes_watch"."Faction" ("Game_id", "Faction_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__FactionNativeTerrainHOMM5__Game_id__Faction_id" ON "heroes_watch"."FactionNativeTerrainHOMM5" ("Game_id", "Faction_id");
ALTER TABLE "heroes_watch"."FactionNativeTerrainHOMM5"
    ADD CONSTRAINT "fk_game__FactionNativeTerrainHOMM5__Terrain_id__Terrain"
    FOREIGN KEY ("Game_id", "Terrain_id")
    REFERENCES "heroes_watch"."Terrain" ("Game_id", "Terrain_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__FactionNativeTerrainHOMM5__Game_id__Terrain_id" ON "heroes_watch"."FactionNativeTerrainHOMM5" ("Game_id", "Terrain_id");
ALTER TABLE "heroes_watch"."FactionSpell"
    ADD CONSTRAINT "fk_game__FactionSpell__Faction_id__Faction"
    FOREIGN KEY ("Game_id", "Faction_id")
    REFERENCES "heroes_watch"."Faction" ("Game_id", "Faction_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__FactionSpell__Game_id__Faction_id" ON "heroes_watch"."FactionSpell" ("Game_id", "Faction_id");
ALTER TABLE "heroes_watch"."FactionSpell"
    ADD CONSTRAINT "fk_game__FactionSpell__Spell_id__Spell"
    FOREIGN KEY ("Game_id", "Spell_id")
    REFERENCES "heroes_watch"."Spell" ("Game_id", "Spell_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__FactionSpell__Game_id__Spell_id" ON "heroes_watch"."FactionSpell" ("Game_id", "Spell_id");
ALTER TABLE "heroes_watch"."GameHOMM8"
    ADD CONSTRAINT "fk_game__GameHOMM8__CurrentPatch_id__Patch"
    FOREIGN KEY ("Game_id", "CurrentPatch_id")
    REFERENCES "heroes_watch"."Patch" ("Game_id", "Patch_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__GameHOMM8__Game_id__CurrentPatch_id" ON "heroes_watch"."GameHOMM8" ("Game_id", "CurrentPatch_id");
ALTER TABLE "heroes_watch"."GameResource"
    ADD CONSTRAINT "fk_game__GameResource__IntroducedInExpansion_id__Expansion"
    FOREIGN KEY ("Game_id", "IntroducedInExpansion_id")
    REFERENCES "heroes_watch"."Expansion" ("Game_id", "Expansion_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__GameResource__Game_id__IntroducedInExpansion_id" ON "heroes_watch"."GameResource" ("Game_id", "IntroducedInExpansion_id");
ALTER TABLE "heroes_watch"."Hero"
    ADD CONSTRAINT "fk_game__Hero__HeroClass_id__HeroClass"
    FOREIGN KEY ("Game_id", "HeroClass_id")
    REFERENCES "heroes_watch"."HeroClass" ("Game_id", "HeroClass_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__Hero__Game_id__HeroClass_id" ON "heroes_watch"."Hero" ("Game_id", "HeroClass_id");
ALTER TABLE "heroes_watch"."Hero"
    ADD CONSTRAINT "fk_game__Hero__IntroducedInExpansion_id__Expansion"
    FOREIGN KEY ("Game_id", "IntroducedInExpansion_id")
    REFERENCES "heroes_watch"."Expansion" ("Game_id", "Expansion_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__Hero__Game_id__IntroducedInExpansion_id" ON "heroes_watch"."Hero" ("Game_id", "IntroducedInExpansion_id");
ALTER TABLE "heroes_watch"."HeroClass"
    ADD CONSTRAINT "fk_game__HeroClass__IntroducedInExpansion_id__Expansion"
    FOREIGN KEY ("Game_id", "IntroducedInExpansion_id")
    REFERENCES "heroes_watch"."Expansion" ("Game_id", "Expansion_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__HeroClass__Game_id__IntroducedInExpansion_id" ON "heroes_watch"."HeroClass" ("Game_id", "IntroducedInExpansion_id");
ALTER TABLE "heroes_watch"."HeroClassAbility"
    ADD CONSTRAINT "fk__HeroClassAbility__requirement_group"
    FOREIGN KEY ("Game_id", "HeroClass_id", "Ability_id", "RequirementSet", "RequirementMode")
    REFERENCES "heroes_watch"."HeroClassAbilityRequirementGroup" ("Game_id", "HeroClass_id", "Ability_id", "RequirementSet", "RequirementMode")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__HeroClassAbility__Game_id__HeroClass_id__Ability_35c02285e1" ON "heroes_watch"."HeroClassAbility" ("Game_id", "HeroClass_id", "Ability_id", "RequirementSet", "RequirementMode");
ALTER TABLE "heroes_watch"."HeroClassAbility"
    ADD CONSTRAINT "fk_game__HeroClassAbility__Ability_id__Ability"
    FOREIGN KEY ("Game_id", "Ability_id")
    REFERENCES "heroes_watch"."Ability" ("Game_id", "Ability_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__HeroClassAbility__Game_id__Ability_id" ON "heroes_watch"."HeroClassAbility" ("Game_id", "Ability_id");
ALTER TABLE "heroes_watch"."HeroClassAbility"
    ADD CONSTRAINT "fk_game__HeroClassAbility__HeroClass_id__HeroClass"
    FOREIGN KEY ("Game_id", "HeroClass_id")
    REFERENCES "heroes_watch"."HeroClass" ("Game_id", "HeroClass_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__HeroClassAbility__Game_id__HeroClass_id" ON "heroes_watch"."HeroClassAbility" ("Game_id", "HeroClass_id");
ALTER TABLE "heroes_watch"."HeroClassAbility"
    ADD CONSTRAINT "fk_game__HeroClassAbility__RequiredAbility_id__Ability"
    FOREIGN KEY ("Game_id", "RequiredAbility_id")
    REFERENCES "heroes_watch"."Ability" ("Game_id", "Ability_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__HeroClassAbility__Game_id__RequiredAbility_id" ON "heroes_watch"."HeroClassAbility" ("Game_id", "RequiredAbility_id");
ALTER TABLE "heroes_watch"."HeroClassAbility"
    ADD CONSTRAINT "fk_game__HeroClassAbility__Skill_id__Skill"
    FOREIGN KEY ("Game_id", "Skill_id")
    REFERENCES "heroes_watch"."Skill" ("Game_id", "Skill_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__HeroClassAbility__Game_id__Skill_id" ON "heroes_watch"."HeroClassAbility" ("Game_id", "Skill_id");
ALTER TABLE "heroes_watch"."HeroClassAbilityRequirementGroup"
    ADD CONSTRAINT "fk__HeroClassAbilityRequirementGroup__Ability_id__Ability"
    FOREIGN KEY ("Ability_id")
    REFERENCES "heroes_watch"."Ability" ("Ability_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__HeroClassAbilityRequirementGroup__Ability_id" ON "heroes_watch"."HeroClassAbilityRequirementGroup" ("Ability_id");
ALTER TABLE "heroes_watch"."HeroClassAbilityRequirementGroup"
    ADD CONSTRAINT "fk__HeroClassAbilityRequirementGroup__Game_id__Game"
    FOREIGN KEY ("Game_id")
    REFERENCES "heroes_watch"."Game" ("Game_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__HeroClassAbilityRequirementGroup__Game_id" ON "heroes_watch"."HeroClassAbilityRequirementGroup" ("Game_id");
ALTER TABLE "heroes_watch"."HeroClassAbilityRequirementGroup"
    ADD CONSTRAINT "fk__HeroClassAbilityRequirementGroup__HeroClass_id__HeroClass"
    FOREIGN KEY ("HeroClass_id")
    REFERENCES "heroes_watch"."HeroClass" ("HeroClass_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__HeroClassAbilityRequirementGroup__HeroClass_id" ON "heroes_watch"."HeroClassAbilityRequirementGroup" ("HeroClass_id");
ALTER TABLE "heroes_watch"."HeroClassAbilityRequirementGroup"
    ADD CONSTRAINT "fk_game__HeroClassAbilityRequirementGroup__Ability_id__Ability"
    FOREIGN KEY ("Game_id", "Ability_id")
    REFERENCES "heroes_watch"."Ability" ("Game_id", "Ability_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__HeroClassAbilityRequirementGroup__Game_id__Ability_id" ON "heroes_watch"."HeroClassAbilityRequirementGroup" ("Game_id", "Ability_id");
ALTER TABLE "heroes_watch"."HeroClassAbilityRequirementGroup"
    ADD CONSTRAINT "fk_game__HeroClassAbilityRequirementGroup__HeroClass_6e64c5a2c8"
    FOREIGN KEY ("Game_id", "HeroClass_id")
    REFERENCES "heroes_watch"."HeroClass" ("Game_id", "HeroClass_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__HeroClassAbilityRequirementGroup__Game_id__HeroClass_id" ON "heroes_watch"."HeroClassAbilityRequirementGroup" ("Game_id", "HeroClass_id");
ALTER TABLE "heroes_watch"."HeroClassPrimarySkillHOMM4"
    ADD CONSTRAINT "fk_game__HeroClassPrimarySkillHOMM4__HeroClass_id__HeroClass"
    FOREIGN KEY ("Game_id", "HeroClass_id")
    REFERENCES "heroes_watch"."HeroClass" ("Game_id", "HeroClass_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__HeroClassPrimarySkillHOMM4__Game_id__HeroClass_id" ON "heroes_watch"."HeroClassPrimarySkillHOMM4" ("Game_id", "HeroClass_id");
ALTER TABLE "heroes_watch"."HeroClassPrimarySkillHOMM4"
    ADD CONSTRAINT "fk_game__HeroClassPrimarySkillHOMM4__Skill_id__Skill"
    FOREIGN KEY ("Game_id", "Skill_id")
    REFERENCES "heroes_watch"."Skill" ("Game_id", "Skill_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__HeroClassPrimarySkillHOMM4__Game_id__Skill_id" ON "heroes_watch"."HeroClassPrimarySkillHOMM4" ("Game_id", "Skill_id");
ALTER TABLE "heroes_watch"."HeroSkill"
    ADD CONSTRAINT "fk_game__HeroSkill__Hero_id__Hero"
    FOREIGN KEY ("Game_id", "Hero_id")
    REFERENCES "heroes_watch"."Hero" ("Game_id", "Hero_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__HeroSkill__Game_id__Hero_id" ON "heroes_watch"."HeroSkill" ("Game_id", "Hero_id");
ALTER TABLE "heroes_watch"."HeroSkill"
    ADD CONSTRAINT "fk_game__HeroSkill__Skill_id__Skill"
    FOREIGN KEY ("Game_id", "Skill_id")
    REFERENCES "heroes_watch"."Skill" ("Game_id", "Skill_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__HeroSkill__Game_id__Skill_id" ON "heroes_watch"."HeroSkill" ("Game_id", "Skill_id");
ALTER TABLE "heroes_watch"."Lore"
    ADD CONSTRAINT "fk_game__Lore__IntroducedInExpansion_id__Expansion"
    FOREIGN KEY ("Game_id", "IntroducedInExpansion_id")
    REFERENCES "heroes_watch"."Expansion" ("Game_id", "Expansion_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__Lore__Game_id__IntroducedInExpansion_id" ON "heroes_watch"."Lore" ("Game_id", "IntroducedInExpansion_id");
ALTER TABLE "heroes_watch"."LoreFull"
    ADD CONSTRAINT "fk__LoreFull__Faction_id__Faction"
    FOREIGN KEY ("Faction_id")
    REFERENCES "heroes_watch"."Faction" ("Faction_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__LoreFull__Faction_id" ON "heroes_watch"."LoreFull" ("Faction_id");
ALTER TABLE "heroes_watch"."LoreFull"
    ADD CONSTRAINT "fk_game__LoreFull__Campaign_id__Campaign"
    FOREIGN KEY ("Game_id", "Campaign_id")
    REFERENCES "heroes_watch"."Campaign" ("Game_id", "Campaign_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__LoreFull__Game_id__Campaign_id" ON "heroes_watch"."LoreFull" ("Game_id", "Campaign_id");
ALTER TABLE "heroes_watch"."LoreFull"
    ADD CONSTRAINT "fk_game__LoreFull__CampaignHero_cid__CampaignHero"
    FOREIGN KEY ("Game_id", "CampaignHero_cid")
    REFERENCES "heroes_watch"."CampaignHero" ("Game_id", "CampaignHero_cid")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__LoreFull__Game_id__CampaignHero_cid" ON "heroes_watch"."LoreFull" ("Game_id", "CampaignHero_cid");
ALTER TABLE "heroes_watch"."LoreFull"
    ADD CONSTRAINT "fk_game__LoreFull__Faction_id__Faction"
    FOREIGN KEY ("Game_id", "Faction_id")
    REFERENCES "heroes_watch"."Faction" ("Game_id", "Faction_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__LoreFull__Game_id__Faction_id" ON "heroes_watch"."LoreFull" ("Game_id", "Faction_id");
ALTER TABLE "heroes_watch"."LoreFull"
    ADD CONSTRAINT "fk_game__LoreFull__Hero_id__Hero"
    FOREIGN KEY ("Game_id", "Hero_id")
    REFERENCES "heroes_watch"."Hero" ("Game_id", "Hero_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__LoreFull__Game_id__Hero_id" ON "heroes_watch"."LoreFull" ("Game_id", "Hero_id");
ALTER TABLE "heroes_watch"."LoreFull"
    ADD CONSTRAINT "fk_game__LoreFull__Lore_id__Lore"
    FOREIGN KEY ("Game_id", "Lore_id")
    REFERENCES "heroes_watch"."Lore" ("Game_id", "Lore_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__LoreFull__Game_id__Lore_id" ON "heroes_watch"."LoreFull" ("Game_id", "Lore_id");
ALTER TABLE "heroes_watch"."LoreFull"
    ADD CONSTRAINT "fk_game__LoreFull__Map_id__Map"
    FOREIGN KEY ("Game_id", "Map_id")
    REFERENCES "heroes_watch"."Map" ("Game_id", "Map_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__LoreFull__Game_id__Map_id" ON "heroes_watch"."LoreFull" ("Game_id", "Map_id");
ALTER TABLE "heroes_watch"."LoreFull"
    ADD CONSTRAINT "fk_game__LoreFull__Scenario_id__Scenario"
    FOREIGN KEY ("Game_id", "Scenario_id")
    REFERENCES "heroes_watch"."Scenario" ("Game_id", "Scenario_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__LoreFull__Game_id__Scenario_id" ON "heroes_watch"."LoreFull" ("Game_id", "Scenario_id");
ALTER TABLE "heroes_watch"."Map"
    ADD CONSTRAINT "fk_game__Map__IntroducedInExpansion_id__Expansion"
    FOREIGN KEY ("Game_id", "IntroducedInExpansion_id")
    REFERENCES "heroes_watch"."Expansion" ("Game_id", "Expansion_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__Map__Game_id__IntroducedInExpansion_id" ON "heroes_watch"."Map" ("Game_id", "IntroducedInExpansion_id");
ALTER TABLE "heroes_watch"."MapObjectPresence"
    ADD CONSTRAINT "fk_game__MapObjectPresence__AdventureObject_id__AdventureObject"
    FOREIGN KEY ("Game_id", "AdventureObject_id")
    REFERENCES "heroes_watch"."AdventureObject" ("Game_id", "AdventureObject_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__MapObjectPresence__Game_id__AdventureObject_id" ON "heroes_watch"."MapObjectPresence" ("Game_id", "AdventureObject_id");
ALTER TABLE "heroes_watch"."MapObjectPresence"
    ADD CONSTRAINT "fk_game__MapObjectPresence__Map_id__Map"
    FOREIGN KEY ("Game_id", "Map_id")
    REFERENCES "heroes_watch"."Map" ("Game_id", "Map_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__MapObjectPresence__Game_id__Map_id" ON "heroes_watch"."MapObjectPresence" ("Game_id", "Map_id");
ALTER TABLE "heroes_watch"."MapTerrain"
    ADD CONSTRAINT "fk_game__MapTerrain__Map_id__Map"
    FOREIGN KEY ("Game_id", "Map_id")
    REFERENCES "heroes_watch"."Map" ("Game_id", "Map_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__MapTerrain__Game_id__Map_id" ON "heroes_watch"."MapTerrain" ("Game_id", "Map_id");
ALTER TABLE "heroes_watch"."MapTerrain"
    ADD CONSTRAINT "fk_game__MapTerrain__Terrain_id__Terrain"
    FOREIGN KEY ("Game_id", "Terrain_id")
    REFERENCES "heroes_watch"."Terrain" ("Game_id", "Terrain_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__MapTerrain__Game_id__Terrain_id" ON "heroes_watch"."MapTerrain" ("Game_id", "Terrain_id");
ALTER TABLE "heroes_watch"."Patch"
    ADD CONSTRAINT "fk_game__Patch__Expansion_id__Expansion"
    FOREIGN KEY ("Game_id", "Expansion_id")
    REFERENCES "heroes_watch"."Expansion" ("Game_id", "Expansion_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__Patch__Game_id__Expansion_id" ON "heroes_watch"."Patch" ("Game_id", "Expansion_id");
ALTER TABLE "heroes_watch"."Scenario"
    ADD CONSTRAINT "fk_game__Scenario__IntroducedInExpansion_id__Expansion"
    FOREIGN KEY ("Game_id", "IntroducedInExpansion_id")
    REFERENCES "heroes_watch"."Expansion" ("Game_id", "Expansion_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__Scenario__Game_id__IntroducedInExpansion_id" ON "heroes_watch"."Scenario" ("Game_id", "IntroducedInExpansion_id");
ALTER TABLE "heroes_watch"."Scenario"
    ADD CONSTRAINT "fk_game__Scenario__Map_id__Map"
    FOREIGN KEY ("Game_id", "Map_id")
    REFERENCES "heroes_watch"."Map" ("Game_id", "Map_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__Scenario__Game_id__Map_id" ON "heroes_watch"."Scenario" ("Game_id", "Map_id");
ALTER TABLE "heroes_watch"."ScenarioConnection"
    ADD CONSTRAINT "fk_game__ScenarioConnection__FromScenario_id__Scenario"
    FOREIGN KEY ("Game_id", "FromScenario_id")
    REFERENCES "heroes_watch"."Scenario" ("Game_id", "Scenario_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__ScenarioConnection__Game_id__FromScenario_id" ON "heroes_watch"."ScenarioConnection" ("Game_id", "FromScenario_id");
ALTER TABLE "heroes_watch"."ScenarioConnection"
    ADD CONSTRAINT "fk_game__ScenarioConnection__ToScenario_id__Scenario"
    FOREIGN KEY ("Game_id", "ToScenario_id")
    REFERENCES "heroes_watch"."Scenario" ("Game_id", "Scenario_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__ScenarioConnection__Game_id__ToScenario_id" ON "heroes_watch"."ScenarioConnection" ("Game_id", "ToScenario_id");
ALTER TABLE "heroes_watch"."Screenshot"
    ADD CONSTRAINT "fk_game__Screenshot__Expansion_id__Expansion"
    FOREIGN KEY ("Game_id", "Expansion_id")
    REFERENCES "heroes_watch"."Expansion" ("Game_id", "Expansion_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__Screenshot__Game_id__Expansion_id" ON "heroes_watch"."Screenshot" ("Game_id", "Expansion_id");
ALTER TABLE "heroes_watch"."Skill"
    ADD CONSTRAINT "fk_game__Skill__IntroducedInExpansion_id__Expansion"
    FOREIGN KEY ("Game_id", "IntroducedInExpansion_id")
    REFERENCES "heroes_watch"."Expansion" ("Game_id", "Expansion_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__Skill__Game_id__IntroducedInExpansion_id" ON "heroes_watch"."Skill" ("Game_id", "IntroducedInExpansion_id");
ALTER TABLE "heroes_watch"."Soundtrack"
    ADD CONSTRAINT "fk_game__Soundtrack__Campaign_id__Campaign"
    FOREIGN KEY ("Game_id", "Campaign_id")
    REFERENCES "heroes_watch"."Campaign" ("Game_id", "Campaign_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__Soundtrack__Game_id__Campaign_id" ON "heroes_watch"."Soundtrack" ("Game_id", "Campaign_id");
ALTER TABLE "heroes_watch"."Soundtrack"
    ADD CONSTRAINT "fk_game__Soundtrack__Faction_id__Faction"
    FOREIGN KEY ("Game_id", "Faction_id")
    REFERENCES "heroes_watch"."Faction" ("Game_id", "Faction_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__Soundtrack__Game_id__Faction_id" ON "heroes_watch"."Soundtrack" ("Game_id", "Faction_id");
ALTER TABLE "heroes_watch"."Soundtrack"
    ADD CONSTRAINT "fk_game__Soundtrack__Terrain_id__Terrain"
    FOREIGN KEY ("Game_id", "Terrain_id")
    REFERENCES "heroes_watch"."Terrain" ("Game_id", "Terrain_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__Soundtrack__Game_id__Terrain_id" ON "heroes_watch"."Soundtrack" ("Game_id", "Terrain_id");
ALTER TABLE "heroes_watch"."Spell"
    ADD CONSTRAINT "fk_game__Spell__IntroducedInExpansion_id__Expansion"
    FOREIGN KEY ("Game_id", "IntroducedInExpansion_id")
    REFERENCES "heroes_watch"."Expansion" ("Game_id", "Expansion_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__Spell__Game_id__IntroducedInExpansion_id" ON "heroes_watch"."Spell" ("Game_id", "IntroducedInExpansion_id");
ALTER TABLE "heroes_watch"."SpellMagicSchool"
    ADD CONSTRAINT "fk_game__SpellMagicSchool__MagicSchool_id__MagicSchool"
    FOREIGN KEY ("Game_id", "MagicSchool_id")
    REFERENCES "heroes_watch"."MagicSchool" ("Game_id", "MagicSchool_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__SpellMagicSchool__Game_id__MagicSchool_id" ON "heroes_watch"."SpellMagicSchool" ("Game_id", "MagicSchool_id");
ALTER TABLE "heroes_watch"."SpellMagicSchool"
    ADD CONSTRAINT "fk_game__SpellMagicSchool__Spell_id__Spell"
    FOREIGN KEY ("Game_id", "Spell_id")
    REFERENCES "heroes_watch"."Spell" ("Game_id", "Spell_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__SpellMagicSchool__Game_id__Spell_id" ON "heroes_watch"."SpellMagicSchool" ("Game_id", "Spell_id");
ALTER TABLE "heroes_watch"."SpellResourceCostHOMM5"
    ADD CONSTRAINT "fk_game__SpellResourceCostHOMM5__Spell_id__Spell"
    FOREIGN KEY ("Game_id", "Spell_id")
    REFERENCES "heroes_watch"."Spell" ("Game_id", "Spell_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__SpellResourceCostHOMM5__Game_id__Spell_id" ON "heroes_watch"."SpellResourceCostHOMM5" ("Game_id", "Spell_id");
ALTER TABLE "heroes_watch"."Terrain"
    ADD CONSTRAINT "fk_game__Terrain__IntroducedInExpansion_id__Expansion"
    FOREIGN KEY ("Game_id", "IntroducedInExpansion_id")
    REFERENCES "heroes_watch"."Expansion" ("Game_id", "Expansion_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__Terrain__Game_id__IntroducedInExpansion_id" ON "heroes_watch"."Terrain" ("Game_id", "IntroducedInExpansion_id");
ALTER TABLE "heroes_watch"."TownScreen"
    ADD CONSTRAINT "fk_game__TownScreen__Faction_id__Faction"
    FOREIGN KEY ("Game_id", "Faction_id")
    REFERENCES "heroes_watch"."Faction" ("Game_id", "Faction_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__TownScreen__Game_id__Faction_id" ON "heroes_watch"."TownScreen" ("Game_id", "Faction_id");
ALTER TABLE "heroes_watch"."TownScreenBuilding"
    ADD CONSTRAINT "fk_game__TownScreenBuilding__Building_id__Building"
    FOREIGN KEY ("Game_id", "Building_id")
    REFERENCES "heroes_watch"."Building" ("Game_id", "Building_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__TownScreenBuilding__Game_id__Building_id" ON "heroes_watch"."TownScreenBuilding" ("Game_id", "Building_id");
ALTER TABLE "heroes_watch"."TownScreenBuilding"
    ADD CONSTRAINT "fk_game__TownScreenBuilding__TownScreen_id__TownScreen"
    FOREIGN KEY ("Game_id", "TownScreen_id")
    REFERENCES "heroes_watch"."TownScreen" ("Game_id", "TownScreen_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__TownScreenBuilding__Game_id__TownScreen_id" ON "heroes_watch"."TownScreenBuilding" ("Game_id", "TownScreen_id");
ALTER TABLE "heroes_watch"."Video"
    ADD CONSTRAINT "fk_game__Video__Campaign_id__Campaign"
    FOREIGN KEY ("Game_id", "Campaign_id")
    REFERENCES "heroes_watch"."Campaign" ("Game_id", "Campaign_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__Video__Game_id__Campaign_id" ON "heroes_watch"."Video" ("Game_id", "Campaign_id");
ALTER TABLE "heroes_watch"."Video"
    ADD CONSTRAINT "fk_game__Video__Scenario_id__Scenario"
    FOREIGN KEY ("Game_id", "Scenario_id")
    REFERENCES "heroes_watch"."Scenario" ("Game_id", "Scenario_id")
    ON UPDATE NO ACTION ON DELETE NO ACTION
    DEFERRABLE INITIALLY DEFERRED;

CREATE INDEX IF NOT EXISTS "ix__Video__Game_id__Scenario_id" ON "heroes_watch"."Video" ("Game_id", "Scenario_id");
-- Ownership checks use final row state and lock referenced parents.
-- Reverse checks run on ownership changes, including Game.SeriesCode changes.
-- Native composite FKs handle direct ownership and resource membership.
-- REPEATABLE READ ownership changes are rejected: an older snapshot can hide
-- a child committed while this transaction waited for the parent's row lock.
CREATE FUNCTION "heroes_watch"."_scope_metadata"(table_name text) RETURNS jsonb
LANGUAGE sql IMMUTABLE STRICT AS $function$
  SELECT '{"Ability":{"pk":"Ability_id","type":"BIGINT","direct":true,"owner":null,"expected":null,"refs":[{"column":"Game_id","table":"Game","target":"Game_id"},{"column":"MediaAsset_id","table":"MediaAsset","target":"MediaAsset_id"}],"incoming":[{"table":"AbilityHOMM1","column":"Ability_id"},{"table":"AbilityHOMM2","column":"Ability_id"},{"table":"AbilityHOMM3","column":"Ability_id"},{"table":"AbilityHOMM4","column":"Ability_id"},{"table":"AbilityHOMM5","column":"Ability_id"},{"table":"AbilityHOMM6","column":"Ability_id"},{"table":"AbilityHOMM7","column":"Ability_id"},{"table":"AbilityHOMM8","column":"Ability_id"},{"table":"CreatureAbility","column":"Ability_id"},{"table":"FactionHOMM6","column":"FactionAbility_id"},{"table":"HeroClassAbility","column":"Ability_id"},{"table":"HeroClassAbility","column":"RequiredAbility_id"},{"table":"HeroClassAbilityRequirementGroup","column":"Ability_id"},{"table":"HeroHOMM7","column":"SpecializationAbility_id"},{"table":"HeroHOMM8","column":"SpecializationAbility_id"},{"table":"SpellHOMM6","column":"Ability_id"}]},"AbilityHOMM1":{"pk":"Ability_id","type":"BIGINT","direct":false,"owner":{"column":"Ability_id","table":"Ability","target":"Ability_id"},"expected":"HOMM1","refs":[{"column":"Ability_id","table":"Ability","target":"Ability_id"}],"incoming":[]},"AbilityHOMM2":{"pk":"Ability_id","type":"BIGINT","direct":false,"owner":{"column":"Ability_id","table":"Ability","target":"Ability_id"},"expected":"HOMM2","refs":[{"column":"Ability_id","table":"Ability","target":"Ability_id"}],"incoming":[]},"AbilityHOMM3":{"pk":"Ability_id","type":"BIGINT","direct":false,"owner":{"column":"Ability_id","table":"Ability","target":"Ability_id"},"expected":"HOMM3","refs":[{"column":"Ability_id","table":"Ability","target":"Ability_id"}],"incoming":[]},"AbilityHOMM4":{"pk":"Ability_id","type":"BIGINT","direct":false,"owner":{"column":"Ability_id","table":"Ability","target":"Ability_id"},"expected":"HOMM4","refs":[{"column":"Ability_id","table":"Ability","target":"Ability_id"}],"incoming":[]},"AbilityHOMM5":{"pk":"Ability_id","type":"BIGINT","direct":false,"owner":{"column":"Ability_id","table":"Ability","target":"Ability_id"},"expected":"HOMM5","refs":[{"column":"Ability_id","table":"Ability","target":"Ability_id"}],"incoming":[]},"AbilityHOMM6":{"pk":"Ability_id","type":"BIGINT","direct":false,"owner":{"column":"Ability_id","table":"Ability","target":"Ability_id"},"expected":"HOMM6","refs":[{"column":"Ability_id","table":"Ability","target":"Ability_id"},{"column":"MagicSchool_id","table":"MagicSchool","target":"MagicSchool_id"}],"incoming":[]},"AbilityHOMM7":{"pk":"Ability_id","type":"BIGINT","direct":false,"owner":{"column":"Ability_id","table":"Ability","target":"Ability_id"},"expected":"HOMM7","refs":[{"column":"Ability_id","table":"Ability","target":"Ability_id"},{"column":"IntroducedInExpansion_id","table":"Expansion","target":"Expansion_id"}],"incoming":[]},"AbilityHOMM8":{"pk":"Ability_id","type":"BIGINT","direct":false,"owner":{"column":"Ability_id","table":"Ability","target":"Ability_id"},"expected":"HOMM8","refs":[{"column":"Ability_id","table":"Ability","target":"Ability_id"},{"column":"ParentSkill_id","table":"Skill","target":"Skill_id"}],"incoming":[]},"AdventureObject":{"pk":"AdventureObject_id","type":"BIGINT","direct":true,"owner":null,"expected":null,"refs":[{"column":"Game_id","table":"Game","target":"Game_id"},{"column":"IntroducedInExpansion_id","table":"Expansion","target":"Expansion_id"},{"column":"MediaAsset_id","table":"MediaAsset","target":"MediaAsset_id"}],"incoming":[{"table":"AdventureObjectCreature","column":"AdventureObject_id"},{"table":"AdventureObjectFaction","column":"AdventureObject_id"},{"table":"AdventureObjectHOMM1","column":"AdventureObject_id"},{"table":"AdventureObjectHOMM2","column":"AdventureObject_id"},{"table":"AdventureObjectHOMM3","column":"AdventureObject_id"},{"table":"AdventureObjectHOMM4","column":"AdventureObject_id"},{"table":"AdventureObjectHOMM5","column":"AdventureObject_id"},{"table":"AdventureObjectHOMM6","column":"AdventureObject_id"},{"table":"AdventureObjectHOMM7","column":"AdventureObject_id"},{"table":"AdventureObjectHOMM8","column":"AdventureObject_id"},{"table":"MapObjectPresence","column":"AdventureObject_id"}]},"AdventureObjectCreature":{"pk":"AdventureObjectCreature_cid","type":"TEXT","direct":true,"owner":null,"expected":null,"refs":[{"column":"AdventureObject_id","table":"AdventureObject","target":"AdventureObject_id"},{"column":"Creature_id","table":"Creature","target":"Creature_id"},{"column":"Game_id","table":"Game","target":"Game_id"}],"incoming":[]},"AdventureObjectFaction":{"pk":"AdventureObjectFaction_cid","type":"TEXT","direct":true,"owner":null,"expected":null,"refs":[{"column":"AdventureObject_id","table":"AdventureObject","target":"AdventureObject_id"},{"column":"Faction_id","table":"Faction","target":"Faction_id"},{"column":"Game_id","table":"Game","target":"Game_id"}],"incoming":[]},"AdventureObjectHOMM1":{"pk":"AdventureObject_id","type":"BIGINT","direct":false,"owner":{"column":"AdventureObject_id","table":"AdventureObject","target":"AdventureObject_id"},"expected":"HOMM1","refs":[{"column":"AdventureObject_id","table":"AdventureObject","target":"AdventureObject_id"}],"incoming":[]},"AdventureObjectHOMM2":{"pk":"AdventureObject_id","type":"BIGINT","direct":false,"owner":{"column":"AdventureObject_id","table":"AdventureObject","target":"AdventureObject_id"},"expected":"HOMM2","refs":[{"column":"AdventureObject_id","table":"AdventureObject","target":"AdventureObject_id"}],"incoming":[]},"AdventureObjectHOMM3":{"pk":"AdventureObject_id","type":"BIGINT","direct":false,"owner":{"column":"AdventureObject_id","table":"AdventureObject","target":"AdventureObject_id"},"expected":"HOMM3","refs":[{"column":"AdventureObject_id","table":"AdventureObject","target":"AdventureObject_id"}],"incoming":[]},"AdventureObjectHOMM4":{"pk":"AdventureObject_id","type":"BIGINT","direct":false,"owner":{"column":"AdventureObject_id","table":"AdventureObject","target":"AdventureObject_id"},"expected":"HOMM4","refs":[{"column":"AdventureObject_id","table":"AdventureObject","target":"AdventureObject_id"}],"incoming":[]},"AdventureObjectHOMM5":{"pk":"AdventureObject_id","type":"BIGINT","direct":false,"owner":{"column":"AdventureObject_id","table":"AdventureObject","target":"AdventureObject_id"},"expected":"HOMM5","refs":[{"column":"AdventureObject_id","table":"AdventureObject","target":"AdventureObject_id"}],"incoming":[]},"AdventureObjectHOMM6":{"pk":"AdventureObject_id","type":"BIGINT","direct":false,"owner":{"column":"AdventureObject_id","table":"AdventureObject","target":"AdventureObject_id"},"expected":"HOMM6","refs":[{"column":"AdventureObject_id","table":"AdventureObject","target":"AdventureObject_id"}],"incoming":[]},"AdventureObjectHOMM7":{"pk":"AdventureObject_id","type":"BIGINT","direct":false,"owner":{"column":"AdventureObject_id","table":"AdventureObject","target":"AdventureObject_id"},"expected":"HOMM7","refs":[{"column":"AdventureObject_id","table":"AdventureObject","target":"AdventureObject_id"}],"incoming":[]},"AdventureObjectHOMM8":{"pk":"AdventureObject_id","type":"BIGINT","direct":false,"owner":{"column":"AdventureObject_id","table":"AdventureObject","target":"AdventureObject_id"},"expected":"HOMM8","refs":[{"column":"AdventureObject_id","table":"AdventureObject","target":"AdventureObject_id"}],"incoming":[]},"Artifact":{"pk":"Artifact_id","type":"BIGINT","direct":true,"owner":null,"expected":null,"refs":[{"column":"Game_id","table":"Game","target":"Game_id"},{"column":"IntroducedInExpansion_id","table":"Expansion","target":"Expansion_id"},{"column":"MediaAsset_id","table":"MediaAsset","target":"MediaAsset_id"}],"incoming":[{"table":"ArtifactComponent","column":"ComponentArtifact_id"},{"table":"ArtifactComponent","column":"CompositeArtifact_id"},{"table":"ArtifactHOMM1","column":"Artifact_id"},{"table":"ArtifactHOMM2","column":"Artifact_id"},{"table":"ArtifactHOMM3","column":"Artifact_id"},{"table":"ArtifactHOMM4","column":"Artifact_id"},{"table":"ArtifactHOMM5","column":"Artifact_id"},{"table":"ArtifactHOMM6","column":"Artifact_id"},{"table":"ArtifactHOMM7","column":"Artifact_id"},{"table":"ArtifactHOMM8","column":"Artifact_id"},{"table":"ArtifactResourceCost","column":"Artifact_id"}]},"ArtifactComponent":{"pk":"ArtifactComponent_cid","type":"TEXT","direct":true,"owner":null,"expected":null,"refs":[{"column":"ComponentArtifact_id","table":"Artifact","target":"Artifact_id"},{"column":"CompositeArtifact_id","table":"Artifact","target":"Artifact_id"},{"column":"Game_id","table":"Game","target":"Game_id"}],"incoming":[]},"ArtifactHOMM1":{"pk":"Artifact_id","type":"BIGINT","direct":false,"owner":{"column":"Artifact_id","table":"Artifact","target":"Artifact_id"},"expected":"HOMM1","refs":[{"column":"Artifact_id","table":"Artifact","target":"Artifact_id"}],"incoming":[]},"ArtifactHOMM2":{"pk":"Artifact_id","type":"BIGINT","direct":false,"owner":{"column":"Artifact_id","table":"Artifact","target":"Artifact_id"},"expected":"HOMM2","refs":[{"column":"Artifact_id","table":"Artifact","target":"Artifact_id"},{"column":"GrantedSpell_id","table":"Spell","target":"Spell_id"}],"incoming":[]},"ArtifactHOMM3":{"pk":"Artifact_id","type":"BIGINT","direct":false,"owner":{"column":"Artifact_id","table":"Artifact","target":"Artifact_id"},"expected":"HOMM3","refs":[{"column":"Artifact_id","table":"Artifact","target":"Artifact_id"}],"incoming":[]},"ArtifactHOMM4":{"pk":"Artifact_id","type":"BIGINT","direct":false,"owner":{"column":"Artifact_id","table":"Artifact","target":"Artifact_id"},"expected":"HOMM4","refs":[{"column":"Artifact_id","table":"Artifact","target":"Artifact_id"}],"incoming":[]},"ArtifactHOMM5":{"pk":"Artifact_id","type":"BIGINT","direct":false,"owner":{"column":"Artifact_id","table":"Artifact","target":"Artifact_id"},"expected":"HOMM5","refs":[{"column":"Artifact_id","table":"Artifact","target":"Artifact_id"},{"column":"ArtifactSetHOMM5_id","table":"ArtifactSetHOMM5","target":"ArtifactSetHOMM5_id"}],"incoming":[]},"ArtifactHOMM6":{"pk":"Artifact_id","type":"BIGINT","direct":false,"owner":{"column":"Artifact_id","table":"Artifact","target":"Artifact_id"},"expected":"HOMM6","refs":[{"column":"Artifact_id","table":"Artifact","target":"Artifact_id"},{"column":"GrantedSpell_id","table":"Spell","target":"Spell_id"}],"incoming":[]},"ArtifactHOMM7":{"pk":"Artifact_id","type":"BIGINT","direct":false,"owner":{"column":"Artifact_id","table":"Artifact","target":"Artifact_id"},"expected":"HOMM7","refs":[{"column":"Artifact_id","table":"Artifact","target":"Artifact_id"}],"incoming":[]},"ArtifactHOMM8":{"pk":"Artifact_id","type":"BIGINT","direct":false,"owner":{"column":"Artifact_id","table":"Artifact","target":"Artifact_id"},"expected":"HOMM8","refs":[{"column":"Artifact_id","table":"Artifact","target":"Artifact_id"}],"incoming":[]},"ArtifactResourceCost":{"pk":"ArtifactResourceCost_cid","type":"TEXT","direct":true,"owner":null,"expected":null,"refs":[{"column":"Artifact_id","table":"Artifact","target":"Artifact_id"},{"column":"Game_id","table":"Game","target":"Game_id"},{"column":"Resource_id","table":"Resource","target":"Resource_id"}],"incoming":[]},"ArtifactSetBonusHOMM5":{"pk":"ArtifactSetBonusHOMM5_id","type":"BIGINT","direct":false,"owner":{"column":"ArtifactSetHOMM5_id","table":"ArtifactSetHOMM5","target":"ArtifactSetHOMM5_id"},"expected":"HOMM5","refs":[{"column":"ArtifactSetHOMM5_id","table":"ArtifactSetHOMM5","target":"ArtifactSetHOMM5_id"},{"column":"HeroClass_id","table":"HeroClass","target":"HeroClass_id"}],"incoming":[]},"ArtifactSetHOMM5":{"pk":"ArtifactSetHOMM5_id","type":"BIGINT","direct":false,"owner":{"column":"IntroducedInExpansion_id","table":"Expansion","target":"Expansion_id"},"expected":"HOMM5","refs":[{"column":"IntroducedInExpansion_id","table":"Expansion","target":"Expansion_id"}],"incoming":[{"table":"ArtifactHOMM5","column":"ArtifactSetHOMM5_id"},{"table":"ArtifactSetBonusHOMM5","column":"ArtifactSetHOMM5_id"}]},"AstrologyHOMM8":{"pk":"Game_id","type":"BIGINT","direct":true,"owner":{"column":"Game_id","table":"Game","target":"Game_id"},"expected":"HOMM8","refs":[{"column":"AstrologyPointResource_id","table":"Resource","target":"Resource_id"},{"column":"Game_id","table":"Game","target":"Game_id"},{"column":"InsightResource_id","table":"Resource","target":"Resource_id"},{"column":"NeutralMagicSchool_id","table":"MagicSchool","target":"MagicSchool_id"}],"incoming":[]},"Building":{"pk":"Building_id","type":"BIGINT","direct":true,"owner":null,"expected":null,"refs":[{"column":"Game_id","table":"Game","target":"Game_id"},{"column":"IntroducedInExpansion_id","table":"Expansion","target":"Expansion_id"},{"column":"MediaAsset_id","table":"MediaAsset","target":"MediaAsset_id"}],"incoming":[{"table":"BuildingCreature","column":"Building_id"},{"table":"BuildingHOMM1","column":"Building_id"},{"table":"BuildingHOMM2","column":"Building_id"},{"table":"BuildingHOMM3","column":"Building_id"},{"table":"BuildingHOMM4","column":"Building_id"},{"table":"BuildingHOMM5","column":"Building_id"},{"table":"BuildingHOMM6","column":"Building_id"},{"table":"BuildingHOMM7","column":"Building_id"},{"table":"BuildingHOMM8","column":"Building_id"},{"table":"BuildingHOMM8","column":"ChoiceBuildingA_id"},{"table":"BuildingHOMM8","column":"ChoiceBuildingB_id"},{"table":"BuildingRequirement","column":"Building_id"},{"table":"BuildingRequirement","column":"RequiredBuilding_id"},{"table":"BuildingResourceCost","column":"Building_id"},{"table":"BuildingUpgrade","column":"BaseBuilding_id"},{"table":"BuildingUpgrade","column":"UpgradedBuilding_id"},{"table":"TownScreenBuilding","column":"Building_id"}]},"BuildingCreature":{"pk":"BuildingCreature_cid","type":"TEXT","direct":true,"owner":null,"expected":null,"refs":[{"column":"Building_id","table":"Building","target":"Building_id"},{"column":"Creature_id","table":"Creature","target":"Creature_id"},{"column":"Game_id","table":"Game","target":"Game_id"}],"incoming":[]},"BuildingHOMM1":{"pk":"Building_id","type":"BIGINT","direct":false,"owner":{"column":"Building_id","table":"Building","target":"Building_id"},"expected":"HOMM1","refs":[{"column":"Building_id","table":"Building","target":"Building_id"},{"column":"Faction_id","table":"Faction","target":"Faction_id"}],"incoming":[]},"BuildingHOMM2":{"pk":"Building_id","type":"BIGINT","direct":false,"owner":{"column":"Building_id","table":"Building","target":"Building_id"},"expected":"HOMM2","refs":[{"column":"Building_id","table":"Building","target":"Building_id"},{"column":"Faction_id","table":"Faction","target":"Faction_id"}],"incoming":[]},"BuildingHOMM3":{"pk":"Building_id","type":"BIGINT","direct":false,"owner":{"column":"Building_id","table":"Building","target":"Building_id"},"expected":"HOMM3","refs":[{"column":"Building_id","table":"Building","target":"Building_id"},{"column":"Faction_id","table":"Faction","target":"Faction_id"}],"incoming":[]},"BuildingHOMM4":{"pk":"Building_id","type":"BIGINT","direct":false,"owner":{"column":"Building_id","table":"Building","target":"Building_id"},"expected":"HOMM4","refs":[{"column":"Building_id","table":"Building","target":"Building_id"},{"column":"Faction_id","table":"Faction","target":"Faction_id"}],"incoming":[]},"BuildingHOMM5":{"pk":"Building_id","type":"BIGINT","direct":false,"owner":{"column":"Building_id","table":"Building","target":"Building_id"},"expected":"HOMM5","refs":[{"column":"Building_id","table":"Building","target":"Building_id"},{"column":"Faction_id","table":"Faction","target":"Faction_id"}],"incoming":[]},"BuildingHOMM6":{"pk":"Building_id","type":"BIGINT","direct":false,"owner":{"column":"Building_id","table":"Building","target":"Building_id"},"expected":"HOMM6","refs":[{"column":"Building_id","table":"Building","target":"Building_id"},{"column":"Faction_id","table":"Faction","target":"Faction_id"}],"incoming":[]},"BuildingHOMM7":{"pk":"Building_id","type":"BIGINT","direct":false,"owner":{"column":"Building_id","table":"Building","target":"Building_id"},"expected":"HOMM7","refs":[{"column":"Building_id","table":"Building","target":"Building_id"},{"column":"Faction_id","table":"Faction","target":"Faction_id"}],"incoming":[]},"BuildingHOMM8":{"pk":"Building_id","type":"BIGINT","direct":false,"owner":{"column":"Building_id","table":"Building","target":"Building_id"},"expected":"HOMM8","refs":[{"column":"Building_id","table":"Building","target":"Building_id"},{"column":"ChoiceBuildingA_id","table":"Building","target":"Building_id"},{"column":"ChoiceBuildingB_id","table":"Building","target":"Building_id"},{"column":"Faction_id","table":"Faction","target":"Faction_id"}],"incoming":[]},"BuildingRequirement":{"pk":"BuildingRequirement_cid","type":"TEXT","direct":true,"owner":null,"expected":null,"refs":[{"column":"Building_id","table":"Building","target":"Building_id"},{"column":"Game_id","table":"Game","target":"Game_id"},{"column":"RequiredBuilding_id","table":"Building","target":"Building_id"}],"incoming":[]},"BuildingResourceCost":{"pk":"BuildingResourceCost_cid","type":"TEXT","direct":true,"owner":null,"expected":null,"refs":[{"column":"Building_id","table":"Building","target":"Building_id"},{"column":"Game_id","table":"Game","target":"Game_id"},{"column":"Resource_id","table":"Resource","target":"Resource_id"}],"incoming":[]},"BuildingUpgrade":{"pk":"BuildingUpgrade_cid","type":"TEXT","direct":true,"owner":null,"expected":null,"refs":[{"column":"BaseBuilding_id","table":"Building","target":"Building_id"},{"column":"Game_id","table":"Game","target":"Game_id"},{"column":"UpgradedBuilding_id","table":"Building","target":"Building_id"}],"incoming":[]},"Campaign":{"pk":"Campaign_id","type":"BIGINT","direct":true,"owner":null,"expected":null,"refs":[{"column":"Expansion_id","table":"Expansion","target":"Expansion_id"},{"column":"Game_id","table":"Game","target":"Game_id"},{"column":"MediaAsset_id","table":"MediaAsset","target":"MediaAsset_id"}],"incoming":[{"table":"CampaignHero","column":"Campaign_id"},{"table":"CampaignHOMM1","column":"Campaign_id"},{"table":"CampaignHOMM2","column":"Campaign_id"},{"table":"CampaignHOMM4","column":"Campaign_id"},{"table":"CampaignHOMM8","column":"Campaign_id"},{"table":"CampaignScenario","column":"Campaign_id"},{"table":"LoreFull","column":"Campaign_id"},{"table":"Soundtrack","column":"Campaign_id"},{"table":"Video","column":"Campaign_id"}]},"CampaignHero":{"pk":"CampaignHero_cid","type":"TEXT","direct":true,"owner":null,"expected":null,"refs":[{"column":"Campaign_id","table":"Campaign","target":"Campaign_id"},{"column":"Game_id","table":"Game","target":"Game_id"},{"column":"Hero_id","table":"Hero","target":"Hero_id"},{"column":"StartingScenario_id","table":"Scenario","target":"Scenario_id"}],"incoming":[{"table":"LoreFull","column":"CampaignHero_cid"}]},"CampaignHOMM1":{"pk":"Campaign_id","type":"BIGINT","direct":false,"owner":{"column":"Campaign_id","table":"Campaign","target":"Campaign_id"},"expected":"HOMM1","refs":[{"column":"Campaign_id","table":"Campaign","target":"Campaign_id"}],"incoming":[]},"CampaignHOMM2":{"pk":"Campaign_id","type":"BIGINT","direct":false,"owner":{"column":"Campaign_id","table":"Campaign","target":"Campaign_id"},"expected":"HOMM2","refs":[{"column":"Campaign_id","table":"Campaign","target":"Campaign_id"}],"incoming":[]},"CampaignHOMM4":{"pk":"Campaign_id","type":"BIGINT","direct":false,"owner":{"column":"Campaign_id","table":"Campaign","target":"Campaign_id"},"expected":"HOMM4","refs":[{"column":"Campaign_id","table":"Campaign","target":"Campaign_id"}],"incoming":[]},"CampaignHOMM8":{"pk":"Campaign_id","type":"BIGINT","direct":false,"owner":{"column":"Campaign_id","table":"Campaign","target":"Campaign_id"},"expected":"HOMM8","refs":[{"column":"Campaign_id","table":"Campaign","target":"Campaign_id"}],"incoming":[]},"CampaignScenario":{"pk":"CampaignScenario_cid","type":"TEXT","direct":true,"owner":null,"expected":null,"refs":[{"column":"Campaign_id","table":"Campaign","target":"Campaign_id"},{"column":"Game_id","table":"Game","target":"Game_id"},{"column":"Scenario_id","table":"Scenario","target":"Scenario_id"}],"incoming":[]},"Creature":{"pk":"Creature_id","type":"BIGINT","direct":true,"owner":null,"expected":null,"refs":[{"column":"Game_id","table":"Game","target":"Game_id"},{"column":"IntroducedInExpansion_id","table":"Expansion","target":"Expansion_id"},{"column":"MediaAsset_id","table":"MediaAsset","target":"MediaAsset_id"}],"incoming":[{"table":"AdventureObjectCreature","column":"Creature_id"},{"table":"BuildingCreature","column":"Creature_id"},{"table":"CreatureAbility","column":"Creature_id"},{"table":"CreatureHOMM1","column":"Creature_id"},{"table":"CreatureHOMM2","column":"Creature_id"},{"table":"CreatureHOMM3","column":"Creature_id"},{"table":"CreatureHOMM4","column":"Creature_id"},{"table":"CreatureHOMM5","column":"Creature_id"},{"table":"CreatureHOMM6","column":"Creature_id"},{"table":"CreatureHOMM7","column":"Creature_id"},{"table":"CreatureHOMM8","column":"Creature_id"},{"table":"CreatureHOMM8","column":"UpgradeCreatureA_id"},{"table":"CreatureHOMM8","column":"UpgradeCreatureB_id"},{"table":"CreatureResourceCost","column":"Creature_id"},{"table":"CreatureSpell","column":"Creature_id"},{"table":"CreatureUpgrade","column":"BaseCreature_id"},{"table":"CreatureUpgrade","column":"UpgradedCreature_id"},{"table":"HeroHOMM8","column":"StartingCreature1_id"},{"table":"HeroHOMM8","column":"StartingCreature2_id"},{"table":"HeroHOMM8","column":"StartingCreature3_id"}]},"CreatureAbility":{"pk":"CreatureAbility_cid","type":"TEXT","direct":true,"owner":null,"expected":null,"refs":[{"column":"Ability_id","table":"Ability","target":"Ability_id"},{"column":"Creature_id","table":"Creature","target":"Creature_id"},{"column":"Game_id","table":"Game","target":"Game_id"}],"incoming":[]},"CreatureHOMM1":{"pk":"Creature_id","type":"BIGINT","direct":false,"owner":{"column":"Creature_id","table":"Creature","target":"Creature_id"},"expected":"HOMM1","refs":[{"column":"Creature_id","table":"Creature","target":"Creature_id"},{"column":"Faction_id","table":"Faction","target":"Faction_id"}],"incoming":[]},"CreatureHOMM2":{"pk":"Creature_id","type":"BIGINT","direct":false,"owner":{"column":"Creature_id","table":"Creature","target":"Creature_id"},"expected":"HOMM2","refs":[{"column":"Creature_id","table":"Creature","target":"Creature_id"},{"column":"Faction_id","table":"Faction","target":"Faction_id"}],"incoming":[]},"CreatureHOMM3":{"pk":"Creature_id","type":"BIGINT","direct":false,"owner":{"column":"Creature_id","table":"Creature","target":"Creature_id"},"expected":"HOMM3","refs":[{"column":"Creature_id","table":"Creature","target":"Creature_id"},{"column":"Faction_id","table":"Faction","target":"Faction_id"}],"incoming":[]},"CreatureHOMM4":{"pk":"Creature_id","type":"BIGINT","direct":false,"owner":{"column":"Creature_id","table":"Creature","target":"Creature_id"},"expected":"HOMM4","refs":[{"column":"Creature_id","table":"Creature","target":"Creature_id"},{"column":"Faction_id","table":"Faction","target":"Faction_id"}],"incoming":[]},"CreatureHOMM5":{"pk":"Creature_id","type":"BIGINT","direct":false,"owner":{"column":"Creature_id","table":"Creature","target":"Creature_id"},"expected":"HOMM5","refs":[{"column":"Creature_id","table":"Creature","target":"Creature_id"},{"column":"Faction_id","table":"Faction","target":"Faction_id"}],"incoming":[]},"CreatureHOMM6":{"pk":"Creature_id","type":"BIGINT","direct":false,"owner":{"column":"Creature_id","table":"Creature","target":"Creature_id"},"expected":"HOMM6","refs":[{"column":"Creature_id","table":"Creature","target":"Creature_id"},{"column":"Faction_id","table":"Faction","target":"Faction_id"}],"incoming":[]},"CreatureHOMM7":{"pk":"Creature_id","type":"BIGINT","direct":false,"owner":{"column":"Creature_id","table":"Creature","target":"Creature_id"},"expected":"HOMM7","refs":[{"column":"Creature_id","table":"Creature","target":"Creature_id"},{"column":"Faction_id","table":"Faction","target":"Faction_id"}],"incoming":[]},"CreatureHOMM8":{"pk":"Creature_id","type":"BIGINT","direct":false,"owner":{"column":"Creature_id","table":"Creature","target":"Creature_id"},"expected":"HOMM8","refs":[{"column":"Creature_id","table":"Creature","target":"Creature_id"},{"column":"Faction_id","table":"Faction","target":"Faction_id"},{"column":"UpgradeCreatureA_id","table":"Creature","target":"Creature_id"},{"column":"UpgradeCreatureB_id","table":"Creature","target":"Creature_id"}],"incoming":[]},"CreatureResourceCost":{"pk":"CreatureResourceCost_cid","type":"TEXT","direct":true,"owner":null,"expected":null,"refs":[{"column":"Creature_id","table":"Creature","target":"Creature_id"},{"column":"Game_id","table":"Game","target":"Game_id"},{"column":"Resource_id","table":"Resource","target":"Resource_id"}],"incoming":[]},"CreatureSpell":{"pk":"CreatureSpell_cid","type":"TEXT","direct":true,"owner":null,"expected":null,"refs":[{"column":"Creature_id","table":"Creature","target":"Creature_id"},{"column":"Game_id","table":"Game","target":"Game_id"},{"column":"Spell_id","table":"Spell","target":"Spell_id"}],"incoming":[]},"CreatureUpgrade":{"pk":"CreatureUpgrade_cid","type":"TEXT","direct":true,"owner":null,"expected":null,"refs":[{"column":"BaseCreature_id","table":"Creature","target":"Creature_id"},{"column":"Game_id","table":"Game","target":"Game_id"},{"column":"UpgradedCreature_id","table":"Creature","target":"Creature_id"}],"incoming":[]},"Expansion":{"pk":"Expansion_id","type":"BIGINT","direct":true,"owner":null,"expected":null,"refs":[{"column":"Game_id","table":"Game","target":"Game_id"}],"incoming":[{"table":"AbilityHOMM7","column":"IntroducedInExpansion_id"},{"table":"AdventureObject","column":"IntroducedInExpansion_id"},{"table":"Artifact","column":"IntroducedInExpansion_id"},{"table":"ArtifactSetHOMM5","column":"IntroducedInExpansion_id"},{"table":"Building","column":"IntroducedInExpansion_id"},{"table":"Campaign","column":"Expansion_id"},{"table":"Creature","column":"IntroducedInExpansion_id"},{"table":"Faction","column":"IntroducedInExpansion_id"},{"table":"GameResource","column":"IntroducedInExpansion_id"},{"table":"Hero","column":"IntroducedInExpansion_id"},{"table":"HeroClass","column":"IntroducedInExpansion_id"},{"table":"Lore","column":"IntroducedInExpansion_id"},{"table":"Map","column":"IntroducedInExpansion_id"},{"table":"MediaAsset","column":"Expansion_id"},{"table":"Patch","column":"Expansion_id"},{"table":"Scenario","column":"IntroducedInExpansion_id"},{"table":"Screenshot","column":"Expansion_id"},{"table":"Skill","column":"IntroducedInExpansion_id"},{"table":"Spell","column":"IntroducedInExpansion_id"},{"table":"Terrain","column":"IntroducedInExpansion_id"}]},"Faction":{"pk":"Faction_id","type":"BIGINT","direct":true,"owner":null,"expected":null,"refs":[{"column":"Game_id","table":"Game","target":"Game_id"},{"column":"IntroducedInExpansion_id","table":"Expansion","target":"Expansion_id"},{"column":"MediaAsset_id","table":"MediaAsset","target":"MediaAsset_id"}],"incoming":[{"table":"AdventureObjectFaction","column":"Faction_id"},{"table":"BuildingHOMM1","column":"Faction_id"},{"table":"BuildingHOMM2","column":"Faction_id"},{"table":"BuildingHOMM3","column":"Faction_id"},{"table":"BuildingHOMM4","column":"Faction_id"},{"table":"BuildingHOMM5","column":"Faction_id"},{"table":"BuildingHOMM6","column":"Faction_id"},{"table":"BuildingHOMM7","column":"Faction_id"},{"table":"BuildingHOMM8","column":"Faction_id"},{"table":"CreatureHOMM1","column":"Faction_id"},{"table":"CreatureHOMM2","column":"Faction_id"},{"table":"CreatureHOMM3","column":"Faction_id"},{"table":"CreatureHOMM4","column":"Faction_id"},{"table":"CreatureHOMM5","column":"Faction_id"},{"table":"CreatureHOMM6","column":"Faction_id"},{"table":"CreatureHOMM7","column":"Faction_id"},{"table":"CreatureHOMM8","column":"Faction_id"},{"table":"FactionHOMM1","column":"Faction_id"},{"table":"FactionHOMM2","column":"Faction_id"},{"table":"FactionHOMM3","column":"Faction_id"},{"table":"FactionHOMM4","column":"AlliedFactionA_id"},{"table":"FactionHOMM4","column":"AlliedFactionB_id"},{"table":"FactionHOMM4","column":"Faction_id"},{"table":"FactionHOMM5","column":"Faction_id"},{"table":"FactionHOMM6","column":"Faction_id"},{"table":"FactionHOMM7","column":"Faction_id"},{"table":"FactionHOMM8","column":"Faction_id"},{"table":"FactionLaw","column":"Faction_id"},{"table":"FactionMagicSchoolHOMM5","column":"Faction_id"},{"table":"FactionNativeTerrainHOMM5","column":"Faction_id"},{"table":"FactionSpell","column":"Faction_id"},{"table":"HeroClassHOMM1","column":"Faction_id"},{"table":"HeroClassHOMM2","column":"Faction_id"},{"table":"HeroClassHOMM3","column":"Faction_id"},{"table":"HeroClassHOMM4","column":"StartingFaction_id"},{"table":"HeroClassHOMM5","column":"Faction_id"},{"table":"HeroClassHOMM6","column":"Faction_id"},{"table":"HeroClassHOMM7","column":"Faction_id"},{"table":"HeroClassHOMM8","column":"Faction_id"},{"table":"LoreFull","column":"Faction_id"},{"table":"Soundtrack","column":"Faction_id"},{"table":"TownScreen","column":"Faction_id"}]},"FactionHOMM1":{"pk":"Faction_id","type":"BIGINT","direct":false,"owner":{"column":"Faction_id","table":"Faction","target":"Faction_id"},"expected":"HOMM1","refs":[{"column":"Faction_id","table":"Faction","target":"Faction_id"}],"incoming":[]},"FactionHOMM2":{"pk":"Faction_id","type":"BIGINT","direct":false,"owner":{"column":"Faction_id","table":"Faction","target":"Faction_id"},"expected":"HOMM2","refs":[{"column":"Faction_id","table":"Faction","target":"Faction_id"}],"incoming":[]},"FactionHOMM3":{"pk":"Faction_id","type":"BIGINT","direct":false,"owner":{"column":"Faction_id","table":"Faction","target":"Faction_id"},"expected":"HOMM3","refs":[{"column":"Faction_id","table":"Faction","target":"Faction_id"},{"column":"NativeTerrain_id","table":"Terrain","target":"Terrain_id"}],"incoming":[]},"FactionHOMM4":{"pk":"Faction_id","type":"BIGINT","direct":false,"owner":{"column":"Faction_id","table":"Faction","target":"Faction_id"},"expected":"HOMM4","refs":[{"column":"AlliedFactionA_id","table":"Faction","target":"Faction_id"},{"column":"AlliedFactionB_id","table":"Faction","target":"Faction_id"},{"column":"Faction_id","table":"Faction","target":"Faction_id"},{"column":"NativeMagicSchool_id","table":"MagicSchool","target":"MagicSchool_id"},{"column":"NativeTerrain_id","table":"Terrain","target":"Terrain_id"}],"incoming":[]},"FactionHOMM5":{"pk":"Faction_id","type":"BIGINT","direct":false,"owner":{"column":"Faction_id","table":"Faction","target":"Faction_id"},"expected":"HOMM5","refs":[{"column":"Faction_id","table":"Faction","target":"Faction_id"},{"column":"RacialSkill_id","table":"Skill","target":"Skill_id"}],"incoming":[]},"FactionHOMM6":{"pk":"Faction_id","type":"BIGINT","direct":false,"owner":{"column":"Faction_id","table":"Faction","target":"Faction_id"},"expected":"HOMM6","refs":[{"column":"Faction_id","table":"Faction","target":"Faction_id"},{"column":"FactionAbility_id","table":"Ability","target":"Ability_id"}],"incoming":[]},"FactionHOMM7":{"pk":"Faction_id","type":"BIGINT","direct":false,"owner":{"column":"Faction_id","table":"Faction","target":"Faction_id"},"expected":"HOMM7","refs":[{"column":"Faction_id","table":"Faction","target":"Faction_id"},{"column":"RacialSkill_id","table":"Skill","target":"Skill_id"}],"incoming":[]},"FactionHOMM8":{"pk":"Faction_id","type":"BIGINT","direct":false,"owner":{"column":"Faction_id","table":"Faction","target":"Faction_id"},"expected":"HOMM8","refs":[{"column":"Faction_id","table":"Faction","target":"Faction_id"},{"column":"FactionSkill_id","table":"Skill","target":"Skill_id"},{"column":"LawScreenMediaAsset_id","table":"MediaAsset","target":"MediaAsset_id"},{"column":"NativeTerrain_id","table":"Terrain","target":"Terrain_id"},{"column":"SignatureResource_id","table":"Resource","target":"Resource_id"}],"incoming":[]},"FactionLaw":{"pk":"FactionLaw_id","type":"BIGINT","direct":false,"owner":{"column":"Faction_id","table":"Faction","target":"Faction_id"},"expected":"HOMM8","refs":[{"column":"Faction_id","table":"Faction","target":"Faction_id"},{"column":"MediaAsset_id","table":"MediaAsset","target":"MediaAsset_id"}],"incoming":[]},"FactionMagicSchoolHOMM5":{"pk":"FactionMagicSchoolHOMM5_cid","type":"TEXT","direct":true,"owner":null,"expected":"HOMM5","refs":[{"column":"Faction_id","table":"Faction","target":"Faction_id"},{"column":"Game_id","table":"Game","target":"Game_id"},{"column":"MagicSchool_id","table":"MagicSchool","target":"MagicSchool_id"}],"incoming":[]},"FactionNativeTerrainHOMM5":{"pk":"FactionNativeTerrainHOMM5_cid","type":"TEXT","direct":true,"owner":null,"expected":"HOMM5","refs":[{"column":"Faction_id","table":"Faction","target":"Faction_id"},{"column":"Game_id","table":"Game","target":"Game_id"},{"column":"Terrain_id","table":"Terrain","target":"Terrain_id"}],"incoming":[]},"FactionSpell":{"pk":"FactionSpell_cid","type":"TEXT","direct":true,"owner":null,"expected":null,"refs":[{"column":"Faction_id","table":"Faction","target":"Faction_id"},{"column":"Game_id","table":"Game","target":"Game_id"},{"column":"Spell_id","table":"Spell","target":"Spell_id"}],"incoming":[]},"Game":{"pk":"Game_id","type":"BIGINT","direct":true,"owner":null,"expected":null,"refs":[],"incoming":[{"table":"Ability","column":"Game_id"},{"table":"AdventureObject","column":"Game_id"},{"table":"AdventureObjectCreature","column":"Game_id"},{"table":"AdventureObjectFaction","column":"Game_id"},{"table":"Artifact","column":"Game_id"},{"table":"ArtifactComponent","column":"Game_id"},{"table":"ArtifactResourceCost","column":"Game_id"},{"table":"AstrologyHOMM8","column":"Game_id"},{"table":"Building","column":"Game_id"},{"table":"BuildingCreature","column":"Game_id"},{"table":"BuildingRequirement","column":"Game_id"},{"table":"BuildingResourceCost","column":"Game_id"},{"table":"BuildingUpgrade","column":"Game_id"},{"table":"Campaign","column":"Game_id"},{"table":"CampaignHero","column":"Game_id"},{"table":"CampaignScenario","column":"Game_id"},{"table":"Creature","column":"Game_id"},{"table":"CreatureAbility","column":"Game_id"},{"table":"CreatureResourceCost","column":"Game_id"},{"table":"CreatureSpell","column":"Game_id"},{"table":"CreatureUpgrade","column":"Game_id"},{"table":"Expansion","column":"Game_id"},{"table":"Faction","column":"Game_id"},{"table":"FactionMagicSchoolHOMM5","column":"Game_id"},{"table":"FactionNativeTerrainHOMM5","column":"Game_id"},{"table":"FactionSpell","column":"Game_id"},{"table":"GameHOMM8","column":"Game_id"},{"table":"GameResource","column":"Game_id"},{"table":"Hero","column":"Game_id"},{"table":"HeroClass","column":"Game_id"},{"table":"HeroClassAbility","column":"Game_id"},{"table":"HeroClassAbilityRequirementGroup","column":"Game_id"},{"table":"HeroClassPrimarySkillHOMM4","column":"Game_id"},{"table":"HeroSkill","column":"Game_id"},{"table":"Lore","column":"Game_id"},{"table":"LoreFull","column":"Game_id"},{"table":"MagicSchool","column":"Game_id"},{"table":"Map","column":"Game_id"},{"table":"MapObjectPresence","column":"Game_id"},{"table":"MapTerrain","column":"Game_id"},{"table":"MediaAsset","column":"Game_id"},{"table":"Patch","column":"Game_id"},{"table":"Scenario","column":"Game_id"},{"table":"ScenarioConnection","column":"Game_id"},{"table":"Screenshot","column":"Game_id"},{"table":"Skill","column":"Game_id"},{"table":"Soundtrack","column":"Game_id"},{"table":"Spell","column":"Game_id"},{"table":"SpellMagicSchool","column":"Game_id"},{"table":"SpellResourceCostHOMM5","column":"Game_id"},{"table":"Terrain","column":"Game_id"},{"table":"TownScreen","column":"Game_id"},{"table":"TownScreenBuilding","column":"Game_id"},{"table":"Video","column":"Game_id"}]},"GameHOMM8":{"pk":"Game_id","type":"BIGINT","direct":true,"owner":{"column":"Game_id","table":"Game","target":"Game_id"},"expected":"HOMM8","refs":[{"column":"CurrentPatch_id","table":"Patch","target":"Patch_id"},{"column":"Game_id","table":"Game","target":"Game_id"}],"incoming":[]},"GameResource":{"pk":"GameResource_cid","type":"TEXT","direct":true,"owner":null,"expected":null,"refs":[{"column":"Game_id","table":"Game","target":"Game_id"},{"column":"IntroducedInExpansion_id","table":"Expansion","target":"Expansion_id"},{"column":"MediaAsset_id","table":"MediaAsset","target":"MediaAsset_id"},{"column":"Resource_id","table":"Resource","target":"Resource_id"}],"incoming":[]},"Hero":{"pk":"Hero_id","type":"BIGINT","direct":true,"owner":null,"expected":null,"refs":[{"column":"Game_id","table":"Game","target":"Game_id"},{"column":"HeroClass_id","table":"HeroClass","target":"HeroClass_id"},{"column":"IntroducedInExpansion_id","table":"Expansion","target":"Expansion_id"},{"column":"PortraitMediaAsset_id","table":"MediaAsset","target":"MediaAsset_id"}],"incoming":[{"table":"CampaignHero","column":"Hero_id"},{"table":"HeroHOMM2","column":"Hero_id"},{"table":"HeroHOMM3","column":"Hero_id"},{"table":"HeroHOMM5","column":"Hero_id"},{"table":"HeroHOMM6","column":"Hero_id"},{"table":"HeroHOMM7","column":"Hero_id"},{"table":"HeroHOMM8","column":"Hero_id"},{"table":"HeroSkill","column":"Hero_id"},{"table":"LoreFull","column":"Hero_id"}]},"HeroClass":{"pk":"HeroClass_id","type":"BIGINT","direct":true,"owner":null,"expected":null,"refs":[{"column":"Game_id","table":"Game","target":"Game_id"},{"column":"IntroducedInExpansion_id","table":"Expansion","target":"Expansion_id"},{"column":"MediaAsset_id","table":"MediaAsset","target":"MediaAsset_id"}],"incoming":[{"table":"ArtifactSetBonusHOMM5","column":"HeroClass_id"},{"table":"Hero","column":"HeroClass_id"},{"table":"HeroClassAbility","column":"HeroClass_id"},{"table":"HeroClassAbilityRequirementGroup","column":"HeroClass_id"},{"table":"HeroClassHOMM1","column":"HeroClass_id"},{"table":"HeroClassHOMM2","column":"HeroClass_id"},{"table":"HeroClassHOMM3","column":"HeroClass_id"},{"table":"HeroClassHOMM4","column":"HeroClass_id"},{"table":"HeroClassHOMM5","column":"HeroClass_id"},{"table":"HeroClassHOMM6","column":"BaseHeroClass_id"},{"table":"HeroClassHOMM6","column":"HeroClass_id"},{"table":"HeroClassHOMM7","column":"HeroClass_id"},{"table":"HeroClassHOMM8","column":"HeroClass_id"},{"table":"HeroClassPrimarySkillHOMM4","column":"HeroClass_id"}]},"HeroClassAbility":{"pk":"HeroClassAbility_cid","type":"TEXT","direct":true,"owner":null,"expected":null,"refs":[{"column":"Ability_id","table":"Ability","target":"Ability_id"},{"column":"Game_id","table":"Game","target":"Game_id"},{"column":"HeroClass_id","table":"HeroClass","target":"HeroClass_id"},{"column":"RequiredAbility_id","table":"Ability","target":"Ability_id"},{"column":"Skill_id","table":"Skill","target":"Skill_id"}],"incoming":[]},"HeroClassAbilityRequirementGroup":{"pk":"HeroClassAbilityRequirementGroup_cid","type":"TEXT","direct":true,"owner":null,"expected":null,"refs":[{"column":"Ability_id","table":"Ability","target":"Ability_id"},{"column":"Game_id","table":"Game","target":"Game_id"},{"column":"HeroClass_id","table":"HeroClass","target":"HeroClass_id"}],"incoming":[]},"HeroClassHOMM1":{"pk":"HeroClass_id","type":"BIGINT","direct":false,"owner":{"column":"HeroClass_id","table":"HeroClass","target":"HeroClass_id"},"expected":"HOMM1","refs":[{"column":"Faction_id","table":"Faction","target":"Faction_id"},{"column":"HeroClass_id","table":"HeroClass","target":"HeroClass_id"}],"incoming":[]},"HeroClassHOMM2":{"pk":"HeroClass_id","type":"BIGINT","direct":false,"owner":{"column":"HeroClass_id","table":"HeroClass","target":"HeroClass_id"},"expected":"HOMM2","refs":[{"column":"Faction_id","table":"Faction","target":"Faction_id"},{"column":"HeroClass_id","table":"HeroClass","target":"HeroClass_id"},{"column":"StartingSpell_id","table":"Spell","target":"Spell_id"}],"incoming":[]},"HeroClassHOMM3":{"pk":"HeroClass_id","type":"BIGINT","direct":false,"owner":{"column":"HeroClass_id","table":"HeroClass","target":"HeroClass_id"},"expected":"HOMM3","refs":[{"column":"Faction_id","table":"Faction","target":"Faction_id"},{"column":"HeroClass_id","table":"HeroClass","target":"HeroClass_id"}],"incoming":[]},"HeroClassHOMM4":{"pk":"HeroClass_id","type":"BIGINT","direct":false,"owner":{"column":"HeroClass_id","table":"HeroClass","target":"HeroClass_id"},"expected":"HOMM4","refs":[{"column":"HeroClass_id","table":"HeroClass","target":"HeroClass_id"},{"column":"StartingFaction_id","table":"Faction","target":"Faction_id"}],"incoming":[]},"HeroClassHOMM5":{"pk":"HeroClass_id","type":"BIGINT","direct":false,"owner":{"column":"HeroClass_id","table":"HeroClass","target":"HeroClass_id"},"expected":"HOMM5","refs":[{"column":"Faction_id","table":"Faction","target":"Faction_id"},{"column":"HeroClass_id","table":"HeroClass","target":"HeroClass_id"},{"column":"RacialSkill_id","table":"Skill","target":"Skill_id"}],"incoming":[]},"HeroClassHOMM6":{"pk":"HeroClass_id","type":"BIGINT","direct":false,"owner":{"column":"HeroClass_id","table":"HeroClass","target":"HeroClass_id"},"expected":"HOMM6","refs":[{"column":"BaseHeroClass_id","table":"HeroClass","target":"HeroClass_id"},{"column":"Faction_id","table":"Faction","target":"Faction_id"},{"column":"HeroClass_id","table":"HeroClass","target":"HeroClass_id"}],"incoming":[]},"HeroClassHOMM7":{"pk":"HeroClass_id","type":"BIGINT","direct":false,"owner":{"column":"HeroClass_id","table":"HeroClass","target":"HeroClass_id"},"expected":"HOMM7","refs":[{"column":"Faction_id","table":"Faction","target":"Faction_id"},{"column":"HeroClass_id","table":"HeroClass","target":"HeroClass_id"}],"incoming":[]},"HeroClassHOMM8":{"pk":"HeroClass_id","type":"BIGINT","direct":false,"owner":{"column":"HeroClass_id","table":"HeroClass","target":"HeroClass_id"},"expected":"HOMM8","refs":[{"column":"Faction_id","table":"Faction","target":"Faction_id"},{"column":"HeroClass_id","table":"HeroClass","target":"HeroClass_id"}],"incoming":[]},"HeroClassPrimarySkillHOMM4":{"pk":"HeroClassPrimarySkillHOMM4_cid","type":"TEXT","direct":true,"owner":null,"expected":"HOMM4","refs":[{"column":"Game_id","table":"Game","target":"Game_id"},{"column":"HeroClass_id","table":"HeroClass","target":"HeroClass_id"},{"column":"Skill_id","table":"Skill","target":"Skill_id"}],"incoming":[]},"HeroHOMM2":{"pk":"Hero_id","type":"BIGINT","direct":false,"owner":{"column":"Hero_id","table":"Hero","target":"Hero_id"},"expected":"HOMM2","refs":[{"column":"Hero_id","table":"Hero","target":"Hero_id"}],"incoming":[]},"HeroHOMM3":{"pk":"Hero_id","type":"BIGINT","direct":false,"owner":{"column":"Hero_id","table":"Hero","target":"Hero_id"},"expected":"HOMM3","refs":[{"column":"Hero_id","table":"Hero","target":"Hero_id"},{"column":"StartingSpell_id","table":"Spell","target":"Spell_id"}],"incoming":[]},"HeroHOMM5":{"pk":"Hero_id","type":"BIGINT","direct":false,"owner":{"column":"Hero_id","table":"Hero","target":"Hero_id"},"expected":"HOMM5","refs":[{"column":"Hero_id","table":"Hero","target":"Hero_id"},{"column":"StartingSpell_id","table":"Spell","target":"Spell_id"}],"incoming":[]},"HeroHOMM6":{"pk":"Hero_id","type":"BIGINT","direct":false,"owner":{"column":"Hero_id","table":"Hero","target":"Hero_id"},"expected":"HOMM6","refs":[{"column":"Hero_id","table":"Hero","target":"Hero_id"}],"incoming":[]},"HeroHOMM7":{"pk":"Hero_id","type":"BIGINT","direct":false,"owner":{"column":"Hero_id","table":"Hero","target":"Hero_id"},"expected":"HOMM7","refs":[{"column":"Hero_id","table":"Hero","target":"Hero_id"},{"column":"SpecializationAbility_id","table":"Ability","target":"Ability_id"},{"column":"StartingSkill_id","table":"Skill","target":"Skill_id"}],"incoming":[]},"HeroHOMM8":{"pk":"Hero_id","type":"BIGINT","direct":false,"owner":{"column":"Hero_id","table":"Hero","target":"Hero_id"},"expected":"HOMM8","refs":[{"column":"Hero_id","table":"Hero","target":"Hero_id"},{"column":"SpecializationAbility_id","table":"Ability","target":"Ability_id"},{"column":"StartingCreature1_id","table":"Creature","target":"Creature_id"},{"column":"StartingCreature2_id","table":"Creature","target":"Creature_id"},{"column":"StartingCreature3_id","table":"Creature","target":"Creature_id"},{"column":"StartingSkill_id","table":"Skill","target":"Skill_id"},{"column":"StartingSpell1_id","table":"Spell","target":"Spell_id"},{"column":"StartingSpell2_id","table":"Spell","target":"Spell_id"}],"incoming":[]},"HeroSkill":{"pk":"HeroSkill_cid","type":"TEXT","direct":true,"owner":null,"expected":null,"refs":[{"column":"Game_id","table":"Game","target":"Game_id"},{"column":"Hero_id","table":"Hero","target":"Hero_id"},{"column":"Skill_id","table":"Skill","target":"Skill_id"}],"incoming":[]},"Lore":{"pk":"Lore_id","type":"BIGINT","direct":true,"owner":null,"expected":null,"refs":[{"column":"Game_id","table":"Game","target":"Game_id"},{"column":"IntroducedInExpansion_id","table":"Expansion","target":"Expansion_id"},{"column":"MediaAsset_id","table":"MediaAsset","target":"MediaAsset_id"}],"incoming":[{"table":"LoreFull","column":"Lore_id"}]},"LoreFull":{"pk":"LoreFull_cid","type":"TEXT","direct":true,"owner":null,"expected":null,"refs":[{"column":"Campaign_id","table":"Campaign","target":"Campaign_id"},{"column":"CampaignHero_cid","table":"CampaignHero","target":"CampaignHero_cid"},{"column":"Faction_id","table":"Faction","target":"Faction_id"},{"column":"Game_id","table":"Game","target":"Game_id"},{"column":"Hero_id","table":"Hero","target":"Hero_id"},{"column":"Lore_id","table":"Lore","target":"Lore_id"},{"column":"Map_id","table":"Map","target":"Map_id"},{"column":"Scenario_id","table":"Scenario","target":"Scenario_id"}],"incoming":[]},"MagicSchool":{"pk":"MagicSchool_id","type":"BIGINT","direct":true,"owner":null,"expected":null,"refs":[{"column":"Game_id","table":"Game","target":"Game_id"},{"column":"MediaAsset_id","table":"MediaAsset","target":"MediaAsset_id"}],"incoming":[{"table":"AbilityHOMM6","column":"MagicSchool_id"},{"table":"AstrologyHOMM8","column":"NeutralMagicSchool_id"},{"table":"FactionHOMM4","column":"NativeMagicSchool_id"},{"table":"FactionMagicSchoolHOMM5","column":"MagicSchool_id"},{"table":"MagicSchoolHOMM4","column":"MagicSchool_id"},{"table":"MagicSchoolHOMM4","column":"OpposingMagicSchool_id"},{"table":"MagicSchoolHOMM5","column":"MagicSchool_id"},{"table":"MagicSchoolHOMM6","column":"MagicSchool_id"},{"table":"MagicSchoolHOMM7","column":"MagicSchool_id"},{"table":"MagicSchoolHOMM8","column":"MagicSchool_id"},{"table":"SkillHOMM4","column":"MagicSchool_id"},{"table":"SkillHOMM7","column":"MagicSchool_id"},{"table":"SkillHOMM8","column":"MagicSchool_id"},{"table":"SpellMagicSchool","column":"MagicSchool_id"}]},"MagicSchoolHOMM4":{"pk":"MagicSchool_id","type":"BIGINT","direct":false,"owner":{"column":"MagicSchool_id","table":"MagicSchool","target":"MagicSchool_id"},"expected":"HOMM4","refs":[{"column":"MagicSchool_id","table":"MagicSchool","target":"MagicSchool_id"},{"column":"OpposingMagicSchool_id","table":"MagicSchool","target":"MagicSchool_id"}],"incoming":[]},"MagicSchoolHOMM5":{"pk":"MagicSchool_id","type":"BIGINT","direct":false,"owner":{"column":"MagicSchool_id","table":"MagicSchool","target":"MagicSchool_id"},"expected":"HOMM5","refs":[{"column":"MagicSchool_id","table":"MagicSchool","target":"MagicSchool_id"},{"column":"SchoolSkill_id","table":"Skill","target":"Skill_id"}],"incoming":[]},"MagicSchoolHOMM6":{"pk":"MagicSchool_id","type":"BIGINT","direct":false,"owner":{"column":"MagicSchool_id","table":"MagicSchool","target":"MagicSchool_id"},"expected":"HOMM6","refs":[{"column":"MagicSchool_id","table":"MagicSchool","target":"MagicSchool_id"}],"incoming":[]},"MagicSchoolHOMM7":{"pk":"MagicSchool_id","type":"BIGINT","direct":false,"owner":{"column":"MagicSchool_id","table":"MagicSchool","target":"MagicSchool_id"},"expected":"HOMM7","refs":[{"column":"MagicSchool_id","table":"MagicSchool","target":"MagicSchool_id"}],"incoming":[]},"MagicSchoolHOMM8":{"pk":"MagicSchool_id","type":"BIGINT","direct":false,"owner":{"column":"MagicSchool_id","table":"MagicSchool","target":"MagicSchool_id"},"expected":"HOMM8","refs":[{"column":"MagicSchool_id","table":"MagicSchool","target":"MagicSchool_id"},{"column":"SchoolSkill_id","table":"Skill","target":"Skill_id"}],"incoming":[]},"Map":{"pk":"Map_id","type":"BIGINT","direct":true,"owner":null,"expected":null,"refs":[{"column":"Game_id","table":"Game","target":"Game_id"},{"column":"IntroducedInExpansion_id","table":"Expansion","target":"Expansion_id"},{"column":"MapFileMediaAsset_id","table":"MediaAsset","target":"MediaAsset_id"}],"incoming":[{"table":"LoreFull","column":"Map_id"},{"table":"MapHOMM1","column":"Map_id"},{"table":"MapHOMM2","column":"Map_id"},{"table":"MapHOMM3","column":"Map_id"},{"table":"MapHOMM4","column":"Map_id"},{"table":"MapHOMM5","column":"Map_id"},{"table":"MapHOMM6","column":"Map_id"},{"table":"MapHOMM7","column":"Map_id"},{"table":"MapHOMM8","column":"Map_id"},{"table":"MapObjectPresence","column":"Map_id"},{"table":"MapTerrain","column":"Map_id"},{"table":"Scenario","column":"Map_id"}]},"MapHOMM1":{"pk":"Map_id","type":"BIGINT","direct":false,"owner":{"column":"Map_id","table":"Map","target":"Map_id"},"expected":"HOMM1","refs":[{"column":"Map_id","table":"Map","target":"Map_id"}],"incoming":[]},"MapHOMM2":{"pk":"Map_id","type":"BIGINT","direct":false,"owner":{"column":"Map_id","table":"Map","target":"Map_id"},"expected":"HOMM2","refs":[{"column":"Map_id","table":"Map","target":"Map_id"}],"incoming":[]},"MapHOMM3":{"pk":"Map_id","type":"BIGINT","direct":false,"owner":{"column":"Map_id","table":"Map","target":"Map_id"},"expected":"HOMM3","refs":[{"column":"Map_id","table":"Map","target":"Map_id"}],"incoming":[]},"MapHOMM4":{"pk":"Map_id","type":"BIGINT","direct":false,"owner":{"column":"Map_id","table":"Map","target":"Map_id"},"expected":"HOMM4","refs":[{"column":"Map_id","table":"Map","target":"Map_id"}],"incoming":[]},"MapHOMM5":{"pk":"Map_id","type":"BIGINT","direct":false,"owner":{"column":"Map_id","table":"Map","target":"Map_id"},"expected":"HOMM5","refs":[{"column":"Map_id","table":"Map","target":"Map_id"}],"incoming":[]},"MapHOMM6":{"pk":"Map_id","type":"BIGINT","direct":false,"owner":{"column":"Map_id","table":"Map","target":"Map_id"},"expected":"HOMM6","refs":[{"column":"Map_id","table":"Map","target":"Map_id"}],"incoming":[]},"MapHOMM7":{"pk":"Map_id","type":"BIGINT","direct":false,"owner":{"column":"Map_id","table":"Map","target":"Map_id"},"expected":"HOMM7","refs":[{"column":"Map_id","table":"Map","target":"Map_id"}],"incoming":[]},"MapHOMM8":{"pk":"Map_id","type":"BIGINT","direct":false,"owner":{"column":"Map_id","table":"Map","target":"Map_id"},"expected":"HOMM8","refs":[{"column":"Map_id","table":"Map","target":"Map_id"}],"incoming":[]},"MapObjectPresence":{"pk":"MapObjectPresence_cid","type":"TEXT","direct":true,"owner":null,"expected":null,"refs":[{"column":"AdventureObject_id","table":"AdventureObject","target":"AdventureObject_id"},{"column":"Game_id","table":"Game","target":"Game_id"},{"column":"Map_id","table":"Map","target":"Map_id"}],"incoming":[]},"MapTerrain":{"pk":"MapTerrain_cid","type":"TEXT","direct":true,"owner":null,"expected":null,"refs":[{"column":"Game_id","table":"Game","target":"Game_id"},{"column":"Map_id","table":"Map","target":"Map_id"},{"column":"Terrain_id","table":"Terrain","target":"Terrain_id"}],"incoming":[]},"MediaAsset":{"pk":"MediaAsset_id","type":"BIGINT","direct":true,"owner":null,"expected":null,"refs":[{"column":"Expansion_id","table":"Expansion","target":"Expansion_id"},{"column":"Game_id","table":"Game","target":"Game_id"}],"incoming":[{"table":"Ability","column":"MediaAsset_id"},{"table":"AdventureObject","column":"MediaAsset_id"},{"table":"Artifact","column":"MediaAsset_id"},{"table":"Building","column":"MediaAsset_id"},{"table":"Campaign","column":"MediaAsset_id"},{"table":"Creature","column":"MediaAsset_id"},{"table":"Faction","column":"MediaAsset_id"},{"table":"FactionHOMM8","column":"LawScreenMediaAsset_id"},{"table":"FactionLaw","column":"MediaAsset_id"},{"table":"GameResource","column":"MediaAsset_id"},{"table":"Hero","column":"PortraitMediaAsset_id"},{"table":"HeroClass","column":"MediaAsset_id"},{"table":"Lore","column":"MediaAsset_id"},{"table":"MagicSchool","column":"MediaAsset_id"},{"table":"Map","column":"MapFileMediaAsset_id"},{"table":"Screenshot","column":"MediaAsset_id"},{"table":"Skill","column":"MediaAsset_id"},{"table":"Soundtrack","column":"MediaAsset_id"},{"table":"Spell","column":"MediaAsset_id"},{"table":"Terrain","column":"MediaAsset_id"},{"table":"TownScreen","column":"BackgroundMediaAsset_id"},{"table":"Video","column":"MediaAsset_id"}]},"Patch":{"pk":"Patch_id","type":"BIGINT","direct":true,"owner":null,"expected":null,"refs":[{"column":"Expansion_id","table":"Expansion","target":"Expansion_id"},{"column":"Game_id","table":"Game","target":"Game_id"}],"incoming":[{"table":"GameHOMM8","column":"CurrentPatch_id"}]},"Resource":{"pk":"Resource_id","type":"BIGINT","direct":false,"owner":null,"expected":null,"refs":[],"incoming":[{"table":"ArtifactResourceCost","column":"Resource_id"},{"table":"AstrologyHOMM8","column":"AstrologyPointResource_id"},{"table":"AstrologyHOMM8","column":"InsightResource_id"},{"table":"BuildingResourceCost","column":"Resource_id"},{"table":"CreatureResourceCost","column":"Resource_id"},{"table":"FactionHOMM8","column":"SignatureResource_id"},{"table":"GameResource","column":"Resource_id"},{"table":"ResourceHOMM1To5","column":"Resource_id"},{"table":"ResourceHOMM8","column":"Resource_id"},{"table":"SpellResourceCostHOMM5","column":"Resource_id"}]},"ResourceHOMM1To5":{"pk":"Resource_id","type":"BIGINT","direct":false,"owner":{"column":"Resource_id","table":"Resource","target":"Resource_id"},"expected":null,"refs":[{"column":"Resource_id","table":"Resource","target":"Resource_id"}],"incoming":[]},"ResourceHOMM8":{"pk":"Resource_id","type":"BIGINT","direct":false,"owner":{"column":"Resource_id","table":"Resource","target":"Resource_id"},"expected":"HOMM8","refs":[{"column":"Resource_id","table":"Resource","target":"Resource_id"}],"incoming":[]},"Scenario":{"pk":"Scenario_id","type":"BIGINT","direct":true,"owner":null,"expected":null,"refs":[{"column":"Game_id","table":"Game","target":"Game_id"},{"column":"IntroducedInExpansion_id","table":"Expansion","target":"Expansion_id"},{"column":"Map_id","table":"Map","target":"Map_id"}],"incoming":[{"table":"CampaignHero","column":"StartingScenario_id"},{"table":"CampaignScenario","column":"Scenario_id"},{"table":"LoreFull","column":"Scenario_id"},{"table":"ScenarioConnection","column":"FromScenario_id"},{"table":"ScenarioConnection","column":"ToScenario_id"},{"table":"ScenarioHOMM1","column":"Scenario_id"},{"table":"ScenarioHOMM2","column":"Scenario_id"},{"table":"ScenarioHOMM3","column":"Scenario_id"},{"table":"ScenarioHOMM4","column":"Scenario_id"},{"table":"ScenarioHOMM5","column":"Scenario_id"},{"table":"ScenarioHOMM6","column":"Scenario_id"},{"table":"ScenarioHOMM7","column":"Scenario_id"},{"table":"ScenarioHOMM8","column":"Scenario_id"},{"table":"Video","column":"Scenario_id"}]},"ScenarioConnection":{"pk":"ScenarioConnection_cid","type":"TEXT","direct":true,"owner":null,"expected":null,"refs":[{"column":"FromScenario_id","table":"Scenario","target":"Scenario_id"},{"column":"Game_id","table":"Game","target":"Game_id"},{"column":"ToScenario_id","table":"Scenario","target":"Scenario_id"}],"incoming":[]},"ScenarioHOMM1":{"pk":"Scenario_id","type":"BIGINT","direct":false,"owner":{"column":"Scenario_id","table":"Scenario","target":"Scenario_id"},"expected":"HOMM1","refs":[{"column":"Scenario_id","table":"Scenario","target":"Scenario_id"}],"incoming":[]},"ScenarioHOMM2":{"pk":"Scenario_id","type":"BIGINT","direct":false,"owner":{"column":"Scenario_id","table":"Scenario","target":"Scenario_id"},"expected":"HOMM2","refs":[{"column":"Scenario_id","table":"Scenario","target":"Scenario_id"}],"incoming":[]},"ScenarioHOMM3":{"pk":"Scenario_id","type":"BIGINT","direct":false,"owner":{"column":"Scenario_id","table":"Scenario","target":"Scenario_id"},"expected":"HOMM3","refs":[{"column":"Scenario_id","table":"Scenario","target":"Scenario_id"}],"incoming":[]},"ScenarioHOMM4":{"pk":"Scenario_id","type":"BIGINT","direct":false,"owner":{"column":"Scenario_id","table":"Scenario","target":"Scenario_id"},"expected":"HOMM4","refs":[{"column":"Scenario_id","table":"Scenario","target":"Scenario_id"}],"incoming":[]},"ScenarioHOMM5":{"pk":"Scenario_id","type":"BIGINT","direct":false,"owner":{"column":"Scenario_id","table":"Scenario","target":"Scenario_id"},"expected":"HOMM5","refs":[{"column":"Scenario_id","table":"Scenario","target":"Scenario_id"}],"incoming":[]},"ScenarioHOMM6":{"pk":"Scenario_id","type":"BIGINT","direct":false,"owner":{"column":"Scenario_id","table":"Scenario","target":"Scenario_id"},"expected":"HOMM6","refs":[{"column":"Scenario_id","table":"Scenario","target":"Scenario_id"}],"incoming":[]},"ScenarioHOMM7":{"pk":"Scenario_id","type":"BIGINT","direct":false,"owner":{"column":"Scenario_id","table":"Scenario","target":"Scenario_id"},"expected":"HOMM7","refs":[{"column":"Scenario_id","table":"Scenario","target":"Scenario_id"}],"incoming":[]},"ScenarioHOMM8":{"pk":"Scenario_id","type":"BIGINT","direct":false,"owner":{"column":"Scenario_id","table":"Scenario","target":"Scenario_id"},"expected":"HOMM8","refs":[{"column":"Scenario_id","table":"Scenario","target":"Scenario_id"}],"incoming":[]},"Screenshot":{"pk":"Screenshot_id","type":"BIGINT","direct":true,"owner":null,"expected":null,"refs":[{"column":"Expansion_id","table":"Expansion","target":"Expansion_id"},{"column":"Game_id","table":"Game","target":"Game_id"},{"column":"MediaAsset_id","table":"MediaAsset","target":"MediaAsset_id"}],"incoming":[]},"Skill":{"pk":"Skill_id","type":"BIGINT","direct":true,"owner":null,"expected":null,"refs":[{"column":"Game_id","table":"Game","target":"Game_id"},{"column":"IntroducedInExpansion_id","table":"Expansion","target":"Expansion_id"},{"column":"MediaAsset_id","table":"MediaAsset","target":"MediaAsset_id"}],"incoming":[{"table":"AbilityHOMM8","column":"ParentSkill_id"},{"table":"FactionHOMM5","column":"RacialSkill_id"},{"table":"FactionHOMM7","column":"RacialSkill_id"},{"table":"FactionHOMM8","column":"FactionSkill_id"},{"table":"HeroClassAbility","column":"Skill_id"},{"table":"HeroClassHOMM5","column":"RacialSkill_id"},{"table":"HeroClassPrimarySkillHOMM4","column":"Skill_id"},{"table":"HeroHOMM7","column":"StartingSkill_id"},{"table":"HeroHOMM8","column":"StartingSkill_id"},{"table":"HeroSkill","column":"Skill_id"},{"table":"MagicSchoolHOMM5","column":"SchoolSkill_id"},{"table":"MagicSchoolHOMM8","column":"SchoolSkill_id"},{"table":"SkillHOMM2","column":"Skill_id"},{"table":"SkillHOMM3","column":"Skill_id"},{"table":"SkillHOMM4","column":"ParentPrimarySkill_id"},{"table":"SkillHOMM4","column":"Skill_id"},{"table":"SkillHOMM5","column":"Skill_id"},{"table":"SkillHOMM7","column":"Skill_id"},{"table":"SkillHOMM8","column":"Skill_id"}]},"SkillHOMM2":{"pk":"Skill_id","type":"BIGINT","direct":false,"owner":{"column":"Skill_id","table":"Skill","target":"Skill_id"},"expected":"HOMM2","refs":[{"column":"Skill_id","table":"Skill","target":"Skill_id"}],"incoming":[]},"SkillHOMM3":{"pk":"Skill_id","type":"BIGINT","direct":false,"owner":{"column":"Skill_id","table":"Skill","target":"Skill_id"},"expected":"HOMM3","refs":[{"column":"Skill_id","table":"Skill","target":"Skill_id"}],"incoming":[]},"SkillHOMM4":{"pk":"Skill_id","type":"BIGINT","direct":false,"owner":{"column":"Skill_id","table":"Skill","target":"Skill_id"},"expected":"HOMM4","refs":[{"column":"MagicSchool_id","table":"MagicSchool","target":"MagicSchool_id"},{"column":"ParentPrimarySkill_id","table":"Skill","target":"Skill_id"},{"column":"Skill_id","table":"Skill","target":"Skill_id"}],"incoming":[]},"SkillHOMM5":{"pk":"Skill_id","type":"BIGINT","direct":false,"owner":{"column":"Skill_id","table":"Skill","target":"Skill_id"},"expected":"HOMM5","refs":[{"column":"Skill_id","table":"Skill","target":"Skill_id"}],"incoming":[]},"SkillHOMM7":{"pk":"Skill_id","type":"BIGINT","direct":false,"owner":{"column":"Skill_id","table":"Skill","target":"Skill_id"},"expected":"HOMM7","refs":[{"column":"MagicSchool_id","table":"MagicSchool","target":"MagicSchool_id"},{"column":"Skill_id","table":"Skill","target":"Skill_id"}],"incoming":[]},"SkillHOMM8":{"pk":"Skill_id","type":"BIGINT","direct":false,"owner":{"column":"Skill_id","table":"Skill","target":"Skill_id"},"expected":"HOMM8","refs":[{"column":"MagicSchool_id","table":"MagicSchool","target":"MagicSchool_id"},{"column":"Skill_id","table":"Skill","target":"Skill_id"}],"incoming":[]},"Soundtrack":{"pk":"Soundtrack_id","type":"BIGINT","direct":true,"owner":null,"expected":null,"refs":[{"column":"Campaign_id","table":"Campaign","target":"Campaign_id"},{"column":"Faction_id","table":"Faction","target":"Faction_id"},{"column":"Game_id","table":"Game","target":"Game_id"},{"column":"MediaAsset_id","table":"MediaAsset","target":"MediaAsset_id"},{"column":"Terrain_id","table":"Terrain","target":"Terrain_id"}],"incoming":[{"table":"SoundtrackHOMM1","column":"Soundtrack_id"},{"table":"SoundtrackHOMM2","column":"Soundtrack_id"},{"table":"SoundtrackHOMM3","column":"Soundtrack_id"},{"table":"SoundtrackHOMM4","column":"Soundtrack_id"},{"table":"SoundtrackHOMM5","column":"Soundtrack_id"},{"table":"SoundtrackHOMM6","column":"Soundtrack_id"},{"table":"SoundtrackHOMM7","column":"Soundtrack_id"}]},"SoundtrackHOMM1":{"pk":"Soundtrack_id","type":"BIGINT","direct":false,"owner":{"column":"Soundtrack_id","table":"Soundtrack","target":"Soundtrack_id"},"expected":"HOMM1","refs":[{"column":"Soundtrack_id","table":"Soundtrack","target":"Soundtrack_id"}],"incoming":[]},"SoundtrackHOMM2":{"pk":"Soundtrack_id","type":"BIGINT","direct":false,"owner":{"column":"Soundtrack_id","table":"Soundtrack","target":"Soundtrack_id"},"expected":"HOMM2","refs":[{"column":"Soundtrack_id","table":"Soundtrack","target":"Soundtrack_id"}],"incoming":[]},"SoundtrackHOMM3":{"pk":"Soundtrack_id","type":"BIGINT","direct":false,"owner":{"column":"Soundtrack_id","table":"Soundtrack","target":"Soundtrack_id"},"expected":"HOMM3","refs":[{"column":"Soundtrack_id","table":"Soundtrack","target":"Soundtrack_id"}],"incoming":[]},"SoundtrackHOMM4":{"pk":"Soundtrack_id","type":"BIGINT","direct":false,"owner":{"column":"Soundtrack_id","table":"Soundtrack","target":"Soundtrack_id"},"expected":"HOMM4","refs":[{"column":"Soundtrack_id","table":"Soundtrack","target":"Soundtrack_id"}],"incoming":[]},"SoundtrackHOMM5":{"pk":"Soundtrack_id","type":"BIGINT","direct":false,"owner":{"column":"Soundtrack_id","table":"Soundtrack","target":"Soundtrack_id"},"expected":"HOMM5","refs":[{"column":"Soundtrack_id","table":"Soundtrack","target":"Soundtrack_id"}],"incoming":[]},"SoundtrackHOMM6":{"pk":"Soundtrack_id","type":"BIGINT","direct":false,"owner":{"column":"Soundtrack_id","table":"Soundtrack","target":"Soundtrack_id"},"expected":"HOMM6","refs":[{"column":"Soundtrack_id","table":"Soundtrack","target":"Soundtrack_id"}],"incoming":[]},"SoundtrackHOMM7":{"pk":"Soundtrack_id","type":"BIGINT","direct":false,"owner":{"column":"Soundtrack_id","table":"Soundtrack","target":"Soundtrack_id"},"expected":"HOMM7","refs":[{"column":"Soundtrack_id","table":"Soundtrack","target":"Soundtrack_id"}],"incoming":[]},"Spell":{"pk":"Spell_id","type":"BIGINT","direct":true,"owner":null,"expected":null,"refs":[{"column":"Game_id","table":"Game","target":"Game_id"},{"column":"IntroducedInExpansion_id","table":"Expansion","target":"Expansion_id"},{"column":"MediaAsset_id","table":"MediaAsset","target":"MediaAsset_id"}],"incoming":[{"table":"ArtifactHOMM2","column":"GrantedSpell_id"},{"table":"ArtifactHOMM6","column":"GrantedSpell_id"},{"table":"CreatureSpell","column":"Spell_id"},{"table":"FactionSpell","column":"Spell_id"},{"table":"HeroClassHOMM2","column":"StartingSpell_id"},{"table":"HeroHOMM3","column":"StartingSpell_id"},{"table":"HeroHOMM5","column":"StartingSpell_id"},{"table":"HeroHOMM8","column":"StartingSpell1_id"},{"table":"HeroHOMM8","column":"StartingSpell2_id"},{"table":"SpellHOMM1","column":"Spell_id"},{"table":"SpellHOMM2","column":"Spell_id"},{"table":"SpellHOMM3","column":"Spell_id"},{"table":"SpellHOMM4","column":"Spell_id"},{"table":"SpellHOMM5","column":"Spell_id"},{"table":"SpellHOMM6","column":"Spell_id"},{"table":"SpellHOMM7","column":"Spell_id"},{"table":"SpellHOMM8","column":"Spell_id"},{"table":"SpellMagicSchool","column":"Spell_id"},{"table":"SpellResourceCostHOMM5","column":"Spell_id"}]},"SpellHOMM1":{"pk":"Spell_id","type":"BIGINT","direct":false,"owner":{"column":"Spell_id","table":"Spell","target":"Spell_id"},"expected":"HOMM1","refs":[{"column":"Spell_id","table":"Spell","target":"Spell_id"}],"incoming":[]},"SpellHOMM2":{"pk":"Spell_id","type":"BIGINT","direct":false,"owner":{"column":"Spell_id","table":"Spell","target":"Spell_id"},"expected":"HOMM2","refs":[{"column":"Spell_id","table":"Spell","target":"Spell_id"}],"incoming":[]},"SpellHOMM3":{"pk":"Spell_id","type":"BIGINT","direct":false,"owner":{"column":"Spell_id","table":"Spell","target":"Spell_id"},"expected":"HOMM3","refs":[{"column":"Spell_id","table":"Spell","target":"Spell_id"}],"incoming":[]},"SpellHOMM4":{"pk":"Spell_id","type":"BIGINT","direct":false,"owner":{"column":"Spell_id","table":"Spell","target":"Spell_id"},"expected":"HOMM4","refs":[{"column":"Spell_id","table":"Spell","target":"Spell_id"}],"incoming":[]},"SpellHOMM5":{"pk":"Spell_id","type":"BIGINT","direct":false,"owner":{"column":"Spell_id","table":"Spell","target":"Spell_id"},"expected":"HOMM5","refs":[{"column":"Spell_id","table":"Spell","target":"Spell_id"}],"incoming":[]},"SpellHOMM6":{"pk":"Spell_id","type":"BIGINT","direct":false,"owner":{"column":"Spell_id","table":"Spell","target":"Spell_id"},"expected":"HOMM6","refs":[{"column":"Ability_id","table":"Ability","target":"Ability_id"},{"column":"Spell_id","table":"Spell","target":"Spell_id"}],"incoming":[]},"SpellHOMM7":{"pk":"Spell_id","type":"BIGINT","direct":false,"owner":{"column":"Spell_id","table":"Spell","target":"Spell_id"},"expected":"HOMM7","refs":[{"column":"Spell_id","table":"Spell","target":"Spell_id"}],"incoming":[]},"SpellHOMM8":{"pk":"Spell_id","type":"BIGINT","direct":false,"owner":{"column":"Spell_id","table":"Spell","target":"Spell_id"},"expected":"HOMM8","refs":[{"column":"Spell_id","table":"Spell","target":"Spell_id"}],"incoming":[]},"SpellMagicSchool":{"pk":"SpellMagicSchool_cid","type":"TEXT","direct":true,"owner":null,"expected":null,"refs":[{"column":"Game_id","table":"Game","target":"Game_id"},{"column":"MagicSchool_id","table":"MagicSchool","target":"MagicSchool_id"},{"column":"Spell_id","table":"Spell","target":"Spell_id"}],"incoming":[]},"SpellResourceCostHOMM5":{"pk":"SpellResourceCostHOMM5_cid","type":"TEXT","direct":true,"owner":null,"expected":"HOMM5","refs":[{"column":"Game_id","table":"Game","target":"Game_id"},{"column":"Resource_id","table":"Resource","target":"Resource_id"},{"column":"Spell_id","table":"Spell","target":"Spell_id"}],"incoming":[]},"Terrain":{"pk":"Terrain_id","type":"BIGINT","direct":true,"owner":null,"expected":null,"refs":[{"column":"Game_id","table":"Game","target":"Game_id"},{"column":"IntroducedInExpansion_id","table":"Expansion","target":"Expansion_id"},{"column":"MediaAsset_id","table":"MediaAsset","target":"MediaAsset_id"}],"incoming":[{"table":"FactionHOMM3","column":"NativeTerrain_id"},{"table":"FactionHOMM4","column":"NativeTerrain_id"},{"table":"FactionHOMM8","column":"NativeTerrain_id"},{"table":"FactionNativeTerrainHOMM5","column":"Terrain_id"},{"table":"MapTerrain","column":"Terrain_id"},{"table":"Soundtrack","column":"Terrain_id"},{"table":"TerrainHOMM1","column":"Terrain_id"},{"table":"TerrainHOMM2","column":"Terrain_id"},{"table":"TerrainHOMM3","column":"Terrain_id"},{"table":"TerrainHOMM4","column":"Terrain_id"},{"table":"TerrainHOMM5","column":"Terrain_id"},{"table":"TerrainHOMM6","column":"Terrain_id"},{"table":"TerrainHOMM7","column":"Terrain_id"}]},"TerrainHOMM1":{"pk":"Terrain_id","type":"BIGINT","direct":false,"owner":{"column":"Terrain_id","table":"Terrain","target":"Terrain_id"},"expected":"HOMM1","refs":[{"column":"Terrain_id","table":"Terrain","target":"Terrain_id"}],"incoming":[]},"TerrainHOMM2":{"pk":"Terrain_id","type":"BIGINT","direct":false,"owner":{"column":"Terrain_id","table":"Terrain","target":"Terrain_id"},"expected":"HOMM2","refs":[{"column":"Terrain_id","table":"Terrain","target":"Terrain_id"}],"incoming":[]},"TerrainHOMM3":{"pk":"Terrain_id","type":"BIGINT","direct":false,"owner":{"column":"Terrain_id","table":"Terrain","target":"Terrain_id"},"expected":"HOMM3","refs":[{"column":"Terrain_id","table":"Terrain","target":"Terrain_id"}],"incoming":[]},"TerrainHOMM4":{"pk":"Terrain_id","type":"BIGINT","direct":false,"owner":{"column":"Terrain_id","table":"Terrain","target":"Terrain_id"},"expected":"HOMM4","refs":[{"column":"Terrain_id","table":"Terrain","target":"Terrain_id"}],"incoming":[]},"TerrainHOMM5":{"pk":"Terrain_id","type":"BIGINT","direct":false,"owner":{"column":"Terrain_id","table":"Terrain","target":"Terrain_id"},"expected":"HOMM5","refs":[{"column":"Terrain_id","table":"Terrain","target":"Terrain_id"}],"incoming":[]},"TerrainHOMM6":{"pk":"Terrain_id","type":"BIGINT","direct":false,"owner":{"column":"Terrain_id","table":"Terrain","target":"Terrain_id"},"expected":"HOMM6","refs":[{"column":"Terrain_id","table":"Terrain","target":"Terrain_id"}],"incoming":[]},"TerrainHOMM7":{"pk":"Terrain_id","type":"BIGINT","direct":false,"owner":{"column":"Terrain_id","table":"Terrain","target":"Terrain_id"},"expected":"HOMM7","refs":[{"column":"Terrain_id","table":"Terrain","target":"Terrain_id"}],"incoming":[]},"TownScreen":{"pk":"TownScreen_id","type":"BIGINT","direct":true,"owner":null,"expected":null,"refs":[{"column":"BackgroundMediaAsset_id","table":"MediaAsset","target":"MediaAsset_id"},{"column":"Faction_id","table":"Faction","target":"Faction_id"},{"column":"Game_id","table":"Game","target":"Game_id"}],"incoming":[{"table":"TownScreenBuilding","column":"TownScreen_id"}]},"TownScreenBuilding":{"pk":"TownScreenBuilding_cid","type":"TEXT","direct":true,"owner":null,"expected":null,"refs":[{"column":"Building_id","table":"Building","target":"Building_id"},{"column":"Game_id","table":"Game","target":"Game_id"},{"column":"TownScreen_id","table":"TownScreen","target":"TownScreen_id"}],"incoming":[]},"Video":{"pk":"Video_id","type":"BIGINT","direct":true,"owner":null,"expected":null,"refs":[{"column":"Campaign_id","table":"Campaign","target":"Campaign_id"},{"column":"Game_id","table":"Game","target":"Game_id"},{"column":"MediaAsset_id","table":"MediaAsset","target":"MediaAsset_id"},{"column":"Scenario_id","table":"Scenario","target":"Scenario_id"}],"incoming":[]}}'::jsonb -> table_name
$function$;

CREATE FUNCTION "heroes_watch"."_scope_row"(table_name text, row_key text) RETURNS jsonb
LANGUAGE plpgsql VOLATILE AS $function$
DECLARE m jsonb; result jsonb;
BEGIN
  m := "heroes_watch"."_scope_metadata"(table_name);
  IF m IS NULL THEN RAISE EXCEPTION 'Unknown integrity table: %', table_name; END IF;
  EXECUTE format('SELECT to_jsonb(r) FROM %I.%I r WHERE %I = $1::%s FOR SHARE',
    'heroes_watch', table_name, m->>'pk', m->>'type') INTO result USING row_key;
  RETURN result;
END
$function$;

CREATE FUNCTION "heroes_watch"."_scope_owner"(table_name text, row_key text) RETURNS bigint
LANGUAGE plpgsql VOLATILE AS $function$
DECLARE m jsonb; r jsonb; result bigint;
BEGIN
  IF row_key IS NULL THEN RETURN NULL; END IF;
  m := "heroes_watch"."_scope_metadata"(table_name);
  r := "heroes_watch"."_scope_row"(table_name, row_key);
  IF r IS NULL THEN RETURN NULL; END IF;
  IF (m->>'direct')::boolean THEN RETURN (r->>'Game_id')::bigint; END IF;
  IF m->'owner' <> 'null'::jsonb AND r->>(m->'owner'->>'column') IS NOT NULL THEN
    RETURN "heroes_watch"."_scope_owner"(m->'owner'->>'table', r->>(m->'owner'->>'column'));
  END IF;
  -- Artifact sets can have no introduction release; their title still scopes them.
  IF m->>'expected' IS NOT NULL THEN
    SELECT "Game_id" INTO result FROM "heroes_watch"."Game" WHERE "SeriesCode" = m->>'expected' FOR SHARE;
    RETURN result;
  END IF;
  RETURN NULL;
END
$function$;

CREATE FUNCTION "heroes_watch"."_check_scope_row"(table_name text, row_key text) RETURNS void
LANGUAGE plpgsql VOLATILE AS $function$
DECLARE m jsonb; r jsonb; reference jsonb; owned bigint; target_game bigint; series text;
BEGIN
  m := "heroes_watch"."_scope_metadata"(table_name);
  r := "heroes_watch"."_scope_row"(table_name, row_key);
  IF r IS NULL THEN RETURN; END IF; -- Row was removed later in this transaction.
  owned := "heroes_watch"."_scope_owner"(table_name, row_key);
  IF m->>'expected' IS NOT NULL THEN
    SELECT "SeriesCode" INTO series FROM "heroes_watch"."Game" WHERE "Game_id" = owned FOR SHARE;
    IF series IS DISTINCT FROM m->>'expected' THEN
      RAISE EXCEPTION 'Game ownership: %(%) requires %, found %', table_name, row_key, m->>'expected', series USING ERRCODE = '23514';
    END IF;
  END IF;
  IF owned IS NULL THEN RETURN; END IF; -- Genuinely global Resource / MediaAsset.
  FOR reference IN SELECT value FROM jsonb_array_elements(m->'refs') LOOP
    IF r->>(reference->>'column') IS NULL THEN CONTINUE; END IF;
    target_game := "heroes_watch"."_scope_owner"(reference->>'table', r->>(reference->>'column'));
    IF target_game IS NOT NULL AND target_game <> owned THEN
      RAISE EXCEPTION 'Game ownership: %(%) field % belongs to game %, expected %', table_name, row_key, reference->>'column', target_game, owned USING ERRCODE = '23514';
    END IF;
  END LOOP;
END
$function$;

CREATE FUNCTION "heroes_watch"."_check_scope_descendants"(table_name text, row_key text, visited text[] DEFAULT ARRAY[]::text[]) RETURNS void
LANGUAGE plpgsql VOLATILE AS $function$
DECLARE m jsonb; incoming jsonb; child_meta jsonb; child_key text; marker text;
BEGIN
  marker := table_name || ':' || row_key;
  IF marker = ANY(visited) THEN RETURN; END IF;
  visited := array_append(visited, marker);
  m := "heroes_watch"."_scope_metadata"(table_name);
  PERFORM "heroes_watch"."_check_scope_row"(table_name, row_key);
  FOR incoming IN SELECT value FROM jsonb_array_elements(m->'incoming') LOOP
    child_meta := "heroes_watch"."_scope_metadata"(incoming->>'table');
    FOR child_key IN EXECUTE format('SELECT %I::text FROM %I.%I WHERE %I = $1::%s FOR SHARE',
      child_meta->>'pk', 'heroes_watch', incoming->>'table', incoming->>'column', m->>'type') USING row_key LOOP
      -- A referenced row may be affected without inheriting its owner's game.
      -- Traverse only ownership edges; check other direct dependants once.
      IF child_meta->'owner'->>'column' = incoming->>'column'
         OR ((child_meta->>'direct')::boolean AND incoming->>'column' = 'Game_id') THEN
        PERFORM "heroes_watch"."_check_scope_descendants"(incoming->>'table', child_key, visited);
      ELSE
        PERFORM "heroes_watch"."_check_scope_row"(incoming->>'table', child_key);
      END IF;
    END LOOP;
  END LOOP;
END
$function$;

CREATE FUNCTION "heroes_watch"."_game_scope_constraint"() RETURNS trigger
LANGUAGE plpgsql VOLATILE AS $function$
DECLARE m jsonb; r jsonb; old_r jsonb; row_key text; owner_column text;
BEGIN
  m := "heroes_watch"."_scope_metadata"(TG_TABLE_NAME);
  r := to_jsonb(NEW);
  row_key := r->>(m->>'pk');
  PERFORM "heroes_watch"."_check_scope_row"(TG_TABLE_NAME, row_key);
  IF TG_OP = 'UPDATE' THEN
    old_r := to_jsonb(OLD);
    owner_column := CASE WHEN (m->>'direct')::boolean THEN 'Game_id' ELSE m->'owner'->>'column' END;
    IF r->(m->>'pk') IS DISTINCT FROM old_r->(m->>'pk')
       OR (owner_column IS NOT NULL AND r->owner_column IS DISTINCT FROM old_r->owner_column)
       OR (TG_TABLE_NAME = 'Game' AND r->'SeriesCode' IS DISTINCT FROM old_r->'SeriesCode') THEN
      IF current_setting('transaction_isolation') = 'repeatable read' THEN
        RAISE EXCEPTION 'Ownership-changing updates on % require READ COMMITTED or SERIALIZABLE', TG_TABLE_NAME
          USING ERRCODE = '0A000',
            HINT = 'Retry the whole transaction using READ COMMITTED or SERIALIZABLE. REPEATABLE READ can hide a recently committed dependent row.';
      END IF;
      PERFORM "heroes_watch"."_check_scope_descendants"(TG_TABLE_NAME, row_key);
    END IF;
  END IF;
  RETURN NULL;
END
$function$;


CREATE CONSTRAINT TRIGGER "ct_game_scope__Ability"
AFTER INSERT OR UPDATE ON "heroes_watch"."Ability"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__AbilityHOMM1"
AFTER INSERT OR UPDATE ON "heroes_watch"."AbilityHOMM1"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__AbilityHOMM2"
AFTER INSERT OR UPDATE ON "heroes_watch"."AbilityHOMM2"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__AbilityHOMM3"
AFTER INSERT OR UPDATE ON "heroes_watch"."AbilityHOMM3"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__AbilityHOMM4"
AFTER INSERT OR UPDATE ON "heroes_watch"."AbilityHOMM4"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__AbilityHOMM5"
AFTER INSERT OR UPDATE ON "heroes_watch"."AbilityHOMM5"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__AbilityHOMM6"
AFTER INSERT OR UPDATE ON "heroes_watch"."AbilityHOMM6"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__AbilityHOMM7"
AFTER INSERT OR UPDATE ON "heroes_watch"."AbilityHOMM7"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__AbilityHOMM8"
AFTER INSERT OR UPDATE ON "heroes_watch"."AbilityHOMM8"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__AdventureObject"
AFTER INSERT OR UPDATE ON "heroes_watch"."AdventureObject"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__AdventureObjectCreature"
AFTER INSERT OR UPDATE ON "heroes_watch"."AdventureObjectCreature"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__AdventureObjectFaction"
AFTER INSERT OR UPDATE ON "heroes_watch"."AdventureObjectFaction"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__AdventureObjectHOMM1"
AFTER INSERT OR UPDATE ON "heroes_watch"."AdventureObjectHOMM1"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__AdventureObjectHOMM2"
AFTER INSERT OR UPDATE ON "heroes_watch"."AdventureObjectHOMM2"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__AdventureObjectHOMM3"
AFTER INSERT OR UPDATE ON "heroes_watch"."AdventureObjectHOMM3"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__AdventureObjectHOMM4"
AFTER INSERT OR UPDATE ON "heroes_watch"."AdventureObjectHOMM4"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__AdventureObjectHOMM5"
AFTER INSERT OR UPDATE ON "heroes_watch"."AdventureObjectHOMM5"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__AdventureObjectHOMM6"
AFTER INSERT OR UPDATE ON "heroes_watch"."AdventureObjectHOMM6"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__AdventureObjectHOMM7"
AFTER INSERT OR UPDATE ON "heroes_watch"."AdventureObjectHOMM7"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__AdventureObjectHOMM8"
AFTER INSERT OR UPDATE ON "heroes_watch"."AdventureObjectHOMM8"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__Artifact"
AFTER INSERT OR UPDATE ON "heroes_watch"."Artifact"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__ArtifactComponent"
AFTER INSERT OR UPDATE ON "heroes_watch"."ArtifactComponent"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__ArtifactHOMM1"
AFTER INSERT OR UPDATE ON "heroes_watch"."ArtifactHOMM1"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__ArtifactHOMM2"
AFTER INSERT OR UPDATE ON "heroes_watch"."ArtifactHOMM2"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__ArtifactHOMM3"
AFTER INSERT OR UPDATE ON "heroes_watch"."ArtifactHOMM3"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__ArtifactHOMM4"
AFTER INSERT OR UPDATE ON "heroes_watch"."ArtifactHOMM4"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__ArtifactHOMM5"
AFTER INSERT OR UPDATE ON "heroes_watch"."ArtifactHOMM5"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__ArtifactHOMM6"
AFTER INSERT OR UPDATE ON "heroes_watch"."ArtifactHOMM6"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__ArtifactHOMM7"
AFTER INSERT OR UPDATE ON "heroes_watch"."ArtifactHOMM7"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__ArtifactHOMM8"
AFTER INSERT OR UPDATE ON "heroes_watch"."ArtifactHOMM8"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__ArtifactResourceCost"
AFTER INSERT OR UPDATE ON "heroes_watch"."ArtifactResourceCost"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__ArtifactSetBonusHOMM5"
AFTER INSERT OR UPDATE ON "heroes_watch"."ArtifactSetBonusHOMM5"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__ArtifactSetHOMM5"
AFTER INSERT OR UPDATE ON "heroes_watch"."ArtifactSetHOMM5"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__AstrologyHOMM8"
AFTER INSERT OR UPDATE ON "heroes_watch"."AstrologyHOMM8"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__Building"
AFTER INSERT OR UPDATE ON "heroes_watch"."Building"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__BuildingCreature"
AFTER INSERT OR UPDATE ON "heroes_watch"."BuildingCreature"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__BuildingHOMM1"
AFTER INSERT OR UPDATE ON "heroes_watch"."BuildingHOMM1"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__BuildingHOMM2"
AFTER INSERT OR UPDATE ON "heroes_watch"."BuildingHOMM2"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__BuildingHOMM3"
AFTER INSERT OR UPDATE ON "heroes_watch"."BuildingHOMM3"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__BuildingHOMM4"
AFTER INSERT OR UPDATE ON "heroes_watch"."BuildingHOMM4"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__BuildingHOMM5"
AFTER INSERT OR UPDATE ON "heroes_watch"."BuildingHOMM5"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__BuildingHOMM6"
AFTER INSERT OR UPDATE ON "heroes_watch"."BuildingHOMM6"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__BuildingHOMM7"
AFTER INSERT OR UPDATE ON "heroes_watch"."BuildingHOMM7"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__BuildingHOMM8"
AFTER INSERT OR UPDATE ON "heroes_watch"."BuildingHOMM8"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__BuildingRequirement"
AFTER INSERT OR UPDATE ON "heroes_watch"."BuildingRequirement"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__BuildingResourceCost"
AFTER INSERT OR UPDATE ON "heroes_watch"."BuildingResourceCost"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__BuildingUpgrade"
AFTER INSERT OR UPDATE ON "heroes_watch"."BuildingUpgrade"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__Campaign"
AFTER INSERT OR UPDATE ON "heroes_watch"."Campaign"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__CampaignHero"
AFTER INSERT OR UPDATE ON "heroes_watch"."CampaignHero"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__CampaignHOMM1"
AFTER INSERT OR UPDATE ON "heroes_watch"."CampaignHOMM1"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__CampaignHOMM2"
AFTER INSERT OR UPDATE ON "heroes_watch"."CampaignHOMM2"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__CampaignHOMM4"
AFTER INSERT OR UPDATE ON "heroes_watch"."CampaignHOMM4"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__CampaignHOMM8"
AFTER INSERT OR UPDATE ON "heroes_watch"."CampaignHOMM8"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__CampaignScenario"
AFTER INSERT OR UPDATE ON "heroes_watch"."CampaignScenario"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__Creature"
AFTER INSERT OR UPDATE ON "heroes_watch"."Creature"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__CreatureAbility"
AFTER INSERT OR UPDATE ON "heroes_watch"."CreatureAbility"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__CreatureHOMM1"
AFTER INSERT OR UPDATE ON "heroes_watch"."CreatureHOMM1"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__CreatureHOMM2"
AFTER INSERT OR UPDATE ON "heroes_watch"."CreatureHOMM2"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__CreatureHOMM3"
AFTER INSERT OR UPDATE ON "heroes_watch"."CreatureHOMM3"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__CreatureHOMM4"
AFTER INSERT OR UPDATE ON "heroes_watch"."CreatureHOMM4"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__CreatureHOMM5"
AFTER INSERT OR UPDATE ON "heroes_watch"."CreatureHOMM5"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__CreatureHOMM6"
AFTER INSERT OR UPDATE ON "heroes_watch"."CreatureHOMM6"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__CreatureHOMM7"
AFTER INSERT OR UPDATE ON "heroes_watch"."CreatureHOMM7"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__CreatureHOMM8"
AFTER INSERT OR UPDATE ON "heroes_watch"."CreatureHOMM8"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__CreatureResourceCost"
AFTER INSERT OR UPDATE ON "heroes_watch"."CreatureResourceCost"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__CreatureSpell"
AFTER INSERT OR UPDATE ON "heroes_watch"."CreatureSpell"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__CreatureUpgrade"
AFTER INSERT OR UPDATE ON "heroes_watch"."CreatureUpgrade"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__Expansion"
AFTER INSERT OR UPDATE ON "heroes_watch"."Expansion"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__Faction"
AFTER INSERT OR UPDATE ON "heroes_watch"."Faction"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__FactionHOMM1"
AFTER INSERT OR UPDATE ON "heroes_watch"."FactionHOMM1"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__FactionHOMM2"
AFTER INSERT OR UPDATE ON "heroes_watch"."FactionHOMM2"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__FactionHOMM3"
AFTER INSERT OR UPDATE ON "heroes_watch"."FactionHOMM3"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__FactionHOMM4"
AFTER INSERT OR UPDATE ON "heroes_watch"."FactionHOMM4"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__FactionHOMM5"
AFTER INSERT OR UPDATE ON "heroes_watch"."FactionHOMM5"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__FactionHOMM6"
AFTER INSERT OR UPDATE ON "heroes_watch"."FactionHOMM6"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__FactionHOMM7"
AFTER INSERT OR UPDATE ON "heroes_watch"."FactionHOMM7"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__FactionHOMM8"
AFTER INSERT OR UPDATE ON "heroes_watch"."FactionHOMM8"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__FactionLaw"
AFTER INSERT OR UPDATE ON "heroes_watch"."FactionLaw"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__FactionMagicSchoolHOMM5"
AFTER INSERT OR UPDATE ON "heroes_watch"."FactionMagicSchoolHOMM5"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__FactionNativeTerrainHOMM5"
AFTER INSERT OR UPDATE ON "heroes_watch"."FactionNativeTerrainHOMM5"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__FactionSpell"
AFTER INSERT OR UPDATE ON "heroes_watch"."FactionSpell"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__Game"
AFTER INSERT OR UPDATE ON "heroes_watch"."Game"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__GameHOMM8"
AFTER INSERT OR UPDATE ON "heroes_watch"."GameHOMM8"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__GameResource"
AFTER INSERT OR UPDATE ON "heroes_watch"."GameResource"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__Hero"
AFTER INSERT OR UPDATE ON "heroes_watch"."Hero"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__HeroClass"
AFTER INSERT OR UPDATE ON "heroes_watch"."HeroClass"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__HeroClassAbility"
AFTER INSERT OR UPDATE ON "heroes_watch"."HeroClassAbility"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__HeroClassAbilityRequirementGroup"
AFTER INSERT OR UPDATE ON "heroes_watch"."HeroClassAbilityRequirementGroup"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__HeroClassHOMM1"
AFTER INSERT OR UPDATE ON "heroes_watch"."HeroClassHOMM1"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__HeroClassHOMM2"
AFTER INSERT OR UPDATE ON "heroes_watch"."HeroClassHOMM2"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__HeroClassHOMM3"
AFTER INSERT OR UPDATE ON "heroes_watch"."HeroClassHOMM3"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__HeroClassHOMM4"
AFTER INSERT OR UPDATE ON "heroes_watch"."HeroClassHOMM4"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__HeroClassHOMM5"
AFTER INSERT OR UPDATE ON "heroes_watch"."HeroClassHOMM5"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__HeroClassHOMM6"
AFTER INSERT OR UPDATE ON "heroes_watch"."HeroClassHOMM6"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__HeroClassHOMM7"
AFTER INSERT OR UPDATE ON "heroes_watch"."HeroClassHOMM7"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__HeroClassHOMM8"
AFTER INSERT OR UPDATE ON "heroes_watch"."HeroClassHOMM8"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__HeroClassPrimarySkillHOMM4"
AFTER INSERT OR UPDATE ON "heroes_watch"."HeroClassPrimarySkillHOMM4"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__HeroHOMM2"
AFTER INSERT OR UPDATE ON "heroes_watch"."HeroHOMM2"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__HeroHOMM3"
AFTER INSERT OR UPDATE ON "heroes_watch"."HeroHOMM3"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__HeroHOMM5"
AFTER INSERT OR UPDATE ON "heroes_watch"."HeroHOMM5"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__HeroHOMM6"
AFTER INSERT OR UPDATE ON "heroes_watch"."HeroHOMM6"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__HeroHOMM7"
AFTER INSERT OR UPDATE ON "heroes_watch"."HeroHOMM7"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__HeroHOMM8"
AFTER INSERT OR UPDATE ON "heroes_watch"."HeroHOMM8"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__HeroSkill"
AFTER INSERT OR UPDATE ON "heroes_watch"."HeroSkill"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__Lore"
AFTER INSERT OR UPDATE ON "heroes_watch"."Lore"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__LoreFull"
AFTER INSERT OR UPDATE ON "heroes_watch"."LoreFull"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__MagicSchool"
AFTER INSERT OR UPDATE ON "heroes_watch"."MagicSchool"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__MagicSchoolHOMM4"
AFTER INSERT OR UPDATE ON "heroes_watch"."MagicSchoolHOMM4"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__MagicSchoolHOMM5"
AFTER INSERT OR UPDATE ON "heroes_watch"."MagicSchoolHOMM5"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__MagicSchoolHOMM6"
AFTER INSERT OR UPDATE ON "heroes_watch"."MagicSchoolHOMM6"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__MagicSchoolHOMM7"
AFTER INSERT OR UPDATE ON "heroes_watch"."MagicSchoolHOMM7"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__MagicSchoolHOMM8"
AFTER INSERT OR UPDATE ON "heroes_watch"."MagicSchoolHOMM8"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__Map"
AFTER INSERT OR UPDATE ON "heroes_watch"."Map"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__MapHOMM1"
AFTER INSERT OR UPDATE ON "heroes_watch"."MapHOMM1"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__MapHOMM2"
AFTER INSERT OR UPDATE ON "heroes_watch"."MapHOMM2"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__MapHOMM3"
AFTER INSERT OR UPDATE ON "heroes_watch"."MapHOMM3"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__MapHOMM4"
AFTER INSERT OR UPDATE ON "heroes_watch"."MapHOMM4"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__MapHOMM5"
AFTER INSERT OR UPDATE ON "heroes_watch"."MapHOMM5"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__MapHOMM6"
AFTER INSERT OR UPDATE ON "heroes_watch"."MapHOMM6"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__MapHOMM7"
AFTER INSERT OR UPDATE ON "heroes_watch"."MapHOMM7"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__MapHOMM8"
AFTER INSERT OR UPDATE ON "heroes_watch"."MapHOMM8"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__MapObjectPresence"
AFTER INSERT OR UPDATE ON "heroes_watch"."MapObjectPresence"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__MapTerrain"
AFTER INSERT OR UPDATE ON "heroes_watch"."MapTerrain"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__MediaAsset"
AFTER INSERT OR UPDATE ON "heroes_watch"."MediaAsset"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__Patch"
AFTER INSERT OR UPDATE ON "heroes_watch"."Patch"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__Resource"
AFTER INSERT OR UPDATE ON "heroes_watch"."Resource"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__ResourceHOMM1To5"
AFTER INSERT OR UPDATE ON "heroes_watch"."ResourceHOMM1To5"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__ResourceHOMM8"
AFTER INSERT OR UPDATE ON "heroes_watch"."ResourceHOMM8"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__Scenario"
AFTER INSERT OR UPDATE ON "heroes_watch"."Scenario"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__ScenarioConnection"
AFTER INSERT OR UPDATE ON "heroes_watch"."ScenarioConnection"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__ScenarioHOMM1"
AFTER INSERT OR UPDATE ON "heroes_watch"."ScenarioHOMM1"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__ScenarioHOMM2"
AFTER INSERT OR UPDATE ON "heroes_watch"."ScenarioHOMM2"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__ScenarioHOMM3"
AFTER INSERT OR UPDATE ON "heroes_watch"."ScenarioHOMM3"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__ScenarioHOMM4"
AFTER INSERT OR UPDATE ON "heroes_watch"."ScenarioHOMM4"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__ScenarioHOMM5"
AFTER INSERT OR UPDATE ON "heroes_watch"."ScenarioHOMM5"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__ScenarioHOMM6"
AFTER INSERT OR UPDATE ON "heroes_watch"."ScenarioHOMM6"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__ScenarioHOMM7"
AFTER INSERT OR UPDATE ON "heroes_watch"."ScenarioHOMM7"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__ScenarioHOMM8"
AFTER INSERT OR UPDATE ON "heroes_watch"."ScenarioHOMM8"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__Screenshot"
AFTER INSERT OR UPDATE ON "heroes_watch"."Screenshot"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__Skill"
AFTER INSERT OR UPDATE ON "heroes_watch"."Skill"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__SkillHOMM2"
AFTER INSERT OR UPDATE ON "heroes_watch"."SkillHOMM2"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__SkillHOMM3"
AFTER INSERT OR UPDATE ON "heroes_watch"."SkillHOMM3"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__SkillHOMM4"
AFTER INSERT OR UPDATE ON "heroes_watch"."SkillHOMM4"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__SkillHOMM5"
AFTER INSERT OR UPDATE ON "heroes_watch"."SkillHOMM5"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__SkillHOMM7"
AFTER INSERT OR UPDATE ON "heroes_watch"."SkillHOMM7"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__SkillHOMM8"
AFTER INSERT OR UPDATE ON "heroes_watch"."SkillHOMM8"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__Soundtrack"
AFTER INSERT OR UPDATE ON "heroes_watch"."Soundtrack"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__SoundtrackHOMM1"
AFTER INSERT OR UPDATE ON "heroes_watch"."SoundtrackHOMM1"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__SoundtrackHOMM2"
AFTER INSERT OR UPDATE ON "heroes_watch"."SoundtrackHOMM2"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__SoundtrackHOMM3"
AFTER INSERT OR UPDATE ON "heroes_watch"."SoundtrackHOMM3"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__SoundtrackHOMM4"
AFTER INSERT OR UPDATE ON "heroes_watch"."SoundtrackHOMM4"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__SoundtrackHOMM5"
AFTER INSERT OR UPDATE ON "heroes_watch"."SoundtrackHOMM5"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__SoundtrackHOMM6"
AFTER INSERT OR UPDATE ON "heroes_watch"."SoundtrackHOMM6"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__SoundtrackHOMM7"
AFTER INSERT OR UPDATE ON "heroes_watch"."SoundtrackHOMM7"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__Spell"
AFTER INSERT OR UPDATE ON "heroes_watch"."Spell"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__SpellHOMM1"
AFTER INSERT OR UPDATE ON "heroes_watch"."SpellHOMM1"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__SpellHOMM2"
AFTER INSERT OR UPDATE ON "heroes_watch"."SpellHOMM2"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__SpellHOMM3"
AFTER INSERT OR UPDATE ON "heroes_watch"."SpellHOMM3"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__SpellHOMM4"
AFTER INSERT OR UPDATE ON "heroes_watch"."SpellHOMM4"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__SpellHOMM5"
AFTER INSERT OR UPDATE ON "heroes_watch"."SpellHOMM5"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__SpellHOMM6"
AFTER INSERT OR UPDATE ON "heroes_watch"."SpellHOMM6"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__SpellHOMM7"
AFTER INSERT OR UPDATE ON "heroes_watch"."SpellHOMM7"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__SpellHOMM8"
AFTER INSERT OR UPDATE ON "heroes_watch"."SpellHOMM8"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__SpellMagicSchool"
AFTER INSERT OR UPDATE ON "heroes_watch"."SpellMagicSchool"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__SpellResourceCostHOMM5"
AFTER INSERT OR UPDATE ON "heroes_watch"."SpellResourceCostHOMM5"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__Terrain"
AFTER INSERT OR UPDATE ON "heroes_watch"."Terrain"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__TerrainHOMM1"
AFTER INSERT OR UPDATE ON "heroes_watch"."TerrainHOMM1"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__TerrainHOMM2"
AFTER INSERT OR UPDATE ON "heroes_watch"."TerrainHOMM2"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__TerrainHOMM3"
AFTER INSERT OR UPDATE ON "heroes_watch"."TerrainHOMM3"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__TerrainHOMM4"
AFTER INSERT OR UPDATE ON "heroes_watch"."TerrainHOMM4"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__TerrainHOMM5"
AFTER INSERT OR UPDATE ON "heroes_watch"."TerrainHOMM5"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__TerrainHOMM6"
AFTER INSERT OR UPDATE ON "heroes_watch"."TerrainHOMM6"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__TerrainHOMM7"
AFTER INSERT OR UPDATE ON "heroes_watch"."TerrainHOMM7"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__TownScreen"
AFTER INSERT OR UPDATE ON "heroes_watch"."TownScreen"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__TownScreenBuilding"
AFTER INSERT OR UPDATE ON "heroes_watch"."TownScreenBuilding"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();

CREATE CONSTRAINT TRIGGER "ct_game_scope__Video"
AFTER INSERT OR UPDATE ON "heroes_watch"."Video"
DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION "heroes_watch"."_game_scope_constraint"();
-- Check existing rows before committing the upgrade. New triggers only see future edits.
DO $validate_scope$
DECLARE table_name text; meta jsonb; row_key text;
BEGIN
  FOREACH table_name IN ARRAY ARRAY['Ability', 'AbilityHOMM1', 'AbilityHOMM2', 'AbilityHOMM3', 'AbilityHOMM4', 'AbilityHOMM5', 'AbilityHOMM6', 'AbilityHOMM7', 'AbilityHOMM8', 'AdventureObject', 'AdventureObjectCreature', 'AdventureObjectFaction', 'AdventureObjectHOMM1', 'AdventureObjectHOMM2', 'AdventureObjectHOMM3', 'AdventureObjectHOMM4', 'AdventureObjectHOMM5', 'AdventureObjectHOMM6', 'AdventureObjectHOMM7', 'AdventureObjectHOMM8', 'Artifact', 'ArtifactComponent', 'ArtifactHOMM1', 'ArtifactHOMM2', 'ArtifactHOMM3', 'ArtifactHOMM4', 'ArtifactHOMM5', 'ArtifactHOMM6', 'ArtifactHOMM7', 'ArtifactHOMM8', 'ArtifactResourceCost', 'ArtifactSetBonusHOMM5', 'ArtifactSetHOMM5', 'AstrologyHOMM8', 'Building', 'BuildingCreature', 'BuildingHOMM1', 'BuildingHOMM2', 'BuildingHOMM3', 'BuildingHOMM4', 'BuildingHOMM5', 'BuildingHOMM6', 'BuildingHOMM7', 'BuildingHOMM8', 'BuildingRequirement', 'BuildingResourceCost', 'BuildingUpgrade', 'Campaign', 'CampaignHero', 'CampaignHOMM1', 'CampaignHOMM2', 'CampaignHOMM4', 'CampaignHOMM8', 'CampaignScenario', 'Creature', 'CreatureAbility', 'CreatureHOMM1', 'CreatureHOMM2', 'CreatureHOMM3', 'CreatureHOMM4', 'CreatureHOMM5', 'CreatureHOMM6', 'CreatureHOMM7', 'CreatureHOMM8', 'CreatureResourceCost', 'CreatureSpell', 'CreatureUpgrade', 'Expansion', 'Faction', 'FactionHOMM1', 'FactionHOMM2', 'FactionHOMM3', 'FactionHOMM4', 'FactionHOMM5', 'FactionHOMM6', 'FactionHOMM7', 'FactionHOMM8', 'FactionLaw', 'FactionMagicSchoolHOMM5', 'FactionNativeTerrainHOMM5', 'FactionSpell', 'Game', 'GameHOMM8', 'GameResource', 'Hero', 'HeroClass', 'HeroClassAbility', 'HeroClassAbilityRequirementGroup', 'HeroClassHOMM1', 'HeroClassHOMM2', 'HeroClassHOMM3', 'HeroClassHOMM4', 'HeroClassHOMM5', 'HeroClassHOMM6', 'HeroClassHOMM7', 'HeroClassHOMM8', 'HeroClassPrimarySkillHOMM4', 'HeroHOMM2', 'HeroHOMM3', 'HeroHOMM5', 'HeroHOMM6', 'HeroHOMM7', 'HeroHOMM8', 'HeroSkill', 'Lore', 'LoreFull', 'MagicSchool', 'MagicSchoolHOMM4', 'MagicSchoolHOMM5', 'MagicSchoolHOMM6', 'MagicSchoolHOMM7', 'MagicSchoolHOMM8', 'Map', 'MapHOMM1', 'MapHOMM2', 'MapHOMM3', 'MapHOMM4', 'MapHOMM5', 'MapHOMM6', 'MapHOMM7', 'MapHOMM8', 'MapObjectPresence', 'MapTerrain', 'MediaAsset', 'Patch', 'Resource', 'ResourceHOMM1To5', 'ResourceHOMM8', 'Scenario', 'ScenarioConnection', 'ScenarioHOMM1', 'ScenarioHOMM2', 'ScenarioHOMM3', 'ScenarioHOMM4', 'ScenarioHOMM5', 'ScenarioHOMM6', 'ScenarioHOMM7', 'ScenarioHOMM8', 'Screenshot', 'Skill', 'SkillHOMM2', 'SkillHOMM3', 'SkillHOMM4', 'SkillHOMM5', 'SkillHOMM7', 'SkillHOMM8', 'Soundtrack', 'SoundtrackHOMM1', 'SoundtrackHOMM2', 'SoundtrackHOMM3', 'SoundtrackHOMM4', 'SoundtrackHOMM5', 'SoundtrackHOMM6', 'SoundtrackHOMM7', 'Spell', 'SpellHOMM1', 'SpellHOMM2', 'SpellHOMM3', 'SpellHOMM4', 'SpellHOMM5', 'SpellHOMM6', 'SpellHOMM7', 'SpellHOMM8', 'SpellMagicSchool', 'SpellResourceCostHOMM5', 'Terrain', 'TerrainHOMM1', 'TerrainHOMM2', 'TerrainHOMM3', 'TerrainHOMM4', 'TerrainHOMM5', 'TerrainHOMM6', 'TerrainHOMM7', 'TownScreen', 'TownScreenBuilding', 'Video'] LOOP
    meta := "heroes_watch"."_scope_metadata"(table_name);
    FOR row_key IN EXECUTE format('SELECT %I::text FROM %I.%I', meta->>'pk', 'heroes_watch', table_name) LOOP
      PERFORM "heroes_watch"."_check_scope_row"(table_name, row_key);
    END LOOP;
  END LOOP;
END
$validate_scope$;

COMMIT;
