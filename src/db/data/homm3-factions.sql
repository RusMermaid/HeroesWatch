-- Content batch from data/heroeswatch.json; see homm3-factions.sources.md.
-- Run in the existing HeroesWatch database after reviewing the JSON batch.
-- Inserts missing rows, reuses physical IDs, fills missing sourced values,
-- and aborts on conflicting non-null facts. Other content is preserved.
-- Run this complete script in a fresh query session; do not select fragments.

BEGIN;
SET LOCAL lock_timeout = '5s';
SET LOCAL statement_timeout = '60s';

DO $faction_batch$
DECLARE
    v_game_0 BIGINT;
    v_expansion_0 BIGINT;
    v_expansion_1 BIGINT;
    v_expansion_2 BIGINT;
    v_terrain_0 BIGINT;
    v_terrain_1 BIGINT;
    v_terrain_2 BIGINT;
    v_terrain_3 BIGINT;
    v_terrain_4 BIGINT;
    v_terrain_5 BIGINT;
    v_terrain_6 BIGINT;
    v_faction_0 BIGINT;
    v_faction_1 BIGINT;
    v_faction_2 BIGINT;
    v_faction_3 BIGINT;
    v_faction_4 BIGINT;
    v_faction_5 BIGINT;
    v_faction_6 BIGINT;
    v_faction_7 BIGINT;
    v_faction_8 BIGINT;
BEGIN
    -- homm3.game
    INSERT INTO heroes_watch."Game" AS existing
        ("SeriesCode", "DisplayOrder", "Name", "ReleaseDate", "Description")
    VALUES ('HOMM3', 3, 'Heroes of Might and Magic III', NULL, NULL)
    ON CONFLICT ("SeriesCode") DO NOTHING;

    SELECT "Game_id" INTO STRICT v_game_0
    FROM heroes_watch."Game"
    WHERE "SeriesCode" = 'HOMM3'
    FOR UPDATE;

    IF NOT EXISTS (
        SELECT 1 FROM heroes_watch."Game"
        WHERE "Game_id" = v_game_0
          AND "SeriesCode" IS NOT DISTINCT FROM 'HOMM3'
          AND "DisplayOrder" IS NOT DISTINCT FROM 3
          AND "Name" IS NOT DISTINCT FROM 'Heroes of Might and Magic III'
    ) THEN
        RAISE EXCEPTION 'Existing Game conflicts with homm3.game; batch rolled back. Review before retrying.';
    END IF;

    -- homm3.expansion.roe
    INSERT INTO heroes_watch."Expansion" AS existing
        ("Game_id", "Code", "Name", "Kind", "ReleaseDate", "Description")
    VALUES (v_game_0, 'ROE', 'The Restoration of Erathia', 'BaseGame', NULL, NULL)
    ON CONFLICT ("Game_id", "Code") DO NOTHING;

    SELECT "Expansion_id" INTO STRICT v_expansion_0
    FROM heroes_watch."Expansion"
    WHERE "Game_id" = v_game_0 AND "Code" = 'ROE'
    FOR UPDATE;

    IF NOT EXISTS (
        SELECT 1 FROM heroes_watch."Expansion"
        WHERE "Expansion_id" = v_expansion_0
          AND "Game_id" IS NOT DISTINCT FROM v_game_0
          AND "Code" IS NOT DISTINCT FROM 'ROE'
          AND "Name" IS NOT DISTINCT FROM 'The Restoration of Erathia'
          AND "Kind" IS NOT DISTINCT FROM 'BaseGame'
    ) THEN
        RAISE EXCEPTION 'Existing Expansion conflicts with homm3.expansion.roe; batch rolled back. Review before retrying.';
    END IF;

    -- homm3.expansion.ab
    INSERT INTO heroes_watch."Expansion" AS existing
        ("Game_id", "Code", "Name", "Kind", "ReleaseDate", "Description")
    VALUES (v_game_0, 'AB', 'Armageddon''s Blade', 'Expansion', NULL, NULL)
    ON CONFLICT ("Game_id", "Code") DO NOTHING;

    SELECT "Expansion_id" INTO STRICT v_expansion_1
    FROM heroes_watch."Expansion"
    WHERE "Game_id" = v_game_0 AND "Code" = 'AB'
    FOR UPDATE;

    IF NOT EXISTS (
        SELECT 1 FROM heroes_watch."Expansion"
        WHERE "Expansion_id" = v_expansion_1
          AND "Game_id" IS NOT DISTINCT FROM v_game_0
          AND "Code" IS NOT DISTINCT FROM 'AB'
          AND "Name" IS NOT DISTINCT FROM 'Armageddon''s Blade'
          AND "Kind" IS NOT DISTINCT FROM 'Expansion'
    ) THEN
        RAISE EXCEPTION 'Existing Expansion conflicts with homm3.expansion.ab; batch rolled back. Review before retrying.';
    END IF;

    -- homm3.expansion.sod
    INSERT INTO heroes_watch."Expansion" AS existing
        ("Game_id", "Code", "Name", "Kind", "ReleaseDate", "Description")
    VALUES (v_game_0, 'SOD', 'The Shadow of Death', 'Expansion', NULL, NULL)
    ON CONFLICT ("Game_id", "Code") DO NOTHING;

    SELECT "Expansion_id" INTO STRICT v_expansion_2
    FROM heroes_watch."Expansion"
    WHERE "Game_id" = v_game_0 AND "Code" = 'SOD'
    FOR UPDATE;

    IF NOT EXISTS (
        SELECT 1 FROM heroes_watch."Expansion"
        WHERE "Expansion_id" = v_expansion_2
          AND "Game_id" IS NOT DISTINCT FROM v_game_0
          AND "Code" IS NOT DISTINCT FROM 'SOD'
          AND "Name" IS NOT DISTINCT FROM 'The Shadow of Death'
          AND "Kind" IS NOT DISTINCT FROM 'Expansion'
    ) THEN
        RAISE EXCEPTION 'Existing Expansion conflicts with homm3.expansion.sod; batch rolled back. Review before retrying.';
    END IF;

    -- homm3.terrain.grass
    INSERT INTO heroes_watch."Terrain" AS existing
        ("Game_id", "Code", "Name", "Kind", "Description", "IntroducedInExpansion_id", "MediaAsset_id")
    VALUES (v_game_0, 'GRASS', 'Grass', 'Basic', NULL, v_expansion_0, NULL)
    ON CONFLICT ("Game_id", "Code") DO UPDATE SET
        "IntroducedInExpansion_id" = COALESCE(existing."IntroducedInExpansion_id", EXCLUDED."IntroducedInExpansion_id");

    SELECT "Terrain_id" INTO STRICT v_terrain_0
    FROM heroes_watch."Terrain"
    WHERE "Game_id" = v_game_0 AND "Code" = 'GRASS'
    FOR UPDATE;

    IF NOT EXISTS (
        SELECT 1 FROM heroes_watch."Terrain"
        WHERE "Terrain_id" = v_terrain_0
          AND "Game_id" IS NOT DISTINCT FROM v_game_0
          AND "Code" IS NOT DISTINCT FROM 'GRASS'
          AND "Name" IS NOT DISTINCT FROM 'Grass'
          AND "Kind" IS NOT DISTINCT FROM 'Basic'
          AND "IntroducedInExpansion_id" IS NOT DISTINCT FROM v_expansion_0
    ) THEN
        RAISE EXCEPTION 'Existing Terrain conflicts with homm3.terrain.grass; batch rolled back. Review before retrying.';
    END IF;

    -- homm3.terrain.snow
    INSERT INTO heroes_watch."Terrain" AS existing
        ("Game_id", "Code", "Name", "Kind", "Description", "IntroducedInExpansion_id", "MediaAsset_id")
    VALUES (v_game_0, 'SNOW', 'Snow', 'Basic', NULL, v_expansion_0, NULL)
    ON CONFLICT ("Game_id", "Code") DO UPDATE SET
        "IntroducedInExpansion_id" = COALESCE(existing."IntroducedInExpansion_id", EXCLUDED."IntroducedInExpansion_id");

    SELECT "Terrain_id" INTO STRICT v_terrain_1
    FROM heroes_watch."Terrain"
    WHERE "Game_id" = v_game_0 AND "Code" = 'SNOW'
    FOR UPDATE;

    IF NOT EXISTS (
        SELECT 1 FROM heroes_watch."Terrain"
        WHERE "Terrain_id" = v_terrain_1
          AND "Game_id" IS NOT DISTINCT FROM v_game_0
          AND "Code" IS NOT DISTINCT FROM 'SNOW'
          AND "Name" IS NOT DISTINCT FROM 'Snow'
          AND "Kind" IS NOT DISTINCT FROM 'Basic'
          AND "IntroducedInExpansion_id" IS NOT DISTINCT FROM v_expansion_0
    ) THEN
        RAISE EXCEPTION 'Existing Terrain conflicts with homm3.terrain.snow; batch rolled back. Review before retrying.';
    END IF;

    -- homm3.terrain.lava
    INSERT INTO heroes_watch."Terrain" AS existing
        ("Game_id", "Code", "Name", "Kind", "Description", "IntroducedInExpansion_id", "MediaAsset_id")
    VALUES (v_game_0, 'LAVA', 'Lava', 'Basic', NULL, v_expansion_0, NULL)
    ON CONFLICT ("Game_id", "Code") DO UPDATE SET
        "IntroducedInExpansion_id" = COALESCE(existing."IntroducedInExpansion_id", EXCLUDED."IntroducedInExpansion_id");

    SELECT "Terrain_id" INTO STRICT v_terrain_2
    FROM heroes_watch."Terrain"
    WHERE "Game_id" = v_game_0 AND "Code" = 'LAVA'
    FOR UPDATE;

    IF NOT EXISTS (
        SELECT 1 FROM heroes_watch."Terrain"
        WHERE "Terrain_id" = v_terrain_2
          AND "Game_id" IS NOT DISTINCT FROM v_game_0
          AND "Code" IS NOT DISTINCT FROM 'LAVA'
          AND "Name" IS NOT DISTINCT FROM 'Lava'
          AND "Kind" IS NOT DISTINCT FROM 'Basic'
          AND "IntroducedInExpansion_id" IS NOT DISTINCT FROM v_expansion_0
    ) THEN
        RAISE EXCEPTION 'Existing Terrain conflicts with homm3.terrain.lava; batch rolled back. Review before retrying.';
    END IF;

    -- homm3.terrain.dirt
    INSERT INTO heroes_watch."Terrain" AS existing
        ("Game_id", "Code", "Name", "Kind", "Description", "IntroducedInExpansion_id", "MediaAsset_id")
    VALUES (v_game_0, 'DIRT', 'Dirt', 'Basic', NULL, v_expansion_0, NULL)
    ON CONFLICT ("Game_id", "Code") DO UPDATE SET
        "IntroducedInExpansion_id" = COALESCE(existing."IntroducedInExpansion_id", EXCLUDED."IntroducedInExpansion_id");

    SELECT "Terrain_id" INTO STRICT v_terrain_3
    FROM heroes_watch."Terrain"
    WHERE "Game_id" = v_game_0 AND "Code" = 'DIRT'
    FOR UPDATE;

    IF NOT EXISTS (
        SELECT 1 FROM heroes_watch."Terrain"
        WHERE "Terrain_id" = v_terrain_3
          AND "Game_id" IS NOT DISTINCT FROM v_game_0
          AND "Code" IS NOT DISTINCT FROM 'DIRT'
          AND "Name" IS NOT DISTINCT FROM 'Dirt'
          AND "Kind" IS NOT DISTINCT FROM 'Basic'
          AND "IntroducedInExpansion_id" IS NOT DISTINCT FROM v_expansion_0
    ) THEN
        RAISE EXCEPTION 'Existing Terrain conflicts with homm3.terrain.dirt; batch rolled back. Review before retrying.';
    END IF;

    -- homm3.terrain.subterranean
    INSERT INTO heroes_watch."Terrain" AS existing
        ("Game_id", "Code", "Name", "Kind", "Description", "IntroducedInExpansion_id", "MediaAsset_id")
    VALUES (v_game_0, 'SUBTERRANEAN', 'Subterranean', 'Basic', NULL, v_expansion_0, NULL)
    ON CONFLICT ("Game_id", "Code") DO UPDATE SET
        "IntroducedInExpansion_id" = COALESCE(existing."IntroducedInExpansion_id", EXCLUDED."IntroducedInExpansion_id");

    SELECT "Terrain_id" INTO STRICT v_terrain_4
    FROM heroes_watch."Terrain"
    WHERE "Game_id" = v_game_0 AND "Code" = 'SUBTERRANEAN'
    FOR UPDATE;

    IF NOT EXISTS (
        SELECT 1 FROM heroes_watch."Terrain"
        WHERE "Terrain_id" = v_terrain_4
          AND "Game_id" IS NOT DISTINCT FROM v_game_0
          AND "Code" IS NOT DISTINCT FROM 'SUBTERRANEAN'
          AND "Name" IS NOT DISTINCT FROM 'Subterranean'
          AND "Kind" IS NOT DISTINCT FROM 'Basic'
          AND "IntroducedInExpansion_id" IS NOT DISTINCT FROM v_expansion_0
    ) THEN
        RAISE EXCEPTION 'Existing Terrain conflicts with homm3.terrain.subterranean; batch rolled back. Review before retrying.';
    END IF;

    -- homm3.terrain.rough
    INSERT INTO heroes_watch."Terrain" AS existing
        ("Game_id", "Code", "Name", "Kind", "Description", "IntroducedInExpansion_id", "MediaAsset_id")
    VALUES (v_game_0, 'ROUGH', 'Rough', 'Basic', NULL, v_expansion_0, NULL)
    ON CONFLICT ("Game_id", "Code") DO UPDATE SET
        "IntroducedInExpansion_id" = COALESCE(existing."IntroducedInExpansion_id", EXCLUDED."IntroducedInExpansion_id");

    SELECT "Terrain_id" INTO STRICT v_terrain_5
    FROM heroes_watch."Terrain"
    WHERE "Game_id" = v_game_0 AND "Code" = 'ROUGH'
    FOR UPDATE;

    IF NOT EXISTS (
        SELECT 1 FROM heroes_watch."Terrain"
        WHERE "Terrain_id" = v_terrain_5
          AND "Game_id" IS NOT DISTINCT FROM v_game_0
          AND "Code" IS NOT DISTINCT FROM 'ROUGH'
          AND "Name" IS NOT DISTINCT FROM 'Rough'
          AND "Kind" IS NOT DISTINCT FROM 'Basic'
          AND "IntroducedInExpansion_id" IS NOT DISTINCT FROM v_expansion_0
    ) THEN
        RAISE EXCEPTION 'Existing Terrain conflicts with homm3.terrain.rough; batch rolled back. Review before retrying.';
    END IF;

    -- homm3.terrain.swamp
    INSERT INTO heroes_watch."Terrain" AS existing
        ("Game_id", "Code", "Name", "Kind", "Description", "IntroducedInExpansion_id", "MediaAsset_id")
    VALUES (v_game_0, 'SWAMP', 'Swamp', 'Basic', NULL, v_expansion_0, NULL)
    ON CONFLICT ("Game_id", "Code") DO UPDATE SET
        "IntroducedInExpansion_id" = COALESCE(existing."IntroducedInExpansion_id", EXCLUDED."IntroducedInExpansion_id");

    SELECT "Terrain_id" INTO STRICT v_terrain_6
    FROM heroes_watch."Terrain"
    WHERE "Game_id" = v_game_0 AND "Code" = 'SWAMP'
    FOR UPDATE;

    IF NOT EXISTS (
        SELECT 1 FROM heroes_watch."Terrain"
        WHERE "Terrain_id" = v_terrain_6
          AND "Game_id" IS NOT DISTINCT FROM v_game_0
          AND "Code" IS NOT DISTINCT FROM 'SWAMP'
          AND "Name" IS NOT DISTINCT FROM 'Swamp'
          AND "Kind" IS NOT DISTINCT FROM 'Basic'
          AND "IntroducedInExpansion_id" IS NOT DISTINCT FROM v_expansion_0
    ) THEN
        RAISE EXCEPTION 'Existing Terrain conflicts with homm3.terrain.swamp; batch rolled back. Review before retrying.';
    END IF;

    -- homm3.faction.castle
    INSERT INTO heroes_watch."Faction" AS existing
        ("Game_id", "Code", "Name", "Description", "IntroducedInExpansion_id", "MediaAsset_id")
    VALUES (v_game_0, 'CASTLE', 'Castle', NULL, v_expansion_0, NULL)
    ON CONFLICT ("Game_id", "Code") DO UPDATE SET
        "IntroducedInExpansion_id" = COALESCE(existing."IntroducedInExpansion_id", EXCLUDED."IntroducedInExpansion_id");

    SELECT "Faction_id" INTO STRICT v_faction_0
    FROM heroes_watch."Faction"
    WHERE "Game_id" = v_game_0 AND "Code" = 'CASTLE'
    FOR UPDATE;

    IF NOT EXISTS (
        SELECT 1 FROM heroes_watch."Faction"
        WHERE "Faction_id" = v_faction_0
          AND "Game_id" IS NOT DISTINCT FROM v_game_0
          AND "Code" IS NOT DISTINCT FROM 'CASTLE'
          AND "Name" IS NOT DISTINCT FROM 'Castle'
          AND "IntroducedInExpansion_id" IS NOT DISTINCT FROM v_expansion_0
    ) THEN
        RAISE EXCEPTION 'Existing Faction conflicts with homm3.faction.castle; batch rolled back. Review before retrying.';
    END IF;

    -- homm3.faction.rampart
    INSERT INTO heroes_watch."Faction" AS existing
        ("Game_id", "Code", "Name", "Description", "IntroducedInExpansion_id", "MediaAsset_id")
    VALUES (v_game_0, 'RAMPART', 'Rampart', NULL, v_expansion_0, NULL)
    ON CONFLICT ("Game_id", "Code") DO UPDATE SET
        "IntroducedInExpansion_id" = COALESCE(existing."IntroducedInExpansion_id", EXCLUDED."IntroducedInExpansion_id");

    SELECT "Faction_id" INTO STRICT v_faction_1
    FROM heroes_watch."Faction"
    WHERE "Game_id" = v_game_0 AND "Code" = 'RAMPART'
    FOR UPDATE;

    IF NOT EXISTS (
        SELECT 1 FROM heroes_watch."Faction"
        WHERE "Faction_id" = v_faction_1
          AND "Game_id" IS NOT DISTINCT FROM v_game_0
          AND "Code" IS NOT DISTINCT FROM 'RAMPART'
          AND "Name" IS NOT DISTINCT FROM 'Rampart'
          AND "IntroducedInExpansion_id" IS NOT DISTINCT FROM v_expansion_0
    ) THEN
        RAISE EXCEPTION 'Existing Faction conflicts with homm3.faction.rampart; batch rolled back. Review before retrying.';
    END IF;

    -- homm3.faction.tower
    INSERT INTO heroes_watch."Faction" AS existing
        ("Game_id", "Code", "Name", "Description", "IntroducedInExpansion_id", "MediaAsset_id")
    VALUES (v_game_0, 'TOWER', 'Tower', NULL, v_expansion_0, NULL)
    ON CONFLICT ("Game_id", "Code") DO UPDATE SET
        "IntroducedInExpansion_id" = COALESCE(existing."IntroducedInExpansion_id", EXCLUDED."IntroducedInExpansion_id");

    SELECT "Faction_id" INTO STRICT v_faction_2
    FROM heroes_watch."Faction"
    WHERE "Game_id" = v_game_0 AND "Code" = 'TOWER'
    FOR UPDATE;

    IF NOT EXISTS (
        SELECT 1 FROM heroes_watch."Faction"
        WHERE "Faction_id" = v_faction_2
          AND "Game_id" IS NOT DISTINCT FROM v_game_0
          AND "Code" IS NOT DISTINCT FROM 'TOWER'
          AND "Name" IS NOT DISTINCT FROM 'Tower'
          AND "IntroducedInExpansion_id" IS NOT DISTINCT FROM v_expansion_0
    ) THEN
        RAISE EXCEPTION 'Existing Faction conflicts with homm3.faction.tower; batch rolled back. Review before retrying.';
    END IF;

    -- homm3.faction.inferno
    INSERT INTO heroes_watch."Faction" AS existing
        ("Game_id", "Code", "Name", "Description", "IntroducedInExpansion_id", "MediaAsset_id")
    VALUES (v_game_0, 'INFERNO', 'Inferno', NULL, v_expansion_0, NULL)
    ON CONFLICT ("Game_id", "Code") DO UPDATE SET
        "IntroducedInExpansion_id" = COALESCE(existing."IntroducedInExpansion_id", EXCLUDED."IntroducedInExpansion_id");

    SELECT "Faction_id" INTO STRICT v_faction_3
    FROM heroes_watch."Faction"
    WHERE "Game_id" = v_game_0 AND "Code" = 'INFERNO'
    FOR UPDATE;

    IF NOT EXISTS (
        SELECT 1 FROM heroes_watch."Faction"
        WHERE "Faction_id" = v_faction_3
          AND "Game_id" IS NOT DISTINCT FROM v_game_0
          AND "Code" IS NOT DISTINCT FROM 'INFERNO'
          AND "Name" IS NOT DISTINCT FROM 'Inferno'
          AND "IntroducedInExpansion_id" IS NOT DISTINCT FROM v_expansion_0
    ) THEN
        RAISE EXCEPTION 'Existing Faction conflicts with homm3.faction.inferno; batch rolled back. Review before retrying.';
    END IF;

    -- homm3.faction.necropolis
    INSERT INTO heroes_watch."Faction" AS existing
        ("Game_id", "Code", "Name", "Description", "IntroducedInExpansion_id", "MediaAsset_id")
    VALUES (v_game_0, 'NECROPOLIS', 'Necropolis', NULL, v_expansion_0, NULL)
    ON CONFLICT ("Game_id", "Code") DO UPDATE SET
        "IntroducedInExpansion_id" = COALESCE(existing."IntroducedInExpansion_id", EXCLUDED."IntroducedInExpansion_id");

    SELECT "Faction_id" INTO STRICT v_faction_4
    FROM heroes_watch."Faction"
    WHERE "Game_id" = v_game_0 AND "Code" = 'NECROPOLIS'
    FOR UPDATE;

    IF NOT EXISTS (
        SELECT 1 FROM heroes_watch."Faction"
        WHERE "Faction_id" = v_faction_4
          AND "Game_id" IS NOT DISTINCT FROM v_game_0
          AND "Code" IS NOT DISTINCT FROM 'NECROPOLIS'
          AND "Name" IS NOT DISTINCT FROM 'Necropolis'
          AND "IntroducedInExpansion_id" IS NOT DISTINCT FROM v_expansion_0
    ) THEN
        RAISE EXCEPTION 'Existing Faction conflicts with homm3.faction.necropolis; batch rolled back. Review before retrying.';
    END IF;

    -- homm3.faction.dungeon
    INSERT INTO heroes_watch."Faction" AS existing
        ("Game_id", "Code", "Name", "Description", "IntroducedInExpansion_id", "MediaAsset_id")
    VALUES (v_game_0, 'DUNGEON', 'Dungeon', NULL, v_expansion_0, NULL)
    ON CONFLICT ("Game_id", "Code") DO UPDATE SET
        "IntroducedInExpansion_id" = COALESCE(existing."IntroducedInExpansion_id", EXCLUDED."IntroducedInExpansion_id");

    SELECT "Faction_id" INTO STRICT v_faction_5
    FROM heroes_watch."Faction"
    WHERE "Game_id" = v_game_0 AND "Code" = 'DUNGEON'
    FOR UPDATE;

    IF NOT EXISTS (
        SELECT 1 FROM heroes_watch."Faction"
        WHERE "Faction_id" = v_faction_5
          AND "Game_id" IS NOT DISTINCT FROM v_game_0
          AND "Code" IS NOT DISTINCT FROM 'DUNGEON'
          AND "Name" IS NOT DISTINCT FROM 'Dungeon'
          AND "IntroducedInExpansion_id" IS NOT DISTINCT FROM v_expansion_0
    ) THEN
        RAISE EXCEPTION 'Existing Faction conflicts with homm3.faction.dungeon; batch rolled back. Review before retrying.';
    END IF;

    -- homm3.faction.stronghold
    INSERT INTO heroes_watch."Faction" AS existing
        ("Game_id", "Code", "Name", "Description", "IntroducedInExpansion_id", "MediaAsset_id")
    VALUES (v_game_0, 'STRONGHOLD', 'Stronghold', NULL, v_expansion_0, NULL)
    ON CONFLICT ("Game_id", "Code") DO UPDATE SET
        "IntroducedInExpansion_id" = COALESCE(existing."IntroducedInExpansion_id", EXCLUDED."IntroducedInExpansion_id");

    SELECT "Faction_id" INTO STRICT v_faction_6
    FROM heroes_watch."Faction"
    WHERE "Game_id" = v_game_0 AND "Code" = 'STRONGHOLD'
    FOR UPDATE;

    IF NOT EXISTS (
        SELECT 1 FROM heroes_watch."Faction"
        WHERE "Faction_id" = v_faction_6
          AND "Game_id" IS NOT DISTINCT FROM v_game_0
          AND "Code" IS NOT DISTINCT FROM 'STRONGHOLD'
          AND "Name" IS NOT DISTINCT FROM 'Stronghold'
          AND "IntroducedInExpansion_id" IS NOT DISTINCT FROM v_expansion_0
    ) THEN
        RAISE EXCEPTION 'Existing Faction conflicts with homm3.faction.stronghold; batch rolled back. Review before retrying.';
    END IF;

    -- homm3.faction.fortress
    INSERT INTO heroes_watch."Faction" AS existing
        ("Game_id", "Code", "Name", "Description", "IntroducedInExpansion_id", "MediaAsset_id")
    VALUES (v_game_0, 'FORTRESS', 'Fortress', NULL, v_expansion_0, NULL)
    ON CONFLICT ("Game_id", "Code") DO UPDATE SET
        "IntroducedInExpansion_id" = COALESCE(existing."IntroducedInExpansion_id", EXCLUDED."IntroducedInExpansion_id");

    SELECT "Faction_id" INTO STRICT v_faction_7
    FROM heroes_watch."Faction"
    WHERE "Game_id" = v_game_0 AND "Code" = 'FORTRESS'
    FOR UPDATE;

    IF NOT EXISTS (
        SELECT 1 FROM heroes_watch."Faction"
        WHERE "Faction_id" = v_faction_7
          AND "Game_id" IS NOT DISTINCT FROM v_game_0
          AND "Code" IS NOT DISTINCT FROM 'FORTRESS'
          AND "Name" IS NOT DISTINCT FROM 'Fortress'
          AND "IntroducedInExpansion_id" IS NOT DISTINCT FROM v_expansion_0
    ) THEN
        RAISE EXCEPTION 'Existing Faction conflicts with homm3.faction.fortress; batch rolled back. Review before retrying.';
    END IF;

    -- homm3.faction.conflux
    INSERT INTO heroes_watch."Faction" AS existing
        ("Game_id", "Code", "Name", "Description", "IntroducedInExpansion_id", "MediaAsset_id")
    VALUES (v_game_0, 'CONFLUX', 'Conflux', NULL, v_expansion_1, NULL)
    ON CONFLICT ("Game_id", "Code") DO UPDATE SET
        "IntroducedInExpansion_id" = COALESCE(existing."IntroducedInExpansion_id", EXCLUDED."IntroducedInExpansion_id");

    SELECT "Faction_id" INTO STRICT v_faction_8
    FROM heroes_watch."Faction"
    WHERE "Game_id" = v_game_0 AND "Code" = 'CONFLUX'
    FOR UPDATE;

    IF NOT EXISTS (
        SELECT 1 FROM heroes_watch."Faction"
        WHERE "Faction_id" = v_faction_8
          AND "Game_id" IS NOT DISTINCT FROM v_game_0
          AND "Code" IS NOT DISTINCT FROM 'CONFLUX'
          AND "Name" IS NOT DISTINCT FROM 'Conflux'
          AND "IntroducedInExpansion_id" IS NOT DISTINCT FROM v_expansion_1
    ) THEN
        RAISE EXCEPTION 'Existing Faction conflicts with homm3.faction.conflux; batch rolled back. Review before retrying.';
    END IF;

    -- homm3.faction.castle (shared primary key)
    INSERT INTO heroes_watch."FactionHOMM3" AS existing
        ("Faction_id", "Alignment", "NativeTerrain_id")
    VALUES (v_faction_0, 'Good', v_terrain_0)
    ON CONFLICT ("Faction_id") DO UPDATE SET
        "Alignment" = COALESCE(existing."Alignment", EXCLUDED."Alignment"),
        "NativeTerrain_id" = COALESCE(existing."NativeTerrain_id", EXCLUDED."NativeTerrain_id");

    IF NOT EXISTS (
        SELECT 1 FROM heroes_watch."FactionHOMM3"
        WHERE "Faction_id" = v_faction_0
          AND "Faction_id" IS NOT DISTINCT FROM v_faction_0
          AND "Alignment" IS NOT DISTINCT FROM 'Good'
          AND "NativeTerrain_id" IS NOT DISTINCT FROM v_terrain_0
    ) THEN
        RAISE EXCEPTION 'Existing FactionHOMM3 conflicts with homm3.faction.castle; batch rolled back. Review before retrying.';
    END IF;

    -- homm3.faction.rampart (shared primary key)
    INSERT INTO heroes_watch."FactionHOMM3" AS existing
        ("Faction_id", "Alignment", "NativeTerrain_id")
    VALUES (v_faction_1, 'Good', v_terrain_0)
    ON CONFLICT ("Faction_id") DO UPDATE SET
        "Alignment" = COALESCE(existing."Alignment", EXCLUDED."Alignment"),
        "NativeTerrain_id" = COALESCE(existing."NativeTerrain_id", EXCLUDED."NativeTerrain_id");

    IF NOT EXISTS (
        SELECT 1 FROM heroes_watch."FactionHOMM3"
        WHERE "Faction_id" = v_faction_1
          AND "Faction_id" IS NOT DISTINCT FROM v_faction_1
          AND "Alignment" IS NOT DISTINCT FROM 'Good'
          AND "NativeTerrain_id" IS NOT DISTINCT FROM v_terrain_0
    ) THEN
        RAISE EXCEPTION 'Existing FactionHOMM3 conflicts with homm3.faction.rampart; batch rolled back. Review before retrying.';
    END IF;

    -- homm3.faction.tower (shared primary key)
    INSERT INTO heroes_watch."FactionHOMM3" AS existing
        ("Faction_id", "Alignment", "NativeTerrain_id")
    VALUES (v_faction_2, 'Good', v_terrain_1)
    ON CONFLICT ("Faction_id") DO UPDATE SET
        "Alignment" = COALESCE(existing."Alignment", EXCLUDED."Alignment"),
        "NativeTerrain_id" = COALESCE(existing."NativeTerrain_id", EXCLUDED."NativeTerrain_id");

    IF NOT EXISTS (
        SELECT 1 FROM heroes_watch."FactionHOMM3"
        WHERE "Faction_id" = v_faction_2
          AND "Faction_id" IS NOT DISTINCT FROM v_faction_2
          AND "Alignment" IS NOT DISTINCT FROM 'Good'
          AND "NativeTerrain_id" IS NOT DISTINCT FROM v_terrain_1
    ) THEN
        RAISE EXCEPTION 'Existing FactionHOMM3 conflicts with homm3.faction.tower; batch rolled back. Review before retrying.';
    END IF;

    -- homm3.faction.inferno (shared primary key)
    INSERT INTO heroes_watch."FactionHOMM3" AS existing
        ("Faction_id", "Alignment", "NativeTerrain_id")
    VALUES (v_faction_3, 'Evil', v_terrain_2)
    ON CONFLICT ("Faction_id") DO UPDATE SET
        "Alignment" = COALESCE(existing."Alignment", EXCLUDED."Alignment"),
        "NativeTerrain_id" = COALESCE(existing."NativeTerrain_id", EXCLUDED."NativeTerrain_id");

    IF NOT EXISTS (
        SELECT 1 FROM heroes_watch."FactionHOMM3"
        WHERE "Faction_id" = v_faction_3
          AND "Faction_id" IS NOT DISTINCT FROM v_faction_3
          AND "Alignment" IS NOT DISTINCT FROM 'Evil'
          AND "NativeTerrain_id" IS NOT DISTINCT FROM v_terrain_2
    ) THEN
        RAISE EXCEPTION 'Existing FactionHOMM3 conflicts with homm3.faction.inferno; batch rolled back. Review before retrying.';
    END IF;

    -- homm3.faction.necropolis (shared primary key)
    INSERT INTO heroes_watch."FactionHOMM3" AS existing
        ("Faction_id", "Alignment", "NativeTerrain_id")
    VALUES (v_faction_4, 'Evil', v_terrain_3)
    ON CONFLICT ("Faction_id") DO UPDATE SET
        "Alignment" = COALESCE(existing."Alignment", EXCLUDED."Alignment"),
        "NativeTerrain_id" = COALESCE(existing."NativeTerrain_id", EXCLUDED."NativeTerrain_id");

    IF NOT EXISTS (
        SELECT 1 FROM heroes_watch."FactionHOMM3"
        WHERE "Faction_id" = v_faction_4
          AND "Faction_id" IS NOT DISTINCT FROM v_faction_4
          AND "Alignment" IS NOT DISTINCT FROM 'Evil'
          AND "NativeTerrain_id" IS NOT DISTINCT FROM v_terrain_3
    ) THEN
        RAISE EXCEPTION 'Existing FactionHOMM3 conflicts with homm3.faction.necropolis; batch rolled back. Review before retrying.';
    END IF;

    -- homm3.faction.dungeon (shared primary key)
    INSERT INTO heroes_watch."FactionHOMM3" AS existing
        ("Faction_id", "Alignment", "NativeTerrain_id")
    VALUES (v_faction_5, 'Evil', v_terrain_4)
    ON CONFLICT ("Faction_id") DO UPDATE SET
        "Alignment" = COALESCE(existing."Alignment", EXCLUDED."Alignment"),
        "NativeTerrain_id" = COALESCE(existing."NativeTerrain_id", EXCLUDED."NativeTerrain_id");

    IF NOT EXISTS (
        SELECT 1 FROM heroes_watch."FactionHOMM3"
        WHERE "Faction_id" = v_faction_5
          AND "Faction_id" IS NOT DISTINCT FROM v_faction_5
          AND "Alignment" IS NOT DISTINCT FROM 'Evil'
          AND "NativeTerrain_id" IS NOT DISTINCT FROM v_terrain_4
    ) THEN
        RAISE EXCEPTION 'Existing FactionHOMM3 conflicts with homm3.faction.dungeon; batch rolled back. Review before retrying.';
    END IF;

    -- homm3.faction.stronghold (shared primary key)
    INSERT INTO heroes_watch."FactionHOMM3" AS existing
        ("Faction_id", "Alignment", "NativeTerrain_id")
    VALUES (v_faction_6, 'Neutral', v_terrain_5)
    ON CONFLICT ("Faction_id") DO UPDATE SET
        "Alignment" = COALESCE(existing."Alignment", EXCLUDED."Alignment"),
        "NativeTerrain_id" = COALESCE(existing."NativeTerrain_id", EXCLUDED."NativeTerrain_id");

    IF NOT EXISTS (
        SELECT 1 FROM heroes_watch."FactionHOMM3"
        WHERE "Faction_id" = v_faction_6
          AND "Faction_id" IS NOT DISTINCT FROM v_faction_6
          AND "Alignment" IS NOT DISTINCT FROM 'Neutral'
          AND "NativeTerrain_id" IS NOT DISTINCT FROM v_terrain_5
    ) THEN
        RAISE EXCEPTION 'Existing FactionHOMM3 conflicts with homm3.faction.stronghold; batch rolled back. Review before retrying.';
    END IF;

    -- homm3.faction.fortress (shared primary key)
    INSERT INTO heroes_watch."FactionHOMM3" AS existing
        ("Faction_id", "Alignment", "NativeTerrain_id")
    VALUES (v_faction_7, 'Neutral', v_terrain_6)
    ON CONFLICT ("Faction_id") DO UPDATE SET
        "Alignment" = COALESCE(existing."Alignment", EXCLUDED."Alignment"),
        "NativeTerrain_id" = COALESCE(existing."NativeTerrain_id", EXCLUDED."NativeTerrain_id");

    IF NOT EXISTS (
        SELECT 1 FROM heroes_watch."FactionHOMM3"
        WHERE "Faction_id" = v_faction_7
          AND "Faction_id" IS NOT DISTINCT FROM v_faction_7
          AND "Alignment" IS NOT DISTINCT FROM 'Neutral'
          AND "NativeTerrain_id" IS NOT DISTINCT FROM v_terrain_6
    ) THEN
        RAISE EXCEPTION 'Existing FactionHOMM3 conflicts with homm3.faction.fortress; batch rolled back. Review before retrying.';
    END IF;

    -- homm3.faction.conflux (shared primary key)
    INSERT INTO heroes_watch."FactionHOMM3" AS existing
        ("Faction_id", "Alignment", "NativeTerrain_id")
    VALUES (v_faction_8, 'Neutral', v_terrain_0)
    ON CONFLICT ("Faction_id") DO UPDATE SET
        "Alignment" = COALESCE(existing."Alignment", EXCLUDED."Alignment"),
        "NativeTerrain_id" = COALESCE(existing."NativeTerrain_id", EXCLUDED."NativeTerrain_id");

    IF NOT EXISTS (
        SELECT 1 FROM heroes_watch."FactionHOMM3"
        WHERE "Faction_id" = v_faction_8
          AND "Faction_id" IS NOT DISTINCT FROM v_faction_8
          AND "Alignment" IS NOT DISTINCT FROM 'Neutral'
          AND "NativeTerrain_id" IS NOT DISTINCT FROM v_terrain_0
    ) THEN
        RAISE EXCEPTION 'Existing FactionHOMM3 conflicts with homm3.faction.conflux; batch rolled back. Review before retrying.';
    END IF;
END
$faction_batch$;

SET CONSTRAINTS ALL IMMEDIATE;
COMMIT;

-- Read-only verification of the nine requested factions.
SELECT
    f."Name" AS "Faction",
    d."Alignment"::text AS "Alignment",
    t."Name" AS "Native terrain",
    e."Name" AS "Introduced in",
    f."Faction_id" AS "Faction ID"
FROM heroes_watch."Faction" f
JOIN heroes_watch."Game" g ON g."Game_id" = f."Game_id"
JOIN heroes_watch."FactionHOMM3" d ON d."Faction_id" = f."Faction_id"
JOIN heroes_watch."Terrain" t
  ON t."Terrain_id" = d."NativeTerrain_id" AND t."Game_id" = g."Game_id"
JOIN heroes_watch."Expansion" e
  ON e."Expansion_id" = f."IntroducedInExpansion_id" AND e."Game_id" = g."Game_id"
WHERE g."SeriesCode" = 'HOMM3'
  AND f."Code" IN ('CASTLE', 'RAMPART', 'TOWER', 'INFERNO', 'NECROPOLIS', 'DUNGEON', 'STRONGHOLD', 'FORTRESS', 'CONFLUX')
ORDER BY array_position(ARRAY['CASTLE', 'RAMPART', 'TOWER', 'INFERNO', 'NECROPOLIS', 'DUNGEON', 'STRONGHOLD', 'FORTRESS', 'CONFLUX'], f."Code");
