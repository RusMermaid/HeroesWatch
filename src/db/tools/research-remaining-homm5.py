"""Build only the missing Heroes V factual catalogs from the 3.1 manual.

Input PDF/text and extracted chunks live in the OS temporary research directory.
No copyrighted descriptions or illustrations are copied into the data fragment.
"""
import json
import re
import tempfile
from collections import defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CACHE = Path(tempfile.gettempdir()) / 'heroeswatch-homm45-research'
SCHEMA = {t['name']: t for t in json.loads((ROOT/'schema/heroeswatch.schema.json').read_text())['tables']}
EXISTING = json.loads((ROOT/'data/heroeswatch.json').read_text(encoding='utf-8'))['tables']
if not (CACHE/'h5-chunks.json').exists() or not (CACHE/'homm5.txt').exists():
    from pypdf import PdfReader
    reader=PdfReader(CACHE/'homm5.pdf')
    if not (CACHE/'homm5.txt').exists():
        (CACHE/'homm5.txt').write_text('\n'.join(f'PAGE {i+1}\n'+p.extract_text() for i,p in enumerate(reader.pages)),encoding='utf-8')
    if not (CACHE/'h5-chunks.json').exists():
        extracted={}
        for page in list(range(105,143))+list(range(160,182))+list(range(183,202))+list(range(259,270)):
            chunks=[]
            reader.pages[page-1].extract_text(visitor_text=lambda t,cm,tm,f,s:chunks.append([round(tm[4],2),round(tm[5],2),f.get('/BaseFont','') if f else '',s,t.strip()]) if t.strip() else None)
            extracted[page]=chunks
        (CACHE/'h5-chunks.json').write_text(json.dumps(extracted),encoding='utf-8')
CHUNKS = json.loads((CACHE/'h5-chunks.json').read_text(encoding='utf-8'))
TABLES = {}

def slug(s):
    return re.sub('[^a-z0-9]+', '.', s.lower()).strip('.')

def row(t, key, **values):
    out = {'_key':key}
    for col in SCHEMA[t]['columns']:
        if col['primaryKey']:
            continue
        name=col['name']
        if name in values:
            out[name]=values.pop(name)
        elif col['nullable']:
            out[name]=None
        else:
            raise ValueError(f'Missing {t}.{name} for {key}')
    if values:
        raise ValueError((t,values))
    return out

def put(t,r):
    key=r['_key']
    if key in {x['_key'] for x in EXISTING.get(t,[])}:
        return key
    prior=next((x for x in TABLES.get(t,[]) if x['_key']==key),None)
    if prior:
        if r!=prior:
            raise ValueError(('Conflicting new row',t,key))
    else:
        TABLES.setdefault(t,[]).append(r)
    return key

def cat(t,name,release=None,**values):
    key=values.pop('_key',f'homm5.{t.lower()}.{slug(name)}')
    values.update(Name=name,Code=key.split(f'homm5.{t.lower()}.')[-1].replace('.','_').upper())
    if any(c['name']=='Game_id' for c in SCHEMA[t]['columns']):
        values['Game_id']='homm5.game'
    if any(c['name']=='IntroducedInExpansion_id' for c in SCHEMA[t]['columns']):
        values['IntroducedInExpansion_id']=f'homm5.expansion.{release}' if release else None
    put(t,row(t,key,**values))
    return key

def junction(t,key,**values):
    return put(t,row(t,f'homm5.{t.lower()}.{key}',Game_id='homm5.game',**values))

def clean(s):
    s=re.sub(r'\s+', ' ',s).strip()
    s=re.sub(r'\s+([,.])',r'\1',s)
    s=s.replace('Magic- proof','Magic-proof')
    return s

def chars(page):
    return CHUNKS[str(page)]

# Every stat table has seven base and fourteen upgrade columns; the neutral
# table has nine columns. Coordinate assignment preserves empty mana cells.
creatures=[]
for page in range(160,169):
    chunks=chars(page)
    headers=[c for c in chunks if c[3]==10 and c[4].endswith('Creatures') and c[1]>30]
    for header in headers:
        title=header[4]
        faction=None if title=='Neutral Creatures' else title.replace('Upgraded ','').replace(' Creatures','')
        count=9 if faction is None else 14 if title.startswith('Upgraded') else 7
        below=[c for c in chunks if c[1]<header[1] and c[1]>30]
        next_header=max([c[1] for c in headers if c[1]<header[1]]+[30])
        below=[c for c in below if c[1]>next_header]
        attack_label=next(c for c in below if c[4]=='Attack')
        attack_y=attack_label[1]
        attack_cells=sorted([c for c in below if abs(c[1]-attack_y)<1.2 and re.fullmatch(r'\d+',c[4])],key=lambda c:c[0])
        if len(attack_cells)!=count:
            raise ValueError(('Attack cells',page,title,len(attack_cells)))
        centers=[c[0]+len(c[4])*2.5 for c in attack_cells]
        step=(centers[-1]-centers[0])/(count-1)
        def column(c):
            return min(range(count),key=lambda i:abs(centers[i]-c[0]))
        def extract(y):
            cells=['']*count
            for c in sorted(below,key=lambda c:c[0]):
                if abs(c[1]-y)<1.4 and centers[0]-step/2<c[0]<centers[-1]+step/2:
                    cells[column(c)]=clean(cells[column(c)]+' '+c[4])
            return cells
        field={}
        for label in ['Attack','Defense','Damage','Hit Points','Speed','Initiative','Shots/Mana','# / Week','Power / Exp','Cost']:
            c=next(c for c in below if c[4]==label)
            field[label]=extract(c[1])
        ability_y=next(c[1] for c in below if c[4]=='Abilities')
        growth_y=next(c[1] for c in below if c[4]=='# / Week')
        names=['']*count
        abilities=['']*count
        for c in sorted(below,key=lambda c:(-c[1],c[0])):
            if not (centers[0]-step/2<c[0]<centers[-1]+step/2):
                continue
            i=column(c)
            if attack_y+5<c[1]<header[1]-5:
                names[i]=clean(names[i]+' '+c[4])
            if growth_y+2<c[1]<ability_y+2:
                abilities[i]=clean(abilities[i]+' '+c[4])
        for i,name in enumerate(names):
            stats={k:v[i] for k,v in field.items()}
            for k in ['Attack','Defense','Hit Points','Speed','Initiative','# / Week']:
                stats[k]=int(stats[k])
            stats['Damage']=list(map(int,re.findall(r'\d+',stats['Damage'])))
            stats['Power / Exp']=list(map(int,re.findall(r'\d+',stats['Power / Exp'])))
            if len(stats['Damage'])!=2 or len(stats['Power / Exp'])!=2:
                raise ValueError((page,name,stats))
            creatures.append(dict(name=name,faction=faction,tier=None if not faction else i//2+1 if count==14 else i+1,
                                  upgrade=0 if count!=14 else 1+i%2,stats=stats,abilities=abilities[i],page=page))

# An isolated coordinate may be nearer the adjacent column than the text's
# center. Known complete names disambiguate the original table headings.
name_fixes={'Crossbow- man':'Crossbowman','Spear- wielder':'Spearwielder',
            'Shield- guard':'Shieldguard','Gob.Witch- Doctor':'Goblin Witch-Doctor'}
for creature in creatures:
    creature['name']=name_fixes.get(creature['name'],creature['name'])
(CACHE/'remaining-h5-creatures.json').write_text(json.dumps(creatures,indent=2),encoding='utf-8')

# Creature catalog, numerical 3.1 statistics, recruitment costs and upgrades.
ability_names={slug(c[4]):c[4] for p in range(169,182) for c in chars(p) if 'Bold' in c[2] and c[3]==8}
for name in ability_names.values():
    key=cat('Ability',name,_key='homm5.ability.creature.'+slug(name))
    put('AbilityHOMM5',row('AbilityHOMM5',key,AbilityKind='Creature'))

for creature in creatures:
    name=creature['name']; stats=creature['stats']; faction=creature['faction']; upgrade=creature['upgrade']
    release='toe' if faction=='Stronghold' or upgrade==2 else 'hof' if faction=='Fortress' or name in ['Wolf','Mummy','Manticore'] else 'base'
    # Six Haven alternatives were already introduced as renegades in HoF.
    if faction=='Haven' and upgrade==2 and name!='Seraph':
        release='hof'
    key=cat('Creature',name,release)
    abilities=creature['abilities'].replace('Range Pen..','Range Penalty.').replace('Range Pen.,','Range Penalty,').replace('Imm. to Blind','Immune to Blind').replace('Crush. Blow','Crushing Blow').replace('Six- headed','Six-headed').replace('Evil- eye','Evil-eye')
    abilities=abilities.replace('Aura of Fire / Ice / Lightning Vulnerability','Aura of Fire Vulnerability, Aura of Ice Vulnerability, Aura of Lightning Vulnerability')
    names=[x.strip().rstrip('.') for x in abilities.split(',') if x.strip().rstrip('.')]
    mana=re.fullmatch(r'(\d+|-)\s*/\s*(\d+|-)',stats['Shots/Mana'])
    put('CreatureHOMM5',row('CreatureHOMM5',key,Faction_id=f'homm5.faction.{slug(faction)}' if faction else None,
        Tier=creature['tier'],CreatureKind='Town' if faction else 'Neutral',Attack=stats['Attack'],Defense=stats['Defense'],
        DamageMin=stats['Damage'][0],DamageMax=stats['Damage'][1],Health=stats['Hit Points'],Speed=stats['Speed'],
        Initiative=stats['Initiative'],CombatSize=2 if 'Large Creature' in names else 1,
        Shots=int(mana[1]) if mana and mana[1]!='-' else None,Mana=int(mana[2]) if mana and mana[2]!='-' else None,
        WeeklyGrowth=stats['# / Week'],Power=stats['Power / Exp'][0],Experience=stats['Power / Exp'][1],
        Movement='Flying' if 'Flyer' in names else 'Ground',Recruitable=True,DoubleUpgrade=False,AlternativeUpgrade=upgrade==2))
    cost=int(re.match(r'\d+',stats['Cost'])[0])
    junction('CreatureResourceCost',slug(name)+'.gold',Creature_id=key,Resource_id='resource.gold',Amount=cost)
    for ability in names:
        aid=slug(ability)
        if aid not in ability_names:
            raise ValueError(('Unrecognized creature ability',name,ability))
        junction('CreatureAbility',slug(name)+'.'+aid,Creature_id=key,Ability_id='homm5.ability.creature.'+aid)
    if faction and upgrade:
        base=next(c for c in creatures if c['faction']==faction and c['tier']==creature['tier'] and c['upgrade']==0)
        junction('CreatureUpgrade',slug(base['name'])+'.'+slug(name),BaseCreature_id='homm5.creature.'+slug(base['name']),UpgradedCreature_id=key)

# Town dwelling-to-creature references, from the same manual's building entries.
raw_text=(CACHE/'homm5.txt').read_text(encoding='utf-8')
page_text={int(n):s for n,s in re.findall(r'PAGE (\d+)\n(.*?)(?=\nPAGE |\Z)',raw_text,re.S)}
for building in EXISTING['Building']:
    if not building['_key'].startswith('homm5.') or building['Category']!='Dwelling':
        continue
    detail=next(x for x in EXISTING['BuildingHOMM5'] if x['_key']==building['_key'])
    faction=detail['Faction_id'].split('.')[-1]
    start_page={'academy':211,'dungeon':215,'fortress':219,'haven':223,'inferno':227,'necropolis':231,'stronghold':235,'sylvan':239}[faction]
    building_text='\n'.join(page_text[p] for p in range(start_page,start_page+4))
    # Entries give exact recruitment names. Only match inside this building's
    # paragraph, ending at the following Cost/Requires/title sequence.
    start=building_text.find('\n'+building['Name']+' - Dwelling Level ')
    if start<0:
        continue
    tail=building_text[start+len(building['Name'])+2:]
    paragraph=tail.split('Cost:',1)[0]
    for creature in creatures:
        if not creature['faction'] or slug(creature['faction'])!=faction or creature['tier']!=detail['DwellingTier']:
            continue
        if bool(creature['upgrade'])==('An upgrade of' in paragraph):
            junction('BuildingCreature',building['_key'].split('homm5.building.')[1]+'.'+slug(creature['name']),
                     Building_id=building['_key'],Creature_id='homm5.creature.'+slug(creature['name']),Relation='Recruits')

# Common skills and all named hero perks. Existing racial skills are preserved.
skill=None
perk_records=[]
for p in range(105,143):
    chunks=chars(p)
    for index,c in enumerate(chunks):
        if 'Bold' in c[2] and c[3]==10 and c[0]<100:
            skill=c[4].split(' (')[0]
            skill={'Training':'Counterstrike','Elemental Chains':'Irresistible Magic'}.get(skill,skill)
            kind='Shatter' if skill.startswith('Shatter') else 'Shout' if skill=='Shout' else 'Magic' if skill.endswith('Magic') and skill!='Irresistible Magic' else 'Racial' if p>=135 else 'Regular'
            key=cat('Skill',skill,'toe' if kind in ['Shatter','Shout'] else 'hof' if skill=='Runelore' else 'base')
            put('SkillHOMM5',row('SkillHOMM5',key,SkillKind=kind,Ruleset='TribesOfTheEast'))
        if 'Bold' not in c[2] or c[3]!=7 or c[0]!=112.19 or (re.match(r'(Basic|Advanced|Expert|Ultimate) ',c[4]) and c[4]!='Expert Trainer'):
            continue
        end=next((i for i in range(index+1,len(chunks)) if 'Bold' in chunks[i][2] and chunks[i][3] in [7,10]),len(chunks))
        body=' '.join(x[4] for x in chunks[index+1:end])
        perk_records.append((skill,c[4],body,p))
ultimate={'Arcane Omniscience','Nature\'s Luck','Absolute Rage','Rage of the Elements','Urgash\'s Call','Howl of Terror','Absolute Protection','Unstoppable Charge'}
for skill,name,body,p in perk_records:
    key=cat('Ability',name,_key='homm5.ability.hero.'+slug(name))
    kind='Ultimate' if name in ultimate else 'Racial' if p>=135 else 'HeroPerk'
    put('AbilityHOMM5',row('AbilityHOMM5',key,AbilityKind=kind))
    classes=re.findall(r'» (Barbarian|Demon Lord|Knight|Necromancer|Ranger|Runemage|Warlock|Wizard):',body)
    racial={'Artificer':'Wizard','Avenger':'Ranger','Blood Rage':'Barbarian','Irresistible Magic':'Warlock','Gating':'Demon Lord','Necromancy':'Necromancer','Runelore':'Runemage','Counterstrike':'Knight'}
    if skill in racial:
        classes=[racial[skill]]
    elif skill.startswith('Shatter') or skill=='Shout':
        classes=['Barbarian']
    elif not classes:
        classes=['Demon Lord','Knight','Necromancer','Ranger','Runemage','Warlock','Wizard']
        if not skill.endswith('Magic') and skill!='Sorcery':
            classes.append('Barbarian')
    for cls in sorted(set(classes)):
        junction('HeroClassAbility',slug(cls)+'.'+slug(skill)+'.'+slug(name),
                 HeroClass_id='homm5.heroclass.'+slug(cls),Skill_id='homm5.skill.'+slug(skill),Ability_id=key,
                 AvailabilityKind='Ultimate' if kind=='Ultimate' else 'Standard')

# Four learned combat schools, the special adventure school, and Runic Magic.
# Warcries have their own SpellKind and are not treated as a magic school.
school_by_page={183:'Adventure Magic',184:'Warcries',185:'Dark Magic',186:'Dark Magic',187:'Destructive Magic',188:'Destructive Magic',
                189:'Light Magic',190:'Light Magic',191:'Runic Magic',192:'Summoning Magic',193:'Summoning Magic'}
for name in dict.fromkeys(school_by_page.values()):
    if name!='Warcries':
        cat('MagicSchool',name)
level=None
spells=[]
for p in range(183,194):
    chunks=chars(p)
    for i,c in enumerate(chunks):
        if 'Bold' in c[2] and c[3]==10 and c[4].startswith('Level '):
            level=int(c[4].split()[1])
        if 'Bold' not in c[2] or c[3]!=8 or c[0]!=112.19:
            continue
        name={'Ralling Cry':'Rallying Cry','Stone spikes':'Stone Spikes'}.get(c[4],c[4])
        mana=next((int(n[4]) for n in chunks[i+1:i+4] if abs(n[1]-c[1])<0.01 and n[4].isdigit()),None)
        school=school_by_page[p]
        release='hof' if p==191 else 'toe' if p==184 or name in ['Sorrow','Vampirism','Deep Freeze','Regeneration','Divine Vengeance','Arcane Crystal','Blade Barrier','Summon Hive'] else 'hof' if name=='Firewall' else 'base'
        skind='Rune' if p==191 else 'Warcry' if p==184 else 'Normal'
        hero_level={'Vessel of Shalassa':1,'Summon Creatures':10,'Instant Travel':15,'Town Portal':20}.get(name)
        if p==184:
            hero_level={1:2,2:6,3:11}[level]
        key=cat('Spell',name,release)
        put('SpellHOMM5',row('SpellHOMM5',key,Level=level,Context='Adventure' if p==183 else 'Combat',SpellKind=skind,
            ManaCost=None if skind=='Rune' or name=='Summon Creatures' else mana,RequiredHeroLevel=hero_level))
        if skind!='Warcry':
            junction('SpellMagicSchool',slug(name)+'.'+slug(school),Spell_id=key,MagicSchool_id='homm5.magicschool.'+slug(school))
        spells.append((name,school,level,mana))
        # Mass versions are distinct castable spellbook entries unlocked by perks.
        end=next((j for j in range(i+1,len(chunks)) if 'Bold' in chunks[j][2] and chunks[j][3] in [8,10]),len(chunks))
        body=' '.join(x[4] for x in chunks[i+1:end])
        mass=re.search(r'adds (Mass [A-Za-z ]+?)(?:\.| \()',body)
        if mass:
            mass_name=mass[1]
            mk=cat('Spell',mass_name,release)
            put('SpellHOMM5',row('SpellHOMM5',mk,Level=level,Context='Combat',SpellKind='Normal',ManaCost=mana*2 if mana is not None else None))
            junction('SpellMagicSchool',slug(mass_name)+'.'+slug(school),Spell_id=mk,MagicSchool_id='homm5.magicschool.'+slug(school))

# Artifacts and their actual equipped sets (sets do not consume components).
sets=["Archer's Dream",'Armor of Dwarven Kings',"Death's Embrace","Lion's Spirit",'Power of Dragons','Runeforce',
      'Sar-Issus Regalia','Vestment of Enlightenment','Weapons of Might','Will of Urgash']
for name in sets:
    cat('ArtifactSetHOMM5',name,'toe')
artifacts=[]
for p in range(194,199):
    chunks=chars(p)
    for i,c in enumerate(chunks):
        if 'Bold' not in c[2] or c[3]!=8:
            continue
        n=chunks[i+1]
        m=re.fullmatch(r'(Minor|Major|Relic) - ([A-Za-z]+) - Cost: (\d+)',n[4])
        if not m:
            continue
        end=next((j for j in range(i+1,len(chunks)) if 'Bold' in chunks[j][2] and chunks[j][3]==8),len(chunks))
        body=' '.join(x[4] for x in chunks[i+1:end])
        setname=next((s for s in sets if s in body),None)
        slot={'Weapon':'RightHand','Shield':'LeftHand','Pocket':'Pocket','Boots':'Feet','Inventory':None,'Helm':'Head','Cuirass':'Torso','Cloak':'Shoulders','Ring':'Ring','Necklace':'Neck'}[m[2]]
        key=cat('Artifact',c[4])
        put('ArtifactHOMM5',row('ArtifactHOMM5',key,ArtifactSetHOMM5_id='homm5.artifactsethomm5.'+slug(setname) if setname else None,
            Class=m[1],Slot=slot,GoldValue=int(m[3]),Tradable=c[4]!='Tear of Asha'))
        artifacts.append(c[4])

# Functional adventure objects from all manual location sections. Existing
# recruitment dwellings are left untouched.
objects=[]
current_section=None
for p in range(259,270):
    for c in chars(p):
        if c[3]==10 and c[4] in ['Terrain Types and Effects','Adventure Map Locations','Battle Sites','Battle Sites on Sea','Dwellings','Mines','Treasures','Sea Treasures']:
            current_section=c[4]
        if 'Bold' not in c[2] or c[3]!=8 or round(c[0],2) not in [139.19,402.81] or current_section in ['Terrain Types and Effects','Dwellings']:
            continue
        name=c[4]
        if not re.match('[A-Za-z]',name):
            continue
        objects.append((name,current_section))
for name,section in dict.fromkeys(objects):
    if 'homm5.adventureobject.'+slug(name) in {r['_key'] for r in EXISTING['AdventureObject']}:
        continue
    category='Mine' if section=='Mines' else 'Reward' if section in ['Treasures','Sea Treasures','Battle Sites','Battle Sites on Sea'] else 'Teleport' if 'Monolith' in name or 'Subterranean Gate' in name or name=='Whirlpool' else 'Shrine' if 'Shrine' in name else 'Decoration' if name=='Inferno Town ruins' else 'Quest' if name in ['Border Guard','Keymaster Tent','Quest Guard','Border Gate','Seer Hut','Obelisk'] else 'Other'
    capture=section=='Mines' or name in ['Lighthouse','Garrison','Outpost','Shipyard']
    interaction='Capture' if capture else 'Pickup' if section in ['Treasures','Sea Treasures'] else 'Combat' if section in ['Battle Sites','Battle Sites on Sea'] else 'Enter' if category=='Teleport' else None if category=='Decoration' else 'Visit'
    key=cat('AdventureObject',name)
    put('AdventureObjectHOMM5',row('AdventureObjectHOMM5',key,Category=category,InteractionType=interaction,Capturable=capture))

# Additional editor/campaign objects documented in the full adventure-object
# list. The manual combines the two Cartographers under the same display name.
for name,category,interaction in [
    ('Soulstone','Reward','Visit'),('Water Cartographer','Other','Visit'),
    ('Border Guard','Quest','Enter'),("Keymaster's Tent",'Quest','Visit'),
    ("Biara's Citadel",'Quest','Enter'),("Demon Sovereign's Citadel",'Quest','Enter'),
    ('Haven Ruins','Decoration',None),("The King's Mausoleum",'Quest','Visit'),("Tieru's Dwelling",'Quest','Visit')]:
    key=cat('AdventureObject',name)
    put('AdventureObjectHOMM5',row('AdventureObjectHOMM5',key,Category=category,InteractionType=interaction,Capturable=False))

# Creature spellbooks: the mastery icons cannot be recovered from plain text,
# so only explicit spell identities and numerical mana costs are imported.
caster_text=page_text[304]+'\n'+page_text[305].split('Spellcasters from the Neutral faction')[0]
for match in re.finditer(r'» (?:Academy|Dungeon|Fortress|Haven|Inferno|Necropolis|Stronghold|Sylvan|Neutral): ([^\n]+?) \(\d+ Mana - Weekly Growth: \d+\)\n(.*?)(?=» |\Z)',caster_text,re.S):
    creature_name=match[1]
    for name,cost in re.findall(r'([A-Za-z][A-Za-z ]+)\n (\d+)',match[2]):
        name={'Stone spikes':'Stone Spikes'}.get(name,name)
        if any(r['Name']==name for r in TABLES['Spell']):
            junction('CreatureSpell',slug(creature_name)+'.'+slug(name),Creature_id='homm5.creature.'+slug(creature_name),
                     Spell_id='homm5.spell.'+slug(name),ManaCostOverride=int(cost))

# Actual set bonuses, using numeric parameters and short original descriptions.
set_bonuses=[
 ("Archer's Dream",2,None,{'ShooterAtbRecoveryReductionPercent':30}),
 ("Archer's Dream",2,'Ranger',{'HeroShootingAtbRecoveryReductionPercent':30}),
 ('Armor of Dwarven Kings',2,None,{'ArmyMagicProofPercent':40}),
 ('Armor of Dwarven Kings',4,None,{'OpeningBlessingsMastery':'Expert','OpeningBlessingsDurationTurns':10,'OpeningBlessings':'Endurance and Deflect Missile'}),
 ('Armor of Dwarven Kings',2,'Runemage',{'SpellPowerPercent':10,'MinimumSpellPowerBonus':1}),
 ("Death's Embrace",2,None,{'EnemySpeed':-1}),
 ("Death's Embrace",4,None,{'EnemyAttackPercentOnNegativeMorale':-20,'EnemyDefensePercentOnNegativeMorale':-20}),
 ("Death's Embrace",2,'Necromancer',{'BansheeHowlEnemyMorale':-2,'BansheeHowlEnemyLuck':-2,'BansheeHowlEnemyInitiativePercent':-20,'BansheeHowlAtbCostPercent':50}),
 ("Death's Embrace",4,'Necromancer',{'NecromancyCostPercent':-25}),
 ("Lion's Spirit",3,None,{'HeroAtbGainPercentOnPositiveMorale':10,'HeroAtbLossPercentOnNegativeMorale':10}),
 ("Lion's Spirit",2,'Knight',{'EnemyMoraleOnHeroAttack':-2}),
 ('Power of Dragons',2,None,{'AllPrimaryAttributes':1}),
 ('Power of Dragons',4,None,{'TierSevenAttack':5,'TierSevenDefense':5,'TierSevenHealth':20}),
 ('Power of Dragons',6,None,{'AllPrimaryAttributes':3}),
 ('Power of Dragons',8,None,{'DailyTierSevenCreatures':1}),
 ('Runeforce',2,None,{'AllPrimaryAttributes':1}),
 ('Runeforce',2,'Warlock',{'ElementalVisionEffectMultiplier':2}),
 ('Sar-Issus Regalia',2,None,{'ArmyCasterManaMultiplier':2,'ArmyCasterSpellPowerMultiplier':2}),
 ('Sar-Issus Regalia',4,None,{'HeroSpellAtbRecoveryReductionPercent':10}),
 ('Sar-Issus Regalia',2,'Wizard',{'HeroSpellAtbRecoveryReductionPercent':10}),
 ('Vestment of Enlightenment',2,None,{'ExperienceBonusPercent':15}),
 ('Weapons of Might',2,None,{'ArmyAttack':3,'ArmyHealth':2}),
 ('Weapons of Might',2,'Barbarian',{'HeroAttackAtbRecoveryReductionPercent':30}),
 ('Will of Urgash',2,None,{'HeroAttack':5}),
 ('Will of Urgash',2,'Demon Lord',{'GatingCreatureBonusPercent':25}),
]
for name,pieces,cls,effect in set_bonuses:
    put('ArtifactSetBonusHOMM5',row('ArtifactSetBonusHOMM5',f'homm5.artifactsetbonushomm5.{slug(name)}.{pieces}.{slug(cls) if cls else "all"}',
        ArtifactSetHOMM5_id='homm5.artifactsethomm5.'+slug(name),RequiredPieceCount=pieces,
        HeroClass_id='homm5.heroclass.'+slug(cls) if cls else None,Effect=effect))

# Release campaigns and their 60 ordered missions; campaign art and prose are
# deliberately not reproduced. Hero links reuse existing identities.
campaigns=[
 ('The Queen','base','Isabel','The Queen|Rebellion|The Siege|The Trap|The Fall of the King'),
 ('The Cultist','base','Agrael',"The Betrayal|The Promise|The Conquest|The Ship|Agrael's Decision"),
 ('The Necromancer','base','Markal','The Temptation|The Attack|The Invasion|The Regicide|The Lord of Heresh'),
 ('The Warlock','base','Raelag',"The Clanlord|The Expansion|The Cultists|The March|Raelag's Offer"),
 ('The Ranger','base','Findan','The Refugees|The Emerald Ones|The Defense|The Archipelago|The Vampire Lord'),
 ('The Mage','base','Zehir',"The Defiant Mage|The Liberation|The Triumvirate|The Alliance|Zehir's Hope"),
 ("Freyda's Dilemma",'hof','Freyda','Rebels|The Suspicion|Duncan|Negotiations|The Choice'),
 ("Wulfstan's Defiance",'hof','Wulfstan','The Border Zone|The Ambush|The Guerrillas|The Brothers|Laszlo'),
 ("Ylaya's Quest",'hof','Ylaya','The Spy|The Break|The Meeting|Dragons|The Decoupling'),
 ('Rage of the Tribes','toe','Quroq','A Murder of Crows'),
 ('The Will of Asha','toe','Arantir',"Last Soul Standing|The Grim Crusade|The Bull's Wake|Beasts and Bones|Heart of Darkness"),
 ('To Honor Our Fathers','toe','Gotai',"Collecting Skulls|One Khan, One Clan|Father Sky's Fury|Mother Earth's Wisdom|Hunting the Hunter"),
 ('Flying to the Rescue','toe','Zehir','Dark Ways and Deeds|Tearing the Veil|Summoning the Dragon|A Flamboyant Exit')
]
for name,release,hero,missions in campaigns:
    ck=cat('Campaign',name,Expansion_id='homm5.expansion.'+release)
    for order,mission in enumerate(missions.split('|'),1):
        mapkey=cat('Map',mission,release,_key='homm5.map.'+slug(name)+'.'+str(order))
        scenario=cat('Scenario',mission,release,_key='homm5.scenario.'+slug(name)+'.'+str(order),Map_id=mapkey)
        junction('CampaignScenario',slug(name)+'.'+str(order),Campaign_id=ck,Scenario_id=scenario,SortOrder=order)
    hero_row=next(x for x in EXISTING['Hero'] if x['_key'].startswith('homm5.') and x['Name']==hero)
    junction('CampaignHero',slug(name)+'.'+slug(hero),Campaign_id=ck,Hero_id=hero_row['_key'],IsCampaignHero=True,CampaignRole='Protagonist')
for campaign,hero in [('The Will of Asha','Ornella'),('To Honor Our Fathers','Kujin')]:
    hero_row=next(x for x in EXISTING['Hero'] if x['_key'].startswith('homm5.') and x['Name']==hero)
    junction('CampaignHero',slug(campaign)+'.'+slug(hero),Campaign_id='homm5.campaign.'+slug(campaign),Hero_id=hero_row['_key'],IsCampaignHero=True,CampaignRole='Protagonist')

if __name__=='__main__':
    (ROOT/'data/research/remaining-homm5.json').write_text(json.dumps({'tables':TABLES},indent=2,ensure_ascii=False)+'\n',encoding='utf-8')
    print(json.dumps({t:len(r) for t,r in TABLES.items()},indent=2))
