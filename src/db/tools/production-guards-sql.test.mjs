import test from "node:test";
import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import {
  BUILDING_DETAIL_TABLES,
  productionGuardsSql,
  validateExistingProductionGuardsSql,
} from "./production-guards-sql.mjs";

const schema = JSON.parse(await readFile(new URL("../schema/heroeswatch.schema.json", import.meta.url), "utf8"));
const quoteIdent = value => `"${String(value).replaceAll('"', '""')}"`;
const quoteLiteral = value => `'${String(value).replaceAll("'", "''")}'`;

test("production guards cover resource membership and every building detail band", () => {
  const sql = productionGuardsSql(schema, quoteIdent, quoteLiteral);
  assert.match(sql, /CREATE OR REPLACE FUNCTION "heroes_watch"\."_require_game_resource"/);
  assert.match(sql, /FROM "heroes_watch"\."GameResource"[\s\S]*FOR KEY SHARE/);
  assert.match(sql, /SignatureResource_id/);
  assert.match(sql, /AstrologyPointResource_id/);
  assert.match(sql, /InsightResource_id/);
  assert.match(sql, /ResourceHOMM8/);
  assert.match(sql, /AFTER DELETE OR UPDATE ON "heroes_watch"\."GameResource"/);
  assert.match(sql, /BEFORE TRUNCATE ON "heroes_watch"\."GameResource"/);
  assert.match(sql, /Use DELETE so deferred resource-membership and reverse-reference safeguards/);
  assert.match(sql, /AFTER UPDATE ON "heroes_watch"\."Faction"/);
  assert.match(sql, /AFTER UPDATE ON "heroes_watch"\."Game"/);
  assert.match(sql, /OLD\."SeriesCode" IS DISTINCT FROM 'HOMM8'[\s\S]*NEW\."SeriesCode" IS DISTINCT FROM 'HOMM8'/);
  assert.match(sql, /_check_scope_row"\('ResourceHOMM8'/);
  assert.match(sql, /_check_homm8_resource_row"\('ResourceHOMM8'/);
  for (const table of BUILDING_DETAIL_TABLES) {
    assert.match(sql, new RegExp(`FROM "heroes_watch"\\."${table}" WHERE "Building_id"`));
    assert.match(sql, new RegExp(`AFTER INSERT OR UPDATE ON "heroes_watch"\\."${table}"`));
  }
  assert.match(sql, /FROM "heroes_watch"\."TownScreen"[\s\S]*FOR SHARE/);
  assert.match(sql, /FROM "heroes_watch"\."Building"[\s\S]*FOR UPDATE/);
  assert.match(sql, /DEFERRABLE INITIALLY DEFERRED/g);
  assert.doesNotMatch(sql, /pg_advisory|LOCK TABLE|DELETE FROM|DROP TABLE|DROP COLUMN/);
});

test("production guards reject only relevant repeatable-read writes", () => {
  const sql = productionGuardsSql(schema, quoteIdent, quoteLiteral);
  assert.equal((sql.match(/current_setting\('transaction_isolation'\) = 'repeatable read'/g) ?? []).length, 7);
  assert.match(sql, /new_data->'Faction_id' IS NOT DISTINCT FROM old_data->'Faction_id'[\s\S]*new_data->'SignatureResource_id' IS NOT DISTINCT FROM old_data->'SignatureResource_id'/);
  assert.match(sql, /NEW\."TownScreenBuilding_cid" IS NOT DISTINCT FROM OLD\."TownScreenBuilding_cid"[\s\S]*NEW\."Building_id" IS NOT DISTINCT FROM OLD\."Building_id"/);
  assert.match(sql, /NEW\."Building_id" IS NOT DISTINCT FROM OLD\."Building_id"[\s\S]*NEW\."Faction_id" IS NOT DISTINCT FROM OLD\."Faction_id"/);
  assert.match(sql, /ERRCODE = '0A000'/);
  assert.match(sql, /CREATE OR REPLACE FUNCTION "heroes_watch"\."_scope_owner"/);
  assert.match(sql, /IF inherited IS NOT NULL THEN RETURN inherited/);
});

test("new functions can omit OR REPLACE while the inherited-owner correction remains a replacement", () => {
  const fresh = productionGuardsSql(schema, quoteIdent, quoteLiteral, { replace: false });
  assert.match(fresh, /CREATE FUNCTION "heroes_watch"\."_require_game_resource"/);
  assert.match(fresh, /CREATE OR REPLACE FUNCTION "heroes_watch"\."_scope_owner"/);
  assert.equal((fresh.match(/CREATE OR REPLACE FUNCTION/g) ?? []).length, 1);
  const validation = validateExistingProductionGuardsSql(schema, quoteIdent, quoteLiteral);
  assert.match(validation, /^-- Block affected writers/);
  assert.match(validation, /IN SHARE ROW EXCLUSIVE MODE/);
  assert.match(validation, /\$validate_production_guards\$/);
  assert.match(validation, /_check_homm8_resource_row/);
  assert.match(validation, /_assert_town_building_faction/);
  assert.doesNotMatch(validation, /ACCESS EXCLUSIVE|DELETE FROM|TRUNCATE/);
});

test("guard generation fails closed if required architecture is absent", () => {
  const broken = structuredClone(schema);
  broken.tables = broken.tables.filter(table => table.name !== "GameResource");
  assert.throws(() => productionGuardsSql(broken, quoteIdent, quoteLiteral), /require table GameResource/);
  const missingColumn = structuredClone(schema);
  missingColumn.tables.find(table => table.name === "FactionHOMM8").columns =
    missingColumn.tables.find(table => table.name === "FactionHOMM8").columns.filter(column => column.name !== "SignatureResource_id");
  assert.throws(() => productionGuardsSql(missingColumn, quoteIdent, quoteLiteral), /FactionHOMM8\.SignatureResource_id/);
});
