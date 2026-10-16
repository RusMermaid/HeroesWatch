// Reviewed original Heroes III / Armageddon's Blade / Shadow of Death mechanics.
// This writes a merge fragment; it never overwrites the cumulative database.
// Sources and interpretation notes: ../data/homm3-magic.sources.md.
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import assert from 'node:assert/strict';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const tables = { Skill: [], SkillHOMM3: [], MagicSchool: [], Spell: [], SpellHOMM3: [], SpellMagicSchool: [] };
const slug = name => name.toLowerCase().replace(/'/g, '').replace(/[^a-z0-9]+/g, '.');
const code = name => slug(name).replace(/\./g, '_').toUpperCase();
const game = 'homm3.game';
const catalog = (type, name, description, expansion = 'roe') => ({
  _key: `homm3.${type}.${slug(name)}`, Game_id: game, Code: code(name), Name: name,
  Description: description, IntroducedInExpansion_id: `homm3.expansion.${expansion}`, MediaAsset_id: null,
});
const skill = (name, description, effects) => {
  const row = catalog('skill', name, `Secondary skill. ${description}`);
  tables.Skill.push(row);
  tables.SkillHOMM3.push({ _key: row._key, BasicEffect: effects[0], AdvancedEffect: effects[1], ExpertEffect: effects[2] });
};

for (const [name, description] of [
  ['Attack', 'Primary skill. Added to the Attack rating of creatures commanded by the hero.'],
  ['Defense', 'Primary skill. Added to the Defense rating of creatures commanded by the hero.'],
  ['Spell Power', 'Primary skill, also called Power. Determines the strength and duration of spells that scale with the caster.'],
  ['Knowledge', 'Primary skill. Each point supplies 10 base maximum spell points; Intelligence and other bonuses can increase this amount.'],
]) tables.Skill.push(catalog('skill', name, description));

for (const element of ['Air', 'Earth', 'Fire', 'Water']) {
  const name = `${element} Magic`;
  tables.MagicSchool.push({ _key: `homm3.magic-school.${element.toLowerCase()}`, Game_id: game,
    Code: element.toUpperCase(), Name: name,
    Description: `Elemental school of magic. The ${name} secondary skill determines mastery and mana discounts for its spells.`, MediaAsset_id: null });
  skill(name, `Improves spells belonging to the ${element} school.`, [
    `Cast ${element} spells at Basic mastery with their school mana discount.`,
    `Cast ${element} spells at Advanced mastery with their school mana discount.`,
    `Cast ${element} spells at Expert mastery with their school mana discount.`,
  ]);
}
skill('Archery', 'Increases the base damage of ranged attacks.', [10, 25, 50].map(n => `Ranged attacks gain ${n}% of base damage.`));
skill('Armorer', 'Reduces physical damage received; spell damage is unaffected. Original siege arrow towers have a bug that reverses this benefit.', [5, 10, 15].map(n => `Physical attack damage received is reduced by ${n}%.`));
skill('Artillery', 'Allows manual control of the Ballista and defensive arrow towers.', [
  'Control the Ballista and towers; each Ballista shot has a 50% chance of double base damage.',
  'Control the Ballista and towers; the Ballista shoots twice, with a 75% double-base-damage chance per shot.',
  'Control the Ballista and towers; the Ballista shoots twice and every shot deals double base damage.',
]);
skill('Ballistics', 'Allows manual targeting of the Catapult during sieges.', [
  'Aim one Catapult shot each round with improved damage.',
  'Aim two Catapult shots each round with improved damage.',
  'Aim two Catapult shots each round at maximum damage.',
]);
skill('Diplomacy', 'Improves negotiations with wandering monsters and reduces surrender costs. Joining also depends on army strength and monster disposition.', [
  'Improves monster negotiations; surrender costs 20% less. Library of Enlightenment admission starts at level 8.',
  'Further improves monster negotiations; surrender costs 40% less. Library of Enlightenment admission starts at level 6.',
  'Provides the strongest monster-negotiation bonus; surrender costs 60% less. Library of Enlightenment admission starts at level 4.',
]);
skill('Eagle Eye', 'After victory, may learn eligible spells used by the enemy hero. Wisdom still limits which spell levels can be learned.', [
  '40% chance per eligible enemy combat spell of level 1 or 2 to learn it after victory.',
  '50% chance per eligible enemy combat spell through level 3 to learn it after victory.',
  '60% chance per eligible enemy combat spell through level 4 to learn it after victory.',
]);
skill('Estates', 'Produces daily gold for the owner.', [125, 250, 500].map(n => `Produces ${n} gold each day.`));
skill('First Aid', 'Allows manual control of the First Aid Tent. Healing repairs the surviving top creature without resurrecting casualties.', [50, 75, 100].map(n => `Control the tent and heal 1-${n} HP on a selected friendly stack each round.`));
skill('Intelligence', 'Increases the normal mana maximum derived from Knowledge.', [25, 50, 100].map(n => `Maximum spell points increase by ${n}%.`));
skill('Leadership', 'Raises the morale modifier of eligible troops.', [1, 2, 3].map(n => `Troop morale gains +${n}.`));
skill('Learning', 'Increases experience awarded to the hero.', [5, 10, 15].map(n => `Earn ${n}% additional experience.`));
skill('Logistics', 'Increases base daily land movement before separate flat movement bonuses.', [10, 20, 30].map(n => `Base movement allowance on land increases by ${n}%.`));
skill('Luck', 'Raises the luck modifier of the army.', [1, 2, 3].map(n => `Army luck gains +${n}.`));
skill('Mysticism', 'Increases daily mana regeneration; the listed value is the total, replacing the normal 1 point per day.', [2, 3, 4].map(n => `Regenerate ${n} spell points per day.`));
skill('Navigation', 'Increases base daily movement while sailing.', [50, 100, 150].map(n => `Base movement allowance at sea increases by ${n}%.`));
skill('Necromancy', 'Raises Skeletons after a victorious battle. Casualty count, casualty HP and available army slots constrain the result; artifacts can alter the raised creature.', [10, 20, 30].map(n => `Use a ${n}% Necromancy rate when converting defeated enemy creatures into Skeletons.`));
skill('Offense', 'Increases the base damage of melee attacks.', [10, 20, 30].map(n => `Melee attacks gain ${n}% of base damage.`));
skill('Pathfinding', 'Reduces extra movement cost on difficult terrain. The original game retains a floor of 100 points for a straight, off-road tile.', [25, 50, 75].map(n => `Subtract up to ${n} movement points from the terrain penalty per straight tile, with a 100-point minimum tile cost.`));
skill('Resistance', 'Gives troops a chance to resist hostile magic.', [5, 10, 20].map(n => `Troops gain a ${n}% chance to resist an applicable hostile spell.`));
skill('Scholar', 'Exchanges spells when friendly heroes meet. Recipients need a spell book and sufficient Wisdom.', [2, 3, 4].map(n => `Exchange known spells up to level ${n} between the meeting heroes.`));
skill('Scouting', 'Extends the hero\'s sight radius on the adventure map.', [1, 2, 3].map(n => `Sight radius increases by ${n} map square${n === 1 ? '' : 's'}.`));
skill('Sorcery', 'Increases spell damage in combat.', [5, 10, 15].map(n => `Combat spell damage gains ${n}%.`));
skill('Tactics', 'Allows troop placement before combat; opposing Tactics mastery subtracts from this advantage.', [3, 5, 7].map((n, i) => `Deploy troops within the first ${n} columns before combat; counter ${i + 1} opposing Tactics mastery level${i ? 's' : ''}.`));
skill('Wisdom', 'Allows higher-level spells to be learned. Spells already known or granted by artifacts can be cast without the corresponding Wisdom level.', [3, 4, 5].map(n => `Learn spells through level ${n}.`));

// ManaCost is the untrained cost. ExpertManaCost is the Expert cost.
// Except Teleport, the same discounted cost applies from Basic through Expert.
const spell = (name, school, level, mana, expertMana, description, effects, context = 'Combat', expansion = 'roe') => {
  const row = catalog('spell', name, description, expansion);
  tables.Spell.push(row);
  tables.SpellHOMM3.push({ _key: row._key, Level: level, Context: context, ManaCost: mana,
    ExpertManaCost: expertMana, BasicEffect: effects[0], AdvancedEffect: effects[1], ExpertEffect: effects[2] });
  for (const element of school === 'all' ? ['Air', 'Earth', 'Fire', 'Water'] : [school]) {
    tables.SpellMagicSchool.push({ _key: `homm3.spell-magic-school.${slug(name)}.${element.toLowerCase()}`,
      Game_id: game, Spell_id: row._key, MagicSchool_id: `homm3.magic-school.${element.toLowerCase()}` });
  }
};
const damage = (name, school, level, mana, expertMana, multiplier, offsets, target) =>
  spell(name, school, level, mana, expertMana, `Instant damage spell. ${target}`, offsets.map(n => `${target} Damage per affected stack: ${multiplier} * Spell Power + ${n}.`));

damage('Magic Arrow', 'all', 1, 5, 4, 10, [10, 20, 30], 'Damages one selected enemy stack.');
damage('Lightning Bolt', 'Air', 2, 10, 8, 25, [10, 20, 50], 'Damages one selected stack.');
damage('Destroy Undead', 'Air', 3, 15, 12, 10, [10, 20, 50], 'Damages every undead stack on both sides.');
spell('Chain Lightning', 'Air', 4, 24, 20, 'Instant lightning attack that jumps between stacks, including allies. Each jump halves the preceding damage.', [
  'First target takes 40 * Spell Power + 25 damage. Up to four stacks are struck, with damage halved on each jump.',
  'First target takes 40 * Spell Power + 50 damage. Up to five stacks are struck, with damage halved on each jump.',
  'First target takes 40 * Spell Power + 100 damage. Up to five stacks are struck, with damage halved on each jump.',
]);
spell("Titan's Lightning Bolt", 'Air', 5, 0, 0, "Granted while Titan's Thunder is equipped. Base damage is independent of Spell Power and Air Magic mastery; other damage modifiers can still apply.", Array(3).fill("Strike one enemy stack for 600 base damage at no mana cost. Requires Titan's Thunder."), 'Combat', 'sod');
damage('Death Ripple', 'Earth', 2, 10, 8, 5, [10, 20, 30], 'Damages non-undead creature stacks on both sides, including non-living creatures; war machines are immune.');
damage('Meteor Shower', 'Earth', 4, 16, 12, 25, [25, 50, 100], 'Damages stacks in the selected hex and its six neighboring hexes, including allies.');
damage('Implosion', 'Earth', 5, 30, 25, 75, [100, 200, 300], 'Damages one selected enemy stack.');
spell('Fire Wall', 'Fire', 2, 8, 6, 'Creates a damaging wall that lasts two rounds. Uses the original 10 * Spell Power damage coefficient.', [
  'Create a wall spanning two hexes. Crossing stacks take 10 * Spell Power + 10 damage.',
  'Create a wall spanning three hexes. Crossing stacks take 10 * Spell Power + 20 damage.',
  'Create a wall spanning three hexes. Crossing stacks take 10 * Spell Power + 50 damage.',
]);
damage('Fireball', 'Fire', 3, 15, 12, 10, [15, 30, 60], 'Damages stacks in the selected hex and its six neighboring hexes, including allies.');
spell('Land Mine', 'Fire', 3, 18, 15, 'Places hidden mines until triggered. Enemy creatures on their native terrain can see and safely cross the mines.', [
  'Place four mines at random hexes; each deals 10 * Spell Power + 25 damage when triggered.',
  'Place six mines at random hexes; each deals 10 * Spell Power + 50 damage when triggered.',
  'Place eight mines at random hexes; each deals 10 * Spell Power + 100 damage when triggered.',
]);
damage('Armageddon', 'Fire', 4, 24, 20, 50, [30, 60, 120], 'Damages every susceptible stack on the battlefield, including allies.');
damage('Inferno', 'Fire', 4, 16, 12, 10, [20, 40, 80], 'Damages stacks within two hexes of the selected hex, including allies; up to 19 hexes.');
damage('Ice Bolt', 'Water', 2, 8, 6, 20, [10, 20, 50], 'Damages one selected enemy stack.');
damage('Frost Ring', 'Water', 3, 12, 9, 10, [15, 30, 60], 'Damages stacks in the six hexes surrounding the selected hex, including allies; the center is spared.');

const duration = 'Lasts one combat round per point of Spell Power unless removed earlier.';
const buff = (name, school, level, mana, expertMana, stat, amounts, side = 'friendly') => spell(name, school, level, mana, expertMana,
  `${stat} modifier. ${duration}`, [
    `One ${side} stack: ${stat} ${amounts[0]}.`,
    `One ${side} stack: ${stat} ${amounts[1]}.`,
    `All ${side} stacks: ${stat} ${amounts[2]}.`,
  ]);
buff('Haste', 'Air', 1, 6, 5, 'Speed', ['+3', '+5', '+5']);
spell('Disrupting Ray', 'Air', 2, 10, 8, 'Defense reduction lasts until combat ends. Repeated casts accumulate; Cure and Dispel do not remove it.', [3, 4, 5].map(n => `Reduce one enemy stack's Defense by ${n}; additional casts stack.`));
buff('Fortune', 'Air', 2, 7, 5, 'Luck', ['+1', '+2', '+2']);
buff('Precision', 'Air', 2, 8, 6, 'Attack for ranged attacks', ['+3', '+6', '+6']);
for (const [element, level, mana, expertMana] of [['Air', 2, 7, 5], ['Earth', 3, 12, 9], ['Fire', 1, 5, 4], ['Water', 1, 5, 4]]) {
  spell(`Protection from ${element}`, element, level, mana, expertMana, `Reduces damage from ${element} spells. ${duration}`, [
    `One friendly stack takes 30% less damage from ${element} spells.`,
    `One friendly stack takes 50% less damage from ${element} spells.`,
    `All friendly stacks take 50% less damage from ${element} spells.`,
  ]);
}
spell('Air Shield', 'Air', 3, 12, 9, `Reduces damage from ranged attacks. ${duration}`, [
  'One friendly stack receives 25% less ranged attack damage.',
  'One friendly stack receives 50% less ranged attack damage.',
  'All friendly stacks receive 50% less ranged attack damage.',
]);
spell('Hypnotize', 'Air', 3, 18, 15, `Temporarily controls an enemy stack. The HP test uses the surviving creature count at full individual health. ${duration}`, [10, 20, 50].map(n => `Control one eligible enemy stack whose full-health HP total is below 25 * Spell Power + ${n}.`));
spell('Counterstrike', 'Air', 4, 24, 20, `Grants extra retaliations each combat round. ${duration}`, [
  'One friendly stack gains one additional retaliation per round.',
  'One friendly stack gains two additional retaliations per round.',
  'All friendly stacks gain two additional retaliations per round.',
]);
spell('Magic Mirror', 'Air', 5, 25, 20, `May redirect an eligible hostile spell targeting the protected stack to a random enemy stack. ${duration}`, [20, 30, 40].map(n => `One friendly stack gains a ${n}% chance to redirect eligible enemy spells.`));
for (const element of ['Air', 'Earth', 'Fire', 'Water']) {
  spell(`Summon ${element} Elemental`, element, 5, 25, 20, `Creates ${element} Elementals for the current battle. Only one element type may be summoned by a side in that battle.`, [2, 3, 4].map(n => `Summon ${n} * Spell Power ${element} Elementals until combat ends.`));
}
spell('Shield', 'Earth', 1, 5, 4, `Reduces melee damage received. ${duration}`, [
  'One friendly stack receives 15% less melee damage.',
  'One friendly stack receives 30% less melee damage.',
  'All friendly stacks receive 30% less melee damage.',
]);
spell('Slow', 'Earth', 1, 6, 5, `Reduces creature Speed, rounded down. Counters Haste. ${duration}`, [
  'One enemy stack retains 75% of its Speed.', 'One enemy stack retains 50% of its Speed.', 'All enemy stacks retain 50% of their Speed.',
]);
buff('Stone Skin', 'Earth', 1, 5, 4, 'Defense', ['+3', '+6', '+6']);
spell('Quicksand', 'Earth', 2, 8, 6, 'Hidden pits stop susceptible creatures entering them. Pits remain until combat ends.', [4, 6, 8].map(n => `Place ${n} quicksand pits at random battlefield hexes.`));
spell('Animate Dead', 'Earth', 3, 15, 12, 'Restores casualties in one allied undead stack. Restored creatures remain after combat at every mastery level.', [30, 60, 160].map(n => `Permanently restore up to 50 * Spell Power + ${n} HP of casualties in one friendly undead stack.`));
spell('Anti-Magic', 'Earth', 3, 15, 12, `Protects one friendly stack from spells within the covered levels; Dispel can remove the protection. ${duration}`, [3, 4, 5].map(n => `One friendly stack is protected against spells of levels 1-${n}, subject to Dispel.`));
spell('Earthquake', 'Earth', 3, 20, 17, 'Instant siege spell that damages fortifications, including arrow towers.', [2, 3, 4].map(n => `Inflict one point of fortification damage on ${n} randomly selected walls or towers.`));
spell('Force Field', 'Earth', 3, 12, 9, 'Creates an impassable barrier for two combat rounds.', [2, 3, 3].map(n => `Place a force barrier covering ${n} hexes that blocks movement.`));
spell('Resurrection', 'Earth', 4, 20, 16, 'Restores casualties in one friendly living stack. Basic resurrection expires after battle; Advanced and Expert resurrection persists.', [
  'Restore up to 50 * Spell Power + 40 HP of living casualties for this battle only.',
  'Permanently restore up to 50 * Spell Power + 80 HP of living casualties.',
  'Permanently restore up to 50 * Spell Power + 160 HP of living casualties.',
]);
buff('Sorrow', 'Earth', 4, 16, 12, 'Morale', ['-1', '-2', '-2'], 'enemy');
buff('Bloodlust', 'Fire', 1, 5, 4, 'Attack for melee attacks', ['+3', '+6', '+6']);
spell('Curse', 'Fire', 1, 6, 5, `Forces low base attack damage and counters Bless. ${duration}`, [
  'One enemy stack uses its minimum base damage.',
  'One enemy stack uses minimum base damage minus 1, with a floor of 1 per creature.',
  'All enemy stacks use minimum base damage minus 1, with a floor of 1 per creature.',
]);
spell('Blind', 'Fire', 2, 10, 8, `Disables one eligible enemy stack until it is attacked, dispelled, or the duration expires. ${duration}`, [
  'Blind one enemy stack; its retaliation to the waking attack has 50% strength.',
  'Blind one enemy stack; its retaliation to the waking attack has 25% strength.',
  'Blind one enemy stack; it cannot retaliate against the waking attack.',
]);
buff('Misfortune', 'Fire', 3, 12, 9, 'Luck', ['-1', '-2', '-2'], 'enemy');
spell('Berserk', 'Fire', 4, 20, 16, 'Affected creatures attack their nearest available stack, including allies. Ends after one attack.', [
  'Apply Berserk to the selected hex.',
  'Apply Berserk to the selected hex and its six neighbors, covering up to seven hexes.',
  'Apply Berserk within two hexes of the selected hex, covering up to 19 hexes.',
]);
spell('Fire Shield', 'Fire', 4, 16, 12, `Damages melee attackers of one protected friendly stack. ${duration}`, [20, 25, 30].map(n => `Return ${n}% of received melee damage to the attacking stack.`));
spell('Frenzy', 'Fire', 4, 16, 12, 'Converts Defense into an Attack bonus until the target\'s action turn in the next round.', [100, 150, 200].map(n => `Add ${n}% of the target stack's Defense to its Attack and set its Defense to 0.`));
spell('Slayer', 'Fire', 4, 16, 12, `Gives one friendly stack +8 Attack against eligible high-level creatures, including their upgrades. ${duration}`, [
  '+8 Attack against dragons, Behemoths, Hydras, Firebirds and their upgrades.',
  '+8 Attack against dragons, Behemoths, Hydras, Firebirds, Angels, Devils and their upgrades.',
  '+8 Attack against dragons, Behemoths, Hydras, Firebirds, Angels, Devils, Giants and their upgrades.',
]);
spell('Sacrifice', 'Fire', 5, 25, 20, 'Destroys a friendly non-undead stack to permanently resurrect another eligible friendly stack.', [3, 6, 10].map(n => `Sacrifice the donor stack. Restore (Spell Power + donor creature base HP + ${n}) * sacrificed creature count HP in the recipient stack.`));
spell('Bless', 'Water', 1, 5, 4, `Forces high base attack damage and counters Curse. ${duration}`, [
  'One friendly stack uses its maximum base damage.',
  'One friendly stack uses maximum base damage plus 1 per creature.',
  'All friendly stacks use maximum base damage plus 1 per creature.',
]);
spell('Cure', 'Water', 1, 6, 5, 'Instantly removes harmful spell effects and heals the injured surviving creature; does not resurrect casualties.', [
  'Remove harmful spells and heal up to 5 * Spell Power + 10 HP on one friendly stack.',
  'Remove harmful spells and heal up to 5 * Spell Power + 20 HP on one friendly stack.',
  'Remove harmful spells and heal up to 5 * Spell Power + 30 HP on every friendly stack.',
]);
spell('Dispel', 'Water', 1, 5, 4, 'Instantly removes dispellable spell effects, whether helpful or harmful.', [
  'Remove spell effects from one friendly stack.',
  'Remove spell effects from one friendly or enemy stack.',
  'Remove spell effects from all stacks and dispellable battlefield obstacles.',
]);
spell('Remove Obstacle', 'Water', 2, 7, 5, 'Instantly clears a selected obstacle. Fixed battlefield features such as cliffs remain.', [
  'Remove one ordinary, nonmagical obstacle.',
  'Remove one ordinary obstacle or Fire Wall.',
  'Remove one ordinary or magical obstacle.',
]);
buff('Weakness', 'Water', 2, 8, 6, 'Attack', ['-3', '-6', '-6'], 'enemy');
spell('Forgetfulness', 'Water', 3, 12, 9, `Suppresses ranged attacks and halves melee contribution. Original-game behavior makes Advanced mass-targeting, matching Expert. ${duration}`, [
  'One eligible enemy shooter stack loses half its ranged and melee damage contribution.',
  'All eligible enemy shooter stacks cannot shoot and retain half their melee damage contribution.',
  'All eligible enemy shooter stacks cannot shoot and retain half their melee damage contribution.',
]);
buff('Mirth', 'Water', 3, 12, 9, 'Morale', ['+1', '+2', '+2']);
spell('Teleport', 'Water', 3, 15, 3, 'Instantly relocates a friendly stack. Mana costs are 15 untrained, 12 Basic, 6 Advanced and 3 Expert.', [
  'Move one friendly stack to a free hex without crossing walls or moats. Costs 12 mana.',
  'Move one friendly stack to a free hex, including across moats but not walls. Costs 6 mana.',
  'Move one friendly stack to any free hex, including across walls and moats. Costs 3 mana.',
]);
spell('Clone', 'Water', 4, 24, 20, `Creates a copy of one friendly stack; any damage destroys the copy. ${duration}`, [5, 6, 7].map(n => `Clone a friendly creature stack of level 1-${n}; the copy disappears upon taking damage.`));
buff('Prayer', 'Water', 4, 16, 12, 'Attack, Defense and Speed', ['+2 each', '+4 each', '+4 each']);

const adventure = (...args) => spell(...args, 'Adventure');
adventure('Visions', 'all', 2, 4, 2, 'Provides detailed nearby scouting reports for the current day. The minimum range is three map squares.', [
  'Inspect wandering stack counts and willingness to join within max(Spell Power, 3) squares.',
  'Also inspect enemy hero primary skills and army counts within max(2 * Spell Power, 3) squares.',
  'Also inspect enemy town details and garrison counts within max(3 * Spell Power, 3) squares.',
]);
adventure('View Air', 'Air', 1, 2, 1, 'Displays selected object categories on the world overview.', [
  'Reveal artifact locations on the world overview.',
  'Reveal artifact and hero locations on the world overview.',
  'Reveal artifact, hero and town locations on the world overview.',
]);
adventure('Disguise', 'Air', 2, 4, 2, 'Changes enemy scouting reports of the casting hero\'s army for the current day.', [
  'Show every stack as the strongest creature type in the hero\'s army while retaining the real counts.',
  'Show every stack as the strongest creature type in the hero\'s army and hide counts with zeroes.',
  'Hide counts and show the strongest creature associated with the longest-owned starting town; fall back to the hero class town when applicable.',
]);
adventure('Dimension Door', 'Air', 5, 25, 20, 'Teleports the hero to a valid nearby map square. Untrained casting is limited to once daily; mastery raises the limit.', [
  'Teleport up to twice per day, spending 300 movement points per cast.',
  'Teleport up to three times per day, spending 300 movement points per cast.',
  'Teleport up to four times per day, spending 200 movement points per cast.',
]);
adventure('Fly', 'Air', 5, 20, 15, 'Allows travel over water and obstacles for the current day, ending on an allowed landing square.', [
  'Fly with a 40% movement penalty.', 'Fly with a 20% movement penalty.', 'Fly without a movement penalty.',
]);
adventure('View Earth', 'Earth', 1, 2, 1, 'Displays resources and terrain information on the world overview.', [
  'Reveal loose resource locations on the world overview.',
  'Reveal loose resources and mines on the world overview.',
  'Reveal terrain, loose resources and mines on the world overview.',
]);
adventure('Town Portal', 'Earth', 4, 16, 12, 'Teleports the hero to an allied town without another visiting hero.', [
  'Travel to the nearest eligible allied town; spend 300 movement points.',
  'Choose any eligible allied town; spend 300 movement points.',
  'Choose any eligible allied town; spend 200 movement points.',
]);
adventure('Summon Boat', 'Water', 1, 8, 7, 'Requires a shoreline with an available adjacent boat tile. A failed probability roll consumes mana.', [
  '50% success chance to summon the nearest eligible unoccupied boat belonging to the player or no player; cannot create a boat.',
  '75% success chance to summon an unoccupied boat or create one if none is available, subject to the map boat limit.',
  '100% success chance to summon an unoccupied boat or create one if none is available, subject to the map boat limit.',
]);
adventure('Scuttle Boat', 'Water', 2, 8, 6, 'Attempts to destroy a selected visible boat; occupied boats cannot be targeted.', [50, 75, 100].map(n => `${n}% chance to destroy the selected unoccupied boat.`));
adventure('Water Walk', 'Water', 4, 12, 8, 'Allows crossing water for the current day; each movement path must finish on unoccupied land.', [
  'Cross water with a 40% movement penalty.', 'Cross water with a 20% movement penalty.', 'Cross water without a movement penalty.',
]);

for (const rows of Object.values(tables)) rows.sort((a, b) => a._key.localeCompare(b._key));
assert.equal(tables.Skill.length, 32);
assert.equal(tables.SkillHOMM3.length, 28);
assert.equal(tables.MagicSchool.length, 4);
assert.equal(tables.Spell.length, 70);
assert.equal(tables.SpellHOMM3.filter(row => row.Context === 'Adventure').length, 10);
assert.equal(tables.SpellMagicSchool.length, 76);
for (const [name, rows] of Object.entries(tables)) assert.equal(new Set(rows.map(row => row._key)).size, rows.length, `${name}: duplicate key`);
const out = path.join(root, 'data', 'research', 'homm3-magic.json');
fs.mkdirSync(path.dirname(out), { recursive: true });
fs.writeFileSync(out, JSON.stringify({ tables }, null, 2) + '\n');
console.log(JSON.stringify(Object.fromEntries(Object.entries(tables).map(([name, rows]) => [name, rows.length]))));
