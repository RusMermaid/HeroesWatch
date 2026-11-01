-- Heroes I and Heroes II Gold faction content.
-- Snapshot of the HOMM1/HOMM2 rows in heroeswatch.json.
-- Sources and alias mapping: homm1-homm2-factions.sources.md.
-- Execute the complete script in a fresh query session on the existing schema.
-- Resolves identities, preserves other content, and rejects conflicting facts.

BEGIN;
SET LOCAL lock_timeout = '5s';
SET LOCAL statement_timeout = '60s';

DO $homm12_import$
DECLARE
    batch CONSTANT JSONB := $homm12_data$
{
  "Game": [
    {
      "_key": "homm1.game",
      "SeriesCode": "HOMM1",
      "DisplayOrder": 1,
      "Name": "Heroes of Might and Magic",
      "ReleaseDate": null,
      "Description": null
    },
    {
      "_key": "homm2.game",
      "SeriesCode": "HOMM2",
      "DisplayOrder": 2,
      "Name": "Heroes of Might and Magic II",
      "ReleaseDate": null,
      "Description": null
    }
  ],
  "Expansion": [
    {
      "_key": "homm1.expansion.base",
      "Game_id": "homm1.game",
      "Code": "BASE",
      "Name": "Heroes of Might and Magic",
      "Kind": "BaseGame",
      "ReleaseDate": null,
      "Description": null
    },
    {
      "_key": "homm2.expansion.sw",
      "Game_id": "homm2.game",
      "Code": "SW",
      "Name": "The Succession Wars",
      "Kind": "BaseGame",
      "ReleaseDate": null,
      "Description": null
    },
    {
      "_key": "homm2.expansion.pol",
      "Game_id": "homm2.game",
      "Code": "POL",
      "Name": "The Price of Loyalty",
      "Kind": "Expansion",
      "ReleaseDate": null,
      "Description": null
    },
    {
      "_key": "homm2.expansion.gold",
      "Game_id": "homm2.game",
      "Code": "GOLD",
      "Name": "Heroes of Might and Magic II Gold",
      "Kind": "Compilation",
      "ReleaseDate": null,
      "Description": null
    }
  ],
  "Faction": [
    {
      "_key": "homm1.faction.knight",
      "Game_id": "homm1.game",
      "Code": "KNIGHT",
      "Name": "Knight",
      "Description": null,
      "IntroducedInExpansion_id": "homm1.expansion.base",
      "MediaAsset_id": null
    },
    {
      "_key": "homm1.faction.sorceress",
      "Game_id": "homm1.game",
      "Code": "SORCERESS",
      "Name": "Sorceress",
      "Description": null,
      "IntroducedInExpansion_id": "homm1.expansion.base",
      "MediaAsset_id": null
    },
    {
      "_key": "homm1.faction.warlock",
      "Game_id": "homm1.game",
      "Code": "WARLOCK",
      "Name": "Warlock",
      "Description": null,
      "IntroducedInExpansion_id": "homm1.expansion.base",
      "MediaAsset_id": null
    },
    {
      "_key": "homm1.faction.barbarian",
      "Game_id": "homm1.game",
      "Code": "BARBARIAN",
      "Name": "Barbarian",
      "Description": null,
      "IntroducedInExpansion_id": "homm1.expansion.base",
      "MediaAsset_id": null
    },
    {
      "_key": "homm2.faction.knight",
      "Game_id": "homm2.game",
      "Code": "KNIGHT",
      "Name": "Knight",
      "Description": null,
      "IntroducedInExpansion_id": "homm2.expansion.sw",
      "MediaAsset_id": null
    },
    {
      "_key": "homm2.faction.sorceress",
      "Game_id": "homm2.game",
      "Code": "SORCERESS",
      "Name": "Sorceress",
      "Description": null,
      "IntroducedInExpansion_id": "homm2.expansion.sw",
      "MediaAsset_id": null
    },
    {
      "_key": "homm2.faction.barbarian",
      "Game_id": "homm2.game",
      "Code": "BARBARIAN",
      "Name": "Barbarian",
      "Description": null,
      "IntroducedInExpansion_id": "homm2.expansion.sw",
      "MediaAsset_id": null
    },
    {
      "_key": "homm2.faction.necromancer",
      "Game_id": "homm2.game",
      "Code": "NECROMANCER",
      "Name": "Necromancer",
      "Description": null,
      "IntroducedInExpansion_id": "homm2.expansion.sw",
      "MediaAsset_id": null
    },
    {
      "_key": "homm2.faction.warlock",
      "Game_id": "homm2.game",
      "Code": "WARLOCK",
      "Name": "Warlock",
      "Description": null,
      "IntroducedInExpansion_id": "homm2.expansion.sw",
      "MediaAsset_id": null
    },
    {
      "_key": "homm2.faction.wizard",
      "Game_id": "homm2.game",
      "Code": "WIZARD",
      "Name": "Wizard",
      "Description": null,
      "IntroducedInExpansion_id": "homm2.expansion.sw",
      "MediaAsset_id": null
    }
  ],
  "FactionHOMM1": [
    {
      "_key": "homm1.faction.knight",
      "TownType": "Farm"
    },
    {
      "_key": "homm1.faction.sorceress",
      "TownType": "Forest"
    },
    {
      "_key": "homm1.faction.warlock",
      "TownType": "Mountain"
    },
    {
      "_key": "homm1.faction.barbarian",
      "TownType": "Plains"
    }
  ],
  "FactionHOMM2": [
    {
      "_key": "homm2.faction.knight",
      "Alignment": "Good",
      "MageGuildMaxLevel": 5
    },
    {
      "_key": "homm2.faction.sorceress",
      "Alignment": "Good",
      "MageGuildMaxLevel": 5
    },
    {
      "_key": "homm2.faction.barbarian",
      "Alignment": "Evil",
      "MageGuildMaxLevel": 5
    },
    {
      "_key": "homm2.faction.necromancer",
      "Alignment": "Evil",
      "MageGuildMaxLevel": 5
    },
    {
      "_key": "homm2.faction.warlock",
      "Alignment": "Evil",
      "MageGuildMaxLevel": 5
    },
    {
      "_key": "homm2.faction.wizard",
      "Alignment": "Good",
      "MageGuildMaxLevel": 5
    }
  ]
}
$homm12_data$::JSONB;
    entry JSONB;
    resolved JSONB := '{}'::JSONB;
    current_id BIGINT;
BEGIN
    -- Game: 2 rows.
    FOR entry IN SELECT value FROM jsonb_array_elements(batch -> 'Game') LOOP
        INSERT INTO heroes_watch."Game" AS existing
            ("SeriesCode", "DisplayOrder", "Name", "ReleaseDate", "Description")
        VALUES (
            (entry ->> 'SeriesCode'),
            (entry ->> 'DisplayOrder')::SMALLINT,
            (entry ->> 'Name'),
            (entry ->> 'ReleaseDate')::DATE,
            (entry ->> 'Description')
        )
        ON CONFLICT ("SeriesCode") DO UPDATE SET
            "ReleaseDate" = COALESCE(existing."ReleaseDate", EXCLUDED."ReleaseDate"),
            "Description" = COALESCE(existing."Description", EXCLUDED."Description");
        SELECT "Game_id" INTO STRICT current_id
        FROM heroes_watch."Game"
        WHERE "SeriesCode" = (entry ->> 'SeriesCode')
        FOR UPDATE;
        resolved := resolved || jsonb_build_object(entry ->> '_key', current_id);
        IF NOT EXISTS (
            SELECT 1 FROM heroes_watch."Game"
            WHERE "Game_id" = current_id
              AND "SeriesCode" IS NOT DISTINCT FROM (entry ->> 'SeriesCode')
              AND "DisplayOrder" IS NOT DISTINCT FROM (entry ->> 'DisplayOrder')::SMALLINT
              AND "Name" IS NOT DISTINCT FROM (entry ->> 'Name')
              AND (entry -> 'ReleaseDate' = 'null'::JSONB OR "ReleaseDate" IS NOT DISTINCT FROM (entry ->> 'ReleaseDate')::DATE)
              AND (entry -> 'Description' = 'null'::JSONB OR "Description" IS NOT DISTINCT FROM (entry ->> 'Description'))
        ) THEN
            RAISE EXCEPTION 'Existing Game conflicts with %; transaction aborted.', entry ->> '_key';
        END IF;
    END LOOP;

    -- Expansion: 4 rows.
    FOR entry IN SELECT value FROM jsonb_array_elements(batch -> 'Expansion') LOOP
        INSERT INTO heroes_watch."Expansion" AS existing
            ("Game_id", "Code", "Name", "Kind", "ReleaseDate", "Description")
        VALUES (
            (resolved ->> (entry ->> 'Game_id'))::BIGINT,
            (entry ->> 'Code'),
            (entry ->> 'Name'),
            (entry ->> 'Kind')::heroes_watch."Enum__Expansion__Kind",
            (entry ->> 'ReleaseDate')::DATE,
            (entry ->> 'Description')
        )
        ON CONFLICT ("Game_id", "Code") DO UPDATE SET
            "ReleaseDate" = COALESCE(existing."ReleaseDate", EXCLUDED."ReleaseDate"),
            "Description" = COALESCE(existing."Description", EXCLUDED."Description");
        SELECT "Expansion_id" INTO STRICT current_id
        FROM heroes_watch."Expansion"
        WHERE "Game_id" = (resolved ->> (entry ->> 'Game_id'))::BIGINT AND "Code" = (entry ->> 'Code')
        FOR UPDATE;
        resolved := resolved || jsonb_build_object(entry ->> '_key', current_id);
        IF NOT EXISTS (
            SELECT 1 FROM heroes_watch."Expansion"
            WHERE "Expansion_id" = current_id
              AND "Game_id" IS NOT DISTINCT FROM (resolved ->> (entry ->> 'Game_id'))::BIGINT
              AND "Code" IS NOT DISTINCT FROM (entry ->> 'Code')
              AND "Name" IS NOT DISTINCT FROM (entry ->> 'Name')
              AND "Kind" IS NOT DISTINCT FROM (entry ->> 'Kind')::heroes_watch."Enum__Expansion__Kind"
              AND (entry -> 'ReleaseDate' = 'null'::JSONB OR "ReleaseDate" IS NOT DISTINCT FROM (entry ->> 'ReleaseDate')::DATE)
              AND (entry -> 'Description' = 'null'::JSONB OR "Description" IS NOT DISTINCT FROM (entry ->> 'Description'))
        ) THEN
            RAISE EXCEPTION 'Existing Expansion conflicts with %; transaction aborted.', entry ->> '_key';
        END IF;
    END LOOP;

    -- Faction: 10 rows.
    FOR entry IN SELECT value FROM jsonb_array_elements(batch -> 'Faction') LOOP
        INSERT INTO heroes_watch."Faction" AS existing
            ("Game_id", "Code", "Name", "Description", "IntroducedInExpansion_id", "MediaAsset_id")
        VALUES (
            (resolved ->> (entry ->> 'Game_id'))::BIGINT,
            (entry ->> 'Code'),
            (entry ->> 'Name'),
            (entry ->> 'Description'),
            (resolved ->> (entry ->> 'IntroducedInExpansion_id'))::BIGINT,
            (resolved ->> (entry ->> 'MediaAsset_id'))::BIGINT
        )
        ON CONFLICT ("Game_id", "Code") DO UPDATE SET
            "Description" = COALESCE(existing."Description", EXCLUDED."Description"),
            "IntroducedInExpansion_id" = COALESCE(existing."IntroducedInExpansion_id", EXCLUDED."IntroducedInExpansion_id"),
            "MediaAsset_id" = COALESCE(existing."MediaAsset_id", EXCLUDED."MediaAsset_id");
        SELECT "Faction_id" INTO STRICT current_id
        FROM heroes_watch."Faction"
        WHERE "Game_id" = (resolved ->> (entry ->> 'Game_id'))::BIGINT AND "Code" = (entry ->> 'Code')
        FOR UPDATE;
        resolved := resolved || jsonb_build_object(entry ->> '_key', current_id);
        IF NOT EXISTS (
            SELECT 1 FROM heroes_watch."Faction"
            WHERE "Faction_id" = current_id
              AND "Game_id" IS NOT DISTINCT FROM (resolved ->> (entry ->> 'Game_id'))::BIGINT
              AND "Code" IS NOT DISTINCT FROM (entry ->> 'Code')
              AND "Name" IS NOT DISTINCT FROM (entry ->> 'Name')
              AND (entry -> 'Description' = 'null'::JSONB OR "Description" IS NOT DISTINCT FROM (entry ->> 'Description'))
              AND (entry -> 'IntroducedInExpansion_id' = 'null'::JSONB OR "IntroducedInExpansion_id" IS NOT DISTINCT FROM (resolved ->> (entry ->> 'IntroducedInExpansion_id'))::BIGINT)
              AND (entry -> 'MediaAsset_id' = 'null'::JSONB OR "MediaAsset_id" IS NOT DISTINCT FROM (resolved ->> (entry ->> 'MediaAsset_id'))::BIGINT)
        ) THEN
            RAISE EXCEPTION 'Existing Faction conflicts with %; transaction aborted.', entry ->> '_key';
        END IF;
    END LOOP;

    -- FactionHOMM1: 4 rows.
    FOR entry IN SELECT value FROM jsonb_array_elements(batch -> 'FactionHOMM1') LOOP
        INSERT INTO heroes_watch."FactionHOMM1" AS existing
            ("Faction_id", "TownType")
        VALUES (
            (resolved ->> (entry ->> '_key'))::BIGINT,
            (entry ->> 'TownType')::heroes_watch."Enum__FactionHOMM1__TownType"
        )
        ON CONFLICT ("Faction_id") DO NOTHING;
        current_id := (resolved ->> (entry ->> '_key'))::BIGINT;
        IF NOT EXISTS (
            SELECT 1 FROM heroes_watch."FactionHOMM1"
            WHERE "Faction_id" = current_id
              AND "TownType" IS NOT DISTINCT FROM (entry ->> 'TownType')::heroes_watch."Enum__FactionHOMM1__TownType"
        ) THEN
            RAISE EXCEPTION 'Existing FactionHOMM1 conflicts with %; transaction aborted.', entry ->> '_key';
        END IF;
    END LOOP;

    -- FactionHOMM2: 6 rows.
    FOR entry IN SELECT value FROM jsonb_array_elements(batch -> 'FactionHOMM2') LOOP
        INSERT INTO heroes_watch."FactionHOMM2" AS existing
            ("Faction_id", "Alignment", "MageGuildMaxLevel")
        VALUES (
            (resolved ->> (entry ->> '_key'))::BIGINT,
            (entry ->> 'Alignment')::heroes_watch."Enum__FactionHOMM2__Alignment",
            (entry ->> 'MageGuildMaxLevel')::SMALLINT
        )
        ON CONFLICT ("Faction_id") DO UPDATE SET
            "MageGuildMaxLevel" = COALESCE(existing."MageGuildMaxLevel", EXCLUDED."MageGuildMaxLevel");
        current_id := (resolved ->> (entry ->> '_key'))::BIGINT;
        IF NOT EXISTS (
            SELECT 1 FROM heroes_watch."FactionHOMM2"
            WHERE "Faction_id" = current_id
              AND "Alignment" IS NOT DISTINCT FROM (entry ->> 'Alignment')::heroes_watch."Enum__FactionHOMM2__Alignment"
              AND (entry -> 'MageGuildMaxLevel' = 'null'::JSONB OR "MageGuildMaxLevel" IS NOT DISTINCT FROM (entry ->> 'MageGuildMaxLevel')::SMALLINT)
        ) THEN
            RAISE EXCEPTION 'Existing FactionHOMM2 conflicts with %; transaction aborted.', entry ->> '_key';
        END IF;
    END LOOP;
END
$homm12_import$;

SET CONSTRAINTS ALL IMMEDIATE;
COMMIT;

-- Read-only: four Heroes I factions and six Heroes II factions.
-- Dashes indicate fields not modeled for that title, not missing required values.
SELECT g."SeriesCode" AS "Game", f."Name" AS "Faction",
       COALESCE(h1."TownType"::TEXT, '-') AS "Town type",
       COALESCE(h2."Alignment"::TEXT, '-') AS "Alignment",
       COALESCE(h2."MageGuildMaxLevel"::TEXT, '-') AS "Mage guild max",
       e."Code" AS "Introduced in"
FROM heroes_watch."Faction" f
JOIN heroes_watch."Game" g ON g."Game_id" = f."Game_id"
JOIN heroes_watch."Expansion" e ON e."Expansion_id" = f."IntroducedInExpansion_id" AND e."Game_id" = g."Game_id"
LEFT JOIN heroes_watch."FactionHOMM1" h1 ON h1."Faction_id" = f."Faction_id" AND g."SeriesCode" = 'HOMM1'
LEFT JOIN heroes_watch."FactionHOMM2" h2 ON h2."Faction_id" = f."Faction_id" AND g."SeriesCode" = 'HOMM2'
WHERE (g."SeriesCode" = 'HOMM1' AND h1."Faction_id" IS NOT NULL AND f."Code" IN ('KNIGHT','SORCERESS','WARLOCK','BARBARIAN'))
   OR (g."SeriesCode" = 'HOMM2' AND h2."Faction_id" IS NOT NULL AND f."Code" IN ('KNIGHT','SORCERESS','BARBARIAN','NECROMANCER','WARLOCK','WIZARD'))
ORDER BY g."DisplayOrder",
    CASE WHEN g."SeriesCode" = 'HOMM1' THEN array_position(ARRAY['KNIGHT','SORCERESS','WARLOCK','BARBARIAN'], f."Code")
         ELSE array_position(ARRAY['KNIGHT','SORCERESS','BARBARIAN','NECROMANCER','WARLOCK','WIZARD'], f."Code") END;
