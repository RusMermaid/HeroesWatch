# Catalog coverage and PostgreSQL handoff

Updated 2026-10-13. The frozen cumulative [JSON](heroeswatch.json) contains
**43,736 rows across 176 table arrays**. The October 4 deployment receipt is a
historical 40,023-row snapshot using reviewed overlay version 2 and migration
0002; it is not a live deployment claim for this frozen research package.

**Historical friend delivery receipt (2026-10-04):** pgAdmin was reported to
have committed the migration, manual catch-up, corrections and all seven
touch-up parts to **HeroesWatch.net**. That earlier review returned **40,023
rows, 176 tables, 23 games and 36 PDF manual records**, with database owner
**postgres**. This receipt is not current deployment evidence for the frozen
current package.
See the [deployment record](live-deployment.json) and
[review query](live-deployment.review.sql).

**2026-10-13 Mac updates:** Both upgrades used restored-backup preflight. The
first 43,613-row import preserved the original 659 rows. The later update adds
123 Olden Era rows, fills 108 descriptions, renames creature `Level` to `Tier`,
stores H1/H2 speed as numbers with generated names, and sets the four dragon
tiers to 8/8/9/10. No identities were removed.
See [the completion record](../reviews/2026-10-13/COMPLETION.md) and
[machine-readable verification](../reviews/2026-10-13/publication-verification.json).
This is separate from the friend's historical Windows receipt. The earlier Mac
observation in [the data review](../reviews/2026-10-13/data-review.md) describes
its pre-upgrade state; the friend's database was not modified.

## Frozen 2026-10-13 source-backed research package

The reviewed research merge covered **14 accepted patch files**, adding **3,713
rows** and filling **667 explicitly null fields**, for the resulting **43,736
rows**. Stable identities were preserved. Tier naming, numeric H1 speeds and
the four dragon tiers are tracked separately from those research fills. The
package includes H1/H2 manual-backed abilities and starting skills, H3 rules,
town screens and campaign details, H5 costs/runes,
terrain/schools and named-hero starts, H8 systems and creature abilities,
normalized junction completion, H8 hero specializations and Neutral Magic.

The deterministic audit trail is [research-2026-10-13-evidence.json](research-2026-10-13-evidence.json).
The generated [research-import.sql](research-import.sql) contains 5,599 rows
including dependencies. Existing databases need migrations through 0005 and
`creature-tier-corrections.sql` before current imports.
The human completion review is [COMPLETION.md](../reviews/2026-10-13/COMPLETION.md).
The Oct 4 friend receipt remains historical evidence about that snapshot only.

## Earlier manual import and comparison

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

On 2026-09-30, the [six-conflict query](manual-conflicts.review.sql) was
reported run in the then-current **HeroesWatch.net** database through pgAdmin.
It returned all six rows in 99 ms; every database value matched the retained
catalog baseline. This is historical evidence for those six values, not current
deployment evidence or confirmation of every field in the comparison report.

Sources and scope: [I–III](manual-homm1-3.sources.md),
[IV–VI](manual-homm4-6.sources.md), [RPGs](manual-mm-rpg.sources.md),
[spin-offs](manual-spin-offs.sources.md), [inventory](manual-inventory.json),
and [per-row evidence](manual-content-evidence.json).

### Manual-batch PostgreSQL status

The manual batch was **reported committed on 2026-10-04** through pgAdmin in
**13.342 seconds**, during the historical delivery recorded above. It is part
of that earlier 40,023-row snapshot; no current deployment is claimed here.

[manual-import.sql](manual-import.sql) remains a **4.3 MB** catch-up subset
containing 3,939 rows: the manual additions and enriched rows plus their foreign
key dependencies. It is generated from the cumulative catalog and content
evidence by `node src/db/tools/build-manual-sql.mjs`. It uses the same transactional
importer and preserves existing IDs and non-null values. It can bring another
pre-manual catalog forward; repeat application resolves existing rows.

Both SQL files passed required JSON, relationship and ownership validation.
The cumulative SQL's deterministic check passed. Current regression and isolated
PostgreSQL results are recorded in the [touch-up review](TOUCHUPS_STATUS.md#schema-and-tests).
The six historical discrepancy checks above remain the evidence for the unresolved
manual disagreements.

## Original requested catalog scope

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
| Olden Era | 146 | 30 | 5 | 93 | 302 | 3 | 194 |

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
- Thirty-five VI/VII creature identities still lack a complete detail row because
  required statistics remain unavailable or ambiguous; five were recovered in
  the touch-up. Unsupported artifact classes
  in I/IV/VI/VII retain generic identities. The schema's ENUMs are not changed
  merely to force incomplete source values into detail tables.
- Classic resource identity and H1-H5 membership/classification coverage now
  includes seven `ResourceHOMM1To5` rows and the reviewed memberships. Optional
  mine-yield, market-value, and map-pile fields remain NULL because they are
  game/edition-dependent and were not normalized without a common primary
  source.
- Olden Era now has supported `GameHOMM8` and `CampaignHOMM8` rows plus the
  reviewed creature-ability graph, but `ScenarioHOMM8`, `MapHOMM8`,
  `MagicSchoolHOMM8`, `ResourceHOMM8`, `AstrologyHOMM8`, and `FactionLaw` detail
  rows remain held. Exact law positions/source paths and the Astrology Insight
  resource identity still need source/schema reconciliation. Neutral Magic is
  now represented; unsupported negative flags are not asserted.
- Heroes IV secondary-only ability tables remain held. No generic class-derived
  abilities or HeroSkill rows are added without direct mechanic evidence.
- Heroes VI/VII source/rank-dependent creature and class details remain held;
  H7 warfare rank vectors, movement/footprint fields, and the 110 unverified
  Hall flags are not replaced with defaults or false values.
- `LoreFull` currently has 22 evidence-backed links (five Hero, twelve
  Campaign, and five Faction); it has no current CampaignHero, Scenario, or Map
  endpoint rows. The schema supports those paths, but current lore coverage does
  not claim that all endpoint kinds are populated.
- Spell and artifact identities are complete against the documented source
  rosters; many optional effect formulas, upgrade prices, perk prerequisites
  and historical balance variations remain unencoded. Source notes distinguish
  direct values from the uniquely invertible VI defense calculations.
- Dwelling-object-to-faction/creature relationships now use
  `AdventureObjectFaction` and `AdventureObjectCreature`. Town recruitment uses
  `BuildingCreature`; these are separate relationships.
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
`ArtifactSetBonusHOMM5` has a `UNIQUE NULLS NOT DISTINCT` constraint matching
the importer's set, required piece count and optional-class identity.
Ambiguous existing or incoming matches stop the import rather than creating
duplicate bonuses. Migration 0002 adds this database constraint.

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

On 2026-09-30, the cumulative **27,915-row import was reported committed** to
the registered **HeroesWatch.net** database on PostgreSQL 18 through the user's
authenticated pgAdmin session. The recorded execution response was `COMMIT`
and "Query returned successfully in 56 secs 581 msec." This remains historical.

At that handoff, pgAdmin was open on `catalog.sql` and its successful result.
No optional review queries, independent row comparison or test suite were run
for this addition, following the user's instruction to skip verification.
