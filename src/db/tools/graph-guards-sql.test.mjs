import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {graphGuardsSql, validateExistingGraphsSql} from './graph-guards-sql.mjs';
const schema = JSON.parse(fs.readFileSync(new URL('../schema/heroeswatch.schema.json', import.meta.url)));
const q = text => '"' + text.replaceAll('"', '""') + '"';
const literal = text => "'" + text.replaceAll("'", "''") + "'";

test('graph safeguards serialize scoped topology writes and inspect final edges', () => {
  const sql = graphGuardsSql(schema, q, literal);
  assert.equal((sql.match(/CREATE TRIGGER /g) ?? []).length, 5);
  assert.equal((sql.match(/CREATE CONSTRAINT TRIGGER /g) ?? []).length, 5);
  assert.match(sql, /heroes_watch:graph:/);
  assert.match(sql, /pg_advisory_xact_lock/);
  assert.match(sql, /ORDER BY 1 LOOP/);
  assert.match(sql, /repeatable read/);
  assert.match(sql, /DEFERRABLE INITIALLY DEFERRED/);
  assert.match(sql, /UNION SELECT edge/);
  assert.doesNotMatch(sql, /UNION ALL SELECT edge/);
  assert.match(validateExistingGraphsSql(schema, q, literal), /_check_catalog_graph_edge/);
});
