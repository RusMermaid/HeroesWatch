# Data batches

`template.json` is the empty, schema-complete starting point for human data
entry. Copy it to `heroeswatch.json`; do not edit the template itself.

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
