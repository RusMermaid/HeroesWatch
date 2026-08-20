# HeroesWatch database handoff

This directory is the checked-in database contract for HeroesWatch. It was
generated from the saved SQLDesigner diagram after the 2NF audit.

Current contract:

- 173 PostgreSQL tables
- 1,285 fields
- 349 foreign keys
- 147 ordinary/shared-PK tables in second normal form
- 26 explicit `*_cid` junction tables covered by the project exemption

## Five-minute start

1. Read [ARCHITECTURE.md](ARCHITECTURE.md) once.
2. Copy [data/template.json](data/template.json) to a cumulative working file,
   normally `src/db/data/heroeswatch.json`.
3. Add rows using the rules in [DATA_ENTRY.md](DATA_ENTRY.md).
4. Validate before handing the file back:

   ```sh
   node src/db/tools/validate.mjs src/db/data/heroeswatch.json
   ```

5. To open the complete structure in PostgreSQL software:

   - create an empty database named `HeroesWatch`;
   - open [`HeroesWatch.sql`](HeroesWatch.sql) in pgAdmin,
     DBeaver, DataGrip, or another PostgreSQL query editor;
   - execute the whole file;
   - refresh `Schemas → heroes_watch → Tables`.

   The file creates all 173 tables, types, constraints, indexes, and links,
   but contains no game data.

   For a Windows computer, follow [WINDOWS.md](WINDOWS.md). The same SQL file
   works on macOS and Windows. A schema-only `HeroesWatch.backup` is also
   included for PostgreSQL Restore tools.

   The equivalent command-line workflow is:

   ```sh
   psql -X -v ON_ERROR_STOP=1 -d heroeswatch \
     -f src/db/postgres/schema.sql
   psql -X -v ON_ERROR_STOP=1 -d heroeswatch \
     -f src/db/postgres/verify.sql
   ```

`HeroesWatch.sql` and `postgres/schema.sql` are intentionally
one-time baselines for an empty database. They do not drop or overwrite an
existing schema.

## What is authoritative?

- `schema/sql-designer.snapshot.json` is the exact saved diagram snapshot.
- `schema/heroeswatch.schema.json` is the compact semantic contract used by
  people and tools.
- `postgres/schema.sql`, the initial migration, JSON Schema, template, normal
  form report, and data dictionary are deterministic generated outputs.
- New content belongs in the cumulative data JSON, not in the schema files.
- The checked-in handoff intentionally contains no content loader and no game
  rows. Data may be entered directly in a PostgreSQL GUI, or the cumulative
  JSON can be integrated later by application code after review.

To verify that generated files are current:

```sh
node src/db/tools/generate.mjs \
  --input src/db/schema/sql-designer.snapshot.json \
  --out src/db \
  --check
```

Do not use SQL Import against the live SQLDesigner diagram. It replaces the
canvas instead of merging it.

## Files

- [ARCHITECTURE.md](ARCHITECTURE.md): relational design and PostgreSQL choices.
- [DATA_ENTRY.md](DATA_ENTRY.md): partner-facing entry and handoff workflow.
- [DATA_DICTIONARY.md](DATA_DICTIONARY.md): every table, field, type, key, and FK.
- [HeroesWatch.sql](HeroesWatch.sql): GUI-friendly complete
  PostgreSQL bootstrap file.
- `HeroesWatch.backup`: cross-platform PostgreSQL custom-format, schema-only
  backup.
- [WINDOWS.md](WINDOWS.md): free DBeaver/PostgreSQL setup and verification.
- `schema/heroeswatch.schema.json`: simple machine-readable architecture.
- `schema/data.schema.json`: autocomplete and structural validation contract.
- `schema/normal-form-report.json`: auditable 2NF result.
- `postgres/migrations/0001_initial.sql`: immutable initial migration.
- `postgres/verify.sql`: catalog-count verification after applying the DDL.
- `tools/generate.mjs`: deterministic SQLDesigner-to-PostgreSQL generator.
- `tools/validate.mjs`: dependency-free data-batch validator.

## Runtime requirements

- Node.js 20 or newer for the local tools.
- PostgreSQL 16 or newer; PostgreSQL 18 is the current reference target.
- A PostgreSQL client such as pgAdmin, DBeaver, DataGrip, or `psql`.
