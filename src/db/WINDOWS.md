# Windows handoff

The HeroesWatch database is portable. Do not copy a macOS PostgreSQL data
directory to Windows. Transfer either of these checked-in files:

- `HeroesWatch.sql` — plain PostgreSQL SQL; the most universal option.
- `HeroesWatch.backup` — PostgreSQL custom-format, schema-only backup.

Both contain the same empty structure: 173 tables, 1,285 fields, 159 ENUM
types, 349 foreign keys, and 228 supporting indexes. Neither contains game
rows.

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

Expected result: DBeaver displays 173 tables under the `heroes_watch` schema.

## Option B: restore the backup

1. Create an empty database named `HeroesWatch`.
2. In DBeaver, right-click the database and choose `Tools → Restore`.
3. Select `HeroesWatch.backup` and PostgreSQL custom format.
4. Keep owner/privilege restoration disabled if the Windows username differs
   from the Mac username.
5. Run the restore and refresh `Schemas → heroes_watch → Tables`.

The backup was created with `--schema-only --no-owner --no-privileges`, so it
is operating-system and username independent. It was restored into a third
clean PostgreSQL 18.6 database and passed the same verification checks as the
plain SQL file.

## Verification

After either method, open `postgres/verify.sql` and execute it. It must report:

```text
tables       173
columns      1285
foreign_keys 349
```

The schema SHA-256 reported by the verifier must be:

```text
b04dd68ee09f7a1f86c055a2e3d01c690daf2791343ad7ca33bc637c59a58673
```

The initial SQL is intentionally clean-install only. Run it once in an empty
database; it will fail safely instead of overwriting an existing
`heroes_watch` schema.
