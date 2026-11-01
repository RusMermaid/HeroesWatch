import test from 'node:test';
import assert from 'node:assert/strict';
import {prepareCatalog, tierCorrectionSql} from './prepare-catalog-v5.mjs';

function fixture() {
  const codes = ['FAERIE_DRAGON', 'RUST_DRAGON', 'CRYSTAL_DRAGON', 'AZURE_DRAGON'];
  return {tables: {
    Game: [{_key: 'game.h3', SeriesCode: 'HOMM3'}],
    Creature: codes.map(Code => ({_key: Code, Game_id: 'game.h3', Code})),
    CreatureHOMM1: [{_key: 'h1', Level: null, Speed: 'Medium', Movement: 'Flying'}],
    CreatureHOMM2: [{_key: 'h2', Level: 2, Speed: 4}],
    CreatureHOMM3: codes.map(_key => ({_key, Level: 7, Speed: 15})),
    CreatureHOMM4: [], SpellHOMM3: [{Level: 4}],
  }};
}

test('creature terminology changes neither spell levels nor movement mode', () => {
  const source = fixture(), before = structuredClone(source), result = prepareCatalog(source);
  assert.deepEqual(source, before);
  assert.deepEqual(result.tables.CreatureHOMM1[0], {_key: 'h1', Tier: null, Speed: 2, Movement: 'Flying'});
  assert.deepEqual(result.tables.CreatureHOMM2[0], {_key: 'h2', Tier: 2, Speed: 4});
  assert.deepEqual(result.tables.CreatureHOMM3.map(row => row.Tier), [8, 8, 9, 10]);
  assert.deepEqual(result.tables.SpellHOMM3, before.tables.SpellHOMM3);
  assert.deepEqual(prepareCatalog(result), result);
});

test('ambiguous fields, unknown speeds and unrelated tier edits are rejected', () => {
  let source = fixture(); source.tables.CreatureHOMM1[0].Tier = 2;
  assert.throws(() => prepareCatalog(source), /both Level and Tier/);
  source = fixture(); source.tables.CreatureHOMM1[0].Speed = 'Unknown';
  assert.throws(() => prepareCatalog(source), /Unrecognized H1 speed/);
  source = fixture(); source.tables.CreatureHOMM3[0].Level = 6;
  assert.throws(() => prepareCatalog(source), /Unrecognized prior Tier/);
});

test('dragon SQL is scoped, guarded, transactional and non-destructive', () => {
  const sql = tierCorrectionSql();
  assert.match(sql, /BEGIN;/); assert.match(sql, /COMMIT;/);
  assert.equal((sql.match(/UPDATE heroes_watch/g) ?? []).length, 4);
  assert.equal((sql.match(/Unexpected existing Tier/g) ?? []).length, 4);
  assert.doesNotMatch(sql, /DELETE|TRUNCATE|DROP/);
  assert.match(sql, /g\."SeriesCode" = 'HOMM3'/);
});
