# Catalog coverage and PostgreSQL handoff

Updated 2026-09-30. The cumulative [JSON](heroeswatch.json) contains **30,481
rows across 173 table arrays**. The manual import adds **2,566 rows** to the
previous 27,915-row catalog and fills **774 previously null fields**. All earlier
rows and non-null values are retained. The schema and initial migration are
unchanged.

## Manual import and comparison

The local collection contains 38 files, deduplicated by SHA-256 into **36 PDF
source records**. The import adds 2,156 RPG rows, 316 spin-off rows, 57 Heroes
rows, 36 manual records and one comparison-report media record. Supported Heroes
fills comprise 568 fields in I–III and 206 in IV–VI.

Might and Magic I–X, Swords of Xeen, Crusaders, Warriors, Shifters and Legends
have independent game identities and use generic catalogs. Platform differences
in Crusaders are labeled explicitly. There are no new RPG-specific tables.
The original PDFs are stored locally and excluded from Git; PostgreSQL stores
their metadata and relative file URIs.

The [manual report](MANUAL_COMPARISON.md) records **7,264 observations**:
6,286 matches, 163 edition/reference differences, six unresolved existing-value
conflicts, and documented gaps, manual errors and naming variants. No existing
non-null mechanic was replaced. The fan Heroes VIII proposal and mod manuals
have metadata only; no authentic Heroes VII or Olden Era manual was found.

On 2026-09-30, the [six-conflict query](manual-conflicts.review.sql) was run in
the live **HeroesWatch.net** database through pgAdmin. It returned all six rows
in 99 ms; every database value matched the retained catalog baseline. This
confirms those six live values, not every field in the full comparison report.

Sources and scope: [I–III](manual-homm1-3.sources.md),
[IV–VI](manual-homm4-6.sources.md), [RPGs](manual-mm-rpg.sources.md),
[spin-offs](manual-spin-offs.sources.md), [inventory](manual-inventory.json),
and [per-row evidence](manual-content-evidence.json).

### Manual-batch PostgreSQL status

The manual-batch application is **not confirmed**. pgAdmin became unresponsive
while loading the 33 MB cumulative SQL file. An execution input was attempted,
but no completion or rollback result could be observed; two window-recovery
attempts timed out. The standard `psql -w` connection had no reusable password.
The last confirmed full import remains the earlier 27,915-row transaction below.

For resuming, [manual-import.sql](manual-import.sql) is a **4.3 MB** subset
containing 3,939 rows: the manual additions and enriched rows plus their foreign
key dependencies. It is generated from the cumulative catalog and content
evidence by `node src/db/tools/build-manual-sql.mjs`. It uses the same transactional
importer and preserves existing IDs and non-null values. Inspect the pending
pgAdmin query's result before resuming; repeat application resolves existing rows.

Both SQL files passed required JSON, relationship and ownership validation.
The cumulative SQL's deterministic check passed. No separate regression test
suite was run for this content batch. The six live discrepancy checks above
were performed as part of the requested manual comparison.

## Requested scope

The latest request extends every listed category across Heroes I–VIII and
their official expansions: factions, classes, heroes, town buildings,
external dwellings, faction and neutral creatures, skills, schools, spells,
artifacts, campaigns and general adventure objects. Each game uses its own
mechanics and factions. HOMM8 is this repository's identifier for
**Olden Era**, whose released Early Access build 25061458 supplies the data.

| Game | Factions | Classes | Named heroes | Town buildings | Map dwellings |
|---|---:|---:|---:|---:|---:|
| I | 4 | 4 | 36 | 60 | 7 |
| II, The Succession Wars, The Price of Loyalty | 6 | 6 | 77 | 171 | 22 |
| III, Restoration of Erathia, Armageddon's Blade, Shadow of Death | 9 | 18 | 156 | 318 | 83 |
| IV, Gathering Storm, Winds of War | 6 | 48 | 310 | 172 | 71 |
| V, Hammers of Fate, Tribes of the East | 8 | 8 | 124 | 292 | 34 |
| VI, adventure packs, Shades of Darkness | 6 | 36 | 139 | 185 | 18 |
| VII, Lost Tales of Axeoth, Trial by Fire | 7 | 44 | 132 | 343 | 21 |
| Olden Era Early Access | 6 | 12 | 112 | 206 levels | 57 |

## Additional category coverage

| Game | Creatures | Skills | Schools | Spells | Artifacts | Campaigns | Map objects, including dwellings |
|---|---:|---:|---:|---:|---:|---:|---:|
| I | 28 | 4 | — | 29 | 39 | 1 | 41 |
| II | 66 | 14 | — | 65 | 99 | 6 | 89 |
| III | 141 | 32 | 4 | 70 | 141 | 20 | 187 |
| IV | 74 | 36 | 5 | 151 | 205 | 18 | 215 |
| V | 177 | 25 | 6 | 80 | 93 | 13 | 150 |
| VI | 109 | Ability model | 7 | 89 | 224 | 11 | 101 |
| VII | 156 | 24 | 7 | 70 | 224 | 11 | 141 |
| Olden Era | 146 | 30 | 4 | 93 | 302 | 3 | 194 |

Heroes I and II do not have spell schools. Heroes VI progression uses its
ability tree, represented by `AbilityHOMM6`, rather than invented conventional
skill rows. Olden Era's three campaign groups are Main Story, Tutorial and
Challenges; only released Act I is represented for the main story. Artifact
counts include sourced quest items and scroll variants, as documented below.

Heroes VI also adds six adventure-map forts. Faction-neutral sites are included
in the dwelling counts. IV's advanced classes are not exclusive to one town.
Olden Era's 206 rows distinguish the building levels defined by its game files.
Heroes I groups equivalent dwelling artwork and labels the snow hut variant.
Heroes II includes 54 standard recruitable heroes and 23 named scenario/campaign
characters. Heroes III's 83 dwellings include random dwelling and Refugee Camp.

Heroes III adds four primary and 28 secondary skills, four spell schools,
70 spells, 76 school memberships, 141 artifacts, 49 combination-component
links, 20 campaigns, and 187 interactive object types. Its terrain catalog
now has ten base surfaces and ten magical overlays. HotA, WoG, and other
unofficial content are excluded.

## Known gaps

- Six VI Dungeon classes and nine VII classes have catalog identities but
  lack game-detail rows because required statistics are missing or conflict
  across sources. Their faction links cannot yet be stored in those details.
  Exact names and evidence are in the [VI](homm6-catalog.sources.md) and
  [VII](homm7-catalog.sources.md) notes.
- VII's 21 external dwellings use explicitly marked editorial faction/tier
  labels; exact English localization is not verified.
- I's snow hut name has an editorial terrain qualifier. II's Roland Ironfist
  and Drakonia have scenario-dependent classes and retain null class FKs.
- Some hero class references and optional mechanics remain null. Same-name
  Heroes V entries with multiple playable classes are documented as such.
  Olden Era covers the 108 standard heroes plus four named Act I protagonists;
  unused and unlocalized definitions are not presented as released heroes.
- Forty VI/VII creature identities lack a complete detail row because required
  statistics remain unavailable or ambiguous. Unsupported artifact classes
  in I/IV/VI/VII retain generic identities. The schema's ENUMs are not changed
  merely to force incomplete source values into detail tables.
- Spell and artifact identities are complete against the documented source
  rosters; many optional effect formulas, upgrade prices, perk prerequisites
  and historical balance variations remain unencoded. Source notes distinguish
  direct values from the uniquely invertible VI defense calculations.
- The current architecture has no dwelling-object-to-faction/creature
  junction. Objects are separate catalog rows, and no hidden relationship
  arrays are inserted in JSONB. Town recruitment uses `BuildingCreature`.
- This is a researched reference catalog, not a complete transcription of
  biographies, all mechanics, campaign mission graphs, decorative scenery,
  or every custom named hero instance in shipped scripts.

## Sources

[I–II catalog](homm1-homm2-catalog.sources.md), [III classes/heroes/buildings](homm3-catalog.sources.md),
[III magic](homm3-magic.sources.md), [III world](homm3-world.sources.md),
[III terrain](homm3-terrain.sources.md), [IV](homm4-catalog.sources.md),
[V](homm5-catalog.sources.md), [VI](homm6-catalog.sources.md),
[VII](homm7-catalog.sources.md), [Olden Era](homm8-catalog.sources.md).

Latest additions: [I–IV](remaining-homm1-4.sources.md),
[V](remaining-homm5.sources.md), [VI–VII](remaining-homm6-7.sources.md),
[Olden Era](remaining-homm8.sources.md). Eight additional game-resource
memberships follow directly from sourced recruitment or building costs.

Only structured facts and concise mechanics enter the bundle. Research
fragments and raw source caches are ignored; they are not alternate imports.
The cumulative JSON is the content source of truth.

## Validate and generate

```sh
node src/db/tools/validate.mjs src/db/data/heroeswatch.json
node --test src/db/tools/validate.test.mjs src/db/tools/catalog.test.mjs
node src/db/tools/build-content-sql.mjs
node src/db/tools/build-content-sql.mjs --check
node src/db/tools/generate.mjs --input src/db/schema/sql-designer.snapshot.json --out src/db --check
```

The builder creates [catalog.sql](catalog.sql), a complete cumulative import
for an **existing** `heroes_watch` schema. It resolves natural keys to local
IDs, preserves existing IDs and non-null values, fills sourced missing values,
and rejects conflicting facts. Foreign keys remain enabled; the complete
transaction is checked before commit. The only helpers are temporary objects.
Sequence gaps after a failed attempt are normal PostgreSQL behavior.
`ArtifactSetBonusHOMM5` has no declared alternate unique key; the importer
matches its set, required piece count and optional class under the table lock.
Ambiguous existing or incoming matches stop the import rather than creating
duplicate bonuses. This policy adds no schema constraint or migration.

Run the whole file in a fresh pgAdmin Query Tool session connected to the
intended database, then run [catalog.review.sql](catalog.review.sql). For psql:

```sh
psql -X -v ON_ERROR_STOP=1 -h HOST -p PORT -U USER -d DATABASE -f src/db/data/catalog.sql
psql -X -v ON_ERROR_STOP=1 -h HOST -p PORT -U USER -d DATABASE -f src/db/data/catalog.review.sql
```

Use pgAdmin's password prompt or a local PostgreSQL password file. Credentials
do not belong in the repository. An empty database first needs the existing
schema-only `HeroesWatch.sql`; never execute that baseline over a populated
schema. Old individual batch scripts remain historical snapshots.

## Earlier verification and execution policy

The following results describe the earlier catalog/importer work. Per the
user's instruction at that stage, the 15,328-row addition did not run a test suite,
independent database comparison, or optional review query. The SQL builder's
required contract validation and normal PostgreSQL constraints still apply.

- Structural validation, same-game FK checks, game-detail ownership, unique
  keys, and catalog regression tests passed.
- All ten generated schema artifacts match the saved diagram, including on
  Windows checkouts with CRLF line endings.
- PostgreSQL 18.4 imported all 12,587 rows over the original 659-row dataset.
  Each original database row was compared before and after and remained equal.
- Repeat imports preserved identities and counts. Existing notes and custom
  junction IDs survived; missing sourced values were filled.
- A deliberately conflicting fact aborted the transaction and rolled back
  earlier new inserts. Non-null JSONB `null` conflicts are also rejected.
- Whole-script submission through libpq, as a GUI can submit it, passed with
  `standard_conforming_strings` initially off. Apostrophes, backslashes and
  dollar-quote delimiters round-tripped correctly. All review queries executed.

The earlier complete-import check used an isolated local test cluster.
Repeat-import and conflict tests used the 7,917-row catalog.

## Earlier PostgreSQL application

On 2026-09-30, the cumulative **27,915-row import committed successfully** to
the registered **HeroesWatch.net** database on PostgreSQL 18, through the
user's authenticated pgAdmin session. The execution response was `COMMIT`
and "Query returned successfully in 56 secs 581 msec."

At that handoff, pgAdmin was open on `catalog.sql` and its successful result.
No optional review queries, independent row comparison or test suite were run
for this addition, following the user's instruction to skip verification.
