-- Read-only: all 126 town creatures under classic Shadow of Death rules with AB content.
-- Damage is per attack; Growth excludes fortifications and horde-building bonuses.
-- Recruitment cost is for one creature, not the price of upgrading an existing unit.
SELECT f."Name" AS "Faction", d."Level",
       CASE WHEN incoming."CreatureUpgrade_cid" IS NULL THEN 'Base' ELSE 'Upgrade' END AS "Form",
       c."Name" AS "Creature", d."Attack", d."Defense",
       d."DamageMin"::TEXT || '-' || d."DamageMax"::TEXT AS "Damage",
       d."Health", d."Speed", d."Movement"::TEXT AS "Movement", d."Size",
       d."Shots", d."Growth", d."AIValue", d."GoldCost",
       COALESCE(rare.cost, '') AS "Other resource cost",
       COALESCE(upgraded."Name", '') AS "Upgrades to", e."Name" AS "Introduced in"
FROM heroes_watch."Creature" c
JOIN heroes_watch."Game" g ON g."Game_id" = c."Game_id"
JOIN heroes_watch."CreatureHOMM3" d ON d."Creature_id" = c."Creature_id"
JOIN heroes_watch."Faction" f ON f."Faction_id" = d."Faction_id" AND f."Game_id" = g."Game_id"
JOIN heroes_watch."Expansion" e ON e."Expansion_id" = c."IntroducedInExpansion_id" AND e."Game_id" = g."Game_id"
LEFT JOIN heroes_watch."CreatureUpgrade" incoming ON incoming."UpgradedCreature_id" = c."Creature_id" AND incoming."Game_id" = g."Game_id"
LEFT JOIN heroes_watch."CreatureUpgrade" outgoing ON outgoing."BaseCreature_id" = c."Creature_id" AND outgoing."Game_id" = g."Game_id"
LEFT JOIN heroes_watch."Creature" upgraded ON upgraded."Creature_id" = outgoing."UpgradedCreature_id" AND upgraded."Game_id" = g."Game_id"
LEFT JOIN LATERAL (
    SELECT STRING_AGG(rc."Amount"::TEXT || ' ' || r."Name", ', ' ORDER BY r."Code") AS cost
    FROM heroes_watch."CreatureResourceCost" rc
    JOIN heroes_watch."Resource" r ON r."Resource_id" = rc."Resource_id"
    WHERE rc."Creature_id" = c."Creature_id" AND rc."Game_id" = g."Game_id" AND r."Code" <> 'GOLD'
) rare ON TRUE
WHERE g."SeriesCode" = 'HOMM3'
  AND f."Code" IN ('CASTLE','TOWER','RAMPART','INFERNO','NECROPOLIS','DUNGEON','STRONGHOLD','FORTRESS','CONFLUX')
ORDER BY array_position(ARRAY['CASTLE','TOWER','RAMPART','INFERNO','NECROPOLIS','DUNGEON','STRONGHOLD','FORTRESS','CONFLUX'], f."Code"),
         d."Level", incoming."CreatureUpgrade_cid" IS NOT NULL, c."Code";
