-- Read-only: six base-game factions and Fortress from Trial by Fire.
-- The skill and introduction joins also require matching Heroes VII game scope.
SELECT f."Name" AS "Faction", d."Alignment"::TEXT AS "Alignment",
       s."Name" AS "Racial skill", sd."MaxMastery"::TEXT AS "Max mastery",
       CASE WHEN e."Kind" = 'BaseGame' THEN 'Base game' ELSE e."Name" END AS "Introduced in"
FROM heroes_watch."Faction" f
JOIN heroes_watch."Game" g ON g."Game_id" = f."Game_id"
JOIN heroes_watch."FactionHOMM7" d ON d."Faction_id" = f."Faction_id"
JOIN heroes_watch."Skill" s ON s."Skill_id" = d."RacialSkill_id" AND s."Game_id" = g."Game_id"
JOIN heroes_watch."SkillHOMM7" sd ON sd."Skill_id" = s."Skill_id"
JOIN heroes_watch."Expansion" e ON e."Expansion_id" = f."IntroducedInExpansion_id" AND e."Game_id" = g."Game_id"
WHERE g."SeriesCode" = 'HOMM7'
  AND sd."SkillKind" = 'Faction'
  AND s."IntroducedInExpansion_id" = e."Expansion_id"
  AND f."Code" IN ('HAVEN','ACADEMY','NECROPOLIS','STRONGHOLD','SYLVAN','DUNGEON','FORTRESS')
ORDER BY array_position(ARRAY['HAVEN','ACADEMY','NECROPOLIS','STRONGHOLD','SYLVAN','DUNGEON','FORTRESS'], f."Code");
