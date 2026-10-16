-- Heroes VI factions and expansion provenance.
-- Snapshot of the HOMM6 rows in heroeswatch.json; sources: homm6-factions.sources.md.
-- Execute the entire script in a fresh query session on the existing schema.
-- Resolves identities, preserves other content, and rejects conflicting facts.

BEGIN;
SET LOCAL lock_timeout = '5s';
SET LOCAL statement_timeout = '60s';

DO $homm6_import$
DECLARE
    batch CONSTANT JSONB := $homm6_data$
{
  "Game": [
    {
      "_key": "homm6.game",
      "SeriesCode": "HOMM6",
      "DisplayOrder": 6,
      "Name": "Might & Magic Heroes VI",
      "ReleaseDate": null,
      "Description": null
    }
  ],
  "Expansion": [
    {
      "_key": "homm6.expansion.base",
      "Game_id": "homm6.game",
      "Code": "BASE",
      "Name": "Might & Magic Heroes VI",
      "Kind": "BaseGame",
      "ReleaseDate": null,
      "Description": null
    },
    {
      "_key": "homm6.expansion.potss",
      "Game_id": "homm6.game",
      "Code": "POTSS",
      "Name": "Pirates of the Savage Sea Adventure Pack",
      "Kind": "Expansion",
      "ReleaseDate": null,
      "Description": "Adventure-pack DLC for the base game featuring a Stronghold campaign."
    },
    {
      "_key": "homm6.expansion.dm",
      "Game_id": "homm6.game",
      "Code": "DM",
      "Name": "Danse Macabre Adventure Pack",
      "Kind": "Expansion",
      "ReleaseDate": null,
      "Description": "Adventure-pack DLC for the base game featuring a Necropolis campaign."
    },
    {
      "_key": "homm6.expansion.sod",
      "Game_id": "homm6.game",
      "Code": "SOD",
      "Name": "Shades of Darkness",
      "Kind": "Expansion",
      "ReleaseDate": null,
      "Description": "Standalone expansion introducing Dungeon and adding Dungeon and Necropolis campaigns."
    }
  ],
  "Ability": [
    {
      "_key": "homm6.ability.guardian.angel",
      "Game_id": "homm6.game",
      "Code": "GUARDIAN_ANGEL",
      "Name": "Guardian Angel",
      "Description": "Protects allied Haven creatures from damage during combat.",
      "MediaAsset_id": null
    },
    {
      "_key": "homm6.ability.gating",
      "Game_id": "homm6.game",
      "Code": "GATING",
      "Name": "Gating",
      "Description": "Summons Inferno reinforcements during combat.",
      "MediaAsset_id": null
    },
    {
      "_key": "homm6.ability.necromancy",
      "Game_id": "homm6.game",
      "Code": "NECROMANCY",
      "Name": "Necromancy",
      "Description": "Raises allied undead creatures during combat.",
      "MediaAsset_id": null
    },
    {
      "_key": "homm6.ability.honor",
      "Game_id": "homm6.game",
      "Code": "HONOR",
      "Name": "Honor",
      "Description": "Improves the defenses of allied Sanctuary creatures during combat.",
      "MediaAsset_id": null
    },
    {
      "_key": "homm6.ability.bloodrage",
      "Game_id": "homm6.game",
      "Code": "BLOODRAGE",
      "Name": "Bloodrage",
      "Description": "Improves the initiative and offensive strength of allied Stronghold creatures during combat.",
      "MediaAsset_id": null
    },
    {
      "_key": "homm6.ability.shroud.of.malassa",
      "Game_id": "homm6.game",
      "Code": "SHROUD_OF_MALASSA",
      "Name": "Shroud of Malassa",
      "Description": "Makes allied Dungeon creatures temporarily invisible during combat.",
      "MediaAsset_id": null
    }
  ],
  "AbilityHOMM6": [
    {
      "_key": "homm6.ability.guardian.angel",
      "AbilityKind": "Faction",
      "Branch": null,
      "Subbranch": null,
      "MagicSchool_id": null,
      "Tier": null,
      "ReputationPath": null,
      "IsActive": true,
      "Cooldown": null,
      "ManaCost": null,
      "Mechanics": null
    },
    {
      "_key": "homm6.ability.gating",
      "AbilityKind": "Faction",
      "Branch": null,
      "Subbranch": null,
      "MagicSchool_id": null,
      "Tier": null,
      "ReputationPath": null,
      "IsActive": true,
      "Cooldown": null,
      "ManaCost": null,
      "Mechanics": null
    },
    {
      "_key": "homm6.ability.necromancy",
      "AbilityKind": "Faction",
      "Branch": null,
      "Subbranch": null,
      "MagicSchool_id": null,
      "Tier": null,
      "ReputationPath": null,
      "IsActive": true,
      "Cooldown": null,
      "ManaCost": null,
      "Mechanics": null
    },
    {
      "_key": "homm6.ability.honor",
      "AbilityKind": "Faction",
      "Branch": null,
      "Subbranch": null,
      "MagicSchool_id": null,
      "Tier": null,
      "ReputationPath": null,
      "IsActive": true,
      "Cooldown": null,
      "ManaCost": null,
      "Mechanics": null
    },
    {
      "_key": "homm6.ability.bloodrage",
      "AbilityKind": "Faction",
      "Branch": null,
      "Subbranch": null,
      "MagicSchool_id": null,
      "Tier": null,
      "ReputationPath": null,
      "IsActive": true,
      "Cooldown": null,
      "ManaCost": null,
      "Mechanics": null
    },
    {
      "_key": "homm6.ability.shroud.of.malassa",
      "AbilityKind": "Faction",
      "Branch": null,
      "Subbranch": null,
      "MagicSchool_id": null,
      "Tier": null,
      "ReputationPath": null,
      "IsActive": true,
      "Cooldown": null,
      "ManaCost": null,
      "Mechanics": null
    }
  ],
  "Faction": [
    {
      "_key": "homm6.faction.haven",
      "Game_id": "homm6.game",
      "Code": "HAVEN",
      "Name": "Haven",
      "Description": null,
      "IntroducedInExpansion_id": "homm6.expansion.base",
      "MediaAsset_id": null
    },
    {
      "_key": "homm6.faction.inferno",
      "Game_id": "homm6.game",
      "Code": "INFERNO",
      "Name": "Inferno",
      "Description": null,
      "IntroducedInExpansion_id": "homm6.expansion.base",
      "MediaAsset_id": null
    },
    {
      "_key": "homm6.faction.necropolis",
      "Game_id": "homm6.game",
      "Code": "NECROPOLIS",
      "Name": "Necropolis",
      "Description": null,
      "IntroducedInExpansion_id": "homm6.expansion.base",
      "MediaAsset_id": null
    },
    {
      "_key": "homm6.faction.sanctuary",
      "Game_id": "homm6.game",
      "Code": "SANCTUARY",
      "Name": "Sanctuary",
      "Description": null,
      "IntroducedInExpansion_id": "homm6.expansion.base",
      "MediaAsset_id": null
    },
    {
      "_key": "homm6.faction.stronghold",
      "Game_id": "homm6.game",
      "Code": "STRONGHOLD",
      "Name": "Stronghold",
      "Description": null,
      "IntroducedInExpansion_id": "homm6.expansion.base",
      "MediaAsset_id": null
    },
    {
      "_key": "homm6.faction.dungeon",
      "Game_id": "homm6.game",
      "Code": "DUNGEON",
      "Name": "Dungeon",
      "Description": null,
      "IntroducedInExpansion_id": "homm6.expansion.sod",
      "MediaAsset_id": null
    }
  ],
  "FactionHOMM6": [
    {
      "_key": "homm6.faction.haven",
      "FactionAbility_id": "homm6.ability.guardian.angel",
      "UniqueBuildingLimit": 2
    },
    {
      "_key": "homm6.faction.inferno",
      "FactionAbility_id": "homm6.ability.gating",
      "UniqueBuildingLimit": 2
    },
    {
      "_key": "homm6.faction.necropolis",
      "FactionAbility_id": "homm6.ability.necromancy",
      "UniqueBuildingLimit": 2
    },
    {
      "_key": "homm6.faction.sanctuary",
      "FactionAbility_id": "homm6.ability.honor",
      "UniqueBuildingLimit": 2
    },
    {
      "_key": "homm6.faction.stronghold",
      "FactionAbility_id": "homm6.ability.bloodrage",
      "UniqueBuildingLimit": 2
    },
    {
      "_key": "homm6.faction.dungeon",
      "FactionAbility_id": "homm6.ability.shroud.of.malassa",
      "UniqueBuildingLimit": 2
    }
  ]
}
$homm6_data$::JSONB;
    entry JSONB;
    resolved JSONB := '{}'::JSONB;
    current_id BIGINT;
BEGIN
    -- Game: 1 rows.
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

    -- Ability: 6 rows.
    FOR entry IN SELECT value FROM jsonb_array_elements(batch -> 'Ability') LOOP
        INSERT INTO heroes_watch."Ability" AS existing
            ("Game_id", "Code", "Name", "Description", "MediaAsset_id")
        VALUES (
            (resolved ->> (entry ->> 'Game_id'))::BIGINT,
            (entry ->> 'Code'),
            (entry ->> 'Name'),
            (entry ->> 'Description'),
            (resolved ->> (entry ->> 'MediaAsset_id'))::BIGINT
        )
        ON CONFLICT ("Game_id", "Code") DO UPDATE SET
            "Description" = COALESCE(existing."Description", EXCLUDED."Description"),
            "MediaAsset_id" = COALESCE(existing."MediaAsset_id", EXCLUDED."MediaAsset_id");
        SELECT "Ability_id" INTO STRICT current_id
        FROM heroes_watch."Ability"
        WHERE "Game_id" = (resolved ->> (entry ->> 'Game_id'))::BIGINT AND "Code" = (entry ->> 'Code')
        FOR UPDATE;
        resolved := resolved || jsonb_build_object(entry ->> '_key', current_id);
        IF NOT EXISTS (
            SELECT 1 FROM heroes_watch."Ability"
            WHERE "Ability_id" = current_id
              AND "Game_id" IS NOT DISTINCT FROM (resolved ->> (entry ->> 'Game_id'))::BIGINT
              AND "Code" IS NOT DISTINCT FROM (entry ->> 'Code')
              AND "Name" IS NOT DISTINCT FROM (entry ->> 'Name')
              AND (entry -> 'Description' = 'null'::JSONB OR "Description" IS NOT DISTINCT FROM (entry ->> 'Description'))
              AND (entry -> 'MediaAsset_id' = 'null'::JSONB OR "MediaAsset_id" IS NOT DISTINCT FROM (resolved ->> (entry ->> 'MediaAsset_id'))::BIGINT)
        ) THEN
            RAISE EXCEPTION 'Existing Ability conflicts with %; transaction aborted.', entry ->> '_key';
        END IF;
    END LOOP;

    -- Faction: 6 rows.
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

    -- AbilityHOMM6: 6 rows.
    FOR entry IN SELECT value FROM jsonb_array_elements(batch -> 'AbilityHOMM6') LOOP
        INSERT INTO heroes_watch."AbilityHOMM6" AS existing
            ("Ability_id", "AbilityKind", "Branch", "Subbranch", "MagicSchool_id", "Tier", "ReputationPath", "IsActive", "Cooldown", "ManaCost", "Mechanics")
        VALUES (
            (resolved ->> (entry ->> '_key'))::BIGINT,
            (entry ->> 'AbilityKind')::heroes_watch."Enum__AbilityHOMM6__AbilityKind",
            (entry ->> 'Branch')::heroes_watch."Enum__AbilityHOMM6__Branch",
            (entry ->> 'Subbranch'),
            (resolved ->> (entry ->> 'MagicSchool_id'))::BIGINT,
            (entry ->> 'Tier')::SMALLINT,
            (entry ->> 'ReputationPath')::heroes_watch."Enum__AbilityHOMM6__ReputationPath",
            (entry ->> 'IsActive')::BOOLEAN,
            (entry ->> 'Cooldown')::SMALLINT,
            (entry ->> 'ManaCost')::SMALLINT,
            (entry ->> 'Mechanics')::JSONB
        )
        ON CONFLICT ("Ability_id") DO UPDATE SET
            "Branch" = COALESCE(existing."Branch", EXCLUDED."Branch"),
            "Subbranch" = COALESCE(existing."Subbranch", EXCLUDED."Subbranch"),
            "MagicSchool_id" = COALESCE(existing."MagicSchool_id", EXCLUDED."MagicSchool_id"),
            "Tier" = COALESCE(existing."Tier", EXCLUDED."Tier"),
            "ReputationPath" = COALESCE(existing."ReputationPath", EXCLUDED."ReputationPath"),
            "Cooldown" = COALESCE(existing."Cooldown", EXCLUDED."Cooldown"),
            "ManaCost" = COALESCE(existing."ManaCost", EXCLUDED."ManaCost"),
            "Mechanics" = COALESCE(existing."Mechanics", EXCLUDED."Mechanics");
        current_id := (resolved ->> (entry ->> '_key'))::BIGINT;
        IF NOT EXISTS (
            SELECT 1 FROM heroes_watch."AbilityHOMM6"
            WHERE "Ability_id" = current_id
              AND "AbilityKind" IS NOT DISTINCT FROM (entry ->> 'AbilityKind')::heroes_watch."Enum__AbilityHOMM6__AbilityKind"
              AND (entry -> 'Branch' = 'null'::JSONB OR "Branch" IS NOT DISTINCT FROM (entry ->> 'Branch')::heroes_watch."Enum__AbilityHOMM6__Branch")
              AND (entry -> 'Subbranch' = 'null'::JSONB OR "Subbranch" IS NOT DISTINCT FROM (entry ->> 'Subbranch'))
              AND (entry -> 'MagicSchool_id' = 'null'::JSONB OR "MagicSchool_id" IS NOT DISTINCT FROM (resolved ->> (entry ->> 'MagicSchool_id'))::BIGINT)
              AND (entry -> 'Tier' = 'null'::JSONB OR "Tier" IS NOT DISTINCT FROM (entry ->> 'Tier')::SMALLINT)
              AND (entry -> 'ReputationPath' = 'null'::JSONB OR "ReputationPath" IS NOT DISTINCT FROM (entry ->> 'ReputationPath')::heroes_watch."Enum__AbilityHOMM6__ReputationPath")
              AND "IsActive" IS NOT DISTINCT FROM (entry ->> 'IsActive')::BOOLEAN
              AND (entry -> 'Cooldown' = 'null'::JSONB OR "Cooldown" IS NOT DISTINCT FROM (entry ->> 'Cooldown')::SMALLINT)
              AND (entry -> 'ManaCost' = 'null'::JSONB OR "ManaCost" IS NOT DISTINCT FROM (entry ->> 'ManaCost')::SMALLINT)
              AND (entry -> 'Mechanics' = 'null'::JSONB OR "Mechanics" IS NOT DISTINCT FROM (entry ->> 'Mechanics')::JSONB)
        ) THEN
            RAISE EXCEPTION 'Existing AbilityHOMM6 conflicts with %; transaction aborted.', entry ->> '_key';
        END IF;
    END LOOP;

    -- FactionHOMM6: 6 rows.
    FOR entry IN SELECT value FROM jsonb_array_elements(batch -> 'FactionHOMM6') LOOP
        INSERT INTO heroes_watch."FactionHOMM6" AS existing
            ("Faction_id", "FactionAbility_id", "UniqueBuildingLimit")
        VALUES (
            (resolved ->> (entry ->> '_key'))::BIGINT,
            (resolved ->> (entry ->> 'FactionAbility_id'))::BIGINT,
            (entry ->> 'UniqueBuildingLimit')::SMALLINT
        )
        ON CONFLICT ("Faction_id") DO NOTHING;
        current_id := (resolved ->> (entry ->> '_key'))::BIGINT;
        IF NOT EXISTS (
            SELECT 1 FROM heroes_watch."FactionHOMM6"
            WHERE "Faction_id" = current_id
              AND "FactionAbility_id" IS NOT DISTINCT FROM (resolved ->> (entry ->> 'FactionAbility_id'))::BIGINT
              AND "UniqueBuildingLimit" IS NOT DISTINCT FROM (entry ->> 'UniqueBuildingLimit')::SMALLINT
        ) THEN
            RAISE EXCEPTION 'Existing FactionHOMM6 conflicts with %; transaction aborted.', entry ->> '_key';
        END IF;
    END LOOP;
END
$homm6_import$;

SET CONSTRAINTS ALL IMMEDIATE;
COMMIT;

-- Read-only: five base-game factions and Dungeon from Shades of Darkness.
SELECT f."Name" AS "Faction", a."Name" AS "Faction ability",
       ad."AbilityKind"::TEXT AS "Ability kind", ad."IsActive" AS "Active",
       d."UniqueBuildingLimit" AS "Unique building limit", e."Name" AS "Introduced in"
FROM heroes_watch."Faction" f
JOIN heroes_watch."Game" g ON g."Game_id" = f."Game_id"
JOIN heroes_watch."FactionHOMM6" d ON d."Faction_id" = f."Faction_id"
JOIN heroes_watch."Ability" a ON a."Ability_id" = d."FactionAbility_id" AND a."Game_id" = g."Game_id"
JOIN heroes_watch."AbilityHOMM6" ad ON ad."Ability_id" = a."Ability_id"
JOIN heroes_watch."Expansion" e ON e."Expansion_id" = f."IntroducedInExpansion_id" AND e."Game_id" = g."Game_id"
WHERE g."SeriesCode" = 'HOMM6'
  AND f."Code" IN ('HAVEN','INFERNO','NECROPOLIS','SANCTUARY','STRONGHOLD','DUNGEON')
ORDER BY array_position(ARRAY['HAVEN','INFERNO','NECROPOLIS','SANCTUARY','STRONGHOLD','DUNGEON'], f."Code");
