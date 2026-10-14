// Build an additive research patch from revision-pinned wiki tables.
// Run from the repository root. --fetch retrieves missing cached revisions.
// --input selects the pre-merge catalog when reproducing an already merged patch.
import fs from 'node:fs';
import { createHash } from 'node:crypto';
const root='src/db/research/2026-10-14',cache='.codex-tmp/gaps-2026-10-14/homm67';
const manifest=JSON.parse(fs.readFileSync(`${root}/heroes6-7.wiki-revisions.json`));
const inputAt=process.argv.indexOf('--input');
const input=inputAt<0?'src/db/data/heroeswatch.json':process.argv[inputAt+1];
if(!input||input.startsWith('--'))throw Error('Missing --input value');
const base=JSON.parse(fs.readFileSync(input)).tables;
const hash=s=>createHash('sha256').update(s).digest('hex');
const pages=new Map();
for(const p of manifest){
 const file=`${cache}/${p.file}`;
 if(!fs.existsSync(file)&&process.argv.includes('--fetch')){
  const url=p.language==='ru'?'https://mightandmagic.fandom.com/ru/api.php':'https://mightandmagic.fandom.com/api.php';
  const params={action:'query',prop:'revisions',revids:String(p.revid),rvprop:'content|ids',rvslots:'main',format:'json'};
  const response=await(await fetch(url+'?'+new URLSearchParams(params))).json();
  const revision=Object.values(response.query.pages)[0].revisions[0];
  if(revision.revid!==p.revid)throw Error('Wrong revision: '+p.title);
  fs.mkdirSync(cache,{recursive:true});fs.writeFileSync(file,revision.slots.main['*']);
 }
 const text=fs.readFileSync(file,'utf8');if(hash(text)!==p.sha256)throw Error('Changed source: '+p.title);
 pages.set(p.language+':'+p.title,{...p,text});
}
const slug=x=>x.toLowerCase().replace(/[^a-z0-9]+/g,'.').replace(/^\.|\.$/g,'');
const clean=x=>x.replace(/\[\[(?:[^\]|]+\|)?([^\]]+)\]\]/g,'$1').replaceAll('&nbsp;',' ').trim();
const evidence=(p,section,notes)=>({source:p.url,revision:p.revid,sourceKind:'community-wiki-table',accessed:'2026-10-14',section,...(notes?{notes}:{})});
const patch={formatVersion:1,researchDate:'2026-10-14',game:'Heroes VI and VII',scope:'Wiki-backed creature profiles, named abilities and relationships, class details and warfare recruitment.',policy:'Additions and null-only fills. Wiki revision provenance is retained. Partial boss profiles and warfare progression vectors remain distinct from complete scalar statistics. No full-game extraction is claimed.',additions:[],fills:[],sources:manifest.map(({text,file,...p})=>p)};
const additions=new Set();
function add(table,row,e){const id=table+'/'+row._key;if(additions.has(id))return;if(base[table].some(x=>x._key===row._key))return;additions.add(id);patch.additions.push({table,row,evidence:e});}
function fill(table,key,field,value,e){const old=base[table].find(x=>x._key===key);if(!old)throw Error('Missing fill row '+key);if(old[field]!=null)return;patch.fills.push({table,key,field,expected:null,value,evidence:e});}
function creaturePage(key){const p=manifest.find(p=>p.creatureKey===key);if(!p)throw Error('Missing creature source '+key);return pages.get(p.language+':'+p.title);}
function info(text){const start=text.search(/\{\{Creature(?:Infobox)?\s*\n/);if(start<0)throw Error('No creature infobox');const lines=text.slice(start).split('\n');const out={};for(const line of lines.slice(1)){if(/^\}\}/.test(line))break;const m=line.match(/^\|([^=]+)=(.*)$/);if(m)out[m[1].trim()]=m[2].replace(/\}\}\s*$/,'').trim();}return out;}
function num(value){return /^\d+$/.test(value||'')?Number(value):null;}
function namesInAbilities(text){
 const headings=[...text.matchAll(/^(={2,6})\s*(.*?)\s*\1\s*$/gm)];const result=[];
 for(let i=0;i<headings.length;i++)if(headings[i][2].trim()==='Abilities'){
  let end=text.length;for(let j=i+1;j<headings.length;j++)if(headings[j][1].length<=headings[i][1].length){end=headings[j].index;break;}
  const section=text.slice(headings[i].index+headings[i][0].length,end);
  for(const match of section.matchAll(/^(?:\|\s*'''([^'\n]+)'''\s*$|;\s*([^\n]+))/gm))result.push(clean(match[1]||match[2]));
 }
 return [...new Set(result)];
}
// Names are creature mechanics, kept separate from same-name hero spells/perks.
// Tables do not consistently establish activated versus triggered semantics;
// no IsActive default or empty per-title detail is fabricated.
for(const c of base.Creature.filter(x=>/^homm[67]\.game$/.test(x.Game_id))){
 const p=creaturePage(c._key),game=c.Game_id.slice(0,5);
 for(const name of namesInAbilities(p.text)){
  const suffix=slug(name),key=`${game}.ability.creature.${suffix}`;
  add('Ability',{_key:key,Game_id:c.Game_id,Code:'CREATURE_'+suffix.toUpperCase().replaceAll('.','_'),Name:name,Description:null,MediaAsset_id:null},evidence(p,'Abilities','Creature mechanic identity; no hero spell/perk identity is reused merely because its name matches.'));
  add('CreatureAbility',{_key:`${game}.creatureability.${c._key.split('.creature.')[1]}.${suffix}`,Game_id:c.Game_id,Creature_id:c._key,Ability_id:key,Parameters:null},evidence(p,'Abilities','Explicitly listed for this creature. Form-specific and numerical effects remain in the cited source; this relation does not assert every form has every ability.'));
 }
}
// VI bosses: source percentages do not become raw integer defense points.
for(const c of base.Creature.filter(x=>x.Game_id==='homm6.game'&&!base.CreatureHOMM6.some(r=>r._key===x._key))){
 const p=creaturePage(c._key),b=info(p.text);if(b.tier!=='Boss')continue;
 const damage=b.damage.match(/^(\d+)(?:\s*-\s*(\d+))?$/);if(!damage)throw Error('Unparsed damage '+c._key);
 const row={_key:c._key,Faction_id:null,Tier:null,CreatureKind:'Boss',AttackType:num(b['magic attack'])!==null?'Magic':'Might',DamageMin:+damage[1],DamageMax:+(damage[2]||damage[1]),MightDefense:null,MagicDefense:null,MightResistancePercent:Number(b['might defense'].replace('%','')),MagicResistancePercent:Number(b['magic defense'].replace('%','')),Health:parseInt(b.hp,10),Speed:num(b.speed),Initiative:num(b.initiative),CombatSize:null,Range:['None','Half','Full'].includes(b.range)?b.range:null,Morale:num(b.morale),Luck:num(b.destiny),BasicGrowth:null,UpgradeGrowth:null,Movement:null,Recruitable:false,DoubleUpgrade:false,AlternativeUpgrade:false};
 add('CreatureHOMM6',row,evidence(p,'Gameplay creature stat block','Partial boss profile. Displayed resistance is a percent, not raw defense; movement and occupied-square footprint are unconfirmed. A single printed damage is stored as a constant min=max. Dragonwraith Health means maximum 70000; its source reports starting health 35000.'));
}
const h6old=JSON.parse(fs.readFileSync('src/db/research/2026-10-13/heroes6.patch.json'));
const spectral=h6old.candidateChanges.find(x=>x.kind==='complete_profile_candidate');
const spectralSource=pages.get('ru:Фантомный дракон');
add('CreatureHOMM6',{_key:spectral.key,...spectral.candidateRow,MightResistancePercent:45,MagicResistancePercent:46},evidence(spectralSource,'Creature stat block','Raw defense, flying movement and non-recruitability are explicit. Large ordinary summoned creature uses the established 2x2 catalog convention. Growth is a game-file value reported by the wiki, not a town recruitment entitlement.'));
// Only the two neutral classes publish initial attributes directly.
const h6classes=h6old.candidateChanges.find(x=>x.kind==='class_detail_candidates');
for(const [name,title]of[['darkblade','Клинок Тьмы (класс героя, HoMM VI)'],['sorcerer','Колдун (класс героя, HoMM VI)']]){
 const key='homm6.heroclass.'+name,v=h6classes.candidates[key],p=pages.get('ru:'+title);
 add('HeroClassHOMM6',{_key:key,Faction_id:v.Faction_id,BaseHeroClass_id:null,ReputationPath:'Neutral',...Object.fromEntries(h6classes.fieldOrder.map((f,i)=>[f,v.defaults[i]]))},evidence(p,'Initial attributes table','Use the initial row, not the displayed maximum-level row.'));
}
for(const [identity,value]of Object.entries(h6old.candidateChanges.find(x=>x.kind==='nullable_growth_candidates').candidates)){
 const at=identity.lastIndexOf('.'),key=identity.slice(0,at),field=identity.slice(at+1),haven=/praetorian|sister/.test(key);
 fill('CreatureHOMM6',key,field,value,{source:`https://w.atwiki.jp/homm/pages/${haven?154:206}.html`,sourceKind:'community-wiki-table',accessed:'2026-10-14',section:'Weekly growth row of the named base/upgraded creature pair'});
}
// VII classes: the Russian wiki publishes explicit growth percentages, including
// the campaign-specific Hell Knight. Article focus is checked against the
// corresponding skillwheel; it is not inferred from growth percentages.
const classSpecs={archon:['Повелитель (класс героя, HoMM VII)','necropolis','Defense'],embalmer:['Бальзамировщик','necropolis','Balanced'],engraver:['Начертатель рун','fortress','Defense'],firebrander:['Властитель огня','fortress','Offense'],'hell.knight':['Рыцарь преисподней','dungeon',null],jarl:['Ярл (класс героя, HoMM VII)','fortress','Balanced'],runelord:['Владыка рун','fortress','Balanced'],thane:['Тан (класс героя, HoMM VII)','fortress','Defense'],warlord:['Военачальник (класс героя, HoMM VII)','fortress','Offense']};
for(const[name,[title,faction,focus]]of Object.entries(classSpecs)){
 const p=pages.get('ru:'+title),raw=p.text.match(/Шанс[\s\S]*?(?=\n==|$)/)?.[0];
 const values=['Сила','Защита','Магия','Дух'].map(label=>Number(raw.match(new RegExp(label+'\\s*[-–—]\\s*(\\d+)%'))?.[1]));
 if(values.some(x=>!Number.isFinite(x))||values.reduce((a,b)=>a+b,0)!==100)throw Error('Invalid growth table '+name);
 add('HeroClassHOMM7',{_key:'homm7.heroclass.'+name,Faction_id:'homm7.faction.'+faction,ClassFocus:focus,IsUniqueClass:name==='hell.knight',...Object.fromEntries(['MightGrowthPct','DefenseGrowthPct','MagicGrowthPct','SpiritGrowthPct'].map((f,i)=>[f,values[i]])),SkillWeights:null},evidence(p,'Chance to improve attributes on level-up','No UCP values used. Archon is defensive and Embalmer balanced per their descriptions and skillwheel roles. The English category labels were inconsistent; numerical fields come from this single cited table.'));
}
// VII warfare units: five published profiles are ordered source positions.
// Do not infer their correspondence with novice/expert/master skill ranks.
for(const c of base.Creature.filter(x=>x.Game_id==='homm7.game'&&!base.CreatureHOMM7.some(r=>r._key===x._key))){
 const p=creaturePage(c._key),b=info(p.text);if(!b.tier.includes('warfare'))throw Error('Unexpected missing VII creature');
 const ruMeta=manifest.find(s=>s.warfareKey===c._key),rp=pages.get('ru:'+ruMeta.title);
 if(!/^\|Скорость\s*=\s*Не двигаа?ется\s*$/m.test(rp.text))throw Error('Stationary behavior not explicit: '+c._key);
 const role={'Attack warfare':'Attack','Support warfare':'Support','Siege warfare':'Siege','Attack and support warfare':'AttackAndSupport'}[b.tier];
 const faction=b.faction.match(/\[\[(\w+) \(H7\)/)?.[1].toLowerCase();
 const vector=s=>s.split(',').map(x=>{let n=num(x.trim());if(n===null)throw Error('Invalid vector '+s);return n;});
 const attacks=vector(b.attack),defenses=vector(b.defense),health=vector(b.hp);
 if(![1,5].includes(attacks.length)||defenses.length!==5||health.length!==5)throw Error('Unexpected profile lengths');
 const profiles=Array.from({length:5},(_,i)=>({index:i+1,...(attacks.length===5?{attack:attacks[i]}:{}),defense:defenses[i],health:health[i]}));
 const support=c._key.endsWith('.healing.tent')||c._key.endsWith('.healing.sister')||c._key.endsWith('.runestone')||c._key.endsWith('.dreamwalker')?'Healing':c._key.endsWith('.mother.treant')?'Renewal':c._key.endsWith('.faceless')?'DeathCloak':c._key.endsWith('.namtaru')?'DarkTouch':null;
 if(support){
  // The Russian ability sections explicitly label effect amounts at levels 1–5.
  // Namtaru has a normal +1 bonus and a separately stated level-five +2 bonus.
  const effects=support==='DarkTouch'?[1,1,1,1,2]:[...rp.text.matchAll(/\*\s*\d+-й Уровень:\s*'''(\d+) ед\./g)].map(m=>+m[1]);
  if(effects.length!==5)throw Error('Invalid support progression '+c._key);
  profiles.forEach((r,i)=>r.effectAmount=effects[i]);
 }
 if(role!=='Support'){const ranges=b.damage.split(',').map(x=>x.trim().match(/^(\d+)-(\d+)$/));if(ranges.length!==5||ranges.some(x=>!x))throw Error('Invalid damage progression');profiles.forEach((r,i)=>{r.damageMin=+ranges[i][1];r.damageMax=+ranges[i][2];});}
 // Preserve the agreeing values; publish neither conflicting wiki value.
 if(c._key==='homm7.creature.ballista')profiles.slice(2).forEach(r=>delete r.defense);
 if(c._key==='homm7.creature.healing.sister')profiles.forEach(r=>delete r.defense);
 if(c._key==='homm7.creature.dreamwalker')delete profiles[4].effectAmount;
 const stats={profileOrder:'source-listed',profiles,...(support?{supportEffect:support}:{})};
 const row={_key:c._key,Faction_id:'homm7.faction.'+faction,Tier:null,CreatureKind:'Warfare',WarfareRole:role,Attack:attacks.length===1?attacks[0]:null,Defense:null,DamageMin:null,DamageMax:null,Health:null,Speed:0,Initiative:c._key==='homm7.creature.dreamwalker'?21:num(b.initiative),CombatSize:null,Shots:null,Mana:null,WeeklyGrowth:null,Movement:'Stationary',Recruitable:role!=='Siege',DoubleUpgrade:false,AlternativeUpgrade:false,WarfareStats:stats};
 add('CreatureHOMM7',row,{...evidence(p,'Creature infobox and warfare role','Source-listed progression; Russian level-1–5 tables corroborate ordering. Russian profiles explicitly say does not move; all seven siege profiles explicitly say not recruitable. Combat footprint is unspecified. Support amounts belong to the named effect, not ordinary attack damage. Conflicting Ballista profile 3–5 and Healing Sister defense values remain absent.'),crossCheck:{source:rp.url,revision:rp.revid,sections:'Creature stat block and Abilities'},...(c._key==='homm7.creature.dreamwalker'?{independentCrossCheck:{source:'https://www.heroes7.acidcave.net/creatures_stronghold.html',notes:'Initiative 21 agrees with the Russian wiki rather than English 100. Level-five healing is 300 here versus Russian 600, so its effectAmount remains absent.'}}:{})});
}
const recruitment=[['academy','Workshop','healing.tent'],['academy','Pyramidal craft','small.pyramid'],['dungeon','Chamber of Whispers','faceless'],['dungeon','Pillar of eyes','shadow.lurker'],['fortress','Rune designer','runestone'],['fortress','Armory','dwarven.ballista'],['haven','Blacksmith','ballista'],['haven','Convent of Elrath','healing.sister'],['necropolis','Namtaru nest','namtaru'],['stronghold','Dream lodge','dreamwalker'],['sylvan','Blacksmith','sylvan.ballista'],['sylvan','Garden of the Sacred Seed','mother.treant']];
for(const[faction,building,creature]of recruitment){
 const fk='homm7.faction.'+faction,detail=base.BuildingHOMM7.filter(d=>d.Faction_id===fk),b=base.Building.find(b=>b.Name.toLowerCase()===building.toLowerCase()&&detail.some(d=>d._key===b._key));if(!b)throw Error('No building '+faction+'/'+building);
 const p=pages.get('en:'+faction[0].toUpperCase()+faction.slice(1)+' (H7)');
 add('BuildingCreature',{_key:b._key+'.recruits.'+creature,Game_id:'homm7.game',Building_id:b._key,Creature_id:'homm7.creature.'+creature,Relation:'Recruits'},evidence(p,'Buildings / Basic / '+building,'The source explicitly says this building allows buying this unit. Fortress Ballistae maps to Dwarven ballista; Sister healers maps to Healing sister; Rune Stones maps to Runestone.'));
}
const resolution=JSON.parse(fs.readFileSync(`${root}/h67-resolution-enrichment.json`));
for(const change of resolution.changes){
 const action=patch.additions.find(action=>action.table===change.table&&action.row._key===change.key);
 if(!action||JSON.stringify(action.row[change.field])!==JSON.stringify(change.expected))throw Error('Resolution precondition differs for '+change.key);
 action.row[change.field]=change.value;action.evidence.resolution=change.evidence;
}
patch.resolution={date:'2026-10-14',priorCommit:resolution.baselineCommit,audit:'h67-resolution-enrichment.json'};
patch.additions.sort((a,b)=>a.table.localeCompare(b.table)||a.row._key.localeCompare(b.row._key));
fs.writeFileSync(`${root}/heroes6-7.patch.json`,JSON.stringify(patch,null,2)+'\n');
const counts=Object.fromEntries([...new Set(patch.additions.map(x=>x.table))].map(t=>[t,patch.additions.filter(x=>x.table===t).length]));
console.log(JSON.stringify({counts,fills:patch.fills.length,linksByGame:[6,7].map(n=>({game:n,links:patch.additions.filter(x=>x.table==='CreatureAbility'&&x.row.Game_id===`homm${n}.game`).length,creatures:new Set(patch.additions.filter(x=>x.table==='CreatureAbility'&&x.row.Game_id===`homm${n}.game`).map(x=>x.row.Creature_id)).size}))},null,2));
