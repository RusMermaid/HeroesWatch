// Resolve a self-contained subset using scalar and composite foreign keys.
// _key values are import identities; generated database IDs are not assumed.
export function selectContentClosure(catalog, schema, seeds) {
  const tableByName = new Map(schema.tables.map(table => [table.name, table]));
  const lookups = new Map(schema.tables.map(table => {
    const lookup = new Map();
    function addAlias(alias, row) {
      if (alias == null) return;
      const previous = lookup.get(alias);
      if (previous && previous !== row) throw new Error(`${table.name} has ambiguous identity alias ${JSON.stringify(alias)} shared by ${previous._key} and ${row._key}`);
      lookup.set(alias, row);
    }
    for (const row of catalog.tables[table.name] ?? []) {
      addAlias(row._key, row);
      for (const column of table.primaryKey) addAlias(row[column], row);
    }
    return [table.name, lookup];
  }));
  function canonical(table, column, value) {
    if (value == null) return null;
    if (table.primaryKey.includes(column)) return lookups.get(table.name).get(value)?._key ?? value;
    const fk = table.foreignKeys.find(fk => fk.columns.length === 1 && fk.columns[0] === column);
    return fk ? canonical(tableByName.get(fk.referencedTable), fk.referencedColumns[0], value) : value;
  }
  const indexes = new Map();
  const selected = new Map(schema.tables.map(table => [table.name, new Set()]));
  const pending = seeds.map(({table, key}) => ({table, key}));
  while (pending.length) {
    const {table: name, key} = pending.pop();
    const table = tableByName.get(name);
    const row = lookups.get(name)?.get(key);
    if (!table || !row) throw new Error(`Missing selected row ${name}/${key}`);
    if (selected.get(name).has(row._key)) continue;
    selected.get(name).add(row._key);
    for (const fk of table.foreignKeys) {
      const values = fk.columns.map(column => row[column] ?? (table.primaryKey.includes(column) ? row._key : null));
      if (values.some(value => value == null)) continue;
      const parent = tableByName.get(fk.referencedTable);
      const indexKey = `${parent.name}:${fk.referencedColumns.join(',')}`;
      if (!indexes.has(indexKey)) {
        const index = new Map();
        for (const candidate of catalog.tables[parent.name] ?? []) {
          const tuple = fk.referencedColumns.map(column => canonical(parent, column,
            candidate[column] ?? (parent.primaryKey.includes(column) ? candidate._key : null)));
          if (tuple.some(value => value == null)) continue;
          const signature = JSON.stringify(tuple);
          if (index.has(signature)) throw new Error(`Ambiguous dependency ${indexKey}/${signature}`);
          index.set(signature, candidate);
        }
        indexes.set(indexKey, index);
      }
      const tuple = JSON.stringify(values.map((value, i) => canonical(parent, fk.referencedColumns[i], value)));
      const target = indexes.get(indexKey).get(tuple);
      if (!target) throw new Error(`Missing dependency ${name}/${row._key}/${fk.columns.join(',')}`);
      pending.push({table: parent.name, key: target._key});
    }
  }
  return Object.fromEntries(schema.tables.map(table => [table.name,
    (catalog.tables[table.name] ?? []).filter(row => selected.get(table.name).has(row._key))]));
}
