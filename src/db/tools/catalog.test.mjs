import test from "node:test";
import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
const { tables } = JSON.parse(readFileSync(new URL("../data/heroeswatch.json", import.meta.url), "utf8"));

test("Heroes III contains the complete classic magic and artifact catalogs", () => {
  const count = (table) => tables[table].filter((row) => row.Game_id === "homm3.game").length;
  assert.equal(count("Skill"), 32);
  assert.equal(tables.SkillHOMM3.length, 28);
  assert.equal(count("MagicSchool"), 4);
  assert.equal(count("Spell"), 70);
  assert.equal(tables.SpellHOMM3.length, 70);
  assert.equal(count("SpellMagicSchool"), 76);
  assert.equal(count("Artifact"), 141);
  assert.equal(count("ArtifactComponent"), 49);
  assert.equal(new Set(tables.ArtifactComponent.map((row) => row.CompositeArtifact_id)).size, 12);
  for (const row of tables.ArtifactComponent) assert.notEqual(row.ComponentArtifact_id, row.CompositeArtifact_id);
});

test("campaign ownership and classic object coverage stay intact", () => {
  const byRelease = Object.fromEntries(["roe", "ab", "sod"].map((release) => [release,
    tables.Campaign.filter((row) => row.Expansion_id === `homm3.expansion.${release}`).length]));
  assert.deepEqual(byRelease, { roe: 7, ab: 6, sod: 7 });
  assert.equal(tables.AdventureObject.filter((row) => row.Game_id === "homm3.game").length, 187);
  assert.equal(tables.AdventureObjectHOMM3.filter((row) => row.Category === "Dwelling").length, 83);
  const goldCost = tables.ArtifactHOMM3.find((row) => row._key === "homm3.artifact.ammo.cart").GoldCost;
  assert.equal(goldCost, 1000, "Use the dedicated classic war-machine price, not the inconsistent summary table");
});

test("multi-school spells remain relational and unofficial additions stay excluded", () => {
  for (const key of ["homm3.spell.magic.arrow", "homm3.spell.visions"]) {
    assert.equal(tables.SpellMagicSchool.filter((row) => row.Spell_id === key).length, 4);
  }
  const unofficial = new Set(["Interference", "Cannon", "Golden Goose", "Ironfist of the Ogre", "Cove", "Factory"]);
  for (const category of ["Faction", "Skill", "Artifact"]) {
    for (const row of tables[category].filter((row) => row.Game_id === "homm3.game")) {
      assert.equal(unofficial.has(row.Name), false, row.Name);
    }
  }
});

test("dedicated artifact sources override misleading summary statistics", () => {
  const effect = (key) => tables.ArtifactHOMM3.find((row) => row._key === key).Effect;
  assert.deepEqual(effect("homm3.artifact.armageddon.s.blade").primarySkillBonuses,
    { attack: 3, defense: 3, power: 3, knowledge: 6 });
  assert.deepEqual(effect("homm3.artifact.vial.of.dragon.blood"),
    { alliedDragonBonuses: { attack: 5, defense: 5 } });
  assert.equal(tables.AdventureObject.find((row) => row._key === "homm3.object.freelancer.s.guild")
    .IntroducedInExpansion_id, "homm3.expansion.ab");
});
