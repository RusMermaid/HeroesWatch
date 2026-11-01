-- Read-only: original releases and the Heroes II Gold compilation.
SELECT g."SeriesCode" AS "Game", e."Name" AS "Release", e."Kind"::TEXT AS "Kind", e."Code"
FROM heroes_watch."Expansion" e
JOIN heroes_watch."Game" g ON g."Game_id" = e."Game_id"
WHERE (g."SeriesCode" = 'HOMM1' AND e."Code" = 'BASE')
   OR (g."SeriesCode" = 'HOMM2' AND e."Code" IN ('SW','POL','GOLD'))
ORDER BY g."DisplayOrder", array_position(ARRAY['BASE','SW','POL','GOLD'], e."Code");
