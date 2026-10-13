#!/usr/bin/env node
// Destructive only to a cryptographically random database created by this run.
// This runner never loads fixtures into PGDATABASE or any other existing DB.
import assert from 'node:assert/strict';
import { spawn } from 'node:child_process';
import { randomBytes } from 'node:crypto';
import fs from 'node:fs';
import path from 'node:path';
import process from 'node:process';
import { fileURLToPath } from 'node:url';
import {
  fingerprintSql,
  inventorySql,
  postgresEnvironment,
  psqlArgs,
  queryJson,
  reconcileInventory,
  requireSuccess,
  runProcess,
} from './postgres-integration-lib.mjs';

const dbRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const repositoryRoot = path.resolve(dbRoot, '..', '..');

if (process.argv.includes('--help')) {
  console.log(`Usage: HW_TEST_POSTGRES=1 PGHOST=... PGPORT=... PGUSER=... node src/db/tools/postgres-integration.mjs

Creates one random disposable database, tests the schema and complete catalog,
and drops only that exact database. PGDATABASE is used only as the maintenance
connection (default: postgres); it never receives schema, fixture, or data rows.`);
  process.exit(0);
}
if (process.argv.length !== 2) throw new Error(`Unknown arguments: ${process.argv.slice(2).join(' ')}`);
if (process.env.HW_TEST_POSTGRES !== '1') {
  console.log('PostgreSQL integration skipped (set HW_TEST_POSTGRES=1 to opt in).');
  process.exit(0);
}

for (const name of ['PGHOST', 'PGPORT', 'PGUSER']) {
  if (!process.env[name]) throw new Error(`${name} is required when HW_TEST_POSTGRES=1`);
}
if (!/^\d+$/.test(process.env.PGPORT)) throw new Error('PGPORT must be an integer');

const connection = {
  host: process.env.PGHOST,
  port: process.env.PGPORT,
  user: process.env.PGUSER,
  maintenance: process.env.PGDATABASE || 'postgres',
};
const binary = name => {
  const explicit = process.env[`HW_${name.toUpperCase()}`];
  if (explicit) return explicit;
  if (process.env.HW_PG_BINDIR) return path.join(process.env.HW_PG_BINDIR, name);
  for (const candidate of [`/opt/homebrew/opt/postgresql@18/bin/${name}`, `/opt/homebrew/bin/${name}`]) {
    try {
      fs.accessSync(candidate, fs.constants.X_OK);
      return candidate;
    } catch { /* try PATH */ }
  }
  return name;
};
const psql = binary('psql');
const createdb = binary('createdb');
const dropdb = binary('dropdb');
const database = `heroeswatch_ci_${process.pid}_${randomBytes(8).toString('hex')}`;
assert.match(database, /^heroeswatch_ci_[0-9]+_[0-9a-f]{16}$/);

const pgEnv = postgresEnvironment(process.env);
const utilityArgs = [
  '--no-password',
  '--host', connection.host,
  '--port', connection.port,
  '--username', connection.user,
  `--maintenance-db=${connection.maintenance}`,
];
const psqlFile = async (file, timeout = 300_000) => requireSuccess(
  psql,
  psqlArgs(connection, database, ['--file', path.join(repositoryRoot, file)]),
  { env: pgEnv, timeout, quiet: true },
);
const psqlSql = async (sql, options = {}) => runProcess(
  psql,
  psqlArgs(connection, database, ['--set', 'VERBOSITY=verbose', '--command', sql]),
  { env: pgEnv, timeout: options.timeout ?? 30_000, quiet: options.quiet ?? true },
);
const successfulSql = async sql => {
  const result = await psqlSql(sql);
  if (result.code !== 0) throw new Error(result.stderr || result.stdout);
  return result;
};
const failureCode = result => {
  const match = `${result.stderr}\n${result.stdout}`.match(/(?:ERROR|FATAL):\s+([0-9A-Z]{5}):/);
  return match?.[1];
};
const requireRejected = (result, allowed, label) => {
  assert.notEqual(result.code, 0, `${label}: statement unexpectedly committed`);
  assert(allowed.includes(failureCode(result)),
    `${label}: expected ${allowed.join('/')} but saw ${failureCode(result) ?? 'no SQLSTATE'}\n${result.stderr}`);
};

function startPsqlSession(applicationName) {
  const child = spawn(psql, psqlArgs(connection, database, [
    '--quiet', '--set', 'VERBOSITY=verbose',
  ]), {
    env: { ...pgEnv, PGAPPNAME: applicationName },
    stdio: ['pipe', 'pipe', 'pipe'],
  });
  const stdout = [];
  const stderr = [];
  let exited = false;
  child.stdout.on('data', chunk => stdout.push(chunk));
  child.stderr.on('data', chunk => stderr.push(chunk));
  const exit = new Promise((resolve, reject) => {
    child.once('error', reject);
    child.once('close', code => {
      exited = true;
      resolve({
        code,
        stdout: Buffer.concat(stdout).toString('utf8'),
        stderr: Buffer.concat(stderr).toString('utf8'),
      });
    });
  });
  return {
    applicationName,
    get exited() { return exited; },
    send(sql, end = false) {
      child.stdin.write(sql);
      if (end) child.stdin.end();
    },
    waitForOutput(marker, timeout = 10_000) {
      const output = () => Buffer.concat(stdout).toString('utf8');
      if (output().includes(marker)) return Promise.resolve();
      return new Promise((resolve, reject) => {
        const timer = setTimeout(() => finish(new Error(
          `${applicationName}: timed out waiting for ${marker}\n${output()}\n${Buffer.concat(stderr)}`,
        )), timeout);
        const onData = () => {
          if (output().includes(marker)) finish();
        };
        const onClose = code => finish(new Error(
          `${applicationName}: psql exited with ${code} before ${marker}\n${Buffer.concat(stderr)}`,
        ));
        const finish = error => {
          clearTimeout(timer);
          child.stdout.off('data', onData);
          child.off('close', onClose);
          if (error) reject(error);
          else resolve();
        };
        child.stdout.on('data', onData);
        child.on('close', onClose);
      });
    },
    exit,
    terminate() {
      if (!exited) child.kill('SIGTERM');
    },
  };
}

async function waitForVerifiedLock(first, second, timeout = 10_000) {
  const deadline = Date.now() + timeout;
  while (Date.now() < deadline) {
    if (first.exited || second.exited) {
      throw new Error('A concurrency session exited before a blocked overlap was observed');
    }
    const state = await queryJson(psql, connection, database, String.raw`
      SELECT jsonb_build_object(
        'firstIdleInTransaction', EXISTS (
          SELECT FROM pg_stat_activity
          WHERE datname = current_database()
            AND application_name = '${first.applicationName}'
            AND state = 'idle in transaction'
        ),
        'secondWaitingOnLock', EXISTS (
          SELECT FROM pg_stat_activity
          WHERE datname = current_database()
            AND application_name = '${second.applicationName}'
            AND state = 'active'
            AND wait_event_type = 'Lock'
        )
      )`, { env: pgEnv });
    if (state.firstIdleInTransaction && state.secondWaitingOnLock) return;
    await new Promise(resolve => setTimeout(resolve, 50));
  }
  throw new Error(`No verified lock overlap for ${first.applicationName} and ${second.applicationName}`);
}

const concurrencyFixture = id => String.raw`
  INSERT INTO heroes_watch."Game" ("Game_id", "SeriesCode", "DisplayOrder", "Name") VALUES
    (${id}, 'HOMM2', ${-id}, 'Fixture H2'),
    (${id - 1}, 'HOMM3', ${-id + 1}, 'Fixture H3');
  INSERT INTO heroes_watch."Creature" ("Creature_id", "Game_id", "Code", "Name")
  VALUES (${id - 2}, ${id - 1}, 'FIXTURE_CREATURE_${-id}', 'Fixture creature');
`;
const concurrencyCleanup = id => String.raw`
  DELETE FROM heroes_watch."CreatureHOMM3" WHERE "Creature_id" = ${id - 2};
  DELETE FROM heroes_watch."Creature" WHERE "Creature_id" = ${id - 2};
  DELETE FROM heroes_watch."Game" WHERE "Game_id" IN (${id}, ${id - 1});
`;

async function runConcurrencyOrder(order, isolation, id) {
  await successfulSql(concurrencyFixture(id));
  const creature = id - 2;
  const h2 = id;
  const firstIsChild = order === 'child-first';
  const label = `${process.pid}_${-id}_${isolation.replaceAll(' ', '_')}_${order.replace('-', '_')}`;
  const childSql = String.raw`
    BEGIN ISOLATION LEVEL ${isolation};
    INSERT INTO heroes_watch."CreatureHOMM3" ("Creature_id", "DoubleUpgrade", "AlternativeUpgrade")
    VALUES (${creature}, FALSE, FALSE);
    SET CONSTRAINTS ALL IMMEDIATE;
    COMMIT;`;
  const parentSql = String.raw`
    BEGIN ISOLATION LEVEL ${isolation};
    UPDATE heroes_watch."Creature" SET "Game_id" = ${h2} WHERE "Creature_id" = ${creature};
    COMMIT;`;
  const first = startPsqlSession(`hw_ci_first_${label}`);
  const second = startPsqlSession(`hw_ci_second_${label}`);
  let firstResult;
  let secondResult;
  try {
    const firstPrefix = firstIsChild
      ? childSql.replace(/\s+COMMIT;\s*$/, '\n\\echo HW_FIRST_READY\n')
      : parentSql.replace(/\s+COMMIT;\s*$/, '\n\\echo HW_FIRST_READY\n');
    first.send(firstPrefix);
    await first.waitForOutput('HW_FIRST_READY');
    second.send(firstIsChild ? parentSql : childSql, true);
    await waitForVerifiedLock(first, second);
    first.send('COMMIT;\n\\q\n', true);
    [firstResult, secondResult] = await Promise.all([first.exit, second.exit]);
  } finally {
    first.terminate();
    second.terminate();
  }
  const childResult = firstIsChild ? firstResult : secondResult;
  const parentResult = firstIsChild ? secondResult : firstResult;
  assert.equal(firstResult.code, 0, `${isolation} ${order}: lock-owning transaction should commit\n${firstResult.stderr}`);
  if (firstIsChild) {
    requireRejected(parentResult, ['23514', '40001', '40P01'], `${isolation} ${order} parent reassignment`);
  } else {
    requireRejected(childResult, ['23514', '40001', '40P01'], `${isolation} ${order} child detail`);
  }
  const invalid = await queryJson(psql, connection, database, String.raw`
    SELECT COALESCE(jsonb_agg(x), '[]'::jsonb) FROM (
      SELECT d."Creature_id", g."SeriesCode"
      FROM heroes_watch."CreatureHOMM3" AS d
      JOIN heroes_watch."Creature" AS c USING ("Creature_id")
      JOIN heroes_watch."Game" AS g USING ("Game_id")
      WHERE d."Creature_id" = ${creature} AND g."SeriesCode" IS DISTINCT FROM 'HOMM3'
    ) AS x`, { env: pgEnv });
  assert.deepEqual(invalid, [], `${isolation} ${order}: conflicting rows committed together`);
  await successfulSql(concurrencyCleanup(id));
}

async function runRepeatableReadGuard(id) {
  await successfulSql(concurrencyFixture(id));
  const creature = id - 2;
  const rejected = await psqlSql(String.raw`
    BEGIN ISOLATION LEVEL REPEATABLE READ;
    UPDATE heroes_watch."Creature" SET "Game_id" = ${id} WHERE "Creature_id" = ${creature};
    COMMIT;`);
  requireRejected(rejected, ['0A000', '40001'], 'REPEATABLE READ ownership change');
  await successfulSql(String.raw`
    BEGIN ISOLATION LEVEL REPEATABLE READ;
    UPDATE heroes_watch."Creature" SET "Name" = 'Fixture creature updated' WHERE "Creature_id" = ${creature};
    COMMIT;
    BEGIN ISOLATION LEVEL REPEATABLE READ;
    INSERT INTO heroes_watch."CreatureHOMM3" ("Creature_id", "DoubleUpgrade", "AlternativeUpgrade")
    VALUES (${creature}, FALSE, FALSE);
    COMMIT;`);
  await successfulSql(concurrencyCleanup(id));
}

let created = false;
try {
  console.log(`Creating isolated PostgreSQL database ${database} ...`);
  await requireSuccess(createdb, [...utilityArgs, '--template=template0', database], { env: pgEnv, timeout: 30_000, quiet: true });
  created = true;

  console.log('Loading current schema and structural verification ...');
  await psqlFile('src/db/postgres/schema.sql');
  await psqlFile('src/db/postgres/verify.sql');

  console.log('Running direct integrity rejection probes ...');
  await psqlFile('src/db/postgres/tests/game-integrity.sql');

  console.log('Running two-session lock-order and isolation probes ...');
  let fixture = -9200;
  for (const isolation of ['READ COMMITTED', 'SERIALIZABLE']) {
    for (const order of ['child-first', 'parent-first']) {
      await runConcurrencyOrder(order, isolation, fixture);
      fixture -= 10;
    }
  }
  await runRepeatableReadGuard(-9300);

  const schema = JSON.parse(fs.readFileSync(path.join(dbRoot, 'schema/heroeswatch.schema.json'), 'utf8'));
  const bundle = JSON.parse(fs.readFileSync(path.join(dbRoot, 'data/heroeswatch.json'), 'utf8'));
  const sourceRows = Object.values(bundle.tables).reduce((sum, rows) => sum + rows.length, 0);
  const expectedRows = Number(process.env.HW_EXPECTED_ROWS ?? '43736');
  assert.equal(sourceRows, expectedRows,
    `catalog row total changed from ${expectedRows}; review the data change and update HW_EXPECTED_ROWS/TESTING.md deliberately`);

  console.log(`Importing and reconciling ${sourceRows.toLocaleString('en-US')} catalog rows ...`);
  await psqlFile('src/db/data/catalog.sql', 900_000);
  await psqlFile('src/db/postgres/tests/creature-values.sql');
  const actual = await queryJson(psql, connection, database, inventorySql(schema), { env: pgEnv, timeout: 300_000 });
  const reconciliation = reconcileInventory(schema, bundle, actual);
  const before = await queryJson(psql, connection, database, fingerprintSql(schema), { env: pgEnv, timeout: 300_000 });

  console.log('Repeating the import and checking stable physical identities ...');
  await psqlFile('src/db/data/catalog.sql', 900_000);
  const after = await queryJson(psql, connection, database, fingerprintSql(schema), { env: pgEnv, timeout: 300_000 });
  assert.deepEqual(after, before, 'the repeated catalog import changed rows or physical IDs');

  const version = await queryJson(psql, connection, database,
    `SELECT to_jsonb(current_setting('server_version'))`, { env: pgEnv });
  console.log(JSON.stringify({
    result: 'PASS',
    databaseVersion: version,
    importedRows: sourceRows,
    ...reconciliation,
    repeatedImport: 'stable rows and physical IDs',
    directIntegrityProbes: 'passed',
    concurrentOrders: 4,
    repeatableReadGuard: 'passed',
  }, null, 2));
} finally {
  if (created) {
    console.log(`Dropping isolated PostgreSQL database ${database} ...`);
    const dropped = await runProcess(dropdb, [...utilityArgs, '--if-exists', '--force', database], {
      env: pgEnv,
      timeout: 30_000,
      quiet: true,
    });
    if (dropped.code !== 0) {
      process.stderr.write(`WARNING: failed to drop exact disposable database ${database}:\n${dropped.stderr}`);
      process.exitCode = 1;
    }
  }
}
