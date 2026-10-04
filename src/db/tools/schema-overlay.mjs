// Reviewed changes after the immutable SQLDesigner export. The original export
// remains historical evidence; these changes define the current contract.
export const BASE_SNAPSHOT_SHA256 = "b04dd68ee09f7a1f86c055a2e3d01c690daf2791343ad7ca33bc637c59a58673";

function column(name, type, nullable = false, extra = {}) {
  return { name, sqlDesignerType: type, postgresType: type, nullable,
    primaryKey: false, unique: false, unsigned: false, default: null,
    comment: null, enumValues: null, ...extra };
}

export function applySchemaOverlay(schema, objectName) {
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
