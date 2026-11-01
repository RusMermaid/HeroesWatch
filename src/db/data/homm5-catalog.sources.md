# Heroes V classes, heroes, towns and map dwellings

Research date: 2026-09-29. Catalog: [heroeswatch.json](heroeswatch.json).
Ruleset: Tribes of the East 3.1, including original-game and Hammers of Fate
content. No Heroes 5.5 or other mods.

## Coverage

| Catalog | Rows |
|---|---:|
| Game / releases | 1 / 3 |
| Factions / classes / racial skills | 8 / 8 / 8 |
| Named heroes | 124 |
| Town buildings | 292 |
| Adventure-map recruitment dwellings | 34 |

Haven, Inferno, Necropolis, Dungeon, Sylvan and Academy are original-game
factions. Fortress was introduced in Hammers of Fate and Stronghold in Tribes
of the East. Each generic faction, class, skill, hero, building and map dwelling
has its corresponding shared-primary-key detail row.

## Sources

- [Heroes V manual, Tribes of the East 3.1 edition](https://h5.heroes.net.pl/uploaded/download/other/Heroes5-Manual-en-3-1.pdf)
  by Stephane Fidanza, Valera Koltsov, Paolo Angelo Sossi and the international
  Heroes community, supported by Ubisoft and Nival. Its foreword identifies the
  contributors and developer support. Original project attribution:
  [Heroes-fr fan manuals](http://www.heroes-fr.com/en/fan_manuals.php).
  - Printed pp. 11–69: 113 hero entries. Repeated ruleset templates and
    alternate identities are reconciled into the single named hero catalog.
  - Printed pp. 211–242: all 292 town buildings, including 14 creature
    dwellings and one Grail building per faction.
  - Printed pp. 266–268: four faction dwellings per faction, Refugee Camp and
    Elemental Conflux, for 34 total.
  - Printed p. 293: class primary-stat growth percentages; pp. 11, 17, 25, 31,
    44, 51, 58 and 64: initial class attributes.
- [Original Tribes of the East manual on Steam](https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/15370/manuals/H5X20047_PCS_MNL_guts.pdf):
  the eight faction/class associations.
- [Haven faction](https://mightandmagic.fandom.com/wiki/Haven_(H5)),
  [Heroes V factions](https://mightandmagic.fandom.com/wiki/Heroes_V_factions)
  and [alignment](https://mightandmagic.fandom.com/wiki/Alignment):
  faction introductions, racial systems and alignment cross-checks.
- Supplemental named scenario hero rosters:
  [Cyrus / Academy](https://mightandmagic.fandom.com/wiki/Cyrus_(H5)),
  [Dgum](https://mightandmagic.fandom.com/wiki/Dgum),
  [Biara / Dungeon and Haven](https://mightandmagic.fandom.com/wiki/Biara),
  [Orlando / Inferno and Haven](https://mightandmagic.fandom.com/wiki/Orlando),
  [Vittorio / Haven](https://mightandmagic.fandom.com/wiki/Vittorio),
  [Batal / Stronghold](https://mightandmagic.fandom.com/wiki/Batal),
  [Alaron / Sylvan](https://mightandmagic.fandom.com/wiki/Alaron),
  [Arantir / Necropolis](https://mightandmagic.fandom.com/wiki/Arantir).
  Eighteen additional names extend the manual roster: Amin, Dgum, Ferigl,
  Ohtar, Segref, Ghost, Giar, Glen, Saint Isabel, Stephan, Erasial, Gamor,
  Kraal, Batal, Dulgan, Gork, Mangu and Toulain.
- [Andreas](https://mightandmagic.fandom.com/wiki/Andreas),
  [Maahir](https://mightandmagic.fandom.com/wiki/Maahir),
  and [adventure-map structures](https://mightandmagic.fandom.com/wiki/List_of_adventure_map_structures_in_Heroes_V):
  expansion, scenario availability and dwelling cross-checks.

## Mapping and limits

- Initial attributes are Attack, Defense, SpellPower, Knowledge. Barbarians
  start at **3, 0, 0, 1**. Growth percentages are in the same order and sum to
  100 for every class.
- The source's good/evil alignment maps to the schema's Light/Dark vocabulary.
  Every racial skill, class and faction association is an FK, not a name in JSONB.
- Heroes share identities across same-name ruleset and class changes. Nicolai,
  Ornella and Orlando each have one row with null `HeroClass_id` because the
  source gives multiple playable classes and the schema permits one class per
  Hero row. Their conflicting specialty names also remain null. Differently
  named game roster entries retain their actual classes: Agrael and Raelag;
  Biara, Shadya and Saint Isabel. Their descriptions document the narrative
  aliases. This preserves the faction-scoped catalog and avoids duplicate
  same-name records for campaign stat variations.
- All 64 standard tavern heroes are marked `Standard`. The manual combines
  campaign and standalone scenario heroes under its campaign headings, so
  remaining `Availability` values stay null rather than asserting exclusivity.
  Unverified hero introduction releases stay null. A story appearance in an
  earlier product is not automatically treated as the introduction of a later
  playable class form.
- Common structures are faction-scoped rows because town requirements and
  effects differ. Counts: Academy 36, Dungeon 37, Fortress 39, Haven 36,
  Inferno 36, Necropolis 36, Stronghold 34, Sylvan 38.
- `TownLevelRequired` records an explicit level requirement in the source;
  null means it was not explicitly stated for that building, not zero.
- Creature tiers, magic guild levels, class initial attributes and growth
  percentages are populated. Detailed costs, build/upgrade prerequisite graphs,
  armies, spell loadouts, biographies and ability formulas remain unresearched.
- External dwellings are AdventureObject records. The schema has no direct
  dwelling-to-faction or dwelling-to-creature junction; no embedded soft FK is
  invented. Refugee Camp and Elemental Conflux are visiting sites; the 32
  faction dwellings are capturable.
- Names retain the 3.1 manual's spellings, including differences between town
  and map structures. This is a reference roster, not an exhaustive extraction
  of all custom named hero instances in shipped map scripts.

The two `research-homm45*.py` scripts reproduce the fragments. The PDF is
cached outside the repository. Its licensed prose and artwork are not copied
into the database; only factual catalog names and numerical attributes are used.
