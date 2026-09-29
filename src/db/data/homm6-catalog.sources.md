# Heroes VI classes, heroes, town buildings, and external dwellings

Research date: 2026-09-29. These are import fragments for merging into
`heroeswatch.json`, not independent bundles. All relationship values are stable
`_key` references. Generic rows own identity; shared-PK detail rows reuse it.
No database IDs, parallel entity lists, or credentials are stored in JSONB.
Names and numeric facts are transcribed; narrative biographies and source
descriptions are not copied.

## Coverage

The fragment `research/homm6-catalog.json` adds 36 class identities, 30 class
details, 139 named hero identities and details, 185 town buildings and details,
146 building prerequisites, 40 verified upgrade edges, 18 faction external
dwellings and six forts with adventure-object details.

The existing six factions and four releases are reused. Dungeon classes,
buildings, and dwellings belong to Shades of Darkness. Sandro is introduced
by Danse Macabre. Heroes cover the source's game and expansion category tree,
with Sandro added because his article is missing the hero category. This is a
catalog of documented gameplay identities; it does not claim a complete audit
of every mission script or editor-only alias.

## Sources and mapping

- [Haven](https://mightandmagic.fandom.com/wiki/Haven_(H6)),
  [Inferno](https://mightandmagic.fandom.com/wiki/Inferno_(H6)),
  [Necropolis](https://mightandmagic.fandom.com/wiki/Necropolis_(H6)),
  [Sanctuary](https://mightandmagic.fandom.com/wiki/Sanctuary_(H6)),
  [Stronghold](https://mightandmagic.fandom.com/wiki/Stronghold_(H6)), and
  [Dungeon](https://mightandmagic.fandom.com/wiki/Dungeon_(H6)) provide the
  faction class lists and town structure tables. Their Structure template
  fields were parsed through the public MediaWiki API and checked by faction:
  five towns have 31 structures, Inferno has 30. Inferno uses Chaos Crucible
  in place of Marketplace and does not have an advanced market.
- [Heroes VI classes](https://mightandmagic.fandom.com/wiki/Category:Heroes_VI_classes)
  and [heroes](https://mightandmagic.fandom.com/wiki/Category:Heroes_VI_heroes)
  provide the recursively enumerated rosters. Individual class and hero pages
  supply class links. A hero with multiple scenario-dependent classes keeps
  its single generic identity; an unambiguous neutral base class is used when
  available, otherwise the nullable class FK remains null.
- [Sandro](https://mightandmagic.fandom.com/wiki/Sandro_(Ashan)) confirms his
  playable Danse Macabre introduction; mentions of him in earlier games do
  not imply a playable Heroes VI base-game appearance.
- [Heroes VI fan manual 0.921](https://www.scribd.com/document/88970592/Mmh6-Manual-Eng-0-921),
  printed page 233, Initial Stats: six starting attributes for each of the
  ten original faction/archetype combinations. This secondary manual covers
  game version 1.4.31451. Its values were also checked against the populated
  class development tables where available. Reputation promotions retain
  the faction/archetype defaults and reference their neutral base class.
- [Adventure-map structure table](https://mightandmagic.fandom.com/wiki/List_of_adventure_map_structures_in_Heroes_VI)
  supplies all three named external dwellings and the fort for each faction.
  Forts control an area; dwellings do not. Both can be captured and converted.

Town buildings and map dwellings remain separate catalogs. Building tiers are
Core for the first three faction creatures, Elite for the next three, and
Champion for the last, following the game's seven-creature lineup. Four
limited faction-special structures per town carry IsFactionUnique; Hall of
the Immortals is a Hall of Heroes upgrade, rather than one of these four.
Prerequisites and upgrades use actual FKs, and only exact matched names from
the requirements tables produce edges. Source spelling is retained, including
"Hall of Forbiden Desires"; a localization-file audit can correct this label.

## Unresolved source facts

The six Dungeon classes have generic records but **no HeroClassHOMM6 detail**:
Darkblade, Shadow Slayer, Trickster, Sorcerer, Dark Prophet, and Shadow Weaver.
Their six required default primary attributes are absent from the sources
retrieved. No zero values or another faction's stats were substituted. This
also means their faction relationship is documented but not yet FK-backed.

The following hero class references remain null because the available source
is missing a class or gives conflicting scenario classes: Djordje, Ishtvan,
Jezebeth, Kiril, Lucretia, Ovidio, Corak, and Yrbeth. Starting armies,
quantitative specialties, costs, complete prerequisite graphs, and exact
availability rules are not asserted where not researched. Campaign-category
membership supplies CampaignOnly; other availability values remain null.

## Validation

The fragment was merged into a temporary copy of the cumulative bundle with
VI, VII, and Olden Era research and passed `src/db/tools/validate.mjs`.
The temporary merge did not modify the cumulative file or PostgreSQL.

