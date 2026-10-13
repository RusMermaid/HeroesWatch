#!/usr/bin/env node

import { readFile } from "node:fs/promises";
import { pathToFileURL } from "node:url";

const reviewedApplicableGaps = {
  HOMM1: ["FactionSpell", "LoreFull", "MapObjectPresence", "MapTerrain", "TownScreenBuilding"],
  HOMM2: ["CampaignHero", "CreatureSpell", "FactionSpell", "LoreFull", "MapObjectPresence", "MapTerrain", "TownScreenBuilding"],
  HOMM3: ["LoreFull"],
  HOMM4: ["BuildingRequirement", "BuildingResourceCost", "CreatureAbility", "HeroSkill", "MapObjectPresence", "MapTerrain", "TownScreenBuilding"],
  HOMM5: ["FactionSpell", "LoreFull", "MapObjectPresence", "MapTerrain", "TownScreenBuilding"],
  HOMM6: ["BuildingResourceCost", "CreatureAbility", "HeroSkill", "MapObjectPresence", "MapTerrain", "TownScreenBuilding"],
  HOMM7: ["BuildingResourceCost", "CreatureAbility", "CreatureSpell", "FactionSpell", "HeroSkill", "LoreFull", "MapObjectPresence", "MapTerrain", "TownScreenBuilding"],
  HOMM8: ["CreatureSpell", "FactionSpell", "HeroClassAbility", "LoreFull", "MapObjectPresence", "MapTerrain", "TownScreenBuilding"],
};

function identityAliases(tableByName, tables, tableName) {
  const table = tableByName.get(tableName);
  const primary = table.primaryKey[0];
  const aliases = new Map();
  for (const row of tables[tableName] ?? []) {
    aliases.set(String(row._key), row._key);
    if (row[primary] != null) aliases.set(String(row[primary]), row._key);
  }
  return aliases;
}

const canonical = (aliases, value) => value == null ? null : aliases.get(String(value)) ?? String(value);

export function buildJunctionCoverage(schema, data) {
  const tables = data.tables;
  const tableByName = new Map(schema.tables.map(table => [table.name, table]));
  const games = tables.Game.filter(game => /^HOMM[1-8]$/.test(game.SeriesCode))
    .sort((a, b) => Number(a.SeriesCode.slice(4)) - Number(b.SeriesCode.slice(4)));
  const gameAliases = identityAliases(tableByName, tables, "Game");
  const gameCodeByKey = new Map(games.map(game => [game._key, game.SeriesCode]));
  const rowGameCode = row => gameCodeByKey.get(canonical(gameAliases, row.Game_id));
  const junctions = schema.tables.filter(table => table.kind === "junction")
    .sort((a, b) => a.name.localeCompare(b.name));

  const counts = junctions.map(table => ({
    table: table.name,
    byGame: Object.fromEntries(games.map(game => [game.SeriesCode,
      (tables[table.name] ?? []).filter(row => rowGameCode(row) === game.SeriesCode).length])),
    total: (tables[table.name] ?? []).length,
  }));
  const countByTable = new Map(counts.map(item => [item.table, item.byGame]));

  function goldCoverage(detailTable, junctionTable, endpoint) {
    const gameCode = detailTable.match(/HOMM[1-8]/)?.[0];
    const game = games.find(row => row.SeriesCode === gameCode);
    const gold = tables.Resource.find(row => row.Code === "GOLD");
    if (!game || !gold) return null;
    const junctionSchema = tableByName.get(junctionTable);
    const endpointTarget = junctionSchema.foreignKeys.find(fk => fk.columns.length === 1 && fk.columns[0] === endpoint)?.referencedTable;
    if (!endpointTarget) throw new Error(`${junctionTable}.${endpoint} has no scalar FK target`);
    const endpointAliases = identityAliases(tableByName, tables, endpointTarget);
    const resourceAliases = identityAliases(tableByName, tables, "Resource");
    const goldKey = canonical(resourceAliases, gold._key);
    const detailPk = tableByName.get(detailTable).primaryKey[0];
    const scalar = tables[detailTable].filter(row => row.GoldCost != null).map(row => ({
      row, endpoint: canonical(endpointAliases, row[detailPk] ?? row._key),
    }));
    const linkedRows = tables[junctionTable].filter(row =>
      rowGameCode(row) === gameCode && canonical(resourceAliases, row.Resource_id) === goldKey);
    const linked = new Map();
    for (const row of linkedRows) {
      const key = canonical(endpointAliases, row[endpoint]);
      if (!linked.has(key)) linked.set(key, []);
      linked.get(key).push(row);
    }
    const missing = scalar.filter(({ endpoint: key }) => !linked.has(key)).map(({ row }) => row._key);
    const amountMismatches = scalar.filter(({ row, endpoint: key }) =>
      linked.has(key) && linked.get(key).some(relation => relation.Amount !== row.GoldCost)).map(({ row }) => row._key);
    const duplicateEndpoints = [...linked].filter(([, rows]) => rows.length > 1).map(([endpointKey, rows]) => ({
      endpointKey, rowKeys: rows.map(row => row._key), amounts: rows.map(row => row.Amount),
    }));
    const conflictingMultipleCosts = duplicateEndpoints.filter(item => new Set(item.amounts).size > 1);
    return { detailTable, junctionTable, scalarRows: scalar.length, linkedRows: linkedRows.length,
      linkedEndpoints: linked.size, missing, amountMismatches, duplicateEndpoints, conflictingMultipleCosts };
  }

  const spellAliases = identityAliases(tableByName, tables, "Spell");
  const spellSchoolCoverage = Object.fromEntries(games.map(game => {
    const spells = tables.Spell.filter(row => rowGameCode(row) === game.SeriesCode);
    const links = tables.SpellMagicSchool.filter(row => rowGameCode(row) === game.SeriesCode);
    const linked = new Set(links.map(row => canonical(spellAliases, row.Spell_id)));
    return [game.SeriesCode, { spells: spells.length, links: links.length,
      unlinked: spells.filter(row => !linked.has(row._key)).map(row => row._key) }];
  }));

  const campaignAliases = identityAliases(tableByName, tables, "Campaign");
  const scenarioAliases = identityAliases(tableByName, tables, "Scenario");
  const campaignScenarioKeys = new Set(tables.CampaignScenario.map(row => [
    rowGameCode(row), canonical(campaignAliases, row.Campaign_id), canonical(scenarioAliases, row.Scenario_id),
  ].join("\u0000")));
  const invalidStartingScenarios = tables.CampaignHero.filter(row => row.StartingScenario_id != null &&
    !campaignScenarioKeys.has([rowGameCode(row), canonical(campaignAliases, row.Campaign_id),
      canonical(scenarioAliases, row.StartingScenario_id)].join("\u0000"))).map(row => row._key);

  const knownApplicableEmpty = Object.fromEntries(games.map(game => [game.SeriesCode,
    (reviewedApplicableGaps[game.SeriesCode] ?? []).filter(table => countByTable.get(table)?.[game.SeriesCode] === 0)]));

  return {
    generatedFrom: { schema: "src/db/schema/heroeswatch.schema.json", data: "src/db/data/heroeswatch.json" },
    scope: "Heroes of Might and Magic I-VIII",
    games: games.map(({ _key, SeriesCode }) => ({ key: _key, seriesCode: SeriesCode })),
    junctionCount: junctions.length,
    counts,
    classificationPolicy: "Counts and source classifications are separate. Zero rows never imply not applicable, and filled rows are omitted from knownApplicableEmpty.",
    knownApplicableEmpty,
    derivedChecks: {
      goldCostRelations: [
        goldCoverage("ArtifactHOMM1", "ArtifactResourceCost", "Artifact_id"),
        goldCoverage("BuildingHOMM1", "BuildingResourceCost", "Building_id"),
        goldCoverage("BuildingHOMM2", "BuildingResourceCost", "Building_id"),
        goldCoverage("CreatureHOMM1", "CreatureResourceCost", "Creature_id"),
        goldCoverage("CreatureHOMM2", "CreatureResourceCost", "Creature_id"),
      ],
      spellMagicSchool: spellSchoolCoverage,
      invalidCampaignHeroStartingScenarios: invalidStartingScenarios,
    },
  };
}

async function main() {
  const root = new URL("../", import.meta.url);
  const schema = JSON.parse(await readFile(new URL("schema/heroeswatch.schema.json", root), "utf8"));
  const data = JSON.parse(await readFile(new URL("data/heroeswatch.json", root), "utf8"));
  console.log(JSON.stringify(buildJunctionCoverage(schema, data), null, 2));
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) await main();
