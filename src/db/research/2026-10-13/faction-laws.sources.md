# Olden Era faction-law research

Review date: 2026-10-13. This is the latest official Cargo snapshot visible on
that date. The wiki does not publish a Cargo-to-Steam-build mapping, so this
patch is not silently labelled as build 25061458.

## Result

`faction-laws.patch.json` stages **194** complete `FactionLaw` rows:

| Faction | Rows |
|---|---:|
| Temple | 32 |
| Necropolis | 32 |
| Grove | 31 |
| Hive | 30 |
| Schism | 35 |
| Dungeon | 34 |
| **Total** | **194** |

The earlier figure of approximately 198 was not authoritative. The live
official `LawTreePosition` table is the cardinality source because a production
law must occupy exactly one screen position. It contains 194 rows, and every
one joins one-to-one to a non-test `Law` row. The complete set is staged; no
slot is invented and no unpositioned/test row is imported.

## Exact official joins

- [Law Cargo table](https://wiki.hoodedhorse.com/Heroes_of_Might_and_Magic_Olden_Era/Special:CargoTables/Law):
  source-native ID, faction, tier, maximum level and exact `SourcePath`.
- [LawTreePosition Cargo table](https://wiki.hoodedhorse.com/Heroes_of_Might_and_Magic_Olden_Era/Special:CargoTables/LawTreePosition):
  faction, tier, side and exact zero-based slot. The official
  [definition revision 13223](https://wiki.hoodedhorse.com/Heroes_of_Might_and_Magic_Olden_Era/index.php?oldid=13223&title=Template:LawTreePositionDef)
  states that slot is the index within each side's law array.
- [Laws Overview revision 23355](https://wiki.hoodedhorse.com/Heroes_of_Might_and_Magic_Olden_Era/index.php?oldid=23355&title=Laws_Overview),
  dated 2026-06-14 14:58: resolved English name, complete per-level effects,
  and displayed Law Seal costs.
- [Laws revision 19237](https://wiki.hoodedhorse.com/Heroes_of_Might_and_Magic_Olden_Era/index.php?oldid=19237&title=Laws):
  Law Points raise faction level, each new level awards a Law Seal, and Seals
  are spent on laws. It also says each higher-level description states the
  complete upgraded effect, not merely the delta. Therefore
  `Cumulative=true`: `EffectLevelN` is the cumulative total at level N and must
  not be added to the preceding level's text.
- [LawsOverview module revision 23354](https://wiki.hoodedhorse.com/Heroes_of_Might_and_Magic_Olden_Era/index.php?oldid=23354&title=Module:LawsOverview):
  documents the live join across Law, Translation, LawLevel and
  LawTreePosition and its sort order: faction, tier, side, slot.

The source-definition phrase “law-points cost” conflicts with the player-facing
mechanic and icon. The patch follows the explicit player-facing separation and
stores the displayed spend in `SealCostLevel1..3`; it does not rename the
architecture or mix tier-unlock point thresholds with enactment costs.

## Verification

- 194 distinct source law IDs.
- 194 distinct HeroesWatch `_key` values.
- 194 distinct `(Faction_id, Code)` identities.
- 194 distinct `(Faction_id, Tier, ScreenSide, SlotIndex)` placements.
- All six H8 faction parents exist.
- Tier range is 1–5; slot indexes are non-negative and source-native.
- `MaxLevel` range is 1–3.
- Every row has exactly `MaxLevel` non-null Seal costs and effects.
- Every row has an official non-empty English name, effect, and source path.
- All 335 level effects are concise, newly worded mechanical summaries rather
  than copied overview prose. Per-level source hashes remain in action evidence.
- Numeric-token comparison passed for all 335 source/summary pairs, preserving
  every amount, percentage, tier, duration, threshold, cap, and multiplier.
- No normalized summary equals its official source sentence.
- Standard research merge dry-run passed: 194 additions, zero fills, 43,930
  resulting rows, and no files written by the validator.

## Reproduction boundary

`research-faction-laws.mjs` requires explicit bounded snapshots for the three
official tables, the reviewed `faction-laws.summaries.json`, and an explicit
pristine catalog. It rejects duplicate/missing IDs, mismatched cardinality or
ordering, unknown faction parents, invalid level shapes, changed numeric-token
sequences, lost player/friendly/enemy/summoned scopes, duplicate screen
positions, verbatim summaries, and already-integrated `FactionLaw` data. The
official snapshots are extraction inputs and are not committed copies of source
prose; the committed summary file contains only original mechanical wording and
row indexes for revision 23355.
