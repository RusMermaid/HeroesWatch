# Heroes I and Heroes II Gold factions

Research date: 2026-09-12. Cumulative data: [heroeswatch.json](heroeswatch.json).
Scope: the original four Heroes I factions and six Heroes II factions, with
the original releases, The Price of Loyalty, and the Heroes II Gold compilation.

## Sources

- The original [Heroes of Might and Magic manual, reproduced by ManualShelf](https://www.manualshelf.com/manual/games-pc/heroes-of-might-and-magic/user-guide-english.html),
  printed pages 74-77 and 80-87: Knight/Farm, Barbarian/Plains,
  Sorceress/Forest, and Warlock/Mountain castle types.
- The original [Heroes II Gold manual, reproduced by ManualMachine](https://manualmachine.com/gamespc/heroesofmightandmagiciigold/1119021-user-manual/),
  Mage Guild and common structures sections: all six towns can build a
  fifth-level Mage Guild.
- [GOG's Heroes II Gold listing](https://www.gog.com/en/game/heroes_of_might_and_magic_2_gold_edition):
  Gold includes the base Heroes II game and The Price of Loyalty expansion.
- [Heroes II release and campaign overview](https://en.wikipedia.org/wiki/Heroes_of_Might_and_Magic_II):
  The Succession Wars is the base game; Knight, Sorceress, and Wizard are
  good-aligned; Barbarian, Necromancer, and Warlock are evil-aligned.

## Input normalization

The user's Heroes I labels are preserved here and mapped to the exact ENUM
values declared in `FactionHOMM1.TownType`:

| Supplied input | Faction name | Stored TownType |
|---|---|---|
| Knight with Fields | Knight | Farm |
| Sorceress with Forests | Sorceress | Forest |
| Warlock with Caves | Warlock | Mountain |
| Barbarians with Planes | Barbarian | Plains |

`Fields`, `Forests`, `Caves`, and `Planes` are not valid ENUM values. The
manual's castle classifications determine the mapping. `Barbarians` is
normalized to the singular faction name `Barbarian`. No ad-hoc alias columns
or new terrain relationships are introduced.

The request's "war of succession expansion" is interpreted as The Succession
Wars, the original Heroes II release. The actual expansion is The Price of
Loyalty. The complete package is represented by Heroes II Gold. These are
three release records under one `Game` identity, with kinds `BaseGame`,
`Expansion`, and `Compilation`, respectively.

## Heroes II values

| Faction | Alignment | MageGuildMaxLevel |
|---|---|---:|
| Knight | Good | 5 |
| Sorceress | Good | 5 |
| Barbarian | Evil | 5 |
| Necromancer | Evil | 5 |
| Warlock | Evil | 5 |
| Wizard | Good | 5 |

All six were introduced in The Succession Wars and remain the same faction
identities in The Price of Loyalty and Gold. No duplicate faction rows are
created for the expansion or compilation.

## Architecture mapping

- Two `Game` rows use `SeriesCode` values `HOMM1` and `HOMM2`, with editorial
  `DisplayOrder` values 1 and 2. These are project identifiers and ordering
  conventions, not physical IDs.
- Four `Expansion` rows represent Heroes I (`BASE`), Heroes II: The Succession
  Wars (`SW`), The Price of Loyalty (`POL`), and Heroes II Gold (`GOLD`).
- Ten `Faction` rows own the names, game scope, and introduction provenance.
  Names recurring across games remain separate game-scoped identities.
- Four `FactionHOMM1` and six `FactionHOMM2` rows reuse their generic faction
  `_key`, allowing PostgreSQL to reuse the parent's actual primary key.
- Heroes I stores its castle type in the declared `TownType` ENUM. Heroes II
  stores `Alignment` and `MageGuildMaxLevel`. No field is copied into a table
  that does not declare it.
- Optional release dates, descriptions, and media references remain null.
  No schema, dictionary, template, or initial migration changes are needed.

The batch contributes 26 records. With the existing 107 Heroes III/IV records,
the cumulative bundle contained 133 rows when this batch was added and
retained all 173 table arrays.

## Validation and PostgreSQL application

```sh
node src/db/tools/validate.mjs src/db/data/heroeswatch.json
```

Validation passed when this batch was added:

```text
Valid HeroesWatch data bundle: 173 tables, 133 rows.
```

Separate checks confirmed the Heroes I town-type mapping, the Heroes II
alignment and mage-guild values, the correct release kinds, same-game parent
references, and equality between the SQL payload and the JSON batch. All 107
previous Heroes III/IV JSON records match the previous commit exactly.

[homm1-homm2-factions.sql](homm1-homm2-factions.sql) is a snapshot of the 26
new records. It resolves keys to generated or existing IDs, fills missing
nullable sourced values, and rejects conflicting existing facts. All foreign
keys remain enabled and are checked before the single transaction commits.
Existing Heroes III/IV content is preserved. JSON edits do not automatically
update this SQL snapshot or a running database.

Use [the faction review](homm1-homm2-factions.review.sql) to inspect all ten
factions and [the release review](homm1-homm2-releases.review.sql) to inspect
the four release records. A dash in the faction review means that a field is
not modeled for that title; it is a display value only.

On 2026-09-12, the previously pending SQL batch was applied successfully to
local PostgreSQL 18, database `HeroesWatch.net`, through pgAdmin 4. Foreign
keys were checked before commit, and the post-commit query returned all ten
Heroes I/II factions with the town types, alignments, and mage-guild values
documented above.
A fresh pgAdmin session independently returned the same ten factions after
commit, completing the previously pending database verification.
