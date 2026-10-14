// Reviewed changes after the immutable SQLDesigner export. The original export
// remains historical evidence; these changes define the current contract.
import { staticCatalogGuardChecks } from "./catalog-guard-rules.mjs";
import {sourceNullableColumns, sourceAddedColumns, sourceDetailChecks} from './source-detail-rules.mjs';

export const BASE_SNAPSHOT_SHA256 = "b04dd68ee09f7a1f86c055a2e3d01c690daf2791343ad7ca33bc637c59a58673";

function column(name, type, nullable = false, extra = {}) {
  return { name, sqlDesignerType: type, postgresType: type, nullable,
    primaryKey: false, unique: false, unsigned: false, default: null,
    comment: null, enumValues: null, ...extra };
}

export function applySchemaOverlayV2(schema, objectName) {
  if (schema.source.sha256 !== BASE_SNAPSHOT_SHA256) {
    throw new Error("Schema overlay requires the reviewed, unchanged SQLDesigner snapshot.");
  }
  const byName = new Map(schema.tables.map(table => [table.name, table]));
  const fk = (table, name, target) => ({ name: objectName("fk", table, name, target),
    columns: [name], referencedTable: target, referencedColumns: [`${target}_id`],
    relationship: "one-to-many", onDelete: "NO ACTION", onUpdate: "NO ACTION", deferrable: true });
  const addJunction = (name, endpoints, extra = []) => {
    const primary = `${name}_cid`;
    const table = { name, kind: "junction", comment: null, primaryKey: [primary],
      columns: [column(primary, "TEXT", false, { primaryKey: true, generatedIdentity: false, importGenerated: true }),
        column("Game_id", "BIGINT"), ...endpoints.map(target => column(`${target}_id`, "BIGINT")), ...extra],
      foreignKeys: [fk(name, "Game_id", "Game"), ...endpoints.map(target => fk(name, `${target}_id`, target))],
      unique: [["Game_id", ...endpoints.map(target => `${target}_id`), ...(extra.some(c => c.name === "Relation") ? ["Relation"] : [])]] };
    schema.tables.push(table); byName.set(name, table);
  };
  const relations = ["Recruits", "Guards", "Transforms"];
  addJunction("AdventureObjectCreature", ["AdventureObject", "Creature"], [
    column("Relation", "ENUM('Recruits','Guards','Transforms')", false, {
      postgresType: "Enum__AdventureObjectCreature__Relation", enumValues: relations }), column("Notes", "TEXT", true)]);
  addJunction("AdventureObjectFaction", ["AdventureObject", "Faction"], [column("Notes", "TEXT", true)]);
  schema.enums.push({ name: "Enum__AdventureObjectCreature__Relation", table: "AdventureObjectCreature", column: "Relation", values: relations });
  const lore = byName.get("LoreFull");
  lore.columns.push(column("Faction_id", "BIGINT", true));
  lore.foreignKeys.push(fk("LoreFull", "Faction_id", "Faction"));
  lore.unique = lore.unique.map(columns => [...columns, "Faction_id"]);
  byName.get("FactionSpell").columns.push(column("SelectionWeight", "INTEGER", true));
  byName.get("FactionSpell").checks = [{ name: "ck__FactionSpell__SelectionWeight", expression: '"SelectionWeight" >= 0' }];
  const hca = byName.get("HeroClassAbility");
  addJunction("HeroClassAbilityRequirementGroup", ["HeroClass", "Ability"], [
    column("RequirementSet", "SMALLINT"),
    column("RequirementMode", "ENUM('All','Any')", false, { postgresType: "Enum__HeroClassAbility__RequirementMode", enumValues: ["All", "Any"] })]);
  const group = byName.get("HeroClassAbilityRequirementGroup");
  group.unique = [["Game_id", "HeroClass_id", "Ability_id", "RequirementSet"], ["Game_id", "HeroClass_id", "Ability_id", "RequirementSet", "RequirementMode"]];
  group.checks = [{ name: "ck__HeroClassAbilityRequirementGroup__positive_set", expression: '"RequirementSet" > 0' }];
  hca.foreignKeys.push({ name: "fk__HeroClassAbility__requirement_group", columns: ["Game_id", "HeroClass_id", "Ability_id", "RequirementSet", "RequirementMode"],
    referencedTable: group.name, referencedColumns: ["Game_id", "HeroClass_id", "Ability_id", "RequirementSet", "RequirementMode"],
    relationship: "one-to-many", onDelete: "NO ACTION", onUpdate: "NO ACTION", deferrable: true });
  hca.uniqueConstraints = [{ columns: ["Game_id", "HeroClass_id", "Ability_id", "RequirementSet", "RequiredAbility_id", "Skill_id", "MinimumMastery"], nullsNotDistinct: true }];
  hca.checks = [{ name: "ck__HeroClassAbility__requirement_group", expression: '("RequirementSet" IS NULL AND "RequirementMode" IS NULL) OR ("RequirementSet" IS NOT NULL AND "RequirementSet" > 0 AND "RequirementMode" IS NOT NULL)' }];
  byName.get("ArtifactSetBonusHOMM5").uniqueConstraints = [{ columns: ["ArtifactSetHOMM5_id", "RequiredPieceCount", "HeroClass_id"], nullsNotDistinct: true }];

  // Retain simple FKs for importer identity lookup and add database ownership
  // protection where both rows carry a non-null game. Nullable global media
  // and inherited ownership are handled by deferred checks below.
  for (const table of schema.tables) {
    const game = table.columns.find(c => c.name === "Game_id");
    if (!game || game.nullable) continue;
    for (const reference of [...table.foreignKeys]) {
      const parent = byName.get(reference.referencedTable);
      if (reference.columns.length !== 1 || reference.columns[0] === "Game_id" || parent.name === "Game") continue;
      const parentGame = parent.columns.find(c => c.name === "Game_id");
      if (!parentGame || parentGame.nullable) continue;
      const parentKey = ["Game_id", ...reference.referencedColumns];
      if (!parent.unique.some(key => JSON.stringify(key) === JSON.stringify(parentKey))) parent.unique.push(parentKey);
      table.foreignKeys.push({ ...reference, name: objectName("fk_game", table.name, ...reference.columns, parent.name),
        columns: ["Game_id", ...reference.columns], referencedColumns: parentKey });
    }
    if (["ArtifactResourceCost", "BuildingResourceCost", "CreatureResourceCost"].includes(table.name)) {
      table.foreignKeys.push({ name: objectName("fk_resource", table.name), columns: ["Game_id", "Resource_id"],
        referencedTable: "GameResource", referencedColumns: ["Game_id", "Resource_id"], relationship: "one-to-many",
        onDelete: "NO ACTION", onUpdate: "NO ACTION", deferrable: true });
    }
  }
  schema.tables.sort((a, b) => a.name.localeCompare(b.name));
  schema.enums.sort((a, b) => a.name.localeCompare(b.name));
  for (const table of schema.tables) {
    table.foreignKeys.sort((a, b) => a.name.localeCompare(b.name));
    table.unique.sort((a, b) => a.join().localeCompare(b.join()));
  }
  schema.source.overlay = { version: 2, module: "src/db/tools/schema-overlay.mjs", migration: "0002_relationship_integrity.sql" };
  schema.integrity = { gameOwnership: "Composite foreign keys plus deferred inherited/global ownership checks",
    globalTables: ["Resource", "MediaAsset"], inheritedOwners: { FactionLaw: "Faction_id", ArtifactSetHOMM5: "IntroducedInExpansion_id", ArtifactSetBonusHOMM5: "ArtifactSetHOMM5_id" },
    prerequisiteGroups: "HeroClassAbilityRequirementGroup defines positive-numbered alternative paths. All/Any combines atoms inside one set. A native FK requires every grouped atom to use the group's mode. NULL group and mode means an association without a documented prerequisite group, not proof of no prerequisites." };
  schema.counts = { tables: schema.tables.length, columns: schema.tables.reduce((n, t) => n + t.columns.length, 0),
    foreignKeys: schema.tables.reduce((n, t) => n + t.foreignKeys.length, 0), enums: schema.enums.length };
  return schema;
}

export function applySchemaOverlayV3(schema, objectName) {
  const byName = new Map(schema.tables.map(table => [table.name, table]));
  const nullableIdentity = (tableName, columns) => {
    const table = byName.get(tableName);
    const signature = columns.join("\u0000");
    table.unique = table.unique.filter(key => key.join("\u0000") !== signature);
    table.uniqueConstraints ??= [];
    if (!table.uniqueConstraints.some(constraint => constraint.columns.join("\u0000") === signature)) {
      table.uniqueConstraints.push({ columns, nullsNotDistinct: true });
    }
  };

  // Ordinary UNIQUE constraints treat NULL values as distinct. These three
  // nullable tuples are business identities, so PostgreSQL 15+
  // NULLS NOT DISTINCT is required to make the declared identities real.
  nullableIdentity("MediaAsset", ["Game_id", "Code"]);
  nullableIdentity("Patch", ["Game_id", "Version", "Platform"]);
  nullableIdentity("LoreFull", ["Game_id", "Lore_id", "Hero_id", "CampaignHero_cid",
    "Campaign_id", "Scenario_id", "Map_id", "LinkRole", "Faction_id"]);

  const campaignHero = byName.get("CampaignHero");
  campaignHero.foreignKeys.push({
    name: objectName("fk_campaign_scenario", "CampaignHero", "StartingScenario_id"),
    columns: ["Game_id", "Campaign_id", "StartingScenario_id"],
    referencedTable: "CampaignScenario",
    referencedColumns: ["Game_id", "Campaign_id", "Scenario_id"],
    relationship: "one-to-many",
    onDelete: "NO ACTION",
    onUpdate: "NO ACTION",
    deferrable: true,
  });

  const spellResourceCost = byName.get("SpellResourceCostHOMM5");
  spellResourceCost.foreignKeys.push({
    name: objectName("fk_resource", "SpellResourceCostHOMM5"),
    columns: ["Game_id", "Resource_id"],
    referencedTable: "GameResource",
    referencedColumns: ["Game_id", "Resource_id"],
    relationship: "one-to-many",
    onDelete: "NO ACTION",
    onUpdate: "NO ACTION",
    deferrable: true,
  });

  for (const table of schema.tables) {
    table.foreignKeys.sort((a, b) => a.name.localeCompare(b.name));
    table.unique.sort((a, b) => a.join().localeCompare(b.join()));
    table.uniqueConstraints?.sort((a, b) => a.columns.join().localeCompare(b.columns.join()));
    table.checks?.sort((a, b) => a.name.localeCompare(b.name));
  }
  schema.source.overlay = { version: 3, module: "src/db/tools/schema-overlay.mjs", migration: "0003_nullable_identity_and_campaign_scope.sql" };
  schema.integrity.nullableBusinessKeys = "Nullable business identities use PostgreSQL 15+ UNIQUE NULLS NOT DISTINCT.";
  schema.integrity.campaignHeroStartingScenario = "A non-null starting scenario must be a member of the same campaign.";
  schema.counts = { tables: schema.tables.length, columns: schema.tables.reduce((n, t) => n + t.columns.length, 0),
    foreignKeys: schema.tables.reduce((n, t) => n + t.foreignKeys.length, 0), enums: schema.enums.length };
  return schema;
}

export function applySchemaOverlayV4(schema) {
  const byName = new Map(schema.tables.map(table => [table.name, table]));
  for (const tableName of ["CreatureHOMM1", "CreatureHOMM2", "CreatureHOMM3", "CreatureHOMM4"]) {
    const table = byName.get(tableName);
    const level = table?.columns.find(column => column.name === "Level");
    if (!level || table.columns.some(column => column.name === "Tier")) {
      throw new Error(`${tableName} must contain Level and not Tier before overlay version 4.`);
    }
    level.name = "Tier";
  }
  schema.source.overlay = { version: 4, module: "src/db/tools/schema-overlay.mjs", migration: "0004_creature_tier_terminology.sql" };
  schema.integrity.creatureTierTerminology = "CreatureHOMM1 through CreatureHOMM4 use Tier; spell Level fields retain their existing meaning.";
  schema.counts = { tables: schema.tables.length, columns: schema.tables.reduce((n, t) => n + t.columns.length, 0),
    foreignKeys: schema.tables.reduce((n, t) => n + t.foreignKeys.length, 0), enums: schema.enums.length };
  return schema;
}

export function applySchemaOverlayV5(schema) {
  const byName = new Map(schema.tables.map(table => [table.name, table]));
  const configurations = [
    ["CreatureHOMM1", [1, 2, 3], [[1, "Slow"], [2, "Medium"], [3, "Fast"]]],
    ["CreatureHOMM2", [2, 3, 4, 5, 6, 7], [[2, "Very Slow"], [3, "Slow"], [4, "Average"], [5, "Fast"], [6, "Very Fast"], [7, "Ultra Fast"]]],
  ];
  for (const [tableName, domain, labels] of configurations) {
    const table = byName.get(tableName);
    const speedIndex = table?.columns.findIndex(candidate => candidate.name === "Speed") ?? -1;
    if (speedIndex < 0 || table.columns.some(candidate => candidate.name === "SpeedName")) {
      throw new Error(`${tableName} must contain Speed and not SpeedName before overlay version 5.`);
    }
    const speed = table.columns[speedIndex];
    speed.sqlDesignerType = "SMALLINT";
    speed.postgresType = "SMALLINT";
    speed.enumValues = null;
    speed.allowedValues = domain;
    const expression = `CASE "Speed" ${labels.map(([value, label]) => `WHEN ${value} THEN '${label}'`).join(" ")} END`;
    table.columns.splice(speedIndex + 1, 0, column("SpeedName", "TEXT", false, {
      generatedExpression: expression,
      importGenerated: true,
    }));
    table.checks ??= [];
    table.checks.push({
      name: `ck__${tableName}__Speed_base_domain`,
      expression: `"Speed" IN (${domain.join(", ")})`,
    });
    table.checks.sort((a, b) => a.name.localeCompare(b.name));
  }
  schema.enums = schema.enums.filter(type => type.name !== "Enum__CreatureHOMM1__Speed");
  schema.source.overlay = { version: 5, module: "src/db/tools/schema-overlay.mjs", migration: "0005_creature_numeric_speed.sql" };
  schema.integrity.creatureSpeed = "CreatureHOMM1 and CreatureHOMM2 store source combat movement as numeric Speed; stored SpeedName is derived and read-only. Movement remains separate.";
  schema.counts = { tables: schema.tables.length, columns: schema.tables.reduce((n, t) => n + t.columns.length, 0),
    foreignKeys: schema.tables.reduce((n, t) => n + t.foreignKeys.length, 0), enums: schema.enums.length };
  return schema;
}

export function applySchemaOverlayV6(schema) {
  const byName = new Map(schema.tables.map(table => [table.name, table]));
  for (const rule of staticCatalogGuardChecks) {
    const table = byName.get(rule.table);
    if (!table) throw new Error(`Unknown catalog guard table ${rule.table}.`);
    table.checks ??= [];
    if (table.checks.some(check => check.name === rule.name)) throw new Error(`Duplicate catalog guard ${rule.name}.`);
    table.checks.push({ name: rule.name, expression: rule.expression });
    table.checks.sort((a, b) => a.name.localeCompare(b.name));
  }
  schema.source.overlay = { version: 6, module: "src/db/tools/schema-overlay.mjs", migration: "0006_catalog_guards.sql" };
  schema.integrity.catalogGuards = "Nonnegative costs, at least one LoreFull subject with multi-context links allowed, and no direct graph self-edges; cross-row graph guards are generated separately.";
  schema.counts = { tables: schema.tables.length, columns: schema.tables.reduce((n, t) => n + t.columns.length, 0),
    foreignKeys: schema.tables.reduce((n, t) => n + t.foreignKeys.length, 0), enums: schema.enums.length };
  return schema;
}

export function applySchemaOverlayV7(schema) {
  const tables = new Map(schema.tables.map(table => [table.name, table]));
  for (const [name, fields] of Object.entries(sourceNullableColumns)) for (const field of fields) {
    tables.get(name).columns.find(column => column.name === field).nullable = true;
  }
  for (const [name, fields] of Object.entries(sourceAddedColumns)) for (const [field, type] of fields) {
    tables.get(name).columns.push(column(field, type, true));
  }
  const role = tables.get('CreatureHOMM7').columns.find(column => column.name === 'WarfareRole');
  role.enumValues = [...role.enumValues, 'AttackAndSupport'];
  role.sqlDesignerType = `ENUM(${role.enumValues.map(value => `'${value}'`).join(',')})`;
  schema.enums.find(item => item.name === role.postgresType).values = [...role.enumValues];
  const movement=tables.get('CreatureHOMM7').columns.find(column=>column.name==='Movement');
  movement.enumValues=[...movement.enumValues,'Stationary'];
  movement.sqlDesignerType=`ENUM(${movement.enumValues.map(value=>`'${value}'`).join(',')})`;
  schema.enums.find(item=>item.name===movement.postgresType).values=[...movement.enumValues];
  for (const rule of sourceDetailChecks) {
    const table = tables.get(rule.table);
    table.checks ??= [];
    table.checks.push({name: rule.name, expression: rule.expression});
    table.checks.sort((a,b) => a.name.localeCompare(b.name));
  }
  schema.source.overlay = {version:7, module:'src/db/tools/schema-overlay.mjs', migration:'0007_source_detail_profiles.sql'};
  schema.integrity.sourceDetails = 'Ordinary creature requirements remain enforced. Exceptional H6 creatures and H7 warfare units may retain source-unknown fields; H7 vectors use source-ordered profiles, not inferred skill ranks. Unknown H8 mode/resource flags are NULL.';
  schema.counts = {tables:schema.tables.length, columns:schema.tables.reduce((n,t)=>n+t.columns.length,0), foreignKeys:schema.tables.reduce((n,t)=>n+t.foreignKeys.length,0), enums:schema.enums.length};
  return schema;
}

export function applySchemaOverlay(schema, objectName) {
  return applySchemaOverlayV7(applySchemaOverlayV6(applySchemaOverlayV5(applySchemaOverlayV4(applySchemaOverlayV3(applySchemaOverlayV2(schema, objectName), objectName)))));
}
