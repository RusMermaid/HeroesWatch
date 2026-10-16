# Heroes III classes, heroes and town buildings

Reviewed 2026-09-29 for classic Restoration of Erathia, Armageddon's Blade,
and Shadow of Death / Complete. This adds 2,964 rows to the cumulative catalog.
It complements [magic](homm3-magic.sources.md), [world objects and artifacts](homm3-world.sources.md),
[terrain](homm3-terrain.sources.md), and the earlier [creatures](homm3-creatures.sources.md).

| Table or relationship | Added rows |
|---|---:|
| HeroClass / HeroClassHOMM3 | 18 / 18 |
| Hero / HeroHOMM3 | 156 / 156 |
| HeroSkill | 291 |
| GameResource (wood and ore) | 2 |
| Building / BuildingHOMM3 | 318 / 318 |
| BuildingResourceCost | 894 |
| BuildingCreature | 315 |
| BuildingRequirement | 326 |
| BuildingUpgrade | 152 |

## Evidence and normalization

The primary evidence is the user's installed classic `H3bitmap.lod` and
`H3ab_bmp.lod` archives, read without altering the installation. `HCTRAITS.TXT`
supplies all 18 class starting attributes, the two primary-growth bands and
secondary-skill weights. `HOTRAITS.TXT` supplies the 156 native hero templates.
The names and class assignments agree with the wiki roster after whitespace
and display-alias normalization. `Building.txt` supplies the classic resource
prices, with `BldgNeut.txt` and `BldgSpec.txt` as name references.

The [hero roster](https://heroes.thelazy.net/index.php/List_of_heroes),
[class reference](https://heroes.thelazy.net/index.php/Hero_class), and the nine
town pages ([Castle](https://heroes.thelazy.net/index.php/Castle),
[Rampart](https://heroes.thelazy.net/index.php/Rampart),
[Tower](https://heroes.thelazy.net/index.php/Tower),
[Inferno](https://heroes.thelazy.net/index.php/Inferno),
[Necropolis](https://heroes.thelazy.net/index.php/Necropolis),
[Dungeon](https://heroes.thelazy.net/index.php/Dungeon),
[Stronghold](https://heroes.thelazy.net/index.php/Stronghold),
[Fortress](https://heroes.thelazy.net/index.php/Fortress),
[Conflux](https://heroes.thelazy.net/index.php/Conflux)) corroborate classes,
specialties, starting skills/spells, and building names/recruitment.
The Shadow of Death branch of `swh` wiki templates is selected explicitly;
HotA and other unofficial content are excluded.

All 318 prices were checked against the native resource table. Five wiki
table discrepancies are corrected by that primary evidence:

| Building | Stored classic price |
|---|---|
| Rampart Centaur Stables | 500 gold, 10 wood |
| Inferno Upgraded Hall of Sins | 1,000 gold, 5 mercury |
| Necropolis Upgraded Estate | 2,000 gold, 5 wood, 10 crystal, 10 gems |
| Necropolis Upgraded Hall of Darkness | 3,000 gold, 5 wood, 5 ore, 2 of each rare resource |
| Necropolis Dragon Vault | 10,000 gold, 5 wood, 5 ore, 5 of each rare resource |

Village Hall is automatic, so the engine's internal one-gold placeholder is
not presented as a purchase price. Grail structures also have no resource-price
row. Names normalize the source spellings Birthing Pools/Birthing Pool and
Aurora Borealias/Aurora Borealis to the English catalog name.

Classic building prerequisites and functional upgrade edges are cross-checked
with [VCMI's original building library](https://github.com/vcmi/vcmi/blob/develop/config/buildingsLibrary.json)
and the nine [original faction definitions](https://github.com/vcmi/vcmi/tree/develop/config/factions).
Those definitions supply typed edges only; no engine source code, assets or
mod-specific entities are included. Functional horde/unique-building upgrades
are retained in addition to the 63 creature-dwelling upgrades.

## Coverage and identity choices

Town building counts are Castle 35, Rampart 36, Tower 36, Inferno 36,
Necropolis 36, Dungeon 36, Stronghold 34, Fortress 34 and Conflux 35.
Each town has two classes and seven base plus seven upgraded creature dwellings.
All recruitment links reference the existing 126 creature identities.

Lord Haart's Knight and Death Knight are distinct native templates and receive
different codes. The roster comprises 144 standard heroes, eleven campaign-only
templates, and the legacy Knight Lord Haart as map-only in Complete. Campaign
reskins and custom names do not create duplicate template rows. Conflux and
Armageddon's Blade additions carry their expansion FK; previously introduced
identities are not duplicated for Shadow of Death.

Every class, hero and building detail reuses its generic parent's `_key`.
Skills, faction membership, starting spells, costs, prerequisites, upgrades and
recruitment use the existing FK columns or junctions. Numeric probability maps
contain readable skill labels and weights, not hidden physical database IDs.
Optional full biographies and unverified mechanics remain null. The schema,
architecture and generated migration are unchanged.
