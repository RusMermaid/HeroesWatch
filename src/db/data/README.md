# Data batches

`template.json` is the empty, schema-complete starting point for a new data
bundle. Extend the existing `heroeswatch.json` for cumulative entry; do not
overwrite it with the template or edit the template itself.

The cumulative working file is:

```text
heroeswatch.json
```

Temporary contributor files are fine during research, but all referenced rows
must be merged into the cumulative file before validation. Do not commit
secrets, credentials, copyrighted media files, or unverified bulk scrapes.
JSON files here contain structured metadata only.

Validate a batch with:

```sh
node src/db/tools/validate.mjs src/db/data/heroeswatch.json
```

See [`../DATA_ENTRY.md`](../DATA_ENTRY.md) for the complete workflow.

## Heroes III faction batch

The Heroes III batch contributes nine classic factions, their shared-PK
`FactionHOMM3` details, and the referenced game, releases, and terrains: 29
records. It uses Shadow of Death mechanics with Armageddon's Blade
content enabled, including Grass as Conflux's native terrain.

- [Sources and mapping](homm3-factions.sources.md) records the research,
  release provenance, and validation results.
- [SQL import](homm3-factions.sql) applies this specific batch to an existing
  HeroesWatch schema in one transaction. It resolves physical IDs and stops
  on conflicting existing facts. Review and execute the entire script in a
  fresh query session.
- [Review query](homm3-factions.review.sql) displays the nine factions with
  alignment, native terrain, release provenance, and physical faction IDs.

The SQL import is a snapshot of this batch. Later JSON edits require a
corresponding reviewed database application; they do not update PostgreSQL
automatically.

## Heroes IV factions and neutral creatures

The Heroes IV batch adds 78 records for Haven, Academy, Necropolis, Asylum,
Preserve, Stronghold, and 26 creatures outside the standard town lineups.
It covers the base game, The Gathering Storm, and Winds of War using the
unmodified Winds of War ruleset.

Neutral creatures retain their faction alignment; they are not a seventh
town faction. The batch includes the eight Creature Portal units and records
which creatures can be purchased under this ruleset.

- [Sources and field mapping](homm4-factions.sources.md) explains provenance,
  recruitment, melee versus ranged statistics, and movement conversion.
- [SQL import](homm4-factions.sql) applies the 78 Heroes IV records in one
  transaction, preserving existing content and rejecting conflicting facts.
- [Faction review](homm4-factions.review.sql) displays the six towns.
- [Creature review](homm4-creatures.review.sql) displays all 26 creatures.

Validate the cumulative JSON, review the sources, and execute the complete SQL
import in a fresh query session against the existing `heroes_watch` schema.

## Heroes I and Heroes II Gold factions

This batch contributes 26 records: two games, four release records, ten
factions, and ten shared-PK details. It adds the original Heroes I and Heroes
II rosters, with The Succession Wars as the Heroes II base game, The Price of
Loyalty as its expansion, and Gold as the compilation.

- [Sources and input mapping](homm1-homm2-factions.sources.md) explains the
  Heroes I town-type labels and the Heroes II release names.
- [SQL import](homm1-homm2-factions.sql) applies the complete 26-row batch in
  one transaction against the existing schema.
- [Faction review](homm1-homm2-factions.review.sql) displays all ten factions.
- [Release review](homm1-homm2-releases.review.sql) displays all four releases.

## Heroes VI factions and expansions

This batch contributes 29 records for Haven, Inferno, Necropolis, Sanctuary,
Stronghold, and Dungeon, their faction abilities, and release provenance.
It covers the base game, Pirates of the Savage Sea, Danse Macabre, and Shades
of Darkness. Dungeon is introduced in Shades of Darkness; the adventure packs
reuse existing faction identities.

- [Sources and mapping](homm6-factions.sources.md) documents the six abilities,
  the limit of two unique buildings per town, and release classifications.
- [SQL import](homm6-factions.sql) applies the complete Heroes VI batch.
- [Faction review](homm6-factions.review.sql) displays the six factions.
- [Release review](homm6-releases.review.sql) displays the four releases.

The cumulative JSON contains 162 records across Heroes I-IV and VI. Execute
each reviewed batch SQL separately in a fresh query session; changes to JSON
do not automatically update the database.
