-- Read-only: expect 14 creatures and 7 upgrade links for each of the nine factions.
-- Cost rows include gold for every creature plus any rare-resource requirement.
WITH roster AS (
    SELECT f."Name", f."Code", c."Creature_id", g."Game_id",
           (SELECT COUNT(*) FROM heroes_watch."CreatureUpgrade" u
            WHERE u."Game_id" = g."Game_id" AND u."BaseCreature_id" = c."Creature_id") AS upgrades,
           (SELECT COUNT(*) FROM heroes_watch."CreatureResourceCost" rc
            WHERE rc."Game_id" = g."Game_id" AND rc."Creature_id" = c."Creature_id") AS costs,
           (
               num_nonnulls(d."Faction_id", d."Alignment", d."Level", d."Attack", d."Defense",
                   d."DamageMin", d."DamageMax", d."Health", d."Speed", d."Movement",
                   d."Size", d."Shots", d."Growth", d."AIValue", d."GoldCost",
                   d."Recruitable", d."DoubleUpgrade", d."AlternativeUpgrade") = 18
               AND d."Alignment"::TEXT = fd."Alignment"::TEXT
               AND d."Level" BETWEEN 1 AND 7
               AND d."DamageMin" <= d."DamageMax"
               AND d."Size" IN (1, 2)
               AND d."Recruitable" AND NOT d."DoubleUpgrade" AND NOT d."AlternativeUpgrade"
               AND e."Game_id" = g."Game_id"
               AND EXISTS (
                   SELECT 1 FROM heroes_watch."CreatureResourceCost" rc
                   JOIN heroes_watch."Resource" r ON r."Resource_id" = rc."Resource_id"
                   JOIN heroes_watch."GameResource" gr ON gr."Resource_id" = r."Resource_id"
                       AND gr."Game_id" = g."Game_id"
                   WHERE rc."Game_id" = g."Game_id" AND rc."Creature_id" = c."Creature_id"
                     AND r."Code" = 'GOLD' AND rc."Amount" = d."GoldCost"
               )
           ) AS valid
    FROM heroes_watch."Creature" c
    JOIN heroes_watch."Game" g ON g."Game_id" = c."Game_id"
    JOIN heroes_watch."CreatureHOMM3" d ON d."Creature_id" = c."Creature_id"
    JOIN heroes_watch."Faction" f ON f."Faction_id" = d."Faction_id" AND f."Game_id" = g."Game_id"
    JOIN heroes_watch."FactionHOMM3" fd ON fd."Faction_id" = f."Faction_id"
    JOIN heroes_watch."Expansion" e ON e."Expansion_id" = c."IntroducedInExpansion_id"
    WHERE g."SeriesCode" = 'HOMM3'
      AND f."Code" IN ('CASTLE','TOWER','RAMPART','INFERNO','NECROPOLIS','DUNGEON','STRONGHOLD','FORTRESS','CONFLUX')
)
SELECT "Name" AS "Faction", COUNT(*) AS "Creatures",
       SUM(upgrades) AS "Upgrade links", SUM(costs) AS "Cost rows",
       BOOL_AND(valid) AS "Valid details"
FROM roster
GROUP BY "Name", "Code"
ORDER BY array_position(ARRAY['CASTLE','TOWER','RAMPART','INFERNO','NECROPOLIS','DUNGEON','STRONGHOLD','FORTRESS','CONFLUX'], "Code");
