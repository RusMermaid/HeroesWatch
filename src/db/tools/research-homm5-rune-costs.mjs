#!/usr/bin/env node
// Factual transcription of resource icons and quantities visually verified on
// PDF/printed page 191 of the developer-supported Heroes V 3.1 manual.
// Emits a research patch only. It never changes the catalog or a database.
import fs from 'node:fs';
import assert from 'node:assert/strict';

const output = new URL('../research/2026-10-13/homm5-rune-costs.patch.json', import.meta.url);
const bundle = JSON.parse(fs.readFileSync(new URL('../data/heroeswatch.json', import.meta.url)));
const evidence = {sourceId: 'h5-manual-3.1-page-191', locator: 'Runic Magic, PDF/printed p.191, resource icons beside each rune name',
  claim: 'Base activation resource quantities in the 3.1 ruleset; Hammers of Fate badges identify introduction, not the ruleset.'};
const definitions = [
  ['charge', ['wood']], ['berserking', ['ore']], ['magic.control', ['gems']],
  ['exorcism', ['sulfur']], ['elemental.immunity', ['mercury']], ['etherealness', ['crystal']],
  ['thunderclap', ['wood', 'mercury']], ['resurrection', ['ore', 'gems']],
  ['battle.rage', ['ore', 'crystal']], ['dragonform', ['wood', 'sulfur']],
];
const additions = [];
for (const resource of ['wood', 'ore', 'mercury', 'sulfur', 'crystal', 'gems']) {
  const key = `resource.${resource}`;
  const existing = bundle.tables.Resource.find(row => row._key === key);
  assert(existing, `Missing global resource ${key}`);
  assert(!bundle.tables.GameResource.some(row => row.Game_id === 'homm5.game' && row.Resource_id === key),
    `H5 membership already exists for ${key}; review the new baseline before regenerating`);
  additions.push({table: 'GameResource', row: {
    _key: `homm5.resource.${resource}`, Game_id: 'homm5.game', Resource_id: key,
    DisplayName: existing.Name, ResourceClass: ['wood', 'ore'].includes(resource) ? 'Common' : 'Rare',
    DisplayOrder: null, MediaAsset_id: null, IntroducedInExpansion_id: null,
  }, evidence});
}
for (const [rune, resources] of definitions) {
  const spell = `homm5.spell.rune.of.${rune}`;
  assert(bundle.tables.SpellHOMM5.some(row => row._key === spell && row.SpellKind === 'Rune'), `Unknown rune ${spell}`);
  for (const resource of resources) additions.push({table: 'SpellResourceCostHOMM5', row: {
    _key: `homm5.rune.cost.tote.${rune}.${resource}`, Game_id: 'homm5.game',
    Spell_id: spell, Resource_id: `resource.${resource}`, Amount: 1, Ruleset: 'TribesOfTheEast',
  }, evidence});
}
assert.equal(additions.filter(action => action.table === 'SpellResourceCostHOMM5').length, 14);
fs.writeFileSync(output, JSON.stringify({formatVersion: 1, researchDate: '2026-10-13',
  notes: 'Baseline rune activation costs only. Skill/perk discounts and repeat-activation modifiers are not additional base-cost rows. No mana cost is inferred.',
  additions, fills: [], sources: [{id: evidence.sourceId,
    title: 'Heroes V Manual — Tribes of the East 3.1',
    url: 'https://h5.heroes.net.pl/uploaded/download/other/Heroes5-Manual-en-3-1.pdf',
    provenance: 'Community handbook supported by Ubisoft and Nival; retained by the project as its final official-3.1 mechanics reference.',
    pdfPage: 191, printedPage: 191, sourceBytes: 58182081, observedETag: '"377c9c1-6042b7303c15b"',
    visualCheck: 'Selective PDF extraction rendered at 2400 pixels; all ten cost labels and fourteen resource icons/quantities inspected.',
  }]}, null, 2) + '\n');
console.log('Staged 6 H5 resource memberships and 14 ruleset-specific rune costs; catalog unchanged.');
