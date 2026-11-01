# Heroes VII follow-up: relationship audit and primary-source boundary

Research date: 2026-10-13. This follow-up is intentionally separate from the
numeric Heroes VII overlay. It records recoverable official relationships and
the exact missing junctions that still require a small final package export.
It contains no mergeable rows and makes no schema or database changes.

## Concrete official documentation that is already represented

The [Ubisoft Heroes VII Editor Manual](https://ubistatic-a.akamaihd.net/0004/prod/images/160407_LT1_Modding/EditorManual.pdf)
documents the Hero Tool properties: Faction, Damage Type, Skill Class,
Specialization, Starting Skill and Starting Army. Its Heroes tab is configured
per map and per player. The screenshot's 22 enabled/visible hero rows match the
existing positive `HeroHOMM7` rows, and all 22 generic `Hero.HeroClass_id`
links match the displayed skill classes. No new relationship is added because
this is corroboration of existing catalog data.

The [Ubisoft Modding Manual](https://ubistatic-a.akamaihd.net/0004/prod/images/160407_LT1_Modding/ModdingManual.pdf)
states that H7 creatures and other content are data-driven archetypes. It does
not enumerate the final creature ability graph, rank vectors, building
recruitment mappings, or map/scenario metadata. The correct next source is a
small export of the installed final package—not a full-game download and not a
visual guess.

The [Ubisoft product page](https://www.ubisoft.com/en-au/games/might-and-magic-heroes-vii/editions/ultimate)
confirms the product/expansion scope but does not provide the missing row-level
relationships.

## Current H7 relationship inventory

| Relationship/data area | Existing rows | Follow-up result |
|---|---:|---|
| `HeroClassAbility` | 2,489 | Existing junction already covers the 44 generic H7 classes, including unresolved detail classes. |
| `BuildingCreature` | 112 | Standard recruitment is populated; the 19 warfare creature links are absent. |
| `CreatureResourceCost` | 184 | Costs exist for many warfare units; this does not identify their recruitment buildings. |
| `CreatureUpgrade` | 56 | Existing upgrade graph is populated for supported H7 rows. |
| `CampaignHero` | 10 | Known protagonist links only; no primary source in scope establishes additional links. |
| `CampaignScenario` | 43 | Campaign ordering is already present. |
| `ScenarioConnection` | 32 | Known linear scenario edges are already present. |
| `CreatureAbility` | 0 | No primary H7 ability assignment source available. |
| `FactionSpell` | 0 | No complete primary faction-to-spell availability matrix available. |
| `MapHOMM7` | 0 | Required map flags/dimensions are not in the official docs consulted. |
| `ScenarioHOMM7` | 0 | Empty detail rows would be meaningless; optional fields need package data. |

## Warfare recruitment links: exact boundary

The missing `BuildingCreature` scope is the 19 warfare identities already
listed in `heroes7.patch.json`. The current building catalog contains plausible
special-building identities (for example Academy Workshop/Pyramidal Craft,
Fortress Foundry/Rune Temple/Armory, and Haven Blacksmith/Convent of Elrath),
but names alone do not prove the unit relationship. The mirrored Ubisoft
Shadow Council posts reproduce some town-screen mappings, but that mirror is
not a primary host and does not establish all 19 links. Therefore no
`BuildingCreature` additions are emitted here.

### Exact-name audit performed for this follow-up

The reviewed H7 `Building` descriptions, `BuildingHOMM7.Effect` values,
`homm7*.sources.md` and H7 review-SQL registries, existing `BuildingCreature`
rows, and the cumulative JSON contain no exact named statement of the form
"building X recruits warfare creature Y" for any of the 19 identities. Twelve
of the warfare identities have resource-cost rows, but a cost is not a
recruitment edge. Consequently the exact-match set is empty, and adding edges
from building names or costs would be name guessing rather than deterministic
normalization of accepted evidence.

The `CreatureAbility` audit is stated as **137 detailed H7 creatures without
links**, not “137 missing relationships”: a creature may legitimately have
zero, one, or many ability edges, so the number of absent edges cannot be
derived from the number of detailed creature rows.

## Why no empty detail rows were emitted

`ScenarioHOMM7` requires only its shared key in the JSON contract, but creating
43 rows with no difficulty, cap, conditions, starting state or carryover data
would falsely imply completed detail coverage. `MapHOMM7` has required fields,
but campaign/scenario names do not establish underground state, level count or
Tear-of-Asha presence. Both remain explicit source gaps.

## Verification

- Read-only repository audit completed: 2,489 H7 `HeroClassAbility` rows,
  112 H7 `BuildingCreature` rows, 184 H7 creature-resource rows, 56 H7
  upgrade rows, 10 H7 CampaignHero rows, 43 CampaignScenario rows and 32
  ScenarioConnection rows.
- Confirmed 19 H7 warfare identities have no `BuildingCreature` rows.
- Confirmed all 22 existing Editor Manual Hall rows already have matching
  generic hero/class links.
- No additions, fills, schema changes, live database writes, GitHub writes,
  forum sources, or full-game downloads were used.
