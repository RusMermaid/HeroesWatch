import {catalogGuardRules} from './catalog-guard-rules.mjs';

export function validateCatalogGuards(schema, bundle) {
  const errors = [];
  const tables = new Map(schema.tables.map(table => [table.name, table]));
  const rows = name => Array.isArray(bundle.tables?.[name]) ? bundle.tables[name].filter(row => row && typeof row === 'object') : [];
  const aliases = new Map(schema.tables.map(table => {
    const map = new Map();
    for (const row of rows(table.name)) for (const value of [row._key, row[table.primaryKey[0]]]) if (value != null) map.set(String(value), row);
    return [table.name, map];
  }));
  const resolve = (table, value) => value == null ? null : aliases.get(table)?.get(String(value));
  const key = (table, value) => resolve(table, value)?._key ?? String(value);
  const owner = (table, row, visited = new Set()) => {
    if (!row || visited.has(`${table}:${row._key}`)) return null;
    visited.add(`${table}:${row._key}`);
    if (table === 'Game') return row;
    const definition = tables.get(table);
    const gameFk = definition?.foreignKeys.find(fk => fk.columns.length === 1 && fk.columns[0] === 'Game_id');
    if (gameFk) return resolve('Game', row.Game_id ?? (definition.primaryKey.includes('Game_id') ? row._key : null));
    const shared = definition?.foreignKeys.find(fk => fk.columns.length === 1 && definition.primaryKey.includes(fk.columns[0]));
    return shared ? owner(shared.referencedTable, resolve(shared.referencedTable, row[shared.columns[0]] ?? row._key), visited) : null;
  };
  for (const table of catalogGuardRules.nonnegativeAmounts) for (const row of rows(table)) {
    if (typeof row.Amount === 'number' && row.Amount < 0) errors.push(`${table}/${row._key}.Amount must be non-negative`);
  }
  for (const row of rows('LoreFull')) if (!catalogGuardRules.loreSubjects.columns.some(column => row[column] != null)) {
    errors.push(`LoreFull/${row._key} must have at least one subject`);
  }
  for (const rule of catalogGuardRules.noSelfEdges) {
    const definition = tables.get(rule.table);
    const leftTable = definition.foreignKeys.find(fk => fk.columns.length === 1 && fk.columns[0] === rule.left).referencedTable;
    const rightTable = definition.foreignKeys.find(fk => fk.columns.length === 1 && fk.columns[0] === rule.right).referencedTable;
    const games = new Map();
    for (const row of rows(rule.table)) {
      const game = key('Game', row.Game_id);
      if (!games.has(game)) games.set(game, new Map());
      const graph = games.get(game), from = key(leftTable, row[rule.left]), to = key(rightTable, row[rule.right]);
      if (from === to) errors.push(`${rule.table}/${row._key} cannot reference itself`);
      if (!graph.has(from)) graph.set(from, new Set());
      graph.get(from).add(to);
      if (!graph.has(to)) graph.set(to, new Set());
    }
    for (const [game, graph] of games) {
      const degree = new Map([...graph.keys()].map(node => [node, 0]));
      for (const targets of graph.values()) for (const target of targets) degree.set(target, degree.get(target) + 1);
      const queue = [...degree].filter(([, value]) => value === 0).map(([node]) => node);
      for (let index = 0; index < queue.length; index++) for (const next of graph.get(queue[index])) {
        degree.set(next, degree.get(next) - 1);
        if (degree.get(next) === 0) queue.push(next);
      }
      if (queue.length !== graph.size) errors.push(`${rule.table} contains a cycle in game ${game}`);
    }
  }
  const memberships = new Set(rows('GameResource').map(row => JSON.stringify([key('Game', row.Game_id), key('Resource', row.Resource_id)])));
  const h8 = rows('Game').find(row => row.SeriesCode === 'HOMM8');
  for (const [table, columns] of [
    ['FactionHOMM8', ['SignatureResource_id']], ['AstrologyHOMM8', ['AstrologyPointResource_id', 'InsightResource_id']], ['ResourceHOMM8', ['Resource_id']],
  ]) for (const row of rows(table)) {
    const game = owner(table, row) ?? (table === 'ResourceHOMM8' ? h8 : null);
    for (const column of columns) {
      const value = row[column] ?? (tables.get(table).primaryKey.includes(column) ? row._key : null);
      if (value != null && (!game || !memberships.has(JSON.stringify([game._key, key('Resource', value)])))) {
        errors.push(`${table}/${row._key}.${column} requires that game's GameResource membership`);
      }
    }
  }
  for (const link of rows('TownScreenBuilding')) {
    const screen = resolve('TownScreen', link.TownScreen_id), building = resolve('Building', link.Building_id);
    const game = building && owner('Building', building);
    if (!screen || !building || !/^HOMM[1-8]$/.test(game?.SeriesCode ?? '')) continue;
    const detail = resolve(`Building${game.SeriesCode}`, building._key) ?? rows(`Building${game.SeriesCode}`).find(row => key('Building', row.Building_id) === building._key);
    if (detail?.Faction_id != null && key('Faction', detail.Faction_id) !== key('Faction', screen.Faction_id)) errors.push(`TownScreenBuilding/${link._key} links different factions`);
  }
  return errors;
}
