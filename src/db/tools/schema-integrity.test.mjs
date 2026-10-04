import test from "node:test";
import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";

const root = new URL("../", import.meta.url);
const schema = JSON.parse(await readFile(new URL("schema/heroeswatch.schema.json", root), "utf8"));
const tables = new Map(schema.tables.map(table => [table.name, table]));
const ddl = await readFile(new URL("postgres/schema.sql", root), "utf8");
const initial = await readFile(new URL("postgres/migrations/0001_initial.sql", root), "utf8");
const migration = await readFile(new URL("postgres/migrations/0002_relationship_integrity.sql", root), "utf8");

test("the reviewed overlay keeps the historical initial migration separate", () => {
  assert.equal(schema.source.overlay.version, 2);
  assert.equal(schema.counts.tables, 176);
  assert.ok(!initial.includes('"AdventureObjectCreature"'));
  assert.ok(!initial.includes('"_game_scope_constraint"'));
  for (const table of ["AdventureObjectCreature", "AdventureObjectFaction", "HeroClassAbilityRequirementGroup"]) {
    assert.ok(ddl.includes(`CREATE TABLE "heroes_watch"."${table}"`));
    assert.ok(migration.includes(`CREATE TABLE "heroes_watch"."${table}"`));
    assert.equal(tables.get(table).primaryKey[0], `${table}_cid`);
  }
  assert.ok(migration.includes("$validate_scope$"));
});

test("direct game ownership is backed by composite foreign keys", () => {
  for (const table of schema.tables) {
    if (!table.columns.some(column => column.name === "Game_id" && !column.nullable)) continue;
    for (const fk of table.foreignKeys.filter(key => key.columns.length === 1 && key.columns[0] !== "Game_id")) {
      const parent = tables.get(fk.referencedTable);
      if (parent.name === "Game" || !parent.columns.some(column => column.name === "Game_id" && !column.nullable)) continue;
      assert.ok(table.foreignKeys.some(candidate =>
        candidate.referencedTable === parent.name &&
        JSON.stringify(candidate.columns) === JSON.stringify(["Game_id", ...fk.columns]) &&
        JSON.stringify(candidate.referencedColumns) === JSON.stringify(["Game_id", ...fk.referencedColumns])),
      `${table.name}.${fk.columns[0]} has no matching same-game FK`);
    }
  }
  assert.ok(!tables.get("Creature").foreignKeys.some(fk => fk.columns.length > 1 && fk.referencedTable === "MediaAsset"));
  for (const tableName of ["CreatureResourceCost", "BuildingResourceCost", "ArtifactResourceCost"]) {
    assert.ok(tables.get(tableName).foreignKeys.some(fk => fk.referencedTable === "GameResource" && fk.columns.join() === "Game_id,Resource_id"));
  }
});

test("prerequisite identity preserves distinct atoms and alternatives", () => {
  const table = tables.get("HeroClassAbility");
  const identity = table.uniqueConstraints.find(constraint => constraint.nullsNotDistinct);
  assert.deepEqual(identity.columns, ["Game_id", "HeroClass_id", "Ability_id", "RequirementSet", "RequiredAbility_id", "Skill_id", "MinimumMastery"]);
  assert.ok(table.foreignKeys.some(fk => fk.referencedTable === "HeroClassAbilityRequirementGroup" && fk.columns.includes("RequirementMode")));
  assert.ok(table.checks[0].expression.includes('"RequirementSet" IS NOT NULL'));
  assert.deepEqual(tables.get("ArtifactSetBonusHOMM5").uniqueConstraints, [{
    columns: ["ArtifactSetHOMM5_id", "RequiredPieceCount", "HeroClass_id"], nullsNotDistinct: true }]);
});

test("inherited ownership checks are deferred and cover reverse ownership edits", () => {
  assert.equal((ddl.match(/CREATE CONSTRAINT TRIGGER /g) ?? []).length, schema.counts.tables);
  assert.ok(ddl.includes('"_check_scope_descendants"'));
  assert.ok(ddl.includes("FOR SHARE"));
  assert.ok(ddl.includes("DEFERRABLE INITIALLY DEFERRED FOR EACH ROW"));
  assert.ok(!ddl.includes("pg_advisory"));
  assert.ok(ddl.includes("current_setting('transaction_isolation') = 'repeatable read'"));
  assert.ok(ddl.includes("ERRCODE = '0A000'"));
  const trigger = ddl.slice(ddl.indexOf('CREATE FUNCTION "heroes_watch"."_game_scope_constraint"'));
  const updateBranch = trigger.indexOf("IF TG_OP = 'UPDATE' THEN");
  const ownershipChange = trigger.indexOf("IF r->(m->>'pk') IS DISTINCT FROM old_r->(m->>'pk')");
  const isolationGuard = trigger.indexOf("current_setting('transaction_isolation')");
  assert.ok(updateBranch >= 0 && updateBranch < ownershipChange && ownershipChange < isolationGuard,
    "The isolation guard must remain inside the ownership-changing UPDATE branch");
});

test("object relationships retain multiplicity and selection weights remain separate", () => {
  assert.deepEqual(tables.get("AdventureObjectCreature").unique.find(key => key.includes("Relation")),
    ["Game_id", "AdventureObject_id", "Creature_id", "Relation"]);
  assert.ok(tables.get("LoreFull").columns.some(column => column.name === "Faction_id" && column.nullable));
  const spell = tables.get("FactionSpell");
  assert.ok(spell.columns.some(column => column.name === "OccurrenceChance"));
  assert.ok(spell.columns.some(column => column.name === "SelectionWeight" && column.postgresType === "INTEGER"));
  assert.ok(spell.checks.some(check => check.expression === '"SelectionWeight" >= 0'));
});
