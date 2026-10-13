import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { createHash } from 'node:crypto';
import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';

const directory = path.dirname(fileURLToPath(import.meta.url));
const schemaPath = path.join(directory, '../schema/heroeswatch.schema.json');
const catalogPath = path.join(directory, '../data/heroeswatch.json');
const finalEvidencePath = path.join(directory, '../data/research-2026-10-13-evidence.json');
const tool = path.join(directory, 'build-research-sql.mjs');
const digest = value => createHash('sha256').update(JSON.stringify(value)).digest('hex');

function fixture() {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), 'heroeswatch-research-sql-test-'));
  const input = path.join(root, 'catalog.json');
  const evidencePath = path.join(root, 'evidence.json');
  const output = path.join(root, 'research.sql');
  const evidence = JSON.parse(fs.readFileSync(finalEvidencePath, 'utf8'));
  fs.copyFileSync(catalogPath, input);
  fs.writeFileSync(evidencePath, JSON.stringify(evidence));
  const run = (...args) => spawnSync(process.execPath, [tool, '--input', input, '--schema', schemaPath,
    '--evidence', evidencePath, '--output', output, ...args], { encoding: 'utf8' });
  return { root, input, evidencePath, output, evidence, run, close: () => fs.rmSync(root, { recursive: true, force: true }) };
}

test('research SQL builder verifies audit rows and produces a repeatable dependency-closed import', () => {
  const item = fixture();
  try {
    const built = item.run();
    assert.equal(built.status, 0, built.stderr);
    assert.match(built.stdout, /Built research\.sql \([0-9]+ rows\)/);
    assert.match(fs.readFileSync(item.output, 'utf8'), /reviewed rows/);
    const checked = item.run('--check');
    assert.equal(checked.status, 0, checked.stderr);
    assert.match(checked.stdout, /Verified deterministic research\.sql/);
  } finally { item.close(); }
});

test('research SQL builder re-hashes every reviewed patch file', () => {
  const item = fixture();
  try {
    item.evidence.patches[0].patchSha256 = '0'.repeat(64);
    fs.writeFileSync(item.evidencePath, JSON.stringify(item.evidence));
    const result = item.run();
    assert.equal(result.status, 1);
    assert.match(result.stderr, /patchSha256 does not match the current reviewed patch file/);
    assert.equal(fs.existsSync(item.output), false);
  } finally { item.close(); }
});

test('research SQL builder rejects traversal and arbitrary audit file reads', () => {
  const item = fixture();
  try {
    item.evidence.patches[0].file = '../../../../etc/passwd.patch.json';
    fs.writeFileSync(item.evidencePath, JSON.stringify(item.evidence));
    const result = item.run();
    assert.equal(result.status, 1);
    assert.match(result.stderr, /must resolve inside research\/2026-10-13/);
    assert.equal(fs.existsSync(item.output), false);
  } finally { item.close(); }
});

test('research SQL builder refuses audit action content that differs from its hashed patch', () => {
  const item = fixture();
  try {
    item.evidence.patches[0].additions[0].row.Name = 'Tampered';
    fs.writeFileSync(item.evidencePath, JSON.stringify(item.evidence));
    const result = item.run();
    assert.equal(result.status, 1);
    assert.match(result.stderr, /audit content does not match the current reviewed patch file/);
    assert.equal(fs.existsSync(item.output), false);
  } finally { item.close(); }
});

test('research SQL builder refuses a selected catalog row that differs from the audited addition', () => {
  const item = fixture();
  try {
    const catalog = JSON.parse(fs.readFileSync(item.input, 'utf8'));
    const addition = item.evidence.patches[0].additions[0];
    const row = catalog.tables[addition.table].find(candidate => candidate._key === addition.key);
    row.Name = `${row.Name} changed`;
    item.evidence.outputSha256 = digest(catalog);
    fs.writeFileSync(item.input, JSON.stringify(catalog));
    fs.writeFileSync(item.evidencePath, JSON.stringify(item.evidence));
    const result = item.run();
    assert.equal(result.status, 1);
    assert.match(result.stderr, /full added row does not match the selected catalog/);
    assert.equal(fs.existsSync(item.output), false);
  } finally { item.close(); }
});
