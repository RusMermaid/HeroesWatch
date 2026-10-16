#!/usr/bin/env node
// Build the manual batch plus its FK dependencies from the cumulative catalog.
// Dependencies are resolved by the normal importer; existing values are retained.
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { spawnSync } from 'node:child_process';
import { selectContentClosure } from './content-closure.mjs';

const dbRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const args = process.argv.slice(2);
if (args.some(arg => arg !== '--check')) throw new Error('Usage: node src/db/tools/build-manual-sql.mjs [--check]');
const read = file => JSON.parse(fs.readFileSync(path.join(dbRoot, file), 'utf8'));
const catalog = read('data/heroeswatch.json');
const schema = read('schema/heroeswatch.schema.json');
const evidence = read('data/manual-content-evidence.json');
const batch = {
  ...catalog,
  notes: 'Manual additions and enriched rows, plus complete FK dependencies. Derived from the cumulative catalog and manual-content-evidence.json. Apply to the existing schema using the normal conflict-preserving importer.',
  tables: selectContentClosure(catalog, schema, [...evidence.addedRows, ...evidence.filledFields]),
};
const temporaryDirectory = path.resolve(dbRoot, '../../.codex-tmp');
fs.mkdirSync(temporaryDirectory, {recursive: true});
const input = path.join(temporaryDirectory, 'manual-import.json');
fs.writeFileSync(input, JSON.stringify(batch, null, 2) + '\n');
const result = spawnSync(process.execPath, [
  path.join(dbRoot, 'tools/build-content-sql.mjs'), '--input', input,
  '--output', path.join(dbRoot, 'data/manual-import.sql'), ...args,
], {encoding: 'utf8'});
if (result.error) throw result.error;
process.stdout.write(result.stdout ?? '');
process.stderr.write(result.stderr ?? '');
process.exitCode = result.status ?? 1;
