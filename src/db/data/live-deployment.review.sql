-- Read-only live deployment summary. Counts include all rows in the schema.
WITH counts AS (
  SELECT count(*) AS n FROM heroes_watch."Ability"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."AbilityHOMM1"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."AbilityHOMM2"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."AbilityHOMM3"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."AbilityHOMM4"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."AbilityHOMM5"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."AbilityHOMM6"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."AbilityHOMM7"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."AbilityHOMM8"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."AdventureObject"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."AdventureObjectCreature"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."AdventureObjectFaction"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."AdventureObjectHOMM1"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."AdventureObjectHOMM2"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."AdventureObjectHOMM3"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."AdventureObjectHOMM4"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."AdventureObjectHOMM5"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."AdventureObjectHOMM6"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."AdventureObjectHOMM7"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."AdventureObjectHOMM8"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."Artifact"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."ArtifactComponent"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."ArtifactHOMM1"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."ArtifactHOMM2"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."ArtifactHOMM3"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."ArtifactHOMM4"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."ArtifactHOMM5"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."ArtifactHOMM6"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."ArtifactHOMM7"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."ArtifactHOMM8"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."ArtifactResourceCost"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."ArtifactSetBonusHOMM5"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."ArtifactSetHOMM5"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."AstrologyHOMM8"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."Building"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."BuildingCreature"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."BuildingHOMM1"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."BuildingHOMM2"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."BuildingHOMM3"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."BuildingHOMM4"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."BuildingHOMM5"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."BuildingHOMM6"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."BuildingHOMM7"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."BuildingHOMM8"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."BuildingRequirement"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."BuildingResourceCost"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."BuildingUpgrade"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."Campaign"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."CampaignHero"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."CampaignHOMM1"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."CampaignHOMM2"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."CampaignHOMM4"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."CampaignHOMM8"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."CampaignScenario"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."Creature"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."CreatureAbility"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."CreatureHOMM1"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."CreatureHOMM2"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."CreatureHOMM3"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."CreatureHOMM4"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."CreatureHOMM5"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."CreatureHOMM6"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."CreatureHOMM7"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."CreatureHOMM8"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."CreatureResourceCost"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."CreatureSpell"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."CreatureUpgrade"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."Expansion"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."Faction"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."FactionHOMM1"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."FactionHOMM2"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."FactionHOMM3"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."FactionHOMM4"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."FactionHOMM5"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."FactionHOMM6"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."FactionHOMM7"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."FactionHOMM8"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."FactionLaw"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."FactionMagicSchoolHOMM5"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."FactionNativeTerrainHOMM5"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."FactionSpell"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."Game"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."GameHOMM8"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."GameResource"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."Hero"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."HeroClass"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."HeroClassAbility"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."HeroClassAbilityRequirementGroup"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."HeroClassHOMM1"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."HeroClassHOMM2"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."HeroClassHOMM3"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."HeroClassHOMM4"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."HeroClassHOMM5"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."HeroClassHOMM6"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."HeroClassHOMM7"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."HeroClassHOMM8"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."HeroClassPrimarySkillHOMM4"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."HeroHOMM2"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."HeroHOMM3"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."HeroHOMM5"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."HeroHOMM6"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."HeroHOMM7"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."HeroHOMM8"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."HeroSkill"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."Lore"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."LoreFull"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."MagicSchool"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."MagicSchoolHOMM4"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."MagicSchoolHOMM5"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."MagicSchoolHOMM6"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."MagicSchoolHOMM7"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."MagicSchoolHOMM8"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."Map"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."MapHOMM1"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."MapHOMM2"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."MapHOMM3"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."MapHOMM4"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."MapHOMM5"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."MapHOMM6"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."MapHOMM7"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."MapHOMM8"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."MapObjectPresence"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."MapTerrain"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."MediaAsset"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."Patch"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."Resource"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."ResourceHOMM1To5"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."ResourceHOMM8"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."Scenario"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."ScenarioConnection"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."ScenarioHOMM1"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."ScenarioHOMM2"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."ScenarioHOMM3"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."ScenarioHOMM4"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."ScenarioHOMM5"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."ScenarioHOMM6"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."ScenarioHOMM7"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."ScenarioHOMM8"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."Screenshot"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."Skill"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."SkillHOMM2"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."SkillHOMM3"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."SkillHOMM4"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."SkillHOMM5"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."SkillHOMM7"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."SkillHOMM8"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."Soundtrack"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."SoundtrackHOMM1"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."SoundtrackHOMM2"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."SoundtrackHOMM3"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."SoundtrackHOMM4"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."SoundtrackHOMM5"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."SoundtrackHOMM6"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."SoundtrackHOMM7"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."Spell"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."SpellHOMM1"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."SpellHOMM2"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."SpellHOMM3"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."SpellHOMM4"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."SpellHOMM5"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."SpellHOMM6"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."SpellHOMM7"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."SpellHOMM8"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."SpellMagicSchool"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."SpellResourceCostHOMM5"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."Terrain"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."TerrainHOMM1"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."TerrainHOMM2"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."TerrainHOMM3"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."TerrainHOMM4"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."TerrainHOMM5"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."TerrainHOMM6"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."TerrainHOMM7"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."TownScreen"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."TownScreenBuilding"
  UNION ALL
  SELECT count(*) AS n FROM heroes_watch."Video"
), metrics AS (
  SELECT 1 AS position, 'Database'::text AS metric, current_database()::text AS value
  UNION ALL
  SELECT 2 AS position, 'Database owner'::text AS metric, (SELECT pg_get_userbyid(datdba) FROM pg_database WHERE datname=current_database())::text AS value
  UNION ALL
  SELECT 3 AS position, 'Schema tables'::text AS metric, (SELECT count(*)::text FROM information_schema.tables WHERE table_schema='heroes_watch' AND table_type='BASE TABLE')::text AS value
  UNION ALL
  SELECT 4 AS position, 'Catalog rows'::text AS metric, (SELECT sum(n)::text FROM counts)::text AS value
  UNION ALL
  SELECT 5 AS position, 'Games'::text AS metric, (SELECT count(*)::text FROM heroes_watch."Game")::text AS value
  UNION ALL
  SELECT 6 AS position, 'PDF manuals'::text AS metric, (SELECT count(*)::text FROM heroes_watch."MediaAsset" WHERE left("Code",7)='MANUAL_' AND "MimeType"='application/pdf')::text AS value
  UNION ALL
  SELECT 7 AS position, 'Object / creature links'::text AS metric, (SELECT count(*)::text FROM heroes_watch."AdventureObjectCreature")::text AS value
  UNION ALL
  SELECT 8 AS position, 'Object / faction links'::text AS metric, (SELECT count(*)::text FROM heroes_watch."AdventureObjectFaction")::text AS value
  UNION ALL
  SELECT 9 AS position, 'Prerequisite groups'::text AS metric, (SELECT count(*)::text FROM heroes_watch."HeroClassAbilityRequirementGroup")::text AS value
  UNION ALL
  SELECT 10 AS position, 'Faction / spell links'::text AS metric, (SELECT count(*)::text FROM heroes_watch."FactionSpell")::text AS value
  UNION ALL
  SELECT 11 AS position, 'Creature / ability links'::text AS metric, (SELECT count(*)::text FROM heroes_watch."CreatureAbility")::text AS value
  UNION ALL
  SELECT 12 AS position, 'Campaign / scenario links'::text AS metric, (SELECT count(*)::text FROM heroes_watch."CampaignScenario")::text AS value
  UNION ALL
  SELECT 13 AS position, 'Scenario progression edges'::text AS metric, (SELECT count(*)::text FROM heroes_watch."ScenarioConnection")::text AS value
  UNION ALL
  SELECT 14 AS position, 'Map / terrain links'::text AS metric, (SELECT count(*)::text FROM heroes_watch."MapTerrain")::text AS value
  UNION ALL
  SELECT 15 AS position, 'Map / object links'::text AS metric, (SELECT count(*)::text FROM heroes_watch."MapObjectPresence")::text AS value
  UNION ALL
  SELECT 16 AS position, 'Starting scenario links'::text AS metric, (SELECT count(*)::text FROM heroes_watch."CampaignHero" WHERE "StartingScenario_id" IS NOT NULL)::text AS value
)
SELECT metric, value FROM metrics ORDER BY position;
