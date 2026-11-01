import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {validateCatalogGuards} from './catalog-guards.mjs';
const schema = JSON.parse(fs.readFileSync(new URL('../schema/heroeswatch.schema.json', import.meta.url)));
const data = JSON.parse(fs.readFileSync(new URL('../data/heroeswatch.json', import.meta.url)));

test('all current catalog rows satisfy v6 guards', () => assert.deepEqual(validateCatalogGuards(schema, data), []));
test('negative amounts and empty lore subjects fail; zero and contextual lore remain allowed', () => {
  const b = structuredClone(data);
  b.tables.CreatureResourceCost[0].Amount = -1;
  for (const column of ['Hero_id','CampaignHero_cid','Campaign_id','Scenario_id','Map_id','Faction_id']) b.tables.LoreFull[0][column] = null;
  const errors = validateCatalogGuards(schema, b);
  assert(errors.some(error => error.includes('non-negative')));
  assert(errors.some(error => error.includes('at least one subject')));
  b.tables.CreatureResourceCost[0].Amount = 0;
  b.tables.LoreFull[0] = data.tables.LoreFull[0];
  assert.deepEqual(validateCatalogGuards(schema, b), []);
});
test('graph cycles and self-edges fail after resolving aliases', () => {
  const b = structuredClone(data), edge = b.tables.CreatureUpgrade[0];
  b.tables.CreatureUpgrade.push({...edge, _key:'test.reverse', BaseCreature_id:edge.UpgradedCreature_id, UpgradedCreature_id:edge.BaseCreature_id});
  assert(validateCatalogGuards(schema, b).some(error => error.includes('CreatureUpgrade contains a cycle')));
  b.tables.CreatureUpgrade.at(-1).BaseCreature_id = edge.BaseCreature_id;
  assert(validateCatalogGuards(schema, b).some(error => error.includes('cannot reference itself')));
});
test('H8 signature memberships and known town-screen faction mismatches fail', () => {
  const b = structuredClone(data), h8 = b.tables.Game.find(row => row.SeriesCode === 'HOMM8');
  const resource = b.tables.FactionHOMM8[0].SignatureResource_id;
  b.tables.GameResource = b.tables.GameResource.filter(row => row.Game_id !== h8._key || row.Resource_id !== resource);
  assert(validateCatalogGuards(schema, b).some(error => error.includes('GameResource membership')));
  const link = b.tables.TownScreenBuilding[0];
  const detail = b.tables.BuildingHOMM3.find(row => row._key === link.Building_id);
  detail.Faction_id = b.tables.FactionHOMM3.find(row => row._key !== detail.Faction_id)._key;
  assert(validateCatalogGuards(schema, b).some(error => error.includes('different factions')));
});
