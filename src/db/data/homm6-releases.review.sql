-- Read-only: Heroes VI and its three gameplay add-ons.
SELECT e."Name" AS "Release", e."Kind"::TEXT AS "Kind", e."Code", e."Description"
FROM heroes_watch."Expansion" e
JOIN heroes_watch."Game" g ON g."Game_id" = e."Game_id"
WHERE g."SeriesCode" = 'HOMM6' AND e."Code" IN ('BASE','POTSS','DM','SOD')
ORDER BY array_position(ARRAY['BASE','POTSS','DM','SOD'], e."Code");
