-- Read-only: the 26 creatures outside standard Heroes IV town lineups.
-- These creatures retain their faction alignment; Faction_id is not a neutral flag.
SELECT c."Name" AS "Creature", f4."Alignment"::TEXT AS "Alignment",
       d."Level", d."Health" AS "HP", d."Attack" AS "Melee attack", d."Defense" AS "Melee defense",
       concat(d."DamageMin", '-', d."DamageMax") AS "Damage", d."Speed",
       d."Movement"::TEXT AS "Movement", d."Shots", d."SpellPoints" AS "Spell points",
       d."Recruitable", e."Code" AS "Introduced in"
FROM heroes_watch."Creature" c
JOIN heroes_watch."Game" g ON g."Game_id" = c."Game_id"
JOIN heroes_watch."CreatureHOMM4" d ON d."Creature_id" = c."Creature_id"
JOIN heroes_watch."Faction" f ON f."Faction_id" = d."Faction_id" AND f."Game_id" = g."Game_id"
JOIN heroes_watch."FactionHOMM4" f4 ON f4."Faction_id" = f."Faction_id"
JOIN heroes_watch."Expansion" e ON e."Expansion_id" = c."IntroducedInExpansion_id" AND e."Game_id" = g."Game_id"
WHERE g."SeriesCode" = 'HOMM4'
  AND c."Code" IN ('PEASANT', 'LEPRECHAUN', 'TROGLODYTE', 'PIRATE', 'ZOMBIE', 'SATYR', 'EVIL_EYE', 'TROLL', 'MUMMY', 'GARGOYLE', 'MERMAID', 'WASPWORT', 'FIRE_ELEMENTAL', 'AIR_ELEMENTAL', 'WATER_ELEMENTAL', 'EARTH_ELEMENTAL', 'ICE_DEMON', 'MANTIS', 'SEA_MONSTER', 'GOBLIN_KNIGHT', 'EVIL_SORCERESS', 'GARGANTUAN', 'DARK_CHAMPION', 'CATAPULT', 'FRENZIED_GNASHER', 'MEGADRAGON')
ORDER BY array_position(ARRAY['BASE','TGS','WOW'], e."Code"), d."Level", c."Name";
