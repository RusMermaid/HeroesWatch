# Screenshot review: implemented changes and delivery

Updated 2026-10-04. The cumulative catalog contains **40,023 rows across 176
table arrays**. This update adds **9,542 rows**, fills **1,233 null fields**,
and corrects **six existing fort labels**. No baseline row or stable key is
removed. The six disputed manual values remain unchanged.

## Findings addressed

| Requested change | Result |
|---|---|
| Combination-artifact regression | Count restricted to Heroes III; Heroes II's valid combination remains included in its own catalog. |
| Gargoyle growth / Genie cost | Manual-confirmed growth 6 and gold cost 650 filled. Genie's separate one-gem cost is retained. |
| Six Heroes VI fort labels | Extracted image filenames removed from `Name`; keys and codes preserved. |
| Olden Era `???` | Installed localization also contains `???`; source uncertainty is explicit in its description. |
| JSONB contracts | All 141 columns have policies: 51 typed profiles and 90 null-only until a source profile is defined. |
| Junction identity | Stable `_cid` keys retained; nullable-safe uniqueness and explicit prerequisite groups added. |
| Game/resource integrity | Composite FKs, deferred ownership checks and cost-to-GameResource FKs protect direct database edits. |
| Faction lore / external dwellings | Faction subject FK plus two dwelling relationship tables, populated from sources. |
| Missing detail rows | Four VI creatures, VII Kraken, and 22 VII Hall heroes added where required values are supported. |

## Relationship coverage

- Heroes III: **478 faction/spell links**, **103 named abilities** and **287
  creature/ability links**. Native spell selection weights have their own field.
- Dwellings: **525 object/creature links** (including 39 Olden Era guard-type
  links) and **275 object/faction links** across all eight Heroes games.
- All **83 Heroes campaigns** now have scenario membership: **373 scenarios**
  and **316 progression edges**, including the sixty existing Heroes V scenarios.
- Original Heroes III maps: **417 terrain memberships** and **5,401 links to
  placed object types matching the catalog**.
- Heroes V: **404 prerequisite groups**, **518 prerequisite atoms**, and
  1,212 of this update's null fills. Existing association keys are retained.
- Five faction-lore links, two missing cost links, two creature-upgrade links
  and seven town recruitment links added.
- **68 of 120** campaign/hero records now identify a supported starting scenario.

## Remaining source gaps

The source review still cannot supply **35 complete creature detail rows**
(16 VI, 19 VII), **15 class detail rows** (six VI, nine VII), or the Hall flags
for **110 VII heroes**. Required fields are listed individually in the
[detail follow-up](touchups-late-details.sources.md). The VII gaps concern
warfare units with rank-dependent values and incomplete movement/size evidence.

Map terrain and object-placement joins currently describe the parsed Heroes III
campaign maps. Equivalent placement coverage for other games, every optional
hero mechanic and every native campaign condition are not claimed complete.
Undocumented prerequisite associations remain ungrouped; null does not mean
that the ability has no prerequisites. All six earlier manual disagreements
remain in [the comparison report](MANUAL_COMPARISON.md).

## Schema and tests

The current schema has **176 tables, 1,304 columns, 450 foreign keys and 160
ENUM types**. The original diagram snapshot and `0001_initial.sql` are preserved.
The reviewed overlay generates a forward-only
[`0002_relationship_integrity.sql`](../postgres/migrations/0002_relationship_integrity.sql).

JSON shape checks run in the validator and JSON Schema. PostgreSQL itself
enforces relationship integrity, including direct SQL/GUI edits. The concurrency
tests found and corrected a stale-snapshot race. Ownership-changing updates
require READ COMMITTED or SERIALIZABLE; ordinary inserts and content edits
continue to work under REPEATABLE READ.

Fresh bootstrap, upgrade from the populated initial schema, twelve concurrent
ownership/media cases and five isolation controls passed in disposable local
test databases on port 55439. Zero invalid rows remained after the final cases.
The live deployment is recorded below.

All **48 Node tests** pass. On populated isolated PostgreSQL databases, both the
full import and the smaller-file route produced exactly 40,023 rows and the
same physical IDs. Their changes match the evidence: 9,542 additions, 1,233
null fills and six corrections. All 30,481 baseline IDs were preserved; repeat
imports changed no data or IDs. See [the test summary](touchups-test-results.json).

## Apply to an existing database

1. Apply migration 0002 once. Use `HeroesWatch.sql` only for a new empty database.
2. Apply `manual-import.sql` to catch up a catalog that predates the manual batch.
3. Apply `touchups-corrections.sql` for the six guarded label corrections.
4. Apply all seven `touchups-import-*.sql` files in manifest order.

[The manifest](touchups-import-manifest.json) lists every part. Each part is
transactional, includes its FK dependencies, preserves local IDs and rejects
unknown conflicting facts. Repeat application resolves existing rows. The full
`catalog.sql` is also current, but the smaller files avoid loading one large
document in pgAdmin. Never reapply the initial bootstrap over a populated schema.

## Confirmed live deployment

On **2026-10-04**, migration 0002, the manual catch-up, guarded corrections and
all seven import parts **committed successfully to HeroesWatch.net** through
pgAdmin. Parts 03–07 used the reviewed server-file loader, which verified each
file's SHA-256 before executing it in one transaction.

Parts 03–07 and the final read-only query completed in **22.146 seconds** and returned
**40,023 rows, 176 tables, 23 games and 36 PDF manual records**. The database
owner is **postgres**. See the [deployment record](live-deployment.json) and
[live review query](live-deployment.review.sql).

| Confirmed step | pgAdmin duration |
|---|---:|
| Migration 0002 | 33.631 seconds |
| Manual catch-up | 13.342 seconds |
| Six guarded label corrections | 0.286 seconds |
| Import part 01 | 18.146 seconds |
| Import part 02 | 6.326 seconds |

These live results confirm deployment and the reported totals. The detailed
field comparisons and repeated-import ID checks are documented in the isolated
test results above. Remaining source gaps are unchanged.

## Sources and audit trail

- [Priority corrections, abilities, dwellings and costs](touchups-priority.sources.md)
- [Campaigns, maps and faction lore](touchups-graphs.sources.md)
- [Heroes V prerequisites](touchups-prerequisites.sources.md)
- [VI/VII detail evidence and remaining fields](touchups-late-details.sources.md)
- [Exact additions, preconditions and source evidence](touchups-evidence.json)
