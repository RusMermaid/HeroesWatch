import test from "node:test";
import assert from "node:assert/strict";
import { readFileSync, mkdtempSync, writeFileSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import path from "node:path";
import { spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";

const directory = path.dirname(fileURLToPath(import.meta.url));
const bundle = JSON.parse(readFileSync(path.join(directory, "../data/heroeswatch.json"), "utf8"));

function validate(mutator) {
  const data = structuredClone(bundle);
  mutator(data.tables);
  const temporary = mkdtempSync(path.join(tmpdir(), "heroeswatch-validator-"));
  try {
    const input = path.join(temporary, "data.json");
    writeFileSync(input, JSON.stringify(data));
    return spawnSync(process.execPath, [path.join(directory, "validate.mjs"), input,
      path.join(directory, "../schema/heroeswatch.schema.json")], { encoding: "utf8" });
  } finally {
    const resolved = path.resolve(temporary);
    assert.equal(path.dirname(resolved), path.resolve(tmpdir()));
    assert.ok(path.basename(resolved).startsWith("heroeswatch-validator-"));
    rmSync(temporary, { recursive: true, force: true });
  }
}

test("the cumulative catalog is internally consistent", () => {
  const result = validate(() => {});
  assert.equal(result.status, 0, result.stderr);
});

test("an existing expansion from another game is rejected", () => {
  const result = validate((tables) => {
    tables.Faction.find((row) => row._key === "homm3.faction.castle")
      .IntroducedInExpansion_id = "homm4.expansion.base";
  });
  assert.equal(result.status, 1);
  assert.match(result.stderr, /IntroducedInExpansion_id crosses games \(HOMM3 to HOMM4\)/);
});

test("shared-PK details must belong to the title named by their table", () => {
  const result = validate((tables) => {
    tables.FactionHOMM3[0]._key = "homm4.faction.haven";
  });
  assert.equal(result.status, 1);
  assert.match(result.stderr, /FactionHOMM3 requires HOMM3/);
});

test("junction endpoints cannot cross game ownership", () => {
  const result = validate((tables) => {
    tables.CreatureUpgrade.find((row) => row.Game_id === "homm3.game").Game_id = "homm4.game";
  });
  assert.equal(result.status, 1);
  assert.match(result.stderr, /Creature_id crosses games \(HOMM4 to HOMM3\)/);
});

test("independent title mechanics enforce the title even without Game_id", () => {
  const result = validate((tables) => {
    tables.ArtifactSetHOMM5.push({ _key: "test.set", Code: "TEST_SET", Name: "Test set",
      IntroducedInExpansion_id: "homm3.expansion.roe" });
  });
  assert.equal(result.status, 1);
  assert.match(result.stderr, /ArtifactSetHOMM5 requires HOMM5/);
});

test("an unversioned artifact set cannot grant a bonus to another title's class", () => {
  const result = validate((tables) => {
    tables.ArtifactSetHOMM5.push({ _key: "test.set", Code: "TEST_SET", Name: "Test set" });
    tables.ArtifactSetBonusHOMM5.push({ _key: "test.set.bonus", ArtifactSetHOMM5_id: "test.set",
      RequiredPieceCount: 2, HeroClass_id: tables.HeroClass.find((row) => row.Game_id === "homm4.game")._key,
      Effect: { attack: 1 } });
  });
  assert.equal(result.status, 1);
  assert.match(result.stderr, /ArtifactSetBonusHOMM5 requires HOMM5/);
});

test("nested JSON is validated during normal bundle ingestion", () => {
  const result = validate((tables) => {
    tables.ArtifactHOMM3[0].Effect = { primarySkillBonuses: { attack: "2" } };
  });
  assert.equal(result.status, 1);
  assert.match(result.stderr, /primarySkillBonuses.attack must be number/);
});

test("unprofiled JSON payloads cannot bypass null-only source policy", () => {
  const result = validate((tables) => {
    tables.HeroHOMM3[0].SpecialtyEffect = { arbitrary: 123 };
  });
  assert.equal(result.status, 1);
  assert.match(result.stderr, /no reviewed JSON profile/);
});

test("costs require resource availability for their title", () => {
  const result = validate((tables) => {
    const cost = tables.CreatureResourceCost.find((row) => row.Game_id === "homm3.game");
    tables.GameResource = tables.GameResource.filter((row) => row.Game_id !== cost.Game_id || row.Resource_id !== cost.Resource_id);
  });
  assert.equal(result.status, 1);
  assert.match(result.stderr, /resource unavailable in GameResource/);
});

test("requirement sets and modes must be supplied together", () => {
  const result = validate((tables) => {
    tables.HeroClassAbility[0].RequirementSet = 1;
  });
  assert.equal(result.status, 1);
  assert.match(result.stderr, /requires RequirementSet and RequirementMode together/);
});

test("the all-class artifact-set identity treats null class as one scope", () => {
  const result = validate((tables) => {
    const bonus = tables.ArtifactSetBonusHOMM5.find((row) => row.HeroClass_id == null);
    assert.ok(bonus);
    tables.ArtifactSetBonusHOMM5.push({ ...bonus, _key: "test.duplicate.all.class.bonus" });
  });
  assert.equal(result.status, 1);
  assert.match(result.stderr, /duplicates \(ArtifactSetHOMM5_id, RequiredPieceCount, HeroClass_id\)/);
});

test("duplicate class ability atoms are rejected even with null requirement fields", () => {
  const result = validate((tables) => {
    tables.HeroClassAbility.push({ ...tables.HeroClassAbility[0], _key: "test.duplicate.ability.atom" });
  });
  assert.equal(result.status, 1);
  assert.match(result.stderr, /duplicates \(Game_id, HeroClass_id, Ability_id, RequirementSet, RequiredAbility_id, Skill_id, MinimumMastery\)/);
});

test("distinct prerequisite alternatives remain valid and resolve composite group references", () => {
  const result = validate((tables) => {
    const ability = tables.HeroClassAbility[0];
    for (const set of [1, 2]) {
      tables.HeroClassAbilityRequirementGroup.push({
        _key: `test.requirement.group.${set}`, Game_id: ability.Game_id,
        HeroClass_id: ability.HeroClass_id, Ability_id: ability.Ability_id,
        RequirementSet: set, RequirementMode: "All",
      });
      tables.HeroClassAbility.push({ ...ability, _key: `test.requirement.atom.${set}`,
        RequirementSet: set, RequirementMode: "All" });
    }
  });
  assert.equal(result.status, 0, result.stderr);
});

test("a composite foreign key checks the full tuple, including group mode", () => {
  const result = validate((tables) => {
    const ability = tables.HeroClassAbility[0];
    tables.HeroClassAbilityRequirementGroup.push({
      _key: "test.requirement.group", Game_id: ability.Game_id,
      HeroClass_id: ability.HeroClass_id, Ability_id: ability.Ability_id,
      RequirementSet: 1, RequirementMode: "All",
    });
    ability.RequirementSet = 1;
    ability.RequirementMode = "Any";
  });
  assert.equal(result.status, 1);
  assert.match(result.stderr, /references missing HeroClassAbilityRequirementGroup/);
});

test("composite game ownership accepts a mix of symbolic keys and physical ids", () => {
  const result = validate((tables) => {
    const game = tables.Game.find((row) => row._key === "homm3.game");
    game.Game_id = 900001;
    const reference = tables.CreatureResourceCost.find((row) => row.Game_id === game._key);
    reference.Game_id = 900001;
  });
  assert.equal(result.status, 0, result.stderr);
});

test("requirement-group identifiers and spell selection weights enforce their SQL bounds", () => {
  const result = validate((tables) => {
    const ability = tables.HeroClassAbility[0];
    tables.HeroClassAbilityRequirementGroup.push({
      _key: "test.invalid.group", Game_id: ability.Game_id, HeroClass_id: ability.HeroClass_id,
      Ability_id: ability.Ability_id, RequirementSet: 0, RequirementMode: "All",
    });
    tables.FactionSpell[0].SelectionWeight = -1;
  });
  assert.equal(result.status, 1);
  assert.match(result.stderr, /RequirementSet must be a positive integer/);
  assert.match(result.stderr, /SelectionWeight must be a non-negative integer/);
});
