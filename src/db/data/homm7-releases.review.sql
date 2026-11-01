-- Read-only: the base game, the two-campaign Lost Tales package, and Trial by Fire.
SELECT e."Name" AS "Release", e."Kind"::TEXT AS "Kind", e."Code", e."Description"
FROM heroes_watch."Expansion" e
JOIN heroes_watch."Game" g ON g."Game_id" = e."Game_id"
WHERE g."SeriesCode" = 'HOMM7' AND e."Code" IN ('BASE','LTOA','TBF')
ORDER BY array_position(ARRAY['BASE','LTOA','TBF'], e."Code");
