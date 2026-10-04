#!/usr/bin/env node

import { readFile } from "node:fs/promises";
import path from "node:path";
import process from "node:process";
import { validateJsonColumn } from "./json-contracts.mjs";

function fail(message, errors) {
  errors.push(message);
}

function rowLabel(table, row, index) {
  return `${table}[${index}]${row?._key ? ` (${row._key})` : ""}`;
}

const INTEGER_BOUNDS = {
  SMALLINT: [-32768, 32767],
  INTEGER: [-2147483648, 2147483647],
  BIGINT: [Number.MIN_SAFE_INTEGER, Number.MAX_SAFE_INTEGER],
};

function isCalendarDate(value) {
  if (typeof value !== "string" || !/^\d{4}-\d{2}-\d{2}$/.test(value)) {
    return false;
  }
  const [year, month, day] = value.split("-").map(Number);
  if (year < 1 || month < 1 || month > 12 || day < 1 || day > 31) {
    return false;
  }
  const date = new Date(Date.UTC(year, month - 1, day));
  return (
    date.getUTCFullYear() === year &&
    date.getUTCMonth() === month - 1 &&
    date.getUTCDate() === day
  );
}

function validateScalar(column, value, isForeignKey, tableName) {
  if (value === null) return column.nullable ? null : "must not be null";
  if (column.enumValues) {
    if (typeof value !== "string" || !column.enumValues.includes(value)) {
      return `must be one of: ${column.enumValues.join(", ")}`;
    }
    return null;
  }
  if (["BIGINT", "INTEGER", "SMALLINT"].includes(column.sqlDesignerType)) {
    if (Number.isInteger(value)) {
      const [minimum, maximum] = INTEGER_BOUNDS[column.sqlDesignerType];
      if (value < minimum || value > maximum) {
        return `must fit PostgreSQL ${column.sqlDesignerType} (${minimum} to ${maximum})`;
      }
      return null;
    }
    if (isForeignKey && typeof value === "string" && value.length > 0) return null;
    return isForeignKey
      ? "must be an integer or a referenced row's _key"
      : "must be an integer";
  }
  if (column.sqlDesignerType === "BOOLEAN") {
    return typeof value === "boolean" ? null : "must be a boolean";
  }
  if (column.sqlDesignerType === "DATE") {
    return isCalendarDate(value)
      ? null
      : "must be a real ISO calendar date (YYYY-MM-DD)";
  }
  if (column.sqlDesignerType === "JSONB") return validateJsonColumn(tableName, column.name, value);
  return typeof value === "string" ? null : "must be a string";
}

async function main() {
  const bundlePath = path.resolve(
    process.argv[2] ?? "src/db/data/template.json",
  );
  const schemaPath = path.resolve(
    process.argv[3] ?? "src/db/schema/heroeswatch.schema.json",
  );
  const [bundle, schema] = await Promise.all([
    readFile(bundlePath, "utf8").then(JSON.parse),
    readFile(schemaPath, "utf8").then(JSON.parse),
  ]);

  const errors = [];
  if (bundle.formatVersion !== 1) fail("formatVersion must be 1", errors);
  if (!bundle.tables || typeof bundle.tables !== "object" || Array.isArray(bundle.tables)) {
    fail("tables must be an object", errors);
  }

  const tableByName = new Map(schema.tables.map((table) => [table.name, table]));
  const keysByTable = new Map();
  const primaryRows = new Map();
  for (const table of schema.tables) {
    const index = new Map();
    function addAlias(alias, row) {
      if (alias == null) return;
      const previous = index.get(alias);
      if (previous && previous !== row) {
        fail(`${table.name} has ambiguous identity alias ${JSON.stringify(alias)} shared by ${previous._key} and ${row._key}`, errors);
        return;
      }
      index.set(alias, row);
    }
    for (const row of Array.isArray(bundle.tables?.[table.name]) ? bundle.tables[table.name] : []) {
      if (!row || typeof row !== "object") continue;
      addAlias(row._key, row);
      for (const column of table.primaryKey) addAlias(row[column], row);
    }
    primaryRows.set(table.name, index);
  }
  function identity(targetTable, column, value, targetRow) {
    if (value === null || value === undefined) return null;
    if (targetTable.primaryKey.includes(column)) return targetRow?._key ?? primaryRows.get(targetTable.name).get(value)?._key ?? value;
    const fk = targetTable.foreignKeys.find((candidate) => candidate.columns.length === 1 && candidate.columns[0] === column);
    if (fk) return identity(tableByName.get(fk.referencedTable), fk.referencedColumns[0], value);
    return value;
  }
  const foreignTupleIndexes = new Map();

  for (const suppliedName of Object.keys(bundle.tables ?? {})) {
    if (!tableByName.has(suppliedName)) {
      fail(`Unknown table: ${suppliedName}`, errors);
    }
  }

  for (const table of schema.tables) {
    const rows = bundle.tables?.[table.name];
    if (!Array.isArray(rows)) {
      fail(`${table.name} must be an array`, errors);
      continue;
    }
    const seenKeys = new Set();
    keysByTable.set(table.name, seenKeys);
    const columnsByName = new Map(
      table.columns.map((column) => [column.name, column]),
    );
    const foreignKeyColumns = new Set(
      table.foreignKeys.flatMap((foreignKey) => foreignKey.columns),
    );

    rows.forEach((row, index) => {
      const label = rowLabel(table.name, row, index);
      if (!row || typeof row !== "object" || Array.isArray(row)) {
        fail(`${label} must be an object`, errors);
        return;
      }
      if (typeof row._key !== "string" || row._key.length === 0) {
        fail(`${label} requires a non-empty _key`, errors);
      } else if (seenKeys.has(row._key)) {
        fail(`${label} duplicates _key ${row._key}`, errors);
      } else {
        seenKeys.add(row._key);
      }

      for (const suppliedColumn of Object.keys(row)) {
        if (suppliedColumn !== "_key" && !columnsByName.has(suppliedColumn)) {
          fail(`${label} has unknown field ${suppliedColumn}`, errors);
        }
      }

      for (const column of table.columns) {
        const sharedPrimaryKey =
          column.primaryKey && foreignKeyColumns.has(column.name);
        const mayBeGenerated = column.importGenerated || sharedPrimaryKey;
        if (!(column.name in row)) {
          if (!column.nullable && !mayBeGenerated && !column.primaryKey) {
            fail(`${label} is missing ${column.name}`, errors);
          }
          continue;
        }
        const message = validateScalar(
          column,
          row[column.name],
          foreignKeyColumns.has(column.name),
          table.name,
        );
        if (message) fail(`${label}.${column.name} ${message}`, errors);
      }
    });

    for (const constraint of [
      { columns: table.primaryKey }, ...table.unique.map((columns) => ({ columns })),
      ...(table.uniqueConstraints ?? []),
    ]) {
      const uniqueColumns = constraint.columns;
      const seen = new Map();
      rows.forEach((row, index) => {
        if (!row || typeof row !== "object" || Array.isArray(row)) return;
        const values = uniqueColumns.map((column) => {
          const value = row[column] ?? null;
          const fk = table.foreignKeys.find((candidate) => candidate.columns.length === 1 && candidate.columns[0] === column);
          const parent = fk && primaryRows.get(fk.referencedTable)?.get(value);
          return parent ? parent._key : value;
        });
        if (!constraint.nullsNotDistinct && values.some((value) => value === null)) return;
        const signature = JSON.stringify(values);
        if (seen.has(signature)) {
          fail(
            `${table.name}[${index}] duplicates (${uniqueColumns.join(", ")}) from row ${seen.get(signature)}`,
            errors,
          );
        } else {
          seen.set(signature, index);
        }
      });
    }
  }

  for (const table of schema.tables) {
    const rows = bundle.tables?.[table.name] ?? [];
    if (!Array.isArray(rows)) continue;
    rows.forEach((row, index) => {
      if (!row || typeof row !== "object" || Array.isArray(row)) return;
      const label = rowLabel(table.name, row, index);
      for (const foreignKey of table.foreignKeys) {
        const parentTable = tableByName.get(foreignKey.referencedTable);
        const parentRows = bundle.tables?.[foreignKey.referencedTable] ?? [];
        const values = foreignKey.columns.map((childColumn) => row[childColumn] ??
          (table.primaryKey.includes(childColumn) && row[childColumn] === undefined ? row._key : null));
        // PostgreSQL MATCH SIMPLE: any null component exempts the tuple. Optional
        // global media links have a separate ownership check below.
        if (values.some((value) => value === undefined || value === null)) continue;
        const indexKey = `${parentTable.name}:${foreignKey.referencedColumns.join(",")}`;
        if (!foreignTupleIndexes.has(indexKey)) {
          foreignTupleIndexes.set(indexKey, new Set((Array.isArray(parentRows) ? parentRows : []).filter((parentRow) => parentRow && typeof parentRow === "object").map((parentRow) =>
            JSON.stringify(foreignKey.referencedColumns.map((parentColumn) => identity(parentTable, parentColumn,
              parentRow[parentColumn] ?? (parentTable.primaryKey.includes(parentColumn) ? parentRow._key : null),
              parentTable.primaryKey.includes(parentColumn) ? parentRow : undefined))))));
        }
        const found = foreignTupleIndexes.get(indexKey).has(JSON.stringify(foreignKey.referencedColumns.map((column, position) => identity(parentTable, column, values[position]))));
        if (!found) {
          fail(
            `${label}.${foreignKey.columns.join(",")} references missing ${parentTable.name}.${foreignKey.referencedColumns.join(",")}: ${values.join(",")}`,
            errors,
          );
        }
      }
    });
  }

  // Foreign keys prove existence; retain ownership checks for globals and for
  // diagnostic messages that identify the two conflicting titles.
  // Shared-PK details inherit ownership from their generic catalog row.
  const rowsByKey = new Map(schema.tables.map((table) => [
    table.name,
    new Map((Array.isArray(bundle.tables?.[table.name]) ? bundle.tables[table.name] : []).filter((row) => row && typeof row === "object").map((row) => [row._key, row])),
  ]));
  function referencedRow(foreignKey, value) {
    if (typeof value === "string") return rowsByKey.get(foreignKey.referencedTable)?.get(value);
    return (bundle.tables?.[foreignKey.referencedTable] ?? []).find((row) => row?.[foreignKey.referencedColumns[0]] === value);
  }
  function owner(table, row, visited = new Set()) {
    if (!row) return null;
    if (table.name === "Game") return row;
    const identity = `${table.name}:${row._key}`;
    if (visited.has(identity)) return null;
    visited.add(identity);
    const gameKey = table.foreignKeys.find((fk) => fk.columns.length === 1 && fk.columns[0] === "Game_id");
    if (gameKey) return referencedRow(gameKey, row.Game_id) ?? null;
    const parentKey = table.foreignKeys.find((fk) => fk.columns.length === 1 && table.primaryKey.includes(fk.columns[0]));
    if (parentKey) {
      return owner(tableByName.get(parentKey.referencedTable), referencedRow(parentKey, row[parentKey.columns[0]] ?? row._key), visited);
    }
    const ownershipColumn = {
      FactionLaw: "Faction_id",
      ArtifactSetHOMM5: "IntroducedInExpansion_id",
      ArtifactSetBonusHOMM5: "ArtifactSetHOMM5_id",
    }[table.name];
    const inherited = table.foreignKeys.find((fk) => fk.columns[0] === ownershipColumn);
    if (inherited && row[ownershipColumn] != null) {
      return owner(tableByName.get(inherited.referencedTable), referencedRow(inherited, row[ownershipColumn]), visited);
    }
    return null;
  }
  for (const table of schema.tables) {
    for (const [index, row] of (Array.isArray(bundle.tables?.[table.name]) ? bundle.tables[table.name] : []).entries()) {
      if (!row || typeof row !== "object") continue;
      const game = owner(table, row);
      const detailGame = table.name === "FactionLaw" ? "HOMM8" : table.name.match(/HOMM[1-8]$/)?.[0];
      if (detailGame && game && game.SeriesCode !== detailGame) {
        fail(`${rowLabel(table.name, row, index)} belongs to ${game.SeriesCode}, but ${table.name} requires ${detailGame}`, errors);
      }
      for (const foreignKey of table.foreignKeys) {
        if (foreignKey.columns.length !== 1) continue;
        const column = foreignKey.columns[0];
        const value = row[column] ?? (table.primaryKey.includes(column) ? row._key : null);
        if (value === null || value === undefined) continue;
        const parentGame = owner(tableByName.get(foreignKey.referencedTable), referencedRow(foreignKey, value));
        if (detailGame && parentGame && parentGame.SeriesCode !== detailGame) {
          fail(`${rowLabel(table.name, row, index)}.${column} belongs to ${parentGame.SeriesCode}, but ${table.name} requires ${detailGame}`, errors);
        }
        if (game && parentGame && parentGame._key !== game._key) {
          fail(`${rowLabel(table.name, row, index)}.${column} crosses games (${game.SeriesCode} to ${parentGame.SeriesCode})`, errors);
        }
      }
    }
  }

  // Numbered requirement sets are alternatives. The atoms in one set share an
  // All/Any mode; the same class/ability can legitimately have multiple sets.
  const requirementModes = new Map();
  for (const [index, row] of (bundle.tables?.HeroClassAbilityRequirementGroup ?? []).entries()) {
    if (!Number.isInteger(row.RequirementSet) || row.RequirementSet < 1) {
      fail(`${rowLabel("HeroClassAbilityRequirementGroup", row, index)}.RequirementSet must be a positive integer`, errors);
    }
  }
  for (const [index, row] of (bundle.tables?.HeroClassAbility ?? []).entries()) {
    const label = rowLabel("HeroClassAbility", row, index);
    const hasSet = row.RequirementSet != null;
    if (hasSet !== (row.RequirementMode != null)) fail(`${label} requires RequirementSet and RequirementMode together`, errors);
    if (hasSet && (!Number.isInteger(row.RequirementSet) || row.RequirementSet < 1)) fail(`${label}.RequirementSet must be a positive integer`, errors);
    if (hasSet) {
      const group = JSON.stringify([row.Game_id, row.HeroClass_id, row.Ability_id, row.RequirementSet]);
      if (requirementModes.has(group) && requirementModes.get(group) !== row.RequirementMode) fail(`${label} disagrees with the RequirementMode of its requirement set`, errors);
      requirementModes.set(group, row.RequirementMode);
    }
  }

  for (const [index, row] of (bundle.tables?.FactionSpell ?? []).entries()) {
    if (row.SelectionWeight != null && (!Number.isInteger(row.SelectionWeight) || row.SelectionWeight < 0)) {
      fail(`${rowLabel("FactionSpell", row, index)}.SelectionWeight must be a non-negative integer`, errors);
    }
  }

  // A Resource catalog row may be global, but a cost must use a resource made
  // available by GameResource for this title. Also enforced by composite SQL FK.
  function referenceIdentity(tableName, column, value) {
    if (typeof value === "string") return value;
    return (bundle.tables?.[tableName] ?? []).find((row) => row?.[column] === value)?._key ?? value;
  }
  const resourceMemberships = new Set((bundle.tables?.GameResource ?? []).map((row) => JSON.stringify([
    referenceIdentity("Game", "Game_id", row.Game_id), referenceIdentity("Resource", "Resource_id", row.Resource_id),
  ])));
  for (const table of schema.tables.filter((table) => /^(Creature|Building|Artifact)ResourceCost$/.test(table.name))) {
    for (const [index, row] of (bundle.tables?.[table.name] ?? []).entries()) {
      const tuple = JSON.stringify([referenceIdentity("Game", "Game_id", row.Game_id), referenceIdentity("Resource", "Resource_id", row.Resource_id)]);
      if (!resourceMemberships.has(tuple)) fail(`${rowLabel(table.name, row, index)} uses a resource unavailable in GameResource for its game`, errors);
    }
  }

  if (errors.length > 0) {
    console.error(`Validation failed with ${errors.length} error(s):`);
    for (const error of errors) console.error(`- ${error}`);
    process.exitCode = 1;
    return;
  }

  const rowCount = Object.values(bundle.tables).reduce(
    (sum, rows) => sum + rows.length,
    0,
  );
  console.log(
    `Valid HeroesWatch data bundle: ${schema.tables.length} tables, ${rowCount} rows.`,
  );
}

main().catch((error) => {
  console.error(error.message);
  process.exitCode = 1;
});
