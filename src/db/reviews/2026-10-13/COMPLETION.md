# HeroesWatch — PR #1 review

October 13, 2026. Changes extend the existing
[PR #1](https://github.com/RusMermaid/HeroesWatch/pull/1), starting at `2848f00`.

## Changes

- Creature `Level` is now **`Tier`**. Spell levels are unchanged.
- Faerie/Rust/Crystal/Azure Dragon tiers are **8/8/9/10**, stored directly.
- H1/H2 `Speed` is numeric. `SpeedName` is generated and cannot disagree with it:
  H1 uses 1/2/3; H2 uses 2–7. Flying stays separate.
- The catalog has **43,736 rows**: 3,713 research additions and 667 null fills.
  This includes H1/H2 abilities and skills, H3 campaign rules and town links,
  H5 costs/prerequisites/hero starts, and Olden Era abilities, hero
  specializations, Neutral Magic and fourteen spell memberships.

[Exact data audit](../../data/research-2026-10-13-evidence.json) ·
[Speed evidence](../../research/2026-10-13/creature-terminology.sources.md) ·
[Olden Era follow-up](../../research/2026-10-13/oldenera-followup.sources.md)

## Architecture

The identity spine, shared-PK details, `_cid` junctions, single `Hero` catalog
and indirect lore links are preserved. There are **176 tables, 1,306 columns,
452 FKs and 29 junction tables**.

Migration 0003 fixes nullable identities, campaign starting-scenario membership
and H5 rune-resource membership. Migration 0004 renames creature tiers; 0005
makes early speeds numeric and derives their labels. Existing migrations stay
immutable. [Junction audit and remaining guards](JUNCTION_AUDIT.md).

## Checks

**94 tests pass.** PostgreSQL 18.6 fresh import, repeated import, restored-backup
upgrade and concurrency checks pass. Exact reconciliation covers 43,736 rows,
255,398 supplied fields and 174,633 FK references.

The local upgrade preserves all 43,613 prior row IDs. After accounting for
renamed fields and the speed conversion, only the four dragon tiers change
existing values. It adds 123 Olden Era rows and fills 108 descriptions.
The friend's database is untouched.

[Current verification](publication-verification.json) ·
[Earlier local checkpoint](completion-verification.json) ·
[Read-only viewer](../../data/completion.review.sql)

## Applying this to an existing database

Back up first. Apply only missing migrations in order through **0005**.
Then run `data/creature-tier-corrections.sql`, followed by `data/catalog.sql`
and `postgres/verify.sql`. Stop on an unexpected-value conflict; do not delete
rows to force an import. Historical standalone creature imports use the old
schema—use the current full catalog instead.

## Remaining gaps

- H6: 16 creature and six class details.
- H7: 19 warfare details, nine class details, 110 Hall flags and missing
  creature-ability/recruitment mappings.
- Olden Era: exact law positions, Insight/Astrology meaning and some required
  resource/map flags.
- H4 ability candidates still lack primary per-creature evidence.
- Some map placements, hero forms, army probabilities and media remain unknown.

Small, versioned game-data exports would resolve the main gaps. Missing facts
have not been turned into invented values. The database is usable, not complete.
