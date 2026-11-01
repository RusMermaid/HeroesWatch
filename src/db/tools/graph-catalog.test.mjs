import test from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
const {tables}=JSON.parse(readFileSync(new URL('../data/heroeswatch.json',import.meta.url),'utf8'));

test('Last Bastion contains its one scenario, rather than its five hero names',()=>{
  const members=tables.CampaignScenario.filter(r=>r.Campaign_id==='homm4.campaign.the.last.bastion');
  assert.equal(members.length,1);
  const scenario=tables.Scenario.find(r=>r._key===members[0].Scenario_id);
  assert.equal(scenario.Name,'Last Man Standing');
  const heroes=tables.CampaignHero.filter(r=>r.Campaign_id==='homm4.campaign.the.last.bastion');
  assert.equal(heroes.length,5);
  assert.ok(heroes.every(r=>r.StartingScenario_id===scenario._key));
});

test('the two Olden Era mission-seven routes independently activate mission eight',()=>{
  const target=tables.Scenario.find(r=>r._key==='homm8.scenario.main.story.campaign.start.phase.mission.8.1');
  assert.ok(target);
  const incoming=tables.ScenarioConnection.filter(r=>r.ToScenario_id===target._key);
  assert.equal(incoming.length,2);
  assert.ok(incoming.every(r=>r.ConnectionKind==='Choice'));
  assert.deepEqual(new Set(incoming.map(r=>r.FromScenario_id)),new Set([
    'homm8.scenario.main.story.campaign.start.phase.mission.7.1',
    'homm8.scenario.main.story.campaign.start.phase.mission.7.alt.1',
  ]));
});

test('supported manual fields and fort display labels retain their corrections',()=>{
  assert.equal(tables.CreatureHOMM1.find(r=>r._key==='homm1.creature.gargoyle').Growth,6);
  assert.equal(tables.CreatureHOMM1.find(r=>r._key==='homm1.creature.genie').GoldCost,650);
  const forts=tables.AdventureObject.filter(r=>r.Game_id==='homm6.game'&&r._key.includes('.file.')&&r._key.endsWith('.fort'));
  assert.equal(forts.length,6);
  assert.ok(forts.every(r=>!r.Name.includes('File:')&&!r.Name.includes('.png')));
});
