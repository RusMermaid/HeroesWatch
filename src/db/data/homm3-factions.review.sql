-- Read-only verification of the nine requested factions.
SELECT
    f."Name" AS "Faction",
    d."Alignment"::text AS "Alignment",
    t."Name" AS "Native terrain",
    e."Name" AS "Introduced in",
    f."Faction_id" AS "Faction ID"
FROM heroes_watch."Faction" f
JOIN heroes_watch."Game" g ON g."Game_id" = f."Game_id"
JOIN heroes_watch."FactionHOMM3" d ON d."Faction_id" = f."Faction_id"
JOIN heroes_watch."Terrain" t
  ON t."Terrain_id" = d."NativeTerrain_id" AND t."Game_id" = g."Game_id"
JOIN heroes_watch."Expansion" e
  ON e."Expansion_id" = f."IntroducedInExpansion_id" AND e."Game_id" = g."Game_id"
WHERE g."SeriesCode" = 'HOMM3'
  AND f."Code" IN ('CASTLE', 'RAMPART', 'TOWER', 'INFERNO', 'NECROPOLIS', 'DUNGEON', 'STRONGHOLD', 'FORTRESS', 'CONFLUX')
ORDER BY array_position(ARRAY['CASTLE', 'RAMPART', 'TOWER', 'INFERNO', 'NECROPOLIS', 'DUNGEON', 'STRONGHOLD', 'FORTRESS', 'CONFLUX'], f."Code");
