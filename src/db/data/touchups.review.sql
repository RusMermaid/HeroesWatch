-- Read-only summary of the updated relationship paths.
SELECT current_database() AS database_name, current_user AS connected_as,
  (SELECT count(*) FROM heroes_watch."Game") AS games,
  (SELECT count(*) FROM heroes_watch."MediaAsset" WHERE left("Code",7)='MANUAL_' AND "MimeType"='application/pdf') AS manual_pdfs,
  (SELECT count(*) FROM heroes_watch."HeroClassAbilityRequirementGroup") AS prerequisite_groups,
  (SELECT count(*) FROM heroes_watch."AdventureObjectCreature") AS object_creature_links,
  (SELECT count(*) FROM heroes_watch."AdventureObjectFaction") AS object_faction_links,
  (SELECT count(*) FROM heroes_watch."CampaignScenario") AS campaign_scenario_links,
  (SELECT count(*) FROM heroes_watch."ScenarioConnection") AS progression_edges,
  (SELECT count(*) FROM heroes_watch."MapTerrain") AS map_terrain_links,
  (SELECT count(*) FROM heroes_watch."MapObjectPresence") AS map_object_links;

SELECT g."SeriesCode", c."Name" AS campaign, count(cs."Scenario_id") AS scenarios
FROM heroes_watch."Campaign" c
JOIN heroes_watch."Game" g ON g."Game_id"=c."Game_id"
LEFT JOIN heroes_watch."CampaignScenario" cs ON cs."Campaign_id"=c."Campaign_id"
GROUP BY g."DisplayOrder",g."SeriesCode",c."Campaign_id",c."Name"
ORDER BY g."DisplayOrder",c."Name";
