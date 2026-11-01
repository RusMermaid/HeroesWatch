# Final PR review and architecture corrections — October 13, 2026

> This is the **40,023-row audit checkpoint**, completed before the user expanded
> the request to collect missing content. See [the completion record](COMPLETION.md)
> for subsequent data additions and the current verification/deployment status.
> Statements below about unchanged catalog content apply to the audit checkpoint.

Reviewed [PR #1](https://github.com/RusMermaid/HeroesWatch/pull/1), **Populate
Heroes catalogs and strengthen database integrity**, at
`2848f0055c6a39ce3ef9b6cea61f717593bf4be5`. It is open and unmerged.
The corrections below are local on `codex/heroeswatch-final-review`; they have
not been pushed, merged, or applied to a working database.

## Outcome

The final contribution is substantially improved and preserves the architecture.
It is a working, internally consistent **40,023-row reference catalog**, not a
complete set of every game's mechanics. Fresh PostgreSQL import and upgrade
from the previous 30,481-row catalog work. All previous physical IDs survive.

Two remaining database integrity gaps were corrected with a forward migration,
not by rewriting the model: nullable business-key uniqueness and campaign
starting-scenario membership. Ingestion checks, generated documentation, source
gap documentation, and repeatable database testing were also improved.

No game facts were invented or changed during this review. The cumulative
`heroeswatch.json`, original diagram snapshot, and already-deployed migrations
`0001_initial.sql` and `0002_relationship_integrity.sql` are unchanged.

## What your friend already completed

The final PR includes these improvements over `225a96b`:

- Composite game-ownership and resource-membership foreign keys; deferred
  checks for inherited game ownership, detail-table suffixes and global media.
- Prerequisite groups and nullable-safe prerequisite-atom/set-bonus identities.
- Faction subjects in `LoreFull`, without moving subject FKs onto `Lore`.
- `AdventureObjectCreature` and `AdventureObjectFaction`, preserving town
  recruitment in `BuildingCreature`.
- Separate spell selection weights and occurrence probabilities.
- All 83 campaigns have scenario membership: 373 memberships and 316 edges.
- 525 object/creature links, 275 object/faction links, 715 faction/spell links,
  868 creature/ability links and 404 prerequisite groups.
- 417 map/terrain memberships and 5,401 mapped object-type presences, principally
  from parsed Heroes III campaign maps.
- Gargoyle growth, Genie cost and six fort-name corrections; five previously
  missing creature detail rows and 22 Heroes VII Hall flags.
- Explicit policies for all 141 JSONB columns: 51 typed profiles and 90
  null-only policies pending reviewed source contracts.

The independent upgrade comparison agrees exactly with the PR's change claim:
**9,542 additions, 1,233 null fills, six existing-name corrections, zero removed
rows, and all 30,481 prior physical IDs retained**.

## Corrections made in this review

### 1. Nullable identities now really prevent duplicate identities

`MediaAsset(Game_id, Code)`, `Patch(Game_id, Version, Platform)`, and the
`LoreFull` subject tuple previously used ordinary UNIQUE constraints. Null key
members could therefore permit duplicate global media, unspecified-platform
patches or repeated lore associations. The importer tried to reject ambiguous
identities, but direct SQL/GUI entry could bypass that protection.

Migration [0003](../../postgres/migrations/0003_nullable_identity_and_campaign_scope.sql)
uses `UNIQUE NULLS NOT DISTINCT` for those existing business keys. This changes
enforcement, not their columns or stable IDs. Null remains allowed; two otherwise
identical null-valued business identities are no longer distinct.

This follows [PostgreSQL's documented NULL uniqueness semantics](https://www.postgresql.org/docs/18/ddl-constraints.html#DDL-CONSTRAINTS-UNIQUE-CONSTRAINTS).
An invalid pre-existing duplicate makes the entire migration fail and roll back;
the migration never silently deduplicates or discards rows.

### 2. Campaign hero starting scenarios now belong to their campaign

The earlier FKs proved that a starting scenario existed in the same game, but
not that it belonged to the campaign on the `CampaignHero` row. The new FK is:

```text
CampaignHero(Game_id, Campaign_id, StartingScenario_id)
  → CampaignScenario(Game_id, Campaign_id, Scenario_id)
```

All 68 supplied starting-scenario links already satisfy this rule. Unknown
starting scenarios remain NULL. `CampaignHero` remains a contextual Hero–Campaign
junction with `IsCampaignHero`; no second hero catalog was introduced. The
small-import dependency closure now includes the exact campaign membership.

### 3. Generated documentation now maps composite FK columns correctly

The data dictionary previously displayed the first referenced column for every
member of a composite FK. For example, it could label `StartingScenario_id` as
referencing `Game_id`. The generator now maps each local component to its
corresponding referenced component. The database's actual target was not changed
by this documentation correction.

### 4. Ingestion safety and regression checks

- Stable portable `_key` formatting now matches the declared JSON contract.
- TEXT and nested JSON string checks reject PostgreSQL-invalid U+0000 and lone
  UTF-16 surrogate values before SQL generation can reject or replace them.
  Cyrillic, CJK, emoji and other valid Unicode remain supported.
- ISO calendar validation correctly handles years 0001–0099 and Gregorian
  leap-year boundaries.
- Nullable duplicate identities are rejected consistently during validation,
  including cases where two reference aliases resolve to the same parent.
- Generated imports identify migration 0003 as the required current schema.
  The small-import manifest lists 0002 then 0003 and keeps its compatibility field.
- Deployed migration hashes are pinned by tests so future generator changes
  cannot silently rewrite their history.
- [TESTING.md](../../TESTING.md) documents the opt-in disposable PostgreSQL suite.
  GitHub Actions is configured for PostgreSQL 16 and 18; remote CI has not yet
  run these unpushed changes.

## Architectural assessment and query paths

| Design choice | Architectural result and query implication |
|---|---|
| Universal identity spine | Preserved. Start with `Game` and a generic identity; use optional title detail only when needed. This avoids duplicated catalogs. |
| Shared-PK detail tables | Preserved. `CreatureHOMM3.Creature_id` is also its generic creature's ID. Missing detail must display as unknown, not make the generic entity vanish through an INNER JOIN. |
| `_cid` junction identities plus compound uniqueness | Preserved. A TEXT `_cid` is a stable single-column physical key; the composite UNIQUE is the relationship's business key. The suffix itself is not a composite PK or a proof of normalization. |
| Same-game ownership | Native composite FKs protect directly game-owned endpoints; deferred checks cover inherited ownership and global media. This also protects direct database entry. |
| Campaign context | `Campaign → CampaignHero → Hero`; optional starting scenario now follows the same campaign's membership. |
| Indirect lore links | `Lore → LoreFull → Hero/Campaign/Faction/...`. No second lore catalog or direct subject FKs on Lore were added. |
| Shared resources | `Game → GameResource → Resource`, with optional `ResourceHOMM1To5`. Do not INNER JOIN the currently empty detail table if the query should return existing memberships. |
| JSONB for variable source payloads | Manageable with explicit contracts. JSON validation is an ingestion responsibility; arbitrary direct SQL JSON writes are not checked against every JSON Schema profile by PostgreSQL. |
| Version provenance | Expansion, patch and source metadata remain separate from identity. Olden Era is the recorded Early Access build, not a claim of permanently final mechanics. |

The Heroes III paths are specifically:

```text
Game → Faction → FactionHOMM3 → Terrain
Game → Faction → CreatureHOMM3 → Creature
Game → Faction → FactionSpell → Spell → SpellHOMM3
Game → Creature → CreatureHOMM3
Creature → CreatureResourceCost → GameResource → Resource
Campaign → CampaignScenario → Scenario → Map
Lore → LoreFull → CampaignHero → Hero
```

`FactionHOMM3` does not itself hold every creature/spell association. Join the
appropriate game-constrained junction or title-detail relation. Prefer LEFT
JOIN for genuinely optional detail, media, lore or unknown mechanics.

The project targets 2NF for ordinary tables and explicitly exempts `_cid`
junctions from its automated normalization policy. No new concrete normalization
violation was found. The policy report is a declared-key regression check,
not a mathematical proof of all functional dependencies or universal 3NF/BCNF.

## Data completeness: what remains incomplete

| Game | Creature identities | Creature detail rows | Missing detail rows |
|---|---:|---:|---:|
| Heroes I | 28 | 28 | 0 |
| Heroes II | 66 | 66 | 0 |
| Heroes III | 141 | 141 | 0 |
| Heroes IV | 74 | 74 | 0 |
| Heroes V | 177 | 177 | 0 |
| Heroes VI | 109 | 93 | 16 |
| Heroes VII | 156 | 137 | 19 |
| Olden Era / HOMM8 | 146 | 146 | 0 |

Complete detail-row coverage is not a claim that every optional field is filled.
Known open items include 15 class details, 110 Heroes VII Hall flags, six manual
disagreements, empty shared-resource details, several empty HOMM8 detail bands,
and incomplete optional effects, campaign rules, maps and placements.

All 176 table arrays are represented; 129 contain rows and 47 are empty. The
22 lore associations target five heroes, twelve campaigns and five factions.
CampaignHero-, Scenario- and Map-targeted lore paths exist structurally but have
no current content. The supplied PDF bytes are not in Git, so this review did not
independently re-read all original manuals. See [the detailed data review](data-review.md).

The detail notes now explicitly distinguish the five resolved creatures from
the remaining missing-field list. No numeric stats were guessed to make a table look
complete. No new exactly-one-subject CHECK was imposed on `LoreFull`: whether
multi-subject contextual links are allowed remains a design decision.

## Verification and delivery boundaries

Tests used a separate PostgreSQL 18.6 cluster with a private Unix socket and no
TCP listener. They did not modify an existing HeroesWatch database. The review
checked both the exact incoming PR and the corrected local version.

- All **58 Node tests pass**, with no skipped or failed tests.
- Fresh current DDL and full import pass.
- Every supplied row/field reconciles: 40,023 rows, 237,507 fields.
- The corrected semantic model has 176 tables, 1,304 columns and 451 FKs.
- Current constraints include 176 PKs, 81 alternate UNIQUEs, 92 composite FKs,
  five NULLS NOT DISTINCT unique indexes, and 176 ownership constraint triggers.
- Same-game, inherited/global ownership, resource membership, prerequisite,
  nullable-identity and campaign-context rejection probes pass.
- Repeated full imports preserve rows and physical IDs.
- Both full and smaller-file routes reconcile all 40,023 rows, 237,507 fields
  and 159,412 non-null FK references; their data and physical IDs are identical.
- Four concurrent lock-order cases pass under READ COMMITTED/SERIALIZABLE,
  with actual lock overlap verified, plus the REPEATABLE READ guard and allowed
  ordinary-write controls.
- Populated initial-schema upgrade and smaller-file delivery are tested against
  the prior 30,481-row baseline, not only against empty schemas.
- Invalid pre-existing duplicate identities reject migration 0003 atomically.
- Deterministic schema, cumulative, manual and touchup artifacts are checked.

Machine-readable results are in [verification-results.json](verification-results.json).
Read-only [route comparison](verify-delivery.mjs) and
[baseline-ID comparison](compare-upgrade.mjs) helpers accompany this report.
Only PostgreSQL 18.6 was executed locally; the configured PostgreSQL 16 CI job
has not yet run on GitHub.

Your friend's October 4 deployment receipt refers to their local pgAdmin
database. It is not a live connection verified from this Mac. A separate
read-only check found this Mac's older `HeroesWatch` database still has 173
tables, six games and 152 creatures. Neither that database nor the friend's
database was upgraded by this review.

## Next application order

1. Back up the actual intended target and confirm its current schema and catalog.
2. For an existing v2 database, review and apply migration 0003 once. If duplicates
   or invalid campaign memberships are found, investigate them; do not delete them
   automatically to force the migration through.
3. For an initial-schema database, apply 0002 then 0003. Use either the reviewed
   cumulative route (guarded corrections, then `catalog.sql`) or the manifest's
   manual catch-up, corrections and seven content parts.
4. For a new empty database, use the current complete schema, then `catalog.sql`.
   Never bootstrap over a populated database.
5. Run structural verification and exact source/DB reconciliation on that target.
   The disposable integration suite is for testing and is not a live migration tool.

## Priorities after this review

1. **Apply the verified corrections to the intended target after backup.** Local
   validation does not make GitHub or either working database current.
2. **Complete source-backed gaps**, especially the 35 missing creature and 15
   class detail records. Keep unknown and inapplicable values distinct.
3. **Define shared-resource detail ownership and lore link cardinality** before
   adding more enforcement or copying per-game values into shared fields.
4. **Expand source/mechanics coverage** for remaining title bands, lore endpoints,
   maps and optional JSON profiles. Preserve edition/patch evidence.
5. **Keep automated checks required for future PRs.** CI validates consistency
   and behavior; it cannot prove every gameplay fact against the original games.
