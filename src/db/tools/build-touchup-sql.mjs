#!/usr/bin/env node
// Small, repeatable GUI imports for the reviewed October relationship update.
import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
import {spawnSync} from 'node:child_process';
import {selectContentClosure} from './content-closure.mjs';
const dbRoot=path.resolve(path.dirname(fileURLToPath(import.meta.url)),'..');
const args=process.argv.slice(2);
if(args.some(a=>a!=='--check'))throw Error('Usage: node src/db/tools/build-touchup-sql.mjs [--check]');
const read=p=>JSON.parse(fs.readFileSync(path.join(dbRoot,p),'utf8'));
const catalog=read('data/heroeswatch.json'),schema=read('schema/heroeswatch.schema.json'),audit=read('data/touchups-evidence.json');
const temp=path.resolve(dbRoot,'../../.codex-tmp/touchups/imports');fs.mkdirSync(temp,{recursive:true});
const quote=s=>"E'"+s.replaceAll('\\','\\\\').replaceAll("'","''")+"'";
const correctionLines=['-- Reviewed label corrections. Run after migration 0002 and before touchup parts.',
 '-- Changes are guarded by their recorded old values; unknown edits abort.',
 'BEGIN;', 'SET LOCAL standard_conforming_strings = on;', "SET LOCAL lock_timeout = '15s';",
 'LOCK TABLE heroes_watch."AdventureObject" IN SHARE ROW EXCLUSIVE MODE;',
 'DO $corrections$\nDECLARE existing_name text;\nBEGIN'];
for(const c of audit.correctedFields){
 if(c.table!=='AdventureObject'||c.field!=='Name'||typeof c.expected!=='string'||typeof c.value!=='string')throw Error('Unreviewed correction policy '+c.key);
 const row=catalog.tables.AdventureObject.find(r=>r._key===c.key);
 const game=catalog.tables.Game.find(r=>r._key===row.Game_id);
 const where=`o."Game_id" = g."Game_id" AND g."SeriesCode" = ${quote(game.SeriesCode)} AND o."Code" = ${quote(row.Code)}`;
 correctionLines.push(`  SELECT o."Name" INTO existing_name FROM heroes_watch."AdventureObject" o, heroes_watch."Game" g WHERE ${where};
  IF FOUND THEN
    IF existing_name IS DISTINCT FROM ${quote(c.expected)} AND existing_name IS DISTINCT FROM ${quote(c.value)} THEN
      RAISE EXCEPTION 'Unrecognized existing label for %; correction aborted', ${quote(c.key)};
    END IF;
    UPDATE heroes_watch."AdventureObject" o SET "Name" = ${quote(c.value)} FROM heroes_watch."Game" g WHERE ${where} AND o."Name" = ${quote(c.expected)};
  END IF;`);
}
correctionLines.push('END\n$corrections$;','COMMIT;','');
const correctionPath=path.join(dbRoot,'data/touchups-corrections.sql');
const correctionSql=correctionLines.join('\n');
if(args.includes('--check')){
 if(!fs.existsSync(correctionPath)||fs.readFileSync(correctionPath,'utf8').replaceAll('\r\n','\n')!==correctionSql)throw Error('Regenerate touchups-corrections.sql');
}else fs.writeFileSync(correctionPath,correctionSql);
const seeds=[...audit.addedRows,...audit.filledFields,...audit.correctedFields];
const core=seeds.filter(r=>r.table!=='MapObjectPresence');
const presence=seeds.filter(r=>r.table==='MapObjectPresence');
const groups=[core];
for(let i=0;i<presence.length;i+=1000)groups.push(presence.slice(i,i+1000));
const manifest={formatVersion:1,requiresMigration:'postgres/migrations/0002_relationship_integrity.sql',
 corrections:'data/touchups-corrections.sql',manualCatchup:'data/manual-import.sql',parts:[],
 note:'Each part is a self-contained, transactional subset with full FK dependencies. Apply corrections first, then all parts. Repeat imports preserve existing IDs and non-null values.'};
for(const [i,seedsForPart]of groups.entries()){
 const filename=`touchups-import-${String(i+1).padStart(2,'0')}.sql`;
 const bundle={...catalog,notes:'Reviewed touchup subset '+(i+1)+'; includes its referenced catalog dependencies.',tables:selectContentClosure(catalog,schema,seedsForPart)};
 const input=path.join(temp,filename+'.json');fs.writeFileSync(input,JSON.stringify(bundle,null,2)+'\n');
 const generated=spawnSync(process.execPath,[path.join(dbRoot,'tools/build-content-sql.mjs'),'--input',input,'--output',path.join(dbRoot,'data',filename),...args],{encoding:'utf8'});
 if(generated.status!==0)throw Error(generated.stderr||generated.stdout||'SQL generation failed');
 process.stdout.write(generated.stdout);
 manifest.parts.push({file:'data/'+filename,seedRows:seedsForPart.length,rows:Object.values(bundle.tables).reduce((n,r)=>n+r.length,0)});
}
const manifestPath=path.join(dbRoot,'data/touchups-import-manifest.json'),manifestText=JSON.stringify(manifest,null,2)+'\n';
if(args.includes('--check')){
 if(!fs.existsSync(manifestPath)||fs.readFileSync(manifestPath,'utf8').replaceAll('\r\n','\n')!==manifestText)throw Error('Regenerate touchups-import-manifest.json');
}else fs.writeFileSync(manifestPath,manifestText);
console.log(`${groups.length} touchup parts plus ${audit.correctedFields.length} guarded label corrections. No database connection was opened.`);
