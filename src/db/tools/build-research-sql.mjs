#!/usr/bin/env node
// Build a deterministic, dependency-closed SQL import from the final reviewed
// research audit. This tool never connects to PostgreSQL.
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import process from 'node:process';
import { createHash } from 'node:crypto';
import { spawnSync } from 'node:child_process';
import { isDeepStrictEqual } from 'node:util';
import { fileURLToPath } from 'node:url';
import { selectContentClosure } from './content-closure.mjs';

const dbRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const options = {
  input: path.join(dbRoot, 'data/heroeswatch.json'),
  schema: path.join(dbRoot, 'schema/heroeswatch.schema.json'),
  evidence: path.join(dbRoot, 'data/research-2026-10-13-evidence.json'),
  output: path.join(dbRoot, 'data/research-import.sql'),
  check: false,
};
for (let index = 2; index < process.argv.length; index++) {
  const argument = process.argv[index];
  if (argument === '--check') options.check = true;
  else if (['--input', '--schema', '--evidence', '--output'].includes(argument)) {
    const value = process.argv[++index];
    if (!value || value.startsWith('--')) throw new Error(`Missing value for ${argument}`);
    options[argument.slice(2)] = path.resolve(value);
  } else if (argument === '--help') {
    console.log('node src/db/tools/build-research-sql.mjs [--input catalog.json] [--schema schema.json] [--evidence evidence.json] [--output research-import.sql] [--check]');
    process.exit(0);
  } else throw new Error(`Unknown argument: ${argument}`);
}

const read = (filename, label) => {
  try { return JSON.parse(fs.readFileSync(filename, 'utf8')); }
  catch (error) { throw new Error(`Cannot read ${label}: ${error.message}`); }
};
const digest = value => createHash('sha256').update(JSON.stringify(value)).digest('hex');
const researchRoot = path.resolve(dbRoot, 'research/2026-10-13');
const realResearchRoot = fs.realpathSync(researchRoot);
function readAuditedPatch(storedPath, label) {
  if (typeof storedPath !== 'string' || !storedPath || path.isAbsolute(storedPath) || storedPath.includes('\\') || storedPath.includes('\0')) {
    throw new Error(`${label}.file must be a safe repository-relative patch path`);
  }
  const candidate = path.dirname(storedPath) === '.'
    ? path.resolve(researchRoot, storedPath)
    : path.resolve(dbRoot, storedPath);
  const relative = path.relative(researchRoot, candidate);
  if (!relative || relative.startsWith(`..${path.sep}`) || relative === '..' || path.isAbsolute(relative) || !candidate.endsWith('.patch.json')) {
    throw new Error(`${label}.file must resolve inside research/2026-10-13 to a *.patch.json file`);
  }
  let stat;
  try { stat = fs.lstatSync(candidate); }
  catch (error) { throw new Error(`${label}.file cannot be read: ${error.message}`); }
  if (!stat.isFile() || stat.isSymbolicLink()) throw new Error(`${label}.file must be a regular non-symbolic-link file`);
  const realCandidate = fs.realpathSync(candidate);
  const realRelative = path.relative(realResearchRoot, realCandidate);
  if (realRelative.startsWith(`..${path.sep}`) || realRelative === '..' || path.isAbsolute(realRelative)) {
    throw new Error(`${label}.file resolves outside the reviewed research directory`);
  }
  const bytes = fs.readFileSync(realCandidate);
  let parsed;
  try { parsed = JSON.parse(bytes.toString('utf8')); }
  catch (error) { throw new Error(`${label}.file is not valid JSON: ${error.message}`); }
  return { bytes, parsed };
}
const catalog = read(options.input, 'catalog');
const schema = read(options.schema, 'semantic schema');
const evidence = read(options.evidence, 'research evidence');
if (evidence.formatVersion !== 1 || !Array.isArray(evidence.patches)) throw new Error('Research evidence must use formatVersion 1 and contain patches');
if (evidence.outputSha256 !== digest(catalog)) throw new Error('Research evidence outputSha256 does not match the selected catalog');

const tableByName = new Map(schema.tables.map(table => [table.name, table]));
const rowsByTable = new Map(schema.tables.map(table => [table.name,
  new Map((catalog.tables?.[table.name] ?? []).map(row => [row._key, row]))]));
const seeds = new Map();
let additions = 0;
let fills = 0;
const auditedFiles = [];
for (const [patchIndex, patch] of evidence.patches.entries()) {
  const label = `patches[${patchIndex}]`;
  if (typeof patch.file !== 'string' || !/^[a-f0-9]{64}$/.test(patch.patchSha256 ?? '')) throw new Error(`${label} lacks a reproducible file name or patch SHA-256`);
  if (!Array.isArray(patch.additions) || !Array.isArray(patch.fills)) throw new Error(`${label} must contain additions and fills`);
  const sourcePatch = readAuditedPatch(patch.file, label);
  const actualPatchSha256 = createHash('sha256').update(sourcePatch.bytes).digest('hex');
  if (actualPatchSha256 !== patch.patchSha256) throw new Error(`${label}.patchSha256 does not match the current reviewed patch file`);
  const sourceMetadata = Object.fromEntries(Object.entries(sourcePatch.parsed)
    .filter(([name]) => !['additions', 'fills', 'sources'].includes(name)));
  const sourceAdditions = (sourcePatch.parsed.additions ?? []).map(action => ({
    table: action.table, key: action.row?._key, row: action.row, evidence: action.evidence,
  }));
  if (!isDeepStrictEqual(sourceMetadata, patch.metadata) ||
      !isDeepStrictEqual(sourcePatch.parsed.sources, patch.sources) ||
      !isDeepStrictEqual(sourceAdditions, patch.additions) ||
      !isDeepStrictEqual(sourcePatch.parsed.fills, patch.fills)) {
    throw new Error(`${label} audit content does not match the current reviewed patch file`);
  }
  auditedFiles.push(patch.file);
  for (const [index, addition] of patch.additions.entries()) {
    const action = `${label}.additions[${index}]`;
    if (!tableByName.has(addition.table) || typeof addition.key !== 'string' || !addition.row) throw new Error(`${action} has an invalid target`);
    const current = rowsByTable.get(addition.table).get(addition.key);
    if (!current) throw new Error(`${action} is missing from the selected catalog`);
    if (!isDeepStrictEqual(current, addition.row)) throw new Error(`${action} full added row does not match the selected catalog`);
    seeds.set(JSON.stringify([addition.table, addition.key]), { table: addition.table, key: addition.key });
    additions++;
  }
  for (const [index, fill] of patch.fills.entries()) {
    const action = `${label}.fills[${index}]`;
    if (!tableByName.has(fill.table) || typeof fill.key !== 'string' || typeof fill.field !== 'string' || fill.expected !== null) {
      throw new Error(`${action} has an invalid guarded fill`);
    }
    const current = rowsByTable.get(fill.table).get(fill.key);
    if (!current || !Object.hasOwn(current, fill.field)) throw new Error(`${action} target is missing from the selected catalog`);
    if (!isDeepStrictEqual(current[fill.field], fill.value)) throw new Error(`${action} final value does not match the selected catalog`);
    seeds.set(JSON.stringify([fill.table, fill.key]), { table: fill.table, key: fill.key });
    fills++;
  }
}
if (seeds.size === 0) throw new Error('Research evidence contains no additions or fills');
if (!isDeepStrictEqual(evidence.patchFiles, auditedFiles)) throw new Error('Research evidence patchFiles does not match its audited patch entries');
if (evidence.summary?.additions !== additions || evidence.summary?.fills !== fills) throw new Error('Research evidence summary does not match its action lists');
const catalogRows = Object.values(catalog.tables ?? {}).reduce((sum, rows) => sum + (Array.isArray(rows) ? rows.length : 0), 0);
if (evidence.summary?.resultingRows !== catalogRows) throw new Error('Research evidence resultingRows does not match the selected catalog');

const batch = {
  ...catalog,
  notes: 'Reviewed 2026-10-13 research delta plus its complete relational and reviewed ScenarioHOMM3 annotation dependencies. Generated from research-2026-10-13-evidence.json.',
  tables: selectContentClosure(catalog, schema, [...seeds.values()]),
};
const temporaryDirectory = fs.mkdtempSync(path.join(os.tmpdir(), 'heroeswatch-research-sql-'));
try {
  const temporaryInput = path.join(temporaryDirectory, 'research-import.json');
  fs.writeFileSync(temporaryInput, JSON.stringify(batch, null, 2) + '\n');
  const result = spawnSync(process.execPath, [path.join(dbRoot, 'tools/build-content-sql.mjs'),
    '--input', temporaryInput, '--schema', options.schema, '--output', options.output,
    ...(options.check ? ['--check'] : [])], { encoding: 'utf8', maxBuffer: 16 * 1024 * 1024 });
  if (result.error) throw result.error;
  process.stdout.write(result.stdout ?? '');
  process.stderr.write(result.stderr ?? '');
  if (result.status !== 0) process.exitCode = result.status ?? 1;
  else console.log(`Research audit seeds: ${seeds.size} distinct row(s), ${additions} addition(s), ${fills} fill(s). No database connection was opened.`);
} finally {
  fs.rmSync(temporaryDirectory, { recursive: true, force: true });
}
