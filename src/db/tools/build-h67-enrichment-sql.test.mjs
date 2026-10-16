import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import {spawnSync} from 'node:child_process';
import {fileURLToPath} from 'node:url';

const directory=path.dirname(fileURLToPath(import.meta.url));
const builder=path.join(directory,'build-h67-enrichment-sql.mjs');
const output=path.join(directory,'../data/h67-profile-enrichment.sql');

test('H7 profile enrichment locks mutable parents and updates only resolved physical IDs',()=>{
  const checked=spawnSync(process.execPath,[builder,'--check'],{encoding:'utf8'});
  assert.equal(checked.status,0,checked.stderr);
  const sql=fs.readFileSync(output,'utf8');
  assert.match(sql,/LOCK TABLE heroes_watch\."Creature", heroes_watch\."CreatureHOMM7", heroes_watch\."Game" IN SHARE ROW EXCLUSIVE MODE;/,
    'lock order must match the alphabetical generated-import order');
  assert.match(sql,/SELECT count\(\*\), min\(d\."Creature_id"\) INTO matches, target_id/);
  assert.match(sql,/IF matches <> 1 THEN RAISE EXCEPTION 'Expected exactly one creature profile:/);
  assert.match(sql,/WHERE d\."Creature_id"=target_id AND d\."WarfareStats" IS NOT DISTINCT FROM previous/);
  assert.match(sql,/GET DIAGNOSTICS changed = ROW_COUNT;/);
  assert.doesNotMatch(sql,/UPDATE heroes_watch\."CreatureHOMM7" d SET "WarfareStats"=.*\n\s+FROM heroes_watch\."Creature"/);
});
