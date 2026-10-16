# HeroesWatch database handoff

This directory is the checked-in database contract for HeroesWatch. It was
generated from the saved SQLDesigner diagram after the 2NF audit.

Current contract:

- 176 PostgreSQL tables
- 1,309 fields (including two generated speed labels)
- 452 foreign keys
- 147 ordinary/shared-PK tables in second normal form
- 29 explicit `*_cid` junction tables covered by the project exemption

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

   The file creates all 176 tables, types, constraints, indexes, and links,
   but contains no game data.

   For a Windows computer, follow [WINDOWS.md](WINDOWS.md). The same SQL file
   works on macOS and Windows. The historical schema-only `HeroesWatch.backup`
   restores the initial contract and then requires migrations 0002 through 0008,
   in that order.

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

- `schema/sql-designer.snapshot.json` is the exact original diagram snapshot.
  `tools/schema-overlay.mjs` records the reviewed changes through version 8. Together
  they generate the current contract; the live diagram has not been replaced.
- `schema/heroeswatch.schema.json` is the compact semantic contract used by
  people and tools.
- `postgres/schema.sql`, the initial migration, JSON Schema, template, normal
  form report, and data dictionary are deterministic generated outputs.
- New content belongs in the cumulative data JSON, not in the schema files.
- The schema baselines contain no game rows. Reviewed content lives in the
  cumulative JSON: 45,616 rows across Heroes I–VIII and related Might and Magic
  RPGs and spin-offs, including classes, heroes,
  town buildings, dwellings, creatures, skills, magic, artifacts, campaigns
  and map objects for each title's actual mechanics and official expansions.
  [Coverage and known gaps](data/CATALOG_STATUS.md) lists counts, provenance,
  unresolved details, and PostgreSQL application status.
  [October 16 independent review](reviews/2026-10-16/README.md) distinguishes
  completed additions from the remaining data work and records repeatable
  checks of the final PR catalog. No live deployment was performed in that review.
  [October 14 completion record](reviews/2026-10-14/RESOLUTION.md)
  tracks the current five-patch update: 1,684 additions and 211 null fills.
  The October 14 Windows receipt reports a 45,616-row local deployment; it is
  not an independent check of that database's present state. The
  [October 13 completion and verification](reviews/2026-10-13/COMPLETION.md)
  records the earlier additions, integrity corrections, and Mac delivery.
  [Screenshot review status](data/TOUCHUPS_STATUS.md) records the new relationships,
  integrity protections, tests and remaining source gaps.
  [The manual comparison](data/MANUAL_COMPARISON.md) records source disagreements,
  edition differences and page evidence from the supplied local PDFs.
- [data/catalog.sql](data/catalog.sql) is the complete cumulative content
  import, generated with `node src/db/tools/build-content-sql.mjs`. It preserves
  local identities and facts and rejects conflicts. Inspect results with
  [data/catalog.review.sql](data/catalog.review.sql).
- [data/research-gaps-import.sql](data/research-gaps-import.sql) is the current
  research delta with 2,562 rows including dependencies, for a complete
  43,932-row baseline after migration 0008. Its five reviewed patches are
  recorded in [the October 14 audit](data/research-2026-10-14-evidence.json).
  `node src/db/tools/build-research-sql.mjs --check` checks this latest delta.
- [data/research-import.sql](data/research-import.sql) remains the historical
  October 13 research import for an already populated 40,023-row final-PR catalog.
  It targets the 43,932-row snapshot and does not contain the October 14 additions.
  For the historical Windows baseline, apply migrations 0003–0005 and the
  [creature tier corrections](data/creature-tier-corrections.sql), then this
  catch-up before migration 0006 checks the added resource memberships.
  [The current delivery review](reviews/2026-10-14/RESOLUTION.md) gives the full order.
  Use [data/completion.review.sql](data/completion.review.sql) for readable
  creature statistics, ability links, campaign heroes, and shared resources.
- [data/homm3-factions.sql](data/homm3-factions.sql) applies that batch in one
  transaction after review. [data/homm4-factions.sql](data/homm4-factions.sql)
  applies the Heroes IV batch, and
  [data/homm1-homm2-factions.sql](data/homm1-homm2-factions.sql) applies Heroes
  I and II. [data/homm6-factions.sql](data/homm6-factions.sql) applies Heroes VI,
  and [data/homm7-factions.sql](data/homm7-factions.sql) applies Heroes VII.
  [data/homm3-creatures.sql](data/homm3-creatures.sql) applies the Heroes III
  town creature roster after its faction batch.
  See [data/README.md](data/README.md) for sources
  and read-only verification queries. These earlier files are historical
  snapshots; the cumulative import above includes their reviewed content.

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
- `postgres/migrations/0002_relationship_integrity.sql`: upgrade an existing
  initial schema with the reviewed relationship integrity layer; run once.
- `postgres/migrations/0003_nullable_identity_and_campaign_scope.sql`: after
  0002, make nullable business identities effective and require a non-null
  campaign-hero starting scenario to belong to that campaign; it also requires
  Heroes V spell/rune costs to use resources registered for that game. Run it
  once. A null starting scenario remains valid for incremental or
  not-yet-researched data.
- `postgres/migrations/0004_creature_tier_terminology.sql`: rename creature
  `Level` to `Tier` in Heroes I–IV; spell levels stay unchanged.
- `postgres/migrations/0005_creature_numeric_speed.sql`: numeric H1/H2 `Speed`
  with generated `SpeedName`. Do not supply the generated name in import JSON.
- `postgres/migrations/0006_catalog_guards.sql`: cost, lore, graph, resource
  membership and town-faction safeguards, including reverse edits.
- `postgres/migrations/0007_source_detail_profiles.sql`: explicit VI resistance
  percentages, VII warfare rank profiles and stationary movement, plus nullable
  source-unknown Olden Era fields. Ordinary creature requirements remain guarded.
- [data/creature-tier-corrections.sql](data/creature-tier-corrections.sql): set
  Faerie/Rust/Crystal/Azure Dragon tiers to 8/8/9/10 before current imports.
- `postgres/verify.sql`: catalog-count verification after applying the DDL.
- `tools/generate.mjs`: deterministic SQLDesigner-to-PostgreSQL generator.
- `tools/validate.mjs`: dependency-free data-batch validator.
- [schema/JSON_CONTRACTS.md](schema/JSON_CONTRACTS.md): JSON payload profiles
  enforced by the validator and generated JSON Schema.

## Runtime requirements

- Node.js 20 or newer for the local tools.
- PostgreSQL 16 or newer; PostgreSQL 18 is the current reference target.
- A PostgreSQL client such as pgAdmin, DBeaver, DataGrip, or `psql`.
