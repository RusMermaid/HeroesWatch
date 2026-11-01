// Guarded enrichment of three existing JSON profiles. Never connects to a database.
import fs from 'node:fs';
import {isDeepStrictEqual} from 'node:util';
import {validateJsonColumn} from './json-contracts.mjs';
const root=new URL('../',import.meta.url),read=name=>JSON.parse(fs.readFileSync(new URL(name,root)));
const audit=read('research/2026-10-14/h67-resolution-enrichment.json'),catalog=read('data/heroeswatch.json');
const quote=value=>"E'"+String(value).replaceAll('\\','\\\\').replaceAll("'","''")+"'";
const sql=['-- Guarded source-supported additions to existing Heroes VII warfare profiles.',
 '-- Apply after migration 0008 and before research-gaps-import.sql when upgrading the 45,560-row catalog.',
 '-- Unknown local changes abort. Repeated execution preserves the recorded result.',
 'BEGIN;', 'SET LOCAL standard_conforming_strings = on;', "SET LOCAL lock_timeout = '15s';",
 'LOCK TABLE heroes_watch."Creature", heroes_watch."CreatureHOMM7", heroes_watch."Game" IN SHARE ROW EXCLUSIVE MODE;',
 'DO $enrichment$\nDECLARE target_id bigint; matches bigint; changed integer; previous jsonb;\nBEGIN'];
if(audit.changes.length!==3)throw Error('Expected exactly three reviewed profile enrichments');
for(const change of audit.changes){
 if(change.table!=='CreatureHOMM7'||change.field!=='WarfareStats')throw Error('Unreviewed enrichment target');
 const previous=structuredClone(change.value);
 for(const leaf of change.addedLeaves){
  if(!['defense','effectAmount'].includes(leaf.field)||!Number.isInteger(leaf.profile)||leaf.profile<1||leaf.profile>5)throw Error('Unreviewed profile path');
  const before=change.expected.profiles[leaf.profile-1],after=previous.profiles[leaf.profile-1];
  if(Object.hasOwn(before,leaf.field)||after[leaf.field]!==leaf.value)throw Error('Enrichment must add an absent leaf');
  delete after[leaf.field];
 }
 if(!isDeepStrictEqual(previous,change.expected))throw Error('Enrichment would replace an existing fact');
 const error=validateJsonColumn('CreatureHOMM7','WarfareStats',change.value);if(error)throw Error(error);
 const row=catalog.tables.CreatureHOMM7.find(row=>row._key===change.key),creature=catalog.tables.Creature.find(row=>row._key===change.key);
 if(!row||!isDeepStrictEqual(row.WarfareStats,change.value)||creature?.Game_id!=='homm7.game')throw Error('Catalog differs from the reviewed enrichment');
 const where=`c."Creature_id"=d."Creature_id" AND g."Game_id"=c."Game_id" AND g."SeriesCode"='HOMM7' AND c."Code"=${quote(creature.Code)}`;
 sql.push(`  SELECT count(*), min(d."Creature_id") INTO matches, target_id
    FROM heroes_watch."CreatureHOMM7" d, heroes_watch."Creature" c, heroes_watch."Game" g WHERE ${where};
  IF matches <> 1 THEN RAISE EXCEPTION 'Expected exactly one creature profile: ${creature.Code}; found %', matches; END IF;
  SELECT d."WarfareStats" INTO STRICT previous FROM heroes_watch."CreatureHOMM7" d WHERE d."Creature_id"=target_id;
  IF previous IS DISTINCT FROM ${quote(JSON.stringify(change.expected))}::jsonb AND previous IS DISTINCT FROM ${quote(JSON.stringify(change.value))}::jsonb THEN
    RAISE EXCEPTION 'Unexpected existing profile: ${creature.Code}';
  END IF;
  IF previous IS DISTINCT FROM ${quote(JSON.stringify(change.value))}::jsonb THEN
    UPDATE heroes_watch."CreatureHOMM7" d SET "WarfareStats"=${quote(JSON.stringify(change.value))}::jsonb
      WHERE d."Creature_id"=target_id AND d."WarfareStats" IS NOT DISTINCT FROM previous;
    GET DIAGNOSTICS changed = ROW_COUNT;
    IF changed <> 1 THEN RAISE EXCEPTION 'Creature profile update count changed: ${creature.Code}; updated %', changed; END IF;
  END IF;`);
}
sql.push('END\n$enrichment$;','COMMIT;','');
const output=new URL('data/h67-profile-enrichment.sql',root),text=sql.join('\n');
if(process.argv.includes('--check')){if(fs.readFileSync(output,'utf8').replaceAll('\r\n','\n')!==text)throw Error('Regenerate h67-profile-enrichment.sql');}
else fs.writeFileSync(output,text);
console.log(`${process.argv.includes('--check')?'Verified':'Built'} three guarded JSON enrichments (nine added numerical facts).`);
