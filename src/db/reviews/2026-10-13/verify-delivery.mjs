// Read-only exact source reconciliation of one database, or two import routes.
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import {fingerprintSql, inventorySql, queryJson, reconcileInventory} from '../../tools/postgres-integration-lib.mjs';

const databases = process.argv.slice(2);
assert([1, 2].includes(databases.length), 'Provide one database, or the full-import and small-import database names');
for (const key of ['PGHOST', 'PGPORT', 'PGUSER']) assert(process.env[key], `${key} is required`);
const connection = {host: process.env.PGHOST, port: process.env.PGPORT, user: process.env.PGUSER};
const psql = process.env.HW_PSQL ?? 'psql';
const schema = JSON.parse(readFileSync(new URL('../../schema/heroeswatch.schema.json', import.meta.url)));
const bundle = JSON.parse(readFileSync(new URL('../../data/heroeswatch.json', import.meta.url)));
const env = {...process.env, PGOPTIONS: '-c default_transaction_read_only=on -c statement_timeout=120000'};
const results = [], fingerprints = [];
for (const database of databases) {
  const actual = await queryJson(psql, connection, database, inventorySql(schema), {env});
  results.push({database, ...reconcileInventory(schema, bundle, actual)});
  fingerprints.push(await queryJson(psql, connection, database, fingerprintSql(schema), {env}));
}
if (databases.length === 2) assert.deepEqual(fingerprints[0], fingerprints[1], 'Full and small import routes differ in data or physical IDs');
console.log(JSON.stringify({result: 'PASS', routes: results,
  ...(databases.length === 2 ? {identicalRowsAndPhysicalIds: true} : {})}, null, 2));
