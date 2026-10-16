// Usage: node src/db/tools/research-remaining-homm8.mjs <extracted Core.zip>
// Writes an additive research fragment, never the cumulative bundle or database.
import fs from 'node:fs';
import path from 'node:path';
const core=process.argv[2];
if(!core) throw Error('Supply the directory containing the extracted DB and Lang folders.');
const read=p=>JSON.parse(fs.readFileSync(path.join(core,p),'utf8').replace(/^\uFEFF/,''));
const files=p=>fs.readdirSync(path.join(core,p),{withFileTypes:true}).flatMap(e=>e.isDirectory()?files(`${p}/${e.name}`):[`${p}/${e.name}`]);
const records=p=>files(p).filter(p=>p.endsWith('.json')).flatMap(p=>(read(p).array||[]).map(v=>({...v,_source:p})));
const loc=new Map(files('Lang/english/texts').flatMap(p=>read(p).tokens||[]).map(v=>[v.sid,v.text]));
const schema=JSON.parse(fs.readFileSync('src/db/schema/heroeswatch.schema.json'));
const existing=JSON.parse(fs.readFileSync('src/db/data/heroeswatch.json')).tables;
const tables={},ignored=[];
const slug=s=>s.normalize('NFD').replace(/\p{M}/gu,'').toLowerCase().replace(/[^a-z0-9]+/g,'.').replace(/^\.|\.$/g,'');
const key=(t,id)=>`homm8.${t.toLowerCase()}.${slug(id)}`;
const game='homm8.game',release='homm8.expansion.base';
function row(t,k,fields){const cols=schema.tables.find(x=>x.name===t).columns;return {_key:k,...Object.fromEntries(cols.filter(c=>!c.primaryKey).map(c=>[c.name,null])),...Object.fromEntries(Object.entries(fields).filter(([k])=>cols.some(c=>c.name===k)))};}
function add(t,r){if(existing[t].some(x=>x._key===r._key))return r._key;const prior=(tables[t]||[]).find(x=>x._key===r._key);if(prior){if(JSON.stringify(prior)!==JSON.stringify(r))throw Error(`Conflicting research row ${t}/${r._key}`);return r._key;}(tables[t]??=[]).push(r);return r._key;}
function cat(t,id,name,fields={}){if(!name)throw Error(`Missing name ${t}/${id}`);return add(t,row(t,key(t,id),{Game_id:game,Code:slug(id).replaceAll('.','_').toUpperCase(),Name:name,IntroducedInExpansion_id:release,...fields}));}
const factions={human:'temple',undead:'necropolis',nature:'grove',demon:'hive',unfrozen:'schism',dungeon:'dungeon'};
const resources={gold:'gold',wood:'wood',ore:'ore',crystals:'crystal',gemstones:'gems',mercury:'mercury',dust:'alchemical.dust',graal:'grail'};
const schools={day:'Daylight Magic',night:'Nightshade Magic',space:'Arcane Magic',primal:'Primal Magic'};
const schoolKeys={};for(const [id,n]of Object.entries(schools))schoolKeys[id]=cat('MagicSchool',id,n);
const signed=n=>`${Number(n)>=0?'+':''}${Number(n)}`;
const pct=n=>`${+(Number(n)*100).toFixed(4)}%`;
const clean=t=>(t||'').replace(/<i>.*?<\/i>/gs,'').replace(/<[^>]+>/g,'').replace(/\s+/g,' ').trim();
const skills=read('DB/heroes_skills/skills/skills.json').array;
const skillMap=new Map(skills.map(s=>[s.id,s]));
const skillNames=new Map(skills.map(s=>[s.id,loc.get(s.name)]));
const sideBuffs=records('DB/side_buffs');
const buffMap=new Map(records('DB/buffs').map(x=>[x.id,x]));
const abilityDefinitions=records('DB/heroes_abilities');
const abilityMap=new Map(abilityDefinitions.map(x=>[x.id,x]));
const statNames={offence:'Attack',defence:'Defense',spellPower:'Spell Power',intelligence:'Knowledge',moral:'Morale',luck:'Luck',viewRadius:'scouting radius',damageMin:'minimum damage',damageMax:'maximum damage',hp:'Health',speed:'Speed',initiative:'Initiative',energyPerCast:'Focus gained when attacking',energyPerTakeDamage:'Focus gained when taking damage',manaRestoreBonus:'daily mana regeneration',magicCastsPerRound:'spell casts per round',outComingBuffDuration:'positive effect duration',outComingDebuffDuration:'negative effect duration',startEnergyBonus:'starting Focus',movementBonus:'daily movement'};
const percentNames={movementPerBonus:'daily movement',expPerBonus:'experience gained',magicAttackPerBonus:'spell damage',diplomacyEfficiencyPerBonus:'Diplomacy efficiency',heroSpellPowerModifier:'hero Spell Power contribution',heroIntelligenceModifier:'hero Knowledge contribution',heroOffenceModifier:'hero Attack contribution',heroDefenceModifier:'hero Defense contribution',offencePer:'Attack',defencePer:'Defense',spellPowerPer:'Spell Power',intelligencePer:'Knowledge'};
function simpleBonuses(bonuses){
 const out=[];
 for(const b of bonuses||[]){const p=b.parameters||[],prefix=b.receiverAllegiance==='enemy'?'Enemy ':b.type==='unitStat'?'Allied creatures: ':'';
  if(b.receivers?.length)continue; // A restricted recipient list needs its own researched wording.
  if(['heroStat','heroStatBattle','unitStat'].includes(b.type)&&statNames[p[0]]&&p.length===2)out.push(`${prefix}${signed(p[1])} ${statNames[p[0]]}`);
  else if(['heroStat','heroStatBattle','unitStat'].includes(b.type)&&percentNames[p[0]]&&p.length===2)out.push(`${prefix}${signed(Number(p[1])*100)}% ${percentNames[p[0]]}`);
  else if(b.type==='sideRes')out.push(`${signed(p[1])} ${resources[p[0]]?.replaceAll('.',' ')||p[0]} per day`);
  else if(b.type==='cityUnitsIncrement')out.push(`Weekly tier-${p[0]} creature growth ${signed(p[1])}`);
  else if(b.type==='cityUnitsIncrementPer')out.push(`Weekly creature growth ${signed(Number(p.at(-1))*100)}%`);
  else if(b.type==='unitStat'&&p[0]==='modifierSet'&&p.length===4){const mode={basic_attack:'basic attacks',shoot_attack:'ranged attacks',range_attack:'long-reach attacks',melee_attack:'melee attacks',magic_damage:'magic damage',counter_attack:'retaliation'}[p[2]];if(mode)out.push(`Allied creatures: ${signed(Number(p[3])*100)}% ${p[1]==='inDmgMods'?'damage received from':'damage dealt by'} ${mode}`);}
 }
 return out.length>0&&out.length===bonuses?.length?[...new Set(out)].join('; ')+'.':null;
}
const extraSkillEffects={
 skill_formation:i=>`Waiting increases Attack; defending increases Defense, for the rest of the round. Mastery level ${i+1}.`,
 skill_siege:i=>`Catapult base damage increases by ${[50,100,150][i]}.`,
 skill_battle_artistry:i=>{const d=abilityMap.get(`skill_warrior_ability_skill_battle_artistry_${i+1}`)?.levels[0]?.damageDealer;return `Heroic Strike base damage increases by ${d.minBaseDmg}.`;},
 skill_diplomacy:i=>`Enables negotiations with neutral armies. Diplomacy efficiency bonus: ${[0,25,50][i]}%.`,
 skill_tactics:i=>`Allows deployment before combat. Adds ${i+1} deployment row(s) and reduces an opposing hero's Tactics allowance by ${i+1}.`,
 skill_wisdom:i=>`Allows one additional spell cast per round through overload, at a ${[100,75,50][i]}% mana surcharge.`,
 skill_summoner:i=>`Grants ${['Basic','Advanced','Expert'][i]} Summon Avatar. The avatar uses Spell Power and receives no hero Attack or Defense contribution.`,
 skill_faction_undead:i=>`Raises defeated creatures with ${[10,15,20][i]}% Necromancy efficiency. Necromantic Energy capacity: ${[3000,4000,5000][i]}.`,
 skill_faction_nature:i=>`Allied creatures begin combat with ${i+1} additional Focus charge(s).`,
 skill_faction_unfrozen:i=>`Abyssal Communion capacity: ${[3,4,5][i]}. Each point adds temporary creatures equal to 2.5% of the army at battle start.`,
 skill_faction_demons:i=>`Grants level ${i+1} Summon Swarm: places eggs that hatch into Fire Larvae on the following round.`,
 skill_faction_dungeon:i=>`Grants level ${i+1} combat stances for Attack, Defense, and Spell Power; one stance can be selected each round.`,
 skill_faction_humans:i=>`Grants level ${i+1} Righteousness: allied kills and casualties temporarily increase the hero's four primary attributes.`,
};
const magicSkills=new Set(['skill_sorcery','skill_battlemage','skill_mastery','skill_summoner','skill_wisdom',...Object.keys(schools).map(s=>'skill_magic_'+s)]);
const generalSkills=new Set(['skill_economy','skill_logistic','skill_enlightenment','skill_diplomacy','skill_scouting']);
const subskills=new Map(read('DB/heroes_skills/sub_skills/sub_skills.json').array.map(s=>[s.id,s]));
for(const s of skills){
 const k=cat('Skill',s.id,loc.get(s.name));const school=s.id.replace('skill_magic_','');
 const effects=s.parametersPerLevel.map((p,i)=>{
  if(schoolKeys[school])return `Allows spells through tier 5 in ${schools[school]}.${i>0?' Casts that school one spell level higher.':''}${i===2?' Learns that school remotely from owned mage guilds.':''}`;
  if(s.id==='skill_mastery')return `Allows learning spells through tier ${i+3} in all four schools.`;
  return extraSkillEffects[s.id]?.(i)||simpleBonuses(p.bonuses);
 });
 if(effects.some(x=>!x))throw Error('Unmapped skill mechanics '+s.id);
 add('SkillHOMM8',row('SkillHOMM8',k,{SkillKind:s.skillType==='Faction'?'Faction':magicSkills.has(s.id)?'Magic':generalSkills.has(s.id)?'General':'Might',MagicSchool_id:schoolKeys[school]||null,MaxMastery:'Expert',BasicEffect:effects[0],AdvancedEffect:effects[1],ExpertEffect:effects[2],SubskillChoiceRule:`Choose one of ${s.parametersPerLevel[1].subSkills.length} subskills at Advanced and one of ${s.parametersPerLevel[2].subSkills.length} at Expert in this build.`}));
 for(const [i,p]of s.parametersPerLevel.entries())for(const [slot,id]of (p.subSkills||[]).entries()){
  const a=subskills.get(id);if(!a)throw Error('Missing subskill '+id);
  const ak=cat('Ability',a.id,loc.get(a.name),{Description:simpleBonuses(a.bonuses)});
  add('AbilityHOMM8',row('AbilityHOMM8',ak,{AbilityKind:'Subskill',ParentSkill_id:k,UnlockMastery:i===1?'Advanced':'Expert',ChoiceSlot:slot+1,IsActive:false,IsFocusAction:false,IsAlternativeAttack:false,Effect:simpleBonuses(a.bonuses)}));
 }
}

// Real creature identities are shared with the preceding town/hero batch.
const units=records('DB/units/units_logics').filter(u=>/\/(humans|undead|nature|demons|unfrozen|dungeon|neutral)\//.test(u._source));
const views=new Map(records('DB/units/units_views').map(u=>[u.id,u]));
const growth=new Map(),families=new Map();
for(const city of records('DB/objects_logic/cities'))for(const d of city.hires||[])for(const u of d.unitsHire?.units||[]){for(const id of u.sids){growth.set(id,u.weeklyIncrement);families.set(id,u.sids);}}
const recruited=new Set(growth.keys());
for(const d of read('DB/objects_logic/hires/barracks.json').array)for(const u of d.unitsData?.units||[])for(const id of u.sids){growth.set(id,u.weeklyIncrement);recruited.add(id);}
const availableUnits=[];
for(const u of units){
 // Avatar variants share a displayed identity and are alternative spell internals.
 if(['avatar_nature','avatar_unfrozen','peasant_normal'].includes(u.id)){ignored.push({category:'Creature',id:u.id,reason:'Alternate internal implementation of an existing displayed identity.'});continue;}
 const n=loc.get(views.get(u.id)?.name_||u.id+'_name');if(!n){ignored.push({category:'Creature',id:u.id,reason:'No English displayed name.'});continue;}
 const k=cat('Creature',u.id,n),fam=families.get(u.id),s=u.stats;
 add('CreatureHOMM8',row('CreatureHOMM8',k,{Faction_id:factions[u.fraction]?'homm8.faction.'+factions[u.fraction]:null,Tier:u.tier,CreatureKind:families.has(u.id)?'Faction':u.id==='avatar'||u.id==='lava_larva'?'Summoned':'Neutral',Attack:s.offence,Defense:s.defence,DamageMin:s.damageMin,DamageMax:s.damageMax,Health:s.hp,Speed:s.speed,Initiative:s.initiative,CombatSize:1,Shots:null,WeeklyGrowth:growth.get(u.id)??null,Movement:s.moveType==='fly'?'Flying':s.moveType==='teleport'?'Teleporting':'Ground',Recruitable:recruited.has(u.id),FocusChargeCapOverride:s.maxEnergy??null,DoubleUpgrade:false,AlternativeUpgrade:!!fam,UpgradeCreatureA_id:fam?.[0]===u.id?key('Creature',fam[1]):null,UpgradeCreatureB_id:fam?.[0]===u.id?key('Creature',fam[2]):null}));
 for(const cost of recruited.has(u.id)?u.unitCost?.costResArray||[]:[]){if(!resources[cost.name])throw Error('Unknown creature cost '+cost.name);add('CreatureResourceCost',row('CreatureResourceCost',k+'.cost.'+slug(cost.name),{Game_id:game,Creature_id:k,Resource_id:'resource.'+resources[cost.name],Amount:cost.cost}));}
 if(fam?.[0]===u.id)for(const upgrade of fam.slice(1))add('CreatureUpgrade',row('CreatureUpgrade',k+'.upgrade.'+slug(upgrade),{Game_id:game,BaseCreature_id:k,UpgradedCreature_id:key('Creature',upgrade)}));
 availableUnits.push(u);
}

// Ordinary spells and their Masterful mode share one spell identity.
const magics=records('DB/magics').filter(m=>!m._source.includes('punishment')&&!m._source.includes('test'));
const magicById=new Map(magics.map(m=>[m.id,m]));
const specialByBase=new Map(magics.filter(m=>m.normalMagicSid).map(m=>[m.normalMagicSid,m]));
const spellPurpose={
 'Healing Water':'Heals an allied living troop without reviving fallen creatures.',
 Haste:'Increases an allied troop’s movement speed.',
 Taunt:'Forces nearby enemies to target the selected allied troop.',
 'Radiant Armor':'Reduces incoming damage from every source.',
 Vulnerability:'Increases damage received by the enemy target.',
 'Summon Starchild':'Summons a temporary Starchild stack on a nearby free hex.',
 Berserk:'Forces the target to attack the nearest troop within range, regardless of allegiance.',
 'Lightning Bolt':'Deals magical damage to an enemy troop.',
 'Thick Hide':'Reduces melee damage received by an allied troop.',
 Wean:'Shortens beneficial effects on enemies.',
 Fireball:'Damages all creatures within one hex of the selected position.',
 'Ice Bolt':'Deals magical damage and reduces enemy Initiative.',
 Firewall:'Burning hexes damage ground troops that cross them.',
 Armageddon:'Damages all creatures on the battlefield.',
 'Chain Lightning':'Strikes successive nearby troops with diminishing damage.',
 'Summon Primal Remnant':'Summons a temporary Primal Remnant stack.',
 Energize:'Immediately generates Focus charges.',
 'Early Start':'Increases an allied troop’s Initiative.',
 Blink:'Teleports an allied troop within the spell’s range.',
};
// Explicit summaries of the localized rules in this installed build. Do not
// infer mechanics from similar names used in earlier Heroes games.
Object.assign(spellPurpose,{
 Blessing:'Increases one allied troop’s basic-attack damage.',
 'Favorable Wind':'Increases ranged and long-reach damage for an allied troop.',
 'Shorten Shadow':'Reduces an enemy troop’s Attack and Defense.',
 'Weakening Ray':'Removes enemy retaliation charges for the current round.',
 'Inner Light':'Shortens negative effects on an allied troop.',
 'Arina’s Touch':'Increases allied Initiative and maximum Health.',
 'Song of Power':'Resets the target allied troop’s ability cooldowns.',
 Riposte:'The allied target retaliates before the incoming attack hits.',
 'Heavenly Blades':'Basic attacks deal additional pure damage and heal the attacker; fallen units are not revived.',
 Vengeance:'Enemies that strike the protected allied troop in melee receive magical damage.',
 Judgement:'Hits the enemy target four times with magical damage.',
 'Arina’s Chosen':'Protects a minimum proportion of the troop’s current creatures; taking damage shortens the effect.',
 'Unnatural Calm':'Reduces enemy basic-attack damage.',
 Web:'Reduces enemy movement speed.',
 'Enlarge Shadow':'Increases an allied troop’s Attack and Defense.',
 Despair:'Applies a stacking curse that deals pure damage when the enemy’s turn begins.',
 'Shade Cloak':'Makes an allied troop untargetable until it acts or the round ends.',
 'Umbral Grip':'Inflicts pure damage that ignores damage modifiers.',
 'Fatal Decay':'Prevents the enemy target from recovering Health; the effect persists after its death.',
 Sleep:'Prevents actions until damage awakens the target; an awakened target cannot be put to sleep again in that battle.',
 Twilight:'Disables the target’s ranged attacks.',
 Silence:'Blocks enemy abilities and Focus generation.',
 'Naira’s Kiss':'Marks an enemy so each of its actions causes magical damage.',
 'Coup de Grâce':'Damage kills the marked enemy stack if its remaining size is below the spell’s original-size threshold.',
 'Shadow Army':'Adds temporary creatures to an allied stack, subject to a limit relative to its permanent creatures.',
 'Crystal Crown':'Creates crystal obstacles that can be destroyed by attacks.',
 'Cave In':'Damages an enemy and fills adjacent empty hexes with destructible rocks.',
 'Earth’s Rage':'Damages fortifications and troops inside castle walls.',
 'Anti‑Magic':'Grants undispellable immunity to spells up to the applicable tier; removes summoned and temporary creatures from the target.',
 'Circle of Winter':'Damages creatures around the selected hex and pushes them outward where possible.',
 'Hksmilla’s Rampage':'Grants Double Strike and increases both damage dealt and damage received.',
 'Stone Fangs':'Deals magical damage to multiple selected enemy troops.',
 'Energy Explosion':'Deals area damage that scales with the targets’ Focus charges.',
 'Optical Illusion':'Reduces ranged damage received by an allied troop.',
 'Temporal Spheres':'Places hidden traps that damage a ground creature and nearby troops when triggered.',
 Shackles:'Prevents the enemy target from retaliating.',
 Carapace:'An allied barrier blocks the next instance of damage.',
 'Impending Fate':'Damages all enemy troops in proportion to their creature tiers.',
 'Mirror Copy':'Creates a temporary allied copy with reduced damage, increased incoming damage and no special abilities.',
 Guillotine:'Deals magical damage based on target maximum Health; repeated casts on the same target grow stronger.',
 'Rewind Life':'Restores allied Health and can revive fallen creatures.',
 'Black Hole':'Damages an area within two hexes and pulls its outer targets inward where possible.',
 'Doreath’s Tide':'Increases allied Speed and Initiative while reducing those attributes for enemies.',
 'Spatial Snare':'Hidden traps interrupt ground movement, end the current turn and cancel the next; a trap at the move’s final destination does not trigger.',
 'Reality Distortion':'Defers incoming damage until the next round and applies it as pure damage.',
 'Dusk Dampening':'Makes the enemy hero’s next spell more expensive and less powerful.',
 'Spell Eruption':'Makes the caster’s next spell cheaper and more powerful.',
 'Magic Arrow':'Hits one enemy three times with magical damage.',
 'Dispel Summon':'Removes an enemy summoned troop.',
 'From a Bird’s Eye':'Reveals region borders, including borders hidden by fog.',
 'Clear Fog':'Reveals an area around a selected adventure-map position.',
 'Back to Foothold!':'Teleports the hero to a selected controlled Remote Foothold.',
 'Back to Town!':'Teleports the hero to the nearest controlled town in range and consumes remaining movement.',
 'Mana Transfusion':'Spends the caster’s mana to restore mana to a nearby allied hero.',
 'Mana Rite':'Converts the hero’s remaining movement into mana recovery.',
 Relocation:'Allows immediate creature transfer between the hero and a controlled town.',
 'Second Wind':'Immediately restores the hero’s movement points.',
 'Pocket Dimension':'Creates a temporary Remote Foothold entrance for depositing troops and artifacts.',
 'Gate of Light':'Creates a temporary two-way route between a nearby entrance and a selected destination.',
 'Town Portal':'Teleports the hero to a selected controlled town.',
 'Dimension Door':'Teleports the hero to a selected position within range.',
 Shadowflight:'Allows the hero to fly over adventure-map obstacles for the day.',
 'Necromancer Will':'Switches between raising undead and recovering Necromantic Energy after combat.',
 'Read Minds':'Reveals neutral stack counts and attitudes around the hero.',
 'Naira’s Veil':'Restores fog around the hero to conceal the area from opponents.',
 Groundsight:'Reveals neutral army positions across the adventure map.',
 'Primordial Chaos':'Changes a nearby neutral army into a different army of equivalent strength.',
 Reinforcements:'Allows immediate interaction with a controlled external dwelling within range.',
 'Assemble!':'Allows immediate interaction with a nearby allied hero.',
});
for(const mastery of ['Basic','Advanced','Expert','Master','Grandmaster'])spellPurpose[mastery+' Summon Avatar']=`Summons the ${mastery.toLowerCase()} Avatar variant; only one avatar per side can be present. Its offensive strength scales with Spell Power.`;
function effect(m,index=0){
 const d=m.battleMagic?.magicDealers?.[m.battleMagic.dealersPerLevels?.[index]??0];
 if(m.id==='primal_1_magic_thunderbolt'&&d?.minBaseDmg!=null)return `Deals ${d.minBaseDmg} + ${d.minStackDmg||0} × Spell Power magical damage to one enemy, before resistance and other modifiers.`;
 const n=loc.get(m.name);const summary=spellPurpose[n];
 if(summary)return summary;
 const text=clean(loc.get(m.description?.[index]||m.description?.[0]));
 if(text&&!/\{\d+\}/.test(text))return text;
 // Preserve the identity while leaving its optional detail absent until the
 // formula can be mapped faithfully. Never put unresolved template text in data.
 return null;
}
for(const m of magics){
 if(m.isSpecialMagic||m.normalMagicSid)continue;
 if(/astral_summon_(nature|unfrozen)_/.test(m.id)){ignored.push({category:'Spell',id:m.id,reason:'Faction-specific avatar implementation; displayed summoning spell already represented.'});continue;}
 const n=loc.get(m.name);if(!n){ignored.push({category:'Spell',id:m.id,reason:'Missing localized name.'});continue;}
 const k=cat('Spell',m.id,n,{Description:effect(m)});
 if(schoolKeys[m.school_])add('SpellMagicSchool',row('SpellMagicSchool',k+'.school.'+m.school_,{Game_id:game,Spell_id:k,MagicSchool_id:schoolKeys[m.school_]}));
 const summary=effect(m);if(!summary){ignored.push({category:'SpellHOMM8',id:m.id,reason:'Unresolved parameterized effect; catalog and school identity retained.'});continue;}
 const special=specialByBase.get(m.id),researchable=!!m.upgradeCost?.length;
 add('SpellHOMM8',row('SpellHOMM8',k,{Tier:m.rank,Context:m.usedOnMap?'Adventure':'Combat',BaseManaCost:m.manaCost?.[0]??null,Target:m.battleMagic?.magicDealers?.[0]?.castTargetParams?.castTarget_??null,IsResearchable:researchable,HasMasterful:!!special,Level1Effect:summary,Level2Effect:m.id==='primal_1_magic_thunderbolt'?effect(m,1):null,Level3Effect:m.id==='primal_1_magic_thunderbolt'?effect(m,2):null,Level4Effect:m.id==='primal_1_magic_thunderbolt'?effect(m,3):null,ResearchDustCostLevel2:m.upgradeRes?null:m.upgradeCost?.[0]??null,ResearchDustCostLevel3:m.upgradeRes?null:m.upgradeCost?.[1]??null,ResearchDustCostLevel4:m.upgradeRes?null:m.upgradeCost?.[2]??null,AstrologyUnlockCost:m.learnCost?.find(c=>c.name==='starDust')?.cost??null,AstrologyUpgradeCostLevel2:m.upgradeRes==='starDust'?m.upgradeCost?.[0]:null,AstrologyUpgradeCostLevel3:m.upgradeRes==='starDust'?m.upgradeCost?.[1]:null,AstrologyUpgradeCostLevel4:m.upgradeRes==='starDust'?m.upgradeCost?.[2]:null,MasterfulEffect:special?effect(special):null}));
}

const sets=new Map(records('DB/items/item_sets').map(s=>[s.id,s]));
const artifacts=records('DB/items/items');
const artifactPurpose={
 ethereal_knowledge_vortex_dress_artifact:'Recovers mana when the opposing hero casts a spell.',
 gifts_of_dwarven_lords_automated_antimagic_shield_artifact:'Allied creatures take 10% less magical damage and are immune to Berserk.',
 gifts_of_dwarven_lords_protective_belt_artifact:'Allied creatures take 10% less magical damage and are immune to Sleep.',
 elixir_of_life_flask_of_oblivion_artifact:'Negative effects on allied creatures last one fewer round.',
 endless_bag_artifact:'Produces one unit of the bearer’s faction resource each day: gems, crystal, or mercury.',
 ethereal_knowledge_mirror_shoes_artifact:'Reduces spell mana costs by 2.',
 ethereal_knowledge_third_eye_artifact:'Raises the effective level of spells in all four schools by 1.',
 shamaniac_soul_gemwood_mask_artifact:'Reduces spell cooldowns by one round.',
 pole_star_artifact:'Removes the mana cost of adventure-map spells.',
 orb_of_destruction_artifact:'Increases Heroic Strike base damage.',
 inner_song_music_sheet_artifact:'Allied creature abilities deal 40% more damage.',
 rule_of_shadow_liquid_silence_artifact:'Enemy creature abilities have one additional round of cooldown.',
 hourglass_of_protection_artifact:'Reduces spell cooldowns by one round.',
 ethereal_knowledge_glass_dagger_artifact:'Spells and allied creature abilities ignore 40% of enemy magic resistance.',
 fine_wand_artifact:'Raises the effective level of spells in all four schools by 1.',
 caduceus_artifact:'Heroic Strike restores mana.',
 rule_of_shadow_the_truthseeker_artifact:'Reduces enemy creature Defense by 10%.',
 excalibur_artifact:'Heroic Strike kills additional creatures of eligible tiers.',
 rule_of_shadow_the_truthmaker_artifact:'Reduces enemy creature Attack by 10%.',
 soulscaller_ring_artifact:'Reduces the opposing hero’s spell level in all four schools by 1.',
 elixir_of_life_ring_of_life_artifact:'Positive effects on allied creatures last one additional round.',
 chain_link_artifact:'Neither hero can cast tier 1 or tier 2 spells in combat.',
 gifts_of_dwarven_lords_crimson_resonance_controller_artifact:'Reduces enemy Spell Power by 20%; allied creatures are immune to effects that prevent attacking.',
 gifts_of_dwarven_lords_emerald_resonance_controller_artifact:'Reduces enemy Spell Power by 10%; allied creatures are immune to effects that kill additional units.',
 seal_of_silence_artifact:'Adds one round to enemy spell cooldowns.',
};
for(const a of artifacts){
 let n=loc.get(a.name);if(!n){ignored.push({category:'Artifact',id:a.id,reason:'No English name; unconfirmed quest/editor item.'});continue;}
 const granted=a.bonuses?.find(b=>b.type==='heroMagicAddition')?.parameters?.[0];
 if(/magic_scroll/.test(a._source)&&magicById.has(granted))n+=` (${loc.get(magicById.get(granted).name)})`;
 const baseBonuses=a.bonuses.filter(b=>!b.activationLevel||b.activationLevel<=1);
 const direct=simpleBonuses(baseBonuses);
 const localized=clean(loc.get(a.description));
 const tierGrant=baseBonuses.find(b=>b.type==='heroMagicAdditionMass'&&b.parameters[0]==='any'&&b.parameters[1]==='any');
 const orb=baseBonuses.find(b=>b.type==='heroStat'&&b.parameters[0]==='magicSchoolSet');
 const summary=artifactPurpose[a.id]||direct||(tierGrant?`Grants all tier ${tierGrant.parameters[2]} spells while equipped.`:null)||(/^resonant_sphere_/.test(a.id)&&orb?`Raises the wearer’s ${schools[orb.parameters[1]]} spell level by 1 and reduces the enemy’s corresponding spell level by 1.`:null)||(localized&&!/\{\d+\}/.test(localized)?localized:null)||(a.id.startsWith('campaign_')&&!a.bonuses.length?'Campaign quest item with no passive stat bonus.':null);
 const k=cat('Artifact',a.id,n,{Description:summary});
 if(!summary){ignored.push({category:'ArtifactHOMM8',id:a.id,reason:'Unresolved dynamic effect; catalog identity retained.'});continue;}
 const set=sets.get(a.itemSet),unlimited=a.maxLevel>=999||a.maxLevel===-1,fields={Slot:({left_hand:'Main Hand',right_hand:'Off Hand',unic_slot:'Relic',item_slot:'Item',armor:'Armor',back:'Back',belt:'Belt',boots:'Feet',head:'Head',ring:'Ring'})[a.slot_],Rarity:a.rarity[0].toUpperCase()+a.rarity.slice(1),UnlimitedUpgrades:unlimited,MaxUpgradeLevel:unlimited?null:a.maxLevel,IsDestroyable:a.canDestroy!==false,DestructionDustReward:a.rewardForDestroy??null,Effect:summary,SetCode:set?slug(set.id).replaceAll('.','_').toUpperCase():null,SetName:set?loc.get(set.name):null,SetPieceOrder:set?set.itemsInSet.indexOf(a.id)+1:null};
 const deltas=a.bonuses.filter(b=>b.upgrade?.increment).map(b=>({...b,parameters:[b.parameters[0],String(b.upgrade.increment)]}));
 fields.UpgradeEffect=deltas.length?simpleBonuses(deltas):null;
 for(const bonus of set?.bonuses||[]){const count=Number(bonus.requiredItemsAmount),txt=simpleBonuses(bonus.heroBonuses);if(count>=2&&count<=8&&txt)fields[`SetBonus${count}Pieces`]=txt;}
 add('ArtifactHOMM8',row('ArtifactHOMM8',k,fields));
}

// Only named operative object types; no TODOs, sprite variants or artifact pickups.
const objectNames=new Set(existing.AdventureObject.filter(x=>x.Game_id===game).map(x=>x.Name));
for(const o of records('DB/objects_logic')){
 if(/\/(todo|hires|cities|items|blocks)\//.test(o._source))continue;
 const n=loc.get(o.id+'_name')||loc.get(o.id);if(!n){ignored.push({category:'AdventureObject',id:o.id,reason:'Internal logic without a separate localized object name.'});continue;}
 if(objectNames.has(n))continue;objectNames.add(n);
 const group=o._source.split('/')[2];
 const category=group==='res_mines'?'Mine':group==='magic_mines'?'Magic amplifier':group==='portals'?'Teleport':group==='prisons'?'Prison':group==='res'?'Resource':group==='chests'?'Treasure':group==='event_banks'?'Visitable site':'Service';
 const captured=['res_mines','magic_mines','garrisons','outposts','town_gates'].includes(group);
 const variants=o.variants||[],guards=[...(o.guardUnits||[]),...variants.flatMap(v=>v.guardUnits||[])];
 const k=cat('AdventureObject',o.id,n);
 add('AdventureObjectHOMM8',row('AdventureObjectHOMM8',k,{Category:category,InteractionType:captured?'Capture':group==='res'||group==='chests'?'Collect':'Visit',VisitRule:({EachHeroOneTime:'Once per hero',Unlimited:'Repeatable',OneTime:'One use',EachSideOneTime:'Once per player'})[o.visitType]||null,Capturable:captured,ResetsDaily:o.visitorsResetType==='OnStartDay'||o.variantRerollType==='OnStartDay',ResetsWeekly:o.visitorsResetType==='OnStartWeek'||o.variantRerollType==='OnStartWeek',Guarded:guards.length>0||Number(o.customGuardValue||0)>0,RewardType:null}));
}
const campaign=cat('Campaign','main.story',loc.get('mainStory'),{Expansion_id:release,Description:'Released Act I of the Olden Era Early Access campaign; later acts are not included.'});
cat('Campaign','tutorial',loc.get('tutorial'),{Expansion_id:release,Description:'The linked introductory tutorial missions in the released game.'});
cat('Campaign','tutorial.challenges',loc.get('campaign_tutorial_challenges'),{Expansion_id:release,Description:'The released set of tutorial challenge missions.'});
for(const h of records('DB/heroes/campaign').filter(h=>/^campaign_hero_[1-4]$/.test(h.id))){
 const classRow=existing.HeroClassHOMM8.find(c=>c.Faction_id==='homm8.faction.'+factions[h.fraction]&&c.ClassKind.toLowerCase()===h.classType);
 const k=cat('Hero',h.id,loc.get(h.id),{HeroClass_id:classRow?._key});
 add('HeroHOMM8',row('HeroHOMM8',k,{Availability:'CampaignOnly',StartingAttack:h.stats.offence,StartingDefense:h.stats.defence,StartingSpellPower:h.stats.spellPower,StartingKnowledge:h.stats.intelligence}));
 add('CampaignHero',row('CampaignHero',k+'.campaign.main.story',{Game_id:game,Campaign_id:campaign,Hero_id:k,IsCampaignHero:true,CampaignRole:'Protagonist'}));
}
for(const h of ['humans','necros','nature','demons','unfrozen','dungeon'].flatMap(d=>records('DB/heroes/'+d))){for(const s of h.startSkills||[]){if(!skillMap.has(s.sid))continue;add('HeroSkill',row('HeroSkill',key('Hero',h.id)+'.skill.'+slug(s.sid),{Game_id:game,Hero_id:key('Hero',h.id),Skill_id:key('Skill',s.sid),Mastery:['Basic','Advanced','Expert'][s.skillLevel-1]}));}}
for(const rows of Object.values(tables))rows.sort((a,b)=>a._key.localeCompare(b._key));
fs.mkdirSync('src/db/data/research',{recursive:true});
fs.writeFileSync('src/db/data/research/remaining-homm8.json',JSON.stringify({tables},null,2)+'\n');
fs.writeFileSync('.codex-tmp/remaining-homm8-unresolved.json',JSON.stringify(ignored,null,2)+'\n');
console.log(Object.fromEntries(Object.entries(tables).map(([t,rows])=>[t,rows.length])));
console.log('Unresolved/filtered source records:',ignored.length);
