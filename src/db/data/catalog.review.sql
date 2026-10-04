-- Read-only catalog review. Run in the target database after catalog.sql commits.
SELECT g."SeriesCode" AS "Game", g."Name",
       (SELECT count(*) FROM heroes_watch."Faction" x WHERE x."Game_id" = g."Game_id") AS "Factions",
       (SELECT count(*) FROM heroes_watch."HeroClass" x WHERE x."Game_id" = g."Game_id") AS "Classes",
       (SELECT count(*) FROM heroes_watch."Hero" x WHERE x."Game_id" = g."Game_id") AS "Heroes",
       (SELECT count(*) FROM heroes_watch."Building" x WHERE x."Game_id" = g."Game_id") AS "Town buildings",
       (SELECT count(*) FROM heroes_watch."AdventureObject" x WHERE x."Game_id" = g."Game_id") AS "Map objects",
       (SELECT count(*) FROM heroes_watch."Skill" x WHERE x."Game_id" = g."Game_id") AS "Skills",
       (SELECT count(*) FROM heroes_watch."MagicSchool" x WHERE x."Game_id" = g."Game_id") AS "Schools",
       (SELECT count(*) FROM heroes_watch."Spell" x WHERE x."Game_id" = g."Game_id") AS "Spells",
       (SELECT count(*) FROM heroes_watch."Artifact" x WHERE x."Game_id" = g."Game_id") AS "Artifacts",
       (SELECT count(*) FROM heroes_watch."Campaign" x WHERE x."Game_id" = g."Game_id") AS "Campaigns"
FROM heroes_watch."Game" g
ORDER BY g."DisplayOrder";

-- Classes and hero counts, using the faction FK declared by each game's model.
WITH affiliation AS (
    SELECT "HeroClass_id", "Faction_id" FROM heroes_watch."HeroClassHOMM1"
    UNION ALL SELECT "HeroClass_id", "Faction_id" FROM heroes_watch."HeroClassHOMM2"
    UNION ALL SELECT "HeroClass_id", "Faction_id" FROM heroes_watch."HeroClassHOMM3"
    UNION ALL SELECT "HeroClass_id", "StartingFaction_id" AS "Faction_id" FROM heroes_watch."HeroClassHOMM4"
    UNION ALL SELECT "HeroClass_id", "Faction_id" FROM heroes_watch."HeroClassHOMM5"
    UNION ALL SELECT "HeroClass_id", "Faction_id" FROM heroes_watch."HeroClassHOMM6"
    UNION ALL SELECT "HeroClass_id", "Faction_id" FROM heroes_watch."HeroClassHOMM7"
    UNION ALL SELECT "HeroClass_id", "Faction_id" FROM heroes_watch."HeroClassHOMM8"
)
SELECT g."SeriesCode" AS "Game", f."Name" AS "Faction", c."Name" AS "Class",
       c."Archetype", count(h."Hero_id") AS "Heroes"
FROM heroes_watch."HeroClass" c
JOIN heroes_watch."Game" g ON g."Game_id" = c."Game_id"
LEFT JOIN affiliation a ON a."HeroClass_id" = c."HeroClass_id"
LEFT JOIN heroes_watch."Faction" f ON f."Faction_id" = a."Faction_id"
LEFT JOIN heroes_watch."Hero" h ON h."HeroClass_id" = c."HeroClass_id"
GROUP BY g."DisplayOrder", g."SeriesCode", f."Name", c."HeroClass_id", c."Name", c."Archetype"
ORDER BY g."DisplayOrder", f."Name", c."Name";

-- Expand this result in pgAdmin to inspect named heroes and release provenance.
SELECT g."SeriesCode" AS "Game", h."Name" AS "Hero", c."Name" AS "Class",
       e."Name" AS "Introduced in", h."Description"
FROM heroes_watch."Hero" h
JOIN heroes_watch."Game" g ON g."Game_id" = h."Game_id"
LEFT JOIN heroes_watch."HeroClass" c ON c."HeroClass_id" = h."HeroClass_id"
LEFT JOIN heroes_watch."Expansion" e ON e."Expansion_id" = h."IntroducedInExpansion_id"
ORDER BY g."DisplayOrder", h."Name";

WITH affiliation AS (
    SELECT "Building_id", "Faction_id" FROM heroes_watch."BuildingHOMM1"
    UNION ALL SELECT "Building_id", "Faction_id" FROM heroes_watch."BuildingHOMM2"
    UNION ALL SELECT "Building_id", "Faction_id" FROM heroes_watch."BuildingHOMM3"
    UNION ALL SELECT "Building_id", "Faction_id" FROM heroes_watch."BuildingHOMM4"
    UNION ALL SELECT "Building_id", "Faction_id" FROM heroes_watch."BuildingHOMM5"
    UNION ALL SELECT "Building_id", "Faction_id" FROM heroes_watch."BuildingHOMM6"
    UNION ALL SELECT "Building_id", "Faction_id" FROM heroes_watch."BuildingHOMM7"
    UNION ALL SELECT "Building_id", "Faction_id" FROM heroes_watch."BuildingHOMM8"
)
SELECT g."SeriesCode" AS "Game", f."Name" AS "Faction", b."Name" AS "Building",
       b."Category", e."Name" AS "Introduced in"
FROM heroes_watch."Building" b
JOIN heroes_watch."Game" g ON g."Game_id" = b."Game_id"
LEFT JOIN affiliation a ON a."Building_id" = b."Building_id"
LEFT JOIN heroes_watch."Faction" f ON f."Faction_id" = a."Faction_id"
LEFT JOIN heroes_watch."Expansion" e ON e."Expansion_id" = b."IntroducedInExpansion_id"
ORDER BY g."DisplayOrder", f."Name", b."Category", b."Name";

SELECT g."SeriesCode" AS "Game", o."Name" AS "Map object", e."Name" AS "Introduced in",
       o."Description"
FROM heroes_watch."AdventureObject" o
JOIN heroes_watch."Game" g ON g."Game_id" = o."Game_id"
LEFT JOIN heroes_watch."Expansion" e ON e."Expansion_id" = o."IntroducedInExpansion_id"
ORDER BY g."DisplayOrder", o."Name";

-- Heroes III spells with actual many-to-many school membership.
SELECT s."Name", d."Level", d."Context", d."ManaCost", d."ExpertManaCost",
       string_agg(m."Name", ', ' ORDER BY m."Name") AS "Schools",
       d."BasicEffect", d."AdvancedEffect", d."ExpertEffect"
FROM heroes_watch."Spell" s
JOIN heroes_watch."SpellHOMM3" d ON d."Spell_id" = s."Spell_id"
JOIN heroes_watch."SpellMagicSchool" sm ON sm."Spell_id" = s."Spell_id"
JOIN heroes_watch."MagicSchool" m ON m."MagicSchool_id" = sm."MagicSchool_id"
GROUP BY s."Spell_id", s."Name", d."Spell_id", d."Level", d."Context", d."ManaCost",
         d."ExpertManaCost", d."BasicEffect", d."AdvancedEffect", d."ExpertEffect"
ORDER BY d."Level", s."Name";

-- Combination artifacts use component FKs rather than JSON name arrays.
SELECT a."Name" AS "Combination artifact",
       string_agg(part."Name", ', ' ORDER BY part."Name") AS "Components"
FROM heroes_watch."ArtifactComponent" ac
JOIN heroes_watch."Artifact" a ON a."Artifact_id" = ac."CompositeArtifact_id"
JOIN heroes_watch."Artifact" part ON part."Artifact_id" = ac."ComponentArtifact_id"
JOIN heroes_watch."Game" g ON g."Game_id" = ac."Game_id"
WHERE g."SeriesCode" = 'HOMM3'
GROUP BY a."Artifact_id", a."Name"
ORDER BY a."Name";

SELECT e."Name" AS "Release", c."Name" AS "Campaign"
FROM heroes_watch."Campaign" c
JOIN heroes_watch."Expansion" e ON e."Expansion_id" = c."Expansion_id"
JOIN heroes_watch."Game" g ON g."Game_id" = c."Game_id"
WHERE g."SeriesCode" = 'HOMM3'
ORDER BY e."Code", c."Name";
