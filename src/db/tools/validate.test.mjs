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

const homm8Patch = {
  _key: "homm8.patch.test.build", Game_id: "homm8.game", Expansion_id: "homm8.expansion.base",
  Version: "Test build", Platform: "Test", ReleaseDate: null, Changes: null, Notes: null,
};
const homm8GameDetail = {
  _key: "homm8.game", CurrentPatch_id: homm8Patch._key, ReleaseStatus: "EarlyAccess", CombatGrid: "Hex",
  FocusPointsPerCharge: 6, DefaultFocusChargeCap: 3, MaximumHeroSkills: 8, LawSealCap: 100,
  LawTier1Seals: 0, LawTier2Seals: 5, LawTier3Seals: 15, LawTier4Seals: 30, LawTier5Seals: 50,
};
function ensureHomm8Detail(tables) {
  let patch = tables.Patch.find((row) => row.Game_id === "homm8.game");
  if (!patch) {
    patch = structuredClone(homm8Patch);
    tables.Patch.push(patch);
  }
  let detail = tables.GameHOMM8.find((row) => row._key === "homm8.game");
  if (!detail) {
    detail = { ...homm8GameDetail, CurrentPatch_id: patch._key };
    tables.GameHOMM8.push(detail);
  }
  delete detail.Game_id;
  return { detail, patch };
}

test("the cumulative catalog is internally consistent", () => {
  const result = validate(() => {});
  assert.equal(result.status, 0, result.stderr);
});

test("portable import keys remain stable and PostgreSQL text remains lossless", () => {
  const invalidKey = validate((tables) => {
    tables.LoreFull[0]._key = "HOMM 1";
  });
  assert.equal(invalidKey.status, 1);
  assert.match(invalidKey.stderr, /requires a stable lowercase _key/);

  const invalidText = validate((tables) => {
    tables.Game[0].Name = "Heroes\u0000I";
  });
  assert.equal(invalidText.status, 1);
  assert.match(invalidText.stderr, /must not contain U\+0000/);

  const invalidUnicode = validate((tables) => {
    tables.Game[0].Name = "Heroes\ud800I";
  });
  assert.equal(invalidUnicode.status, 1);
  assert.match(invalidUnicode.stderr, /valid Unicode scalar values/);
});

test("database-generated fields cannot be supplied by import JSON", () => {
  const result = validate((tables) => {
    tables.CreatureHOMM1[0].SpeedName = "Slow";
  });
  assert.equal(result.status, 1);
  assert.match(result.stderr, /SpeedName is database-generated and must be omitted/);
});

test("H1 and H2 base creature speed values stay within their reviewed numeric domains", () => {
  for (const [tableName, invalid] of [["CreatureHOMM1", 4], ["CreatureHOMM2", 8]]) {
    const result = validate((tables) => {
      tables[tableName][0].Speed = invalid;
    });
    assert.equal(result.status, 1);
    assert.match(result.stderr, new RegExp(`${tableName}.*Speed must be one of:`));
  }
});

test("ISO calendar validation handles early years and leap-day boundaries", () => {
  const validEarlyYear = validate((tables) => {
    tables.Game[0].ReleaseDate = "0004-02-29";
  });
  assert.equal(validEarlyYear.status, 0, validEarlyYear.stderr);

  const invalidCenturyLeapDay = validate((tables) => {
    tables.Game[0].ReleaseDate = "1900-02-29";
  });
  assert.equal(invalidCenturyLeapDay.status, 1);
  assert.match(invalidCenturyLeapDay.stderr, /must be a real ISO calendar date/);
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

test("GameHOMM8 inherits its game from an omitted shared Game_id", () => {
  const result = validate((tables) => {
    ensureHomm8Detail(tables);
  });
  assert.equal(result.status, 0, result.stderr);
});

test("GameHOMM8 rejects a CurrentPatch owned by another game", () => {
  const result = validate((tables) => {
    tables.Patch.push({ _key: "homm3.patch.test", Game_id: "homm3.game", Expansion_id: "homm3.expansion.roe",
      Version: "Test", Platform: "Test", ReleaseDate: null, Changes: null, Notes: null });
    const { detail } = ensureHomm8Detail(tables);
    detail.CurrentPatch_id = "homm3.patch.test";
  });
  assert.equal(result.status, 1);
  assert.match(result.stderr, /CurrentPatch_id crosses games \(HOMM8 to HOMM3\)/);
});

test("an omitted unresolved shared key never falls through to the first generated row", () => {
  const result = validate((tables) => {
    const { patch } = ensureHomm8Detail(tables);
    tables.GameHOMM8.push({ ...homm8GameDetail, _key: "homm8.missing.game", CurrentPatch_id: patch._key });
  });
  assert.equal(result.status, 1);
  assert.match(result.stderr, /references missing Game\.Game_id: homm8\.missing\.game/);
  assert.doesNotMatch(result.stderr, /belongs to HOMM3/);
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

test("Heroes III scenario-rule catalog keys resolve within Heroes III", () => {
  const addScenarioRules = (tables) => {
    const detail = tables.ScenarioHOMM3[0];
    const scenarioKey = detail._key;
    Object.assign(detail, {
      VictoryConditions: { kind: "AcquireArtifact", allowNormalVictory: true, appliesToAI: true,
        artifact: { nativeId: 7, artifactKey: "homm3.artifact.centaur.s.axe" } },
      LossConditions: { standardDaysWithoutTown: 7, special: null },
      StartingBonuses: { selectionMode: "BonusChoices", playerColor: { nativeId: 0, name: "Red" }, choices: [
        { kind: "Resource", nativeId: 6, resourceKeys: ["resource.gold"], amount: 1000 },
      ] },
      CarryoverRules: { nativeKeepsMask: 15, heroKeeps: ["Experience", "PrimarySkills", "SecondarySkills", "Spells"],
        keptCreatureTypes: [{ nativeId: 0, creatureKey: "homm3.creature.pikeman" }], keptArtifactTypes: [] } });
    return scenarioKey;
  };
  const valid = validate(addScenarioRules);
  assert.equal(valid.status, 0, valid.stderr);

  const missing = validate((tables) => {
    const scenarioKey = addScenarioRules(tables);
    tables.ScenarioHOMM3.find((row) => row._key === scenarioKey).CarryoverRules.keptCreatureTypes[0].creatureKey = "homm3.creature.missing";
  });
  assert.equal(missing.status, 1);
  assert.match(missing.stderr, /references missing Creature/);

  const crossGame = validate((tables) => {
    const scenarioKey = addScenarioRules(tables);
    tables.ScenarioHOMM3.find((row) => row._key === scenarioKey).CarryoverRules.keptCreatureTypes[0].creatureKey =
      tables.Creature.find((row) => row.Game_id === "homm4.game")._key;
  });
  assert.equal(crossGame.status, 1);
  assert.match(crossGame.stderr, /references HOMM4 Creature/);
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

test("a campaign hero's starting scenario must belong to the same campaign", () => {
  const result = validate((tables) => {
    const hero = tables.CampaignHero.find((row) => row.StartingScenario_id != null);
    const otherMembership = tables.CampaignScenario.find((row) =>
      row.Game_id === hero.Game_id && row.Campaign_id !== hero.Campaign_id);
    assert.ok(otherMembership);
    hero.StartingScenario_id = otherMembership.Scenario_id;
  });
  assert.equal(result.status, 1);
  assert.match(result.stderr, /references missing CampaignScenario\.Game_id,Campaign_id,Scenario_id/);
});

test("nullable business identities treat nulls as equal", () => {
  const result = validate((tables) => {
    const asset = tables.MediaAsset.find((row) => row.Game_id === null);
    assert.ok(asset);
    tables.MediaAsset.push({ ...asset, _key: "test.duplicate.global.media" });
  });
  assert.equal(result.status, 1);
  assert.match(result.stderr, /duplicates \(Game_id, Code\)/);
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
