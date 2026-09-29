# Catalog coverage and PostgreSQL handoff

Reviewed 2026-09-29. The cumulative [JSON](heroeswatch.json) contains **12,587
rows across 173 table arrays**, including 11,928 additions. All 659 previously
committed rows are preserved exactly. The schema, architectural layers, and
initial migration are unchanged.

## Requested scope

The catalog uses the actual factions from Heroes I–VIII for classes,
heroes, town buildings, and external dwellings. The separate skills, magic,
campaigns, artifacts, and general map-object request applies to Heroes III
and its official expansions. HOMM8 is this repository's identifier for
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
| Olden Era Early Access | 6 | 12 | 108 standard | 206 levels | 57 |

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
  Olden Era covers the 108 standard heroes; campaign/tutorial variants and
  unused definitions are not presented as additional verified heroes.
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

## Verification completed

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

The complete-import check used an isolated local test cluster. Earlier
repeat-import and conflict tests used the 7,917-row catalog and the same
importer. **Application to the user's registered `HeroesWatch.net` database
remains pending PostgreSQL authentication.** pgAdmin was opened but requested
the postgres password; no new catalog transaction was submitted there.
The user requested no further verification. The prepared import may be executed
after signing in, without running the optional review queries.
