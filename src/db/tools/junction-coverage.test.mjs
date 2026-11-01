import test from "node:test";
import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import { buildJunctionCoverage } from "./junction-coverage.mjs";

const root = new URL("../", import.meta.url);
const schema = JSON.parse(await readFile(new URL("schema/heroeswatch.schema.json", root), "utf8"));
const catalog = JSON.parse(await readFile(new URL("data/heroeswatch.json", root), "utf8"));

test("junction coverage reports all 29 junctions across Heroes I-VIII", () => {
  const report = buildJunctionCoverage(schema, catalog);
  assert.equal(report.junctionCount, 29);
  assert.deepEqual(report.games.map(game => game.seriesCode),
    ["HOMM1", "HOMM2", "HOMM3", "HOMM4", "HOMM5", "HOMM6", "HOMM7", "HOMM8"]);
  assert.equal(report.counts.length, 29);
  for (const item of report.counts) {
    assert.deepEqual(Object.keys(item.byGame), report.games.map(game => game.seriesCode));
  }
  const counts = new Map(report.counts.map(item => [item.table, item.byGame]));
  for (const [game, tables] of Object.entries(report.knownApplicableEmpty)) {
    for (const table of tables) assert.equal(counts.get(table)[game], 0, `${game}.${table} is no longer empty`);
  }
  assert.ok(!report.knownApplicableEmpty.HOMM1.includes("CampaignHero"));
  assert.ok(!report.knownApplicableEmpty.HOMM5.includes("FactionNativeTerrainHOMM5"));
  assert.deepEqual(report.derivedChecks.invalidCampaignHeroStartingScenarios, []);
});

test("gold derivation checks preserve zero, resolve aliases, and expose conflicting duplicates", () => {
  const data = structuredClone(catalog);
  const game = data.tables.Game.find(row => row._key === "homm1.game");
  const gold = data.tables.Resource.find(row => row.Code === "GOLD");
  const detail = data.tables.ArtifactHOMM1.find(row => row.GoldCost != null);
  const parent = data.tables.Artifact.find(row => row._key === detail._key);
  const cost = data.tables.ArtifactResourceCost.find(row => row.Game_id === "homm1.game" && row.Artifact_id === detail._key && row.Resource_id === gold._key);
  game.Game_id = 101;
  gold.Resource_id = 202;
  parent.Artifact_id = 303;
  detail.Artifact_id = 303;
  detail.GoldCost = 0;
  cost.Game_id = 101;
  cost.Resource_id = 202;
  cost.Artifact_id = 303;
  cost.Amount = 0;

  let result = buildJunctionCoverage(schema, data).derivedChecks.goldCostRelations
    .find(item => item.detailTable === "ArtifactHOMM1");
  assert.equal(result.scalarRows, 1);
  assert.equal(result.linkedRows, 1);
  assert.deepEqual(result.missing, []);
  assert.deepEqual(result.amountMismatches, []);

  data.tables.ArtifactResourceCost.push({ ...cost, _key: "test.conflicting.zero.cost",
    Game_id: "homm1.game", Resource_id: gold._key, Artifact_id: parent._key, Amount: 1 });
  result = buildJunctionCoverage(schema, data).derivedChecks.goldCostRelations
    .find(item => item.detailTable === "ArtifactHOMM1");
  assert.equal(result.linkedRows, 2);
  assert.equal(result.linkedEndpoints, 1);
  assert.equal(result.duplicateEndpoints.length, 1);
  assert.equal(result.conflictingMultipleCosts.length, 1);
  assert.deepEqual(result.amountMismatches, [detail._key]);
});
