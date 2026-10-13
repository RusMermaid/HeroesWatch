# Database testing

The dependency-free Node tests and deterministic generation checks are safe to
run in any checkout:

```sh
node src/db/tools/generate.mjs \
  --input src/db/schema/sql-designer.snapshot.json \
  --out src/db \
  --check
node src/db/tools/build-content-sql.mjs --check
node src/db/tools/build-manual-sql.mjs --check
node src/db/tools/build-touchup-sql.mjs --check
node src/db/tools/build-research-sql.mjs --check
node src/db/tools/prepare-catalog-v5.mjs --check
node --test src/db/tools/*.test.mjs
```

## PostgreSQL integration suite

The PostgreSQL suite is deliberately opt-in. It requires PostgreSQL 16 or newer
and explicit connection settings for a test instance:

```sh
HW_TEST_POSTGRES=1 \
HW_EXPECTED_ROWS=43736 \
PGHOST=127.0.0.1 \
PGPORT=5432 \
PGUSER=postgres \
PGDATABASE=postgres \
node src/db/tools/postgres-integration.mjs
```

Supply `PGPASSWORD` when the test server requires password authentication. Use
`HW_PG_BINDIR` if `psql`, `createdb`, and `dropdb` are not on `PATH`; individual
`HW_PSQL`, `HW_CREATEDB`, and `HW_DROPDB` settings can override them instead.

The runner never loads the schema, fixtures, or catalog into `PGDATABASE`.
It generates a random name matching
`heroeswatch_ci_<process-id>_<16-hex-digits>`, creates that database from
`template0`, and cleans up only that exact name in a `finally` block. Use a
dedicated local or CI PostgreSQL cluster because the configured role needs
`CREATEDB` and permission to force-drop its disposable database.

The integration suite verifies:

- the complete current DDL and structural verification script;
- direct rejection cases for same-game ownership, inherited detail bands,
  global-media reverse ownership, resource membership, prerequisite groups,
  nullable business identities, and campaign/scenario membership;
- both two-session parent/child lock orders under `READ COMMITTED` and
  `SERIALIZABLE`; each case verifies through `pg_stat_activity` that the second
  transaction is actively waiting on a lock before the first may commit;
- the deliberate `REPEATABLE READ` ownership guard, while ordinary content
  updates and valid detail inserts remain allowed;
- creature Tier names, dragon tiers, numeric base speeds and generated labels;
- one complete 43,736-row catalog import and exact comparison of every supplied
  JSON field and every non-null FK described by the semantic schema;
- a second import with a whole-database fingerprint proving that rows and
  physical IDs are stable.

`HW_EXPECTED_ROWS` is an intentional change gate. When reviewed data is added
or removed, update the workflow and this document in the same change after the
new total has been independently verified.

GitHub Actions runs the deterministic checks and Node tests once, then runs the
opt-in integration suite against clean PostgreSQL 16 and 18 service containers.
It does not deploy, migrate, or connect to a live HeroesWatch database.
