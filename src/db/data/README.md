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

The cumulative file contains nine classic factions, their shared-PK
`FactionHOMM3` details, and the referenced game, releases, and terrains: 29
records in total. It uses Shadow of Death mechanics with Armageddon's Blade
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
