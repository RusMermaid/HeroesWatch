#!/usr/bin/env node

import { readFile } from "node:fs/promises";
import path from "node:path";
import process from "node:process";

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

function validateScalar(column, value, isForeignKey) {
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
  if (column.sqlDesignerType === "JSONB") return null;
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
  if (!bundle.tables || typeof bundle.tables !== "object") {
    fail("tables must be an object", errors);
  }

  const tableByName = new Map(schema.tables.map((table) => [table.name, table]));
  const keysByTable = new Map();

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
        );
        if (message) fail(`${label}.${column.name} ${message}`, errors);
      }
    });

    for (const uniqueColumns of [table.primaryKey, ...table.unique]) {
      const seen = new Map();
      rows.forEach((row, index) => {
        const values = uniqueColumns.map((column) => row[column]);
        if (values.some((value) => value === undefined || value === null)) return;
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
    rows.forEach((row, index) => {
      const label = rowLabel(table.name, row, index);
      for (const foreignKey of table.foreignKeys) {
        const childColumn = foreignKey.columns[0];
        const parentColumn = foreignKey.referencedColumns[0];
        const parentTable = tableByName.get(foreignKey.referencedTable);
        const parentRows = bundle.tables?.[foreignKey.referencedTable] ?? [];
        let value = row[childColumn];
        if (
          value === undefined &&
          table.primaryKey.includes(childColumn) &&
          typeof row._key === "string"
        ) {
          value = row._key;
        }
        if (value === undefined || value === null) continue;
        const found =
          typeof value === "string"
            ? keysByTable.get(foreignKey.referencedTable)?.has(value)
            : parentRows.some((parentRow) => parentRow[parentColumn] === value);
        if (!found) {
          fail(
            `${label}.${childColumn} references missing ${parentTable.name}.${parentColumn}: ${value}`,
            errors,
          );
        }
      }
    });
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
