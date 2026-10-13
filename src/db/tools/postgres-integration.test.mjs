import test from 'node:test';
import assert from 'node:assert/strict';
import { reconcileInventory } from './postgres-integration-lib.mjs';

const column = (name, postgresType, nullable = false, generatedIdentity = false) => ({
  name, postgresType, nullable, generatedIdentity,
});
const scalarFk = (name, columnName, referencedTable, referencedColumn) => ({
  name,
  columns: [columnName],
  referencedTable,
  referencedColumns: [referencedColumn],
});

test('PostgreSQL reconciliation resolves text aliases, omitted nullable keys, and composite FKs', () => {
  const schema = { tables: [
    {
      name: 'Scope',
      columns: [column('Scope_cid', 'TEXT')],
      primaryKey: ['Scope_cid'],
      unique: [],
      foreignKeys: [],
    },
    {
      name: 'Item',
      columns: [
        column('Item_id', 'BIGINT', false, true),
        column('Scope_cid', 'TEXT'),
        column('Code', 'TEXT'),
        column('Variant', 'TEXT', true),
      ],
      primaryKey: ['Item_id'],
      unique: [],
      uniqueConstraints: [{ columns: ['Scope_cid', 'Code', 'Variant'], nullsNotDistinct: true }],
      foreignKeys: [scalarFk('fk_item_scope', 'Scope_cid', 'Scope', 'Scope_cid')],
    },
    {
      name: 'ItemLink',
      columns: [
        column('ItemLink_cid', 'TEXT'),
        column('Scope_cid', 'TEXT'),
        column('Item_id', 'BIGINT'),
      ],
      primaryKey: ['ItemLink_cid'],
      unique: [],
      foreignKeys: [
        scalarFk('fk_link_scope', 'Scope_cid', 'Scope', 'Scope_cid'),
        scalarFk('fk_link_item', 'Item_id', 'Item', 'Item_id'),
        {
          name: 'fk_link_scope_item',
          columns: ['Scope_cid', 'Item_id'],
          referencedTable: 'Item',
          referencedColumns: ['Scope_cid', 'Item_id'],
        },
      ],
    },
  ] };
  const bundle = { tables: {
    Scope: [{ _key: 'portable.scope', Scope_cid: 'physical.scope' }],
    Item: [{ _key: 'portable.item', Scope_cid: 'physical.scope', Code: 'ITEM' }],
    ItemLink: [{ _key: 'portable.link', Scope_cid: 'portable.scope', Item_id: 'portable.item' }],
  } };
  const actual = {
    Scope: [{ Scope_cid: 'physical.scope' }],
    Item: [{ Item_id: 7, Scope_cid: 'physical.scope', Code: 'ITEM', Variant: null }],
    ItemLink: [{ ItemLink_cid: 'portable.link', Scope_cid: 'physical.scope', Item_id: 7 }],
  };

  const result = reconcileInventory(schema, bundle, actual);
  assert.deepEqual(result, {
    tableArrays: 3,
    expectedRows: 3,
    comparedFields: 5,
    checkedRelationships: 4,
  });
});
