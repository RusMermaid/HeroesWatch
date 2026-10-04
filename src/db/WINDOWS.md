# Windows handoff

The HeroesWatch database is portable. Do not copy a macOS PostgreSQL data
directory to Windows. Transfer either of these checked-in files:

- `HeroesWatch.sql` — plain PostgreSQL SQL; the most universal option.
- `HeroesWatch.backup` — historical initial schema, PostgreSQL custom format.

The current SQL creates 176 tables, 1,304 fields, 160 ENUM types and 450 foreign
keys. The backup contains the original 173-table contract and requires
`postgres/migrations/0002_relationship_integrity.sql` afterward. Neither
contains game rows.

## Free software

Use the free editions of:

- PostgreSQL: https://www.postgresql.org/download/windows/
- DBeaver Community: https://dbeaver.io/download/

DBeaver Community is open source and is not DBeaver PRO or a trial.

## Option A: open the SQL file

1. Install PostgreSQL and DBeaver Community.
2. Create an empty PostgreSQL database named `HeroesWatch`.
3. In DBeaver, create a PostgreSQL connection to:
   - Host: `localhost`
   - Port: `5432`
   - Database: `HeroesWatch`
   - Username/password: the values selected during PostgreSQL installation.
4. Open `HeroesWatch.sql` in DBeaver's SQL Editor.
5. Execute the entire script once.
6. Refresh `Schemas → heroes_watch → Tables`.

Expected result: DBeaver displays 176 tables under the `heroes_watch` schema.

## Option B: restore the backup

1. Create an empty database named `HeroesWatch`.
2. In DBeaver, right-click the database and choose `Tools → Restore`.
3. Select `HeroesWatch.backup` and PostgreSQL custom format.
4. Keep owner/privilege restoration disabled if the Windows username differs
   from the Mac username.
5. Run the restore and refresh `Schemas → heroes_watch → Tables`.
6. Execute `postgres/migrations/0002_relationship_integrity.sql` once to upgrade
   the initial schema to the current contract.

The backup was created with `--schema-only --no-owner --no-privileges`, so it
is operating-system and username independent. It was restored into a third
clean PostgreSQL 18.6 database and passed the same verification checks as the
plain SQL file.

## Verification

After either method, open `postgres/verify.sql` and execute it. It must report:

```text
tables       176
columns      1304
foreign_keys 450
```

The original diagram SHA-256 reported by the verifier remains:

```text
b04dd68ee09f7a1f86c055a2e3d01c690daf2791343ad7ca33bc637c59a58673
```

The current contract additionally includes reviewed overlay version 2; the
unchanged diagram hash alone does not describe those added constraints.

The initial SQL is intentionally clean-install only. Run it once in an empty
database; it will fail safely instead of overwriting an existing
`heroes_watch` schema.
