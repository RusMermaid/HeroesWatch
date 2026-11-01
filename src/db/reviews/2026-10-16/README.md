# Final PR data review — October 16, 2026

Your friend's update is substantial and is present in PR #1. Most of the
specific gaps raised in the previous review have been filled. The database is
not yet a complete record of every game mechanic, however: an entity, an
ability name and a fully described mechanic are different levels of coverage.

Reviewed commits: `9450e79` and `6e0753a`, compared with `7ad2a6b`.
The catalog remains **45,616 rows in 176 tables**, with **1,309 columns and
452 foreign keys**. This review does not deploy, merge the PR or alter game facts.

## What your friend completed

| Area | Verified additions |
|---|---|
| Heroes IV | 76 ability identities, 76 detail rows and 167 creature links across all 74 catalogued creatures. |
| Heroes V | 103 starting armies, 11 specialty-name fills and 22 starting-skill links. |
| Heroes VI | All 109 creature and 36 class identities now have details; 577 creature-ability links. Boss profiles are intentionally partial. |
| Heroes VII | All 156 creatures and 44 classes have details; 249 creature-ability links, 12 warfare recruitment links, and five source-listed profiles for each of 19 warfare units. |
| VII heroes | 72/132 have positive Hall evidence, up from 22. The other 60 remain unknown, not false. |
| Olden Era | Nine alternative attacks, five schools, eleven resource details, Astrology, 21 map and scenario details, and two tutorial/challenge campaign details. |

The independent comparison found **1,684 added rows, 211 null-only fills,
zero removed identities and zero replacements of previously populated fields**
relative to `7ad2a6b`. Between the two friend commits, nine absent properties
were also added to three newly introduced VII warfare JSON profiles. These are
not nine additional rows or replacements of established numerical values.

The full measured inventory is [catalog-audit.json](catalog-audit.json).
Counts describe existing catalog identities, not proof that every shipped
script, variant, expansion edge case or future release has been enumerated.

## Remaining data work

Suggested order: VII hero starts and VI/VII creature mechanics first; then IV
town economy and the concrete model limitations below; then mission/lore and
media coverage. Source disputes should be settled before filling their fields.

### 1. Hero and creature mechanics

- **VII hero starts:** all 72 current hero detail rows lack starting armies,
  starting attributes, starting spells, starting-skill links and specialization
  links. The other 60 heroes lack detail rows because their required Hall flag
  is unknown. Start with small, version-labelled editor/game-data exports.
  Do not infer `false` from an incomplete roster or campaign participation.
- **VI/VII creature abilities:** 215 VI and 120 VII ability identities have
  no game-detail row. The new links identify abilities, but do not fully encode
  durations, formulas, triggers, targeting or form restrictions. Per-creature
  `Parameters` is empty for all 167 IV, 577 VI, 249 VII and 826 Olden Era links.
  Some shared mechanics already live in ability details/descriptions; a null
  parameter document is not itself evidence that a parameter is required.
- **VI bosses:** 13 profiles lack raw defenses, footprint and movement; some
  additional speed/range/initiative fields are unknown. Displayed resistance
  percentages must not be substituted for raw defense points.
- **VII warfare:** all 19 footprints remain unknown. Five numerical profiles
  exist per unit, but the schema has no explicit skill/mastery-to-profile link.
  Rank-varying scalar nulls are intentional: use `WarfareStats.profiles`, not
  `COALESCE(Defense, 0)`.
- **V hero variants:** 21/124 starts remain unresolved: 18 identities are absent
  from the reviewed manual, while Nicolai, Orlando and Ornella have conflicting
  class-specific starts. Raven and Arantir have two starting spells but the
  current detail table has one spell slot. Preserve the variants; do not pick
  an arbitrary first row. [Evidence](../../research/2026-10-14/heroes45.sources.md).
- **III starting armies:** still unencoded because native slots include
  probabilities and war machines that the present JSON shape cannot preserve.
  **VI** has no populated hero-start mechanics. **Olden Era** has starts for
  108 standard heroes; four campaign heroes intentionally lack those defaults.

### 2. Town economy, schools and progression

- IV has no `BuildingResourceCost`, `BuildingRequirement` or `BuildingUpgrade`
  rows. Research costs and prerequisites first; verify which upgrade edges
  actually exist instead of assuming every building has one.
- V has six school identities but no `MagicSchoolHOMM5` details.
- Olden Era has no `HeroClassAbility` links. Class/subclass prerequisites need
  source review; distinct subclass identities and alternative hero-start forms
  may need a small architecture extension. Do not clone the universal Hero
  catalog to represent those contexts.
- Classic resources and H1–5 memberships are present. Game-dependent mine
  yields, exchange values and map-pile ranges are not fully normalized.

### 3. Spell and artifact effects

- V has 80/80 spell details, but no populated `EffectByMastery` documents.
- VII has 69/70 spell details; Reveal Treasure's numerical spell level is not
  established. IV's four generic-only spells are creature spells, so a hero
  spell level must not be invented for them.
- III has 141 artifact details but only 51 structured effects. Effect formulas,
  mastery scaling, sets, restrictions and version differences need further
  coverage across the other games too.
- Generic-only special items remain: I **1**, IV **41**, V **1**, VI **21**,
  VII **60**. They include quest items, scrolls, potions and Grail-like objects
  outside the current detail enums. Their identities are present. Decide the
  classification before adding rows; widening an enum merely to satisfy a
  row-count target is not sufficient research.

### 4. Campaigns, map rules and lore

The graph already contains **83 campaigns, 373 scenarios/maps, 373 campaign
memberships, 316 scenario edges and 124 campaign-hero links**. That does not
mean all mission content has been extracted.

| Game | Maps with no game-detail row | Scenarios with no game-detail row |
|---|---:|---:|
| I | 9 | 9 |
| II | 47 | 47 |
| IV | 70 | 70 |
| V | 60 | 60 |
| VI | 36 | 36 |
| VII | 43 | 43 |
| **Total** | **265** | **265** |

These identities and their campaign ordering exist; detailed victory/loss
conditions, starting states and map capabilities remain separate work.
Only III currently has terrain membership (417 rows), object placement
(5,401 rows) and town-screen building placement (318 rows).

II has **zero `CampaignHero` assignments**. Across all games, only 68/124
campaign-hero rows identify a starting scenario; a null may be legitimate or
unresearched and needs campaign-by-campaign checking.

There are 37 lore records and 22 `LoreFull` links: five to Hero, twelve to
Campaign and five to Faction. There are no CampaignHero, Scenario or Map
endpoints yet. Add sourced links through `LoreFull`; do not put entity FKs on
Lore. Soundtrack, Video and Screenshot catalogs also remain empty, if media
is included in the next content scope.

### 5. Olden Era source verification

The current data is explicitly scoped to recorded Steam build **25061458**.
The original Windows files were not available in this review. Their hashes,
extractor logic and merged facts can be inspected, but the extraction cannot
be independently repeated from hashes alone.

Concrete follow-up:

1. Export a small, account-free manifest record and the factual JSON fragments
   needed for verification; a full game installation is unnecessary.
2. Verify the 21 hand-authored objective summaries against specific quest
   conditions/localization keys. The generator parses and hashes the map
   scripts, but does not derive or assert the objectives from them.
3. Check the catalog classifications for the ten tutorial/challenge maps.
   `MapKind=Campaign` and mission numbers are authored/derived mappings, not
   direct header fields.
4. Assert alternative-attack logic/view correspondence rather than relying
   only on matching array positions.
5. Resolve the active Astrology threshold table, Advanced Tutorial difficulty
   mismatch, and optional map/resource flags from that same build. Keep
   unknowns null.

The current official [Spellcasting guide](https://wiki.hoodedhorse.com/Heroes_of_Might_and_Magic_Olden_Era/Spellcasting)
supports four regular schools, five spell tiers and four effective spell
levels. The [Neutral Spells page](https://wiki.hoodedhorse.com/Heroes_of_Might_and_Magic_Olden_Era/Neutral_Spells)
describes a different points progression from the retained build's
Astrology/Insight model. Do not mix those snapshots or call the retained data
verified against the latest game build. See the clarified
[Olden Era evidence notes](../../research/2026-10-14/olden.sources.md).

## Source-quality corrections

The V 3.1 reference is community-compiled, not an original publisher manual.
Its army panels still support the imported ranges. IV's evidence has a Unicorn
ability-label typo (`Blinding attack` instead of `Blind`) and an unrecorded
Terror-duration disagreement: the selected two-turn rule is not corroborated
by Prima's one-turn definition. These are now explicit in the
[IV/V evidence notes](../../research/2026-10-14/heroes45.sources.md), along with
the Summon Demons alias and incomplete Long Weapon summary. Historical patch
hashes and game facts have not been silently rewritten.

VI/VII's disputed defense/healing values remain explicit wiki-snapshot choices,
not independently verified native-game facts. Their alternatives are retained
in the [resolution notes](../../research/2026-10-14/h67-resolution.sources.md).
No new values were sourced from random forums in this review.

## Architecture and query paths

The latest additions preserve the architecture: one Hero catalog, shared-PK
game details, `_cid` junctions with business uniqueness, same-game ownership,
indirect lore, and shared resources through `GameResource`. Existing migrations
0001–0008 are not rewritten by this review. Creature `Tier`, numeric H1/H2
`Speed` with generated `SpeedName`, and dragon tiers 8/8/9/10 are preserved.

| Query | What works now / what must not be inferred |
|---|---|
| Game → Creature → game detail → CreatureAbility → Ability | Every catalogued I–VIII creature has a detail row. Ability links do not imply complete effect formulas. |
| Faction → Building → BuildingCreature → Creature | Recruitment is relational; the twelve new VII warfare purchase edges resolve to the correct faction buildings. Siege-only machines need not have purchase edges. |
| Game → GameResource → Resource → ResourceHOMM1To5 | Shared classic-resource identity and per-game membership work; missing optional economy fields are not zero costs. |
| Campaign → CampaignHero → Hero | There is no second hero catalog. II assignments and some context fields still need research. |
| Campaign → CampaignScenario → Scenario → Map | Ordering/branch edges work; a linked map does not imply decoded terrain or full mission rules. |
| Lore → LoreFull → subject | The path is enforced, but only Hero/Campaign/Faction endpoints currently have content. |

Queryable variant starts, special-item classifications and some currently
unprofiled mechanics need contract decisions before data entry. These are
targeted extensions, not a reason to replace the shared architecture.

- `HeroHOMM7.IsHallHero` is required. That currently prevents storing a partial
  hero detail when Hall eligibility alone is unknown. Consider a nullable
  eligibility flag or separately sourced eligibility record; never use false
  as a placeholder.
- A single V starting-spell FK cannot represent a two-spell start. A reviewed
  multi-spell relationship/contract is needed, with edition/class context where
  starts differ. Reuse the one canonical Hero identity.
- Special-item enum gaps and unprofiled JSON mechanics require explicit
  contracts before import. The existing validator deliberately refuses arbitrary
  payloads; leaving such values null is safer than bypassing that validation.

Not every missing detail row needs to be created. I/IV intentionally have no
hero-detail table. III's four primary skills do not belong in its secondary
mastery detail table. Boss tiers, warfare rank-varying scalars, nonrecruitable
growth and inapplicable campaign act numbers must not be filled with arbitrary
zeros merely to remove nulls. Conversely, III's seven generic-only terrain
mechanics and the empty I/II ability-detail bands are further enrichment work,
not missing terrain/ability identities.

## Verification and fixes

The fresh PostgreSQL 18.6 import and the populated upgrade both reconciled
**267,563 supplied fields and 180,672 references** across all 45,616 rows.
Repeated import preserved physical IDs. Direct rejection tests and concurrent
ownership, graph, resource and town-link probes passed. All 117 original Node
tests and deterministic artifact checks passed before the review changes.

The review also identified two gaps in automated handoff verification:

- The upgrade runner did not exercise the exact 45,560-row v7 snapshot followed
  by `0008 → h67-profile-enrichment.sql → research-gaps-import.sql`.
- The enrichment resolved mutable parent identities while locking only the
  detail table. Concurrent identity edits could invalidate its target lookup.

The follow-up adds that exact upgrade path, conflict/rollback and repeat-import
checks, protects enrichment targets, and reconstructs the pre-v8 schema without
silently retaining its later numeric type. Final results are recorded in
[verification.json](verification.json).

Final retest: **118/118 Node tests passed, zero skipped**. The exact v7 upgrade
also passed on PostgreSQL 18.6, preserved all **45,560 original physical IDs**,
and reconciled the final 45,616 rows. A conflict in the second JSON profile
rolled back the first profile's update and retained the conflicting local value.
Generated artifacts are current; no migration was changed.

Other changes correct stale coverage notes and distinguish hand-authored
source interpretation from automatically decoded fields. The catalog JSON and
game values are unchanged. Your friend's Windows deployment receipt remains
historical evidence; neither that database nor the Mac database was modified.

## Recheck this review

```sh
node src/db/reviews/2026-10-16/audit-catalog.mjs
node src/db/tools/validate.mjs src/db/data/heroeswatch.json
node --test src/db/tools/*.test.mjs
node src/db/tools/build-h67-enrichment-sql.mjs --check
```

The audit script reads the current checkout and compares it with `7ad2a6b`;
that commit must exist locally. Its saved JSON records the reviewed head, not
a promise that future commits have identical coverage. PostgreSQL integration
requires the explicit opt-in documented in the test runners and creates only
randomly named disposable databases. Deployment remains a separate task.
