-- Read-only: five base-game factions and Dungeon from Shades of Darkness.
SELECT f."Name" AS "Faction", a."Name" AS "Faction ability",
       ad."AbilityKind"::TEXT AS "Ability kind", ad."IsActive" AS "Active",
       d."UniqueBuildingLimit" AS "Unique building limit", e."Name" AS "Introduced in"
FROM heroes_watch."Faction" f
JOIN heroes_watch."Game" g ON g."Game_id" = f."Game_id"
JOIN heroes_watch."FactionHOMM6" d ON d."Faction_id" = f."Faction_id"
JOIN heroes_watch."Ability" a ON a."Ability_id" = d."FactionAbility_id" AND a."Game_id" = g."Game_id"
JOIN heroes_watch."AbilityHOMM6" ad ON ad."Ability_id" = a."Ability_id"
JOIN heroes_watch."Expansion" e ON e."Expansion_id" = f."IntroducedInExpansion_id" AND e."Game_id" = g."Game_id"
WHERE g."SeriesCode" = 'HOMM6'
  AND f."Code" IN ('HAVEN','INFERNO','NECROPOLIS','SANCTUARY','STRONGHOLD','DUNGEON')
ORDER BY array_position(ARRAY['HAVEN','INFERNO','NECROPOLIS','SANCTUARY','STRONGHOLD','DUNGEON'], f."Code");
