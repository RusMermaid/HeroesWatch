# Olden Era global systems and resource parents

Target: Olden Era Early Access build **25061458**, snapshot 2026-09-29.
Review date: 2026-10-13.

## Staged actions

`homm8-systems.patch.json` adds six source-backed rows:

| Table | Key |
|---|---|
| `Resource` | `resource.law.points` |
| `GameResource` | `homm8.resource.law.points` |
| `Resource` | `resource.astrology.points` |
| `GameResource` | `homm8.resource.astrology.points` |
| `Patch` | `homm8.patch.steam.build.25061458` |
| `GameHOMM8` | `homm8.game` |

The official game-data import identifies native `faction_laws_points` and
`astrology_exp` resources on 2026-05-13. Dated mechanics pages consistently
call them **Law Points** and **Astrology Points**. They are scoped to H8 through
`GameResource` and introduced by the base Early Access release.

No `ResourceHOMM8` detail is staged. Its required negative booleans
(`IsTradeable`, `IsMineProduced`) and persistence contract are not all
explicitly stated by a coherent target-aligned source. Generic identity and
game membership do not require those guesses.

## Completed GameHOMM8 profile

Dated official mechanics revisions plus the retained installed-build identity
establish the complete required profile:

| Field | Value | Evidence |
|---|---:|---|
| `FocusPointsPerCharge` | 6 | Focus revision 17487, 2026-05-15 |
| `DefaultFocusChargeCap` | 3 | Focus revision 17487, 2026-05-15 |
| `LawSealCap` | 100 | Laws revision 19237, 2026-05-23 |
| `LawTier1Seals` | 0 | Laws revision 19237 |
| `LawTier2Seals` | 5 | Laws revision 19237 |
| `LawTier3Seals` | 15 | Laws revision 19237 |
| `LawTier4Seals` | 30 | Laws revision 19237 |
| `LawTier5Seals` | 50 | Laws revision 19237 |
| `ReleaseStatus` | EarlyAccess | Official Steam release and retained base-release row |
| `CombatGrid` | Hex | Combat System revision 40878, 2026-09-04 |
| `MaximumHeroSkills` | 8 | SkillRollTable revision 18180, 2026-05-19 |
| `CurrentPatch_id` | Steam build 25061458 | Retained installed snapshot, 2026-09-29 |

The official FactionLawTier definition independently records the same
`[0, 5, 15, 30, 50]` values for all six factions in its 2026-05-05 corpus.

Sources:

- [Focus oldid 17487](https://wiki.hoodedhorse.com/Heroes_of_Might_and_Magic_Olden_Era/index.php?oldid=17487&title=Focus)
- [Laws oldid 19237](https://wiki.hoodedhorse.com/Heroes_of_Might_and_Magic_Olden_Era/index.php?oldid=19237&title=Laws)
- [FactionLawTier definition](https://wiki.hoodedhorse.com/Heroes_of_Might_and_Magic_Olden_Era/Template:FactionLawTierDef)

`Patch.Version` is free text, not a semantic-version enum. The staged Patch
row therefore uses the truthful label `Steam build 25061458`, with a note that
it is the installed build observed by the retained snapshot rather than an
undocumented semantic version. `GameHOMM8.CurrentPatch_id` references it.

The v0.80.18 changelog dated 2026-06-01 documents extensive balance changes and
a Sprint-template-specific reduction to Astrology/Law point level costs. It
does not identify Steam build 25061458 or contradict the global Focus and Law
Seal constants above. The patch row does not claim that mapping.

## Faction-law audit

Official Cargo documentation describes:

- 198 production laws;
- one to three levels per law;
- faction membership and tier;
- per-level resolved effects and costs;
- separate LawTreePosition records for screen placement.

LawTreePosition revision 13223 defines `side` as `faction|army` and
`slot` as a zero-based index within faction+tier+side. Each production law
has exactly one position.

No `FactionLaw` rows are staged because the HeroesWatch table requires
`ScreenSide`, `SlotIndex`, and `SourcePath`. Category values in the public
six faction-law overviews establish faction-versus-army side, and the template
establishes slot semantics, but all 198 concrete slot/source-path values were
not exposed by the reviewed pages.

There is also a source-semantic conflict that must be resolved first:
`LawLevelDef` calls its `cost` a law-points cost, while player-facing faction
tables display the same cost column with Law Seal icons and the HeroesWatch
columns are named `SealCostLevel1..3`. Importing 198 laws before resolving
that discrepancy would silently assign the wrong unit.

## Astrology boundary

Official game-data pages establish native `starDust` and `astrology_exp`
identities. Only Astrology Points are staged because their player-facing name
is independently verified. `starDust` remains held: its display/role contract
was not established from a dated official page.

`AstrologyHOMM8` is still blocked structurally. It requires a
`NeutralMagicSchool_id`, while the retained target extractor deliberately
models only Daylight, Nightshade, Arcane, and Primal schools and keeps neutral
spells outside an invented fifth school. No fake school is added.

## Verification boundary

This patch does not alter earlier ability/campaign patches, cumulative JSON,
generated SQL, GitHub, or a live database. It is intended for the research
merge tool's dry-run before any parent integration.
