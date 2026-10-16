// Unknown source values remain NULL. Ordinary creature requirements are retained.
export const sourceNullableColumns = {
  CreatureHOMM6: ['MightDefense', 'MagicDefense', 'CombatSize', 'Movement', 'Speed', 'Initiative', 'Luck', 'Range'],
  CreatureHOMM7: ['Attack', 'Defense', 'DamageMin', 'DamageMax', 'Health', 'Speed', 'CombatSize', 'Movement'],
  ResourceHOMM8: ['IsTradeable', 'IsMineProduced', 'IsPersistent'],
  CampaignHOMM8: ['AvailableActCount'],
  MapHOMM8: ['LevelCount', 'HasUnderground', 'SupportsClassic', 'SupportsSingleHero', 'SupportsArena', 'SupportsMultiplayer', 'SupportsHotseat', 'SupportsMatchmaking', 'SupportsRanked'],
  ScenarioHOMM8: ['AllowsMultiplayer', 'AllowsHotseat', 'SupportsMatchmaking', 'SupportsRanked'],
};
export const sourceAddedColumns = {
  CreatureHOMM6: [['MightResistancePercent', 'SMALLINT'], ['MagicResistancePercent', 'SMALLINT']],
  CreatureHOMM7: [['WarfareStats', 'JSONB']],
};
const required = names => names.map(name => `"${name}" IS NOT NULL`).join(' AND ');
export const sourceDetailChecks = [
  {table:'CreatureHOMM6', name:'ck_h6_ordinary_stats', expression:`"CreatureKind" NOT IN ('Town', 'Neutral') OR (${required(sourceNullableColumns.CreatureHOMM6)})`},
  {table:'CreatureHOMM7', name:'ck_h7_ordinary_stats', expression:`"CreatureKind" = 'Warfare' OR (${required(sourceNullableColumns.CreatureHOMM7)})`},
  {table:'CreatureHOMM7', name:'ck_h7_warfare_profile_scope', expression:`("WarfareStats" IS NULL OR "CreatureKind" = 'Warfare') AND ("CreatureKind" <> 'Warfare' OR "WarfareRole" IS NOT NULL)`},
  ...['Might', 'Magic'].map(kind => ({table:'CreatureHOMM6', name:`ck_h6_${kind.toLowerCase()}_resistance`, expression:`"${kind}ResistancePercent" BETWEEN 0 AND 100`})),
];

export function validateSourceDetails(bundle) {
  const errors=[];
  for(const table of ['CreatureHOMM6','CreatureHOMM7']) for(const row of bundle.tables?.[table]??[]) {
    const ordinary=table==='CreatureHOMM6' ? ['Town','Neutral'].includes(row.CreatureKind) : row.CreatureKind!=='Warfare';
    if(ordinary) for(const field of sourceNullableColumns[table]) if(row[field]==null) errors.push(`${table}/${row._key}.${field} is required for ordinary creatures`);
    if(table==='CreatureHOMM6') for(const field of ['MightResistancePercent','MagicResistancePercent']) {
      if(row[field]!=null && (row[field]<0||row[field]>100)) errors.push(`${table}/${row._key}.${field} must be between 0 and 100`);
    }
    if(table==='CreatureHOMM7') {
      if(row.WarfareStats!=null&&row.CreatureKind!=='Warfare') errors.push(`${table}/${row._key}.WarfareStats requires a warfare unit`);
      if(row.CreatureKind==='Warfare'&&row.WarfareRole==null) errors.push(`${table}/${row._key}.WarfareRole is required for warfare units`);
      for(const [index,profile] of (row.WarfareStats?.profiles??[]).entries()) {
        if(profile.index!==index+1) errors.push(`${table}/${row._key}.WarfareStats profiles must retain contiguous source order`);
        if(profile.damageMin!=null&&profile.damageMax!=null&&profile.damageMin>profile.damageMax) errors.push(`${table}/${row._key}.WarfareStats damage minimum exceeds maximum`);
      }
    }
  }
  return errors;
}
