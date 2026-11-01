#!/usr/bin/env node
// Review and merge bounded, evidence-backed research patches. Dry-run is the
// default; no source file is changed unless --apply is supplied explicitly.
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import process from "node:process";
import { createHash } from "node:crypto";
import { spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";

const dbRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const defaults = {
  patchDir: path.join(dbRoot, "research/2026-10-13"),
  input: path.join(dbRoot, "data/heroeswatch.json"),
  schema: path.join(dbRoot, "schema/heroeswatch.schema.json"),
  output: null,
  evidenceOutput: path.join(dbRoot, "data/research-2026-10-13-evidence.json"),
  patches: [],
  apply: false,
};
const options = { ...defaults };
for (let index = 2; index < process.argv.length; index++) {
  const argument = process.argv[index];
  if (argument === "--apply") options.apply = true;
  else if (argument === "--patch") {
    const value = process.argv[++index];
    if (!value || value.startsWith("--")) throw new Error("Missing value for --patch");
    options.patches.push(path.resolve(value));
  }
  else if (["--patch-dir", "--input", "--schema", "--output", "--evidence-output"].includes(argument)) {
    const value = process.argv[++index];
    if (!value || value.startsWith("--")) throw new Error(`Missing value for ${argument}`);
    const property = argument.slice(2).replace(/-([a-z])/g, (_, letter) => letter.toUpperCase());
    options[property] = path.resolve(value);
  } else if (argument === "--help") {
    console.log("node src/db/tools/apply-research-patches.mjs [--patch FILE ... | --patch-dir DIR] [--input JSON] [--schema JSON] [--output JSON] [--evidence-output JSON] [--apply]");
    process.exit(0);
  } else throw new Error(`Unknown argument: ${argument}`);
}
options.output ??= options.input;

const isPlainObject = (value) => value !== null && typeof value === "object" && !Array.isArray(value);
const exactKeys = (value, allowed, label) => {
  if (!isPlainObject(value)) throw new Error(`${label} must be an object`);
  const supplied = Object.keys(value).sort();
  const expected = [...allowed].sort();
  if (JSON.stringify(supplied) !== JSON.stringify(expected)) {
    throw new Error(`${label} must contain exactly: ${expected.join(", ")}`);
  }
};
const evidenceValue = (value, label) => {
  if (typeof value === "string") {
    if (!value.trim() || value.length > 16000) throw new Error(`${label} must be non-empty and at most 16000 characters`);
    return;
  }
  if (!Array.isArray(value) && !isPlainObject(value)) throw new Error(`${label} must be a non-empty string, array, or object`);
  const state = { nodes: 0, hasText: false };
  const walk = (item, at, depth = 0) => {
    state.nodes++;
    if (state.nodes > 10000 || depth > 16) throw new Error(`${label} is too large or deeply nested`);
    if (typeof item === "string") {
      if (!item.trim() || item.length > 16000) throw new Error(`${at} must be non-empty and at most 16000 characters`);
      state.hasText = true;
      return;
    }
    if (typeof item === "number" && Number.isFinite(item) || typeof item === "boolean") return;
    if (Array.isArray(item)) {
      if (item.length === 0 || item.length > 512) throw new Error(`${at} must be a non-empty bounded array`);
      item.forEach((nested, index) => walk(nested, `${at}[${index}]`, depth + 1));
      return;
    }
    if (isPlainObject(item)) {
      const entries = Object.entries(item);
      if (entries.length === 0 || entries.length > 64) throw new Error(`${at} must be a non-empty bounded object`);
      for (const [name, nested] of entries) {
        if (!name || name.length > 256 || name.includes("\0")) throw new Error(`${at} contains an invalid evidence field name`);
        walk(nested, `${at}.${name}`, depth + 1);
      }
      return;
    }
    throw new Error(`${at} contains an unsupported evidence value`);
  };
  walk(value, label);
  if (!state.hasText) throw new Error(`${label} must contain at least one non-empty text citation or claim`);
};
const boundedMetadata = (value, label, state = { nodes: 0 }, depth = 0) => {
  state.nodes++;
  if (state.nodes > 10000 || depth > 16) throw new Error(`${label} is too large or deeply nested`);
  if (value === null || typeof value === "boolean" || typeof value === "number" && Number.isFinite(value)) return;
  if (typeof value === "string") {
    if (value.length > 16000) throw new Error(`${label} is too long`);
    return;
  }
  if (Array.isArray(value)) {
    if (value.length > 512) throw new Error(`${label} has too many items`);
    value.forEach((item, index) => boundedMetadata(item, `${label}[${index}]`, state, depth + 1));
    return;
  }
  if (isPlainObject(value)) {
    if (Object.keys(value).length > 64) throw new Error(`${label} has too many fields`);
    for (const [name, item] of Object.entries(value)) {
      if (!name || name.length > 256 || name.includes("\0")) throw new Error(`${label} contains an invalid metadata field name`);
      boundedMetadata(item, `${label}.${name}`, state, depth + 1);
    }
    return;
  }
  throw new Error(`${label} contains an unsupported value`);
};
const digest = (value) => createHash("sha256").update(JSON.stringify(value)).digest("hex");
const textDigest = (value) => createHash("sha256").update(value).digest("hex");
const readJson = (filename, label = filename) => {
  try {
    return JSON.parse(fs.readFileSync(filename, "utf8"));
  } catch (error) {
    throw new Error(`Cannot read ${label}: ${error.message}`);
  }
};

function validateWithCatalogValidator(bundle, schemaPath) {
  const temporaryDirectory = fs.mkdtempSync(path.join(os.tmpdir(), "heroeswatch-research-patch-"));
  try {
    const candidatePath = path.join(temporaryDirectory, "candidate.json");
    fs.writeFileSync(candidatePath, JSON.stringify(bundle));
    const result = spawnSync(process.execPath, [path.join(dbRoot, "tools/validate.mjs"), candidatePath, schemaPath], {
      encoding: "utf8", maxBuffer: 16 * 1024 * 1024,
    });
    if (result.error) throw result.error;
    if (result.status !== 0) throw new Error(`resulting bundle failed validation:\n${(result.stderr || result.stdout).trim()}`);
  } finally {
    fs.rmSync(temporaryDirectory, { recursive: true, force: true });
  }
}

// Prepare every replacement before moving any target. If a later rename fails,
// restore every original file so --apply does not leave a half-written pair.
function atomicWrite(entries) {
  const prepared = [];
  try {
    for (const [index, entry] of entries.entries()) {
      fs.mkdirSync(path.dirname(entry.target), { recursive: true });
      const stem = `.${path.basename(entry.target)}.${process.pid}.${index}`;
      const temporary = path.join(path.dirname(entry.target), `${stem}.tmp`);
      const backup = path.join(path.dirname(entry.target), `${stem}.bak`);
      fs.writeFileSync(temporary, entry.content, { flag: "wx" });
      prepared.push({ ...entry, temporary, backup, hadOriginal: fs.existsSync(entry.target), installed: false });
    }
    for (const item of prepared) if (item.hadOriginal) fs.renameSync(item.target, item.backup);
    for (const item of prepared) {
      fs.renameSync(item.temporary, item.target);
      item.installed = true;
    }
    // Installation is now complete. Backup cleanup is best-effort: a cleanup
    // failure must not trigger rollback after some backups were already removed.
    for (const item of prepared) if (item.hadOriginal) {
      try { fs.rmSync(item.backup, { force: true }); } catch { /* retain recoverable backup */ }
    }
  } catch (error) {
    for (const item of [...prepared].reverse()) {
      if (item.installed) fs.rmSync(item.target, { force: true });
      if (item.hadOriginal && fs.existsSync(item.backup)) fs.renameSync(item.backup, item.target);
      fs.rmSync(item.temporary, { force: true });
    }
    throw error;
  }
}

function main() {
  const schema = readJson(options.schema, "semantic schema");
  let originalText;
  try { originalText = fs.readFileSync(options.input, "utf8"); }
  catch (error) { throw new Error(`Cannot read catalog input: ${error.message}`); }
  let original;
  try { original = JSON.parse(originalText); }
  catch (error) { throw new Error(`Cannot read catalog input: ${error.message}`); }
  const originalFileSha256 = textDigest(originalText);
  const captureFileState = (filename) => {
    if (!fs.existsSync(filename)) return { exists: false, sha256: null };
    return { exists: true, sha256: textDigest(fs.readFileSync(filename)) };
  };
  const customOutputState = path.resolve(options.output) === path.resolve(options.input) ? null : captureFileState(options.output);
  const evidenceOutputState = captureFileState(options.evidenceOutput);
  const candidate = structuredClone(original);
  const tableByName = new Map(schema.tables.map((table) => [table.name, table]));
  for (const table of schema.tables) {
    if (!Array.isArray(candidate.tables?.[table.name])) throw new Error(`Catalog table ${table.name} must be an array`);
  }

  let patchPaths;
  if (options.patches.length) patchPaths = [...options.patches].sort();
  else {
    try {
      patchPaths = fs.readdirSync(options.patchDir, { withFileTypes: true })
        .filter((entry) => entry.isFile() && entry.name.endsWith(".patch.json"))
        .map((entry) => path.join(options.patchDir, entry.name)).sort();
    } catch (error) {
      throw new Error(`Cannot read patch directory: ${error.message}`);
    }
  }
  if (patchPaths.length === 0) throw new Error("No *.patch.json research patches found; empty research is not completion");
  for (const patchPath of patchPaths) {
    if (!patchPath.endsWith(".patch.json")) throw new Error(`Selected patch must end with .patch.json: ${patchPath}`);
    let stat;
    try { stat = fs.lstatSync(patchPath); }
    catch (error) { throw new Error(`Cannot inspect selected patch ${patchPath}: ${error.message}`); }
    if (!stat.isFile() || stat.isSymbolicLink()) throw new Error(`Selected patch must be a regular non-symbolic-link file: ${patchPath}`);
  }
  if (new Set(patchPaths.map((filename) => path.resolve(filename))).size !== patchPaths.length) throw new Error("The same patch path was selected more than once");
  const patchIdentities = patchPaths.map((filename) => {
    const stat = fs.statSync(filename);
    return `${stat.dev}:${stat.ino}`;
  });
  if (new Set(patchIdentities).size !== patchIdentities.length) throw new Error("Selected patch paths alias the same file");
  const patchFiles = patchPaths.map((filename) => path.basename(filename));
  if (new Set(patchFiles).size !== patchFiles.length) throw new Error("Selected patches must have unique filenames for a deterministic audit trail");

  const currentRows = new Map(schema.tables.map((table) => [table.name,
    new Map(candidate.tables[table.name].map((row) => [row._key, row]))]));
  const additions = new Set();
  const fills = new Set();
  const auditPatches = [];
  let additionCount = 0;
  let fillCount = 0;

  for (const [patchIndex, patchFile] of patchFiles.entries()) {
    const patchPath = patchPaths[patchIndex];
    let patchText;
    try { patchText = fs.readFileSync(patchPath, "utf8"); }
    catch (error) { throw new Error(`Cannot read ${patchFile}: ${error.message}`); }
    let patch;
    try { patch = JSON.parse(patchText); }
    catch (error) { throw new Error(`Cannot read ${patchFile}: ${error.message}`); }
    if (!isPlainObject(patch)) throw new Error(`${patchFile} must be an object`);
    for (const required of ["additions", "fills", "sources"]) {
      if (!Object.hasOwn(patch, required)) throw new Error(`${patchFile} requires ${required}`);
    }
    if (Object.hasOwn(patch, "formatVersion") && patch.formatVersion !== 1) throw new Error(`${patchFile}.formatVersion must be 1`);
    if (Object.keys(patch).length > 16) throw new Error(`${patchFile} has too many top-level fields`);
    const metadata = Object.fromEntries(Object.entries(patch)
      .filter(([name]) => !["additions", "fills", "sources"].includes(name)));
    boundedMetadata(metadata, `${patchFile}.metadata`);
    for (const property of ["additions", "fills", "sources"]) {
      if (!Array.isArray(patch[property])) throw new Error(`${patchFile}.${property} must be an array`);
    }
    if (patch.additions.length + patch.fills.length === 0) {
      throw new Error(`${patchFile} has no additions or fills; empty research is not completion`);
    }
    if (patch.sources.length === 0) throw new Error(`${patchFile}.sources must contain at least one source`);
    patch.sources.forEach((source, index) => evidenceValue(source, `${patchFile}.sources[${index}]`));
    const audit = { file: patchFile, patchSha256: textDigest(patchText), metadata, sources: patch.sources, additions: [], fills: [] };

    for (const [index, action] of patch.additions.entries()) {
      const label = `${patchFile}.additions[${index}]`;
      exactKeys(action, ["table", "row", "evidence"], label);
      evidenceValue(action.evidence, `${label}.evidence`);
      const table = tableByName.get(action.table);
      if (!table) throw new Error(`${label}.table is unknown: ${action.table}`);
      if (!isPlainObject(action.row)) throw new Error(`${label}.row must be an object`);
      if (typeof action.row._key !== "string" || action.row._key.length === 0) throw new Error(`${label}.row requires _key`);
      const allowedColumns = new Set(table.columns.map((column) => column.name));
      const primaryColumns = new Set(table.primaryKey);
      for (const field of Object.keys(action.row)) {
        if (field !== "_key" && !allowedColumns.has(field)) throw new Error(`${label}.row has unknown field ${field}`);
        if (primaryColumns.has(field)) throw new Error(`${label}.row must omit physical primary key ${field}`);
      }
      const identity = JSON.stringify([action.table, action.row._key]);
      if (currentRows.get(action.table).has(action.row._key)) throw new Error(`${label} cannot overwrite existing row ${action.table}/${action.row._key}`);
      if (additions.has(identity)) throw new Error(`${label} duplicates an addition for ${action.table}/${action.row._key}`);
      additions.add(identity);
      const row = structuredClone(action.row);
      candidate.tables[action.table].push(row);
      currentRows.get(action.table).set(row._key, row);
      additionCount++;
      audit.additions.push({ table: action.table, key: row._key, row: structuredClone(row), evidence: action.evidence });
    }

    for (const [index, action] of patch.fills.entries()) {
      const label = `${patchFile}.fills[${index}]`;
      exactKeys(action, ["table", "key", "field", "expected", "value", "evidence"], label);
      evidenceValue(action.evidence, `${label}.evidence`);
      const table = tableByName.get(action.table);
      if (!table) throw new Error(`${label}.table is unknown: ${action.table}`);
      if (typeof action.key !== "string" || !action.key) throw new Error(`${label}.key must be a non-empty _key`);
      if (typeof action.field !== "string" || !action.field) throw new Error(`${label}.field must be a column name`);
      if (action.field === "_key" || table.primaryKey.includes(action.field)) throw new Error(`${label} cannot rename or replace row identity`);
      const column = table.columns.find((candidateColumn) => candidateColumn.name === action.field);
      if (!column) throw new Error(`${label}.field is unknown: ${action.field}`);
      if (!Object.hasOwn(action, "expected") || action.expected !== null) throw new Error(`${label}.expected must be exactly null`);
      if (action.value === null) throw new Error(`${label}.value must fill the field with a non-null value`);
      const identity = JSON.stringify([action.table, action.key]);
      if (additions.has(identity)) throw new Error(`${label} cannot fill a row introduced by the same patch set; put the value in its addition`);
      const fieldIdentity = JSON.stringify([action.table, action.key, action.field]);
      if (fills.has(fieldIdentity)) throw new Error(`${label} duplicates or conflicts with another fill for ${action.table}/${action.key}.${action.field}`);
      const row = currentRows.get(action.table).get(action.key);
      if (!row) throw new Error(`${label} references missing row ${action.table}/${action.key}`);
      if (!Object.hasOwn(row, action.field) || row[action.field] !== null) {
        throw new Error(`${label} requires current ${action.table}/${action.key}.${action.field} to be explicitly null`);
      }
      fills.add(fieldIdentity);
      row[action.field] = structuredClone(action.value);
      fillCount++;
      audit.fills.push({ table: action.table, key: action.key, field: action.field,
        expected: null, value: action.value, evidence: action.evidence });
    }
    auditPatches.push(audit);
  }

  validateWithCatalogValidator(candidate, options.schema);
  const rowCount = Object.values(candidate.tables).reduce((sum, rows) => sum + rows.length, 0);
  const evidence = {
    formatVersion: 1,
    purpose: "Deterministic audit trail for the explicitly selected reviewed research patches.",
    inputSha256: digest(original),
    outputSha256: digest(candidate),
    patchFiles,
    summary: { additions: additionCount, fills: fillCount, resultingRows: rowCount },
    patches: auditPatches,
  };
  const catalogText = JSON.stringify(candidate, null, 2) + "\n";
  const evidenceText = JSON.stringify(evidence, null, 2) + "\n";

  const protectedInputs = new Set([options.input, options.schema, ...patchPaths]
    .map((filename) => path.resolve(filename)));
  if (protectedInputs.has(path.resolve(options.output)) && path.resolve(options.output) !== path.resolve(options.input)) {
    throw new Error("Catalog output cannot overwrite the schema or a patch file");
  }
  if (path.resolve(options.evidenceOutput) === path.resolve(options.output) || path.resolve(options.evidenceOutput) === path.resolve(options.input) ||
      protectedInputs.has(path.resolve(options.evidenceOutput))) throw new Error("Evidence output must be separate from catalog, schema, and patch inputs");

  if (!options.apply) {
    console.log(`Dry run valid: ${patchFiles.length} patch file(s), ${additionCount} addition(s), ${fillCount} fill(s), ${rowCount} resulting rows. No files written.`);
    return;
  }
  for (const target of [options.output, options.evidenceOutput]) {
    if (fs.existsSync(target) && fs.lstatSync(target).isSymbolicLink()) throw new Error(`Refusing to overwrite symbolic-link target: ${target}`);
  }
  const existingIdentity = (filename) => {
    if (!fs.existsSync(filename)) return null;
    const stat = fs.statSync(filename);
    return `${stat.dev}:${stat.ino}`;
  };
  const targetIdentities = [options.output, options.evidenceOutput].map(existingIdentity).filter(Boolean);
  if (new Set(targetIdentities).size !== targetIdentities.length) throw new Error("Catalog and evidence outputs alias the same existing file");
  for (const target of [options.output, options.evidenceOutput]) {
    const identity = existingIdentity(target);
    for (const protectedFile of protectedInputs) {
      const isInPlaceCatalog = path.resolve(target) === path.resolve(options.output) &&
        path.resolve(options.output) === path.resolve(options.input) && protectedFile === path.resolve(options.input);
      if (!isInPlaceCatalog && identity && identity === existingIdentity(protectedFile)) throw new Error(`Output aliases protected input: ${target}`);
    }
  }
  let currentInputText;
  try { currentInputText = fs.readFileSync(options.input, "utf8"); }
  catch (error) { throw new Error(`Cannot recheck catalog input before apply: ${error.message}`); }
  if (textDigest(currentInputText) !== originalFileSha256) {
    throw new Error("Catalog input changed during patch validation; no files were written");
  }
  const assertFileState = (filename, originalState, label) => {
    const currentState = captureFileState(filename);
    if (currentState.exists !== originalState.exists || currentState.sha256 !== originalState.sha256) {
      throw new Error(`${label} changed during patch validation; no files were written`);
    }
  };
  if (customOutputState) assertFileState(options.output, customOutputState, "Catalog output");
  assertFileState(options.evidenceOutput, evidenceOutputState, "Evidence output");
  atomicWrite([
    { target: options.output, content: catalogText },
    { target: options.evidenceOutput, content: evidenceText },
  ]);
  console.log(`Applied ${patchFiles.length} patch file(s): ${additionCount} addition(s), ${fillCount} fill(s), ${rowCount} resulting rows.`);
  console.log(`Catalog: ${options.output}`);
  console.log(`Evidence: ${options.evidenceOutput}`);
}

try {
  main();
} catch (error) {
  console.error(`Research patch merge failed: ${error.message}`);
  process.exitCode = 1;
}
