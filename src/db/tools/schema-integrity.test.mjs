import test from "node:test";
import assert from "node:assert/strict";
import { createHash } from "node:crypto";
import { readFile } from "node:fs/promises";
import { staticCatalogGuardChecks } from "./catalog-guard-rules.mjs";

const root = new URL("../", import.meta.url);
const schema = JSON.parse(await readFile(new URL("schema/heroeswatch.schema.json", root), "utf8"));
const tables = new Map(schema.tables.map(table => [table.name, table]));
const ddl = await readFile(new URL("postgres/schema.sql", root), "utf8");
const initial = await readFile(new URL("postgres/migrations/0001_initial.sql", root), "utf8");
const migration = await readFile(new URL("postgres/migrations/0002_relationship_integrity.sql", root), "utf8");
const migration3 = await readFile(new URL("postgres/migrations/0003_nullable_identity_and_campaign_scope.sql", root), "utf8");
const migration4 = await readFile(new URL("postgres/migrations/0004_creature_tier_terminology.sql", root), "utf8");
const migration5 = await readFile(new URL("postgres/migrations/0005_creature_numeric_speed.sql", root), "utf8");
const migration6 = await readFile(new URL("postgres/migrations/0006_catalog_guards.sql", root), "utf8");
const migration7 = await readFile(new URL('postgres/migrations/0007_source_detail_profiles.sql',root),'utf8');
const dataSchema = JSON.parse(await readFile(new URL("schema/data.schema.json", root), "utf8"));
const dictionary = await readFile(new URL("DATA_DICTIONARY.md", root), "utf8");

test("published and deployed migration history remains immutable", () => {
  const digest = sql => createHash("sha256").update(sql.replaceAll("\r\n", "\n")).digest("hex");
  // 0001/0002 were delivered at 2848f00; 0003 was applied locally on October 13;
  // 0004 is pinned before publication. Corrections need a new forward migration.
  assert.equal(digest(initial), "d96ebdfad3601ec7a4f7f1243f31f813cc0abba2d0992365c203a4bd947b866e");
  assert.equal(digest(migration), "b9c55d3ae0ff8f23544f366dd02b9e412b878d48e15833b6204097f9edda0f98");
  assert.equal(digest(migration3), "45d2c3c79d4317a1d44e3089ac6f23ac83f0b1863ad59dcae4f665967a295821");
  assert.equal(digest(migration4), "37a0f61de380816653579bbe4774fe4d823b6510d8d0053a91e24f75acf12d4f");
  assert.equal(digest(migration5), "3f3512c3bbea253cc589c475e5eb4017b76a978fcb77e28d53992f41f27558d1");
  assert.equal(digest(migration6), "151c530ae7ea62ed605d5f42a80e421f84d99581e14226e819ccb372df78ac11");
  assert.equal(digest(migration7), '7ecb610ae431a40bd7250ef32a002b39e7a006a437a637c50d9b2eff2047d735');
});

test("the reviewed overlay keeps the historical initial migration separate", () => {
  assert.equal(schema.source.overlay.version, 8);
  assert.equal(schema.counts.tables, 176);
  assert.ok(!initial.includes('"AdventureObjectCreature"'));
  assert.ok(!initial.includes('"_game_scope_constraint"'));
  for (const table of ["AdventureObjectCreature", "AdventureObjectFaction", "HeroClassAbilityRequirementGroup"]) {
    assert.ok(ddl.includes(`CREATE TABLE "heroes_watch"."${table}"`));
    assert.ok(migration.includes(`CREATE TABLE "heroes_watch"."${table}"`));
    assert.equal(tables.get(table).primaryKey[0], `${table}_cid`);
  }
  assert.ok(migration.includes("$validate_scope$"));
  assert.ok(!migration.includes("fk_campaign_scenario__CampaignHero__StartingScenario_id"));
  assert.ok(migration3.includes("fk_campaign_scenario__CampaignHero__StartingScenario_id"));
  assert.ok(migration3.includes("UNIQUE NULLS NOT DISTINCT"));
});

test("creature tiers use a data-preserving forward rename without changing spell levels", () => {
  for (const tableName of ["CreatureHOMM1", "CreatureHOMM2", "CreatureHOMM3", "CreatureHOMM4"]) {
    const table = tables.get(tableName);
    assert.ok(table.columns.some(column => column.name === "Tier"));
    assert.ok(!table.columns.some(column => column.name === "Level"));
    assert.ok(migration4.includes(`ALTER TABLE "heroes_watch"."${tableName}" RENAME COLUMN "Level" TO "Tier";`));
  }
  for (const tableName of ["SpellHOMM1", "SpellHOMM2", "SpellHOMM3", "SpellHOMM4", "SpellHOMM5", "SpellHOMM7"]) {
    assert.ok(tables.get(tableName).columns.some(column => column.name === "Level"), `${tableName}.Level must remain unchanged`);
  }
  assert.doesNotMatch(migration4, /SpellHOMM|ALTER COLUMN "Speed"|DROP COLUMN|DELETE FROM|TRUNCATE/);
  assert.equal((migration4.match(/RENAME COLUMN "Level" TO "Tier"/g) ?? []).length, 4);
});

test("H1 and H2 speed names are stored generated labels over bounded numeric speed", () => {
  for (const [tableName, domain, labels] of [
    ["CreatureHOMM1", [1, 2, 3], ["Slow", "Medium", "Fast"]],
    ["CreatureHOMM2", [2, 3, 4, 5, 6, 7], ["Very Slow", "Slow", "Average", "Fast", "Very Fast", "Ultra Fast"]],
  ]) {
    const table = tables.get(tableName);
    const speed = table.columns.find(column => column.name === "Speed");
    const name = table.columns.find(column => column.name === "SpeedName");
    assert.equal(speed.postgresType, "SMALLINT");
    assert.deepEqual(speed.enumValues, null);
    assert.deepEqual(speed.allowedValues, domain);
    assert.equal(name.postgresType, "TEXT");
    assert.equal(name.importGenerated, true);
    assert.match(name.generatedExpression, /^CASE "Speed" /);
    for (const label of labels) assert.match(name.generatedExpression, new RegExp(`'${label}'`));
    assert.ok(table.checks.some(check => check.expression === `"Speed" IN (${domain.join(", ")})`));
    assert.equal(dataSchema.$defs[tableName].properties.SpeedName.readOnly, true);
    assert.deepEqual(dataSchema.$defs[tableName].properties.SpeedName.not, {});
    assert.ok(!dataSchema.$defs[tableName].required.includes("SpeedName"));
    assert.deepEqual(dataSchema.$defs[tableName].properties.Speed.enum, domain);
    assert.match(ddl, new RegExp(`"SpeedName" TEXT GENERATED ALWAYS AS .* STORED NOT NULL`));
  }
  assert.doesNotMatch(migration5, /ALTER COLUMN "Movement"|DELETE FROM|TRUNCATE/);
  assert.match(migration5, /CreatureHOMM1\.Speed contains an unsupported legacy label/);
  assert.match(migration5, /CreatureHOMM2\.Speed contains a value outside the reviewed base domain 2\.\.7/);
  assert.ok(migration5.indexOf("$validate_creature_speed$;") < migration5.indexOf('ALTER COLUMN "Speed" TYPE SMALLINT'));
  assert.match(migration5, /^BEGIN;[\s\S]*COMMIT;\n$/m);
});

test("static catalog guards preserve valid domains without narrowing lore to one context", () => {
  for (const rule of staticCatalogGuardChecks) {
    const table = tables.get(rule.table);
    assert.ok(table.checks.some(check => check.name === rule.name && check.expression === rule.expression), rule.name);
    assert.ok(migration6.includes(`ADD CONSTRAINT "${rule.name}" CHECK (${rule.expression});`), rule.name);
  }
  const lore = staticCatalogGuardChecks.find(rule => rule.table === "LoreFull");
  assert.match(lore.expression, />= 1$/);
  assert.ok(!lore.expression.endsWith(") = 1"), "LoreFull must allow multi-context links");
  assert.equal(staticCatalogGuardChecks.filter(rule => rule.name.endsWith("__no_self_edge")).length, 5);
  assert.equal(staticCatalogGuardChecks.filter(rule => rule.name.endsWith("__Amount_nonnegative")).length, 4);
  assert.doesNotMatch(migration6, /^\s*(?:DELETE FROM|TRUNCATE TABLE|DROP TABLE|ALTER TABLE .* DROP COLUMN)\b/m);
  assert.match(migration6, /^BEGIN;[\s\S]*COMMIT;\n$/m);
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
  for (const tableName of ["CreatureResourceCost", "BuildingResourceCost", "ArtifactResourceCost", "SpellResourceCostHOMM5"]) {
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
  assert.equal((ddl.match(/CREATE CONSTRAINT TRIGGER "ct_game_scope__/g) ?? []).length, schema.counts.tables);
  assert.ok(ddl.includes('"_check_scope_descendants"'));
  assert.ok(ddl.includes("FOR SHARE"));
  assert.ok(ddl.includes("DEFERRABLE INITIALLY DEFERRED FOR EACH ROW"));
  const ownershipSql = ddl.slice(ddl.indexOf('CREATE FUNCTION "heroes_watch"."_scope_metadata"'),
    ddl.indexOf('-- Cross-row production guards'));
  assert.ok(!ownershipSql.includes("pg_advisory"), "game ownership must not serialize unrelated writes with advisory locks");
  assert.ok(ddl.includes("current_setting('transaction_isolation') = 'repeatable read'"));
  assert.ok(ddl.includes("ERRCODE = '0A000'"));
  const trigger = ownershipSql.slice(ownershipSql.indexOf('CREATE FUNCTION "heroes_watch"."_game_scope_constraint"'));
  const updateBranch = trigger.indexOf("IF TG_OP = 'UPDATE' THEN");
  const ownershipChange = trigger.indexOf("IF r->(m->>'pk') IS DISTINCT FROM old_r->(m->>'pk')");
  const isolationGuard = trigger.indexOf("current_setting('transaction_isolation')");
  assert.ok(updateBranch >= 0 && updateBranch < ownershipChange && ownershipChange < isolationGuard,
    "The isolation guard must remain inside the ownership-changing UPDATE branch");
});

test("fresh schema and migration 0006 install and validate production graph guards", () => {
  for (const token of ["_catalog_graph_metadata", "_catalog_graph_write_lock", "ct_graph_cycle__CreatureUpgrade",
    "ct_production_resource__FactionHOMM8", "ct_production_town_link__TownScreenBuilding"]) {
    assert.ok(ddl.includes(token), `fresh schema missing ${token}`);
    assert.ok(migration6.includes(token), `migration 0006 missing ${token}`);
  }
  assert.ok(migration6.indexOf("_catalog_graph_metadata") < migration6.indexOf("$validate_graphs$"));
  assert.ok(migration6.indexOf("_check_homm8_resource_row") < migration6.indexOf("$validate_production_guards$"));
  assert.match(migration6, /LOCK TABLE[\s\S]*IN SHARE ROW EXCLUSIVE MODE/);
  assert.match(migration6, /^BEGIN;[\s\S]*COMMIT;\n$/m);
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

test("nullable business identities and campaign starting scenarios are database-enforced", () => {
  for (const [tableName, columns] of [
    ["MediaAsset", ["Game_id", "Code"]],
    ["Patch", ["Game_id", "Version", "Platform"]],
    ["LoreFull", ["Game_id", "Lore_id", "Hero_id", "CampaignHero_cid", "Campaign_id", "Scenario_id", "Map_id", "LinkRole", "Faction_id"]],
  ]) {
    const table = tables.get(tableName);
    assert.ok(!table.unique.some(key => key.join() === columns.join()));
    assert.ok(table.uniqueConstraints.some(constraint =>
      constraint.nullsNotDistinct && constraint.columns.join() === columns.join()),
    `${tableName} must treat nulls as equal in its business identity`);
  }
  assert.ok(tables.get("CampaignHero").foreignKeys.some(fk =>
    fk.referencedTable === "CampaignScenario" &&
    fk.columns.join() === "Game_id,Campaign_id,StartingScenario_id" &&
    fk.referencedColumns.join() === "Game_id,Campaign_id,Scenario_id"));
});

test("the dictionary maps every composite FK component to its matching target column", () => {
  const campaignHero = dictionary.slice(dictionary.indexOf("## CampaignHero"), dictionary.indexOf("## CampaignHOMM1"));
  const startingScenario = campaignHero.split("\n").find(line => line.startsWith("| `StartingScenario_id`"));
  assert.match(startingScenario, /FK → Scenario\.Scenario_id/);
  assert.match(startingScenario, /FK → CampaignScenario\.Scenario_id/);
  assert.doesNotMatch(startingScenario, /FK → (?:Scenario|CampaignScenario)\.Game_id/);
});
