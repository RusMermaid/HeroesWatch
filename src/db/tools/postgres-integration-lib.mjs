import assert from 'node:assert/strict';
import { spawn } from 'node:child_process';
import { isDeepStrictEqual } from 'node:util';

export const quoteIdentifier = value => `"${value.replaceAll('"', '""')}"`;
export const quoteLiteral = value => `'${String(value).replaceAll("'", "''")}'`;

export function runProcess(command, args, options = {}) {
  const { input, timeout = 120_000, env = process.env, quiet = false } = options;
  return new Promise((resolve, reject) => {
    const child = spawn(command, args, { env, stdio: ['pipe', 'pipe', 'pipe'] });
    const stdout = [];
    const stderr = [];
    const timer = setTimeout(() => {
      child.kill('SIGTERM');
      reject(new Error(`${command} timed out after ${timeout} ms`));
    }, timeout);
    child.stdout.on('data', chunk => stdout.push(chunk));
    child.stderr.on('data', chunk => stderr.push(chunk));
    child.on('error', error => {
      clearTimeout(timer);
      reject(error);
    });
    child.on('close', code => {
      clearTimeout(timer);
      const result = {
        code,
        stdout: Buffer.concat(stdout).toString('utf8'),
        stderr: Buffer.concat(stderr).toString('utf8'),
      };
      if (!quiet && result.stdout) process.stdout.write(result.stdout);
      if (!quiet && result.stderr) process.stderr.write(result.stderr);
      resolve(result);
    });
    if (input !== undefined) child.stdin.end(input);
    else child.stdin.end();
  });
}

export async function requireSuccess(command, args, options = {}) {
  const result = await runProcess(command, args, options);
  if (result.code !== 0) {
    const detail = (result.stderr || result.stdout).trim();
    throw new Error(`${command} exited with ${result.code}${detail ? `:\n${detail}` : ''}`);
  }
  return result;
}

export function psqlArgs(connection, database, extra = []) {
  return [
    '-X', '--no-password', '--set', 'ON_ERROR_STOP=1',
    '--host', connection.host,
    '--port', connection.port,
    '--username', connection.user,
    '--dbname', database,
    ...extra,
  ];
}

export function postgresEnvironment(base = process.env) {
  return {
    ...base,
    PGCONNECT_TIMEOUT: base.PGCONNECT_TIMEOUT ?? '8',
    PGOPTIONS: base.PGOPTIONS ?? '-c statement_timeout=120000 -c lock_timeout=15000',
  };
}

export async function queryJson(psql, connection, database, sql, options = {}) {
  const result = await requireSuccess(psql, psqlArgs(connection, database, ['--tuples-only', '--no-align', '--command', sql]), {
    ...options,
    quiet: true,
    env: postgresEnvironment(options.env),
  });
  const value = result.stdout.trim();
  assert(value, 'PostgreSQL query returned no JSON');
  return JSON.parse(value);
}

export function inventorySql(schema) {
  const parts = schema.tables.map(table =>
    `SELECT ${quoteLiteral(table.name)} AS name, COALESCE(jsonb_agg(to_jsonb(t)), '[]'::jsonb) AS rows FROM heroes_watch.${quoteIdentifier(table.name)} AS t`,
  );
  return `SELECT jsonb_object_agg(name, rows) FROM (${parts.join(' UNION ALL ')}) AS inventory`;
}

export function fingerprintSql(schema) {
  const parts = schema.tables.map(table => {
    const qualified = `heroes_watch.${quoteIdentifier(table.name)}`;
    return `SELECT ${quoteLiteral(table.name)} AS name, count(*) AS row_count, md5(COALESCE(string_agg(to_jsonb(t)::text, E'\\n' ORDER BY to_jsonb(t)::text), '')) AS digest FROM ${qualified} AS t`;
  });
  return `SELECT jsonb_object_agg(name, jsonb_build_object('rows', row_count, 'digest', digest)) FROM (${parts.join(' UNION ALL ')}) AS fingerprints`;
}

const identityPolicies = {
  ArtifactSetBonusHOMM5: ['ArtifactSetHOMM5_id', 'RequiredPieceCount', 'HeroClass_id'],
};

/**
 * Reconcile every supplied JSON field with a freshly imported PostgreSQL
 * catalog. Foreign-key aliases are resolved through the actual physical IDs,
 * including explicit TEXT junction IDs and nullable natural-key members.
 */
export function reconcileInventory(schema, bundle, actual) {
  const tables = new Map(schema.tables.map(table => [table.name, table]));
  const mapped = new Map(schema.tables.map(table => [table.name, new Map()]));
  const aliases = new Map(schema.tables.map(table => [table.name, new Map()]));
  const pending = [];
  let expectedRows = 0;

  for (const table of schema.tables) {
    const expectedTable = bundle.tables[table.name];
    assert(Array.isArray(expectedTable), `${table.name}: source table array is missing`);
    assert(Array.isArray(actual[table.name]), `${table.name}: database table inventory is missing`);
    assert.equal(actual[table.name].length, expectedTable.length, `${table.name}: row count differs`);
    expectedRows += expectedTable.length;
    for (const row of expectedTable) pending.push({ table, row });
  }

  const fkFor = (table, column) => table.foreignKeys.find(fk =>
    fk.columns.length === 1 && fk.columns[0] === column,
  );
  const resolveValue = (table, row, column) => {
    const field = table.columns.find(candidate => candidate.name === column);
    const fk = fkFor(table, column);
    let value = row[column];
    if (value === undefined && table.primaryKey.includes(column)) {
      if (fk) value = row._key;
      else if (field?.postgresType === 'TEXT') value = row._key;
    }
    if (value === undefined && field?.nullable) return null;
    if (!fk || value === null || value === undefined) return value;
    const parent = aliases.get(fk.referencedTable).get(String(value));
    return parent?.[fk.referencedColumns[0]];
  };

  let work = pending;
  while (work.length) {
    const next = [];
    for (const item of work) {
      const { table, row } = item;
      const pk = table.primaryKey[0];
      const pkColumn = table.columns.find(column => column.name === pk);
      const sharedPk = fkFor(table, pk);
      const naturalKeys = [
        ...(table.uniqueConstraints ?? []).map(constraint => constraint.columns),
        ...(table.unique ?? []),
      ].filter(columns => !columns.includes(pk));
      let key;
      if (sharedPk) key = [pk];
      else if (pkColumn?.postgresType === 'TEXT' && !pkColumn.generatedIdentity) key = [pk];
      else key = naturalKeys.find(columns => columns.every(column =>
        Object.hasOwn(row, column) || table.columns.find(field => field.name === column)?.nullable,
      )) ?? (identityPolicies[table.name] ? [identityPolicies[table.name]] : []).flat();
      if (!key?.length) throw new Error(`${table.name}/${row._key}: no reconcilable identity`);

      const values = key.map(column => resolveValue(table, row, column));
      const unresolved = key.some((column, index) => {
        const value = row[column] ?? (table.primaryKey.includes(column) ? row._key : undefined);
        return fkFor(table, column) && value !== null && value !== undefined && values[index] === undefined;
      });
      if (unresolved) {
        next.push(item);
        continue;
      }
      const matches = actual[table.name].filter(candidate =>
        key.every((column, index) => isDeepStrictEqual(candidate[column], values[index])),
      );
      assert.equal(matches.length, 1, `${table.name}/${row._key}: expected exactly one physical identity using (${key.join(', ')})`);
      const match = matches[0];
      mapped.get(table.name).set(row._key, match);
      for (const alias of [row._key, row[pk]]) {
        if (alias === null || alias === undefined) continue;
        const existing = aliases.get(table.name).get(String(alias));
        assert(!existing || existing === match, `${table.name}: ambiguous alias ${String(alias)}`);
        aliases.get(table.name).set(String(alias), match);
      }
    }
    assert(next.length < work.length,
      `Unresolved identities: ${next.slice(0, 20).map(item => `${item.table.name}/${item.row._key}`).join(', ')}`);
    work = next;
  }

  let comparedFields = 0;
  for (const table of schema.tables) {
    for (const expected of bundle.tables[table.name]) {
      const physical = mapped.get(table.name).get(expected._key);
      assert(physical, `${table.name}/${expected._key}: physical row was not mapped`);
      for (const column of Object.keys(expected).filter(column => column !== '_key')) {
        assert.deepEqual(physical[column], resolveValue(table, expected, column),
          `${table.name}/${expected._key}.${column}`);
        comparedFields++;
      }
    }
  }

  // Independently traverse every non-null FK from the database inventory.
  // This is intentionally redundant with PostgreSQL: it also proves the
  // generated semantic contract describes the constraints that were loaded.
  const indexes = new Map();
  const tuple = values => JSON.stringify(values);
  const parentIndex = (tableName, columns) => {
    const signature = `${tableName}:${columns.join(',')}`;
    if (!indexes.has(signature)) {
      const index = new Map();
      for (const row of actual[tableName]) {
        const key = tuple(columns.map(column => row[column]));
        index.set(key, (index.get(key) ?? 0) + 1);
      }
      indexes.set(signature, index);
    }
    return indexes.get(signature);
  };
  let checkedRelationships = 0;
  for (const table of schema.tables) {
    for (const row of actual[table.name]) {
      for (const fk of table.foreignKeys) {
        const values = fk.columns.map(column => row[column]);
        if (values.some(value => value === null)) continue;
        const count = parentIndex(fk.referencedTable, fk.referencedColumns).get(tuple(values)) ?? 0;
        assert.equal(count, 1, `${table.name}: broken or ambiguous FK ${fk.name}`);
        checkedRelationships++;
      }
    }
  }

  return { tableArrays: schema.tables.length, expectedRows, comparedFields, checkedRelationships };
}
