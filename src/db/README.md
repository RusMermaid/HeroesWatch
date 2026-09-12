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
2. Open [data/heroeswatch.json](data/heroeswatch.json) to extend the cumulative
   data. Use [data/template.json](data/template.json) only when starting a new,
   empty bundle.
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
- The schema baselines contain no game rows. Reviewed content lives in the
  cumulative JSON: four Heroes I factions, six Heroes II factions, nine Heroes
  III factions, six Heroes IV factions, six Heroes VI factions, seven Heroes
  VII factions, 26 Heroes IV non-town creatures, and their supporting records
  (194 rows in total).
- [data/homm3-factions.sql](data/homm3-factions.sql) applies that batch in one
  transaction after review. [data/homm4-factions.sql](data/homm4-factions.sql)
  applies the Heroes IV batch, and
  [data/homm1-homm2-factions.sql](data/homm1-homm2-factions.sql) applies Heroes
  I and II. [data/homm6-factions.sql](data/homm6-factions.sql) applies Heroes VI,
  and [data/homm7-factions.sql](data/homm7-factions.sql) applies Heroes VII.
  See [data/README.md](data/README.md) for sources
  and read-only verification queries. A general-purpose content loader is
  not included.

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
