# Olden Era creature-ability completion evidence

Target: Olden Era Early Access build **25061458**, repository series code
`HOMM8`, snapshot date 2026-09-29. Review date: 2026-10-13.

## Staged result

`homm8-abilities.patch.json` is staged research, not an applied catalog change.
It audits all 146 current H8 creatures and stages:

| Row family | Rows |
|---|---:|
| `Ability` | 288 |
| `AbilityHOMM8` | 279 |
| `CreatureAbility` | 826 |
| **Total** | **1,393** |

All 146 creatures have an official dated article revision whose HP, Attack,
Defense, minimum/maximum Damage, Initiative, and Speed exactly equal the
retained build-25061458 row. Their Abilities sections directly establish the
826 named memberships. Seven matching combat fields are strong version
corroboration, not proof that every hidden field is identical to that build.

The 288 ability identities use semantic HeroesWatch project keys derived from
verified official localized names and mechanics. They do **not** claim to be
native game IDs. Exact matching name, type, cost/cooldown, and normalized
displayed mechanics reuse one shared identity; different semantics get distinct
stable keys.

Every junction has a text `_cid` and the architecture's
`(Game_id, Creature_id, Ability_id)` business key. Every staged H8 detail
reuses its generic ability key.

## Mechanical summaries

All 288 generic abilities have newly worded `Description` values. All 279
supported detail rows repeat the same summary in `Effect`. Each summary:

- is 15-30 words;
- preserves explicit values, targets, duration, chance, limits, and
  action-continuation qualifiers;
- avoids narrative text and long copied article prose;
- is reused only when the normalized displayed mechanic is identical.

There are no unresolved/null summaries and all are marked high confidence.
Independent QA resolved five poison-effect exclusions through the official
English marker `description_effect_undead_dragon_embodiment_construct_immunities`,
confirmed the construct wording, and identified Hive Flame as the Expert Summon
Swarm subskill used by Unstable Concoction.

## Required boolean derivations

The patch distinguishes explicit classification from absence:

- `Creature Type`, `Attack Type`, `Movement Type`, and `Passive Ability`
  explicitly describe non-actions, so their details use
  `IsActive=false`, `IsFocusAction=false`, and
  `IsAlternativeAttack=false`.
- `Active Ability` plus a displayed Focus cost explicitly establishes
  `IsActive=true`, `IsFocusAction=true`, and
  `IsAlternativeAttack=false`. Displayed zero-Focus abilities keep cost zero.
  Displayed cooldowns are retained.
- Dawn Hoplet revision 38122 explicitly gives Morning Dew zero Focus cost,
  zero cooldown, once-per-battle use, and one generated Focus Charge. Its
  `FocusGainRule` is retained rather than withholding the detail.
- `Alternative Attack` proves identity and membership. Its generic
  `Ability` and `CreatureAbility` are staged, but its `AbilityHOMM8`
  sidecar is withheld: absence of a displayed Focus cost does not prove
  `IsFocusAction=false`.

This accounts for the 9-identity difference between 288 abilities and 279
detail rows. A missing optional detail does not invalidate a real FK-backed
junction.

## Full-catalog verification

Official article routing was resolved for every catalog name, including
punctuation-sensitive titles such as Sun's Aegis, the Aga'Shoth and Ra'Shoth
families, and Stinger (unit). Upgraded Damage markup was parsed as two displayed
values rather than treating embedded Base/Increase annotations as balance
changes.

The patch retains a compact `held.articleAudit` entry for every creature with:

- catalog key and native creature ID;
- official article revision ID;
- seven compared combat values;
- displayed ability type, name, Focus cost, and cooldown.

It also retains two non-applied corroboration inventories:

- 358 current synthetic Cargo ability slots;
- the older official source-native graph for 145 current unit IDs and 738
  memberships.

The official [UnitAbility schema](https://wiki.hoodedhorse.com/Heroes_of_Might_and_Magic_Olden_Era/Template:UnitAbilityDef)
states that Cargo `ability_id` is synthetic. Those IDs are therefore not
misrepresented as native IDs or imported as duplicate identities.

Supporting official structured sources:

- [UnitsData native graph, oldid 6225](https://wiki.hoodedhorse.com/Heroes_of_Might_and_Magic_Olden_Era/index.php?oldid=6225&title=Data:UnitsData.json)
- [GameEntities definitions, oldid 7008](https://wiki.hoodedhorse.com/Heroes_of_Might_and_Magic_Olden_Era/index.php?oldid=7008&title=Data:GameEntities.json)
- [English localization, oldid 20253](https://wiki.hoodedhorse.com/Heroes_of_Might_and_Magic_Olden_Era/index.php?oldid=20253&title=Data:LocStrings/en.json)

These older raw pages are corroboration only. Staged membership and names come
from the version-aligned dated articles recorded on every staged row.

## Remaining work

- Add the 9 remaining alternative-attack `AbilityHOMM8` sidecars only when their Focus
  semantics are explicit.
- Run normal JSON/schema validation and a temporary PostgreSQL import after the
  parent integration step.

No cumulative JSON, generated SQL, GitHub branch, or live database was changed.
