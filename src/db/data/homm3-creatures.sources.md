# Heroes III town creatures: sources and mapping

Research date: 2026-09-12. Cumulative content: [heroeswatch.json](heroeswatch.json).
This batch covers all 126 creatures in Castle, Tower, Rampart, Inferno,
Necropolis, Dungeon, Stronghold, Fortress, and Conflux: seven base creatures
and seven upgrades per faction.

## Ruleset and release provenance

The values describe classic Shadow of Death / Heroes III Complete mechanics
with Armageddon's Blade content enabled, matching the existing faction batch.
Introduction provenance records when the creature first appeared, separately
from the ruleset used for its current statistics.

The four basic Air, Water, Fire, and Earth Elementals existed as neutral
creatures in Restoration of Erathia. The original
[RoE manual, page 116, transcribed by the wiki](https://heroes.thelazy.net/index.php/Restoration_of_Erathia_Manual_Page_116)
lists them. They became Conflux units in Armageddon's Blade, as also explained
in the [neutral-creature reference](https://heroes.thelazy.net/index.php/Neutral_creature).
They therefore retain ROE introduction while their detail rows use their
Conflux faction and current town levels.

The other ten Conflux creatures were introduced by Armageddon's Blade.
Its manual describes Conflux creatures on
[page 14](https://heroes.thelazy.net/index.php/Armageddon%27s_Blade_Manual_Page_14),
and [page 16](https://heroes.thelazy.net/index.php/Armageddon%27s_Blade_Manual_Page_16).
The resulting introduction counts are 116 ROE and 10 AB. Shadow of Death
supplies the selected mechanics without introducing another town lineup.
Non-town creatures and mod additions are outside this nine-faction batch.

## Research and normalization

The wiki's [creature overview](https://heroes.thelazy.net/index.php/List_of_creatures)
provides the roster and numeric table. Each pair page below supplies an
additional check of combat stats, recruitment, upgrades, and battlefield size.
These are community-maintained references; no installed game files were read.

The overview and pair pages mix `onlysod` and `onlyhota` variants. The entry
selects the classic `onlysod` values and excludes `onlyhota` content.
Examples that matter here include Monk AI value 485, Efreet Sultan AI value
1848, Psychic/Magic Elemental gold costs 750/800, Firebird/Phoenix growth 2/2,
gold costs 1500/2000, and AI values 4547/6721.

Three pair infoboxes disagree with the overview. Their AI values are resolved
using the overview, the dedicated
[AI/Fight Value table](https://heroes.thelazy.net/index.php/AI_Value), and the
classic [Tribute to Strategists reference, PDF pages 24-25](https://heroes3wog.net/download/%255BManual%255D%2520Tribute%2520to%2520Strategists.pdf):

| Creature | Entered AIValue | Conflicting pair-infobox value |
|---|---:|---:|
| Stone Golem | 250 | 260 |
| Hobgoblin | 78 | 68 |
| Cyclops King | 1443 | 1433 |

Other numerical fields agree between the overview and pair infoboxes after
removing building-bonus and double-attack annotations. Damage is the range
for one attack; a displayed `x2` is not part of `DamageMax`. Growth is the
base weekly dwelling production before Citadel, Castle, horde buildings,
Grail, or calendar effects.

`Size` counts occupied battlefield hexes: 81 creatures occupy one hex and
45 occupy two. Angel occupies one, while Archangel occupies two. Movement
uses the declared enum: Ground, Flying, or Teleporting. Both Devil forms
teleport. A creature with no ranged attack has `Shots: 0`; shooter values
are their full ammunition capacity.

Recruitment costs buy one creature. They are not upgrade-price differences.
Angels and Archangels include the Shadow of Death gem costs: the
[Angel/Archangel reference](https://heroes.thelazy.net/index.php/Angel_and_Archangel)
explicitly notes that these gems were absent in ROE/AB mechanics.

## Creature pairs and individual references

Each link opens the shared reference for both forms in that row.

| Faction | Level | Base creature / source | Upgrade |
|---|---:|---|---|
| Castle | 1 | [Pikeman](https://heroes.thelazy.net/index.php/Pikeman_and_Halberdier) | Halberdier |
| Castle | 2 | [Archer](https://heroes.thelazy.net/index.php/Archer_and_Marksman) | Marksman |
| Castle | 3 | [Griffin](https://heroes.thelazy.net/index.php/Griffin_and_Royal_Griffin) | Royal Griffin |
| Castle | 4 | [Swordsman](https://heroes.thelazy.net/index.php/Swordsman_and_Crusader) | Crusader |
| Castle | 5 | [Monk](https://heroes.thelazy.net/index.php/Monk_and_Zealot) | Zealot |
| Castle | 6 | [Cavalier](https://heroes.thelazy.net/index.php/Cavalier_and_Champion) | Champion |
| Castle | 7 | [Angel](https://heroes.thelazy.net/index.php/Angel_and_Archangel) | Archangel |
| Tower | 1 | [Gremlin](https://heroes.thelazy.net/index.php/Gremlin_and_Master_Gremlin) | Master Gremlin |
| Tower | 2 | [Stone Gargoyle](https://heroes.thelazy.net/index.php/Stone_Gargoyle_and_Obsidian_Gargoyle) | Obsidian Gargoyle |
| Tower | 3 | [Stone Golem](https://heroes.thelazy.net/index.php/Stone_Golem_and_Iron_Golem) | Iron Golem |
| Tower | 4 | [Mage](https://heroes.thelazy.net/index.php/Mage_and_Arch_Mage) | Arch Mage |
| Tower | 5 | [Genie](https://heroes.thelazy.net/index.php/Genie_and_Master_Genie) | Master Genie |
| Tower | 6 | [Naga](https://heroes.thelazy.net/index.php/Naga_and_Naga_Queen) | Naga Queen |
| Tower | 7 | [Giant](https://heroes.thelazy.net/index.php/Giant_and_Titan) | Titan |
| Rampart | 1 | [Centaur](https://heroes.thelazy.net/index.php/Centaur_and_Centaur_Captain) | Centaur Captain |
| Rampart | 2 | [Dwarf](https://heroes.thelazy.net/index.php/Dwarf_and_Battle_Dwarf) | Battle Dwarf |
| Rampart | 3 | [Wood Elf](https://heroes.thelazy.net/index.php/Wood_Elf_and_Grand_Elf) | Grand Elf |
| Rampart | 4 | [Pegasus](https://heroes.thelazy.net/index.php/Pegasus_and_Silver_Pegasus) | Silver Pegasus |
| Rampart | 5 | [Dendroid Guard](https://heroes.thelazy.net/index.php/Dendroid_Guard_and_Dendroid_Soldier) | Dendroid Soldier |
| Rampart | 6 | [Unicorn](https://heroes.thelazy.net/index.php/Unicorn_and_War_Unicorn) | War Unicorn |
| Rampart | 7 | [Green Dragon](https://heroes.thelazy.net/index.php/Green_Dragon_and_Gold_Dragon) | Gold Dragon |
| Inferno | 1 | [Imp](https://heroes.thelazy.net/index.php/Imp_and_Familiar) | Familiar |
| Inferno | 2 | [Gog](https://heroes.thelazy.net/index.php/Gog_and_Magog) | Magog |
| Inferno | 3 | [Hell Hound](https://heroes.thelazy.net/index.php/Hell_Hound_and_Cerberus) | Cerberus |
| Inferno | 4 | [Demon](https://heroes.thelazy.net/index.php/Demon_and_Horned_Demon) | Horned Demon |
| Inferno | 5 | [Pit Fiend](https://heroes.thelazy.net/index.php/Pit_Fiend_and_Pit_Lord) | Pit Lord |
| Inferno | 6 | [Efreeti](https://heroes.thelazy.net/index.php/Efreeti_and_Efreet_Sultan) | Efreet Sultan |
| Inferno | 7 | [Devil](https://heroes.thelazy.net/index.php/Devil_and_Arch_Devil) | Arch Devil |
| Necropolis | 1 | [Skeleton](https://heroes.thelazy.net/index.php/Skeleton_and_Skeleton_Warrior) | Skeleton Warrior |
| Necropolis | 2 | [Walking Dead](https://heroes.thelazy.net/index.php/Walking_Dead_and_Zombie) | Zombie |
| Necropolis | 3 | [Wight](https://heroes.thelazy.net/index.php/Wight_and_Wraith) | Wraith |
| Necropolis | 4 | [Vampire](https://heroes.thelazy.net/index.php/Vampire_and_Vampire_Lord) | Vampire Lord |
| Necropolis | 5 | [Lich](https://heroes.thelazy.net/index.php/Lich_and_Power_Lich) | Power Lich |
| Necropolis | 6 | [Black Knight](https://heroes.thelazy.net/index.php/Black_Knight_and_Dread_Knight) | Dread Knight |
| Necropolis | 7 | [Bone Dragon](https://heroes.thelazy.net/index.php/Bone_Dragon_and_Ghost_Dragon) | Ghost Dragon |
| Dungeon | 1 | [Troglodyte](https://heroes.thelazy.net/index.php/Troglodyte_and_Infernal_Troglodyte) | Infernal Troglodyte |
| Dungeon | 2 | [Harpy](https://heroes.thelazy.net/index.php/Harpy_and_Harpy_Hag) | Harpy Hag |
| Dungeon | 3 | [Beholder](https://heroes.thelazy.net/index.php/Beholder_and_Evil_Eye) | Evil Eye |
| Dungeon | 4 | [Medusa](https://heroes.thelazy.net/index.php/Medusa_and_Medusa_Queen) | Medusa Queen |
| Dungeon | 5 | [Minotaur](https://heroes.thelazy.net/index.php/Minotaur_and_Minotaur_King) | Minotaur King |
| Dungeon | 6 | [Manticore](https://heroes.thelazy.net/index.php/Manticore_and_Scorpicore) | Scorpicore |
| Dungeon | 7 | [Red Dragon](https://heroes.thelazy.net/index.php/Red_Dragon_and_Black_Dragon) | Black Dragon |
| Stronghold | 1 | [Goblin](https://heroes.thelazy.net/index.php/Goblin_and_Hobgoblin) | Hobgoblin |
| Stronghold | 2 | [Wolf Rider](https://heroes.thelazy.net/index.php/Wolf_Rider_and_Wolf_Raider) | Wolf Raider |
| Stronghold | 3 | [Orc](https://heroes.thelazy.net/index.php/Orc_and_Orc_Chieftain) | Orc Chieftain |
| Stronghold | 4 | [Ogre](https://heroes.thelazy.net/index.php/Ogre_and_Ogre_Mage) | Ogre Mage |
| Stronghold | 5 | [Roc](https://heroes.thelazy.net/index.php/Roc_and_Thunderbird) | Thunderbird |
| Stronghold | 6 | [Cyclops](https://heroes.thelazy.net/index.php/Cyclops_and_Cyclops_King) | Cyclops King |
| Stronghold | 7 | [Behemoth](https://heroes.thelazy.net/index.php/Behemoth_and_Ancient_Behemoth) | Ancient Behemoth |
| Fortress | 1 | [Gnoll](https://heroes.thelazy.net/index.php/Gnoll_and_Gnoll_Marauder) | Gnoll Marauder |
| Fortress | 2 | [Lizardman](https://heroes.thelazy.net/index.php/Lizardman_and_Lizard_Warrior) | Lizard Warrior |
| Fortress | 3 | [Serpent Fly](https://heroes.thelazy.net/index.php/Serpent_Fly_and_Dragon_Fly) | Dragon Fly |
| Fortress | 4 | [Basilisk](https://heroes.thelazy.net/index.php/Basilisk_and_Greater_Basilisk) | Greater Basilisk |
| Fortress | 5 | [Gorgon](https://heroes.thelazy.net/index.php/Gorgon_and_Mighty_Gorgon) | Mighty Gorgon |
| Fortress | 6 | [Wyvern](https://heroes.thelazy.net/index.php/Wyvern_and_Wyvern_Monarch) | Wyvern Monarch |
| Fortress | 7 | [Hydra](https://heroes.thelazy.net/index.php/Hydra_and_Chaos_Hydra) | Chaos Hydra |
| Conflux | 1 | [Pixie](https://heroes.thelazy.net/index.php/Pixie_and_Sprite) | Sprite |
| Conflux | 2 | [Air Elemental](https://heroes.thelazy.net/index.php/Air_Elemental_and_Storm_Elemental) | Storm Elemental |
| Conflux | 3 | [Water Elemental](https://heroes.thelazy.net/index.php/Water_Elemental_and_Ice_Elemental) | Ice Elemental |
| Conflux | 4 | [Fire Elemental](https://heroes.thelazy.net/index.php/Fire_Elemental_and_Energy_Elemental) | Energy Elemental |
| Conflux | 5 | [Earth Elemental](https://heroes.thelazy.net/index.php/Earth_Elemental_and_Magma_Elemental) | Magma Elemental |
| Conflux | 6 | [Psychic Elemental](https://heroes.thelazy.net/index.php/Psychic_Elemental_and_Magic_Elemental) | Magic Elemental |
| Conflux | 7 | [Firebird](https://heroes.thelazy.net/index.php/Firebird_and_Phoenix) | Phoenix |

## Architecture and JSON mapping

- Every creature has one generic `Creature` row and one `CreatureHOMM3`
  detail row with the same stable dotted `_key`. All 18 non-PK creature-detail
  fields are populated, including faction, alignment, combat stats, movement,
  size, shots, growth, AI value, gold cost, recruitability, and upgrade flags.
- Alignment matches the existing faction detail. Creature, faction, release,
  cost, and upgrade endpoints all resolve within HOMM3 where game scope applies.
- All town forms are recruitable. `DoubleUpgrade` and `AlternativeUpgrade`
  are false for all 126 rows. These flags do not mean "is upgraded"; the 63
  base-to-upgrade relationships live in the shared `CreatureUpgrade` graph.
- Five shared `Resource` rows represent Gold, Mercury, Sulfur, Crystal, and
  Gems. Five `GameResource` rows associate these cost resources with HOMM3.
  Resource keys are global (`resource.gold`, etc.); game membership has its
  own game-scoped key. `Gem` in the wiki normalizes to resource name `Gems`.
- There are 140 `CreatureResourceCost` rows: 126 gold costs and 14 rare-resource
  costs. `CreatureHOMM3.GoldCost` equals the gold relationship's `Amount`.
  The existing scalar and relational fields are populated consistently.
- Independent physical PKs and junction `*_cid` fields are omitted from JSON.
  The import allocates BIGINT identities, reuses shared parent IDs, and uses
  the stable `_key` for each new TEXT junction identity.
- Numbers remain JSON numbers, flags are booleans, enum strings retain exact
  spelling, and optional generic descriptions/media remain null. No abilities,
  spell IDs, building identities, or other relationships are hidden in JSONB.
  Detailed ability, spell, and dwelling catalogs are separate entry subjects.
- The existing schema and all 173 table arrays are preserved.

The batch contributes 465 new rows: 126 Creature, 126 CreatureHOMM3,
63 CreatureUpgrade, 140 CreatureResourceCost, 5 Resource, and 5 GameResource.
The cumulative bundle contains 659 records, including all 194 earlier rows.

## Validation and PostgreSQL application

Validate the cumulative bundle from the repository root:

```sh
node src/db/tools/validate.mjs src/db/data/heroeswatch.json
```

Validation passed:

```text
Valid HeroesWatch data bundle: 173 tables, 659 rows.
```

Separate checks confirmed that all 194 earlier rows are unchanged, the 126
creature stat records match the reviewed source values, every faction has
seven valid upgrade pairs, all costs are positive and use registered game
resources, references stay within the correct game, and the SQL snapshot
matches the JSON. All creature-detail fields are populated. The 116/10
introduction split and the 81/45 battlefield-size split were also checked.

[homm3-creatures.sql](homm3-creatures.sql) contains the reviewed snapshot.
Apply [homm3-factions.sql](homm3-factions.sql) first on an existing HeroesWatch
schema. The creature script resolves its 13 existing game/release/faction
prerequisites without modifying them, then imports the 465 content rows in
one transaction. It checks faction alignment, keeps all constraints enabled,
fills only missing sourced values, and aborts on conflicting existing facts.

[The summary query](homm3-creatures.summary.sql) should return nine factions
with 14 creatures and 7 upgrade links each, 140 cost rows in total, and true
detail checks. [The complete review](homm3-creatures.review.sql) displays all
126 creatures with stats, costs, upgrade targets, and introduction releases.
Run review queries in a fresh session after commit. Editing JSON alone does
not update PostgreSQL.

On 2026-09-12, the batch was applied successfully to local PostgreSQL 18,
database `HeroesWatch.net`, through the saved pgAdmin 4 connection. The
post-commit summary returned all nine factions with 14 creatures, 7 upgrade
links, and true detail checks for each. Cost-row counts were 16 for Castle,
Tower, Rampart, Inferno, and Dungeon, and 15 for Necropolis, Stronghold,
Fortress, and Conflux: 140 in total. A separate query session then returned
all 126 committed creatures with their stats, costs, upgrade targets, and
introduction releases. The complete review was left open in pgAdmin.
