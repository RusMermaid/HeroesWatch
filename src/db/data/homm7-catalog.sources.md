# Heroes VII classes, heroes, buildings, and external dwellings

Research date: 2026-09-29. These are import fragments for merging into
`heroeswatch.json`, not independent bundles. All relationship values are stable
`_key` references. Generic rows own identity; shared-PK detail rows reuse it.
No database IDs, parallel entity lists, or credentials are stored in JSONB.
Names and numeric facts are transcribed; narrative biographies and source
descriptions are not copied.

## Coverage

`research/homm7-catalog.json` adds 44 class identities, 35 class details,
132 hero identities, 343 town buildings and details (49 per faction),
207 prerequisite edges, 54 upgrade edges, and 21 faction/tier external
dwelling identities with details.

It reuses the seven existing factions and three releases. Forty-two classes
are the six normal classes of each faction; Djinn Lord and Hell Knight are
special classes. Fortress content and Hell Knight reference Trial by Fire.
Genevieve Seymour, Pherlon, and Dogwoggle reference Lost Tales of Axeoth.
Named heroes follow the category roster plus Maahir, confirmed by his class
and character articles. Category coverage is not a full mission-script audit.

## Sources and mapping

- The [Haven](https://mightandmagic.fandom.com/wiki/Haven_(H7)),
  [Academy](https://mightandmagic.fandom.com/wiki/Academy_(H7)),
  [Necropolis](https://mightandmagic.fandom.com/wiki/Necropolis_(H7)),
  [Stronghold](https://mightandmagic.fandom.com/wiki/Stronghold_(H7)),
  [Sylvan](https://mightandmagic.fandom.com/wiki/Sylvan_(H7)),
  [Dungeon](https://mightandmagic.fandom.com/wiki/Dungeon_(H7)), and
  [Fortress](https://mightandmagic.fandom.com/wiki/Fortress_(H7)) faction pages
  provide class identities and town building tables. Public MediaWiki raw
  templates supply names, requirements, dwelling tiers, mage-guild levels,
  and mutually exclusive champion dwellings.
- [Class category](https://mightandmagic.fandom.com/wiki/Category:Heroes_VII_classes)
  and [hero category](https://mightandmagic.fandom.com/wiki/Category:Heroes_VII_heroes),
  recursively enumerated, supply roster membership. Individual articles
  supply class links; ambiguous links remain null.
- [Djinn Lord](https://mightandmagic.fandom.com/wiki/Djinn_Lord) and
  [Hell Knight](https://mightandmagic.fandom.com/wiki/Hell_Knight) establish
  the two special classes. [Maahir](https://mightandmagic.fandom.com/wiki/Maahir)
  and [Battlemage](https://mightandmagic.fandom.com/wiki/Battlemage_(H7))
  establish his Heroes VII appearance and class.
- [October 2015 class-stat table](https://www.gamersky.com/handbook/201510/671280_24.shtml)
  supplies the four growth percentages in Might, Defense, Magic, Spirit order.
  This secondary reference predates the unofficial community patch and is
  used for 35 verified rows, including Djinn Lord.
- [Dwelling overview](https://mightandmagic.fandom.com/wiki/Dwelling),
  [original publisher dwelling explanation reproduced in an RSS archive](https://shadow1705.rssing.com/chan-52808156/all_p4.html),
  and [publisher patch 2.2 announcement](https://steamcommunity.com/app/321960/discussions/0/350542683191363473/)
  support faction-scoped Core, Elite, and Champion external dwellings and
  recruitment in areas of control. External dwellings can be captured and
  upgraded, and do not themselves act as area-control forts.
- [Ubisoft's editor manual](https://ubistatic-a.akamaihd.net/0004/prod/images/160407_LT1_Modding/EditorManual.pdf)
  corroborates faction, affinity, and class as distinct editor properties.

## Explicit coverage gaps

The 21 external-dwelling Names are **editorial faction/tier labels**, for
example "Haven core dwelling". They identify verified dwelling types;
they are not claimed to be the exact English localization strings. Each
row's Description carries this distinction. The schema has no faction FK
on AdventureObjectHOMM7, so faction affiliation cannot be represented there
without an architectural change.

Nine classes have no detail row because the required original-game growth
percentages remain unresolved: Archon, Embalmer, Jarl, Runelord, Engraver,
Thane, Firebrander, Hell Knight, and Warlord. The
[2023 community table](https://www.reddit.com/r/HoMM/comments/10afobg/looking_for_info_on_hero_stat_growth_rates_in_7/)
contains Fortress values but discusses a game using UCP; those values were
not assumed to be original-game settings. Archon and Embalmer values are
swapped between the 2015 and 2023 tables, so neither was selected blindly.
The generic identities remain; their faction FKs await verified detail rows.

These hero class FKs remain null: Grainne, Genevieve Seymour, Pherlon,
Dogwoggle, Ivan, Adar-Malik, Luna, Vein, and Etunia. HeroHOMM7 requires the
IsHallHero flag; reliable availability evidence for every listed hero was
not available, so this batch does not synthesize hero detail rows. Costs,
full quantitative effects, and a complete requirements graph remain outside
this transcribed set. Nullable unverified values remain null.

## Validation

The fragment passed the repository validator after a temporary merge with
the cumulative bundle and VI/Olden Era fragments. No database application is
performed by this research fragment or source document.

