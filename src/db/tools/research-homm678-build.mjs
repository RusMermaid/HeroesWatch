// Builds reviewed factual catalog fragments from the cached VI/VII wiki source.
import fs from 'node:fs';
const dir='.codex-tmp/research-homm678';
const outputDir='src/db/data/research';
const schema=JSON.parse(fs.readFileSync('src/db/schema/heroeswatch.schema.json'));
const safe=s=>s.replace(/[^a-zA-Z0-9]/g,'-');
const slug=s=>s.normalize('NFD').replace(/\p{M}/gu,'').toLowerCase().replace(/[^a-z0-9]+/g,'.').replace(/^\.|\.$/g,'');
const clean=s=>s.replace(/\[\[([^\]|]+)\|([^\]]+)\]\]/g,'$2').replace(/\[\[([^\]]+)\]\]/g,'$1').replace(/<[^>]+>/g,' ').replace(/'{2,}/g,'').replace(/&nbsp;/g,' ').trim();
const links=s=>[...s.matchAll(/\[\[([^\]|]+)(?:\|([^\]]+))?\]\]/g)].map(m=>({page:m[1],name:m[2]||m[1].replace(/ \([^)]*\)$/,'')}));
const read=p=>fs.readFileSync(`${dir}/.tmp-page-${safe(p)}.txt`,'utf8');
// Fan manual 0.921, Initial Stats, printed p.233; stats are per faction/archetype.
const initial6={Haven:[[1,3,1,1,2,1],[0,2,2,2,2,1]],Inferno:[[3,2,1,1,0,2],[2,1,2,2,0,2]],Necropolis:[[2,3,2,1,0,1],[1,2,3,2,0,1]],Sanctuary:[[2,2,1,2,1,1],[1,1,2,3,1,1]],Stronghold:[[4,2,0,1,1,1],[3,1,1,1,1,1]]};
// October 2015 GamerSky table, in Might/Defense/Magic/Spirit order.
// Conflicting Archon/Embalmer and unsupported expansion values are excluded.
const growth7=new Map(Object.entries({
 Vindicator:[35,30,25,10],Knight:[30,40,15,15],Paladin:[20,45,10,25],Inquisitor:[20,15,40,25],Priest:[10,20,35,35],Confessor:[5,30,25,40],
 Warmonger:[45,25,25,5],Barbarian:[40,35,15,10],Chieftain:[30,40,10,20],'Storm Caller':[30,10,40,20],Shaman:[20,15,35,30],'Earth Shaper':[15,25,25,35],
 Blademage:[35,25,30,10],Alchemist:[30,35,20,15],Sherif:[20,40,15,25],Battlemage:[20,10,45,25],Wizard:[10,15,40,35],Enchanter:[5,25,30,40],'Djinn Lord':[5,5,45,45],
 'Ebon Knight':[35,25,25,15],'Death Knight':[30,35,15,20],'Bone Guard':[20,40,10,30],Necromancer:[20,10,40,30],
 Avenger:[40,20,25,15],Ranger:[35,30,15,20],Warden:[25,35,10,30],Thornsower:[25,5,40,30],Mystic:[15,10,35,40],Starsinger:[10,20,25,45],
 'Shadow Slayer':[45,20,25,10],Darkblade:[40,30,15,15],Trickster:[30,35,10,25],'Dark Prophet':[30,5,40,25],Sorcerer:[20,10,35,35],'Shade Weaver':[15,20,25,40]
}));
function row(t,key,fields){return {_key:key,...Object.fromEntries(schema.tables.find(x=>x.name===t).columns.filter(c=>!c.primaryKey).map(c=>[c.name,null])),...fields};}
for(const g of [6,7]){
 const prefix=`homm${g}`,game=`${prefix}.game`,tables={},out=(t,r)=>(tables[t]??=[]).push(r);
 const catalog=(t,name,key,extra={})=>row(t,key,{Game_id:game,Code:key.split('.').slice(2).join('_').toUpperCase(),Name:name,...extra});
 const index=JSON.parse(fs.readFileSync(`${dir}/.tmp-index-${g}.json`));
 if(g===6&&!index.heroes.includes('Sandro (Ashan)'))index.heroes.push('Sandro (Ashan)');
 if(g===7&&!index.heroes.includes('Maahir'))index.heroes.push('Maahir');
 const factions=g===6?['Haven','Inferno','Necropolis','Sanctuary','Stronghold','Dungeon']:['Haven','Academy','Necropolis','Stronghold','Sylvan','Dungeon','Fortress'];
 const classes=new Map(),heroKnown=new Map(),unresolved=[];
 for(const faction of factions){
  const txt=fs.readFileSync(`${dir}/.tmp-${g}-${faction}.txt`,'utf8');
  const expansion=`${prefix}.expansion.${g===6&&faction==='Dungeon'?'sod':g===7&&faction==='Fortress'?'tbf':'base'}`;
  const cls=txt.match(/\|classes\s*=([^\n]+)/)?.[1]||'';
  for(const [i,c] of links(cls).entries())classes.set(c.page,{...c,faction,archetype:i<3?'Might':'Magic',focus:(g===6?['Blood','Neutral','Tears']:['Offense','Balanced','Defense'])[i%3],expansion});
  const body=txt.split('==Buildings==')[1]?.split('==Gallery==')[0];
  if(!body)throw Error('Missing buildings '+faction);
  const bs=[];let dwellingIndex=0;
  for(const m of body.matchAll(/^\|name(\d+)\s*=([^\n]+)\n/gm)){
   const name=clean(m[2]);
   if(!name||name.includes('{{'))throw Error('Unparsed building '+name);
   const chunk=body.slice(m.index,body.indexOf(`\n|name`,m.index+1)<0?undefined:body.indexOf(`\n|name`,m.index+1));
   const desc=chunk.match(new RegExp('\\|desc'+m[1]+'\\s*=([^\\n]+)'))?.[1]||'';
   const req=chunk.match(new RegExp('\\|req'+m[1]+'\\s*=([^\\n]+)'))?.[1]||'';
   const section=body.slice(0,m.index).match(/===+([^=]+)===+/g)?.at(-1)||'';
   const dwelling=/Unupgraded|Upgraded/i.test(section),growth=/Growth upgrade/i.test(section);
   const category=dwelling?'Dwelling':growth?'Horde':/^(Village hall|Town hall|City hall|Capitol)$/i.test(name)?'Hall':/fortification|artillery|moat/i.test(name)?'Fortification':/guild/i.test(name)?'MageGuild':/Tear of Asha/.test(req)?'Grail':/marketplace|Chaos crucible/i.test(name)?'Economy':'Special';
   const key=`${prefix}.building.${slug(faction)}.${slug(name)}`;
   const match=desc.match(/(Core|Elite|Champion) dwelling/i);
   let tier=match?match[1][0].toUpperCase()+match[1].slice(1).toLowerCase():null;
   if(g===6&&dwelling){const ordinal=dwellingIndex++%7;tier=ordinal<3?'Core':ordinal<6?'Elite':'Champion';}
   out('Building',catalog('Building',name,key,{Category:category,IntroducedInExpansion_id:expansion}));
   if(g===6)out('BuildingHOMM6',row('BuildingHOMM6',key,{Faction_id:`${prefix}.faction.${slug(faction)}`,TownLevelRequired:req.match(/Town level (\d+)/i)?+req.match(/Town level (\d+)/i)[1]:null,DwellingTier:tier,IsFactionUnique:category==='Special'&&!/Hall of Heroes|Hall of the Immortals|town portal/i.test(name),IsConvertible:true}));
   else out('BuildingHOMM7',row('BuildingHOMM7',key,{Faction_id:`${prefix}.faction.${slug(faction)}`,TownLevelRequired:req.match(/Town level (\d+)/i)?+req.match(/Town level (\d+)/i)[1]:null,DwellingTier:tier,MageGuildLevel:/guild.*level\s*(\d)/i.test(name)?+name.match(/guild.*level\s*(\d)/i)[1]:null,DwellingChoice:dwelling&&(/impossible to build/i.test(desc)||tier==='Champion')}));
   bs.push({name,key,req,section});
  }
  for(const b of bs){
   for(const r of bs.filter(r=>r!==b&&b.req.split(/<br\s*\/?\s*>|<hr\s*\/?\s*>/i).map(clean).includes(r.name))){
    out('BuildingRequirement',row('BuildingRequirement',`${b.key}.requires.${slug(r.name)}`,{Game_id:game,Building_id:b.key,RequiredBuilding_id:r.key}));
    if(/^=+Upgraded=+$/.test(b.section))out('BuildingUpgrade',row('BuildingUpgrade',`${b.key}.upgrade.${slug(r.name)}`,{Game_id:game,BaseBuilding_id:r.key,UpgradedBuilding_id:b.key}));
   }
  }
 }
 for(const p of index.classes){
  let c=classes.get(p),txt=read(p);
  if(!c){let faction=txt.match(/\[\[([^\]|]+) \(H7\)\|[^\]]+\]\] faction/);if(!faction)throw Error('Unknown class '+p);c={page:p,name:p,faction:faction[1],archetype:/is a might class/i.test(txt)?'Might':'Magic',focus:null,expansion:`${prefix}.expansion.${/Trial by Fire/.test(txt)?'tbf':'base'}`};classes.set(p,c);}
  c.key=`${prefix}.heroclass.${slug(c.name)}`;
  out('HeroClass',catalog('HeroClass',c.name,c.key,{Archetype:c.archetype,Description:`${c.faction} ${c.archetype.toLowerCase()} class${c.focus?`; ${c.focus.toLowerCase()} ${g===6?'reputation':'focus'}`:''}.`,IntroducedInExpansion_id:c.expansion}));
  const stats=initial6[c.faction]?.[c.archetype==='Might'?0:1];
  if(g===6&&stats){const base=[...classes.values()].find(b=>b.faction===c.faction&&b.archetype===c.archetype&&b.focus==='Neutral');out('HeroClassHOMM6',row('HeroClassHOMM6',c.key,{Faction_id:`${prefix}.faction.${slug(c.faction)}`,BaseHeroClass_id:c.focus==='Neutral'?null:`${prefix}.heroclass.${slug(base.name)}`,ReputationPath:c.focus,DefaultMightPower:stats[0],DefaultMightDefense:stats[1],DefaultMagicPower:stats[2],DefaultMagicDefense:stats[3],DefaultLeadership:stats[4],DefaultDestiny:stats[5]}));}
  else if(g===7&&growth7.has(c.name)&&!['Archon','Embalmer'].includes(c.name)){const v=growth7.get(c.name);out('HeroClassHOMM7',row('HeroClassHOMM7',c.key,{Faction_id:`${prefix}.faction.${slug(c.faction)}`,ClassFocus:c.focus,IsUniqueClass:c.name==='Djinn Lord'||c.name==='Hell Knight',MightGrowthPct:v[0],DefenseGrowthPct:v[1],MagicGrowthPct:v[2],SpiritGrowthPct:v[3]}));}
  else unresolved.push(`${c.name}: ${g===6?'required initial primary attributes':'required primary-attribute growth percentages'} not verified; optional detail row omitted.`);
  const known=txt.match(/==(?:Known|Notable)[^\n]*==([\s\S]*?)(?:\n==|\n{{H[67] class}})/i)?.[1]||'';
  for(const h of links(known)){const set=heroKnown.get(h.page)||new Set();set.add(c.key);heroKnown.set(h.page,set);}
 }
 for(const p of index.heroes){
  const txt=read(p); const classText=txt.match(/\|class\s*=([\s\S]*?)(?:\n\|\w|\n}})/)?.[1]||'';
  let candidates=links(classText).filter(c=>classes.has(c.page)).map(c=>classes.get(c.page).key);
  candidates=[...new Set(candidates.length?candidates:[...(heroKnown.get(p)||[])])];
  let heroClass=candidates.length===1?candidates[0]:null;
  if(candidates.length>1){const neutral=candidates.filter(k=>[...classes.values()].some(c=>c.key===k&&c.focus==='Neutral'));if(neutral.length===1)heroClass=neutral[0];}
  const name=p.replace(/ \([^)]*\)$/,'');
  const key=`${prefix}.hero.${slug(name)}`;
  let exp='base';
  if(g===6&&/Category:Shades of Darkness Dungeon/.test(txt))exp='sod';
  if(g===7&&/Category:Trial by Fire/.test(txt))exp='tbf';
  if(g===7&&['Genevieve Seymour','Pherlon','Dogwoggle'].includes(p))exp='ltoa';
  // Absence of a base-game appearance is necessary before claiming DLC introduction.
  if(g===6&&!/\{\{icon-H6\}\}/i.test(txt)){
   if(/Pirates of the Savage Sea/.test(txt))exp='potss';
   if(/Danse Macabre/.test(txt))exp='dm';
  }
  if(g===6&&p==='Sandro (Ashan)')exp='dm';
  out('Hero',catalog('Hero',name,key,{HeroClass_id:heroClass,IntroducedInExpansion_id:`${prefix}.expansion.${exp}`}));
  if(!heroClass)unresolved.push(`${name}: class differs by scenario or is not documented; HeroClass_id remains null.`);
  if(g===6)out('HeroHOMM6',row('HeroHOMM6',key,{Availability:/Category:Heroes VI campaign heroes/.test(txt)?'CampaignOnly':null}));
  // VII IsHallHero cannot be inferred safely from a character page; generic identity suffices.
 }
 if(g===6){
  const txt=fs.readFileSync(`${dir}/.tmp-List-of-adventure-map-structures-in-Heroes-VI.txt`,'utf8').split('== Dwellings and Forts ==')[1].split('\n== ')[0];
  for(const faction of factions){
   const section=txt.split(`=== ${faction} ===`)[1]?.split('\n=== ')[0];if(!section)throw Error('Missing dwellings '+faction);
   for(const m of section.matchAll(/^! align="center"\|\s*([^\n]+)/gm)){
    const name=clean(m[1]),fort=/Fort$/.test(name),key=`${prefix}.adventureobject.${slug(faction)}.${slug(name)}`;
    out('AdventureObject',catalog('AdventureObject',name,key,{Description:`${faction} ${fort?'area-control fort':'external creature dwelling'}.`,IntroducedInExpansion_id:`${prefix}.expansion.${faction==='Dungeon'?'sod':'base'}`}));
    out('AdventureObjectHOMM6',row('AdventureObjectHOMM6',key,{Category:fort?'Fort':'Dwelling',InteractionType:'Capture',VisitRule:'Repeatable',Capturable:true,Convertible:true,ProvidesAreaControl:fort}));
   }
  }
 }
 if(g===7)for(const faction of factions)for(const tier of ['Core','Elite','Champion']){
  const key=`homm7.adventureobject.${slug(faction)}.${tier.toLowerCase()}.dwelling`;
  out('AdventureObject',catalog('AdventureObject',`${faction} ${tier.toLowerCase()} dwelling`,key,{Description:`Editorial catalog label for the ${faction} ${tier.toLowerCase()} external dwelling; exact English in-game title awaits localization verification.`,IntroducedInExpansion_id:`homm7.expansion.${faction==='Fortress'?'tbf':'base'}`}));
  out('AdventureObjectHOMM7',row('AdventureObjectHOMM7',key,{Category:'Dwelling',InteractionType:'Capture',VisitRule:'Repeatable',Capturable:true,IsDestructible:false,IsControlPoint:false}));
 }
 for(const t of Object.keys(tables)){
  const seen=new Set();for(const r of tables[t]){if(seen.has(r._key))throw Error(`Duplicate ${t} ${r._key}`);seen.add(r._key);}
  tables[t].sort((a,b)=>a._key.localeCompare(b._key));
 }
 fs.writeFileSync(`${outputDir}/homm${g}-catalog.json`,JSON.stringify({tables},null,2)+'\n');
 fs.writeFileSync(`${dir}/.tmp-unresolved-${g}.json`,JSON.stringify(unresolved,null,2));
 console.log(g,Object.fromEntries(Object.entries(tables).map(([k,v])=>[k,v.length])), 'unresolved',unresolved.length);
}
