import fs from 'node:fs';
const root=new URL('../../',import.meta.url);
const catalog=JSON.parse(fs.readFileSync(new URL('data/heroeswatch.json',root)));
const count=table=>`(SELECT count(*)::text FROM heroes_watch."${table}")`;
const metrics=[
  ['Database','current_database()'],
  ['Database owner',"(SELECT pg_get_userbyid(datdba) FROM pg_database WHERE datname=current_database())"],
  ['Schema columns',"(SELECT count(*)::text FROM information_schema.columns WHERE table_schema='heroes_watch')"],
  ['Catalog rows',`(SELECT sum(n)::text FROM (${Object.keys(catalog.tables).map(table=>`SELECT count(*) AS n FROM heroes_watch."${table}"`).join('\nUNION ALL\n')}) counts)`],
  ['Heroes IV abilities',count('AbilityHOMM4')],
  ...[4,6,7].map(n=>[`Heroes ${n} creature ability links`,`(SELECT count(*)::text FROM heroes_watch."CreatureAbility" ca JOIN heroes_watch."Game" g USING ("Game_id") WHERE g."SeriesCode"='HOMM${n}')`]),
  ['Heroes VI creature details',count('CreatureHOMM6')],
  ['Heroes VI class details',count('HeroClassHOMM6')],
  ['Heroes VII warfare details',`(SELECT count(*)::text FROM heroes_watch."CreatureHOMM7" WHERE "CreatureKind"='Warfare')`],
  ['Heroes VII class details',count('HeroClassHOMM7')],
  ['Heroes V starting armies',`(SELECT count(*)::text FROM heroes_watch."HeroHOMM5" WHERE "StartingArmy" IS NOT NULL)`],
  ['Olden Era alternative attacks',`(SELECT count(*)::text FROM heroes_watch."AbilityHOMM8" WHERE "IsAlternativeAttack")`],
  ['Olden Era schools',count('MagicSchoolHOMM8')],
  ['Olden Era resources',count('ResourceHOMM8')],
  ['Olden Era Astrology',count('AstrologyHOMM8')],
  ['Olden Era map details',count('MapHOMM8')],
  ['Olden Era scenario details',count('ScenarioHOMM8')],
  ['Olden Era campaign details',count('CampaignHOMM8')],
];
const sql='-- Read-only October 14 research deployment summary.\nWITH metrics AS (\n'+metrics.map(([name,expression],index)=>`SELECT ${index+1} AS position, '${name}'::text AS metric, (${expression})::text AS value`).join('\nUNION ALL\n')+'\n) SELECT metric,value FROM metrics ORDER BY position;\n';
fs.writeFileSync(new URL('data/research-gaps.review.sql',root),sql);
console.log(`Wrote ${metrics.length} deployment metrics.`);
