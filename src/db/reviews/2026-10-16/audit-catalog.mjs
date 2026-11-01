// Read-only comparison with the last reviewed catalog. Run from any directory.
import fs from 'node:fs';
import {execFileSync} from 'node:child_process';
import {isDeepStrictEqual} from 'node:util';
import {createHash} from 'node:crypto';
import path from 'node:path';
import {fileURLToPath} from 'node:url';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../../../..');
const baselineRef = '7ad2a6b7ed45bb63411986a3ec6863fcfc8f1a6b';
const file = 'src/db/data/heroeswatch.json';
const before = JSON.parse(execFileSync('git', ['show', `${baselineRef}:${file}`], {cwd:root, maxBuffer:64*1024*1024}));
const bytes = fs.readFileSync(path.join(root, file));
const after = JSON.parse(bytes);
const schema = JSON.parse(fs.readFileSync(path.join(root, 'src/db/schema/heroeswatch.schema.json')));
const definitions = new Map(schema.tables.map(table => [table.name,table]));
const total = bundle => Object.values(bundle.tables).reduce((n,rows) => n + rows.length, 0);
const delta = {added:0, removed:0, nullFills:0, existingValueChanges:[], byTable:[]};
for (const [table,rows] of Object.entries(before.tables)) {
  const current = new Map(after.tables[table].map(row => [row._key,row]));
  const keys = new Set(rows.map(row => row._key));
  const counts = {table, added:after.tables[table].filter(row => !keys.has(row._key)).length, nullFills:0, existingValueChanges:0};
  delta.added += counts.added;
  for (const row of rows) {
    const next = current.get(row._key);
    if (!next) { delta.removed++; continue; }
    for (const column of new Set([...Object.keys(row),...Object.keys(next)])) {
      if (isDeepStrictEqual(row[column],next[column]) || row[column] === undefined && next[column] === null) continue;
      if (row[column] === null) { delta.nullFills++; counts.nullFills++; }
      else {
        counts.existingValueChanges++;
        delta.existingValueChanges.push({table,key:row._key,column,before:row[column],after:next[column]});
      }
    }
  }
  if (counts.added || counts.nullFills || counts.existingValueChanges) delta.byTable.push(counts);
}
const games = {};
for (const game of after.tables.Game.filter(row => /^HOMM[1-8]$/.test(row.SeriesCode)).sort((a,b) => a.SeriesCode.localeCompare(b.SeriesCode))) {
  const result = {};
  for (const parent of ['Faction','Creature','HeroClass','Hero','Ability','Skill','MagicSchool','Spell','Artifact','Building','Terrain','AdventureObject','Map','Scenario','Campaign']) {
    const detail = `${parent}${game.SeriesCode}`;
    if (!definitions.has(detail)) continue; // An omitted subtype is not a missing row.
    const rows = after.tables[parent].filter(row => row.Game_id === game._key);
    const pk = definitions.get(detail).primaryKey[0];
    const covered = new Set(after.tables[detail].map(row => row[pk] ?? row._key));
    const missing = rows.filter(row => !covered.has(row._key));
    result[parent] = {identities:rows.length, detailRows:rows.length-missing.length,
      missingCount:missing.length,
      missingExamples:missing.slice(0,5).map(row => ({key:row._key,name:row.Name ?? row.Title}))};
  }
  result.junctions = Object.fromEntries(schema.tables.filter(table => table.kind === 'junction').map(table =>
    [table.name,after.tables[table.name].filter(row => row.Game_id === game._key).length]));
  games[game.SeriesCode] = result;
}
const partialDetails = {};
for (const table of ['CreatureHOMM6','CreatureHOMM7','HeroHOMM5','HeroHOMM7','ResourceHOMM8','MapHOMM8','ScenarioHOMM8','CampaignHOMM8','AstrologyHOMM8']) {
  const definition = definitions.get(table), rows = after.tables[table];
  partialDetails[table] = {rows:rows.length, unknownByField:Object.fromEntries(definition.columns
    .filter(column => !column.primaryKey && !column.generatedExpression)
    .map(column => [column.name, rows.filter(row => row[column.name] == null).length])
    .filter(([,count]) => count > 0))};
}
const warfare = after.tables.CreatureHOMM7.filter(row => row.CreatureKind === 'Warfare').map(row => ({
  key:row._key, role:row.WarfareRole, combatSize:row.CombatSize,
  scalarUnknowns:['Attack','Defense','DamageMin','DamageMax','Health','Speed','Movement'].filter(name => row[name] == null),
  profileOrder:row.WarfareStats?.profileOrder,
  profileCount:row.WarfareStats?.profiles?.length ?? 0,
}));
console.log(JSON.stringify({baselineRef,reviewedRef:execFileSync('git',['rev-parse','HEAD'],{cwd:root,encoding:'utf8'}).trim(),
  catalogFileSha256:createHash('sha256').update(bytes).digest('hex'), baselineRows:total(before), currentRows:total(after),
  schema:{tables:schema.tables.length,columns:schema.tables.reduce((n,t)=>n+t.columns.length,0),foreignKeys:schema.tables.reduce((n,t)=>n+t.foreignKeys.length,0)},
  delta,games,partialDetails,warfare,
  emptyTables:schema.tables.filter(table=>after.tables[table.name].length===0).map(table=>table.name),
  caveats:['Missing detail counts are relative to existing catalog identities, not proof of a complete game roster.',
    'Nulls include legitimate inapplicable fields; source notes determine whether each is missing or intentional.',
    'Published source choices and native-source hashes are not an independent reread of game files unavailable on this computer.']},null,2));
