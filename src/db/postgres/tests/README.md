# PostgreSQL integrity tests

These tests require an approved, isolated database. They must not be run against
`HeroesWatch.net` or another working catalog. None of these files starts a server.

## Single-session cases

Create the empty current schema with `../schema.sql`, then run
`game-integrity.sql` using `psql --no-psqlrc --set ON_ERROR_STOP=1`. The fixture
rejects a nonempty `Game` table and rolls back all changes.

It covers inherited title ownership, parent reassignment, global media,
per-game resource membership, nullable business identities, prerequisite
alternatives and group modes. It also covers pending rows that are deleted or
replaced, a transient mismatch repaired before validation, and later edits
after `SET CONSTRAINTS ALL IMMEDIATE`.

## Concurrent parent reassignment and detail insertion

Use two separate connections to the same isolated schema. Commit a fixture
with two `Game` rows (`HOMM2` and `HOMM3`) and one `Creature` owned by `HOMM3`,
with no detail row. The examples call its ID `:creature` and the HOMM2 ID `:h2`.

### Child obtains the parent lock first

1. In connection A, begin a transaction, insert `CreatureHOMM3` for the
   creature, and run `SET CONSTRAINTS ALL IMMEDIATE`. Leave the transaction open.
2. In connection B, begin a transaction and update the creature's `Game_id`
   to `:h2`. The update should wait for A's shared ownership lock.
3. Commit A. B must reject its reassignment during update or commit because
   the committed detail requires HOMM3. Roll B back after the error.

### Parent obtains the write lock first

1. Restore the fixture without a detail row. In connection B, begin a
   transaction and update the creature's `Game_id` to `:h2`, without committing.
2. In connection A, begin a transaction, insert `CreatureHOMM3`, and run
   `SET CONSTRAINTS ALL IMMEDIATE`. A should wait for B's parent lock.
3. Commit B. A must reject its detail because the parent now belongs to HOMM2.
   Roll A back after the error.

Run both orders under READ COMMITTED and SERIALIZABLE. A serialization failure
(`40001`) or detected deadlock (`40P01`) is also a valid rejection under concurrent
edits. Both conflicting writes must never commit together.

Repeat both orders under REPEATABLE READ. The ownership-changing update must
be rejected with `0A000` (a serialization failure while obtaining an earlier
lock may also reject it). This restriction is deliberate: the transaction's
old snapshot can otherwise miss the new child after waiting for the parent
lock. Retrying the ownership change requires READ COMMITTED or SERIALIZABLE.
Also check that a normal content-field update and a valid insert still commit
under REPEATABLE READ; the restriction must not become a blanket write ban.

After each case, check that this query returns no rows:

```sql
SELECT d."Creature_id", g."SeriesCode"
FROM heroes_watch."CreatureHOMM3" d
JOIN heroes_watch."Creature" c USING ("Creature_id")
JOIN heroes_watch."Game" g USING ("Game_id")
WHERE g."SeriesCode" IS DISTINCT FROM 'HOMM3';
```

Repeat the two orders with an initially global `MediaAsset`: one connection
adds a HOMM3 consumer while the other assigns the asset to HOMM2. This checks
the nullable-global ownership path independently of title-detail checks.

Record actual command results and database version when these tests are run.
The presence of these files alone does not establish that PostgreSQL testing
has occurred.
