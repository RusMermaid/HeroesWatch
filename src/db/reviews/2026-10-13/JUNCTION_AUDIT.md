# Junction and relationship audit
Reviewed 2026-10-13 against generated overlay **v6** (`Tier`/numeric `Speed`).
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
subject endpoint. The following database guards now protect future writes too.

## Guards added in migration 0006

1. All four resource-cost tables reject negative amounts; zero remains valid.
2. H8 signature, Astrology and resource-detail references require H8 membership.
   Reverse deletion, re-keying and game changes are checked. `GameResource`
   truncation is blocked; use checked row deletion.
3. Town-screen links reject a different known building faction, including later
   detail creation and reverse edits. Unknown faction details remain allowed.
4. Lore links require at least one subject. Multiple contextual subjects remain
   allowed; no unrequested exactly-one restriction was introduced.
5. Component, requirement, upgrade and scenario graphs reject self-edges and
   cycles. H2 cross-campaign edges remain valid. Topology writes serialize only
   within the same game and graph family, not across the whole catalog.

The checks use final transaction state and validate existing rows on upgrade.
Relevant cross-row/topology edits require READ COMMITTED or SERIALIZABLE;
ordinary content edits still work at REPEATABLE READ. This matches PostgreSQL's
[snapshot and serialization rules](https://www.postgresql.org/docs/18/transaction-iso.html).
The ingestion validator and small-import dependency resolver enforce the same
relationships. Deployment permissions and operations belong to the later PR.

`src/db/tools/junction-coverage.mjs` reports all 29 junctions across HOMM1–8,
separates empty counts from reviewed applicability, resolves symbolic/physical
aliases, and audits deterministic cost and campaign-start relationships.
