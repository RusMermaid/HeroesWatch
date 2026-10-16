import test from 'node:test';
import assert from 'node:assert/strict';
import { catalogConcurrencyCaseMatrix, catalogRepeatableReadFamilies, runCatalogConcurrency, runCatalogRepeatableReadControls } from './catalog-concurrency.mjs';

test('catalog concurrency matrix covers three families, both orders, and two isolation levels', () => {
  assert.equal(catalogConcurrencyCaseMatrix.length, 12);
  assert.equal(new Set(catalogConcurrencyCaseMatrix.map(item => JSON.stringify(item))).size, 12);
  for (const family of ['graph-cycle', 'homm8-resource', 'town-building-faction']) {
    const cases = catalogConcurrencyCaseMatrix.filter(item => item.family === family);
    assert.equal(cases.length, 4);
    assert.deepEqual(new Set(cases.map(item => item.order)), new Set(['forward-first', 'reverse-first']));
    assert.deepEqual(new Set(cases.map(item => item.isolation)), new Set(['READ COMMITTED', 'SERIALIZABLE']));
  }
});

test('catalog concurrency runner rejects an unscoped database request', async () => {
  await assert.rejects(() => runCatalogConcurrency({}), /requires psql.*disposable database/);
});

test('repeatable-read controls cover every catalog guard family and require scoped settings', async () => {
  assert.deepEqual(catalogRepeatableReadFamilies, ['graph-cycle', 'homm8-resource', 'town-building-faction']);
  await assert.rejects(() => runCatalogRepeatableReadControls({}), /requires psql.*disposable database/);
});
