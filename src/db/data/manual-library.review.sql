-- Registered local manuals and the page-linked comparison report.
SELECT COALESCE(g."SeriesCode", 'MULTI-GAME / REFERENCE') AS "Game", m."Name",
       m."SourceEdition", m."Credit", m."Uri", m."Checksum", m."Description"
FROM heroes_watch."MediaAsset" m
LEFT JOIN heroes_watch."Game" g ON g."Game_id" = m."Game_id"
WHERE m."Code" LIKE 'MANUAL\_%' ESCAPE '\'
ORDER BY g."DisplayOrder" NULLS LAST, m."Name";
