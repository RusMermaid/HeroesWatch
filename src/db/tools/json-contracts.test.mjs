import test from "node:test";
import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { jsonColumnSchema, validateJsonColumn, validateJsonSchema } from "./json-contracts.mjs";

const schema = JSON.parse(readFileSync(new URL("../schema/heroeswatch.schema.json", import.meta.url)));
const bundle = JSON.parse(readFileSync(new URL("../data/heroeswatch.json", import.meta.url)));
const check = (table, column, value) => validateJsonColumn(table, column, value);

test("every JSONB column has an explicit contract and current non-null values satisfy it", () => {
  let count = 0;
  for (const table of schema.tables) for (const column of table.columns.filter((column) => column.sqlDesignerType === "JSONB")) {
    count++;
    assert.ok(Object.keys(jsonColumnSchema(table.name, column.name)).length, `${table.name}.${column.name}`);
    for (const row of bundle.tables[table.name] ?? []) if (row[column.name] != null) {
      assert.equal(check(table.name, column.name, row[column.name]), null, `${row._key}.${column.name}`);
    }
  }
  assert.equal(count, 141);
  assert.throws(() => jsonColumnSchema("NewUnreviewedTable", "Effect"), /No JSON contract/);
});

test("contracts reject wrong container types and misspelled or wrong scalar fields", () => {
  assert.match(check("ArtifactHOMM3", "Effect", "attack +2"), /must be object/);
  assert.match(check("ArtifactHOMM3", "Effect", { primarySkillBonuses: { attack: "2" } }), /attack must be number/);
  assert.match(check("ArtifactHOMM3", "Effect", { primarySkillBonuses: { attak: 2 } }), /not an allowed field/);
  assert.match(check("AdventureObjectHOMM3", "Interaction", { weeklyAccumulation: 1, requiresHeroVisit: true }), /must be boolean/);
  assert.match(check("ArtifactHOMM2", "Effect", { modifiers: [{ kind: "luck", value: 2 }] }), /isCurse is required/);
  assert.equal(check("ArtifactHOMM2", "Effect", { modifiers: [{ kind: "blind_spell_immunity", value: null, isCurse: false }] }), null);
  assert.match(check("ArtifactHOMM1", "Effect", {}), /must not be empty/);
});

test("the existing source scalar exceptions remain narrow", () => {
  assert.equal(check("FactionMagicSchoolHOMM5", "GuaranteedSlotsPerCircle", 1), null);
  assert.match(check("FactionMagicSchoolHOMM5", "GuaranteedSlotsPerCircle", { 1: 1 }), /must be integer/);
  assert.match(check("FactionMagicSchoolHOMM5", "GuaranteedSlotsPerCircle", 0.5), /must be integer/);
  assert.equal(check("HeroClassHOMM1", "ClassEffect", "Improves morale."), null);
  assert.match(check("HeroClassHOMM1", "ClassEffect", ["Improves morale."]), /must be string/);
});

test("source references require usable locators and positive page numbers", () => {
  assert.equal(check("Lore", "SourceLinks", [{ title: "Manual", url: "manual:abc123#pdf-pages=5" }]), null);
  assert.equal(check("Lore", "SourceLinks", [{ uri: "manuals/files/39781a0a67cd/manual.pdf", pdfPage: 2 }]), null);
  assert.match(check("Lore", "SourceLinks", [{ uri: "manuals/files/39781a0a67cd/manual.pdf", pdfPage: 0 }]), />= 1/);
  assert.match(check("Lore", "SourceLinks", [{ title: "Manual", url: "javascript:alert(1)" }]), /invalid format/);
  assert.match(check("Lore", "SourceLinks", [{ title: "Manual", sha256: "wrong", pdfPage: 2 }]), /invalid format/);
});

test("source mastery names and probability totals cannot silently drift", () => {
  const profile = { Unskilled: { formula: "10 * Magic" }, Novice: { formula: "12 * Magic" }, Expert: { formula: "14 * Magic" }, Master: { formula: "20 * Magic" } };
  assert.equal(check("SpellHOMM7", "EffectByMastery", profile), null);
  assert.match(check("SpellHOMM7", "EffectByMastery", { ...profile, Basic: { formula: "bad rank" } }), /Basic is not an allowed field/);
  profile.Master.formula = 20;
  assert.match(check("SpellHOMM7", "EffectByMastery", profile), /formula must be string/);
  const chances = { levels2To9: { Attack: 25, Defense: 25, Power: 25, Knowledge: 25 }, levels10Plus: { Attack: 25, Defense: 25, Power: 25, Knowledge: 24 } };
  assert.match(check("HeroClassHOMM3", "PrimarySkillChances", chances), /must total 100/);
});

test("weapon growth thresholds and army ranges are bounded and internally consistent", () => {
  assert.equal(check("ArtifactHOMM6", "Effect", { maxLevel: 2, experienceThresholds: [0, 100], bonuses: [{ level: 2, attribute: "Might Power", value: 3 }] }), null);
  assert.match(check("ArtifactHOMM6", "Effect", { maxLevel: 2, experienceThresholds: [0, 0], bonuses: [{ attribute: "Might Power", value: 3 }] }), /increase/);
  assert.match(check("ArtifactHOMM6", "Effect", { maxLevel: 2, experienceThresholds: [0, 100], bonuses: [{ level: 3, attribute: "Might Power", value: 3 }] }), /exceeds/);
  assert.equal(check("HeroHOMM3", "StartingArmy", [{ creatureKey: "homm3.creature.pikeman", minimum: 5, maximum: 10 }]), null);
  assert.match(check("HeroHOMM3", "StartingArmy", [{ creatureKey: "homm3.creature.pikeman", minimum: 10, maximum: 5 }]), /minimum exceeds/);
  assert.match(check("HeroHOMM3", "StartingArmy", [{ creatureKey: "homm3.creature.pikeman" }]), /requires count/);
});

test("unreviewed mechanics fail closed and schema vocabulary cannot be ignored", () => {
  assert.match(check("MapHOMM8", "TemplateDefinition", { anything: "goes" }), /no reviewed JSON profile/);
  assert.throws(() => validateJsonSchema({ type: "number", unimplementedKeyword: true }, 1), /Unsupported JSON contract keyword/);
});

test("campaign conditions require provenance and closed, typed native counter predicates", () => {
  const condition = { description: "Complete the previous mission.", source: "native:campaign/mainStory/storyHub.json",
    nativeCounters: { logicOperation: "And", array: [{ counterSid: "mission_complete", operation: "==", value: 1 }] } };
  assert.equal(check("ScenarioConnection", "Condition", condition), null);
  assert.equal(check("CampaignScenario", "AvailabilityCondition", { description: "Available to the Knight campaign.", source: "manual:homm1#pdf-page=78" }), null);
  assert.match(check("ScenarioConnection", "Condition", { description: "Complete the previous mission." }), /source is required/);
  assert.match(check("ScenarioConnection", "Condition", { ...condition, nativeCounters: { ...condition.nativeCounters,
    array: [{ counterSid: "mission_complete", operation: "==", value: "1" }] } }), /value must be number/);
  assert.match(check("ScenarioConnection", "Condition", { ...condition, nativeCounters: { ...condition.nativeCounters,
    array: [{ counterSid: "mission_complete", operation: "eval", value: 1 }] } }), /operation must be one of/);
  assert.match(check("ScenarioConnection", "Condition", { ...condition, nativeCounters: { ...condition.nativeCounters,
    array: [{ counterSid: "mission_complete", operation: "==", value: 1, script: "run" }] } }), /script is not an allowed field/);
  assert.match(check("ScenarioConnection", "Condition", { ...condition, nativeCounters: { logicOperation: "Xor", array: [] } }), /logicOperation must be one of/);
});
