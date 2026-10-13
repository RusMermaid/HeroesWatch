import test from "node:test";
import assert from "node:assert/strict";
import { readFileSync, writeFileSync, mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import path from "node:path";
import { spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";
import { selectContentClosure } from "./content-closure.mjs";
import { scenarioHomm3Annotations } from "./scenario-homm3-annotations.mjs";

const directory = path.dirname(fileURLToPath(import.meta.url));
const schema = JSON.parse(readFileSync(path.join(directory, "../schema/heroeswatch.schema.json")));
const catalog = JSON.parse(readFileSync(path.join(directory, "../data/heroeswatch.json")));
const seed = (table, key) => ({ table, key });
const select = (source, seeds) => ({ formatVersion: 1, tables: selectContentClosure(source, schema, seeds) });

function build(bundle) {
  const temporary = mkdtempSync(path.join(tmpdir(), "heroeswatch-closure-test-"));
  try {
    const input = path.join(temporary, "input.json");
    const output = path.join(temporary, "output.sql");
    writeFileSync(input, JSON.stringify(bundle));
    const validation = spawnSync(process.execPath, [path.join(directory, "validate.mjs"), input], { encoding: "utf8" });
    const result = spawnSync(process.execPath, [path.join(directory, "build-content-sql.mjs"), "--input", input, "--output", output], { encoding: "utf8" });
    const sql = result.status === 0 ? readFileSync(output, "utf8") : null;
    return { validation, result, sql };
  } finally {
    const resolved = path.resolve(temporary);
    assert.equal(path.dirname(resolved), path.resolve(tmpdir()));
    assert.ok(path.basename(resolved).startsWith("heroeswatch-closure-test-"));
    rmSync(resolved, { recursive: true, force: true });
  }
}

function withRequirementGroups() {
  const source = structuredClone(catalog);
  const base = source.tables.HeroClassAbility[0];
  for (const set of [1, 2]) {
    source.tables.HeroClassAbilityRequirementGroup.push({
      _key: `test.group.${set}`, Game_id: base.Game_id, HeroClass_id: base.HeroClass_id,
      Ability_id: base.Ability_id, RequirementSet: set, RequirementMode: "All",
    });
    source.tables.HeroClassAbility.push({ ...base, _key: `test.atom.${set}`, RequirementSet: set, RequirementMode: "All" });
  }
  return source;
}

test("cost closure includes the exact game's resource membership", () => {
  const cost = catalog.tables.CreatureResourceCost.find(row => row.Game_id === "homm3.game");
  const closure = select(catalog, [seed("CreatureResourceCost", cost._key)]);
  assert.equal(closure.tables.GameResource.length, 1);
  assert.equal(closure.tables.GameResource[0].Game_id, cost.Game_id);
  assert.equal(closure.tables.GameResource[0].Resource_id, cost.Resource_id);
  assert.ok(closure.tables.Resource.some(row => row._key === cost.Resource_id));
  const { result } = build(closure);
  assert.equal(result.status, 0, result.stderr);
});

test("a missing membership fails closure even when the global resource exists", () => {
  const source = structuredClone(catalog);
  const cost = source.tables.CreatureResourceCost.find(row => row.Game_id === "homm3.game");
  source.tables.GameResource = source.tables.GameResource.filter(row => row.Game_id !== cost.Game_id || row.Resource_id !== cost.Resource_id);
  assert.throws(() => select(source, [seed("CreatureResourceCost", cost._key)]), /Missing dependency .*Game_id,Resource_id/);
});

function withHomm8ResourceDetails() {
  const source = structuredClone(catalog);
  source.tables.ResourceHOMM8.push({
    _key: "resource.gold", ResourceRole: "Stockpile", Scope: "Kingdom",
    IsTradeable: true, IsMineProduced: true, IsPersistent: true,
    DefaultDailyIncome: null, Mechanics: null,
  });
  source.tables.AstrologyHOMM8.push({
    _key: "homm8.game", NeutralMagicSchool_id: "homm8.magicschool.neutral",
    AstrologyPointResource_id: "resource.astrology.points", InsightResource_id: "resource.law.points",
    MaximumSpellLevel: 5, FirstInsightThreshold: null, InsightThresholdIncrease: null,
    IncomeRule: null, UnlockRule: "Fixture unlock rule.", UpgradeRule: "Fixture upgrade rule.",
  });
  return source;
}

test("HOMM8 global details pull every declared per-game resource membership", () => {
  const source = withHomm8ResourceDetails();
  const faction = source.tables.FactionHOMM8[0];
  const factionClosure = select(source, [seed("FactionHOMM8", faction._key)]);
  assert.ok(factionClosure.tables.GameResource.some(row =>
    row.Game_id === "homm8.game" && row.Resource_id === faction.SignatureResource_id));

  const resourceClosure = select(source, [seed("ResourceHOMM8", "resource.gold")]);
  assert.ok(resourceClosure.tables.GameResource.some(row =>
    row.Game_id === "homm8.game" && row.Resource_id === "resource.gold"));

  const astrologyClosure = select(source, [seed("AstrologyHOMM8", "homm8.game")]);
  assert.deepEqual(new Set(astrologyClosure.tables.GameResource.map(row => row.Resource_id)),
    new Set(["resource.astrology.points", "resource.law.points"]));
  const { result } = build(astrologyClosure);
  assert.equal(result.status, 0, result.stderr);
});

test("HOMM8 resource memberships resolve mixed physical and symbolic aliases", () => {
  const source = withHomm8ResourceDetails();
  const game = source.tables.Game.find(row => row.SeriesCode === "HOMM8");
  const resource = source.tables.Resource.find(row => row._key === "resource.gems");
  const faction = source.tables.FactionHOMM8.find(row => row.SignatureResource_id === resource._key);
  const membership = source.tables.GameResource.find(row =>
    row.Game_id === game._key && row.Resource_id === resource._key);
  game.Game_id = 88001;
  resource.Resource_id = 88002;
  faction.SignatureResource_id = 88002;
  membership.Game_id = 88001;
  membership.Resource_id = 88002;
  membership.GameResource_cid = "physical.homm8.gems.membership";

  const closure = select(source, [seed("FactionHOMM8", faction._key)]);
  assert.deepEqual(closure.tables.Game.map(row => row._key), [game._key]);
  assert.deepEqual(closure.tables.Resource.map(row => row._key), [resource._key]);
  assert.deepEqual(closure.tables.GameResource.map(row => row._key), [membership._key]);
});

test("each HOMM8 scoped global resource reference fails closed without membership", () => {
  for (const { table, key, resource } of [
    { table: "FactionHOMM8", key: catalog.tables.FactionHOMM8[0]._key,
      resource: catalog.tables.FactionHOMM8[0].SignatureResource_id },
    { table: "ResourceHOMM8", key: "resource.gold", resource: "resource.gold" },
    { table: "AstrologyHOMM8", key: "homm8.game", resource: "resource.astrology.points" },
  ]) {
    const source = withHomm8ResourceDetails();
    source.tables.GameResource = source.tables.GameResource.filter(row =>
      row.Game_id !== "homm8.game" || row.Resource_id !== resource);
    assert.throws(() => select(source, [seed(table, key)]),
      new RegExp(`Missing HOMM8 resource membership ${table.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")}`));
  }
});

test("a missing HOMM8 membership fails after physical resource aliases are resolved", () => {
  const source = withHomm8ResourceDetails();
  const game = source.tables.Game.find(row => row.SeriesCode === "HOMM8");
  const faction = source.tables.FactionHOMM8[0];
  const resource = source.tables.Resource.find(row => row._key === faction.SignatureResource_id);
  const membership = source.tables.GameResource.find(row =>
    row.Game_id === game._key && row.Resource_id === resource._key);
  game.Game_id = 88101;
  resource.Resource_id = 88102;
  faction.SignatureResource_id = 88102;
  membership.Game_id = 88101;
  membership.Resource_id = 88102;
  source.tables.GameResource = source.tables.GameResource.filter(row => row !== membership);
  assert.throws(() => select(source, [seed("FactionHOMM8", faction._key)]),
    /Missing HOMM8 resource membership FactionHOMM8/);
});

test("a grouped atom pulls its exact prerequisite group without unrelated alternatives", () => {
  const source = withRequirementGroups();
  const closure = select(source, [seed("HeroClassAbility", "test.atom.1")]);
  assert.deepEqual(closure.tables.HeroClassAbilityRequirementGroup.map(row => row._key), ["test.group.1"]);
  assert.deepEqual(closure.tables.HeroClassAbility.map(row => row._key), ["test.atom.1"]);
  const { result } = build(closure);
  assert.equal(result.status, 0, result.stderr);
});

test("a null requirement tuple does not pull another group's atoms", () => {
  const source = withRequirementGroups();
  const ungrouped = source.tables.HeroClassAbility[0];
  assert.equal(ungrouped.RequirementSet, null);
  const closure = select(source, [seed("HeroClassAbility", ungrouped._key)]);
  assert.equal(closure.tables.HeroClassAbilityRequirementGroup.length, 0);
});

test("mode is part of the composite prerequisite target", () => {
  const source = withRequirementGroups();
  source.tables.HeroClassAbility.find(row => row._key === "test.atom.1").RequirementMode = "Any";
  assert.throws(() => select(source, [seed("HeroClassAbility", "test.atom.1")]), /Missing dependency .*RequirementSet,RequirementMode/);
});

test("campaign hero closure includes the exact campaign-scenario membership", () => {
  const hero = catalog.tables.CampaignHero.find((row) => row.StartingScenario_id != null);
  assert.ok(hero);
  const closure = select(catalog, [seed("CampaignHero", hero._key)]);
  assert.ok(closure.tables.CampaignScenario.some((row) =>
    row.Game_id === hero.Game_id && row.Campaign_id === hero.Campaign_id && row.Scenario_id === hero.StartingScenario_id));
  const { result, sql } = build(closure);
  assert.equal(result.status, 0, result.stderr);
  assert.match(sql, /Requires the HeroesWatch schema through postgres\/migrations\/0006_catalog_guards\.sql/);
});

test("generated display fields are omitted from import INSERT and UPDATE statements", () => {
  const detail = catalog.tables.CreatureHOMM1[0];
  const closure = select(catalog, [seed("CreatureHOMM1", detail._key)]);
  const { result, sql } = build(closure);
  assert.equal(result.status, 0, result.stderr);
  assert.doesNotMatch(sql, /"SpeedName"/);
});

test("the complete Heroes III scenario-rule subset includes every reviewed annotation dependency", () => {
  const ruleRows = catalog.tables.ScenarioHOMM3.filter((row) => scenarioHomm3Annotations(row).length > 0);
  assert.ok(ruleRows.length > 0);
  const closure = select(catalog, ruleRows.map((row) => seed("ScenarioHOMM3", row._key)));
  for (const row of ruleRows) for (const reference of scenarioHomm3Annotations(row)) {
    assert.ok(closure.tables[reference.table].some((target) => target._key === reference.key),
      `${row._key}/${reference.path}/${reference.key}`);
  }
  const { validation, result } = build(closure);
  assert.equal(validation.status, 0, validation.stderr);
  assert.equal(result.status, 0, result.stderr);
});

test("a missing Heroes III scenario annotation target stops closure", () => {
  const source = structuredClone(catalog);
  const row = source.tables.ScenarioHOMM3.find((candidate) => candidate.VictoryConditions?.artifact?.artifactKey);
  assert.ok(row);
  row.VictoryConditions.artifact.artifactKey = "homm3.artifact.missing";
  assert.throws(() => select(source, [seed("ScenarioHOMM3", row._key)]),
    /Missing ScenarioHOMM3 annotation dependency .*VictoryConditions\.artifact.*homm3\.artifact\.missing/);
});

test("Heroes III resource annotations pull the exact GameResource membership", () => {
  const row = catalog.tables.ScenarioHOMM3.find((candidate) =>
    scenarioHomm3Annotations(candidate).some((reference) => reference.requiresGameResource));
  assert.ok(row);
  const closure = select(catalog, [seed("ScenarioHOMM3", row._key)]);
  for (const reference of scenarioHomm3Annotations(row).filter((item) => item.requiresGameResource)) {
    assert.ok(closure.tables.GameResource.some((membership) =>
      membership.Game_id === "homm3.game" && membership.Resource_id === reference.key));
  }
});

test("closure does not traverse arbitrary unreviewed JSON key-shaped values", () => {
  const source = structuredClone(catalog);
  const row = source.tables.ScenarioHOMM3.find((candidate) => candidate.VictoryConditions != null);
  row.VictoryConditions.unreviewed = { heroKey: "homm3.hero.missing" };
  const closure = select(source, [seed("ScenarioHOMM3", row._key)]);
  assert.equal(closure.tables.Hero.some((hero) => hero._key === "homm3.hero.missing"), false);
});

test("omitted shared primary keys resolve through the parent catalog identity", () => {
  const detail = catalog.tables.CreatureHOMM3[0];
  assert.equal(detail.Creature_id, undefined);
  const closure = select(catalog, [seed("CreatureHOMM3", detail._key)]);
  assert.ok(closure.tables.Creature.some(row => row._key === detail._key));
  const { result } = build(closure);
  assert.equal(result.status, 0, result.stderr);
});

test("closure canonicalizes mixed physical and symbolic game references", () => {
  const source = structuredClone(catalog);
  source.tables.Game.find(row => row._key === "homm3.game").Game_id = 991001;
  const cost = source.tables.CreatureResourceCost.find(row => row.Game_id === "homm3.game");
  cost.Game_id = 991001;
  const closure = select(source, [seed("CreatureResourceCost", cost._key)]);
  assert.equal(closure.tables.Game.length, 1);
  assert.equal(closure.tables.Game[0]._key, "homm3.game");
  assert.equal(closure.tables.GameResource.length, 1);
});

function withTextPrimaryReference(usePhysical) {
  const source = structuredClone(catalog);
  const lore = source.tables.Lore.find(row => source.tables.CampaignHero.some(hero => hero.Game_id === row.Game_id));
  const hero = source.tables.CampaignHero.find(row => row.Game_id === lore.Game_id);
  hero.CampaignHero_cid = "existing.physical.campaign.hero";
  source.tables.LoreFull.push({ _key: "test.lore.reference", Game_id: lore.Game_id, Lore_id: lore._key,
    CampaignHero_cid: usePhysical ? hero.CampaignHero_cid : hero._key, LinkRole: "Related" });
  return select(source, [seed("LoreFull", "test.lore.reference")]);
}

test("text junction identities can differ from their portable import keys", () => {
  const { validation, result } = build(withTextPrimaryReference(false));
  assert.equal(validation.status, 0, validation.stderr);
  assert.equal(result.status, 0, result.stderr);
});

test("physical text junction references accepted by validation also import", () => {
  const { validation, result } = build(withTextPrimaryReference(true));
  assert.equal(validation.status, 0, validation.stderr);
  assert.equal(result.status, 0, result.stderr);
});

test("nullable LoreFull natural keys are rejected before import", () => {
  const closure = withTextPrimaryReference(false);
  const row = closure.tables.LoreFull[0];
  closure.tables.LoreFull.push({ ...row, _key: "test.duplicate.lore.reference" });
  const { validation, result } = build(closure);
  assert.equal(validation.status, 1);
  assert.match(validation.stderr, /duplicates \(Game_id, Lore_id, Hero_id, CampaignHero_cid, Campaign_id, Scenario_id, Map_id, LinkRole, Faction_id\)/);
  assert.equal(result.status, 1);
  assert.match(result.stderr, /duplicates \(Game_id, Lore_id, Hero_id, CampaignHero_cid, Campaign_id, Scenario_id, Map_id, LinkRole, Faction_id\)/);
});

test("nullable natural-key duplicates are rejected after reference aliases are resolved", () => {
  const closure = withTextPrimaryReference(false);
  const row = closure.tables.LoreFull[0];
  closure.tables.LoreFull.push({ ...row, _key: "test.alias.duplicate.lore.reference",
    CampaignHero_cid: "existing.physical.campaign.hero" });
  const { validation, result } = build(closure);
  assert.equal(validation.status, 1);
  assert.match(validation.stderr, /duplicates \(Game_id, Lore_id, Hero_id, CampaignHero_cid, Campaign_id, Scenario_id, Map_id, LinkRole, Faction_id\)/);
  assert.equal(result.status, 1);
  assert.match(result.stderr, /duplicates \(Game_id, Lore_id, Hero_id, CampaignHero_cid, Campaign_id, Scenario_id, Map_id, LinkRole, Faction_id\)/);
});

test("portable keys cannot shadow another row's explicit text primary key", () => {
  const source = structuredClone(catalog);
  const [first, second] = source.tables.CampaignHero;
  first.CampaignHero_cid = second._key;
  assert.throws(() => select(source, [seed("CampaignHero", first._key)]), /CampaignHero has ambiguous identity alias/);
  const { validation, result } = build(source);
  assert.equal(validation.status, 1);
  assert.match(validation.stderr, /CampaignHero has ambiguous identity alias/);
  assert.equal(result.status, 1);
  assert.match(result.stderr, /CampaignHero has ambiguous identity alias/);
});
