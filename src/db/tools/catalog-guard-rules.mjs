// Declarative catalog guard configuration shared by the semantic overlay,
// forward migration generator, tests, and cross-row production guards.
export const catalogGuardRules = Object.freeze({
  nonnegativeAmounts: Object.freeze([
    "ArtifactResourceCost",
    "BuildingResourceCost",
    "CreatureResourceCost",
    "SpellResourceCostHOMM5",
  ]),
  loreSubjects: Object.freeze({
    table: "LoreFull",
    columns: Object.freeze(["Hero_id", "CampaignHero_cid", "Campaign_id", "Scenario_id", "Map_id", "Faction_id"]),
  }),
  noSelfEdges: Object.freeze([
    Object.freeze({ table: "ArtifactComponent", left: "CompositeArtifact_id", right: "ComponentArtifact_id" }),
    Object.freeze({ table: "BuildingRequirement", left: "Building_id", right: "RequiredBuilding_id" }),
    Object.freeze({ table: "BuildingUpgrade", left: "BaseBuilding_id", right: "UpgradedBuilding_id" }),
    Object.freeze({ table: "CreatureUpgrade", left: "BaseCreature_id", right: "UpgradedCreature_id" }),
    Object.freeze({ table: "ScenarioConnection", left: "FromScenario_id", right: "ToScenario_id" }),
  ]),
});

export const staticCatalogGuardChecks = Object.freeze([
  ...catalogGuardRules.nonnegativeAmounts.map(table => Object.freeze({
    table,
    name: `ck__${table}__Amount_nonnegative`,
    expression: '"Amount" >= 0',
  })),
  Object.freeze({
    table: catalogGuardRules.loreSubjects.table,
    name: "ck__LoreFull__has_subject",
    expression: `num_nonnulls(${catalogGuardRules.loreSubjects.columns.map(column => `"${column}"`).join(", ")}) >= 1`,
  }),
  ...catalogGuardRules.noSelfEdges.map(rule => Object.freeze({
    table: rule.table,
    name: `ck__${rule.table}__no_self_edge`,
    expression: `"${rule.left}" <> "${rule.right}"`,
  })),
]);
