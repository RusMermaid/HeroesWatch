"""Build IV/V catalog fragments after running research-homm45.py.

Only factual catalog labels, classifications and verified numbers are retained.
See data/homm4-catalog.sources.md and data/homm5-catalog.sources.md.
"""
import json
from pathlib import Path
import re
import tempfile

ROOT = Path(__file__).resolve().parents[1]
CACHE = Path(tempfile.gettempdir()) / 'heroeswatch-homm45-research'
SCHEMA = {t['name']: t for t in json.loads((ROOT/'schema/heroeswatch.schema.json').read_text())['tables']}
OUT = ROOT/'data/research'
OUT.mkdir(exist_ok=True)

def slug(s):
    return re.sub(r'[^a-z0-9]+', '.', s.lower()).strip('.')

def row(t, key, **values):
    result = {'_key': key}
    for c in SCHEMA[t]['columns']:
        if c['primaryKey']:
            continue
        if c['name'] in values:
            result[c['name']] = values.pop(c['name'])
        elif c['nullable']:
            result[c['name']] = None
        else:
            raise ValueError(f'Missing {t}.{c["name"]}')
    assert not values, (t, values)
    return result

def catalog(t, game, name, key=None, release='base', **values):
    key = key or f'homm{game}.{t.lower()}.{slug(name)}'
    values.update(Game_id=f'homm{game}.game', Code=key.split(f'homm{game}.{t.lower()}.')[-1].replace('.','_').upper(), Name=name)
    if any(c['name']=='IntroducedInExpansion_id' for c in SCHEMA[t]['columns']):
        values['IntroducedInExpansion_id'] = f'homm{game}.expansion.{release}' if release else None
    return row(t,key,**values)

def add(tables,t,item):
    assert item['_key'] not in {r['_key'] for r in tables.get(t,[])}, (t,item['_key'])
    tables.setdefault(t,[]).append(item)

h4={}
starting = {
 'Knight':('haven','Might'),'Priest':('haven','Magic'),
 'Lord':('academy','Might'),'Mage':('academy','Magic'),
 'Death Knight':('necropolis','Might'),'Necromancer':('necropolis','Magic'),
 'Thief':('asylum','Might'),'Sorcerer':('asylum','Magic'),
 'Archer':('preserve','Might'),'Druid':('preserve','Magic'),
 'Barbarian':('stronghold','Might')}
advanced = 'Archmage|Assassin|Bard|Battle Mage|Beast Lord|Beastmaster|Cardinal|Crusader|Dark Lord|Dark Priest|Demonologist|Enchanter|Field Marshal|Fire Diviner|Fireguard|General|Guildmaster|Heretic|Illusionist|Lich|Lord Commander|Monk|Ninja|Paladin|Prophet|Pyromancer|Ranger|Reaver|Seer|Shadow Mage|Summoner|Warden|Warlock|Warlord|Witch King|Wizard|Wizard King'.split('|')
for name in list(starting)+advanced:
    r=catalog('HeroClass',4,name,Archetype=starting[name][1] if name in starting else None)
    add(h4,'HeroClass',r)
    add(h4,'HeroClassHOMM4',row('HeroClassHOMM4',r['_key'], StartingFaction_id=f'homm4.faction.{starting[name][0]}' if name in starting else None,
        ClassTier='Starting' if name in starting else 'Archmage' if name=='Archmage' else 'Advanced'))

# Faction hero rosters cross-checked against the class/faction reference tables.
rosters={
'Knight': 'Araja|Archimemnon|Sir Christian|Dallas|Dalt|Equila|Frini|Gail|Julia|Laine|Lysander|Marcius|Mardigo|Mierna|Mullich|Nathaniel|Olwa|Orrin|Oyssin|Rex Mundi|Sigrid|Sir Kentaine|Sir Worton|Sorsha|Tamara|Thera|Tyris|Valoryn|Verdish|Zambu',
'Priest':'Adelaide|Alita Eventide|Bakrus|Bloomberg|Caitlin|Corita|Desette|Dorine|Ingham|Isabeau|Jerwall|Karth|Kathleen|Lemmar|Leslie|Maureen|Michael|Mirlanda|Nanette|Nevon|Pirvian|Proetho|Rion|Sanya|Vallia|Virgil|Winifred',
'Lord':'Alem|Annavanta|Aycora|Danika|Davius|Fafner|Fynelda|Grum|Hally|Hedegraus|Jubal|Iona|Merrox|Neela|Nobblenot|Oaryn|Paulus|Piquedram|Petula|Rissa|Segwen|Sharah|Teddor|Tharj Orcsplitter|Ufretin|Verno',
'Mage':'Aenain|Aine|Astral|Brendemar|Bohb|Brissa|Calyphona|Cyra|Daremyth|Emilia Nighthaven|Gavin Magnus|Genevieve Seymour|Grindan|Grunkie|Gurvilin|Malcom|Melody|Minasli|Mudgeon|Mysterio the Magnificent|Olivaster|Pherlon|Qubar|Raven|Redwara|Solmyr ibn Wali Barad|Suzieque|Sylas Zanj|Tina|Theodorus|Urnaka',
'Thief':'Aidan|Ajit|Andria|Calistar|Captain Swift|Dace|Erica Fade|Flaren|Flaym|Gretchin|Gruezak|Gundross|Hafir|Hoogula|Jael|Kardd|Kineta|Lorelei|Madmarik|Nazibar|Octavia|Pete Girly|Rufus|Runagark|Sizz|Tacitia|Valynne|Tawni Balfour',
'Sorcerer':'Aathea|Ajwar|Atella|Charzir|Cyrca|Darkstorm|Helice|Iboz|Isa|Jeddite|Kaspar|Kozuss|Maddox|Mastero|Mayweda|Mered|Nefafareen|Norzok|Pythia|Raona|Ritzil|Scorage|Spazz Maticus|Sephinroth|Uvodd|Xyron|Yorpix|Yoru',
'Death Knight':'Aglion|Arkenvoss|Calh|Charna|Docata|Fiona|Gargareen|Grok|Harkenraz|Jarvis|Malustar|Moander|Luna|Oddrema|Panur|Rahjuu|Reeva|Shriek|Straker|Suraze|Tamika|Varduum|Vilexica|Winsela|Xerxon|Yott',
'Necromancer':'Aislinn|Archilus|Ash|Ayden|Baenefa|Baron Von Tarkin|Castrata|Damala|Draezerak|Endan|Felina|Gauldoth Half-Dead|Hastner|Hexx|Hsine|Jessika|Kalibarr|Kurtos|Lamentia|Masqua|Mezizto|Norticus|Paskovich|Rab|Sandro|Sark|Thessa|Vidomina|Yxia',
'Archer':'Anium|Avanine|Blackdog|Callis|Enathrae|Erensar|Erutan Revol|Fahtrim|Gillion|Gramin|Gwedmyr|Ignatius|Ilia|Ivor|Jenova|Kamiana|Kyrre|Lindette|Lord Harke|Mephala|Merlith|Neska|Pyral|Ryland|Shaera|Shyn|Snowjay|Theritos|Trinni',
'Druid':'Aeris|Agraynel|Aleta|Arebell|Braebar|Brook|Coronius|Derden|Eleece|Elleshar|Elwin|Farnivon|Gathran|Gem|Gue|Iscandel|Kaliki|Labetha|Lowell|Melodia|Oris|Regina|Saleena|Sannah|Tonwen|Vianne|Yesterfox',
'Barbarian':'Abegga|Bofmog|Bron|Colwa|Crag Hack|Dogwoggle|Drenka|Ferret|Hagnar|Jadne|Kel|Khorrun|Krellion|Lanya|Mongo|Nef|Oroon|Ranella|Shiva|Tazar|Toadeater|Trome|Vix|Waerjak|Wegg|Wolfric|Yog|Yutena',
'Demonologist':'Hexis'}
tgs={'Alita Eventide','Bohb','Kozuss','Agraynel','Dogwoggle','Hexis'}
wow={'Baron Von Tarkin','Mysterio the Magnificent','Erutan Revol','Mongo','Spazz Maticus'}
class_overrides={'Alita Eventide':'Dark Priest','Bohb':'Archmage','Kozuss':'Wizard','Agraynel':'Bard'}
for hero_class,names in rosters.items():
    for name in names.split('|'):
        add(h4,'Hero',catalog('Hero',4,name,HeroClass_id=f'homm4.heroclass.{slug(class_overrides.get(name,hero_class))}', release='tgs' if name in tgs else 'wow' if name in wow else 'base'))

factions4={'life':'haven','order':'academy','death':'necropolis','chaos':'asylum','nature':'preserve','might':'stronghold'}
for alignment,items in json.loads((CACHE/'h4-buildings.json').read_text()).items():
    dwelling_index=0
    faction=factions4[alignment]
    for item in items:
        name=item['name']
        is_dwelling=item['section']=='Creature Dwellings'
        is_grail=item['section']=='Grail Building'
        level=re.search(r'level (\d)',name)
        cat='Dwelling' if is_dwelling else 'Grail' if is_grail else 'Hall' if name in ['Village Hall','Town Hall','City Hall'] else 'Fortification' if name in ['Fort','Citadel','Castle'] else 'MageGuild' if level else 'Special'
        r=catalog('Building',4,name,key=f'homm4.building.{faction}.{slug(name)}',Category=cat)
        add(h4,'Building',r)
        add(h4,'BuildingHOMM4',row('BuildingHOMM4',r['_key'],Faction_id=f'homm4.faction.{faction}',
             Level=dwelling_index//2+1 if is_dwelling else int(level[1]) if level else None,
             IsDwelling=is_dwelling or name=='Creature Portal',IsGrail=is_grail,RequiresWater=name=='Shipyard',DwellingChoice=item['choice']))
        if is_dwelling:
            dwelling_index+=1
            object_name='Halfling Burrow' if name=='Halfling Burrows' else name
            obj=catalog('AdventureObject',4,object_name,Description=f'Adventure-map recruitment dwelling associated with {faction.title()}.')
            add(h4,'AdventureObject',obj)
            add(h4,'AdventureObjectHOMM4',row('AdventureObjectHOMM4',obj['_key'],Category='Dwelling'))

external4={
 'haven':'Hovel|Siege Workshop',
 'academy':'Ward of Sorcery',
 'asylum':"Warren|Pirate's Cove|Pillar of Eyes|Troll Cave|Goblin Armory",
 'preserve':'Magic Rainbow|Wine Keg|Air Portal|Earth Portal|Fire Portal|Water Portal|Hothouse|Mantis Nest|Gargantuan Dell',
 'necropolis':"Desecrated Grave|Parapet|Embalmer's Lab|Ice Gate|Dark Knight's Sanctum",
 'stronghold':'Beast Pen'}
wow_dwellings={'Siege Workshop','Ward of Sorcery','Goblin Armory','Gargantuan Dell',"Dark Knight's Sanctum",'Beast Pen'}
for faction,names in external4.items():
    for name in names.split('|'):
        r=catalog('AdventureObject',4,name,release='wow' if name in wow_dwellings else 'base',Description=f'Adventure-map recruitment dwelling associated with {faction.title()}.')
        add(h4,'AdventureObject',r)
        add(h4,'AdventureObjectHOMM4',row('AdventureObjectHOMM4',r['_key'],Category='Dwelling'))

h5={}
add(h5,'Game',row('Game','homm5.game',SeriesCode='HOMM5',DisplayOrder=5,Name='Heroes of Might and Magic V'))
for code,name,kind in [('base','Heroes of Might and Magic V','BaseGame'),('hof','Hammers of Fate','Expansion'),('toe','Tribes of the East','Expansion')]:
    add(h5,'Expansion',row('Expansion',f'homm5.expansion.{code}',Game_id='homm5.game',Code=code.upper(),Name=name,Kind=kind))

# Initial attributes from manual pp.11,17,25,31,44,51,58,64; growth from p.293.
classes5={
 'Academy':('Wizard','Magic','Artificer','Light',[0,0,2,3],[10,15,30,45]),
 'Dungeon':('Warlock','Magic','Irresistible Magic','Dark',[1,0,3,1],[30,10,45,15]),
 'Fortress':('Runemage','Magic','Runelore','Light',[0,1,2,2],[20,30,30,20]),
 'Haven':('Knight','Might','Counterstrike','Light',[1,2,1,1],[30,45,10,15]),
 'Inferno':('Demon Lord','Might','Gating','Dark',[2,0,1,2],[45,10,15,30]),
 'Necropolis':('Necromancer','Magic','Necromancy','Dark',[0,1,3,1],[10,30,45,15]),
 'Stronghold':('Barbarian','Might','Blood Rage','Dark',[3,0,0,1],[45,35,5,15]),
 'Sylvan':('Ranger','Might','Avenger','Light',[0,2,1,2],[15,45,10,30])}
def release5(faction):
    return 'hof' if faction=='Fortress' else 'toe' if faction=='Stronghold' else 'base'
for faction,(cls,arch,skill,alignment,stats,growth) in classes5.items():
    release=release5(faction)
    fac=catalog('Faction',5,faction,release=release)
    add(h5,'Faction',fac)
    sk=catalog('Skill',5,skill,release=release)
    add(h5,'Skill',sk)
    add(h5,'SkillHOMM5',row('SkillHOMM5',sk['_key'],SkillKind='Racial',Ruleset='TribesOfTheEast'))
    add(h5,'FactionHOMM5',row('FactionHOMM5',fac['_key'],Alignment=alignment,RacialSkill_id=sk['_key']))
    cl=catalog('HeroClass',5,cls,release=release,Archetype=arch)
    add(h5,'HeroClass',cl)
    values=dict(zip(['DefaultStartingAttack','DefaultStartingDefense','DefaultStartingSpellPower','DefaultStartingKnowledge'],stats))
    values.update(zip(['AttackGrowthPct','DefenseGrowthPct','SpellPowerGrowthPct','KnowledgeGrowthPct'],growth))
    add(h5,'HeroClassHOMM5',row('HeroClassHOMM5',cl['_key'],Faction_id=fac['_key'],RacialSkill_id=sk['_key'],**values))

extracted=json.loads((CACHE/'h5-extracted.json').read_text())
hero_by_key={}
for item in extracted['heroes']:
    key=(item['faction'],item['name'])
    previous=hero_by_key.get(key)
    if previous and not previous['campaign']:
        continue
    hero_by_key[key]=item
hof_heroes={'Duncan','Freyda','Ylaya','Andreas','Lorenzo','Valeria','Thralsai','Giovanni','Guarg'}
toe_heroes={'Arantir','Agbeth','Ranleth'}
for (faction,name),item in hero_by_key.items():
    # The same character can have distinct playable class forms (e.g. Nicolai).
    key=f'homm5.hero.{slug(faction)}.{slug(name)}'
    release=release5(faction)
    if name in hof_heroes: release='hof'
    if name in toe_heroes: release='toe'
    if name=='Ornella': release='hof' if faction=='Haven' else 'toe'
    if name in {'Benedikt','Bertrand','Gabrielle','Orlando'}: release=None
    r=catalog('Hero',5,name,key=key,release=release,HeroClass_id=f'homm5.heroclass.{slug(classes5[faction][0])}')
    add(h5,'Hero',r)
    add(h5,'HeroHOMM5',row('HeroHOMM5',r['_key'],Availability=None if item['campaign'] else 'Standard',SpecialtyName=item['specialty']))

# Additional named scenario actors documented by the faction roster references.
extra_heroes5={
 'Academy':'Amin|Dgum',
 'Dungeon':'Ferigl|Ohtar|Segref',
 'Haven':'Ghost|Giar|Glen|Saint Isabel|Stephan',
 'Inferno':'Erasial|Gamor|Kraal',
 'Stronghold':'Batal|Dulgan|Gork|Mangu|Toulain'}
for faction,names in extra_heroes5.items():
    for name in names.split('|'):
        r=catalog('Hero',5,name,key=f'homm5.hero.{slug(faction)}.{slug(name)}',release='toe' if faction=='Stronghold' else None,HeroClass_id=f'homm5.heroclass.{slug(classes5[faction][0])}')
        add(h5,'Hero',r)
        add(h5,'HeroHOMM5',row('HeroHOMM5',r['_key']))

# Hero owns a named character identity, not a campaign-specific stat template.
# Where official playable forms use several classes the one-class FK stays null.
alias_notes={
 'Agrael':'Demon Lord roster identity of the character later known as Raelag.',
 'Raelag':'Warlock roster identity of the character previously known as Agrael.',
 'Biara':'Demon Lord roster identity; also appears in disguise as Shadya and Saint Isabel.',
 'Shadya':'Warlock roster identity used by Biara as a disguise.',
 'Saint Isabel':'Knight roster identity used by Biara while impersonating Isabel.'}
hero_details={r['_key']:r for r in h5['HeroHOMM5']}
groups={}
for hero in h5['Hero']:
    name=hero['Name']
    groups.setdefault(name,[]).append(hero)
h5['Hero']=[]
h5['HeroHOMM5']=[]
for name,variants in groups.items():
    preferred=next((v for v in variants if v['Name']==name),variants[0])
    details=[hero_details[v['_key']] for v in variants]
    hero=dict(preferred); detail=dict(hero_details[preferred['_key']])
    hero['_key']=detail['_key']=f'homm5.hero.{slug(name)}'
    hero['Code']=slug(name).replace('.','_').upper()
    if name in alias_notes: hero['Description']=alias_notes[name]
    if len({v['HeroClass_id'] for v in variants})>1:
        hero['HeroClass_id']=None
        forms=', '.join(sorted({v['Name'] for v in variants}))
        hero['Description']=f'Playable forms use more than one hero class. Source names: {forms}.'
    if len({d['SpecialtyName'] for d in details})>1:
        detail['SpecialtyName']=None
    releases=[v['IntroducedInExpansion_id'] for v in variants if v['IntroducedInExpansion_id']]
    if releases:
        hero['IntroducedInExpansion_id']=min(releases,key=lambda x:['base','hof','toe'].index(x.rsplit('.',1)[1]))
    add(h5,'Hero',hero)
    add(h5,'HeroHOMM5',detail)

numbers={'one':1,'two':2,'three':3,'four':4,'five':5}
for item in extracted['buildings']:
    name=item['name']; faction=item['faction']
    magic=re.fullmatch('Magic Guild level (one|two|three|four|five)',name)
    cat='Dwelling' if item['dwellingTier'] else 'Grail' if item['grail'] else 'MageGuild' if magic else 'Hall' if name in ['Village Hall','Town Hall','City Hall','Capitol'] else 'Fortification' if name in ['Fort','Citadel','Castle'] else 'Economy' if name in ['Marketplace','Resource Silo'] else 'Special'
    r=catalog('Building',5,name,key=f'homm5.building.{slug(faction)}.{slug(name)}',release=release5(faction),Category=cat)
    add(h5,'Building',r)
    add(h5,'BuildingHOMM5',row('BuildingHOMM5',r['_key'],Faction_id=f'homm5.faction.{slug(faction)}',TownLevelRequired=item['townLevel'],DwellingTier=item['dwellingTier'],MageGuildLevel=numbers[magic[1]] if magic else None))

for index,name in enumerate(extracted['dwellings']):
    faction=None if index<2 else ['Academy','Dungeon','Fortress','Haven','Inferno','Necropolis','Stronghold','Sylvan'][(index-2)//4]
    r=catalog('AdventureObject',5,name,release=release5(faction),Description=f'Adventure-map recruitment dwelling associated with {faction}.' if faction else 'Adventure-map recruitment site.')
    add(h5,'AdventureObject',r)
    add(h5,'AdventureObjectHOMM5',row('AdventureObjectHOMM5',r['_key'],Category='Dwelling',InteractionType='Capture' if faction else 'Visit',Capturable=bool(faction)))

for game,tables in [(4,h4),(5,h5)]:
    for records in tables.values(): records.sort(key=lambda r:r['_key'])
    (OUT/f'homm{game}-catalog.json').write_text(json.dumps({'tables':dict(sorted(tables.items()))},indent=2,ensure_ascii=False)+'\n',encoding='utf-8')
    print(game,{t:len(rows) for t,rows in tables.items()})
