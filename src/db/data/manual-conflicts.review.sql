-- Read-only review of the six unresolved manual disagreements.
-- A disagreement is not proof that the current game-rule value is wrong.
SELECT 'HOMM1' AS "Game", 'Orc' AS "Entity", 'Speed' AS "Field", d."Speed"::text AS "Database value", 'Slow' AS "Manual value", d."Speed"::text = 'Medium' AS "Matches retained catalog", 'manual.c1d7c0b2da69' AS "Manual key", 82 AS "PDF page"
FROM heroes_watch."CreatureHOMM1" d
JOIN heroes_watch."Creature" p ON p."Creature_id" = d."Creature_id"
JOIN heroes_watch."Game" g ON g."Game_id" = p."Game_id"
WHERE g."SeriesCode" = 'HOMM1' AND p."Code" = 'ORC'
UNION ALL
SELECT 'HOMM1' AS "Game", 'Gargoyle' AS "Entity", 'Attack' AS "Field", d."Attack"::text AS "Database value", '4' AS "Manual value", d."Attack"::text = '3' AS "Matches retained catalog", 'manual.c1d7c0b2da69' AS "Manual key", 86 AS "PDF page"
FROM heroes_watch."CreatureHOMM1" d
JOIN heroes_watch."Creature" p ON p."Creature_id" = d."Creature_id"
JOIN heroes_watch."Game" g ON g."Game_id" = p."Game_id"
WHERE g."SeriesCode" = 'HOMM1' AND p."Code" = 'GARGOYLE'
UNION ALL
SELECT 'HOMM2' AS "Game", 'Giant' AS "Entity", 'GoldCost' AS "Field", d."GoldCost"::text AS "Database value", '1250' AS "Manual value", d."GoldCost"::text = '2000' AS "Matches retained catalog", 'manual.a99f53fdd378' AS "Manual key", 90 AS "PDF page"
FROM heroes_watch."CreatureHOMM2" d
JOIN heroes_watch."Creature" p ON p."Creature_id" = d."Creature_id"
JOIN heroes_watch."Game" g ON g."Game_id" = p."Game_id"
WHERE g."SeriesCode" = 'HOMM2' AND p."Code" = 'GIANT'
UNION ALL
SELECT 'HOMM1' AS "Game", 'Jousting Arena' AS "Entity", 'GoldCost' AS "Field", d."GoldCost"::text AS "Database value", '4000' AS "Manual value", d."GoldCost"::text = '3000' AS "Matches retained catalog", 'manual.c1d7c0b2da69' AS "Manual key", 81 AS "PDF page"
FROM heroes_watch."BuildingHOMM1" d
JOIN heroes_watch."Building" p ON p."Building_id" = d."Building_id"
JOIN heroes_watch."Game" g ON g."Game_id" = p."Game_id"
WHERE g."SeriesCode" = 'HOMM1' AND p."Code" = 'KNIGHT_JOUSTING_ARENA'
UNION ALL
SELECT 'HOMM1' AS "Game", 'Bridge' AS "Entity", 'GoldCost' AS "Field", d."GoldCost"::text AS "Database value", '3000' AS "Manual value", d."GoldCost"::text = '4000' AS "Matches retained catalog", 'manual.c1d7c0b2da69' AS "Manual key", 83 AS "PDF page"
FROM heroes_watch."BuildingHOMM1" d
JOIN heroes_watch."Building" p ON p."Building_id" = d."Building_id"
JOIN heroes_watch."Game" g ON g."Game_id" = p."Game_id"
WHERE g."SeriesCode" = 'HOMM1' AND p."Code" = 'BARBARIAN_BRIDGE'
UNION ALL
SELECT 'HOMM4' AS "Game", 'Giant Strength' AS "Entity", 'ManaCost' AS "Field", d."ManaCost"::text AS "Database value", '2' AS "Manual value", d."ManaCost"::text = '3' AS "Matches retained catalog", 'manual.1082fde64d0e' AS "Manual key", 40 AS "PDF page"
FROM heroes_watch."SpellHOMM4" d
JOIN heroes_watch."Spell" p ON p."Spell_id" = d."Spell_id"
JOIN heroes_watch."Game" g ON g."Game_id" = p."Game_id"
WHERE g."SeriesCode" = 'HOMM4' AND p."Code" = 'GIANT_STRENGTH'
ORDER BY "Game", "Entity", "Field";
