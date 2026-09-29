#!/usr/bin/env node
// Build a reviewed, transactional catalog import; never connect to PostgreSQL.
import fs from 'node:fs';
import path from 'node:path';
import process from 'node:process';
import { createHash } from 'node:crypto';
import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';

const dbRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const options = { input: path.join(dbRoot, 'data/heroeswatch.json'), schema: path.join(dbRoot, 'schema/heroeswatch.schema.json'), output: path.join(dbRoot, 'data/catalog.sql'), check: false };
for (let i = 2; i < process.argv.length; i++) {
  const arg = process.argv[i];
  if (arg === '--check') options.check = true;
  else if (['--input', '--schema', '--output'].includes(arg)) {
    const value = process.argv[++i];
    if (!value || value.startsWith('--')) throw new Error(`Missing value for ${arg}`);
    options[arg.slice(2)] = path.resolve(value);
  } else if (arg === '--help') {
    console.log('node src/db/tools/build-content-sql.mjs [--input bundle.json] [--schema schema.json] [--output catalog.sql] [--check]');
    process.exit(0);
  } else throw new Error(`Unknown argument: ${arg}`);
}

const validation = spawnSync(process.execPath, [path.join(dbRoot, 'tools/validate.mjs'), options.input, options.schema], { encoding: 'utf8' });
if (validation.error) throw validation.error;
process.stdout.write(validation.stdout ?? '');
process.stderr.write(validation.stderr ?? '');
if (validation.status !== 0) process.exit(validation.status ?? 1);

const inputText = fs.readFileSync(options.input, 'utf8');
const schemaText = fs.readFileSync(options.schema, 'utf8');
const bundle = JSON.parse(inputText);
const schema = JSON.parse(schemaText);
const tableByName = new Map(schema.tables.map(table => [table.name, table]));
const quoteIdentifier = value => '"' + value.replaceAll('"', '""') + '"';
const quoteText = value => {
  if (value.includes('\0')) throw new Error('PostgreSQL text cannot contain a NUL character');
  // Explicit escape literals work even when a GUI submits this whole script
  // with standard_conforming_strings disabled before the transaction starts.
  return "E'" + value.replaceAll("\\", "\\\\").replaceAll("'", "''") + "'";
};
const qualified = table => `${quoteIdentifier(schema.postgresSchema)}.${quoteIdentifier(table.name)}`;
const identifier = (table, key) => JSON.stringify([table, key]);
const compare = (a, b) => a < b ? -1 : a > b ? 1 : 0;
const nodes = new Map();
const incomingBusinessKeys = new Map();

// Only identity-defining dependencies must be acyclic. Other FK cycles work
// because all identities are known before any complete row is inserted.
for (const table of schema.tables) {
  if (table.primaryKey.length !== 1 || table.foreignKeys.some(fk => fk.columns.length !== 1 || fk.referencedColumns.length !== 1)) {
    if (bundle.tables[table.name].length) throw new Error(`${table.name}: this importer requires single-column primary and foreign keys`);
  }
  for (const row of bundle.tables[table.name]) {
    const pk = table.primaryKey[0];
    const columnByName = new Map(table.columns.map(column => [column.name, column]));
    const pkColumn = columnByName.get(pk);
    const parent = table.foreignKeys.find(fk => fk.columns[0] === pk);
    const identityKind = parent ? 'shared' : pkColumn.generatedIdentity ? 'generated' : pkColumn.postgresType === 'TEXT' ? 'text' : null;
    if (!identityKind) throw new Error(`${table.name}: unsupported identity type`);
    if (identityKind === 'generated' && row[pk] !== undefined) throw new Error(`${table.name}/${row._key}: omit generated primary key ${pk}; identity is resolved by the declared business key`);
    const values = { ...row };
    delete values._key;
    if (identityKind === 'shared' && values[pk] === undefined) values[pk] = row._key;
    if (identityKind === 'text' && values[pk] === undefined) values[pk] = row._key;
    const businessKey = identityKind === 'shared' ? [pk] : table.unique.find(columns => columns.every(column => Object.hasOwn(values, column) || columnByName.get(column).nullable));
    if (identityKind === 'generated' && !businessKey) throw new Error(`${table.name}/${row._key}: no complete declared business key; add a reviewed identity policy before importing this table`);
    if (businessKey) {
      const signature = JSON.stringify([table.name, businessKey, businessKey.map(column => values[column])]);
      if (incomingBusinessKeys.has(signature)) throw new Error(`${table.name}/${row._key}: business key also supplied by ${incomingBusinessKeys.get(signature)}; nullable key members still require unambiguous import identity`);
      incomingBusinessKeys.set(signature, row._key);
    }
    for (const column of table.columns) {
      if (column.default !== null && !column.generatedIdentity && !Object.hasOwn(values, column.name)) throw new Error(`${table.name}/${row._key}: explicitly supply ${column.name}; implicit column defaults need a reviewed import policy`);
    }
    nodes.set(identifier(table.name, row._key), { table, row, values, columnByName, pk, pkColumn, identityKind, businessKey, dependencies: new Set() });
  }
}

function referencedNode(node, fk, value) {
  if (typeof value === 'string') return nodes.get(identifier(fk.referencedTable, value));
  return [...nodes.values()].find(candidate => candidate.table.name === fk.referencedTable && candidate.row[fk.referencedColumns[0]] === value);
}
for (const node of nodes.values()) {
  for (const column of node.businessKey ?? []) {
    const fk = node.table.foreignKeys.find(candidate => candidate.columns[0] === column);
    const value = node.values[column];
    if (!fk || value === null || value === undefined) continue;
    const referenced = referencedNode(node, fk, value);
    if (!referenced) throw new Error(`${node.table.name}/${node.row._key}: missing identity dependency ${column}`);
    node.dependencies.add(identifier(referenced.table.name, referenced.row._key));
  }
}
const ordered = [];
const visited = new Set();
const active = new Set();
function visit(key, chain = []) {
  if (visited.has(key)) return;
  if (active.has(key)) throw new Error(`Cyclic business-key dependencies require an explicit identity policy: ${[...chain, key].join(' -> ')}`);
  active.add(key);
  const node = nodes.get(key);
  for (const dependency of [...node.dependencies].sort(compare)) visit(dependency, [...chain, key]);
  active.delete(key);
  visited.add(key);
  ordered.push(node);
}
for (const key of [...nodes.keys()].sort(compare)) visit(key);

const mapName = 'pg_temp.heroeswatch_import_keys';
const rowId = (tableName, key) => `(SELECT row_id FROM ${mapName} WHERE table_name = ${quoteText(tableName)} AND import_key = ${quoteText(key)})`;
function typeName(column) {
  return column.enumValues ? `${quoteIdentifier(schema.postgresSchema)}.${quoteIdentifier(column.postgresType)}` : column.postgresType;
}
function sqlValue(node, columnName) {
  const column = node.columnByName.get(columnName);
  const value = node.values[columnName];
  if (value === null || value === undefined) return 'NULL';
  const fk = node.table.foreignKeys.find(candidate => candidate.columns[0] === columnName);
  if (fk) {
    const referenced = referencedNode(node, fk, value);
    if (!referenced) throw new Error(`${node.table.name}/${node.row._key}: missing reference ${columnName}`);
    if (fk.referencedColumns[0] !== referenced.pk) throw new Error(`${node.table.name}: foreign key to a non-primary field needs an explicit mapping`);
    return `${rowId(referenced.table.name, referenced.row._key)}::${typeName(column)}`;
  }
  if (column.postgresType === 'JSONB') return `${quoteText(JSON.stringify(value))}::JSONB`;
  if (typeof value === 'boolean') return value ? 'TRUE' : 'FALSE';
  if (typeof value === 'number') return String(value);
  return `${quoteText(value)}::${typeName(column)}`;
}
let blockNumber = 0;
function block(body, functionName = null) {
  let delimiter;
  do { delimiter = `$heroeswatch_${blockNumber++}$`; } while (body.includes(delimiter));
  const prefix = functionName ? `CREATE FUNCTION ${functionName}(p_key TEXT, p_data JSONB) RETURNS VOID LANGUAGE plpgsql AS` : 'DO';
  return `${prefix} ${delimiter}\n${body}\n${delimiter};\n`;
}
const digest = text => createHash('sha256').update(text).digest('hex');
const output = [
  '-- Generated by src/db/tools/build-content-sql.mjs; do not edit.',
  `-- Content SHA-256 (parsed JSON): ${digest(JSON.stringify(bundle))}`,
  `-- Semantic schema SHA-256 (parsed JSON): ${digest(JSON.stringify(schema))}`,
  `-- ${ordered.length} reviewed rows; existing values are preserved and conflicting non-null values abort the entire transaction.`,
  '-- Run the whole file in pgAdmin Query Tool or psql. No credentials are included.',
  '-- Requires the existing HeroesWatch schema. Helper functions and the key table are temporary.',
  '-- Identity sequence values can advance on a rolled-back attempt, as with ordinary PostgreSQL inserts.',
  'BEGIN;',
  'SET LOCAL standard_conforming_strings = on;',
  "SET LOCAL lock_timeout = '15s';",
  'SET CONSTRAINTS ALL DEFERRED;',
  // Lock in a fixed order to keep a concurrent writer from changing a match
  // between identity resolution and the final conflict check.
  `LOCK TABLE ${[...new Set(ordered.map(node => qualified(node.table)))].sort(compare).join(', ')} IN SHARE ROW EXCLUSIVE MODE;`,
  `CREATE TEMPORARY TABLE heroeswatch_import_keys (table_name TEXT NOT NULL, import_key TEXT NOT NULL, row_id TEXT NOT NULL, PRIMARY KEY (table_name, import_key)) ON COMMIT DROP;`,
  '',
  '-- Typed helper functions are removed before commit.',
];
if (!ordered.length) throw new Error('The bundle has no rows to import');

const policies = new Map();
for (const node of ordered) {
  const signature = JSON.stringify([node.table.name, node.businessKey]);
  if (!policies.has(signature)) policies.set(signature, { node, resolve: `pg_temp.hw_resolve_${policies.size}` });
  node.resolveFunction = policies.get(signature).resolve;
}
const applyFunctions = new Map();
for (const node of ordered) {
  if (!applyFunctions.has(node.table.name)) applyFunctions.set(node.table.name, { node, apply: `pg_temp.hw_apply_${applyFunctions.size}` });
  node.applyFunction = applyFunctions.get(node.table.name).apply;
}

for (const { node, resolve } of policies.values()) {
  const { table, pk, identityKind } = node;
  const qTable = qualified(table);
  const qPk = quoteIdentifier(pk);
  let body = `DECLARE\n  incoming ${qTable}%ROWTYPE;\n  resolved_id TEXT;\n  matches BIGINT;\nBEGIN\n  incoming := jsonb_populate_record(NULL::${qTable}, p_data);`;
  if (identityKind === 'shared') {
    body += `\n  resolved_id := incoming.${qPk}::TEXT;\n  IF resolved_id IS NULL THEN\n    RAISE EXCEPTION 'Missing shared identity: %/%', ${quoteText(table.name)}, p_key;\n  END IF;`;
  } else {
    const natural = node.businessKey?.map(column => `target.${quoteIdentifier(column)} IS NOT DISTINCT FROM incoming.${quoteIdentifier(column)}`).join('\n      AND ');
    const predicate = identityKind === 'text'
      ? `target.${qPk} IS NOT DISTINCT FROM incoming.${qPk}${natural ? `\n      OR (${natural})` : ''}`
      : natural;
    body += `\n  SELECT count(*), min(target.${qPk}::TEXT) INTO matches, resolved_id\n  FROM ${qTable} AS target\n  WHERE ${predicate};\n  IF matches > 1 THEN\n    RAISE EXCEPTION 'Ambiguous existing identity: %/%. Review duplicate business keys or conflicting junction cid.', ${quoteText(table.name)}, p_key;\n  END IF;\n  IF matches = 0 THEN`;
    if (identityKind === 'generated') {
      body += `\n    resolved_id := nextval(pg_get_serial_sequence(${quoteText(qTable)}, ${quoteText(pk)}))::TEXT;\n    IF EXISTS (SELECT 1 FROM ${qTable} WHERE ${qPk} = resolved_id::BIGINT) THEN\n      RAISE EXCEPTION 'Identity sequence behind existing IDs: %/%. Review sequence state before retrying.', ${quoteText(table.name)}, p_key;\n    END IF;`;
    } else body += `\n    resolved_id := incoming.${qPk}::TEXT;`;
    body += '\n  END IF;';
  }
  body += `\n  INSERT INTO ${mapName} (table_name, import_key, row_id)\n  VALUES (${quoteText(table.name)}, p_key, resolved_id);\nEND`;
  output.push(block(body, resolve));
}

for (const { node, apply } of applyFunctions.values()) {
  const { table, pk } = node;
  const qTable = qualified(table);
  const qPk = quoteIdentifier(pk);
  const columns = table.columns;
  const nonPrimaryColumns = columns.filter(column => column.name !== pk);
  let body = `DECLARE\n  incoming ${qTable}%ROWTYPE;\n  existing ${qTable}%ROWTYPE;\nBEGIN\n  incoming := jsonb_populate_record(NULL::${qTable}, p_data);`;
  body += `\n  SELECT * INTO existing FROM ${qTable} WHERE ${qPk} = incoming.${qPk};\n  IF FOUND THEN`;
  // Compare typed fields so SQL NULL and a non-null JSONB literal null stay
  // distinct. Converting whole rows to JSONB would conflate those two states.
  for (const column of columns) {
    const field = quoteIdentifier(column.name);
    body += `\n    IF incoming.${field} IS NOT NULL AND existing.${field} IS NOT NULL AND incoming.${field} IS DISTINCT FROM existing.${field} THEN\n      RAISE EXCEPTION 'Content conflict: %/%.%; existing non-null value retained and import rolled back.', ${quoteText(table.name)}, p_key, ${quoteText(column.name)};\n    END IF;`;
  }
  if (nonPrimaryColumns.length) {
    const assignments = nonPrimaryColumns.map(column => `${quoteIdentifier(column.name)} = COALESCE(existing.${quoteIdentifier(column.name)}, incoming.${quoteIdentifier(column.name)})`).join(',\n        ');
    const missing = nonPrimaryColumns.map(column => `(existing.${quoteIdentifier(column.name)} IS NULL AND incoming.${quoteIdentifier(column.name)} IS NOT NULL)`).join('\n      OR ');
    body += `\n    IF ${missing} THEN\n      UPDATE ${qTable} SET ${assignments}\n      WHERE ${qPk} = incoming.${qPk};\n    END IF;`;
  } else body += '\n    NULL;';
  body += `\n  ELSE\n    INSERT INTO ${qTable} (${columns.map(column => quoteIdentifier(column.name)).join(', ')})${node.identityKind === 'generated' ? '\n    OVERRIDING SYSTEM VALUE' : ''}\n    VALUES (${columns.map(column => `incoming.${quoteIdentifier(column.name)}`).join(', ')});\n  END IF;\nEND`;
  output.push(block(body, apply));
}

function payload(node, columns, resolvedPrimary = false) {
  const staticValues = {};
  const dynamic = [];
  for (const name of columns) {
    const column = node.columnByName.get(name);
    if (resolvedPrimary && name === node.pk) {
      dynamic.push(quoteText(name), `${rowId(node.table.name, node.row._key)}::${typeName(column)}`);
    } else if (node.table.foreignKeys.some(fk => fk.columns[0] === name) && node.values[name] !== null && node.values[name] !== undefined) {
      dynamic.push(quoteText(name), sqlValue(node, name));
    } else staticValues[name] = node.values[name] ?? null;
  }
  const pieces = [`${quoteText(JSON.stringify(staticValues))}::JSONB`];
  // jsonb_build_object accepts at most 100 function arguments.
  for (let i = 0; i < dynamic.length; i += 100) pieces.push(`jsonb_build_object(${dynamic.slice(i, i + 100).join(', ')})`);
  return pieces.join(' || ');
}
output.push('-- Phase 1: resolve existing identities and reserve new sequence values.');
output.push(block('BEGIN\n' + ordered.map(node => {
  const columns = [...new Set([...(node.businessKey ?? []), ...(node.identityKind === 'generated' ? [] : [node.pk])])];
  return `  PERFORM ${node.resolveFunction}(${quoteText(node.row._key)}, ${payload(node, columns)});`;
}).join('\n') + '\nEND'));
output.push('-- Phase 2: compare complete rows, fill nulls, and insert missing content.');
output.push(block('BEGIN\n' + ordered.map(node => {
  const columns = node.table.columns.filter(column => column.name === node.pk || Object.hasOwn(node.values, column.name)).map(column => column.name);
  return `  PERFORM ${node.applyFunction}(${quoteText(node.row._key)}, ${payload(node, columns, true)});`;
}).join('\n') + '\nEND'));
output.push('SET CONSTRAINTS ALL IMMEDIATE;', `SELECT table_name AS imported_table, count(*) AS reviewed_rows FROM ${mapName} GROUP BY table_name ORDER BY table_name;`);
for (const { resolve } of policies.values()) output.push(`DROP FUNCTION ${resolve}(TEXT, JSONB);`);
for (const { apply } of applyFunctions.values()) output.push(`DROP FUNCTION ${apply}(TEXT, JSONB);`);
output.push('COMMIT;', '');
const sql = output.join('\n');
if (options.check) {
  if (!fs.existsSync(options.output) || fs.readFileSync(options.output, 'utf8').replaceAll('\r\n', '\n') !== sql) {
    console.error(`${path.basename(options.output)} is missing or differs from the reviewed content; run the builder without --check.`);
    process.exit(1);
  }
  console.log(`Verified deterministic ${path.basename(options.output)} (${ordered.length} rows).`);
} else {
  fs.mkdirSync(path.dirname(options.output), { recursive: true });
  fs.writeFileSync(options.output, sql);
  console.log(`Built ${path.basename(options.output)} (${ordered.length} rows). No database connection was opened.`);
}
