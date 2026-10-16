-- Read-only browsing queries for the completed reference catalog.
-- Run in the intended HeroesWatch database. No missing statistic becomes zero.
-- Each statement is independent and works in psql, DBeaver or pgAdmin.

-- Every generic creature stays visible, including creatures whose required
-- native statistics have not yet been independently established.
WITH details AS (
  SELECT "Creature_id", 'HOMM1' AS band, to_jsonb(d) - 'Creature_id' AS stats FROM heroes_watch."CreatureHOMM1" d
  UNION ALL SELECT "Creature_id", 'HOMM2', to_jsonb(d) - 'Creature_id' FROM heroes_watch."CreatureHOMM2" d
  UNION ALL SELECT "Creature_id", 'HOMM3', to_jsonb(d) - 'Creature_id' FROM heroes_watch."CreatureHOMM3" d
  UNION ALL SELECT "Creature_id", 'HOMM4', to_jsonb(d) - 'Creature_id' FROM heroes_watch."CreatureHOMM4" d
  UNION ALL SELECT "Creature_id", 'HOMM5', to_jsonb(d) - 'Creature_id' FROM heroes_watch."CreatureHOMM5" d
  UNION ALL SELECT "Creature_id", 'HOMM6', to_jsonb(d) - 'Creature_id' FROM heroes_watch."CreatureHOMM6" d
  UNION ALL SELECT "Creature_id", 'HOMM7', to_jsonb(d) - 'Creature_id' FROM heroes_watch."CreatureHOMM7" d
  UNION ALL SELECT "Creature_id", 'HOMM8', to_jsonb(d) - 'Creature_id' FROM heroes_watch."CreatureHOMM8" d
), abilities AS (
  SELECT ca."Creature_id", jsonb_agg(jsonb_build_object(
    'ability_id', a."Ability_id", 'name', a."Name", 'description', a."Description",
    'parameters', ca."Parameters") ORDER BY a."Name", a."Ability_id") AS abilities
  FROM heroes_watch."CreatureAbility" ca
  JOIN heroes_watch."Ability" a ON a."Game_id" = ca."Game_id" AND a."Ability_id" = ca."Ability_id"
  GROUP BY ca."Creature_id"
)
SELECT g."SeriesCode", c."Code", c."Name",
       d.stats ->> 'Tier' AS "Tier",
       (d.stats ->> 'Speed')::SMALLINT AS "Speed",
       d.stats ->> 'SpeedName' AS "SpeedName", d.band AS detail_band,
       d."Creature_id" IS NOT NULL AS has_native_detail,
       d.stats AS native_statistics, a.abilities
FROM heroes_watch."Creature" c
JOIN heroes_watch."Game" g ON g."Game_id" = c."Game_id"
LEFT JOIN details d ON d."Creature_id" = c."Creature_id"
LEFT JOIN abilities a ON a."Creature_id" = c."Creature_id"
ORDER BY g."DisplayOrder", c."Name", c."Creature_id";

-- Campaign roles always resolve to the single Hero catalog.
SELECT g."SeriesCode", c."Name" AS campaign, h."Name" AS hero,
       ch."IsCampaignHero", ch."CampaignRole", s."Name" AS starting_scenario
FROM heroes_watch."CampaignHero" ch
JOIN heroes_watch."Game" g ON g."Game_id" = ch."Game_id"
JOIN heroes_watch."Campaign" c ON c."Game_id" = ch."Game_id" AND c."Campaign_id" = ch."Campaign_id"
JOIN heroes_watch."Hero" h ON h."Game_id" = ch."Game_id" AND h."Hero_id" = ch."Hero_id"
LEFT JOIN heroes_watch."Scenario" s ON s."Game_id" = ch."Game_id" AND s."Scenario_id" = ch."StartingScenario_id"
ORDER BY g."DisplayOrder", c."Name", h."Name";

-- Shared resources plus optional classic details; an empty subtype must not
-- accidentally hide a valid game membership.
SELECT g."SeriesCode", r."Name", gr."ResourceClass" AS game_class,
       classic."ResourceClass" AS classic_class, classic."DefaultMineYield"
FROM heroes_watch."GameResource" gr
JOIN heroes_watch."Game" g ON g."Game_id" = gr."Game_id"
JOIN heroes_watch."Resource" r ON r."Resource_id" = gr."Resource_id"
LEFT JOIN heroes_watch."ResourceHOMM1To5" classic ON classic."Resource_id" = r."Resource_id"
  AND g."SeriesCode" IN ('HOMM1','HOMM2','HOMM3','HOMM4','HOMM5')
ORDER BY g."DisplayOrder", r."Name";

-- Version-specific rune costs are relational, not hidden in a JSON payload.
SELECT s."Name" AS rune, rc."Ruleset", r."Name" AS resource, rc."Amount"
FROM heroes_watch."SpellResourceCostHOMM5" rc
JOIN heroes_watch."Spell" s ON s."Game_id" = rc."Game_id" AND s."Spell_id" = rc."Spell_id"
JOIN heroes_watch."GameResource" gr ON gr."Game_id" = rc."Game_id" AND gr."Resource_id" = rc."Resource_id"
JOIN heroes_watch."Resource" r ON r."Resource_id" = gr."Resource_id"
ORDER BY s."Name", rc."Ruleset", r."Name";
