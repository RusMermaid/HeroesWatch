# Heroes I and II classes, heroes, buildings and external dwellings

Reviewed 2026-09-29. These additions extend the existing factions and releases
in [heroeswatch.json](heroeswatch.json); they do not replace earlier entries.

| Game | Classes / details | Heroes | Town buildings / details | External dwellings / details |
|---|---:|---:|---:|---:|
| Heroes I | 4 / 4 | 36 | 60 / 60 | 7 / 7 |
| Heroes II, The Succession Wars and The Price of Loyalty | 6 / 6 | 77 | 171 / 171 | 22 / 22 |

The batch contributes 1,706 rows, including 14 resource memberships, 653
building costs, 252 prerequisite links and 57 building-upgrade links. No schema
or generated architecture artifact changes are needed.

## Sources and corrections

- *Heroes of Might and Magic: The Official Strategy Guide*, tables 2-2 and 4-1,
  printed pp. 17-18 and 38 (PDF pp. 27-28 and 48), and external sites on
  printed pp. 54, 59-60. [Published guide scan](https://oldapplestuff.com/download/Macintosh/Macintosh_Garden/manuals/HOMM_Strategy_Guide.pdf).
  The building tables were visually inspected. They resolve conflicting fan
  tables: Bridge costs 4,000 gold; Swamp 4,000; Fenced Meadow 3,000; Red Tower
  uses 20 mercury; Mage Guild level 4 uses 10 of each rare resource. Knight's
  Jousting Arena costs 3,000 gold and Cathedral requires wood, not ore.
- The [Heroes I class comparison](https://tartarus.rpgclassics.com/homm1/HowHeroesWork.php),
  [map-object reference](https://tartarus.rpgclassics.com/homm1/MapObjects.php),
  and [dwelling list](https://h1.heroes.net.pl/lokacje) corroborate starting
  attributes, spellbooks and external recruitment. The guide explains the
  terrain-dependent huts: snow replaces goblins with dwarves and cabin
  archers with peasants. Repeated artwork for the same recruitment function
  is grouped; `Hut (Snow)` is explicitly marked as an editorial qualifier.
- Might and Magic Wiki's Heroes I [Knight](https://mightandmagic.fandom.com/wiki/Knight_(H1)),
  [Barbarian](https://mightandmagic.fandom.com/wiki/Barbarian_(H1)),
  [Sorceress](https://mightandmagic.fandom.com/wiki/Sorceress_(H1)), and
  [Warlock](https://mightandmagic.fandom.com/wiki/Warlock_(H1)) rosters supply
  nine heroes each. Their linked Farm, Plains, Forest and Mountain pages
  corroborate the six faction dwellings and prerequisite graphs.
- Heroes II [Knight](https://mightandmagic.fandom.com/wiki/Knight_(H2)),
  [Barbarian](https://mightandmagic.fandom.com/wiki/Barbarian_(H2)),
  [Sorceress](https://mightandmagic.fandom.com/wiki/Sorceress_(H2)),
  [Warlock](https://mightandmagic.fandom.com/wiki/Warlock_(H2)),
  [Wizard](https://mightandmagic.fandom.com/wiki/Wizard_(H2)), and
  [Necromancer](https://mightandmagic.fandom.com/wiki/Necromancer_(H2)) pages
  supply building names, costs, requirements and standard/campaign galleries.
  Every priced building was independently compared with the
  [fheroes2 building definitions](https://github.com/ihhub/fheroes2/blob/master/src/fheroes2/castle/buildinginfo.cpp);
  all resource amounts agree. The engine is a cross-check, not a source of
  mod-only catalog additions.
- [Heroes II map structures](https://mightandmagic.fandom.com/wiki/List_of_adventure_map_structures_in_Heroes_II)
  supplies 17 base-game dwellings and five Price of Loyalty additions:
  four elemental altars and Barrow Mounds. Initial defenders are not listed
  as recruitable creatures: Troll Bridge recruits trolls; Dragon City recruits
  red dragons; City of the Dead recruits power liches.

## Identity and architecture decisions

Heroes I has four classes and 36 normal heroes. The model has no `HeroHOMM1`
table, so those heroes are stored solely in the generic `Hero` catalog with
their class FK. Each town has six dwellings, the castle, four utility buildings,
and four distinct Mage Guild levels: 15 rows per faction. There are no Heroes I
creature-dwelling upgrades. Repeated building names use faction-scoped codes.

Heroes II has 54 standard recruitable heroes, 19 named campaign heroes and
four additional named Price of Loyalty scenario characters. Ceallach, Dainwin,
Elderian and Mog were checked against their individual wiki pages and are
marked `MapOnly`. They reuse portraits but are separate named identities.
Roland Ironfist and Drakonia have scenario-dependent classes; their generic
class FK remains null and the alternatives are documented in `Description`.
Wiki redirects for Zam/Zom and display names such as Brother Brax are resolved.
Arbitrary player/custom-map renamings are outside this catalog.

The Necromancer Shrine is introduced in Price of Loyalty and replaces the
otherwise unavailable Tavern. The Tent has no purchase price. The Warlock's
Green, Red and Black Towers form a two-step upgrade chain. Prerequisites and
upgrades use the declared junctions; monetary costs use `BuildingResourceCost`.
The schema's nullable fields for secondary-skill weights, starting armies,
starting spells and detailed effects are left null where not part of this
researched batch. No numeric zero is used as a placeholder for unknown data.

External sites are `AdventureObject` plus the appropriate shared-PK detail.
The schema does not define an external-dwelling-to-creature/faction junction;
short descriptions identify recruitment without embedding foreign keys in JSON.
This addition does not claim a new complete Heroes I/II creature-stat catalog.

Only factual names, numeric values, short original descriptions and typed
relationships are stored. Raw wikitext, scans, images and copyrighted prose
remain outside the committed dataset.
