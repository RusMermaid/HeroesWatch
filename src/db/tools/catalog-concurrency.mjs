import assert from 'node:assert/strict';
import { spawn } from 'node:child_process';
import {
  postgresEnvironment,
  psqlArgs,
  queryJson,
  requireSuccess,
  runProcess,
} from './postgres-integration-lib.mjs';

const ISOLATIONS = Object.freeze(['READ COMMITTED', 'SERIALIZABLE']);
const FAMILIES = Object.freeze(['graph-cycle', 'homm8-resource', 'town-building-faction']);
const ORDERS = Object.freeze(['forward-first', 'reverse-first']);

export const catalogConcurrencyCaseMatrix = Object.freeze(
  FAMILIES.flatMap(family => ORDERS.flatMap(order => ISOLATIONS.map(isolation =>
    Object.freeze({ family, order, isolation })))),
);
export const catalogRepeatableReadFamilies = Object.freeze([...FAMILIES]);

const failureCode = result => {
  const match = `${result.stderr}\n${result.stdout}`.match(/(?:ERROR|FATAL):\s+([0-9A-Z]{5}):/);
  return match?.[1];
};

function startPsqlSession(psql, connection, database, env, applicationName) {
  const child = spawn(psql, psqlArgs(connection, database, ['--quiet', '--set', 'VERBOSITY=verbose']), {
    env: { ...postgresEnvironment(env), PGAPPNAME: applicationName },
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
      resolve({ code, stdout: Buffer.concat(stdout).toString('utf8'), stderr: Buffer.concat(stderr).toString('utf8') });
    });
  });
  return {
    applicationName,
    get exited() { return exited; },
    send(sql, end = false) {
      if (exited) throw new Error(`${applicationName}: cannot write to an exited psql session`);
      child.stdin.write(sql);
      if (end) child.stdin.end();
    },
    waitForOutput(marker, timeout = 15_000) {
      const output = () => Buffer.concat(stdout).toString('utf8');
      if (output().includes(marker)) return Promise.resolve();
      return new Promise((resolve, reject) => {
        const finish = error => {
          clearTimeout(timer);
          child.stdout.off('data', onData);
          child.off('close', onClose);
          if (error) reject(error);
          else resolve();
        };
        const timer = setTimeout(() => finish(new Error(
          `${applicationName}: timed out waiting for ${marker}\n${output()}\n${Buffer.concat(stderr).toString('utf8')}`,
        )), timeout);
        const onData = () => { if (output().includes(marker)) finish(); };
        const onClose = code => finish(new Error(
          `${applicationName}: psql exited with ${code} before ${marker}\n${Buffer.concat(stderr).toString('utf8')}`,
        ));
        child.stdout.on('data', onData);
        child.on('close', onClose);
      });
    },
    exit,
    terminate() { if (!exited) child.kill('SIGTERM'); },
  };
}

async function waitForVerifiedLock(psql, connection, database, env, first, second, timeout = 15_000) {
  const deadline = Date.now() + timeout;
  while (Date.now() < deadline) {
    if (first.exited || second.exited) throw new Error('A catalog concurrency session exited before blocked overlap was observed');
    const state = await queryJson(psql, connection, database, `
      SELECT jsonb_build_object(
        'firstIdleInTransaction', EXISTS (
          SELECT FROM pg_stat_activity WHERE datname = current_database()
            AND application_name = '${first.applicationName}' AND state = 'idle in transaction'
        ),
        'secondWaitingOnLock', EXISTS (
          SELECT FROM pg_stat_activity WHERE datname = current_database()
            AND application_name = '${second.applicationName}' AND state = 'active' AND wait_event_type = 'Lock'
        )
      )`, { env: postgresEnvironment(env) });
    if (state.firstIdleInTransaction && state.secondWaitingOnLock) return;
    await new Promise(resolve => setTimeout(resolve, 50));
  }
  throw new Error(`No verified lock overlap for ${first.applicationName} and ${second.applicationName}`);
}

function graphCase(base) {
  const game = base;
  const left = base - 1;
  const right = base - 2;
  return {
    setup: `
      INSERT INTO heroes_watch."Game" ("Game_id", "SeriesCode", "DisplayOrder", "Name")
      VALUES (${game}, 'HOMM3', -30000, 'Concurrency H3');
      INSERT INTO heroes_watch."Creature" ("Creature_id", "Game_id", "Code", "Name") VALUES
        (${left}, ${game}, 'CONCURRENCY_LEFT', 'Concurrency left'),
        (${right}, ${game}, 'CONCURRENCY_RIGHT', 'Concurrency right');`,
    actions: {
      forward: { sql: `INSERT INTO heroes_watch."CreatureUpgrade" ("CreatureUpgrade_cid", "Game_id", "BaseCreature_id", "UpgradedCreature_id") VALUES ('concurrency.graph.forward', ${game}, ${left}, ${right})`, prime: true },
      reverse: { sql: `INSERT INTO heroes_watch."CreatureUpgrade" ("CreatureUpgrade_cid", "Game_id", "BaseCreature_id", "UpgradedCreature_id") VALUES ('concurrency.graph.reverse', ${game}, ${right}, ${left})`, prime: true },
    },
    verify: `SELECT jsonb_build_object(
      'rows', (SELECT count(*) FROM heroes_watch."CreatureUpgrade" WHERE "Game_id" = ${game}),
      'invalid', EXISTS (
        SELECT 1 FROM heroes_watch."CreatureUpgrade" a JOIN heroes_watch."CreatureUpgrade" b
          ON a."Game_id" = b."Game_id" AND a."BaseCreature_id" = b."UpgradedCreature_id"
         AND a."UpgradedCreature_id" = b."BaseCreature_id"
        WHERE a."Game_id" = ${game}
      ))`,
    assertState(state) { assert.equal(state.rows, 1); assert.equal(state.invalid, false); },
    cleanup: `
      DELETE FROM heroes_watch."CreatureUpgrade" WHERE "Game_id" = ${game};
      DELETE FROM heroes_watch."Creature" WHERE "Game_id" = ${game};
      DELETE FROM heroes_watch."Game" WHERE "Game_id" = ${game};`,
  };
}

function resourceCase(base) {
  const game = base;
  const resource = base - 1;
  return {
    setup: `
      INSERT INTO heroes_watch."Game" ("Game_id", "SeriesCode", "DisplayOrder", "Name")
      VALUES (${game}, 'HOMM8', -30001, 'Concurrency H8');
      INSERT INTO heroes_watch."Resource" ("Resource_id", "Code", "Name")
      VALUES (${resource}, 'CONCURRENCY_RESOURCE', 'Concurrency resource');
      INSERT INTO heroes_watch."GameResource" ("GameResource_cid", "Game_id", "Resource_id")
      VALUES ('concurrency.resource.membership', ${game}, ${resource});`,
    actions: {
      forward: { sql: `INSERT INTO heroes_watch."ResourceHOMM8" ("Resource_id", "ResourceRole", "Scope", "IsTradeable", "IsMineProduced", "IsPersistent") VALUES (${resource}, 'Stockpile', 'Kingdom', FALSE, FALSE, TRUE)`, prime: true },
      reverse: { sql: `DELETE FROM heroes_watch."GameResource" WHERE "Game_id" = ${game} AND "Resource_id" = ${resource}`, prime: true },
    },
    verify: `SELECT jsonb_build_object(
      'membership', (SELECT count(*) FROM heroes_watch."GameResource" WHERE "Game_id" = ${game} AND "Resource_id" = ${resource}),
      'detail', (SELECT count(*) FROM heroes_watch."ResourceHOMM8" WHERE "Resource_id" = ${resource}),
      'invalid', (NOT EXISTS (SELECT 1 FROM heroes_watch."GameResource" WHERE "Game_id" = ${game} AND "Resource_id" = ${resource})
        AND EXISTS (SELECT 1 FROM heroes_watch."ResourceHOMM8" WHERE "Resource_id" = ${resource})))`,
    assertState(state) {
      assert.equal(state.invalid, false);
      assert.ok((state.membership === 1 && state.detail === 1) || (state.membership === 0 && state.detail === 0));
    },
    cleanup: `
      DELETE FROM heroes_watch."ResourceHOMM8" WHERE "Resource_id" = ${resource};
      DELETE FROM heroes_watch."GameResource" WHERE "Game_id" = ${game} AND "Resource_id" = ${resource};
      DELETE FROM heroes_watch."Resource" WHERE "Resource_id" = ${resource};
      DELETE FROM heroes_watch."Game" WHERE "Game_id" = ${game};`,
  };
}

function townCase(base) {
  const game = base;
  const factionA = base - 1;
  const factionB = base - 2;
  const building = base - 3;
  const screen = base - 4;
  return {
    setup: `
      INSERT INTO heroes_watch."Game" ("Game_id", "SeriesCode", "DisplayOrder", "Name")
      VALUES (${game}, 'HOMM3', -30002, 'Concurrency town H3');
      INSERT INTO heroes_watch."Faction" ("Faction_id", "Game_id", "Code", "Name") VALUES
        (${factionA}, ${game}, 'CONCURRENCY_A', 'Concurrency faction A'),
        (${factionB}, ${game}, 'CONCURRENCY_B', 'Concurrency faction B');
      INSERT INTO heroes_watch."Building" ("Building_id", "Game_id", "Code", "Name")
      VALUES (${building}, ${game}, 'CONCURRENCY_BUILDING', 'Concurrency building');
      INSERT INTO heroes_watch."TownScreen" ("TownScreen_id", "Game_id", "Faction_id", "Code", "Name")
      VALUES (${screen}, ${game}, ${factionA}, 'CONCURRENCY_SCREEN', 'Concurrency screen');`,
    actions: {
      forward: { sql: `INSERT INTO heroes_watch."TownScreenBuilding" ("TownScreenBuilding_cid", "Game_id", "TownScreen_id", "Building_id") VALUES ('concurrency.town.link', ${game}, ${screen}, ${building})`, prime: true },
      reverse: { sql: `INSERT INTO heroes_watch."BuildingHOMM3" ("Building_id", "Faction_id") VALUES (${building}, ${factionB})`, prime: true },
    },
    verify: `SELECT jsonb_build_object(
      'link', (SELECT count(*) FROM heroes_watch."TownScreenBuilding" WHERE "TownScreen_id" = ${screen} AND "Building_id" = ${building}),
      'detail', (SELECT count(*) FROM heroes_watch."BuildingHOMM3" WHERE "Building_id" = ${building}),
      'invalid', EXISTS (
        SELECT 1 FROM heroes_watch."TownScreenBuilding" link
        JOIN heroes_watch."TownScreen" screen ON screen."TownScreen_id" = link."TownScreen_id"
        JOIN heroes_watch."BuildingHOMM3" detail ON detail."Building_id" = link."Building_id"
        WHERE link."TownScreen_id" = ${screen} AND detail."Faction_id" IS DISTINCT FROM screen."Faction_id"
      ))`,
    assertState(state) {
      assert.equal(state.invalid, false);
      assert.ok((state.link === 1 && state.detail === 0) || (state.link === 0 && state.detail === 1));
    },
    cleanup: `
      DELETE FROM heroes_watch."TownScreenBuilding" WHERE "TownScreen_id" = ${screen};
      DELETE FROM heroes_watch."BuildingHOMM3" WHERE "Building_id" = ${building};
      DELETE FROM heroes_watch."TownScreen" WHERE "TownScreen_id" = ${screen};
      DELETE FROM heroes_watch."Building" WHERE "Building_id" = ${building};
      DELETE FROM heroes_watch."Faction" WHERE "Game_id" = ${game};
      DELETE FROM heroes_watch."Game" WHERE "Game_id" = ${game};`,
  };
}

async function executeSql(psql, connection, database, env, sql, timeout = 30_000) {
  return requireSuccess(psql, psqlArgs(connection, database, ['--command', sql]), {
    env: postgresEnvironment(env), timeout, quiet: true,
  });
}

async function runOneCase({ psql, connection, database, env }, descriptor, index) {
  const factory = descriptor.family === 'graph-cycle' ? graphCase
    : descriptor.family === 'homm8-resource' ? resourceCase : townCase;
  const fixture = factory(-9_700_000 - index * 20);
  const firstKey = descriptor.order === 'forward-first' ? 'forward' : 'reverse';
  const secondKey = firstKey === 'forward' ? 'reverse' : 'forward';
  const firstAction = fixture.actions[firstKey];
  const secondAction = fixture.actions[secondKey];
  // PostgreSQL truncates application_name at 63 bytes. The case index already
  // identifies family/order/isolation; keep names safe even with long PIDs.
  const suffix = `${process.pid}_${index}`;
  const first = startPsqlSession(psql, connection, database, env, `hw_catalog_first_${suffix}`);
  const second = startPsqlSession(psql, connection, database, env, `hw_catalog_second_${suffix}`);
  let firstResult;
  let secondResult;
  try {
    await executeSql(psql, connection, database, env, fixture.setup);
    first.send(`BEGIN ISOLATION LEVEL ${descriptor.isolation};\n${firstAction.sql};\n${firstAction.prime ? 'SET CONSTRAINTS ALL IMMEDIATE;\n' : ''}\\echo HW_CATALOG_FIRST_READY\n`);
    await first.waitForOutput('HW_CATALOG_FIRST_READY');
    second.send(`BEGIN ISOLATION LEVEL ${descriptor.isolation};\n${secondAction.sql};\nCOMMIT;\n`, true);
    await waitForVerifiedLock(psql, connection, database, env, first, second);
    first.send('COMMIT;\n\\q\n', true);
    [firstResult, secondResult] = await Promise.all([first.exit, second.exit]);

    const successful = [firstResult, secondResult].filter(result => result.code === 0);
    const failed = [firstResult, secondResult].filter(result => result.code !== 0);
    assert.equal(successful.length, 1, `${descriptor.family}/${descriptor.order}/${descriptor.isolation}: exactly one writer must commit`);
    assert.equal(failed.length, 1, `${descriptor.family}/${descriptor.order}/${descriptor.isolation}: exactly one writer must abort`);
    const sqlState = failureCode(failed[0]);
    assert.ok(['23514', '40001', '40P01'].includes(sqlState),
      `${descriptor.family}/${descriptor.order}/${descriptor.isolation}: unexpected SQLSTATE ${sqlState ?? 'none'}\n${failed[0].stderr}`);
    const state = await queryJson(psql, connection, database, fixture.verify, { env: postgresEnvironment(env) });
    fixture.assertState(state);
    return {
      ...descriptor,
      overlapVerified: true,
      committedWriter: firstResult.code === 0 ? firstKey : secondKey,
      abortedWriter: firstResult.code === 0 ? secondKey : firstKey,
      failureSqlState: sqlState,
    };
  } finally {
    first.terminate();
    second.terminate();
    await Promise.allSettled([first.exit, second.exit]);
    try {
      await executeSql(psql, connection, database, env, fixture.cleanup);
    } catch (error) {
      error.message = `${descriptor.family}/${descriptor.order}/${descriptor.isolation}: cleanup failed: ${error.message}`;
      throw error;
    }
  }
}

export async function runCatalogConcurrency({ psql, connection, database, env = process.env }) {
  if (!psql || !connection?.host || !connection?.port || !connection?.user || !database) {
    throw new Error('runCatalogConcurrency requires psql, host/port/user connection settings, and a disposable database');
  }
  const results = [];
  for (const [index, descriptor] of catalogConcurrencyCaseMatrix.entries()) {
    results.push(await runOneCase({ psql, connection, database, env }, descriptor, index));
  }
  return results;
}

function repeatableGraphCase(base) {
  const game = base;
  const left = base - 1;
  const right = base - 2;
  return {
    setup: `
      INSERT INTO heroes_watch."Game" ("Game_id", "SeriesCode", "DisplayOrder", "Name") VALUES (${game}, 'HOMM3', -30010, 'RR graph H3');
      INSERT INTO heroes_watch."Creature" ("Creature_id", "Game_id", "Code", "Name") VALUES
        (${left}, ${game}, 'RR_LEFT', 'RR left'), (${right}, ${game}, 'RR_RIGHT', 'RR right');
      INSERT INTO heroes_watch."CreatureUpgrade" ("CreatureUpgrade_cid", "Game_id", "BaseCreature_id", "UpgradedCreature_id")
        VALUES ('rr.graph.existing', ${game}, ${left}, ${right});`,
    rejected: `INSERT INTO heroes_watch."CreatureUpgrade" ("CreatureUpgrade_cid", "Game_id", "BaseCreature_id", "UpgradedCreature_id") VALUES ('rr.graph.rejected', ${game}, ${right}, ${left})`,
    allowed: `UPDATE heroes_watch."CreatureUpgrade" SET "BaseCreature_id" = "BaseCreature_id" WHERE "CreatureUpgrade_cid" = 'rr.graph.existing'`,
    verify: `SELECT jsonb_build_object('rows', (SELECT count(*) FROM heroes_watch."CreatureUpgrade" WHERE "Game_id" = ${game}), 'rejectedPresent', EXISTS (SELECT 1 FROM heroes_watch."CreatureUpgrade" WHERE "CreatureUpgrade_cid" = 'rr.graph.rejected'))`,
    assertState(state) { assert.equal(state.rows, 1); assert.equal(state.rejectedPresent, false); },
    cleanup: `DELETE FROM heroes_watch."CreatureUpgrade" WHERE "Game_id" = ${game}; DELETE FROM heroes_watch."Creature" WHERE "Game_id" = ${game}; DELETE FROM heroes_watch."Game" WHERE "Game_id" = ${game};`,
  };
}

function repeatableResourceCase(base) {
  const game = base;
  const first = base - 1;
  const second = base - 2;
  return {
    setup: `
      INSERT INTO heroes_watch."Game" ("Game_id", "SeriesCode", "DisplayOrder", "Name") VALUES (${game}, 'HOMM8', -30011, 'RR resource H8');
      INSERT INTO heroes_watch."Resource" ("Resource_id", "Code", "Name") VALUES
        (${first}, 'RR_RESOURCE_FIRST', 'RR resource first'), (${second}, 'RR_RESOURCE_SECOND', 'RR resource second');
      INSERT INTO heroes_watch."GameResource" ("GameResource_cid", "Game_id", "Resource_id") VALUES
        ('rr.resource.first', ${game}, ${first}), ('rr.resource.second', ${game}, ${second});
      INSERT INTO heroes_watch."ResourceHOMM8" ("Resource_id", "ResourceRole", "Scope", "IsTradeable", "IsMineProduced", "IsPersistent", "Mechanics")
        VALUES (${first}, 'Stockpile', 'Kingdom', FALSE, FALSE, TRUE, NULL);`,
    rejected: `INSERT INTO heroes_watch."ResourceHOMM8" ("Resource_id", "ResourceRole", "Scope", "IsTradeable", "IsMineProduced", "IsPersistent") VALUES (${second}, 'Stockpile', 'Kingdom', FALSE, FALSE, TRUE)`,
    allowed: `UPDATE heroes_watch."ResourceHOMM8" SET "Mechanics" = 'RR allowed notes edit' WHERE "Resource_id" = ${first}`,
    verify: `SELECT jsonb_build_object('rows', (SELECT count(*) FROM heroes_watch."ResourceHOMM8" WHERE "Resource_id" IN (${first}, ${second})), 'allowedNotes', (SELECT "Mechanics" FROM heroes_watch."ResourceHOMM8" WHERE "Resource_id" = ${first}), 'rejectedPresent', EXISTS (SELECT 1 FROM heroes_watch."ResourceHOMM8" WHERE "Resource_id" = ${second}))`,
    assertState(state) { assert.equal(state.rows, 1); assert.equal(state.allowedNotes, 'RR allowed notes edit'); assert.equal(state.rejectedPresent, false); },
    cleanup: `DELETE FROM heroes_watch."ResourceHOMM8" WHERE "Resource_id" IN (${first}, ${second}); DELETE FROM heroes_watch."GameResource" WHERE "Game_id" = ${game}; DELETE FROM heroes_watch."Resource" WHERE "Resource_id" IN (${first}, ${second}); DELETE FROM heroes_watch."Game" WHERE "Game_id" = ${game};`,
  };
}

function repeatableTownCase(base) {
  const game = base;
  const faction = base - 1;
  const buildingA = base - 2;
  const buildingB = base - 3;
  const screen = base - 4;
  return {
    setup: `
      INSERT INTO heroes_watch."Game" ("Game_id", "SeriesCode", "DisplayOrder", "Name") VALUES (${game}, 'HOMM3', -30012, 'RR town H3');
      INSERT INTO heroes_watch."Faction" ("Faction_id", "Game_id", "Code", "Name") VALUES (${faction}, ${game}, 'RR_FACTION', 'RR faction');
      INSERT INTO heroes_watch."Building" ("Building_id", "Game_id", "Code", "Name") VALUES
        (${buildingA}, ${game}, 'RR_BUILDING_A', 'RR building A'), (${buildingB}, ${game}, 'RR_BUILDING_B', 'RR building B');
      INSERT INTO heroes_watch."BuildingHOMM3" ("Building_id", "Faction_id") VALUES (${buildingA}, ${faction});
      INSERT INTO heroes_watch."TownScreen" ("TownScreen_id", "Game_id", "Faction_id", "Code", "Name") VALUES (${screen}, ${game}, ${faction}, 'RR_SCREEN', 'RR screen');
      INSERT INTO heroes_watch."TownScreenBuilding" ("TownScreenBuilding_cid", "Game_id", "TownScreen_id", "Building_id") VALUES ('rr.town.existing', ${game}, ${screen}, ${buildingA});`,
    rejected: `INSERT INTO heroes_watch."TownScreenBuilding" ("TownScreenBuilding_cid", "Game_id", "TownScreen_id", "Building_id") VALUES ('rr.town.rejected', ${game}, ${screen}, ${buildingB})`,
    allowed: `UPDATE heroes_watch."TownScreenBuilding" SET "Hotspot" = '{"x":1}'::jsonb WHERE "TownScreenBuilding_cid" = 'rr.town.existing'`,
    verify: `SELECT jsonb_build_object('rows', (SELECT count(*) FROM heroes_watch."TownScreenBuilding" WHERE "TownScreen_id" = ${screen}), 'allowedHotspot', (SELECT "Hotspot" FROM heroes_watch."TownScreenBuilding" WHERE "TownScreenBuilding_cid" = 'rr.town.existing'), 'rejectedPresent', EXISTS (SELECT 1 FROM heroes_watch."TownScreenBuilding" WHERE "TownScreenBuilding_cid" = 'rr.town.rejected'))`,
    assertState(state) { assert.equal(state.rows, 1); assert.deepEqual(state.allowedHotspot, { x: 1 }); assert.equal(state.rejectedPresent, false); },
    cleanup: `DELETE FROM heroes_watch."TownScreenBuilding" WHERE "TownScreen_id" = ${screen}; DELETE FROM heroes_watch."BuildingHOMM3" WHERE "Building_id" IN (${buildingA}, ${buildingB}); DELETE FROM heroes_watch."TownScreen" WHERE "TownScreen_id" = ${screen}; DELETE FROM heroes_watch."Building" WHERE "Building_id" IN (${buildingA}, ${buildingB}); DELETE FROM heroes_watch."Faction" WHERE "Faction_id" = ${faction}; DELETE FROM heroes_watch."Game" WHERE "Game_id" = ${game};`,
  };
}

async function rawSql(psql, connection, database, env, sql) {
  return runProcess(psql, psqlArgs(connection, database, ['--set', 'VERBOSITY=verbose', '--command', sql]), {
    env: postgresEnvironment(env), timeout: 30_000, quiet: true,
  });
}

export async function runCatalogRepeatableReadControls({ psql, connection, database, env = process.env }) {
  if (!psql || !connection?.host || !connection?.port || !connection?.user || !database) {
    throw new Error('runCatalogRepeatableReadControls requires psql, host/port/user connection settings, and a disposable database');
  }
  const factories = [repeatableGraphCase, repeatableResourceCase, repeatableTownCase];
  const results = [];
  for (const [index, family] of catalogRepeatableReadFamilies.entries()) {
    const fixture = factories[index](-9_800_000 - index * 20);
    try {
      await executeSql(psql, connection, database, env, fixture.setup);
      const rejected = await rawSql(psql, connection, database, env,
        `BEGIN ISOLATION LEVEL REPEATABLE READ; ${fixture.rejected}; SET CONSTRAINTS ALL IMMEDIATE; COMMIT;`);
      assert.notEqual(rejected.code, 0, `${family}: relevant REPEATABLE READ write unexpectedly committed`);
      assert.equal(failureCode(rejected), '0A000', `${family}: expected SQLSTATE 0A000\n${rejected.stderr}`);
      await executeSql(psql, connection, database, env,
        `BEGIN ISOLATION LEVEL REPEATABLE READ; ${fixture.allowed}; SET CONSTRAINTS ALL IMMEDIATE; COMMIT;`);
      const state = await queryJson(psql, connection, database, fixture.verify, { env: postgresEnvironment(env) });
      fixture.assertState(state);
      results.push({ family, rejectedSqlState: '0A000', allowedControl: 'PASS' });
    } finally {
      await executeSql(psql, connection, database, env, fixture.cleanup);
    }
  }
  return results;
}
