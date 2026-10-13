# HeroesWatch — PR #1 review

October 13, 2026. Updates to the existing
[PR #1](https://github.com/RusMermaid/HeroesWatch/pull/1).

## Data

**43,932 rows**, including 196 additions since `1dbe176`:

- 194 Olden Era faction laws with exact positions, costs and source paths.
- Insight resource identity and its H8 membership.
- Law effects are short mechanical summaries with source hashes. Each level
  describes the total effect, not an amount to add to previous levels.

The laws use the official Cargo snapshot reviewed October 13. No exact mapping
to the earlier Steam build is claimed.
[Law sources](../../research/2026-10-13/faction-laws.sources.md) ·
[Insight sources](../../research/2026-10-13/olden-resources.sources.md) ·
[Full research audit](../../data/research-2026-10-13-evidence.json)

Creature `Tier`, dragon tiers **8/8/9/10**, numeric early-game `Speed` and
generated `SpeedName` remain unchanged.

## Database safeguards

Migration **0006** adds:

- Nonnegative costs; zero is valid.
- Required H8 resource membership, including reverse edits.
- Matching known town-screen/building factions.
- At least one lore subject; contextual multiple subjects remain allowed.
- No self-edges or cycles in component, prerequisite, upgrade and scenario graphs.

The architecture remains **176 tables, 1,306 columns, 452 FKs and 29 junctions**.
No duplicate catalogs, copied game IDs or deployment roles were added.
[Guard details](JUNCTION_AUDIT.md).

## Tests

**114 tests pass.** PostgreSQL 18.6 checks cover fresh and repeated imports,
populated v5→v6 upgrades, 16 concurrent writer cases and isolation controls.
Negative-cost and cyclic baselines reject migration 0006 atomically.

All 43,932 rows reconcile: **258,706 fields and 174,831 FK references**.
[Verification](data-guards-verification.json).

## Still missing

- H6: 16 creature and six class details.
- H7: 19 warfare details, nine class details, 110 Hall flags and some links.
  [Exact small game packages needed](../../research/2026-10-13/heroes7-final.sources.md).
- Olden Era: confirmed mapping between Astrology, neutral progression and
  Insight spending; some resource/map flags.
- H4 ability evidence and some map placements, hero forms and media.

No missing values were invented. **Deployment belongs to the second PR.**
This batch was tested in disposable databases, not applied to either working
database. When scheduled, apply missing migrations through 0006 before current
content imports; the previous tier-correction instructions still apply.
