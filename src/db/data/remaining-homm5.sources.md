# Heroes V remaining catalogs

Research date: 2026-09-29. This additive batch supplies the categories that
were missing after the Heroes V faction, class, hero, town and dwelling batch.
Existing rows are preserved. The gameplay baseline is **Tribes of the East
3.1**, incorporating the base game and Hammers of Fate.

## Added content

| Content | New rows |
|---|---:|
| Creatures with numerical game details | 177 |
| Creature abilities | 167 |
| Hero perks, racial abilities and ultimates | 180 |
| Common, magic, shatter and shout skills | 17 |
| Magic schools | 6 |
| Spells, runes and warcries | 80 |
| Artifacts | 92 |
| Artifact sets / set bonuses | 10 / 25 |
| Adventure object types | 116 |
| Campaigns | 13 |
| Campaign mission maps / scenarios | 60 / 60 |

The fragment contains **3,866 rows** including shared-key details and
junctions. The creature roster contains 21 creatures for each of the eight
factions, plus nine neutral creatures. Every town creature has its base or
alternative upgrade status, and the batch adds 112 actual upgrade edges,
168 town dwelling recruitment links, 581 creature ability links, 60 creature
spellbook links and 177 gold recruitment costs.

Hero perks have 787 class/skill availability links. The eight existing racial
skills remain unchanged, bringing the skill catalog to 25. The 80 spell
entries comprise 52 ordinary spells, 12 mass versions, 10 runes and six
warcries. There are 74 school links: warcries retain `SpellKind=Warcry` and
are not presented as a magic school. The schools are Dark, Destructive,
Light, Summoning, Adventure and Runic Magic.

The adventure objects supplement the 34 existing recruitment dwellings for
150 catalog entries. Different artwork variants and key colors are not
separate object types. The two cartographers are distinct functional types.
Campaign coverage is six base campaigns, three Hammers of Fate campaigns,
and four Tribes of the East campaigns including the one-mission prologue.
Every mission has an ordered campaign junction. Fifteen protagonist links
reuse the existing heroes, including Ornella and Kujin.

## Sources

- [Heroes V manual, Tribes of the East 3.1 edition](https://h5.heroes.net.pl/uploaded/download/other/Heroes5-Manual-en-3-1.pdf),
  by Stephane Fidanza, Valera Koltsov, Paolo Angelo Sossi and the international
  Heroes community, with Ubisoft and Nival support. The foreword identifies
  the contributors and the developer support.
  - Printed pp. 105–142: common skills, racial skills and all named perks.
  - pp. 160–168: full base, upgrade, alternative upgrade and neutral creature
    tables; attack, defense, damage, health, speed, initiative, ammunition,
    mana, growth, power, experience and recruitment gold.
  - pp. 169–181: the creature ability catalog.
  - pp. 182–193: schools, spells, runes, warcries, levels, mana and mass
    versions. Page 182 explicitly distinguishes warcries from magic.
  - pp. 194–198: 92 artifact types, classes, equipment slots and gold values.
  - pp. 199–201: ten sets, their members and all 25 general/class bonuses.
  - pp. 211–242: existing town dwelling names, tiers and recruitment choices.
  - pp. 259–269: functional adventure locations, battle sites, mines and
    treasures. Page 260 has two same-named Cartographer entries for land and
    sea maps; this batch names the second one Water Cartographer.
  - pp. 304–305: creature spellbooks and numerical mana costs.
- [Heroes V adventure structures](https://mightandmagic.fandom.com/wiki/List_of_adventure_map_structures_in_Heroes_V):
  additional Soulstone, Water Cartographer, Border Guard, Keymaster's Tent
  and named campaign structures. Inferno Ruins is represented by the
  manual's existing name, Inferno Town ruins.
- [Campaign and mission index](https://w.atwiki.jp/homm/pages/68.html):
  all base and expansion campaign sequences.
- [The Break](https://mightandmagic.fandom.com/wiki/The_Break) and
  [The Decoupling](https://mightandmagic.fandom.com/wiki/The_Decoupling):
  the campaign navigation tables establish the Hammers of Fate names and
  order, and cross-reference the base and Tribes of the East campaigns.
- [Summoning the Dragon](https://mightandmagic.fandom.com/wiki/Summoning_the_Dragon)
  and [A Flamboyant Exit](https://mightandmagic.fandom.com/wiki/A_Flamboyant_Exit):
  the English mission names and their places in Flying to the Rescue.
- [Tribes of the East walkthrough contents](https://www.nexto.pl/upload/virtualo/gryonline/2c685d9c400ff7e6157942eb016028f7e6c396ec/free/2c685d9c400ff7e6157942eb016028f7e6c396ec.pdf):
  confirms Collecting Skulls, correcting Collecting Bones in the Japanese
  index, and the singular Summoning the Dragon.

Only catalog labels, classifications, numerical facts and newly written
structured parameters are included. The source PDF, artwork and descriptive
game prose are not included in the repository.

## Mapping and remaining field limits

- All relations use schema foreign keys with stable import keys. Generic
  and Heroes V detail records share the same `_key`.
- Statistics are the final official 3.1 ruleset, not separate historical
  snapshots of every patch. Renamed or rebalanced pre-3.1 forms are not
  duplicated as additional creatures. Dynamically scaled summons and war
  machines are outside the fixed town/neutral creature roster; no invented
  fixed statistics are supplied for them.
- `CombatSize` is the footprint side length: 1 for ordinary units and 2 for
  large units. `Movement=Flying` follows the manual's Flyer ability, including
  units whose traversal animation resembles teleportation.
- Blank shots/mana cells remain null. Neutral tier values are null because
  the neutral table does not state a tier. Required numerical creature
  fields are all sourced; none are fabricated.
- Gold recruitment costs are explicit. The additional rare-resource icons
  are not encoded because text extraction alone does not identify them.
- Perk availability links connect each ability to its documented skill and
  applicable classes. The complete prerequisite graph and mastery thresholds
  are not encoded; those optional fields remain null. Common perks without
  a class restriction apply to eligible classes; Barbarians use Shatter/Shout
  instead of the regular magic schools/Sorcery.
- Artifact sets use `ArtifactHOMM5.ArtifactSetHOMM5_id`; they are equipped
  sets, so no `ArtifactComponent` assembly rows are invented. Thirty-three
  member artifacts reference their sets. Most individual artifact effects,
  general skill effects and spell mastery formulas remain nullable; the set
  bonuses contain original structured numerical descriptions.
- Summon Creatures has a variable mana cost of one per creature, so its
  scalar `ManaCost` remains null. Rune costs consume resources, not mana;
  their scalar mana costs remain null. Creature spell mastery icons are not
  transcribed from text, so `CreatureSpell.Mastery` stays null.
- Introduction releases for artifacts and most map objects remain null
  unless established. Campaign mission dimensions, scenario scripts and
  objectives remain null rather than using estimates.
- The manual's PDF line breaks are removed from Crossbowman, Spearwielder,
  Shieldguard and Goblin Witch-Doctor. Rallying Cry corrects the manual's
  Ralling Cry typo. Its other source spelling conventions are retained.
- No test suite, database verification, PostgreSQL write, Git commit or
  GitHub publication was performed by this research batch, as requested.

## Reproduction

Run `research-homm45.py` to cache the source PDF, then
`research-remaining-homm5.py` with Python and pypdf. The latter creates its
temporary extraction cache when needed and writes only
`data/research/remaining-homm5.json`. It excludes keys already present in
the cumulative catalog. The top-level integration task merges the fragment
and handles database application and delivery.
