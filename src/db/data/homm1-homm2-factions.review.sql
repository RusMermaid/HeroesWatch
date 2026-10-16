-- Read-only: four Heroes I factions and six Heroes II factions.
-- Dashes indicate fields not modeled for that title, not missing required values.
SELECT g."SeriesCode" AS "Game", f."Name" AS "Faction",
       COALESCE(h1."TownType"::TEXT, '-') AS "Town type",
       COALESCE(h2."Alignment"::TEXT, '-') AS "Alignment",
       COALESCE(h2."MageGuildMaxLevel"::TEXT, '-') AS "Mage guild max",
       e."Code" AS "Introduced in"
FROM heroes_watch."Faction" f
JOIN heroes_watch."Game" g ON g."Game_id" = f."Game_id"
JOIN heroes_watch."Expansion" e ON e."Expansion_id" = f."IntroducedInExpansion_id" AND e."Game_id" = g."Game_id"
LEFT JOIN heroes_watch."FactionHOMM1" h1 ON h1."Faction_id" = f."Faction_id" AND g."SeriesCode" = 'HOMM1'
LEFT JOIN heroes_watch."FactionHOMM2" h2 ON h2."Faction_id" = f."Faction_id" AND g."SeriesCode" = 'HOMM2'
WHERE (g."SeriesCode" = 'HOMM1' AND h1."Faction_id" IS NOT NULL AND f."Code" IN ('KNIGHT','SORCERESS','WARLOCK','BARBARIAN'))
   OR (g."SeriesCode" = 'HOMM2' AND h2."Faction_id" IS NOT NULL AND f."Code" IN ('KNIGHT','SORCERESS','BARBARIAN','NECROMANCER','WARLOCK','WIZARD'))
ORDER BY g."DisplayOrder",
    CASE WHEN g."SeriesCode" = 'HOMM1' THEN array_position(ARRAY['KNIGHT','SORCERESS','WARLOCK','BARBARIAN'], f."Code")
         ELSE array_position(ARRAY['KNIGHT','SORCERESS','BARBARIAN','NECROMANCER','WARLOCK','WIZARD'], f."Code") END;
