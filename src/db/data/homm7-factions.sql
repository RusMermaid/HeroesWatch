-- Heroes VII factions, racial skills, and expansion provenance.
-- Snapshot of the HOMM7 rows in heroeswatch.json; sources: homm7-factions.sources.md.
-- Execute the entire script in a fresh query session on the existing schema.
-- Resolves identities, preserves other content, and rejects conflicting facts.

BEGIN;
SET LOCAL lock_timeout = '5s';
SET LOCAL statement_timeout = '60s';

DO $homm7_import$
DECLARE
    batch CONSTANT JSONB := $homm7_data$
{
  "Game": [
    {
      "_key": "homm7.game",
      "SeriesCode": "HOMM7",
      "DisplayOrder": 7,
      "Name": "Might & Magic Heroes VII",
      "ReleaseDate": null,
      "Description": null
    }
  ],
  "Expansion": [
    {
      "_key": "homm7.expansion.base",
      "Game_id": "homm7.game",
      "Code": "BASE",
      "Name": "Might & Magic Heroes VII",
      "Kind": "BaseGame",
      "ReleaseDate": null,
      "Description": null
    },
    {
      "_key": "homm7.expansion.ltoa",
      "Game_id": "homm7.game",
      "Code": "LTOA",
      "Name": "Lost Tales of Axeoth",
      "Kind": "Expansion",
      "ReleaseDate": null,
      "Description": "Free campaign content package containing Unity and Every Dog Has His Day."
    },
    {
      "_key": "homm7.expansion.tbf",
      "Game_id": "homm7.game",
      "Code": "TBF",
      "Name": "Trial by Fire",
      "Kind": "Expansion",
      "ReleaseDate": null,
      "Description": "Standalone expansion introducing the Fortress faction."
    }
  ],
  "Skill": [
    {
      "_key": "homm7.skill.righteousness",
      "Game_id": "homm7.game",
      "Code": "RIGHTEOUSNESS",
      "Name": "Righteousness",
      "Description": null,
      "IntroducedInExpansion_id": "homm7.expansion.base",
      "MediaAsset_id": null
    },
    {
      "_key": "homm7.skill.metamagic",
      "Game_id": "homm7.game",
      "Code": "METAMAGIC",
      "Name": "Metamagic",
      "Description": null,
      "IntroducedInExpansion_id": "homm7.expansion.base",
      "MediaAsset_id": null
    },
    {
      "_key": "homm7.skill.necromancy",
      "Game_id": "homm7.game",
      "Code": "NECROMANCY",
      "Name": "Necromancy",
      "Description": null,
      "IntroducedInExpansion_id": "homm7.expansion.base",
      "MediaAsset_id": null
    },
    {
      "_key": "homm7.skill.bloodrage",
      "Game_id": "homm7.game",
      "Code": "BLOODRAGE",
      "Name": "Bloodrage",
      "Description": null,
      "IntroducedInExpansion_id": "homm7.expansion.base",
      "MediaAsset_id": null
    },
    {
      "_key": "homm7.skill.natures.revenge",
      "Game_id": "homm7.game",
      "Code": "NATURES_REVENGE",
      "Name": "Nature's Revenge",
      "Description": null,
      "IntroducedInExpansion_id": "homm7.expansion.base",
      "MediaAsset_id": null
    },
    {
      "_key": "homm7.skill.shroud.of.malassa",
      "Game_id": "homm7.game",
      "Code": "SHROUD_OF_MALASSA",
      "Name": "Shroud of Malassa",
      "Description": null,
      "IntroducedInExpansion_id": "homm7.expansion.base",
      "MediaAsset_id": null
    },
    {
      "_key": "homm7.skill.rune.magic",
      "Game_id": "homm7.game",
      "Code": "RUNE_MAGIC",
      "Name": "Rune Magic",
      "Description": null,
      "IntroducedInExpansion_id": "homm7.expansion.tbf",
      "MediaAsset_id": null
    }
  ],
  "SkillHOMM7": [
    {
      "_key": "homm7.skill.righteousness",
      "SkillKind": "Faction",
      "MagicSchool_id": null,
      "MaxMastery": "Grandmaster",
      "EffectByMastery": null
    },
    {
      "_key": "homm7.skill.metamagic",
      "SkillKind": "Faction",
      "MagicSchool_id": null,
      "MaxMastery": "Grandmaster",
      "EffectByMastery": null
    },
    {
      "_key": "homm7.skill.necromancy",
      "SkillKind": "Faction",
      "MagicSchool_id": null,
      "MaxMastery": "Grandmaster",
      "EffectByMastery": null
    },
    {
      "_key": "homm7.skill.bloodrage",
      "SkillKind": "Faction",
      "MagicSchool_id": null,
      "MaxMastery": "Grandmaster",
      "EffectByMastery": null
    },
    {
      "_key": "homm7.skill.natures.revenge",
      "SkillKind": "Faction",
      "MagicSchool_id": null,
      "MaxMastery": "Grandmaster",
      "EffectByMastery": null
    },
    {
      "_key": "homm7.skill.shroud.of.malassa",
      "SkillKind": "Faction",
      "MagicSchool_id": null,
      "MaxMastery": "Grandmaster",
      "EffectByMastery": null
    },
    {
      "_key": "homm7.skill.rune.magic",
      "SkillKind": "Faction",
      "MagicSchool_id": null,
      "MaxMastery": "Grandmaster",
      "EffectByMastery": null
    }
  ],
  "Faction": [
    {
      "_key": "homm7.faction.haven",
      "Game_id": "homm7.game",
      "Code": "HAVEN",
      "Name": "Haven",
      "Description": null,
      "IntroducedInExpansion_id": "homm7.expansion.base",
      "MediaAsset_id": null
    },
    {
      "_key": "homm7.faction.academy",
      "Game_id": "homm7.game",
      "Code": "ACADEMY",
      "Name": "Academy",
      "Description": null,
      "IntroducedInExpansion_id": "homm7.expansion.base",
      "MediaAsset_id": null
    },
    {
      "_key": "homm7.faction.necropolis",
      "Game_id": "homm7.game",
      "Code": "NECROPOLIS",
      "Name": "Necropolis",
      "Description": null,
      "IntroducedInExpansion_id": "homm7.expansion.base",
      "MediaAsset_id": null
    },
    {
      "_key": "homm7.faction.stronghold",
      "Game_id": "homm7.game",
      "Code": "STRONGHOLD",
      "Name": "Stronghold",
      "Description": null,
      "IntroducedInExpansion_id": "homm7.expansion.base",
      "MediaAsset_id": null
    },
    {
      "_key": "homm7.faction.sylvan",
      "Game_id": "homm7.game",
      "Code": "SYLVAN",
      "Name": "Sylvan",
      "Description": null,
      "IntroducedInExpansion_id": "homm7.expansion.base",
      "MediaAsset_id": null
    },
    {
      "_key": "homm7.faction.dungeon",
      "Game_id": "homm7.game",
      "Code": "DUNGEON",
      "Name": "Dungeon",
      "Description": null,
      "IntroducedInExpansion_id": "homm7.expansion.base",
      "MediaAsset_id": null
    },
    {
      "_key": "homm7.faction.fortress",
      "Game_id": "homm7.game",
      "Code": "FORTRESS",
      "Name": "Fortress",
      "Description": null,
      "IntroducedInExpansion_id": "homm7.expansion.tbf",
      "MediaAsset_id": null
    }
  ],
  "FactionHOMM7": [
    {
      "_key": "homm7.faction.haven",
      "Alignment": "Good",
      "RacialSkill_id": "homm7.skill.righteousness"
    },
    {
      "_key": "homm7.faction.academy",
      "Alignment": "Good",
      "RacialSkill_id": "homm7.skill.metamagic"
    },
    {
      "_key": "homm7.faction.necropolis",
      "Alignment": "Evil",
      "RacialSkill_id": "homm7.skill.necromancy"
    },
    {
      "_key": "homm7.faction.stronghold",
      "Alignment": "Neutral",
      "RacialSkill_id": "homm7.skill.bloodrage"
    },
    {
      "_key": "homm7.faction.sylvan",
      "Alignment": "Good",
      "RacialSkill_id": "homm7.skill.natures.revenge"
    },
    {
      "_key": "homm7.faction.dungeon",
      "Alignment": "Evil",
      "RacialSkill_id": "homm7.skill.shroud.of.malassa"
    },
    {
      "_key": "homm7.faction.fortress",
      "Alignment": "Neutral",
      "RacialSkill_id": "homm7.skill.rune.magic"
    }
  ]
}
$homm7_data$::JSONB;
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

    -- Expansion: 3 rows.
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

    -- Skill: 7 rows.
    FOR entry IN SELECT value FROM jsonb_array_elements(batch -> 'Skill') LOOP
        INSERT INTO heroes_watch."Skill" AS existing
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
        SELECT "Skill_id" INTO STRICT current_id
        FROM heroes_watch."Skill"
        WHERE "Game_id" = (resolved ->> (entry ->> 'Game_id'))::BIGINT AND "Code" = (entry ->> 'Code')
        FOR UPDATE;
        resolved := resolved || jsonb_build_object(entry ->> '_key', current_id);
        IF NOT EXISTS (
            SELECT 1 FROM heroes_watch."Skill"
            WHERE "Skill_id" = current_id
              AND "Game_id" IS NOT DISTINCT FROM (resolved ->> (entry ->> 'Game_id'))::BIGINT
              AND "Code" IS NOT DISTINCT FROM (entry ->> 'Code')
              AND "Name" IS NOT DISTINCT FROM (entry ->> 'Name')
              AND (entry -> 'Description' = 'null'::JSONB OR "Description" IS NOT DISTINCT FROM (entry ->> 'Description'))
              AND (entry -> 'IntroducedInExpansion_id' = 'null'::JSONB OR "IntroducedInExpansion_id" IS NOT DISTINCT FROM (resolved ->> (entry ->> 'IntroducedInExpansion_id'))::BIGINT)
              AND (entry -> 'MediaAsset_id' = 'null'::JSONB OR "MediaAsset_id" IS NOT DISTINCT FROM (resolved ->> (entry ->> 'MediaAsset_id'))::BIGINT)
        ) THEN
            RAISE EXCEPTION 'Existing Skill conflicts with %; transaction aborted.', entry ->> '_key';
        END IF;
    END LOOP;

    -- Faction: 7 rows.
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

    -- SkillHOMM7: 7 rows.
    FOR entry IN SELECT value FROM jsonb_array_elements(batch -> 'SkillHOMM7') LOOP
        INSERT INTO heroes_watch."SkillHOMM7" AS existing
            ("Skill_id", "SkillKind", "MagicSchool_id", "MaxMastery", "EffectByMastery")
        VALUES (
            (resolved ->> (entry ->> '_key'))::BIGINT,
            (entry ->> 'SkillKind')::heroes_watch."Enum__SkillHOMM7__SkillKind",
            (resolved ->> (entry ->> 'MagicSchool_id'))::BIGINT,
            (entry ->> 'MaxMastery')::heroes_watch."Enum__SkillHOMM7__MaxMastery",
            (entry ->> 'EffectByMastery')::JSONB
        )
        ON CONFLICT ("Skill_id") DO UPDATE SET
            "MagicSchool_id" = COALESCE(existing."MagicSchool_id", EXCLUDED."MagicSchool_id"),
            "EffectByMastery" = COALESCE(existing."EffectByMastery", EXCLUDED."EffectByMastery");
        current_id := (resolved ->> (entry ->> '_key'))::BIGINT;
        IF NOT EXISTS (
            SELECT 1 FROM heroes_watch."SkillHOMM7"
            WHERE "Skill_id" = current_id
              AND "SkillKind" IS NOT DISTINCT FROM (entry ->> 'SkillKind')::heroes_watch."Enum__SkillHOMM7__SkillKind"
              AND (entry -> 'MagicSchool_id' = 'null'::JSONB OR "MagicSchool_id" IS NOT DISTINCT FROM (resolved ->> (entry ->> 'MagicSchool_id'))::BIGINT)
              AND "MaxMastery" IS NOT DISTINCT FROM (entry ->> 'MaxMastery')::heroes_watch."Enum__SkillHOMM7__MaxMastery"
              AND (entry -> 'EffectByMastery' = 'null'::JSONB OR "EffectByMastery" IS NOT DISTINCT FROM (entry ->> 'EffectByMastery')::JSONB)
        ) THEN
            RAISE EXCEPTION 'Existing SkillHOMM7 conflicts with %; transaction aborted.', entry ->> '_key';
        END IF;
    END LOOP;

    -- FactionHOMM7: 7 rows.
    FOR entry IN SELECT value FROM jsonb_array_elements(batch -> 'FactionHOMM7') LOOP
        INSERT INTO heroes_watch."FactionHOMM7" AS existing
            ("Faction_id", "Alignment", "RacialSkill_id")
        VALUES (
            (resolved ->> (entry ->> '_key'))::BIGINT,
            (entry ->> 'Alignment')::heroes_watch."Enum__FactionHOMM7__Alignment",
            (resolved ->> (entry ->> 'RacialSkill_id'))::BIGINT
        )
        ON CONFLICT ("Faction_id") DO NOTHING;
        current_id := (resolved ->> (entry ->> '_key'))::BIGINT;
        IF NOT EXISTS (
            SELECT 1 FROM heroes_watch."FactionHOMM7"
            WHERE "Faction_id" = current_id
              AND "Alignment" IS NOT DISTINCT FROM (entry ->> 'Alignment')::heroes_watch."Enum__FactionHOMM7__Alignment"
              AND "RacialSkill_id" IS NOT DISTINCT FROM (resolved ->> (entry ->> 'RacialSkill_id'))::BIGINT
        ) THEN
            RAISE EXCEPTION 'Existing FactionHOMM7 conflicts with %; transaction aborted.', entry ->> '_key';
        END IF;
    END LOOP;

END
$homm7_import$;

SET CONSTRAINTS ALL IMMEDIATE;
COMMIT;

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
