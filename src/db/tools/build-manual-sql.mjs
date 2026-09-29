#!/usr/bin/env node
// Build the manual batch plus its FK dependencies from the cumulative catalog.
// Dependencies are resolved by the normal importer; existing values are retained.
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { spawnSync } from 'node:child_process';

const dbRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const args = process.argv.slice(2);
if (args.some(arg => arg !== '--check')) throw new Error('Usage: node src/db/tools/build-manual-sql.mjs [--check]');
const read = file => JSON.parse(fs.readFileSync(path.join(dbRoot, file), 'utf8'));
const catalog = read('data/heroeswatch.json');
const schema = read('schema/heroeswatch.schema.json');
const evidence = read('data/manual-content-evidence.json');
const tableByName = new Map(schema.tables.map(table => [table.name, table]));
const byKey = new Map(Object.entries(catalog.tables).map(([name, rows]) => [name, new Map(rows.map(row => [row._key, row]))]));
const selected = new Map(schema.tables.map(table => [table.name, new Set()]));
const pending = [...evidence.addedRows, ...evidence.filledFields].map(({table, key}) => ({table, key}));
while (pending.length) {
  const {table: name, key} = pending.pop();
  if (selected.get(name)?.has(key)) continue;
  const table = tableByName.get(name);
  const row = byKey.get(name)?.get(key);
  if (!table || !row) throw new Error(`Missing manual-batch row ${name}/${key}`);
  selected.get(name).add(key);
  for (const fk of table.foreignKeys) {
    if (fk.columns.length !== 1) throw new Error('Composite FK requires a reviewed dependency policy');
    const column = fk.columns[0];
    const value = row[column] ?? (table.primaryKey.includes(column) ? row._key : null);
    if (value == null) continue;
    const target = typeof value === 'string'
      ? byKey.get(fk.referencedTable)?.get(value)
      : catalog.tables[fk.referencedTable].find(candidate => candidate[fk.referencedColumns[0]] === value);
    if (!target) throw new Error(`Missing dependency ${name}/${key}/${column}`);
    pending.push({table: fk.referencedTable, key: target._key});
  }
}
const batch = {
  ...catalog,
  notes: 'Manual additions and enriched rows, plus complete FK dependencies. Derived from the cumulative catalog and manual-content-evidence.json. Apply to the existing schema using the normal conflict-preserving importer.',
  tables: Object.fromEntries(Object.entries(catalog.tables).map(([table, rows]) => [table, rows.filter(row => selected.get(table).has(row._key))])),
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
