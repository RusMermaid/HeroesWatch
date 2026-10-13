import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";

const directory = path.dirname(fileURLToPath(import.meta.url));
const schemaPath = path.join(directory, "../schema/heroeswatch.schema.json");
const schema = JSON.parse(fs.readFileSync(schemaPath, "utf8"));
const tool = path.join(directory, "apply-research-patches.mjs");
const emptyCatalog = () => ({ $schema: "../schema/data.schema.json", formatVersion: 1, notes: "Test catalog.",
  tables: Object.fromEntries(schema.tables.map((table) => [table.name, []])) });
const firstGame = { _key: "test.game.one", SeriesCode: "TEST1", DisplayOrder: 1, Name: "Test One", ReleaseDate: null, Description: null };
const secondGame = { _key: "test.game.two", SeriesCode: "TEST2", DisplayOrder: 2, Name: "Test Two", ReleaseDate: null, Description: null };
const evidence = { sourceId: "test-source", locator: "manual:test#page=1", claim: "Test fixture claim." };
const nestedSource = { id: "test-source", kind: "primary", title: "Test manual",
  locators: ["PDF p.1", "PDF p.2"], supports: ["First claim", "Second claim"],
  observed: { date: "2026-10-13", pageCount: 2 } };

function fixture(catalog = emptyCatalog()) {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "heroeswatch-research-tool-test-"));
  const patchDir = path.join(root, "patches");
  const input = path.join(root, "catalog.json");
  const output = path.join(root, "output.json");
  const audit = path.join(root, "evidence.json");
  fs.mkdirSync(patchDir);
  fs.writeFileSync(input, JSON.stringify(catalog, null, 2) + "\n");
  return { root, patchDir, input, output, audit,
    patch(name, value) { fs.writeFileSync(path.join(patchDir, name), JSON.stringify(value, null, 2) + "\n"); },
    run(...extra) { return spawnSync(process.execPath, [tool, "--patch-dir", patchDir, "--input", input,
      "--schema", schemaPath, "--output", output, "--evidence-output", audit, ...extra], { encoding: "utf8" }); },
    close() { fs.rmSync(root, { recursive: true, force: true }); } };
}
const patch = ({ additions = [], fills = [] } = {}) => ({ additions, fills, sources: [evidence] });

test("dry-run validates useful research without changing files", () => {
  const item = fixture();
  try {
    item.patch("game.patch.json", { formatVersion: 1, researchDate: "2026-10-13",
      scope: { table: "Game", keys: [firstGame._key] }, candidateChanges: { [firstGame._key]: "reviewed" },
      additions: [{ table: "Game", row: firstGame, evidence: [evidence,
        { sourceId: "second-source", locators: ["PDF p.2", "data:file#row=1"] }] }],
      fills: [], sources: [nestedSource] });
    const before = fs.readFileSync(item.input, "utf8");
    const result = item.run();
    assert.equal(result.status, 0, result.stderr);
    assert.match(result.stdout, /Dry run valid: 1 patch file.*1 addition.*No files written/);
    assert.equal(fs.readFileSync(item.input, "utf8"), before);
    assert.equal(fs.existsSync(item.output), false);
    assert.equal(fs.existsSync(item.audit), false);
  } finally { item.close(); }
});

test("repeatable --patch selects only reviewed files and never skips a selected empty patch", () => {
  const item = fixture();
  try {
    const reviewed = path.join(item.patchDir, "reviewed.patch.json");
    const empty = path.join(item.patchDir, "empty.patch.json");
    item.patch("reviewed.patch.json", patch({ additions: [{ table: "Game", row: firstGame, evidence }] }));
    item.patch("empty.patch.json", patch());
    const selected = item.run("--patch", reviewed);
    assert.equal(selected.status, 0, selected.stderr);
    assert.match(selected.stdout, /Dry run valid: 1 patch file/);
    const rejected = item.run("--patch", empty);
    assert.equal(rejected.status, 1);
    assert.match(rejected.stderr, /empty research is not completion/);
  } finally { item.close(); }
});

test("explicit apply writes a validated catalog and deterministic evidence", () => {
  const catalog = emptyCatalog();
  catalog.tables.Game.push(structuredClone(firstGame));
  const item = fixture(catalog);
  try {
    item.patch("reviewed.patch.json", patch({
      additions: [{ table: "Game", row: secondGame, evidence }],
      fills: [{ table: "Game", key: firstGame._key, field: "Description", expected: null,
        value: "Evidence-backed description.", evidence }],
    }));
    const result = item.run("--apply");
    assert.equal(result.status, 0, result.stderr);
    const output = JSON.parse(fs.readFileSync(item.output, "utf8"));
    assert.equal(output.tables.Game.length, 2);
    assert.equal(output.tables.Game[0].Description, "Evidence-backed description.");
    const audit = JSON.parse(fs.readFileSync(item.audit, "utf8"));
    assert.deepEqual(audit.summary, { additions: 1, fills: 1, resultingRows: 2 });
    assert.deepEqual(audit.patchFiles, ["reviewed.patch.json"]);
    assert.equal(audit.patches[0].fills[0].expected, null);
    assert.deepEqual(audit.patches[0].additions[0].row, secondGame);
    assert.match(audit.patches[0].patchSha256, /^[a-f0-9]{64}$/);
  } finally { item.close(); }
});

test("an invalid resulting bundle rolls back without touching either output", () => {
  const item = fixture();
  try {
    fs.writeFileSync(item.output, "catalog sentinel\n");
    fs.writeFileSync(item.audit, "evidence sentinel\n");
    item.patch("invalid.patch.json", patch({ additions: [{ table: "Game",
      row: { _key: "test.invalid", SeriesCode: "BROKEN", DisplayOrder: 1 }, evidence }] }));
    const result = item.run("--apply");
    assert.equal(result.status, 1);
    assert.match(result.stderr, /resulting bundle failed validation/);
    assert.equal(fs.readFileSync(item.output, "utf8"), "catalog sentinel\n");
    assert.equal(fs.readFileSync(item.audit, "utf8"), "evidence sentinel\n");
  } finally { item.close(); }
});

test("conflicting fills across patches are rejected without file changes", () => {
  const catalog = emptyCatalog();
  catalog.tables.Game.push(structuredClone(firstGame));
  const item = fixture(catalog);
  try {
    for (const [name, value] of [["a.patch.json", "First"], ["b.patch.json", "Second"]]) {
      item.patch(name, patch({ fills: [{ table: "Game", key: firstGame._key, field: "Description",
        expected: null, value, evidence }] }));
    }
    const before = fs.readFileSync(item.input, "utf8");
    const result = item.run("--apply");
    assert.equal(result.status, 1);
    assert.match(result.stderr, /duplicates or conflicts with another fill/);
    assert.equal(fs.readFileSync(item.input, "utf8"), before);
    assert.equal(fs.existsSync(item.output), false);
    assert.equal(fs.existsSync(item.audit), false);
  } finally { item.close(); }
});

test("identity changes and additions that overwrite existing keys are rejected", () => {
  const catalog = emptyCatalog();
  catalog.tables.Game.push(structuredClone(firstGame));
  for (const [name, action, message] of [
    ["rename.patch.json", patch({ fills: [{ table: "Game", key: firstGame._key, field: "_key",
      expected: null, value: "test.game.renamed", evidence }] }), /cannot rename or replace row identity/],
    ["overwrite.patch.json", patch({ additions: [{ table: "Game", row: { ...firstGame, Name: "Replacement" }, evidence }] }), /cannot overwrite existing row/],
    ["physical-primary.patch.json", patch({ additions: [{ table: "Game",
      row: { ...secondGame, Game_id: 42 }, evidence }] }), /must omit physical primary key Game_id/],
  ]) {
    const item = fixture(catalog);
    try {
      item.patch(name, action);
      const result = item.run("--apply");
      assert.equal(result.status, 1);
      assert.match(result.stderr, message);
      assert.equal(fs.existsSync(item.output), false);
      assert.equal(fs.existsSync(item.audit), false);
    } finally { item.close(); }
  }
});

test("fills require both an exact null precondition and a currently null field", () => {
  for (const [catalogValue, expected, message] of [
    [null, "unknown", /expected must be exactly null/],
    ["Already present", null, /to be explicitly null/],
  ]) {
    const catalog = emptyCatalog();
    catalog.tables.Game.push({ ...firstGame, Description: catalogValue });
    const item = fixture(catalog);
    try {
      item.patch("fill.patch.json", patch({ fills: [{ table: "Game", key: firstGame._key,
        field: "Description", expected, value: "New value", evidence }] }));
      const result = item.run("--apply");
      assert.equal(result.status, 1);
      assert.match(result.stderr, message);
      assert.equal(fs.existsSync(item.output), false);
      assert.equal(fs.existsSync(item.audit), false);
    } finally { item.close(); }
  }
});

test("the same reviewed inputs produce byte-identical catalog and evidence outputs", () => {
  const results = [];
  for (let attempt = 0; attempt < 2; attempt++) {
    const item = fixture();
    try {
      item.patch("stable.patch.json", patch({ additions: [{ table: "Game", row: firstGame, evidence }] }));
      const result = item.run("--apply");
      assert.equal(result.status, 0, result.stderr);
      results.push([fs.readFileSync(item.output, "utf8"), fs.readFileSync(item.audit, "utf8")]);
    } finally { item.close(); }
  }
  assert.deepEqual(results[0], results[1]);
});

test("apply refuses a symbolic-link output instead of overwriting its target", () => {
  const item = fixture();
  try {
    item.patch("stable.patch.json", patch({ additions: [{ table: "Game", row: firstGame, evidence }] }));
    const target = path.join(item.root, "symlink-target.json");
    fs.writeFileSync(target, "sentinel\n");
    fs.symlinkSync(target, item.output);
    const result = item.run("--apply");
    assert.equal(result.status, 1);
    assert.match(result.stderr, /Refusing to overwrite symbolic-link target/);
    assert.equal(fs.readFileSync(target, "utf8"), "sentinel\n");
    assert.equal(fs.existsSync(item.audit), false);
  } finally { item.close(); }
});

test("empty or unsupported patch claims do not count as completed research", () => {
  const item = fixture();
  try {
    item.patch("empty.patch.json", { additions: [], fills: [], sources: [evidence] });
    const result = item.run();
    assert.equal(result.status, 1);
    assert.match(result.stderr, /empty research is not completion/);
  } finally { item.close(); }
});

test("evidence containers must be non-empty and contain real citation text", () => {
  for (const invalidEvidence of [[], {}, [1, true]]) {
    const item = fixture();
    try {
      item.patch("invalid-evidence.patch.json", patch({ additions: [{ table: "Game", row: firstGame,
        evidence: invalidEvidence }] }));
      const result = item.run();
      assert.equal(result.status, 1);
      assert.match(result.stderr, /non-empty|at least one non-empty text citation/);
    } finally { item.close(); }
  }
});
