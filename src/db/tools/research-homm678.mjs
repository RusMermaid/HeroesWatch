// Research aid: fetch factual wiki tables for the VI/VII catalog fragments.
// Temporary wikitext stays in .tmp files and is not a distributable dataset.
import fs from 'node:fs/promises';
const dir = '.codex-tmp/research-homm678';
await fs.mkdir(dir, {recursive:true});
const api = 'https://mightandmagic.fandom.com/api.php';
const safe = s => s.replace(/[^a-zA-Z0-9]/g, '-');
async function get(params) {
  const r = await fetch(`${api}?${new URLSearchParams({...params,format:'json'})}`);
  if (!r.ok) throw Error(`${r.status}: ${r.url}`);
  return r.json();
}
async function category(name, seen = new Set()) {
  if (seen.has(name)) return [];
  seen.add(name);
  const j = await get({action:'query',list:'categorymembers',cmtitle:name,cmlimit:'500'});
  const names=[];
  for(const p of j.query.categorymembers) {
    if(p.ns===14) names.push(...await category(p.title,seen));
    else if(p.ns===0) names.push(p.title);
  }
  return [...new Set(names)];
}
async function fetchPages(titles) {
  for(let start=0;start<titles.length;start+=40) {
    const j=await get({action:'query',prop:'revisions',rvprop:'content',rvslots:'main',titles:titles.slice(start,start+40).join('|')});
    for(const p of Object.values(j.query.pages)) if(p.revisions) await fs.writeFile(`${dir}/.tmp-page-${safe(p.title)}.txt`,p.revisions[0].slots.main['*']);
  }
}
for(const [g,roman] of [[6,'VI'],[7,'VII']]) {
  const heroes=await category(`Category:Heroes ${roman} heroes`);
  const classes=await category(`Category:Heroes ${roman} classes`);
  await fs.writeFile(`${dir}/.tmp-index-${g}.json`,JSON.stringify({heroes,classes},null,2));
  await fetchPages([...heroes,...classes,...(g===6?['Sandro (Ashan)']:['Maahir'])]);
  const factions=g===6?['Haven','Inferno','Necropolis','Sanctuary','Stronghold','Dungeon']:['Haven','Academy','Necropolis','Stronghold','Sylvan','Dungeon','Fortress'];
  for(const faction of factions){
    const page=`${faction} (H${g})`,j=await get({action:'parse',page,prop:'wikitext'});
    await fs.writeFile(`${dir}/.tmp-${g}-${faction}.txt`,j.parse.wikitext['*']);
  }
  if(g===6){const page='List of adventure map structures in Heroes VI',j=await get({action:'parse',page,prop:'wikitext'});await fs.writeFile(`${dir}/.tmp-${safe(page)}.txt`,j.parse.wikitext['*']);}
  console.log(g,{heroes:heroes.length,classes:classes.length});
}
