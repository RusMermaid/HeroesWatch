#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import { createHash } from "node:crypto";

const options = { metadata: null, positions: null, overview: null, summaries: null, catalog: null, output: null };
for (let index = 2; index < process.argv.length; index++) {
  const argument = process.argv[index];
  if (argument === "--help") {
    console.log("node research-faction-laws.mjs --metadata Law.json --positions LawTreePosition.json --overview LawsOverview.json --summaries faction-laws.summaries.json --catalog heroeswatch.json --output faction-laws.patch.json");
    process.exit(0);
  }
  if (!["--metadata", "--positions", "--overview", "--summaries", "--catalog", "--output"].includes(argument)) throw new Error(`Unknown argument: ${argument}`);
  const value = process.argv[++index];
  if (!value || value.startsWith("--")) throw new Error(`Missing value for ${argument}`);
  options[argument.slice(2)] = path.resolve(value);
}
for (const name of Object.keys(options)) if (!options[name]) throw new Error(`Required option missing: --${name}`);
if (new Set(Object.values(options)).size !== Object.values(options).length) throw new Error("Inputs and output must use distinct paths");

const read = (filename) => JSON.parse(fs.readFileSync(filename, "utf8"));
const sha256 = (value) => createHash("sha256").update(value).digest("hex");
const metadata = read(options.metadata);
const positions = read(options.positions);
const overview = read(options.overview);
const summaries = read(options.summaries);
const catalog = read(options.catalog);
for (const [name, value] of Object.entries({ metadata, positions, overview })) {
  if (!Array.isArray(value.rows)) throw new Error(`${name} snapshot requires rows`);
}
if (summaries.sourceRevision !== 23355 || !Array.isArray(summaries.rows) || summaries.rows.length !== 194) {
  throw new Error("Reviewed summaries must contain 194 rows for Laws Overview revision 23355");
}
const numericTokens = (value) => value.match(/[+−–-]?\d+(?:\.\d+)?%?/g) ?? [];
const normalized = (value) => value.replace(/\s+/g, " ").trim();
const cleanLawName = (value) => {
  const cleaned = normalized(value).replace(/^File:.*?\.png\s+/i, "");
  if (!cleaned || /(?:^|\s)(?:File:|Image:)|\.png\b/i.test(cleaned)) throw new Error(`Unresolved law-name media markup: ${value}`);
  return cleaned;
};

const factionKeys = {
  human: "homm8.faction.temple",
  undead: "homm8.faction.necropolis",
  nature: "homm8.faction.grove",
  demon: "homm8.faction.hive",
  unfrozen: "homm8.faction.schism",
  dungeon: "homm8.faction.dungeon",
};
const factionDisplay = { human: "Temple", undead: "Necropolis", nature: "Grove", demon: "Hive", unfrozen: "Schism", dungeon: "Dungeon" };
const factionRank = { human: 1, undead: 2, nature: 3, demon: 4, unfrozen: 5, dungeon: 6 };
const sideRank = { faction: 1, army: 2 };
const byId = (rows, label) => {
  const map = new Map();
  for (const row of rows) {
    if (!row?.id || map.has(row.id)) throw new Error(`${label} has a missing or duplicate id: ${row?.id}`);
    map.set(row.id, row);
  }
  return map;
};
const laws = byId(metadata.rows, "Law");
const placements = byId(positions.rows, "LawTreePosition");
if (laws.size !== 194 || placements.size !== 194 || overview.rows.length !== 194) {
  throw new Error(`Expected 194 production rows in every source, found Law=${laws.size}, positions=${placements.size}, overview=${overview.rows.length}`);
}
for (const id of laws.keys()) if (!placements.has(id)) throw new Error(`Law has no placement: ${id}`);
for (const id of placements.keys()) if (!laws.has(id)) throw new Error(`Placement has no Law: ${id}`);

const ordered = [...placements.values()].sort((a, b) =>
  factionRank[a.faction] - factionRank[b.faction] || a.tier - b.tier ||
  sideRank[a.side] - sideRank[b.side] || a.slot - b.slot);
const factionCatalogKeys = new Set(catalog.tables.Faction.filter((row) => row.Game_id === "homm8.game").map((row) => row._key));
for (const key of Object.values(factionKeys)) if (!factionCatalogKeys.has(key)) throw new Error(`Missing H8 faction parent: ${key}`);
if (catalog.tables.FactionLaw.length !== 0) throw new Error("FactionLaw must be empty in the selected baseline; refusing to overwrite or duplicate integrated rows");

const additions = [];
const tupleKeys = new Set();
for (const [index, placement] of ordered.entries()) {
  const law = laws.get(placement.id);
  const display = overview.rows[index];
  const reviewed = summaries.rows[index];
  const expectedDisplay = factionDisplay[placement.faction];
  if (display.factionDisplay !== expectedDisplay || display.tier !== placement.tier || display.side.toLowerCase() !== placement.side) {
    throw new Error(`Overview/Cargo ordering mismatch at ${index}: ${placement.id}`);
  }
  if (law.faction !== placement.faction || law.tier !== placement.tier) throw new Error(`Law/position mismatch: ${placement.id}`);
  if (!Number.isInteger(placement.slot) || placement.slot < 0) throw new Error(`Invalid zero-based slot: ${placement.id}`);
  if (!Number.isInteger(law.maxLevel) || law.maxLevel < 1 || law.maxLevel > 3) throw new Error(`Invalid max level: ${placement.id}`);
  if (display.costs.length !== law.maxLevel || display.effects.length !== law.maxLevel) throw new Error(`Level count mismatch: ${placement.id}`);
  if (reviewed?.rowIndex !== index || !Array.isArray(reviewed.effects) || reviewed.effects.length !== law.maxLevel) {
    throw new Error(`Reviewed summary mismatch: ${placement.id}`);
  }
  if (display.costs.some((cost) => !Number.isInteger(cost) || cost < 0) || display.effects.some((effect) => typeof effect !== "string" || !effect.trim())) {
    throw new Error(`Invalid cost/effect data: ${placement.id}`);
  }
  for (let level = 0; level < law.maxLevel; level++) {
    const sourceEffect = normalized(display.effects[level]);
    const summary = normalized(reviewed.effects[level]);
    if (!summary || summary === sourceEffect) throw new Error(`Summary is empty or verbatim: ${placement.id} level ${level + 1}`);
    if (JSON.stringify(numericTokens(summary)) !== JSON.stringify(numericTokens(sourceEffect))) {
      throw new Error(`Summary changes numeric tokens: ${placement.id} level ${level + 1}`);
    }
    const scopeChecks = [
      [/\byour\b/i, /\b(your|own|player)\b/i, "player-owned"],
      [/\bfriendly\b/i, /\b(friendly|allied)\b/i, "friendly"],
      [/\benemy\b/i, /\b(enemy|opposing)\b/i, "enemy"],
      [/\bsummoned\b/i, /\bsummoned\b/i, "summoned"],
      [/\buntil\b/i, /\buntil\b/i, "until"],
      [/\bexcept\b/i, /\bexcept\b/i, "except"],
    ];
    for (const [sourcePattern, summaryPattern, label] of scopeChecks) {
      if (sourcePattern.test(sourceEffect) && !summaryPattern.test(summary)) {
        throw new Error(`Summary drops ${label} scope: ${placement.id} level ${level + 1}`);
      }
    }
  }
  const tuple = `${placement.faction}|${placement.tier}|${placement.side}|${placement.slot}`;
  if (tupleKeys.has(tuple)) throw new Error(`Duplicate screen position: ${tuple}`);
  tupleKeys.add(tuple);
  const row = {
    _key: `homm8.factionlaw.${placement.faction}.${law.ordinal}`,
    Faction_id: factionKeys[placement.faction],
    Code: placement.id.toUpperCase(),
    Name: cleanLawName(display.name),
    Tier: law.tier,
    Cumulative: true,
    ScreenSide: placement.side === "faction" ? "Faction" : "Army",
    SlotIndex: placement.slot,
    MaxLevel: law.maxLevel,
    SealCostLevel1: display.costs[0],
    SealCostLevel2: display.costs[1] ?? null,
    SealCostLevel3: display.costs[2] ?? null,
    EffectLevel1: normalized(reviewed.effects[0]),
    EffectLevel2: reviewed.effects[1] ? normalized(reviewed.effects[1]) : null,
    EffectLevel3: reviewed.effects[2] ? normalized(reviewed.effects[2]) : null,
    Description: null,
    MediaAsset_id: null,
    SourcePath: law.sourcePath,
  };
  additions.push({
    table: "FactionLaw",
    row,
    evidence: {
      kind: "official-live-cargo-law-join",
      sourceLawId: placement.id,
      lawTable: metadata.source,
      positionTable: positions.source,
      overview: overview.revisionLink,
      overviewLastEdited: overview.footerText?.trim(),
      facts: "Law metadata and source path join 1:1 to the zero-based tree position; the overview resolves English name, complete per-level effects, and displayed Law Seal costs.",
      sourceEffectSha256: display.effects.map((effect) => sha256(effect.replace(/\s+/g, " ").trim())),
      summaryStyle: "Concise newly worded mechanical summary; each level is the complete total effect at that level, not an additive delta.",
    },
  });
}

const patch = {
  formatVersion: 1,
  reviewDate: "2026-10-13",
  status: "staged-research-only",
  target: { game: "homm8.game", title: "Heroes of Might and Magic: Olden Era", sourceSnapshot: "official live Cargo tables reviewed 2026-10-13" },
  scope: { productionLaws: additions.length, excludedTestOrUnpositionedRows: 39, expectedEarlierApproximation: 198, authoritativePositionedCount: 194 },
  additions,
  fills: [],
  sources: [
    { id: "cargo-law", url: metadata.source, facts: "Live official Law rows: identity, faction, tier, maximum level and source path." },
    { id: "cargo-law-tree-position", url: positions.source, facts: "Live official one-to-one placements: faction, tier, side and zero-based slot." },
    { id: "laws-overview-23355", url: overview.revisionLink, facts: "Dynamically rendered live Cargo data: English name, resolved per-level effects and displayed Seal costs." },
    { id: "laws-mechanics-19237", url: "https://wiki.hoodedhorse.com/Heroes_of_Might_and_Magic_Olden_Era/index.php?oldid=19237&title=Laws", facts: "Law Points raise faction level; each level grants a Law Seal; Seals are spent on Laws; upgraded descriptions state the entire resulting effect rather than a delta. Cumulative=true means EffectLevelN is the cumulative total at that level; consumers must not add it to prior levels." },
    { id: "laws-module-23354", url: "https://wiki.hoodedhorse.com/Heroes_of_Might_and_Magic_Olden_Era/index.php?oldid=23354&title=Module:LawsOverview", facts: "The official overview joins Law, Translation, LawLevel and LawTreePosition and sorts faction, tier, side and zero-based slot." },
  ],
  held: {
    historicalCountConflict: "Earlier template prose estimated approximately 198 production laws. The live authoritative LawTreePosition table contains exactly 194 one-to-one positioned production rows; only those 194 are staged.",
    versionBoundary: "This is the latest official Cargo snapshot available on the review date. It is not silently labelled as Steam build 25061458 because the wiki does not publish a Cargo-to-Steam-build mapping.",
  },
};
fs.writeFileSync(options.output, `${JSON.stringify(patch, null, 2)}\n`);
console.log(`Wrote ${additions.length} FactionLaw additions to ${options.output}`);
