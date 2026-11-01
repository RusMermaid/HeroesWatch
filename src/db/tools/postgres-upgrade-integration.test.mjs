import test from 'node:test';
import assert from 'node:assert/strict';
import path from 'node:path';
import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';

const directory = path.dirname(fileURLToPath(import.meta.url));
const runner = path.join(directory, 'postgres-upgrade-integration.mjs');

test('upgrade runner is opt-in and documents its disposable-database scope', () => {
  const skipped = spawnSync(process.execPath, [runner], { encoding: 'utf8',
    env: { ...process.env, HW_TEST_POSTGRES: '0' } });
  assert.equal(skipped.status, 0, skipped.stderr);
  assert.match(skipped.stdout, /upgrade integration skipped/);

  const help = spawnSync(process.execPath, [runner, '--help'], { encoding: 'utf8' });
  assert.equal(help.status, 0, help.stderr);
  assert.match(help.stdout, /random disposable v5 and v7 databases/);
  assert.match(help.stdout, /45,560-row v7 handoff/);
  assert.match(help.stdout, /complete enrichment transaction/);
  assert.match(help.stdout, /drops only those exact databases/);
});

test('upgrade runner rejects arguments and unscoped opt-in connections', () => {
  const unknown = spawnSync(process.execPath, [runner, '--database', 'heroeswatch'], { encoding: 'utf8' });
  assert.notEqual(unknown.status, 0);
  assert.match(unknown.stderr, /Unknown arguments/);

  const unscoped = spawnSync(process.execPath, [runner], { encoding: 'utf8', env: {
    ...process.env, HW_TEST_POSTGRES: '1', PGHOST: '', PGPORT: '', PGUSER: '',
  } });
  assert.notEqual(unscoped.status, 0);
  assert.match(unscoped.stderr, /PGHOST is required/);
});
