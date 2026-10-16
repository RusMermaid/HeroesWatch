#!/usr/bin/env node
// Creates and drops only cryptographically named disposable databases.
// PGDATABASE is used solely as the maintenance connection.
import assert from 'node:assert/strict';
import { createHash, randomBytes } from 'node:crypto';
import fs from 'node:fs';
import path from 'node:path';
import process from 'node:process';
import os from 'node:os';
import {rewindResearch} from './rewind-research.mjs';
import {sourceNullableColumns,sourceAddedColumns,sourceDetailChecks} from './source-detail-rules.mjs';
import { fileURLToPath } from 'node:url';
import {
  fingerprintSql,
  inventorySql,
  postgresEnvironment,
  psqlArgs,
  queryJson,
  reconcileInventory,
  runProcess,
} from './postgres-integration-lib.mjs';

const dbRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const repositoryRoot = path.resolve(dbRoot, '..', '..');

if (process.argv.includes('--help')) {
  console.log(`Usage: HW_TEST_POSTGRES=1 PGHOST=... PGPORT=... PGUSER=... node src/db/tools/postgres-upgrade-integration.mjs

Creates random disposable v5 and v7 databases plus guarded-failure clones,
proves both supported upgrades preserve their baseline catalogs, and imports
the reviewed research delta twice on the 45,560-row v7 handoff.
Invalid cost/cycle baselines must roll back v6; a missing warfare role must
roll back every v7 schema change. Unexpected local profile JSON must roll back
the complete enrichment transaction. The runner drops only those exact databases.`);
  process.exit(0);
}
if (process.argv.length !== 2) throw new Error(`Unknown arguments: ${process.argv.slice(2).join(' ')}`);
if (process.env.HW_TEST_POSTGRES !== '1') {
  console.log('PostgreSQL upgrade integration skipped (set HW_TEST_POSTGRES=1 to opt in).');
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
    try { fs.accessSync(candidate, fs.constants.X_OK); return candidate; } catch { /* try PATH */ }
  }
  return name;
};
const psql = binary('psql');
const createdb = binary('createdb');
const dropdb = binary('dropdb');
const token = randomBytes(8).toString('hex');
const prefix = `heroeswatch_upgrade_${process.pid}_${token}`;
const databases = {
  main: `${prefix}_main`,
  badAmount: `${prefix}_bad_amount`,
  badCycle: `${prefix}_bad_cycle`,
  badProfile: `${prefix}_bad_profile`,
  handoff: `${prefix}_handoff`,
  badEnrichment: `${prefix}_bad_enrichment`,
};
for (const database of Object.values(databases)) {
  assert.match(database, /^heroeswatch_upgrade_[0-9]+_[0-9a-f]{16}_(?:main|bad_amount|bad_cycle|bad_profile|handoff|bad_enrichment)$/);
}

const pgEnv = postgresEnvironment(process.env);
const utilityArgs = [
  '--no-password', '--host', connection.host, '--port', connection.port,
  '--username', connection.user, `--maintenance-db=${connection.maintenance}`,
];
const created = [];
const short = value => value.length <= 8000 ? value : `${value.slice(0, 4000)}\n... output truncated ...\n${value.slice(-4000)}`;
async function requireShortSuccess(command, args, options = {}) {
  const result = await runProcess(command, args, { ...options, quiet: true });
  if (result.code !== 0) throw new Error(`${path.basename(command)} exited with ${result.code}:\n${short(result.stderr || result.stdout)}`);
  return result;
}
const psqlFile = (database, file, timeout = 300_000) => requireShortSuccess(
  psql,
  psqlArgs(connection, database, ['--set', 'VERBOSITY=verbose', '--file', path.join(repositoryRoot, file)]),
  { env: pgEnv, timeout },
);
const psqlSql = (database, sql) => runProcess(
  psql,
  psqlArgs(connection, database, ['--set', 'VERBOSITY=verbose', '--command', sql]),
  { env: pgEnv, timeout: 120_000, quiet: true },
);
const successfulSql = async (database, sql) => {
  const result = await psqlSql(database, sql);
  if (result.code !== 0) throw new Error(short(result.stderr || result.stdout));
  return result;
};
const sqlstate = result => `${result.stderr}\n${result.stdout}`.match(/ERROR:\s+([0-9A-Z]{5}):/)?.[1];
const guardNames = [
  'ck__ArtifactResourceCost__Amount_nonnegative',
  'ck__BuildingResourceCost__Amount_nonnegative',
  'ck__CreatureResourceCost__Amount_nonnegative',
  'ck__SpellResourceCostHOMM5__Amount_nonnegative',
  'ck__LoreFull__has_subject',
  'ck__ArtifactComponent__no_self_edge',
  'ck__BuildingRequirement__no_self_edge',
  'ck__BuildingUpgrade__no_self_edge',
  'ck__CreatureUpgrade__no_self_edge',
  'ck__ScenarioConnection__no_self_edge',
];
const guardStateSql = `SELECT jsonb_build_object(
  'constraints', (SELECT count(*) FROM pg_constraint c JOIN pg_namespace n ON n.oid=c.connamespace
    WHERE n.nspname='heroes_watch' AND c.conname = ANY (ARRAY[${guardNames.map(name => `'${name}'`).join(',')}])),
  'triggers', (SELECT count(*) FROM pg_trigger t JOIN pg_class r ON r.oid=t.tgrelid
    JOIN pg_namespace n ON n.oid=r.relnamespace WHERE n.nspname='heroes_watch' AND NOT t.tgisinternal
    AND (t.tgname LIKE 'ct_production_%' OR t.tgname LIKE 'tr_production_%'
      OR t.tgname LIKE 'ct_graph_cycle__%' OR t.tgname LIKE 'tr_graph_write__%'))
)`;

const sqlLiteral = value => `'${value.replaceAll("'", "''")}'`;
const sourceColumnPairs = entries => entries.map(([table, field]) =>
  `(${sqlLiteral(table)}, ${sqlLiteral(field)})`).join(',');
const sourceRequiredPairs = Object.entries(sourceNullableColumns)
  .flatMap(([table, fields]) => fields.map(field => [table, field]));
const sourceAddedPairs = Object.entries(sourceAddedColumns)
  .flatMap(([table, fields]) => fields.map(([field]) => [table, field]));
const sourceStateSql = `SELECT jsonb_build_object(
  'addedColumns', (SELECT count(*) FROM information_schema.columns
    WHERE table_schema='heroes_watch' AND (table_name,column_name) IN
      (VALUES ${sourceColumnPairs(sourceAddedPairs)})),
  'newEnumValues', (SELECT count(*) FROM pg_enum e JOIN pg_type t ON t.oid=e.enumtypid
    JOIN pg_namespace n ON n.oid=t.typnamespace WHERE n.nspname='heroes_watch'
    AND ((t.typname='Enum__CreatureHOMM7__WarfareRole' AND e.enumlabel='AttackAndSupport')
      OR (t.typname='Enum__CreatureHOMM7__Movement' AND e.enumlabel='Stationary'))),
  'newChecks', (SELECT count(*) FROM pg_constraint c JOIN pg_namespace n ON n.oid=c.connamespace
    WHERE n.nspname='heroes_watch' AND c.conname = ANY
      (ARRAY[${sourceDetailChecks.map(rule => sqlLiteral(rule.name)).join(',')}])),
  'originalRequiredColumns', (SELECT count(*) FROM information_schema.columns
    WHERE table_schema='heroes_watch' AND is_nullable='NO' AND (table_name,column_name) IN
      (VALUES ${sourceColumnPairs(sourceRequiredPairs)}))
)`;
const expectedPreSourceState = {
  addedColumns: 0, newEnumValues: 0, newChecks: 0,
  originalRequiredColumns: sourceRequiredPairs.length,
};

async function create(database, template) {
  const args = [...utilityArgs, `--template=${template}`, database];
  await requireShortSuccess(createdb, args, { env: pgEnv, timeout: 60_000 });
  created.push(database);
}
async function requireMigrationRejected(database, label) {
  const result = await runProcess(psql, psqlArgs(connection, database, [
    '--set', 'VERBOSITY=verbose', '--file', path.join(repositoryRoot, 'src/db/postgres/migrations/0006_catalog_guards.sql'),
  ]), { env: pgEnv, timeout: 300_000, quiet: true });
  assert.notEqual(result.code, 0, `${label}: migration unexpectedly committed`);
  assert.equal(sqlstate(result), '23514', `${label}: expected SQLSTATE 23514, got ${sqlstate(result) ?? 'none'}\n${short(result.stderr)}`);
  const state = await queryJson(psql, connection, database, guardStateSql, { env: pgEnv });
  assert.deepEqual(state, { constraints: 0, triggers: 0 }, `${label}: v6 objects survived a failed transaction`);
}

async function requireSourceMigrationRejected(database) {
  const before = await queryJson(psql, connection, database, sourceStateSql, { env: pgEnv });
  assert.deepEqual(before, expectedPreSourceState, 'v6 profile fixture unexpectedly contains v7 schema changes');
  const guardsBefore = await queryJson(psql, connection, database, guardStateSql, { env: pgEnv });
  const result = await runProcess(psql, psqlArgs(connection, database, [
    '--set', 'VERBOSITY=verbose', '--file', path.join(repositoryRoot, 'src/db/postgres/migrations/0007_source_detail_profiles.sql'),
  ]), { env: pgEnv, timeout: 300_000, quiet: true });
  assert.notEqual(result.code, 0, 'missing warfare role: v7 unexpectedly committed');
  assert.equal(sqlstate(result), '23514', `missing warfare role: expected SQLSTATE 23514, got ${sqlstate(result) ?? 'none'}\n${short(result.stderr)}`);
  assert.match(result.stderr, /ck_h7_warfare_profile_scope/, 'v7 failed for an unrelated reason');
  const after = await queryJson(psql, connection, database, sourceStateSql, { env: pgEnv });
  assert.deepEqual(after, before, 'failed v7 migration retained a new column, enum, check, or nullability change');
  const guardsAfter = await queryJson(psql, connection, database, guardStateSql, { env: pgEnv });
  assert.deepEqual(guardsAfter, guardsBefore, 'failed v7 migration changed existing v6 guards');
}

const schema = JSON.parse(fs.readFileSync(path.join(dbRoot, 'schema/heroeswatch.schema.json'), 'utf8'));
const bundle = JSON.parse(fs.readFileSync(path.join(dbRoot, 'data/heroeswatch.json'), 'utf8'));
const sourceRows = Object.values(bundle.tables).reduce((sum, rows) => sum + rows.length, 0);
const researchAudit=JSON.parse(fs.readFileSync(path.join(dbRoot,'data/research-2026-10-14-evidence.json'),'utf8'));
const enrichmentAudit=JSON.parse(fs.readFileSync(path.join(dbRoot,'research/2026-10-14/h67-resolution-enrichment.json'),'utf8'));
const baseline=rewindResearch(bundle,researchAudit);
const baselineRows=Object.values(baseline.tables).reduce((sum,rows)=>sum+rows.length,0);
assert.equal(baselineRows,43_932,'reviewed full research rewind must contain exactly 43,932 rows');
assert.equal(researchAudit.summary.resultingRows, sourceRows, 'research audit row total differs from the catalog');
assert.equal(researchAudit.patches.at(-1)?.file, 'zz-h67-resolution.patch.json', 'last reviewed patch is no longer the handoff delta');
assert.equal(enrichmentAudit.changes.length, 3, 'expected three handoff profile enrichments');

const handoffBaseline=structuredClone(bundle);
const resolutionPatch=researchAudit.patches.at(-1);
for(const fill of [...resolutionPatch.fills].reverse()) {
  const row=handoffBaseline.tables[fill.table]?.find(candidate=>candidate._key===fill.key);
  assert(row, `missing handoff fill row ${fill.table}/${fill.key}`);
  assert.deepEqual(row[fill.field],fill.value,`handoff fill differs at ${fill.table}/${fill.key}.${fill.field}`);
  row[fill.field]=fill.expected;
}
for(const addition of [...resolutionPatch.additions].reverse()) {
  const rows=handoffBaseline.tables[addition.table];
  const index=rows?.findIndex(candidate=>candidate._key===addition.key)??-1;
  assert(index>=0,`missing handoff addition ${addition.table}/${addition.key}`);
  assert.deepEqual(rows[index],addition.row,`handoff addition differs at ${addition.table}/${addition.key}`);
  rows.splice(index,1);
}
for(const change of enrichmentAudit.changes) {
  const row=handoffBaseline.tables[change.table]?.find(candidate=>candidate._key===change.key);
  assert(row,`missing handoff enrichment row ${change.table}/${change.key}`);
  assert.deepEqual(row[change.field],change.value,`catalog enrichment differs at ${change.table}/${change.key}.${change.field}`);
  row[change.field]=structuredClone(change.expected);
}
const handoffRows=Object.values(handoffBaseline.tables).reduce((sum,rows)=>sum+rows.length,0);
assert.equal(handoffRows,45_560,'reviewed handoff reconstruction must contain exactly 45,560 rows');
assert.equal(enrichmentAudit.baselineCommit,'9450e7919cf4ff7164ec2efb4804006807ff71df','enrichment audit baseline commit changed');
const handoffSha256=createHash('sha256').update(JSON.stringify(handoffBaseline)).digest('hex');
assert.equal(handoffSha256,'5ff345039a40a63ae3f29d5a04d244e0eb113930bbf8481adc37bac0b86387f8',
  'reconstructed handoff differs from the exact reviewed v7 catalog');

const recalculateCounts=contract => {
  contract.counts={tables:contract.tables.length,columns:contract.tables.reduce((sum,table)=>sum+table.columns.length,0),
    foreignKeys:contract.tables.reduce((sum,table)=>sum+table.foreignKeys.length,0),enums:contract.enums.length};
  return contract;
};
const v7Schema=structuredClone(schema);
assert.deepEqual(v7Schema.source.overlay,{version:8,module:'src/db/tools/schema-overlay.mjs',migration:'0008_fractional_magic_defense.sql'});
const v7MagicTable=v7Schema.tables.find(table=>table.name==='CreatureHOMM6');
const v7Magic=v7MagicTable.columns.find(column=>column.name==='MagicDefense');
assert.equal(v7Magic.postgresType,'NUMERIC','current schema no longer describes the v8 magic-defense type');
v7Magic.postgresType='SMALLINT';v7Magic.sqlDesignerType='SMALLINT';v7Magic.comment=null;
v7MagicTable.checks=v7MagicTable.checks.filter(check=>check.name!=='ck_h6_magic_defense_finite');
v7Schema.source.overlay={version:7,module:'src/db/tools/schema-overlay.mjs',migration:'0007_source_detail_profiles.sql'};
recalculateCounts(v7Schema);

const baselineSchema=structuredClone(v7Schema);
for(const table of baselineSchema.tables) {
  for(const field of sourceNullableColumns[table.name]??[]) table.columns.find(column=>column.name===field).nullable=false;
  table.columns=table.columns.filter(column=>!(sourceAddedColumns[table.name]??[]).some(([name])=>name===column.name));
  if(table.checks) table.checks=table.checks.filter(check=>!sourceDetailChecks.some(rule=>rule.table===table.name&&rule.name===check.name));
}
const previousRole=baselineSchema.tables.find(table=>table.name==='CreatureHOMM7').columns.find(column=>column.name==='WarfareRole');
previousRole.enumValues=previousRole.enumValues.filter(value=>value!=='AttackAndSupport');
previousRole.sqlDesignerType=`ENUM(${previousRole.enumValues.map(value=>`'${value}'`).join(',')})`;
baselineSchema.enums.find(item=>item.name===previousRole.postgresType).values=[...previousRole.enumValues];
const previousMovement=baselineSchema.tables.find(table=>table.name==='CreatureHOMM7').columns.find(column=>column.name==='Movement');
previousMovement.enumValues=previousMovement.enumValues.filter(value=>value!=='Stationary');
previousMovement.sqlDesignerType=`ENUM(${previousMovement.enumValues.map(value=>`'${value}'`).join(',')})`;
baselineSchema.enums.find(item=>item.name===previousMovement.postgresType).values=[...previousMovement.enumValues];
baselineSchema.source.overlay={version:6,module:'src/db/tools/schema-overlay.mjs',migration:'0006_catalog_guards.sql'};
delete baselineSchema.integrity.sourceDetails;
recalculateCounts(baselineSchema);
const baselineMagic=baselineSchema.tables.find(table=>table.name==='CreatureHOMM6').columns.find(column=>column.name==='MagicDefense');
assert.equal(baselineMagic.postgresType,'SMALLINT','v6 fixture must predate fractional magic defense');
assert(!baselineSchema.tables.find(table=>table.name==='CreatureHOMM6').checks.some(check=>check.name==='ck_h6_magic_defense_finite'),
  'v6 fixture retained the v8 magic-defense check');
const temporary=fs.mkdtempSync(path.join(os.tmpdir(),'heroeswatch-upgrade-baseline-'));
fs.writeFileSync(path.join(temporary,'catalog.json'),JSON.stringify(baseline));
fs.writeFileSync(path.join(temporary,'schema.json'),JSON.stringify(baselineSchema));
fs.writeFileSync(path.join(temporary,'handoff-catalog.json'),JSON.stringify(handoffBaseline));
fs.writeFileSync(path.join(temporary,'handoff-schema.json'),JSON.stringify(v7Schema));
if (process.env.HW_EXPECTED_ROWS !== undefined) {
  assert.equal(sourceRows, Number(process.env.HW_EXPECTED_ROWS), 'catalog row total differs from HW_EXPECTED_ROWS');
}
const enrichmentEntries=enrichmentAudit.changes.map(change=>{
  const creature=bundle.tables.Creature.find(row=>row._key===change.key);
  assert(creature?.Code,`missing creature code for ${change.key}`);
  return {...change,code:creature.Code};
});
const profileStateSql=`SELECT jsonb_object_agg(c."Code",d."WarfareStats")
  FROM heroes_watch."CreatureHOMM7" d
  JOIN heroes_watch."Creature" c ON c."Creature_id"=d."Creature_id"
  JOIN heroes_watch."Game" g ON g."Game_id"=c."Game_id"
  WHERE g."SeriesCode"='HOMM7' AND c."Code" IN (${enrichmentEntries.map(change=>sqlLiteral(change.code)).join(',')})`;
const identifier=value=>`"${value.replaceAll('"','""')}"`;
const physicalIdentitySql=contract=>`SELECT jsonb_object_agg(name, identities) FROM (${contract.tables.map(table=>{
  const identity=`jsonb_build_array(${table.primaryKey.map(column=>`${identifier(column)}::text`).join(',')})`;
  return `SELECT ${sqlLiteral(table.name)} AS name, COALESCE(jsonb_agg(${identity} ORDER BY ${identity}::text),'[]'::jsonb) AS identities FROM heroes_watch.${identifier(table.name)}`;
}).join(' UNION ALL ')}) AS physical_identities`;

try {
  await requireShortSuccess(process.execPath,[path.join(dbRoot,'tools/build-content-sql.mjs'),'--input',path.join(temporary,'catalog.json'),'--schema',path.join(temporary,'schema.json'),'--output',path.join(temporary,'catalog.sql')],{timeout:300000});
  await requireShortSuccess(process.execPath,[path.join(dbRoot,'tools/build-content-sql.mjs'),'--input',path.join(temporary,'handoff-catalog.json'),'--schema',path.join(temporary,'handoff-schema.json'),'--output',path.join(temporary,'handoff-catalog.sql')],{timeout:300000});
  console.log(`Creating disposable v5 database ${databases.main} ...`);
  await create(databases.main, 'template0');
  for (const migration of ['0001_initial.sql', '0002_relationship_integrity.sql',
    '0003_nullable_identity_and_campaign_scope.sql', '0004_creature_tier_terminology.sql',
    '0005_creature_numeric_speed.sql']) {
    await psqlFile(databases.main, `src/db/postgres/migrations/${migration}`);
  }
  await requireShortSuccess(psql,psqlArgs(connection,databases.main,['--file',path.join(temporary,'catalog.sql')]),{env:pgEnv,timeout:900000});
  const preGuardState = await queryJson(psql, connection, databases.main, guardStateSql, { env: pgEnv });
  assert.deepEqual(preGuardState, { constraints: 0, triggers: 0 }, 'v5 unexpectedly contains v6 guards');
  const before = await queryJson(psql, connection, databases.main, fingerprintSql(baselineSchema), { env: pgEnv, timeout: 300_000 });

  console.log('Cloning the populated v5 baseline for atomic rollback probes ...');
  await create(databases.badAmount, databases.main);
  await create(databases.badCycle, databases.main);

  console.log('Applying v6 to the valid populated baseline ...');
  await psqlFile(databases.main, 'src/db/postgres/migrations/0006_catalog_guards.sql');
  console.log('Cloning the populated v6 baseline for the v7 atomic rollback probe ...');
  await create(databases.badProfile, databases.main);
  await psqlFile(databases.main, 'src/db/postgres/migrations/0007_source_detail_profiles.sql');
  await psqlFile(databases.main, 'src/db/postgres/migrations/0008_fractional_magic_defense.sql');
  await psqlFile(databases.main, 'src/db/postgres/verify.sql');
  const after = await queryJson(psql, connection, databases.main, fingerprintSql(baselineSchema), { env: pgEnv, timeout: 300_000 });
  assert.deepEqual(after, before, 'v6/v7 migrations changed catalog rows or physical IDs');
  await psqlFile(databases.main, 'src/db/data/research-gaps-import.sql',900_000);
  await psqlFile(databases.main, 'src/db/postgres/tests/source-details.sql');
  const actual = await queryJson(psql, connection, databases.main, inventorySql(schema), { env: pgEnv, timeout: 300_000 });
  const reconciliation = reconcileInventory(schema, bundle, actual);
  const installed = await queryJson(psql, connection, databases.main, guardStateSql, { env: pgEnv });
  assert.equal(installed.constraints, guardNames.length, 'valid upgrade did not install every static v6 constraint');
  assert(installed.triggers > 0, 'valid upgrade installed no v6 triggers');

  console.log(`Creating the exact ${handoffRows.toLocaleString('en-US')}-row populated v7 handoff ...`);
  await create(databases.handoff,'template0');
  for(const migration of ['0001_initial.sql','0002_relationship_integrity.sql',
    '0003_nullable_identity_and_campaign_scope.sql','0004_creature_tier_terminology.sql',
    '0005_creature_numeric_speed.sql','0006_catalog_guards.sql','0007_source_detail_profiles.sql']) {
    await psqlFile(databases.handoff,`src/db/postgres/migrations/${migration}`);
  }
  await requireShortSuccess(psql,psqlArgs(connection,databases.handoff,['--file',path.join(temporary,'handoff-catalog.sql')]),
    {env:pgEnv,timeout:900_000});
  const handoffBeforeV8=await queryJson(psql,connection,databases.handoff,fingerprintSql(v7Schema),{env:pgEnv,timeout:300_000});
  const handoffIdentities=await queryJson(psql,connection,databases.handoff,physicalIdentitySql(v7Schema),{env:pgEnv,timeout:300_000});
  assert.equal(Object.values(handoffIdentities).reduce((sum,identities)=>sum+identities.length,0),handoffRows,
    'physical-ID snapshot does not cover every handoff row');
  const handoffProfiles=await queryJson(psql,connection,databases.handoff,profileStateSql,{env:pgEnv});
  for(const change of enrichmentEntries) assert.deepEqual(handoffProfiles[change.code],change.expected,
    `${change.code}: reconstructed handoff profile differs from the audited pre-enrichment value`);

  await psqlFile(databases.handoff,'src/db/postgres/migrations/0008_fractional_magic_defense.sql');
  const handoffAfterV8=await queryJson(psql,connection,databases.handoff,fingerprintSql(v7Schema),{env:pgEnv,timeout:300_000});
  assert.deepEqual(handoffAfterV8,handoffBeforeV8,'v8 changed handoff rows or physical IDs');
  await create(databases.badEnrichment,databases.handoff);

  console.log('Applying the guarded profile enrichment twice, then the current research import twice ...');
  await psqlFile(databases.handoff,'src/db/data/h67-profile-enrichment.sql');
  await psqlFile(databases.handoff,'src/db/data/h67-profile-enrichment.sql');
  const enrichedProfiles=await queryJson(psql,connection,databases.handoff,profileStateSql,{env:pgEnv});
  for(const change of enrichmentEntries) assert.deepEqual(enrichedProfiles[change.code],change.value,
    `${change.code}: guarded enrichment did not install the reviewed profile`);
  await psqlFile(databases.handoff,'src/db/data/research-gaps-import.sql',900_000);
  const handoffAfterImport=await queryJson(psql,connection,databases.handoff,fingerprintSql(schema),{env:pgEnv,timeout:300_000});
  const identitiesAfterImport=await queryJson(psql,connection,databases.handoff,physicalIdentitySql(schema),{env:pgEnv,timeout:300_000});
  for(const table of v7Schema.tables) {
    const retained=new Set(identitiesAfterImport[table.name].map(identity=>JSON.stringify(identity)));
    assert(handoffIdentities[table.name].every(identity=>retained.has(JSON.stringify(identity))),
      `${table.name}: first enrichment and research delta replaced or removed a handoff physical ID`);
  }
  await psqlFile(databases.handoff,'src/db/data/research-gaps-import.sql',900_000);
  const handoffAfterRepeat=await queryJson(psql,connection,databases.handoff,fingerprintSql(schema),{env:pgEnv,timeout:300_000});
  assert.deepEqual(handoffAfterRepeat,handoffAfterImport,'repeated handoff research import changed rows or physical IDs');
  const handoffActual=await queryJson(psql,connection,databases.handoff,inventorySql(schema),{env:pgEnv,timeout:300_000});
  const handoffReconciliation=reconcileInventory(schema,bundle,handoffActual);

  console.log('Proving unexpected local profile JSON rejects and rolls back the whole enrichment ...');
  const firstChange=enrichmentEntries[0], conflictingChange=enrichmentEntries[1];
  const unexpectedProfile=structuredClone(conflictingChange.expected);
  unexpectedProfile.profiles[0].health+=1;
  const localChange=await queryJson(psql,connection,databases.badEnrichment,`WITH changed AS (
    UPDATE heroes_watch."CreatureHOMM7" d SET "WarfareStats"=${sqlLiteral(JSON.stringify(unexpectedProfile))}::jsonb
    FROM heroes_watch."Creature" c, heroes_watch."Game" g
    WHERE c."Creature_id"=d."Creature_id" AND g."Game_id"=c."Game_id"
      AND g."SeriesCode"='HOMM7' AND c."Code"=${sqlLiteral(conflictingChange.code)}
    RETURNING d."Creature_id"
  ) SELECT to_jsonb(count(*)) FROM changed`,{env:pgEnv});
  assert.equal(localChange,1,'unexpected local JSON fixture did not change exactly one profile');
  const rejectedEnrichment=await runProcess(psql,psqlArgs(connection,databases.badEnrichment,[
    '--set','VERBOSITY=verbose','--file',path.join(repositoryRoot,'src/db/data/h67-profile-enrichment.sql'),
  ]),{env:pgEnv,timeout:300_000,quiet:true});
  assert.notEqual(rejectedEnrichment.code,0,'unexpected local JSON: enrichment unexpectedly committed');
  assert.equal(sqlstate(rejectedEnrichment),'P0001',`unexpected local JSON: expected SQLSTATE P0001, got ${sqlstate(rejectedEnrichment)??'none'}\n${short(rejectedEnrichment.stderr)}`);
  assert.match(rejectedEnrichment.stderr,new RegExp(`Unexpected existing profile: ${conflictingChange.code}`));
  const profilesAfterRejection=await queryJson(psql,connection,databases.badEnrichment,profileStateSql,{env:pgEnv});
  assert.deepEqual(profilesAfterRejection[firstChange.code],firstChange.expected,
    'earlier enrichment target survived a later profile conflict instead of rolling back');
  assert.deepEqual(profilesAfterRejection[conflictingChange.code],unexpectedProfile,
    'failed enrichment rewrote the conflicting local profile');

  console.log('Proving a negative-cost baseline rejects and rolls back v6 atomically ...');
  await successfulSql(databases.badAmount, `UPDATE heroes_watch."CreatureResourceCost" SET "Amount"=-1
    WHERE "CreatureResourceCost_cid"=(SELECT "CreatureResourceCost_cid" FROM heroes_watch."CreatureResourceCost" ORDER BY 1 LIMIT 1)`);
  await requireMigrationRejected(databases.badAmount, 'negative amount');
  const negative = await queryJson(psql, connection, databases.badAmount,
    `SELECT to_jsonb(count(*)) FROM heroes_watch."CreatureResourceCost" WHERE "Amount" < 0`, { env: pgEnv });
  assert.equal(negative, 1, 'failed migration unexpectedly rewrote invalid baseline data');

  console.log('Proving a cyclic graph baseline rejects and rolls back v6 atomically ...');
  await successfulSql(databases.badCycle, `INSERT INTO heroes_watch."CreatureUpgrade"
    ("CreatureUpgrade_cid","Game_id","BaseCreature_id","UpgradedCreature_id")
    SELECT 'hw_upgrade_cycle_fixture', edge."Game_id", edge."UpgradedCreature_id", edge."BaseCreature_id"
    FROM heroes_watch."CreatureUpgrade" edge
    WHERE NOT EXISTS (SELECT 1 FROM heroes_watch."CreatureUpgrade" reverse
      WHERE reverse."Game_id"=edge."Game_id"
        AND reverse."BaseCreature_id"=edge."UpgradedCreature_id"
        AND reverse."UpgradedCreature_id"=edge."BaseCreature_id")
    ORDER BY edge."CreatureUpgrade_cid" LIMIT 1`);
  await requireMigrationRejected(databases.badCycle, 'creature-upgrade cycle');
  const cycleFixture = await queryJson(psql, connection, databases.badCycle,
    `SELECT to_jsonb(count(*)) FROM heroes_watch."CreatureUpgrade" WHERE "CreatureUpgrade_cid"='hw_upgrade_cycle_fixture'`, { env: pgEnv });
  assert.equal(cycleFixture, 1, 'failed migration unexpectedly rewrote cyclic baseline data');

  console.log('Proving a missing warfare-role baseline rejects and rolls back v7 atomically ...');
  const profileFixture = await queryJson(psql, connection, databases.badProfile, `WITH fixture AS (
    UPDATE heroes_watch."CreatureHOMM7" SET "CreatureKind"='Warfare', "WarfareRole"=NULL
    WHERE "Creature_id"=(SELECT min("Creature_id") FROM heroes_watch."CreatureHOMM7" WHERE "CreatureKind"='Town')
    RETURNING *
  ) SELECT to_jsonb(fixture) FROM fixture`, { env: pgEnv });
  assert(profileFixture && Number.isSafeInteger(profileFixture.Creature_id), 'missing warfare-role fixture was not created');
  assert.equal(profileFixture.CreatureKind, 'Warfare');
  assert.equal(profileFixture.WarfareRole, null);
  await requireSourceMigrationRejected(databases.badProfile);
  const retainedProfile = await queryJson(psql, connection, databases.badProfile,
    `SELECT to_jsonb(creature) FROM heroes_watch."CreatureHOMM7" creature WHERE "Creature_id"=${profileFixture.Creature_id}`, { env: pgEnv });
  assert.deepEqual(retainedProfile, profileFixture, 'failed v7 migration rewrote the invalid baseline creature');

  const version = await queryJson(psql, connection, databases.main,
    `SELECT to_jsonb(current_setting('server_version'))`, { env: pgEnv });
  console.log(JSON.stringify({
    result: 'PASS', databaseVersion: version, sourceRows, handoffRows,
    upgrades: [
      '0001..0005 + exact 43,932-row research baseline -> 0006 -> 0007 -> 0008 + research gap delta',
      'exact 45,560-row populated v7 handoff -> 0008 -> guarded profile enrichment twice -> research gap delta twice',
    ],
    preservedFingerprint: true, reconciliation, handoffReconciliation,
    invalidBaselines: ['negative amount: v6 23514 + atomic rollback', 'creature cycle: v6 23514 + atomic rollback',
      'missing warfare role: v7 23514 + columns, enum, checks, nullability and baseline row preserved',
      'unexpected local warfare JSON: P0001 + earlier target and conflicting target preserved'],
  }, null, 2));
} finally {
  fs.rmSync(temporary,{recursive:true,force:true});
  for (const database of created.reverse()) {
    const dropped = await runProcess(dropdb, [...utilityArgs, '--if-exists', '--force', database], {
      env: pgEnv, timeout: 60_000, quiet: true,
    });
    if (dropped.code !== 0) {
      process.stderr.write(`WARNING: failed to drop exact disposable database ${database}:\n${short(dropped.stderr)}`);
      process.exitCode = 1;
    }
  }
}
