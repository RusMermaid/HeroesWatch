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
