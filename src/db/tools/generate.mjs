#!/usr/bin/env node

import { createHash } from "node:crypto";
import { mkdir, readFile, writeFile } from "node:fs/promises";
import path from "node:path";
import process from "node:process";
import { applySchemaOverlay, applySchemaOverlayV2, applySchemaOverlayV3, applySchemaOverlayV4, applySchemaOverlayV5, applySchemaOverlayV6, applySchemaOverlayV7 } from "./schema-overlay.mjs";
import {sourceNullableColumns, sourceAddedColumns, sourceDetailChecks} from './source-detail-rules.mjs';
import { staticCatalogGuardChecks } from "./catalog-guard-rules.mjs";
import { gameIntegritySql, validateExistingScopeSql } from "./game-integrity-sql.mjs";
import { jsonColumnSchema } from "./json-contracts.mjs";
import { graphGuardsSql, validateExistingGraphsSql } from "./graph-guards-sql.mjs";
import { productionGuardsSql, validateExistingProductionGuardsSql } from "./production-guards-sql.mjs";

const POSTGRES_SCHEMA = "heroes_watch";
const DIAGRAM_URL =
  "https://sql-designer.com/diagrams/932ebd44-bda4-45c2-a3e5-0358c579e076";

function parseArgs(argv) {
  const args = { check: false };
  for (let index = 0; index < argv.length; index += 1) {
    const value = argv[index];
    if (value === "--input") args.input = argv[++index];
    else if (value === "--out") args.out = argv[++index];
    else if (value === "--check") args.check = true;
    else if (value === "--help" || value === "-h") args.help = true;
    else throw new Error(`Unknown argument: ${value}`);
  }
  return args;
}

function usage() {
  return [
    "Usage:",
    "  node src/db/tools/generate.mjs --input <sql-designer.json> --out src/db",
    "  node src/db/tools/generate.mjs --input <sql-designer.json> --out src/db --check",
  ].join("\n");
}

function sha256(value) {
  return createHash("sha256").update(value).digest("hex");
}

function quoteIdent(value) {
  return `"${String(value).replaceAll('"', '""')}"`;
}

function quoteLiteral(value) {
  return `'${String(value).replaceAll("'", "''")}'`;
}

function objectName(prefix, ...parts) {
  const raw = [prefix, ...parts]
    .join("__")
    .replaceAll(/[^A-Za-z0-9_]/g, "_");
  if (Buffer.byteLength(raw, "utf8") <= 63) return raw;
  const suffix = sha256(raw).slice(0, 10);
  return `${raw.slice(0, 52)}_${suffix}`;
}

function parseEnum(sqlDesignerType) {
  if (!sqlDesignerType.startsWith("ENUM(")) return null;
  const body = sqlDesignerType.slice(5, -1);
  const values = [];
  const matcher = /'((?:''|[^'])*)'/g;
  let match;
  while ((match = matcher.exec(body)) !== null) {
    values.push(match[1].replaceAll("''", "'"));
  }
  if (values.length === 0) {
    throw new Error(`Could not parse enum: ${sqlDesignerType}`);
  }
  return values;
}

function asArray(value) {
  return Array.isArray(value) ? value : [];
}

function stableSort(value) {
  if (Array.isArray(value)) return value.map(stableSort);
  if (value && typeof value === "object") {
    return Object.fromEntries(
      Object.keys(value)
        .sort()
        .map((key) => [key, stableSort(value[key])]),
    );
  }
  return value;
}

function json(value) {
  return `${JSON.stringify(value, null, 2)}\n`;
}

function keySignature(columns) {
  return columns.join("\u0000");
}

function tableKind(table) {
  const primaryColumn = table.columns.find((column) =>
    table.primaryKey.includes(column.name),
  );
  if (primaryColumn?.name.endsWith("_cid")) return "junction";
  const sharedPrimaryKey = table.foreignKeys.some(
    (foreignKey) =>
      foreignKey.relationship === "one-to-one" &&
      keySignature(foreignKey.columns) === keySignature(table.primaryKey),
  );
  return sharedPrimaryKey ? "game-detail" : "catalog";
}

function buildSemanticSchema(nodes, sourceHash) {
  const tableNodes = nodes
    .filter((node) => node.type === "table")
    .sort((left, right) => left.label.localeCompare(right.label));
  const rowNodes = nodes.filter((node) => node.type === "row");
  const rowById = new Map(rowNodes.map((row) => [row.id, row]));
  const tableByNodeId = new Map(tableNodes.map((table) => [table.id, table]));

  const tables = tableNodes.map((tableNode) => {
    const columns = rowNodes
      .filter((row) => row.parentNode === tableNode.id)
      .sort(
        (left, right) =>
          left.position.y - right.position.y ||
          left.label.localeCompare(right.label),
      )
      .map((row) => {
        const enumValues = parseEnum(row.data.sqlType);
        return {
          name: row.label,
          sqlDesignerType: row.data.sqlType,
          postgresType: enumValues
            ? objectName("Enum", tableNode.label, row.label)
            : row.data.sqlType,
          enumValues,
          nullable: Boolean(row.data.nullable),
          primaryKey: row.data.keyMod === "PRIMARY KEY",
          unique: row.data.keyMod === "UNIQUE",
          unsigned: Boolean(row.data.unsigned),
          default: row.data.defaultValue ?? null,
          comment: row.data.comment ?? null,
        };
      });

    const primaryKey = columns
      .filter((column) => column.primaryKey)
      .map((column) => column.name);
    if (primaryKey.length !== 1) {
      throw new Error(
        `${tableNode.label} must have exactly one primary-key column; found ${primaryKey.length}`,
      );
    }

    const unique = [];
    for (const column of columns.filter((item) => item.unique)) {
      unique.push([column.name]);
    }
    for (const columnsInConstraint of asArray(tableNode.data.uniqueTogether)) {
      unique.push([...columnsInConstraint]);
    }

    return {
      name: tableNode.label,
      kind: "catalog",
      columns,
      primaryKey,
      unique,
      foreignKeys: [],
      comment: null,
    };
  });

  const tableByName = new Map(tables.map((table) => [table.name, table]));

  for (const edge of nodes.filter((node) => node.type === "chickenFoot")) {
    const referencedRow = rowById.get(edge.source);
    const referencingRow = rowById.get(edge.target);
    if (!referencedRow || !referencingRow) {
      throw new Error(`Edge ${edge.id} has a missing row endpoint`);
    }
    const referencedTableNode = tableByNodeId.get(referencedRow.parentNode);
    const referencingTableNode = tableByNodeId.get(referencingRow.parentNode);
    if (!referencedTableNode || !referencingTableNode) {
      throw new Error(`Edge ${edge.id} has a missing table endpoint`);
    }
    const referencingTable = tableByName.get(referencingTableNode.label);
    referencingTable.foreignKeys.push({
      name: objectName(
        "fk",
        referencingTableNode.label,
        referencingRow.label,
        referencedTableNode.label,
      ),
      columns: [referencingRow.label],
      referencedTable: referencedTableNode.label,
      referencedColumns: [referencedRow.label],
      relationship: edge.data?.relationshipType ?? "one-to-many",
      onDelete: "NO ACTION",
      onUpdate: "NO ACTION",
      deferrable: true,
    });
  }

  for (const table of tables) {
    table.foreignKeys.sort(
      (left, right) =>
        left.columns.join().localeCompare(right.columns.join()) ||
        left.referencedTable.localeCompare(right.referencedTable),
    );
    const knownUnique = new Set([
      keySignature(table.primaryKey),
      ...table.unique.map(keySignature),
    ]);
    for (const foreignKey of table.foreignKeys) {
      if (
        foreignKey.relationship === "one-to-one" &&
        !knownUnique.has(keySignature(foreignKey.columns))
      ) {
        table.unique.push([...foreignKey.columns]);
        knownUnique.add(keySignature(foreignKey.columns));
      }
    }
    table.unique.sort((left, right) =>
      keySignature(left).localeCompare(keySignature(right)),
    );
    table.kind = tableKind(table);
    const primaryColumn = table.columns.find((column) => column.primaryKey);
    primaryColumn.generatedIdentity =
      primaryColumn.sqlDesignerType === "BIGINT" && table.kind === "catalog";
    primaryColumn.importGenerated =
      primaryColumn.generatedIdentity || primaryColumn.name.endsWith("_cid");
  }

  const enums = tables.flatMap((table) =>
    table.columns
      .filter((column) => column.enumValues)
      .map((column) => ({
        name: column.postgresType,
        table: table.name,
        column: column.name,
        values: column.enumValues,
      })),
  );

  return {
    formatVersion: 1,
    database: "HeroesWatchNet",
    postgresSchema: POSTGRES_SCHEMA,
    source: {
      kind: "SQLDesigner",
      diagram: DIAGRAM_URL,
      sha256: sourceHash,
    },
    conventions: {
      identifierCase: "PascalCase tables; established *_id and *_cid columns",
      quotedPostgresIdentifiers: true,
      sharedPrimaryKeyDetails: true,
      cidPolicy: "TEXT surrogate for exempt junction rows",
      targetNormalForm: "2NF",
    },
    counts: {
      tables: tables.length,
      columns: tables.reduce((sum, table) => sum + table.columns.length, 0),
      foreignKeys: tables.reduce(
        (sum, table) => sum + table.foreignKeys.length,
        0,
      ),
      enums: enums.length,
    },
    enums,
    tables,
  };
}

function sqlDefault(column) {
  if (column.default === null) return "";
  if (typeof column.default === "boolean") {
    return ` DEFAULT ${column.default ? "TRUE" : "FALSE"}`;
  }
  if (typeof column.default === "number") return ` DEFAULT ${column.default}`;
  return ` DEFAULT ${quoteLiteral(column.default)}`;
}

function postgresType(column) {
  if (column.enumValues) {
    return `${quoteIdent(POSTGRES_SCHEMA)}.${quoteIdent(column.postgresType)}`;
  }
  return column.postgresType;
}

function uniqueDefinition(table, constraint) {
  return `CONSTRAINT ${quoteIdent(objectName("uq", table.name, ...constraint.columns))} UNIQUE${constraint.nullsNotDistinct ? " NULLS NOT DISTINCT" : ""} (${constraint.columns.map(quoteIdent).join(", ")})`;
}

function tableDefinitions(table) {
  const definitions = table.columns.map(column => {
    if (column.generatedIdentity && column.generatedExpression) throw new Error(`${table.name}.${column.name} cannot be both identity and expression-generated`);
    if (column.generatedExpression && column.default !== null) throw new Error(`${table.name}.${column.name} cannot combine a generated expression and default`);
    const generated = column.generatedExpression
      ? ` GENERATED ALWAYS AS (${column.generatedExpression}) STORED`
      : column.generatedIdentity ? " GENERATED BY DEFAULT AS IDENTITY" : "";
    return `    ${quoteIdent(column.name)} ${postgresType(column)}${generated}${sqlDefault(column)}${column.nullable ? "" : " NOT NULL"}`;
  });
  definitions.push(`    CONSTRAINT ${quoteIdent(objectName("pk", table.name))} PRIMARY KEY (${table.primaryKey.map(quoteIdent).join(", ")})`);
  for (const columns of table.unique) definitions.push(`    ${uniqueDefinition(table, { columns })}`);
  for (const constraint of table.uniqueConstraints ?? []) definitions.push(`    ${uniqueDefinition(table, constraint)}`);
  for (const check of table.checks ?? []) definitions.push(`    CONSTRAINT ${quoteIdent(check.name)} CHECK (${check.expression})`);
  return definitions;
}

function foreignKeyDdl(table, foreignKey) {
  return [
    `ALTER TABLE ${quoteIdent(POSTGRES_SCHEMA)}.${quoteIdent(table.name)}`,
    `    ADD CONSTRAINT ${quoteIdent(foreignKey.name)}`,
    `    FOREIGN KEY (${foreignKey.columns.map(quoteIdent).join(", ")})`,
    `    REFERENCES ${quoteIdent(POSTGRES_SCHEMA)}.${quoteIdent(foreignKey.referencedTable)} (${foreignKey.referencedColumns.map(quoteIdent).join(", ")})`,
    `    ON UPDATE ${foreignKey.onUpdate} ON DELETE ${foreignKey.onDelete}`,
    "    DEFERRABLE INITIALLY DEFERRED;", "",
  ].join("\n");
}

function generateDdl(schema) {
  const lines = [
    "-- Generated from src/db/schema/sql-designer.snapshot.json.",
    "-- Do not edit this file directly; run src/db/tools/generate.mjs.",
    "-- Open and execute this whole file in pgAdmin, DBeaver, DataGrip, or psql.",
    `-- Source SHA-256: ${schema.source.sha256}`,
    `-- Expected: ${schema.counts.tables} tables, ${schema.counts.columns} columns, ${schema.counts.foreignKeys} foreign keys.`,
    "",
    "BEGIN;",
    "",
    `CREATE SCHEMA ${quoteIdent(POSTGRES_SCHEMA)};`,
    "",
  ];

  for (const enumType of schema.enums) {
    lines.push(
      `CREATE TYPE ${quoteIdent(POSTGRES_SCHEMA)}.${quoteIdent(enumType.name)} AS ENUM (`,
      enumType.values
        .map((value) => `    ${quoteLiteral(value)}`)
        .join(",\n"),
      ");",
      "",
    );
  }

  for (const table of schema.tables) {
    const definitions = tableDefinitions(table);

    lines.push(
      `CREATE TABLE ${quoteIdent(POSTGRES_SCHEMA)}.${quoteIdent(table.name)} (`,
      definitions.join(",\n"),
      ");",
      "",
    );
  }

  for (const table of schema.tables) {
    for (const foreignKey of table.foreignKeys) {
      lines.push(foreignKeyDdl(table, foreignKey));
    }
  }

  const indexes = new Map();
  for (const table of schema.tables) {
    const covered = new Set([
      keySignature(table.primaryKey),
      ...table.unique.map(keySignature),
    ]);
    for (const foreignKey of table.foreignKeys) {
      const signature = keySignature(foreignKey.columns);
      if (covered.has(signature)) continue;
      const name = objectName("ix", table.name, ...foreignKey.columns);
      indexes.set(
        `${table.name}\u0000${signature}`,
        `CREATE INDEX ${quoteIdent(name)} ON ${quoteIdent(POSTGRES_SCHEMA)}.${quoteIdent(table.name)} (${foreignKey.columns.map(quoteIdent).join(", ")});`,
      );
    }
  }
  for (const statement of [...indexes.values()].sort()) {
    lines.push(statement);
  }

  if (schema.integrity) lines.push("", gameIntegritySql(schema, quoteIdent, quoteLiteral),
    productionGuardsSql(schema, quoteIdent, quoteLiteral), graphGuardsSql(schema, quoteIdent, quoteLiteral));
  lines.push("", "COMMIT;", "");
  return lines.join("\n");
}

function jsonSchemaType(column, foreignKeyColumns, tableName) {
  if (column.enumValues) return { type: "string", enum: column.enumValues };
  if (["BIGINT", "INTEGER", "SMALLINT"].includes(column.sqlDesignerType)) {
    if (foreignKeyColumns.has(column.name)) {
      return {
        oneOf: [
          { type: "integer" },
          {
            type: "string",
            minLength: 1,
            description: "A referenced row's import-only _key",
          },
        ],
      };
    }
    return { type: "integer", ...(column.allowedValues ? { enum: column.allowedValues } : {}) };
  }
  if (column.sqlDesignerType === "BOOLEAN") return { type: "boolean" };
  if (column.sqlDesignerType === "DATE") {
    return { type: "string", format: "date" };
  }
  if (column.sqlDesignerType === "JSONB") return jsonColumnSchema(tableName, column.name);
  return { type: "string" };
}

function generateDataJsonSchema(schema) {
  const tableProperties = {};
  const definitions = {};

  for (const table of schema.tables) {
    const foreignKeyColumns = new Set(
      table.foreignKeys.flatMap((foreignKey) => foreignKey.columns),
    );
    const properties = {
      _key: {
        type: "string",
        minLength: 1,
        description:
          "Import-only stable key. It is never stored as a database column.",
      },
    };
    const required = ["_key"];
    for (const column of table.columns) {
      const valueSchema = jsonSchemaType(column, foreignKeyColumns, table.name);
      if (column.generatedExpression) {
        properties[column.name] = {
          not: {},
          readOnly: true,
          description: `Must be omitted from import JSON. Database-generated from: ${column.generatedExpression}`,
        };
        continue;
      }
      properties[column.name] = column.nullable
        ? {
            anyOf: [valueSchema, { type: "null" }],
            description: column.primaryKey
              ? "Database primary key; normally omitted from human-edited data."
              : undefined,
          }
        : {
            ...valueSchema,
            description: column.primaryKey
              ? "Database primary key; normally omitted from human-edited data."
              : undefined,
          };
      const isSharedPrimaryKey =
        column.primaryKey && foreignKeyColumns.has(column.name);
      if (
        !column.nullable &&
        !column.importGenerated &&
        !isSharedPrimaryKey &&
        !column.primaryKey
      ) {
        required.push(column.name);
      }
    }
    definitions[table.name] = {
      type: "object",
      additionalProperties: false,
      required,
      properties,
    };
    tableProperties[table.name] = {
      type: "array",
      items: { $ref: `#/$defs/${table.name}` },
      default: [],
    };
  }

  return {
    $schema: "https://json-schema.org/draft/2020-12/schema",
    $id: "https://heroeswatch.local/schema/data.schema.json",
    title: "HeroesWatch data-entry bundle",
    type: "object",
    additionalProperties: false,
    required: ["formatVersion", "tables"],
    properties: {
      $schema: { type: "string" },
      formatVersion: { const: 1 },
      notes: { type: "string" },
      tables: {
        type: "object",
        additionalProperties: false,
        required: schema.tables.map((table) => table.name),
        properties: tableProperties,
      },
    },
    $defs: definitions,
  };
}

function generateUpgrade(before, after) {
  const ns = quoteIdent(POSTGRES_SCHEMA);
  const beforeTables = new Map(before.tables.map(table => [table.name, table]));
  const lines = [
    "-- Generated forward migration from the immutable 0001 contract.",
    "-- Apply once to an existing heroes_watch schema before importing current content.",
    "-- PostgreSQL 15+ is required for NULLS NOT DISTINCT identity constraints.",
    "BEGIN;", "",
    `LOCK TABLE ${before.tables.map(table => `${ns}.${quoteIdent(table.name)}`).join(", ")} IN SHARE ROW EXCLUSIVE MODE;`, "",
  ];
  for (const type of after.enums.filter(type => !before.enums.some(old => old.name === type.name))) {
    lines.push(`CREATE TYPE ${ns}.${quoteIdent(type.name)} AS ENUM (${type.values.map(quoteLiteral).join(", ")});`, "");
  }
  for (const table of after.tables) {
    const previous = beforeTables.get(table.name);
    if (!previous) {
      lines.push(`CREATE TABLE ${ns}.${quoteIdent(table.name)} (`, tableDefinitions(table).join(",\n"), ");", "");
      continue;
    }
    for (const column of table.columns.filter(column => !previous.columns.some(old => old.name === column.name))) {
      lines.push(`ALTER TABLE ${ns}.${quoteIdent(table.name)} ADD COLUMN ${quoteIdent(column.name)} ${postgresType(column)}${sqlDefault(column)}${column.nullable ? "" : " NOT NULL"};`);
    }
    for (const columns of previous.unique.filter(columns => !table.unique.some(current => keySignature(columns) === keySignature(current)))) {
      lines.push(`ALTER TABLE ${ns}.${quoteIdent(table.name)} DROP CONSTRAINT ${quoteIdent(objectName("uq", table.name, ...columns))};`);
    }
    for (const columns of table.unique.filter(columns => !previous.unique.some(old => keySignature(columns) === keySignature(old)))) {
      lines.push(`ALTER TABLE ${ns}.${quoteIdent(table.name)} ADD ${uniqueDefinition(table, { columns })};`);
    }
    for (const constraint of table.uniqueConstraints ?? []) {
      lines.push(`ALTER TABLE ${ns}.${quoteIdent(table.name)} ADD ${uniqueDefinition(table, constraint)};`);
    }
    for (const check of table.checks ?? []) {
      lines.push(`ALTER TABLE ${ns}.${quoteIdent(table.name)} ADD CONSTRAINT ${quoteIdent(check.name)} CHECK (${check.expression});`);
    }
  }
  for (const table of after.tables) {
    const previous = beforeTables.get(table.name);
    for (const foreignKey of table.foreignKeys.filter(fk => !previous?.foreignKeys.some(old => old.name === fk.name))) {
      lines.push(foreignKeyDdl(table, foreignKey));
      const columns = foreignKey.columns;
      const oldIndexExists = previous?.foreignKeys.some(fk => keySignature(fk.columns) === keySignature(columns));
      const covered = [table.primaryKey, ...table.unique, ...(table.uniqueConstraints ?? []).map(c => c.columns)]
        .some(key => keySignature(key) === keySignature(columns));
      if (!oldIndexExists && !covered) {
        lines.push(`CREATE INDEX IF NOT EXISTS ${quoteIdent(objectName("ix", table.name, ...columns))} ON ${ns}.${quoteIdent(table.name)} (${columns.map(quoteIdent).join(", ")});`);
      }
    }
  }
  lines.push(gameIntegritySql(after, quoteIdent, quoteLiteral), validateExistingScopeSql(after, quoteIdent, quoteLiteral), "", "COMMIT;", "");
  return lines.join("\n");
}

function generateOverlayUpgrade(before, after) {
  const ns = quoteIdent(POSTGRES_SCHEMA);
  const beforeTables = new Map(before.tables.map(table => [table.name, table]));
  const touched = new Set();
  const lines = [
    "-- Generated forward migration from overlay version 2 to version 3.",
    "-- Apply once after 0002_relationship_integrity.sql.",
    "-- PostgreSQL 15+ is required for NULLS NOT DISTINCT identity constraints.",
    "BEGIN;", "",
  ];

  const identities = table => new Map([
    ...table.unique.map(columns => [keySignature(columns), { columns, nullsNotDistinct: false }]),
    ...(table.uniqueConstraints ?? []).map(constraint => [keySignature(constraint.columns), constraint]),
  ]);

  for (const table of after.tables) {
    const previous = beforeTables.get(table.name);
    if (!previous) throw new Error(`Overlay upgrade cannot add table ${table.name}; use a reviewed migration path.`);
    if (JSON.stringify(previous.columns) !== JSON.stringify(table.columns)) {
      throw new Error(`Overlay upgrade cannot change columns on ${table.name}; use a reviewed migration path.`);
    }
    const oldIdentities = identities(previous);
    const newIdentities = identities(table);
    for (const [signature, oldConstraint] of oldIdentities) {
      const current = newIdentities.get(signature);
      if (!current || Boolean(current.nullsNotDistinct) !== Boolean(oldConstraint.nullsNotDistinct)) {
        lines.push(`ALTER TABLE ${ns}.${quoteIdent(table.name)} DROP CONSTRAINT ${quoteIdent(objectName("uq", table.name, ...oldConstraint.columns))};`);
        touched.add(table.name);
      }
    }
    for (const [signature, constraint] of newIdentities) {
      const oldConstraint = oldIdentities.get(signature);
      if (!oldConstraint || Boolean(oldConstraint.nullsNotDistinct) !== Boolean(constraint.nullsNotDistinct)) {
        lines.push(`ALTER TABLE ${ns}.${quoteIdent(table.name)} ADD ${uniqueDefinition(table, constraint)};`);
        touched.add(table.name);
      }
    }
    const oldChecks = new Set((previous.checks ?? []).map(check => check.name));
    for (const check of table.checks ?? []) {
      if (oldChecks.has(check.name)) continue;
      lines.push(`ALTER TABLE ${ns}.${quoteIdent(table.name)} ADD CONSTRAINT ${quoteIdent(check.name)} CHECK (${check.expression});`);
      touched.add(table.name);
    }
  }

  for (const table of after.tables) {
    const previous = beforeTables.get(table.name);
    for (const foreignKey of table.foreignKeys.filter(fk => !previous.foreignKeys.some(old => old.name === fk.name))) {
      lines.push("", foreignKeyDdl(table, foreignKey).trimEnd());
      const columns = foreignKey.columns;
      const covered = [table.primaryKey, ...table.unique, ...(table.uniqueConstraints ?? []).map(c => c.columns)]
        .some(key => keySignature(key) === keySignature(columns));
      if (!covered) {
        lines.push(`CREATE INDEX IF NOT EXISTS ${quoteIdent(objectName("ix", table.name, ...columns))} ON ${ns}.${quoteIdent(table.name)} (${columns.map(quoteIdent).join(", ")});`);
      }
      touched.add(table.name);
      touched.add(foreignKey.referencedTable);
    }
  }

  lines.splice(5, 0,
    `LOCK TABLE ${[...touched].sort().map(name => `${ns}.${quoteIdent(name)}`).join(", ")} IN SHARE ROW EXCLUSIVE MODE;`, "");
  lines.push("", "COMMIT;", "");
  return lines.join("\n");
}

function generateOverlayV4Upgrade(before, after) {
  const ns = quoteIdent(POSTGRES_SCHEMA);
  const tableNames = ["CreatureHOMM1", "CreatureHOMM2", "CreatureHOMM3", "CreatureHOMM4"];
  const expectedTables = structuredClone(before.tables);
  for (const tableName of tableNames) {
    const oldTable = expectedTables.find(table => table.name === tableName);
    const newTable = after.tables.find(table => table.name === tableName);
    const oldLevel = oldTable?.columns.find(column => column.name === "Level");
    const newTier = newTable?.columns.find(column => column.name === "Tier");
    if (!oldLevel || !newTier || JSON.stringify({ ...oldLevel, name: "Tier" }) !== JSON.stringify(newTier)) {
      throw new Error(`Overlay version 4 requires a data-preserving Level-to-Tier rename on ${tableName}.`);
    }
    oldLevel.name = "Tier";
  }
  if (JSON.stringify(expectedTables) !== JSON.stringify(after.tables) || JSON.stringify(before.enums) !== JSON.stringify(after.enums)) {
    throw new Error("Overlay version 4 contains changes beyond the reviewed creature Tier renames.");
  }
  return [
    "-- Generated forward migration from overlay version 3 to version 4.",
    "-- Apply once after 0003_nullable_identity_and_campaign_scope.sql.",
    "-- Renames creature rank terminology only; all values, nullability, and physical IDs are preserved.",
    "BEGIN;", "",
    `LOCK TABLE ${tableNames.map(name => `${ns}.${quoteIdent(name)}`).join(", ")} IN ACCESS EXCLUSIVE MODE;`, "",
    ...tableNames.map(name => `ALTER TABLE ${ns}.${quoteIdent(name)} RENAME COLUMN ${quoteIdent("Level")} TO ${quoteIdent("Tier")};`),
    "", "COMMIT;", "",
  ].join("\n");
}

function generateOverlayV5Upgrade(before, after) {
  const ns = quoteIdent(POSTGRES_SCHEMA);
  const h1 = after.tables.find(table => table.name === "CreatureHOMM1");
  const h2 = after.tables.find(table => table.name === "CreatureHOMM2");
  const h1Name = h1?.columns.find(column => column.name === "SpeedName");
  const h2Name = h2?.columns.find(column => column.name === "SpeedName");
  if (!h1Name?.generatedExpression || !h2Name?.generatedExpression) {
    throw new Error("Overlay version 5 requires generated SpeedName columns for CreatureHOMM1 and CreatureHOMM2.");
  }
  const expectedTables = structuredClone(before.tables);
  const expectedEnums = structuredClone(before.enums).filter(type => type.name !== "Enum__CreatureHOMM1__Speed");
  for (const [tableName, domain, generated] of [
    ["CreatureHOMM1", [1, 2, 3], h1Name],
    ["CreatureHOMM2", [2, 3, 4, 5, 6, 7], h2Name],
  ]) {
    const table = expectedTables.find(candidate => candidate.name === tableName);
    const speedIndex = table.columns.findIndex(column => column.name === "Speed");
    const speed = table.columns[speedIndex];
    speed.sqlDesignerType = "SMALLINT";
    speed.postgresType = "SMALLINT";
    speed.enumValues = null;
    speed.allowedValues = domain;
    table.columns.splice(speedIndex + 1, 0, structuredClone(generated));
    table.checks ??= [];
    table.checks.push({ name: `ck__${tableName}__Speed_base_domain`, expression: `"Speed" IN (${domain.join(", ")})` });
    table.checks.sort((a, b) => a.name.localeCompare(b.name));
  }
  if (JSON.stringify(expectedTables) !== JSON.stringify(after.tables) || JSON.stringify(expectedEnums) !== JSON.stringify(after.enums)) {
    throw new Error("Overlay version 5 contains changes beyond the reviewed H1/H2 numeric speed representation.");
  }
  const h1Type = `${ns}.${quoteIdent("Enum__CreatureHOMM1__Speed")}`;
  return [
    "-- Generated forward migration from overlay version 4 to version 5.",
    "-- Apply once after 0004_creature_tier_terminology.sql.",
    "-- Numeric Speed is the source of truth; SpeedName is derived and Movement remains separate.",
    "BEGIN;", "",
    `LOCK TABLE ${ns}.${quoteIdent("CreatureHOMM1")}, ${ns}.${quoteIdent("CreatureHOMM2")} IN ACCESS EXCLUSIVE MODE;`, "",
    "DO $validate_creature_speed$",
    "BEGIN",
    `  IF EXISTS (SELECT 1 FROM ${ns}.${quoteIdent("CreatureHOMM1")} WHERE ${quoteIdent("Speed")} IS NULL OR ${quoteIdent("Speed")}::text NOT IN ('Slow', 'Medium', 'Fast')) THEN`,
    "    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'CreatureHOMM1.Speed contains an unsupported legacy label; migration aborted';",
    "  END IF;",
    `  IF EXISTS (SELECT 1 FROM ${ns}.${quoteIdent("CreatureHOMM2")} WHERE ${quoteIdent("Speed")} IS NULL OR ${quoteIdent("Speed")} NOT IN (2, 3, 4, 5, 6, 7)) THEN`,
    "    RAISE EXCEPTION USING ERRCODE = '23514', MESSAGE = 'CreatureHOMM2.Speed contains a value outside the reviewed base domain 2..7; migration aborted';",
    "  END IF;",
    "END",
    "$validate_creature_speed$;", "",
    `ALTER TABLE ${ns}.${quoteIdent("CreatureHOMM1")} ALTER COLUMN ${quoteIdent("Speed")} TYPE SMALLINT USING (CASE ${quoteIdent("Speed")}::text WHEN 'Slow' THEN 1 WHEN 'Medium' THEN 2 WHEN 'Fast' THEN 3 END);`,
    `DROP TYPE ${h1Type};`, "",
    `ALTER TABLE ${ns}.${quoteIdent("CreatureHOMM1")} ADD CONSTRAINT ${quoteIdent("ck__CreatureHOMM1__Speed_base_domain")} CHECK (${quoteIdent("Speed")} IN (1, 2, 3));`,
    `ALTER TABLE ${ns}.${quoteIdent("CreatureHOMM2")} ADD CONSTRAINT ${quoteIdent("ck__CreatureHOMM2__Speed_base_domain")} CHECK (${quoteIdent("Speed")} IN (2, 3, 4, 5, 6, 7));`, "",
    `ALTER TABLE ${ns}.${quoteIdent("CreatureHOMM1")} ADD COLUMN ${quoteIdent("SpeedName")} TEXT GENERATED ALWAYS AS (${h1Name.generatedExpression}) STORED NOT NULL;`,
    `ALTER TABLE ${ns}.${quoteIdent("CreatureHOMM2")} ADD COLUMN ${quoteIdent("SpeedName")} TEXT GENERATED ALWAYS AS (${h2Name.generatedExpression}) STORED NOT NULL;`,
    "", "COMMIT;", "",
  ].join("\n");
}

function generateOverlayV6Upgrade(before, after) {
  const ns = quoteIdent(POSTGRES_SCHEMA);
  const expectedTables = structuredClone(before.tables);
  const expectedByName = new Map(expectedTables.map(table => [table.name, table]));
  for (const rule of staticCatalogGuardChecks) {
    const table = expectedByName.get(rule.table);
    table.checks ??= [];
    table.checks.push({ name: rule.name, expression: rule.expression });
    table.checks.sort((a, b) => a.name.localeCompare(b.name));
  }
  if (JSON.stringify(expectedTables) !== JSON.stringify(after.tables) || JSON.stringify(before.enums) !== JSON.stringify(after.enums)) {
    throw new Error("Overlay version 6 contains changes beyond the reviewed catalog guards.");
  }
  const touched = [...new Set(staticCatalogGuardChecks.map(rule => rule.table))].sort();
  const lines = [
    "-- Generated forward migration from overlay version 5 to version 6.",
    "-- Apply once after 0005_creature_numeric_speed.sql.",
    "-- Adds static catalog guards without deleting, rewriting, or deduplicating content.",
    "BEGIN;", "",
    `LOCK TABLE ${touched.map(name => `${ns}.${quoteIdent(name)}`).join(", ")} IN ACCESS EXCLUSIVE MODE;`, "",
    ...staticCatalogGuardChecks.map(rule =>
      `ALTER TABLE ${ns}.${quoteIdent(rule.table)} ADD CONSTRAINT ${quoteIdent(rule.name)} CHECK (${rule.expression});`),
    "",
    productionGuardsSql(after, quoteIdent, quoteLiteral, { replace: true }),
    "",
    graphGuardsSql(after, quoteIdent, quoteLiteral),
    "",
    validateExistingProductionGuardsSql(after, quoteIdent, quoteLiteral),
    "",
    validateExistingGraphsSql(after, quoteIdent, quoteLiteral),
    "", "COMMIT;", "",
  ];
  return lines.join("\n");
}

function generateOverlayV7Upgrade(before, after) {
  const expected=applySchemaOverlayV7(structuredClone(before));
  if(JSON.stringify(expected.tables)!==JSON.stringify(after.tables)||JSON.stringify(expected.enums)!==JSON.stringify(after.enums)) throw new Error('Unreviewed changes in source detail migration');
  const ns=quoteIdent(POSTGRES_SCHEMA), qualified=name=>`${ns}.${quoteIdent(name)}`;
  return [
    '-- Generated forward migration from overlay version 6 to version 7.',
    '-- Preserves ordinary creature requirements; represents exceptional source profiles and unknown flags.',
    'BEGIN;',
    ...Object.entries(sourceNullableColumns).flatMap(([table,fields])=>fields.map(field=>`ALTER TABLE ${qualified(table)} ALTER COLUMN ${quoteIdent(field)} DROP NOT NULL;`)),
    ...Object.entries(sourceAddedColumns).flatMap(([table,fields])=>fields.map(([field,type])=>`ALTER TABLE ${qualified(table)} ADD COLUMN ${quoteIdent(field)} ${type};`)),
    `ALTER TYPE ${ns}.${quoteIdent('Enum__CreatureHOMM7__WarfareRole')} ADD VALUE 'AttackAndSupport';`,
    `ALTER TYPE ${ns}.${quoteIdent('Enum__CreatureHOMM7__Movement')} ADD VALUE 'Stationary';`,
    ...sourceDetailChecks.map(rule=>`ALTER TABLE ${qualified(rule.table)} ADD CONSTRAINT ${quoteIdent(rule.name)} CHECK (${rule.expression});`),
    'COMMIT;', '',
  ].join('\n');
}

function generateNormalFormReport(schema) {
  const auditedCompositeKeys = new Map([
    [
      "Patch",
      new Set([keySignature(["Game_id", "Version", "Platform"])]),
    ],
    [
      "FactionLaw",
      new Set([
        keySignature(["Faction_id", "Code"]),
        keySignature(["Faction_id", "Tier", "ScreenSide", "SlotIndex"]),
      ]),
    ],
  ]);

  const factionLaw = schema.tables.find((table) => table.name === "FactionLaw");
  const gameHomm8 = schema.tables.find((table) => table.name === "GameHOMM8");
  const factionLawColumns = new Map(
    factionLaw.columns.map((column) => [column.name, column]),
  );
  const gameHomm8Columns = new Map(
    gameHomm8.columns.map((column) => [column.name, column]),
  );
  if (
    factionLawColumns.has("CumulativeSealsRequired") ||
    factionLawColumns.get("Cumulative")?.sqlDesignerType !== "BOOLEAN"
  ) {
    throw new Error(
      "2NF regression: FactionLaw must keep Cumulative BOOLEAN and must not repeat CumulativeSealsRequired.",
    );
  }
  for (let tier = 1; tier <= 5; tier += 1) {
    const column = gameHomm8Columns.get(`LawTier${tier}Seals`);
    if (column?.sqlDesignerType !== "SMALLINT" || column.nullable) {
      throw new Error(
        `2NF regression: GameHOMM8.LawTier${tier}Seals must be a required SMALLINT.`,
      );
    }
  }

  const tables = schema.tables.map((table) => {
    const primaryColumn = table.columns.find((column) => column.primaryKey);
    const candidateKeys = [table.primaryKey, ...table.unique].filter((key) =>
      !(key.length > table.primaryKey.length && table.primaryKey.every(column => key.includes(column))) &&
      key.every(
        (columnName) =>
          !table.columns.find((column) => column.name === columnName).nullable,
      ),
    );
    const exempt = primaryColumn.name.endsWith("_cid");
    const compositeCandidateKeys = candidateKeys.filter((key) => key.length > 1);
    if (!exempt) {
      for (const candidateKey of compositeCandidateKeys) {
        const signature = keySignature(candidateKey);
        const isGameScopedCode =
          signature === keySignature(["Game_id", "Code"]);
        const explicitlyAudited = auditedCompositeKeys
          .get(table.name)
          ?.has(signature);
        if (!isGameScopedCode && !explicitlyAudited) {
          throw new Error(
            `2NF audit required: unrecognized composite candidate key ${table.name}(${candidateKey.join(", ")}).`,
          );
        }
      }
    }
    return {
      table: table.name,
      primaryKey: table.primaryKey,
      candidateKeys,
      status: exempt ? "exempt-_cid" : "2NF-audited",
      reason: exempt
        ? "Explicit user exemption for *_cid junction structures."
        : compositeCandidateKeys.length === 0
          ? "Single-column primary key and no composite candidate key, so no partial-key dependency is possible."
          : "Single-column primary key; recognized composite alternate keys passed the recorded semantic audit.",
    };
  });
  return {
    target: "Second Normal Form (2NF)",
    result: "pass",
    scope: "All non-*_cid tables",
    sourceSha256: schema.source.sha256,
    summary: {
      tables: tables.length,
      passing: tables.filter((table) => table.status === "2NF-audited").length,
      cidExempt: tables.filter((table) => table.status === "exempt-_cid")
        .length,
    },
    appliedCorrection: {
      table: "FactionLaw",
      removed: "CumulativeSealsRequired",
      retainedLawFlag: "Cumulative BOOLEAN",
      movedTo: [
        "GameHOMM8.LawTier1Seals",
        "GameHOMM8.LawTier2Seals",
        "GameHOMM8.LawTier3Seals",
        "GameHOMM8.LawTier4Seals",
        "GameHOMM8.LawTier5Seals",
      ],
      rationale:
        "Tier thresholds depend on the game/tier, while Cumulative is a property of an individual law.",
    },
    jsonbPolicy:
      "PostgreSQL JSONB is treated as one typed value for 2NF. It is retained only where the diagram declares JSONB; relational identities and foreign keys remain columns.",
    tables,
  };
}

function generateDictionary(schema) {
  const lines = [
    "# HeroesWatch data dictionary",
    "",
    "> Generated by `src/db/tools/generate.mjs`. Do not edit by hand.",
    "",
    `Source: ${schema.source.diagram}`,
    "",
  ];
  for (const table of schema.tables) {
    lines.push(
      `## ${table.name}`,
      "",
      `Kind: **${table.kind}**. Primary key: \`${table.primaryKey.join(", ")}\`.`,
      "",
      "| Field | PostgreSQL type | Required | Key / relationship |",
      "|---|---|---:|---|",
    );
    for (const column of table.columns) {
      const relationships = table.foreignKeys
        .filter((foreignKey) => foreignKey.columns.includes(column.name))
        .map(
          (foreignKey) => {
            const position = foreignKey.columns.indexOf(column.name);
            return `FK → ${foreignKey.referencedTable}.${foreignKey.referencedColumns[position]}`;
          },
        );
      if (column.primaryKey) relationships.unshift("PK");
      if (column.unique) relationships.push("UNIQUE");
      if (column.generatedExpression) relationships.push(`GENERATED ALWAYS AS (${column.generatedExpression}) STORED; read-only in import JSON`);
      const type = column.enumValues
        ? `ENUM(${column.enumValues.join(" | ")})`
        : column.postgresType;
      lines.push(
        `| \`${column.name}\` | \`${type}\` | ${column.generatedExpression ? "Generated" : column.nullable ? "No" : "Yes"} | ${relationships.join("; ")} |`,
      );
    }
    if (table.unique.length > 0) {
      lines.push(
        "",
        `Alternate unique keys: ${table.unique.map((key) => `\`(${key.join(", ")})\``).join(", ")}.`,
      );
    }
    for (const constraint of table.uniqueConstraints ?? []) lines.push("", `Additional unique key: \`(${constraint.columns.join(", ")})\`${constraint.nullsNotDistinct ? "; NULL values compare as equal" : ""}.`);
    for (const check of table.checks ?? []) lines.push("", `Check: \`${check.expression}\`.`);
    lines.push("");
  }
  return `${lines.join("\n")}\n`;
}

function generateVerifySql(schema) {
  return `DO $$
DECLARE
    actual_tables integer;
    actual_columns integer;
    actual_primary_keys integer;
    actual_foreign_keys integer;
BEGIN
    SELECT count(*) INTO actual_tables
    FROM information_schema.tables
    WHERE table_schema = '${POSTGRES_SCHEMA}' AND table_type = 'BASE TABLE';

    SELECT count(*) INTO actual_columns
    FROM information_schema.columns
    WHERE table_schema = '${POSTGRES_SCHEMA}';

    SELECT count(*) INTO actual_primary_keys
    FROM pg_constraint c
    JOIN pg_namespace n ON n.oid = c.connamespace
    WHERE n.nspname = '${POSTGRES_SCHEMA}' AND c.contype = 'p';

    SELECT count(*) INTO actual_foreign_keys
    FROM pg_constraint c
    JOIN pg_namespace n ON n.oid = c.connamespace
    WHERE n.nspname = '${POSTGRES_SCHEMA}' AND c.contype = 'f';

    IF actual_tables <> ${schema.counts.tables} THEN
        RAISE EXCEPTION 'Expected ${schema.counts.tables} tables, found %', actual_tables;
    END IF;
    IF actual_columns <> ${schema.counts.columns} THEN
        RAISE EXCEPTION 'Expected ${schema.counts.columns} columns, found %', actual_columns;
    END IF;
    IF actual_primary_keys <> ${schema.counts.tables} THEN
        RAISE EXCEPTION 'Expected ${schema.counts.tables} primary keys, found %', actual_primary_keys;
    END IF;
    IF actual_foreign_keys <> ${schema.counts.foreignKeys} THEN
        RAISE EXCEPTION 'Expected ${schema.counts.foreignKeys} foreign keys, found %', actual_foreign_keys;
    END IF;
END
$$;

SELECT
    '${schema.source.sha256}' AS source_sha256,
    ${schema.counts.tables} AS tables,
    ${schema.counts.columns} AS columns,
    ${schema.counts.foreignKeys} AS foreign_keys;
`;
}

async function emit(filePath, content, check) {
  if (check) {
    let existing;
    try {
      existing = await readFile(filePath, "utf8");
    } catch {
      throw new Error(`Generated file is missing: ${filePath}`);
    }
    // Git may check text files out as CRLF on Windows.
    if (existing.replace(/\r\n/g, "\n") !== content.replace(/\r\n/g, "\n")) {
      throw new Error(`Generated file is stale: ${filePath}`);
    }
    return;
  }
  await mkdir(path.dirname(filePath), { recursive: true });
  await writeFile(filePath, content);
}

async function main() {
  const args = parseArgs(process.argv.slice(2));
  if (args.help) {
    console.log(usage());
    return;
  }
  if (!args.input || !args.out) throw new Error(usage());

  const inputPath = path.resolve(args.input);
  const outputDirectory = path.resolve(args.out);
  const raw = await readFile(inputPath, "utf8");
  const nodes = JSON.parse(raw);
  if (!Array.isArray(nodes)) throw new Error("SQLDesigner snapshot must be an array");

  // Hash semantic content rather than insignificant JSON whitespace so the
  // checked-in snapshot can be used as the next deterministic generator input.
  const sourceHash = sha256(JSON.stringify(stableSort(nodes)));
  const initialSchema = buildSemanticSchema(nodes, sourceHash);
  const overlayV2Schema = applySchemaOverlayV2(structuredClone(initialSchema), objectName);
  const overlayV3Schema = applySchemaOverlayV3(structuredClone(overlayV2Schema), objectName);
  const overlayV4Schema = applySchemaOverlayV4(structuredClone(overlayV3Schema), objectName);
  const overlayV5Schema = applySchemaOverlayV5(structuredClone(overlayV4Schema), objectName);
  const overlayV6Schema = applySchemaOverlayV6(structuredClone(overlayV5Schema));
  const schema = applySchemaOverlay(structuredClone(initialSchema), objectName);
  const ddl = generateDdl(schema);
  const dataSchema = generateDataJsonSchema(schema);
  const template = {
    $schema: "../schema/data.schema.json",
    formatVersion: 1,
    notes: "Replace empty arrays with reviewed rows. Keep _key values stable.",
    tables: Object.fromEntries(schema.tables.map((table) => [table.name, []])),
  };
  const normalFormReport = generateNormalFormReport(schema);
  const dictionary = generateDictionary(schema);
  const verifySql = generateVerifySql(schema);

  const outputs = [
    ["schema/sql-designer.snapshot.json", raw.endsWith("\n") ? raw : `${raw}\n`],
    ["schema/heroeswatch.schema.json", json(stableSort(schema))],
    ["schema/data.schema.json", json(stableSort(dataSchema))],
    ["schema/normal-form-report.json", json(stableSort(normalFormReport))],
    ["HeroesWatch.sql", ddl],
    ["postgres/schema.sql", ddl],
    ["postgres/migrations/0001_initial.sql", generateDdl(initialSchema)],
    ["postgres/migrations/0002_relationship_integrity.sql", generateUpgrade(initialSchema, overlayV2Schema)],
    ["postgres/migrations/0003_nullable_identity_and_campaign_scope.sql", generateOverlayUpgrade(overlayV2Schema, overlayV3Schema)],
    ["postgres/migrations/0004_creature_tier_terminology.sql", generateOverlayV4Upgrade(overlayV3Schema, overlayV4Schema)],
    ["postgres/migrations/0005_creature_numeric_speed.sql", generateOverlayV5Upgrade(overlayV4Schema, overlayV5Schema)],
    ["postgres/migrations/0006_catalog_guards.sql", generateOverlayV6Upgrade(overlayV5Schema, overlayV6Schema)],
    ["postgres/migrations/0007_source_detail_profiles.sql", generateOverlayV7Upgrade(overlayV6Schema, schema)],
    ["postgres/verify.sql", verifySql],
    ["data/template.json", json(template)],
    ["DATA_DICTIONARY.md", dictionary],
  ];

  for (const [relativePath, content] of outputs) {
    await emit(path.join(outputDirectory, relativePath), content, args.check);
  }

  console.log(
    `${args.check ? "Verified" : "Generated"} ${outputs.length} files from ${schema.counts.tables} tables, ${schema.counts.columns} columns, and ${schema.counts.foreignKeys} foreign keys.`,
  );
}

main().catch((error) => {
  console.error(error.message);
  process.exitCode = 1;
});
