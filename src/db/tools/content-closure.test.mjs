import test from "node:test";
import assert from "node:assert/strict";
import { readFileSync, writeFileSync, mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import path from "node:path";
import { spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";
import { selectContentClosure } from "./content-closure.mjs";

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
    return { validation, result };
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

test("nullable LoreFull natural keys cannot create ambiguous duplicate import identities", () => {
  const closure = withTextPrimaryReference(false);
  const row = closure.tables.LoreFull[0];
  closure.tables.LoreFull.push({ ...row, _key: "test.duplicate.lore.reference" });
  const { validation, result } = build(closure);
  // PostgreSQL's legacy nullable UNIQUE allows this; the importer must refuse
  // because two portable identities would resolve to the same business row.
  assert.equal(validation.status, 0, validation.stderr);
  assert.equal(result.status, 1);
  assert.match(result.stderr, /business key also supplied by .*nullable key members/);
});

test("nullable natural-key duplicates are detected after reference aliases are resolved", () => {
  const closure = withTextPrimaryReference(false);
  const row = closure.tables.LoreFull[0];
  closure.tables.LoreFull.push({ ...row, _key: "test.alias.duplicate.lore.reference",
    CampaignHero_cid: "existing.physical.campaign.hero" });
  const { validation, result } = build(closure);
  assert.equal(validation.status, 0, validation.stderr);
  assert.equal(result.status, 1);
  assert.match(result.stderr, /business key also supplied by .*nullable key members/);
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
