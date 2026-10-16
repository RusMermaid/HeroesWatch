// Read-only comparison of two explicitly named audit databases on the same server.
// PGHOST/PGPORT/PGUSER and HW_PSQL are supplied by the caller. No database writes.
import {execFileSync} from 'node:child_process';
import {readFileSync} from 'node:fs';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';

const [before, after, ...options] = process.argv.slice(2);
assert(options.every(option => option === '--normalize-v5'), 'Unknown comparison option');
assert(before && after, 'Usage: node compare-upgrade.mjs BEFORE_DATABASE AFTER_DATABASE');
const schema = JSON.parse(readFileSync(new URL('../../schema/heroeswatch.schema.json', import.meta.url)));
const q = value => '"' + value.replaceAll('"', '""') + '"';
function query(database, sql, side) {
  const connection = Object.fromEntries(['PGHOST', 'PGPORT', 'PGUSER'].map(key =>
    [key, process.env[`HW_${side}_${key}`] ?? process.env[key]]).filter(([, value]) => value));
  return execFileSync(process.env.HW_PSQL ?? 'psql', ['-X', '-w', '-v', 'ON_ERROR_STOP=1', '-At', '-d', database, '-c', sql], {
    encoding: 'utf8', maxBuffer: 256 * 1024 * 1024,
    env: {...process.env, ...connection, PGCONNECT_TIMEOUT: '5', PGOPTIONS: '-c default_transaction_read_only=on -c statement_timeout=60000'},
  }).trim();
}
function inventory(database, side) {
  const names = query(database, "SELECT tablename FROM pg_tables WHERE schemaname='heroes_watch' ORDER BY tablename", side).split('\n');
  return Object.fromEntries(names.map(name => [name, JSON.parse(query(database,
    `SELECT COALESCE(jsonb_agg(to_jsonb(r) ORDER BY ${q(schema.tables.find(t => t.name === name).primaryKey[0])}), '[]') FROM heroes_watch.${q(name)} r`, side))]));
}
const old = inventory(before, 'BEFORE'), current = inventory(after, 'AFTER');
let renamedTierFields = 0, convertedSpeedValues = 0;
if (options.includes('--normalize-v5')) {
  for (const table of ['CreatureHOMM1', 'CreatureHOMM2', 'CreatureHOMM3', 'CreatureHOMM4']) {
    for (const row of old[table] ?? []) {
      if (Object.hasOwn(row, 'Level')) {
        assert(!Object.hasOwn(row, 'Tier'), 'Ambiguous baseline Tier');
        row.Tier = row.Level; delete row.Level; renamedTierFields++;
      }
    }
  }
  for (const row of old.CreatureHOMM1 ?? []) {
    if (typeof row.Speed === 'string') {
      assert(Object.hasOwn({Slow: 1, Medium: 2, Fast: 3}, row.Speed), 'Unknown legacy speed');
      row.Speed = {Slow: 1, Medium: 2, Fast: 3}[row.Speed]; convertedSpeedValues++;
    }
  }
}
let preservedRows = 0, addedRows = 0, removedRows = 0, nullFills = 0, changedFacts = 0;
const changes = [];
for (const table of schema.tables) {
  const pk = table.primaryKey[0];
  const oldRows = new Map((old[table.name] ?? []).map(row => [row[pk], row]));
  const rows = new Map((current[table.name] ?? []).map(row => [row[pk], row]));
  for (const [id, row] of oldRows) {
    if (!rows.has(id)) { removedRows++; continue; }
    preservedRows++;
    const updated = rows.get(id);
    for (const column of table.columns) {
      if (column.generatedExpression) continue;
      const a = row[column.name] ?? null, b = updated[column.name] ?? null;
      if (JSON.stringify(a) === JSON.stringify(b)) continue;
      if (a === null && b !== null) nullFills++; else changedFacts++;
      changes.push({table: table.name, id, field: column.name, before: a, after: b});
    }
  }
  addedRows += [...rows.keys()].filter(id => !oldRows.has(id)).length;
}
assert.equal(removedRows, 0, 'Upgrade removed prior physical primary keys');
console.log(JSON.stringify({before, after, preservedRows, addedRows, removedRows, nullFills, changedFacts,
  normalization: {renamedTierFields, convertedSpeedValues, generatedFieldsExcluded: true},
  beforeRows: Object.values(old).reduce((n, rows) => n + rows.length, 0),
  beforeDataSha256: createHash('sha256').update(JSON.stringify(old)).digest('hex'),
  afterRows: Object.values(current).reduce((n, rows) => n + rows.length, 0),
  afterDataSha256: createHash('sha256').update(JSON.stringify(current)).digest('hex'),
  changesSha256: createHash('sha256').update(JSON.stringify(changes)).digest('hex'),
  nonNullChanges: changes.filter(change => change.before !== null),
}, null, 2));
