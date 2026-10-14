import {createHash} from 'node:crypto';
import {isDeepStrictEqual} from 'node:util';
const digest = value => createHash('sha256').update(JSON.stringify(value)).digest('hex');

// Reconstructs the exact research baseline for migration tests; never writes data.
export function rewindResearch(catalog, audit) {
  if(digest(catalog)!==audit.outputSha256) throw new Error('Research output hash mismatch');
  const result=structuredClone(catalog);
  for(const patch of [...audit.patches].reverse()) {
    for(const fill of patch.fills) {
      const row=result.tables[fill.table].find(row=>row._key===fill.key);
      if(!row||!isDeepStrictEqual(row[fill.field],fill.value)||fill.expected!==null) throw new Error('Research fill mismatch');
      row[fill.field]=null;
    }
    for(const addition of patch.additions) {
      const rows=result.tables[addition.table], index=rows.findIndex(row=>row._key===addition.key);
      if(index<0||!isDeepStrictEqual(rows[index],addition.row)) throw new Error('Research addition mismatch');
      rows.splice(index,1);
    }
  }
  if(digest(result)!==audit.inputSha256) throw new Error('Reconstructed research baseline hash mismatch');
  return result;
}
