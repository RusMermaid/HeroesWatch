# Olden Era released faction catalog (repository HOMM8 band)

Research date: 2026-09-29. Fragment: `research/homm8-catalog.json`.

## Release and primary source

[The official Steam product page](https://store.steampowered.com/app/3105440/Heroes_of_Might__Magic_Olden_Era/)
confirms an Early Access release on 2026-04-30. HOMM8 is the repository's
architecture band; the published game is **Heroes of Might and Magic: Olden
Era**, not an officially numbered Heroes VIII.

The main source is the user's installed, released **Steam build 25061458**,
read from its `Core.zip`. The archive was extracted into an ignored temporary
research folder; no installed files were edited and no raw game archive,
translations, biographies, or artwork are committed. The stored release
description records the build and research date.

Source paths inside Core.zip:

- `DB/fractions/*.json`: six available factions, native terrain, signature
  resources, and faction-law presence.
- `DB/biomes_info.json`: native biome/faction mapping.
- `DB/heroes/{humans,necros,nature,demons,unfrozen,dungeon}/*.json`: the 108
  standard heroes, faction/class type, primary attributes, growth weights,
  starting army bounds, and skill references.
- `DB/heroes_skills/skills_by_level_tables/*.json`: ordinary skill-offer
  weights, translated into skill-name/weight text for the schema's declared
  SkillWeights field. Source engine IDs are not embedded in that text.
- `DB/heroes_skills/skills/skills.json`: the six faction-skill identities.
- `DB/heroes_specializations/specializations_*.json`: specialization identity
  for every standard hero.
- `DB/objects_logic/cities/*_city.json`: every faction town building level,
  resource cost, prerequisite, recruitment relation, and passive income.
- `DB/objects_logic/hires/barracks.json`: operative external-dwelling logic,
  including the 42 faction dwellings and 15 neutral dwellings.
- `Lang/english/texts/*.json`: English names only. Internal keys are resolved
  before catalog insertion; long translated descriptions are not reproduced.

The [publisher-hosted wiki's game-file guide](https://wiki.hoodedhorse.com/Heroes_of_Might_and_Magic_Olden_Era/Help:Game_Files)
documents Core.zip and its DB/Lang structure. Its
[faction overview](https://wiki.hoodedhorse.com/Heroes_of_Might_and_Magic_Olden_Era/Factions),
[hero roster](https://wiki.hoodedhorse.com/Heroes_of_Might_and_Magic_Olden_Era/Heroes),
and [native-terrain rules](https://wiki.hoodedhorse.com/Heroes_of_Might_and_Magic_Olden_Era/Units)
corroborate the six names, 108 standard heroes, 12 classes, and +1 initiative
on native terrain. The released faction **Schism** is used; earlier preview
labels do not become separate factions.

## Counts

| Catalog or relation | Rows |
|---|---:|
| Game / base release | 1 / 1 |
| Faction / FactionHOMM8 | 6 / 6 |
| Terrain / faction Skill | 6 / 6 |
| New Resource / GameResource | 4 / 8 |
| HeroClass / HeroClassHOMM8 | 12 / 12 |
| Hero / HeroHOMM8 | 108 / 108 |
| Hero specialization Ability identities | 108 |
| Creature identities used by recruitment and armies | 126 |
| Building / BuildingHOMM8 | 206 / 206 |
| BuildingResourceCost | 623 |
| BuildingRequirement | 180 |
| BuildingUpgrade | 88 |
| BuildingCreature | 168 |
| AdventureObject / AdventureObjectHOMM8 | 57 / 57 |

The six factions are Temple, Necropolis, Grove, Hive, Schism, and Dungeon.
Each has two classes, nine standard heroes per class, and seven external
faction dwellings. All 206 town levels come directly from the released town
definitions. Ordinary building upgrades and creature-recruitment relationships
are FK-backed; no source relationship arrays are copied into JSONB.

## Scope and schema limits

- This covers the complete **standard faction hero roster**, town building
  levels, and operative external-dwelling collection in the identified build.
  It excludes campaign/tutorial hero variants, custom-map scripted heroes,
  unreleased campaign acts, demo folders, and test/TODO definitions. File
  presence by itself was not treated as proof of released playable content.
- The two decorative neutral dwelling objects that have no operative hire
  entries are excluded. No interactive recruitment behavior is asserted for
  them merely because an English label exists.
- Primary-attribute class weights describe the initial growth band. Later
  level-ups use the source's 25/25/25/25 band, recorded in the class description
  because this schema has only one scalar weight per attribute.
- SkillWeights describes the normal basic-skill offer pool. Special offers
  at particular levels are not flattened into this pool.
- StartingSkill_id stores the first starting skill in the source (the faction
  skill). The schema has one slot; additional starting skills are not hidden
  in JSONB. Starting spell slots are left null in this faction-focused batch.
- Specializations are first-class Ability identities. Their optional details
  and effects are not invented; compound passive/active definitions require
  a separate mechanics pass.
- Creature dependency identities permit real recruitment and army FKs. This
  batch does not claim full creature combat-stat coverage.
- Building HasChoice reflects optional building effects. Where there are
  three economic choices, the two nullable choice-building FK slots remain
  null: those effects are neither two buildings nor a two-option choice.
  Passive income fields store only the unconditional source bonuses.
- AdventureObjectHOMM8 has no faction or creature FK. Its dwelling catalog
  therefore records category and behavior, while town recruitment uses the
  existing BuildingCreature relation. No substitute relationship list is
  stored inside ScriptDefinition or Effect.

## Reproduction and validation

`src/db/tools/research-homm678-olden.mjs` reads an extracted Core.zip directory
and regenerates this fragment. It reads the semantic schema and cumulative
resource identities, adds only missing shared resources, and fails on missing
English names, inconsistent class weights, unknown resources, or unresolved
building prerequisites. It does not apply data to PostgreSQL.

The fragment passed `src/db/tools/validate.mjs` after merging into a temporary
copy of the cumulative bundle with the VI/VII fragments. Independent count
checks confirm six factions, 12 classes, 108 standard heroes, 206 building
levels, 42 faction dwellings, and 15 operative neutral dwellings.
