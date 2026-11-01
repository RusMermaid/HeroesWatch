import test from 'node:test';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {rewindResearch} from './rewind-research.mjs';
const hash=x=>createHash('sha256').update(JSON.stringify(x)).digest('hex');
test('migration baseline reconstruction verifies hashes and reverses only audited changes',()=>{
  const before={tables:{Example:[{_key:'old',Name:null}]}};
  const after={tables:{Example:[{_key:'old',Name:'Filled'},{_key:'new',Name:'Added'}]}};
  const audit={inputSha256:hash(before),outputSha256:hash(after),patches:[{fills:[{table:'Example',key:'old',field:'Name',expected:null,value:'Filled'}],additions:[{table:'Example',key:'new',row:after.tables.Example[1]}]}]};
  assert.deepEqual(rewindResearch(after,audit),before);
  assert.equal(after.tables.Example.length,2);
  assert.throws(()=>rewindResearch(after,{...audit,inputSha256:'bad'}),/baseline hash/);
  assert.throws(()=>rewindResearch(before,audit),/output hash/);
});
