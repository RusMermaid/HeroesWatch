-- Read-only: the six Heroes IV towns, shared across the base game and expansions.
SELECT f."Name" AS "Faction", d."Alignment"::TEXT AS "Alignment",
       t."Name" AS "Native terrain", m."Name" AS "Magic school",
       d."HasMagicGuild" AS "Magic guild",
       concat_ws(', ', a."Name", b."Name") AS "Allied factions"
FROM heroes_watch."Faction" f
JOIN heroes_watch."Game" g ON g."Game_id" = f."Game_id"
JOIN heroes_watch."FactionHOMM4" d ON d."Faction_id" = f."Faction_id"
JOIN heroes_watch."Terrain" t ON t."Terrain_id" = d."NativeTerrain_id" AND t."Game_id" = g."Game_id"
LEFT JOIN heroes_watch."MagicSchool" m ON m."MagicSchool_id" = d."NativeMagicSchool_id" AND m."Game_id" = g."Game_id"
LEFT JOIN heroes_watch."Faction" a ON a."Faction_id" = d."AlliedFactionA_id" AND a."Game_id" = g."Game_id"
LEFT JOIN heroes_watch."Faction" b ON b."Faction_id" = d."AlliedFactionB_id" AND b."Game_id" = g."Game_id"
WHERE g."SeriesCode" = 'HOMM4'
  AND f."Code" IN ('HAVEN', 'ACADEMY', 'NECROPOLIS', 'ASYLUM', 'PRESERVE', 'STRONGHOLD')
ORDER BY array_position(ARRAY['HAVEN','ACADEMY','NECROPOLIS','ASYLUM','PRESERVE','STRONGHOLD'], f."Code");
