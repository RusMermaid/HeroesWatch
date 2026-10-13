# Junction and relationship audit
Reviewed 2026-10-13 against generated overlay **v5** (`Tier`/numeric `Speed`).
Current generated contract: **176 tables, 1,306 columns, 452 foreign keys**;
93 foreign keys are composite. This is a current-state review, not a claim that
every possible game fact or defensive guard has been completed.

## Structural result
All 29 junction tables have a global TEXT `*_cid` primary key plus a declared
business unique key. Nullable identities in `HeroClassAbility` and `LoreFull`
use `UNIQUE NULLS NOT DISTINCT`. Direct same-game endpoints use composite FKs;
shared-PK title details use deferred ownership/title checks.

The 29 junctions are:
`AdventureObjectCreature`, `AdventureObjectFaction`, `ArtifactComponent`,
`ArtifactResourceCost`, `BuildingCreature`, `BuildingRequirement`,
`BuildingResourceCost`, `BuildingUpgrade`, `CampaignHero`, `CampaignScenario`,
`CreatureAbility`, `CreatureResourceCost`, `CreatureSpell`, `CreatureUpgrade`,
`FactionMagicSchoolHOMM5`, `FactionNativeTerrainHOMM5`, `FactionSpell`,
`GameResource`, `HeroClassAbility`, `HeroClassAbilityRequirementGroup`,
`HeroClassPrimarySkillHOMM4`, `HeroSkill`, `LoreFull`, `MapObjectPresence`,
`MapTerrain`, `ScenarioConnection`, `SpellMagicSchool`,
`SpellResourceCostHOMM5`, and `TownScreenBuilding`.

Current data passes FK/uniqueness validation. It has no cross-game cost
membership, invalid campaign starting scenario, graph self-edge/cycle, or
TownScreen/building faction mismatch. All 22 current `LoreFull` rows have one
subject endpoint. These data facts do not substitute for missing DB guards.

## Remaining guard risks — explicitly not fixed

1. The four resource-cost tables still accept negative `Amount`; add `>= 0`
   checks while preserving valid zero values.
2. `FactionHOMM8.SignatureResource_id` and future `AstrologyHOMM8` resource
   references are not constrained to H8 `GameResource` membership.
3. `TownScreenBuilding` enforces same game, not same faction; current H3 rows
   are correct, but future direct SQL can cross-link faction screens/buildings.
4. `LoreFull` permits zero or multiple subject endpoints. Require at least one;
   exact-one versus contextual multi-target links remains a product decision.
5. Component/requirement/upgrade/scenario graphs lack self-edge CHECKs and
   general cycle validation. Current rows are clean; H2 cross-campaign scenario
   transitions are intentional and must not be rejected as same-campaign errors.

`src/db/tools/junction-coverage.mjs` reports all 29 junctions across HOMM1–8,
separates empty counts from reviewed applicability, resolves symbolic/physical
aliases, and audits deterministic cost and campaign-start relationships.
