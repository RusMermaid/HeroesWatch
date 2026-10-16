// Read an extracted, user-owned Core.zip; emit only factual names and mechanics.
// Usage: node src/db/tools/research-homm678-olden.mjs <extracted-core-directory>
import fs from 'node:fs';
import path from 'node:path';
const core=process.argv[2]; if(!core)throw Error('An extracted Core directory is required.');
const read=p=>JSON.parse(fs.readFileSync(path.join(core,p),'utf8').replace(/^\uFEFF/,''));
const files=p=>fs.readdirSync(path.join(core,p),{withFileTypes:true}).flatMap(e=>e.isDirectory()?files(`${p}/${e.name}`):[`${p}/${e.name}`]);
const records=p=>files(p).filter(p=>p.endsWith('.json')).flatMap(p=>(read(p).array||[]).map(v=>({...v,_source:p})));
const loc=new Map(files('Lang/english/texts').flatMap(p=>read(p).tokens||[]).map(v=>[v.sid,v.text]));
const name=s=>{const n=loc.get(s);if(!n)throw Error(`Missing English localization ${s}`);return n;};
const slug=s=>s.normalize('NFD').replace(/\p{M}/gu,'').toLowerCase().replace(/[^a-z0-9]+/g,'.').replace(/^\.|\.$/g,'');
const schema=JSON.parse(fs.readFileSync('src/db/schema/heroeswatch.schema.json'));
const existing=JSON.parse(fs.readFileSync('src/db/data/heroeswatch.json')).tables;
const tables={},byTable=new Map(),exp='homm8.expansion.base';
function row(t,key,fields){return {_key:key,...Object.fromEntries(schema.tables.find(x=>x.name===t).columns.filter(c=>!c.primaryKey).map(c=>[c.name,null])),...fields};}
function out(t,r){let ids=byTable.get(t)||new Set();if(ids.has(r._key))return r._key;ids.add(r._key);byTable.set(t,ids);(tables[t]??=[]).push(r);return r._key;}
function cat(t,id,n,fields={}){const key=`homm8.${t.toLowerCase()}.${slug(id)}`;return out(t,row(t,key,{Game_id:'homm8.game',Code:slug(id).replaceAll('.','_').toUpperCase(),Name:n,IntroducedInExpansion_id:exp,...fields}));}
out('Game',row('Game','homm8.game',{SeriesCode:'HOMM8',DisplayOrder:8,Name:'Heroes of Might and Magic: Olden Era',ReleaseDate:'2026-04-30',Description:'Early Access release. HOMM8 is the repository series band; the published title is Olden Era.'}));
out('Expansion',row('Expansion',exp,{Game_id:'homm8.game',Code:'BASE',Name:'Olden Era Early Access',Kind:'BaseGame',ReleaseDate:'2026-04-30',Description:'Released Early Access content, researched against installed Steam build 25061458 on 2026-09-29. Future campaign acts and demo-only content are excluded.'}));
const resNames={gold:['gold','Gold'],wood:['wood','Wood'],ore:['ore','Ore'],crystals:['crystal','Crystal'],gemstones:['gems','Gems'],mercury:['mercury','Mercury'],dust:['alchemical.dust','Alchemical Dust'],graal:['grail','Grail']},resKeys={};
for(const [i,[id,[key,n]]] of Object.entries(resNames).entries()){
 const k=`resource.${key}`;resKeys[id]=k;
 if(!existing.Resource.some(r=>r._key===k))out('Resource',row('Resource',k,{Code:key.replaceAll('.','_').toUpperCase(),Name:n}));
 out('GameResource',row('GameResource',`homm8.resource.${key}`,{Game_id:'homm8.game',Resource_id:k,DisplayName:n,ResourceClass:id==='gold'?'Currency':['wood','ore'].includes(id)?'Common':id==='graal'?'Other':id==='dust'?'Precious':'Rare',DisplayOrder:i+1,IntroducedInExpansion_id:exp}));
}
const skills=read('DB/heroes_skills/skills/skills.json').array,skillMap=new Map(skills.map(s=>[s.id,s])),skillKeys=new Map();
function skill(id){if(skillKeys.has(id))return skillKeys.get(id);const s=skillMap.get(id);if(!s)throw Error('Missing skill '+id);const k=cat('Skill',id,name(s.name));skillKeys.set(id,k);return k;}
const factionSkill={human:'skill_faction_humans',undead:'skill_faction_undead',nature:'skill_faction_nature',demon:'skill_faction_demons',unfrozen:'skill_faction_unfrozen',dungeon:'skill_faction_dungeon'};
const factionKeys={},factions=records('DB/fractions');
for(const f of factions){
 const terrain=cat('Terrain',f.biome,f.biome,{Kind:'Basic'}),k=cat('Faction',name(f.name),name(f.name));factionKeys[f.id]=k;
 out('FactionHOMM8',row('FactionHOMM8',k,{NativeTerrain_id:terrain,SignatureResource_id:resKeys[f.resourceName],FactionSkill_id:skill(factionSkill[f.id]),NativeTerrainInitiativeBonus:1,HasFactionLaw:f.fractionLawsLines.length>0}));
}
const standardDirs=['humans','necros','nature','demons','unfrozen','dungeon'];
const heroes=standardDirs.flatMap(d=>records(`DB/heroes/${d}`));
const classKeys=new Map();
for(const f of factions)for(const type of ['might','magic']){
 const members=heroes.filter(h=>h.fraction===f.id&&h.classType===type);if(members.length!==9)throw Error(`Expected nine ${f.id} ${type} heroes`);
 const h=members[0],roll=h.statsRolls[0].rollChances,stats=Object.fromEntries(roll.map(x=>[x.v,x.c]));
 if(members.some(m=>JSON.stringify(m.statsRolls)!==JSON.stringify(h.statsRolls)))throw Error('Nonuniform class growth '+f.id+type);
 const weights=read(`DB/heroes_skills/skills_by_level_tables/${h.skillsRollVariant}.json`).array[0].defaultList[0].rollChances;
 const weightText=weights.map(w=>`${name(skillMap.get(w.sid).name)}: ${w.chance}`).join('; ');
 const n=name(`${type}_${f.id}_name`),k=cat('HeroClass',n,n,{Archetype:type==='might'?'Might':'Magic',Description:'Primary attribute weights apply before the later 25/25/25/25 growth band. Skill weights describe the ordinary basic-skill offer pool.'});
 classKeys.set(`${f.id}.${type}`,k);
 out('HeroClassHOMM8',row('HeroClassHOMM8',k,{Faction_id:factionKeys[f.id],ClassKind:type==='might'?'Might':'Magic',AttackGrowthWeight:stats[0],DefenseGrowthWeight:stats[1],SpellPowerGrowthWeight:stats[2],KnowledgeGrowthWeight:stats[3],SkillWeights:weightText}));
}
const creatureKeys=new Map();
function creature(id){if(creatureKeys.has(id))return creatureKeys.get(id);const n=loc.get(id+'_name');if(!n)throw Error('Missing unit name '+id);const k=cat('Creature',id,n);creatureKeys.set(id,k);return k;}
const specs=new Map(records('DB/heroes_specializations').map(s=>[s.id,s]));
for(const h of heroes){
 const spec=specs.get(h.specialization),ability=spec?cat('Ability',spec.id,name(spec.name)):null;
 const k=cat('Hero',h.id,name(h.id),{HeroClass_id:classKeys.get(`${h.fraction}.${h.classType}`)});
 const fields={Availability:'Standard',SpecializationAbility_id:ability,StartingSkill_id:skill(h.startSkills[0].sid),StartingAttack:h.stats.offence,StartingDefense:h.stats.defence,StartingSpellPower:h.stats.spellPower,StartingKnowledge:h.stats.intelligence};
 h.startSquad.slice(0,3).forEach((u,i)=>{fields[`StartingCreature${i+1}_id`]=creature(u.sid);fields[`StartingCreature${i+1}Min`]=u.min;fields[`StartingCreature${i+1}Max`]=u.max;});
 out('HeroHOMM8',row('HeroHOMM8',k,fields));
}
// All buildings from the six released faction town definitions, including every level.
const buildingRows=[];
const keyFor=(f,s,l)=>`homm8.building.${slug(f)}.${slug(s)}.level.${l}`;
for(const city of records('DB/objects_logic/cities').filter(c=>factionKeys[c.fraction])){
 for(const [category,arr] of Object.entries(city))if(Array.isArray(arr))for(const b of arr)if(b.sid&&b.parametersPerLevel){
  for(const [i,p] of b.parametersPerLevel.entries()){
   const key=keyFor(city.fraction,b.sid,i+1),n=name(b.names[i]),bonus=b.bonusesPerLevel?.[i]?.bonuses||[];
   const resourceIncome=r=>{const x=bonus.find(x=>x.type==='sideRes'&&x.parameters[0]===r);return x?+x.parameters[1]:null;};
   const pointIncome=t=>{const x=bonus.find(x=>x.type===t);return x?+x.parameters[0]:null;};
   const choices=b.optionalEffectsPerLevel?.[i]?.effects||[];
   const categoryMap={mains:'Hall',walls:'Fortification',magicGuilds:'MageGuild',hires:'Dwelling',graals:'Grail',banks:'Economy',markets:'Economy',taverns:'Special'};
   out('Building',row('Building',key,{Game_id:'homm8.game',Code:slug(`${city.fraction}.${b.sid}.level.${i+1}`).replaceAll('.','_').toUpperCase(),Name:n,Category:categoryMap[category]||'Special',IntroducedInExpansion_id:exp}));
   out('BuildingHOMM8',row('BuildingHOMM8',key,{Faction_id:factionKeys[city.fraction],BuildingCategory:category,SourceKind:'Town',Level:i+1,HasChoice:choices.length>0,GoldIncome:resourceIncome('gold'),LawPointIncome:pointIncome('citySideExp'),AstrologyPointIncome:pointIncome('astrologyExp'),AlchemicalDustIncome:resourceIncome('dust')}));
   for(const cost of p.costs||[]){if(!resKeys[cost.name])throw Error('Unknown resource '+cost.name);out('BuildingResourceCost',row('BuildingResourceCost',`${key}.cost.${slug(cost.name)}`,{Game_id:'homm8.game',Building_id:key,Resource_id:resKeys[cost.name],Amount:cost.cost}));}
   buildingRows.push({key,f:city.fraction,b,level:i+1,p});
   if(category==='hires')for(const u of b.unitsHire?.units||[])for(const id of (i===0?u.sids.slice(0,1):u.sids))out('BuildingCreature',row('BuildingCreature',`${key}.recruits.${slug(id)}`,{Game_id:'homm8.game',Building_id:key,Creature_id:creature(id),Relation:'Recruits'}));
  }
 }
}
const knownBuildings=new Set(buildingRows.map(b=>b.key));
for(const r of buildingRows){
 for(const p of r.p.prevBuildings||[]){const target=keyFor(r.f,p.sid,p.level);if(!knownBuildings.has(target))throw Error('Missing building prerequisite '+target);out('BuildingRequirement',row('BuildingRequirement',`${r.key}.requires.${slug(p.sid)}.${p.level}`,{Game_id:'homm8.game',Building_id:r.key,RequiredBuilding_id:target}));}
 if(r.level>1)out('BuildingUpgrade',row('BuildingUpgrade',`${r.key}.upgrade`,{Game_id:'homm8.game',BaseBuilding_id:keyFor(r.f,r.b.sid,r.level-1),UpgradedBuilding_id:r.key}));
}
for(const d of read('DB/objects_logic/hires/barracks.json').array){
 const n=loc.get(d.id+'_name');if(!n)throw Error('Missing dwelling name '+d.id);
 // This collection is the operative hire logic: decorative TODO objects have no entry.
 const k=cat('AdventureObject',d.id,n,{Description:factionKeys[d.fraction]?`${name(factions.find(f=>f.id===d.fraction).name)} external creature dwelling.`:'Neutral external creature dwelling.'});
 out('AdventureObjectHOMM8',row('AdventureObjectHOMM8',k,{Category:'Dwelling',InteractionType:'Capture',VisitRule:'Repeatable',Capturable:true,ResetsDaily:false,ResetsWeekly:true,Guarded:(d.guardUnits||[]).length>0,RewardType:'Creature recruitment'}));
}
// Ability has no release column; its title-specific specialization classification
// is omitted because the generic definition can include both passive and active bonuses.
for(const r of tables.Ability||[])delete r.IntroducedInExpansion_id;
for(const table of Object.values(tables))table.sort((a,b)=>a._key.localeCompare(b._key));
fs.writeFileSync('src/db/data/research/homm8-catalog.json',JSON.stringify({tables},null,2)+'\n');
console.log(Object.fromEntries(Object.entries(tables).map(([k,v])=>[k,v.length])));
