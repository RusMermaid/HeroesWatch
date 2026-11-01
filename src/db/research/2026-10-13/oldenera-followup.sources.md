# Olden Era follow-up completion evidence

Target: **Heroes of Might and Magic: Olden Era**, repository series code
`HOMM8`, retained Early Access Steam build **25061458** dated 2026-09-29.
Review date: 2026-10-13.

`oldenera-followup.patch.json` is a source-reviewed patch only. It does not
change the canonical catalog, generated SQL, GitHub, or a database.

## Reproducing the patch

The generator deliberately has no temporary-file or current-catalog default.
It requires two explicit inputs:

```text
node src/db/research/2026-10-13/build-oldenera-followup.mjs \
  --snapshot /absolute/path/heroes-overview-oldid-32291.snapshot.json \
  --catalog /absolute/path/pristine-pr-baseline.heroeswatch.json \
  --output /absolute/path/oldenera-followup.patch.json
```

`--catalog` must be the pristine catalog state before this follow-up: all 108
specialization descriptions must still be null, their `AbilityHOMM8` rows must
be absent, and the Neutral Magic parent/links must be absent. Passing the
already-integrated catalog is intentionally rejected by those preconditions.

Create the local snapshot from the dated official
[Heroes Overview revision 32291](https://wiki.hoodedhorse.com/Heroes_of_Might_and_Magic_Olden_Era/index.php?title=Heroes_Overview&oldid=32291).
Its top-level object needs `revisionLink` containing `oldid=32291` and exactly
108 `rows`. Each row needs four non-empty strings:

```json
{"hero":"Ister","className":"Knight","specialty":"Wayfarer","description":"local source text"}
```

On the rendered table, each hero record is the eight-cell row followed by its
single-cell expanded specialization description. Normalize repeated whitespace
only; retain punctuation because the generator hashes the normalized source
description and independently normalizes hero/specialty punctuation for joins.
Keep this snapshot outside the repository: it is bounded extraction input, not
a committed copy of the official prose.

For the reviewed inputs, the generated patch SHA-256 is
`a9c8c2c4b17362967f0e096ba998b7fa48f8b06b8d62786976045270d97f9707`.

## Staged actions

| Action | Rows |
|---|---:|
| Fill `Ability.Description` for released hero specializations | 108 |
| Add `AbilityHOMM8` specialization details | 108 |
| Add the generic `Neutral Magic` school | 1 |
| Link officially enumerated spells to `Neutral Magic` | 14 |
| **Total** | **231** |

### Hero specializations

The official [Heroes Overview revision 32291](https://wiki.hoodedhorse.com/Heroes_of_Might_and_Magic_Olden_Era/index.php?title=Heroes_Overview&oldid=32291),
last edited 2026-07-23 15:48, contains all 108 released faction heroes,
their specialization names, and resolved English mechanics. Every displayed
hero was matched to the existing `Hero → HeroHOMM8.SpecializationAbility_id →
Ability` path. The patch aborts if any hero, name, key, null precondition, or
one-to-one mapping differs.

The official [HeroSpecialization definition revision 15885](https://wiki.hoodedhorse.com/Heroes_of_Might_and_Magic_Olden_Era/index.php?title=Template:HeroSpecializationDef&oldid=15885)
defines each specialization as the hero's unique passive. Therefore the new
sidecars use:

- `AbilityKind = HeroSpecialization`;
- `IsActive = false`;
- `IsFocusAction = false`;
- `IsAlternativeAttack = false`;
- null Focus cost, cooldown, parent skill, mastery and choice slot.

Descriptions and effects are concise, newly worded mechanical summaries. The
patch does not copy the overview prose. Each action retains the SHA-256 of the
normalized official description so a reviewer can reconcile it to the dated
source without embedding the source text.

### Neutral Magic

The official [Neutral Spells revision 21359](https://wiki.hoodedhorse.com/Heroes_of_Might_and_Magic_Olden_Era/index.php?title=Neutral_Spells&oldid=21359),
dated 2026-06-01 07:40, explicitly calls `Neutral Magic` a school and lists the
following fourteen spell identities:

- Magic Arrow;
- Necromancer Will;
- Back to Town!;
- Mana Rite;
- Relocation;
- Pocket Dimension;
- Second Wind;
- Shadowflight;
- Town Portal;
- Basic, Advanced and Expert Summon Avatar;
- Dimension Door;
- Gate of Light.

The patch adds one real same-game `MagicSchool` parent and exactly those
fourteen `SpellMagicSchool` rows. It does not assign nearby bonus spells merely
because their internal names look neutral. This resolves the previous concern
that a neutral parent would be an invented fifth school: the official source
expressly defines it.

No `MagicSchoolHOMM8` row is added for Neutral Magic. That sidecar requires
both `UsesObservatory` and `UsesAstrology`; the dated source establishes the
school, its tiered spell list and its point-based progression, but does not
define both booleans in those schema terms.

## Verification

The follow-up patch was checked against the current 43,613-row catalog:

- 108 official heroes matched 108 distinct existing specialization keys;
- 108 description fields were explicitly null before the fills;
- no specialization already had an `AbilityHOMM8` row;
- every specialization name matched after punctuation normalization;
- all 108 summaries are non-empty and none equals a source description;
- all fourteen neutral spell names resolved to existing H8 spell identities;
- the standard research merge dry-run passed with 123 additions, 108 fills,
  and 43,736 resulting rows.

## Remaining Olden Era blockers

| Area | Remaining issue |
|---|---|
| Nine alternative attacks | Identity and 826 creature memberships are complete. The official display proves `Alternative Attack` and often explicitly says that no Focus is spent, but it does not establish the schema's required `IsActive`/`IsFocusAction` combination without changing the meaning of those fields. |
| Four regular `MagicSchoolHOMM8` rows | School skill, tier-5 ceiling, four spell levels and Observatory use are source-backed. `UsesAstrology` is not defined by the official mechanics in the schema's terms, so required booleans are not guessed. |
| `AstrologyHOMM8` | The real Neutral Magic parent now exists, but the retained schema reflects an older mixed Astrology/Insight/neutral progression model. The required `InsightResource_id`, exact thresholds and unlock/upgrade contracts are not coherently established for build 25061458. |
| `ResourceHOMM8` | Generic resource identities and H8 memberships exist. Required negative booleans for tradeability, mine production and persistence are not inferred from omission. |
| `FactionLaw` | The official overview exposes names, factions, tiers, categories, effects and displayed Seal costs for 198 production laws. Cargo definitions establish source path and zero-based position fields, but the rendered overview does not expose each law's exact `SourcePath` and numeric slot. Keep `SealCostLevel1..3`: the player-facing Laws revision clearly distinguishes earned Law Points from spent Law Seals, so the `LawLevelDef` phrase “law-points cost” is a documentation-label conflict. A target-aligned export is still required before staging all rows. The same Laws revision establishes that each level description is the complete upgraded effect, not a delta. |
| `MapHOMM8` / `ScenarioHOMM8` | Parent identities exist, but level/underground and matchmaking/hotseat/ranked flags remain required. Absence of a mode on a campaign page is not evidence for `false`. |
| `CampaignHOMM8` tutorial groups | `AvailableActCount` is required, but tutorial/challenge groupings do not establish whether zero means inapplicable or an actual count. |

### Minimal architecture correction candidates

No schema change is needed for Neutral Magic or hero specialization details.
Before adding other held rows, the smallest useful architecture review is:

1. define `AbilityHOMM8.IsActive` and `IsFocusAction` for alternative attacks,
   or replace the two booleans with an explicit action/funding classification;
2. clarify whether `MagicSchoolHOMM8.UsesAstrology` names a current build-25061458
   mechanic or an earlier design concept;
3. reconcile `AstrologyHOMM8` with the current Neutral Magic level/point model;
4. rename FactionLaw cost fields only if primary build data confirms the values
   are not Law Seals. The current player-facing source supports retaining Seal
   terminology until that conflict is resolved.

If immediate `ResourceHOMM8` population is required, the smallest safe schema
change is to make `IsTradeable`, `IsMineProduced`, and `IsPersistent` nullable
without defaults. `NULL` then means “not established,” allowing source-backed
`Meter/Kingdom` rows for Law and Astrology Points and `Stockpile/Kingdom` rows
for treasury resources without converting missing evidence into `false`.

## Additional normalized gaps found in the audit

These are separate from the 231 staged actions and require coordinated schema
work before data import:

- [HeroStartSquadDef revision 15709](https://wiki.hoodedhorse.com/Heroes_of_Might_and_Magic_Olden_Era/Template:HeroStartSquadDef)
  proves one to three primary army slots plus an alternative slot. The current
  three fixed creature columns cannot preserve that variant. Add a
  `HeroStartSquadHOMM8_cid` junction keyed by game, hero, variant and slot, with
  creature and minimum/maximum amounts; migrate before deprecating fixed slots.
- [HeroSubClassDef revision 15886](https://wiki.hoodedhorse.com/Heroes_of_Might_and_Magic_Olden_Era/Template:HeroSubClassDef)
  identifies 24 named subclasses, five skill requirements per subclass, and 46
  bonuses. A subclass entity plus skill-requirement and granted-ability
  junctions is needed; `HeroClassAbility` alone cannot preserve the identity.
- The official Cargo corpus exposes 26 week/month Astrologist events. They are
  a separate rollable event catalog, not fields of the singleton
  `AstrologyHOMM8` row, and need their own H8 entity before import.

Those schema proposals were not implemented in this follow-up.

These are proposals only; this follow-up does not modify the schema.
