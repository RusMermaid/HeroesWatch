import test from 'node:test';
import assert from 'node:assert/strict';
import {sourceNullableColumns,validateSourceDetails} from './source-detail-rules.mjs';
import {validateJsonColumn} from './json-contracts.mjs';
const validate=(table,row)=>validateSourceDetails({tables:{[table]:[{_key:'probe',...row}]}});

test('exceptional stats can be unknown without weakening ordinary creature requirements',()=>{
  assert.deepEqual(validate('CreatureHOMM6',{CreatureKind:'Boss'}),[]);
  assert.equal(validate('CreatureHOMM6',{CreatureKind:'Town'}).length,sourceNullableColumns.CreatureHOMM6.length);
  assert.deepEqual(validate('CreatureHOMM7',{CreatureKind:'Warfare',WarfareRole:'AttackAndSupport'}),[]);
  assert.equal(validate('CreatureHOMM7',{CreatureKind:'Town'}).length,sourceNullableColumns.CreatureHOMM7.length);
  assert.match(validate('CreatureHOMM7',{CreatureKind:'Warfare'}).join(),/WarfareRole is required/);
  assert.match(validate('CreatureHOMM6',{CreatureKind:'Boss',MightResistancePercent:101}).join(),/between 0 and 100/);
});

test('warfare profile contracts preserve source order and distinguish healing from damage',()=>{
  const stats={profileOrder:'source-listed',supportEffect:'Healing',profiles:[{index:1,health:200,effectAmount:50},{index:2,health:300,effectAmount:100}]};
  assert.equal(validateJsonColumn('CreatureHOMM7','WarfareStats',stats),null);
  assert.match(validateJsonColumn('CreatureHOMM7','WarfareStats',{profileOrder:'source-listed',profiles:[{index:1}]}),/at least 2 properties/);
  assert.match(validateJsonColumn('CreatureHOMM7','WarfareStats',{profileOrder:'source-listed',profiles:[{index:1,effectAmount:1}]}),/supportEffect is required/);
  assert.deepEqual(validate('CreatureHOMM7',{CreatureKind:'Warfare',WarfareRole:'Support',WarfareStats:stats}),[]);
  assert.match(validateJsonColumn('CreatureHOMM7','WarfareStats',{...stats,profiles:[{index:1,health:'200'}]}),/must be integer/);
  assert.match(validateJsonColumn('CreatureHOMM7','WarfareStats',{...stats,profiles:[{index:1,health:-1}]}),/>= 0/);
  assert.match(validateJsonColumn('CreatureHOMM7','WarfareStats',{...stats,skillRank:'Expert'}),/not an allowed field/);
  assert.match(validate('CreatureHOMM7',{CreatureKind:'Warfare',WarfareRole:'Attack',WarfareStats:{...stats,profiles:[{index:2,damageMin:20,damageMax:10}]}}).join(),/source order.*minimum exceeds/);
  assert.match(validate('CreatureHOMM7',{CreatureKind:'Town',WarfareStats:stats}).join(),/requires a warfare unit/);
});
