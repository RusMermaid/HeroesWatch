# Olden Era missing details

Reviewed **2026-10-14** against installed Steam build **25061458**. The installed
manifest still identifies that build; its queued target build is not used.
The patch reads `Core.zip` and the installed `maps/Story_maps` files directly.
Every action records the source paths and SHA-256 checksums. Raw game files,
localization prose, artwork, and map scripts stay outside Git.

**October 16 independent review:** the catalog, evidence records and generator
were checked, but the original Windows game files were not available here.
Hashes identify the recorded inputs; they do not let another reviewer repeat
the extraction without those inputs. The generator mixes decoded fields with
hand-authored summaries and catalog classifications, as distinguished below.

## Result

`olden.patch.json` has **70 additions and 63 null fills**. Existing keys and
non-null catalog values are preserved.

| Added detail family | Rows |
|---|---:|
| Alternative creature attacks | 9 |
| Magic schools | 5 |
| Resources | 11 |
| Astrology | 1 |
| Maps | 21 |
| Scenarios | 21 |
| Tutorial/challenge campaigns | 2 |

The 63 fills are width, height, and player-slot count for the 21 existing maps.
All scenarios receive objective summaries and mission rules; 20 receive
supported starting-treasury values. These details describe available evidence,
not a complete simulation of every script or supported mode.

## Alternative attacks

All nine missing ability identities were matched by localized name against
every existing creature membership. All matched native definitions occur in
`DB/units/units_logics/**.alternativeAttacks` with `basic_attack` tags. Their
display definitions occur at the same index in `DB/units/units_views/**`.
They are separate from the native `abilities` collection.

The architecture now defines `IsActive` as a player-chosen action, including
an alternative basic attack. `IsFocusAction` identifies the dedicated Focus
ability family, including explicitly zero-cost Focus abilities. Consequently
these attacks use `true`, `false`, and `true` for `IsActive`, `IsFocusAction`,
and `IsAlternativeAttack` respectively.

Seven Fighting Style entries explicitly state that they spend no Focus, so
their `FocusChargeCost` is zero. General Melee Attack and Free Target retain
null cost because their display does not specify a numeric value. Cooldowns
remain null; the native `-1` sentinel is not converted into an invented number.
The shared Melee Attack effect retains its existing general wording because
individual creatures have different damage modifiers.

## Astrology and schools

The same-build tutorial resolves the previous uncertainty about three related
names. `Lang/english/texts/tutorial.json`, token
`tutorial_M_28_3_5_new`, explicitly describes city Astrology Point income,
accumulation granting Insight, and spending Insight to learn or upgrade
powerful Global Map spells. Token `tutorial_C6_1` and UI token
`help_text_spells` corroborate the relationship. The Altar of Insight's
localized definition and `starDust` spell learning/upgrade costs identify the
spendable resource.

`AstrologyHOMM8` therefore references the existing Neutral Magic, Astrology
Points, and Insight identities. Main-city-building levels generate 500, 750,
and 1,000 Astrology Points daily in this build. The source contains five
different threshold arrays in `DB/astrology_exp/astrology_exp.json`; their
first thresholds and lengths are retained in the evidence. The active
selection is not established, and their increments are not globally constant,
so both optional threshold scalars remain null.

The four regular schools use Mage Guild/Observatory progression. High Neutral
spells additionally use the Astrology/Insight system. `UsesAstrology` means
the school includes spells governed by that system; it does not mean every
spell in the school requires Insight. Regular schools have tier ceiling 5;
the installed Neutral spells reach tier 4. Effective spell levels reach 4.

The official [Spellcasting article](https://wiki.hoodedhorse.com/Heroes_of_Might_and_Magic_Olden_Era/Spellcasting)
corroborates the Observatory, regular schools, and effective level cap.
The public [Neutral Spells article](https://wiki.hoodedhorse.com/Heroes_of_Might_and_Magic_Olden_Era/Neutral_Spells)
describes a different progression model. It does not override this explicitly
identified installed build. The catalog does not combine that model's
numbers with the retained build's statistics.

## Resources

`DB/resources_exchange.json` and `DB/objects_logic/res_mines/mines.json`
establish positive trading and mine-production flags. Their exact native
resource IDs are retained in the evidence. Other flags remain null. Persistence
is also left unknown because its contract was not defined by the reviewed
source. No omission is converted into a false flag.

Mine yields are described as amounts **per owned mine**, rather than inserted
as unconditional `DefaultDailyIncome`. Law Points, Astrology Points, and
Insight retain their distinct identities and mechanics.

## Maps, missions, and tutorial groups

Each existing scenario's native `mapSid` selects its exact mission variant.
The `.map` package is gzip-compressed and begins with length-prefixed hash,
editor-version, and JSON metadata fields. The extractor checks the repeated
map hash before using `sizeX`, `sizeZ`, or `spawns.playersCount`. These values
fill map dimensions and player-slot counts; the editor version becomes
`MapHOMM8.DefinitionVersion`.

`campaigns/**/missions/*.json` supplies available difficulties, side types,
hero-selection counts, explicit spell/faction-law/guild restrictions, and
starting treasuries. The objective summaries are hand-authored entries in
`build-olden.py`, attributed to quest definitions and English localization.
The script parses and hashes the map quest JSON but does not inspect its quest
conditions when producing those summaries. In particular, it does not assert
the three reported `ResCounter >= 10` conditions for Crystal, Gems and Mercury,
or the challenge deadlines. These need source-path assertions or a separate
manual-review record before they can be described as independently reproduced.

`GameMode=Scenario` describes the authored mission category. `MapKind=Campaign`
is a catalog classification applied to all 21 mission assets, including the
ten tutorial/challenge maps; it is not decoded from their headers. Mission
numbers are parsed from mission identifiers. The raw numeric
mode in a saved map header is not treated as proof of all playable modes.
Single-player support is established by the campaign pipeline and explicit
human side. Other mode capabilities, terrain-level count, and underground
presence remain null. The header's `IsMatchMakingGame=false` is a stored
session default, not proof that an asset can never support matchmaking.

Tutorial has two mission nodes; Challenges has eight. Neither grouping
defines numbered acts. `AvailableActCount` is therefore null under the revised
contract rather than a fabricated zero. Tutorial's explicit progression
transfer flag is retained in its rules.

### Source inconsistency

`campaigns/tutorial/missions/Tutorial_Mission_1.json` enables difficulty index
1, but all variant difficulty entries use index 0. The engine's fallback
behavior is not established here. Advanced Tutorial's `StartingState` remains
null and the discrepancy is recorded in the patch's `held` section.

## Reproduction and checks

Run with the **pristine pre-patch catalog** and schema overlay v7:

```text
python src/db/research/2026-10-14/build-olden.py \
  --assets PATH/TO/HeroesOldenEra_Data/StreamingAssets \
  --manifest PATH/TO/steamapps/appmanifest_3105440.acf \
  --catalog PATH/TO/pristine.heroeswatch.json \
  --schema src/db/schema/heroeswatch.schema.json \
  --output PATH/TO/olden.patch.json
```

The generator checks the installed build, exact existing identities, null
preconditions, every alternate-attack membership, tutorial node counts,
Astrology localization markers, and map metadata framing. It uses only Python's
standard library and does not connect to PostgreSQL.

Remaining reproducibility work: retain a small, account-free build manifest
record; assert alternate-attack logic/view correspondence instead of relying
only on array position; and verify the hand-authored objectives, campaign
narrative and resource descriptions separately from the decoded values. No
full game installation or redistribution of game assets is needed in Git.

Repository merge dry-run passed for this patch: **70 additions, 63 fills,
44,002 resulting rows** against the 43,932-row baseline. Integration,
PostgreSQL application, and PR delivery are performed by the parent batch.
