# Heroes IV classes, heroes, towns and map dwellings

Research date: 2026-09-29. Catalog: [heroeswatch.json](heroeswatch.json).
Ruleset: the original game, The Gathering Storm and Winds of War. No mod content.

## Coverage

| Catalog | Rows |
|---|---:|
| Hero classes | 48 (11 starting, 36 advanced, 1 Archmage) |
| Named heroes | 310 |
| Town buildings | 172 |
| Adventure-map recruitment dwellings | 71 |

Each class and town building has its matching HOMM4 detail row. Each map
dwelling has an AdventureObjectHOMM4 detail with category `Dwelling`.
The six existing factions are Haven, Academy, Necropolis, Asylum, Preserve and
Stronghold. The existing game, expansion and faction keys are reused.

## Sources

- [Age of Heroes class table, Ring of Saturn mirror](https://ringofsaturn.com/games/heroes4/heroclasses.shtml): all 48 starting and advanced classes.
- Age of Heroes original town structure tables, mirrored by Ring of Saturn:
  [Haven](https://www.ringofsaturn.com/games/heroes4/buildings_life.shtml),
  [Academy](https://www.ringofsaturn.com/games/heroes4/buildings_order.shtml),
  [Necropolis](https://www.ringofsaturn.com/games/heroes4/buildings_death.shtml),
  [Asylum](https://www.ringofsaturn.com/games/heroes4/buildings_chaos.shtml),
  [Preserve](https://www.ringofsaturn.com/games/heroes4/buildings_nature.shtml),
  [Stronghold](https://www.ringofsaturn.com/games/heroes4/buildings_might.shtml).
  Counts by faction are 30, 29, 29, 30, 30 and 24 respectively. Tables distinguish
  eight normal creature dwellings in each town and the mutually exclusive choices.
- Might and Magic Wiki factual hero roster tables:
  [Haven](https://mightandmagic.fandom.com/wiki/Haven_(H4)),
  [Academy / Mage](https://mightandmagic.fandom.com/wiki/Mage_(H4_class)),
  [Necropolis / Death Knight](https://mightandmagic.fandom.com/wiki/Death_Knight_(H4)),
  [Asylum / Thief](https://mightandmagic.fandom.com/wiki/Thief_(H4)),
  [Preserve](https://mightandmagic.fandom.com/wiki/Preserve),
  [Stronghold](https://mightandmagic.fandom.com/wiki/Stronghold_(H4)).
- [Jaskinia Behemota hero catalog](https://h4.heroes.net.pl/bohaterowie/zycie)
  and [Haven hero list](https://heroesofmightandmagic.funsite.cz/?page=heroesh4_eden):
  spelling and class cross-checks, including Pirvian.
- [Hexis](https://mightandmagic.fandom.com/wiki/Hexis),
  [Kozuss](https://mightandmagic.fandom.com/wiki/Kozuss),
  [Agraynel](https://mightandmagic.fandom.com/wiki/Agraynel),
  [Alita Eventide](https://mightandmagic.fandom.com/wiki/Alita_Eventide):
  the Gathering Storm heroes' actual advanced classes. Bohb is an Archmage,
  Kozuss a Wizard, Agraynel a Bard, Alita a Dark Priest and Hexis a Demonologist.
- [Adventure-map structures](https://mightandmagic.fandom.com/wiki/List_of_adventure_map_structures_in_Heroes_IV)
  and [Jaskinia Behemota dwelling tables](https://h4.heroes.net.pl/lokacje/siedliska):
  71 external recruitment dwellings, including the expansion additions.
- [Ice Demon](https://mightandmagic.fandom.com/wiki/Ice_demon) and
  [Dark Champion](https://mightandmagic.fandom.com/wiki/Dark_champion):
  Ice Gate and Dark Knight's Sanctum names.
- [Existing faction research](homm4-factions.sources.md): the four Gathering
  Storm creatures acquired their map dwellings in Winds of War. Their dwellings
  therefore use the WOW expansion key. Mermaid, Sea Monster and Megadragon
  have no purchasable dwellings in this ruleset.

## Mapping and limitations

- `Hero.HeroClass_id`, `HeroClassHOMM4.StartingFaction_id` and
  `BuildingHOMM4.Faction_id` are real references. Advanced classes have no
  exclusive faction. The schema has no `HeroHOMM4` table or direct dwelling to
  faction/creature junction, so no pseudo foreign keys are inserted in JSONB.
- Town buildings and external dwellings are separate catalog entities. The
  Preserve's Creature Portal is a town special building with `IsDwelling=true`.
- The mummy dwelling is **Embalmer's Lab**, verified from the English
  adventure-map structure table's raw wiki source and cross-checked against
  Jaskinia Behemota's Polish dwelling row.
- This is the named roster from the listed faction references plus Hexis.
  It includes the ten expansion protagonists and campaign characters listed in
  those rosters. It is not an audit of every custom name attached to an enemy
  hero instance in every campaign map.
- Biography prose, artwork, unverified costs, skill probabilities, class bonus
  mechanics, build prerequisites and creature production links are not imported.
  Optional unknown scalar and JSONB fields remain null. No numeric combat
  statistics are guessed. The source spellings are retained as display names;
  `_key` and `Code` are stable project identifiers.

## Reproduction

Run `research-homm45.py` followed by `research-homm45-build.py` in
`src/db/tools` with Python and pypdf available. The former caches source
documents in the system temporary directory. The latter writes the two IV/V
fragments without changing the cumulative bundle. Only factual labels and
classifications enter the repository; source prose and PDF files stay outside it.
The generated research fragments use the ignored paths
`src/db/data/research/homm4-catalog.json` and
`src/db/data/research/homm5-catalog.json` before merging into the cumulative bundle.
