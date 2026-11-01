#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import { createHash } from "node:crypto";
import { fileURLToPath } from "node:url";

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "../../../..");
const options = { snapshot: null, catalog: null, output: path.join(root, "src/db/research/2026-10-13/oldenera-followup.patch.json") };
for (let index = 2; index < process.argv.length; index++) {
  const argument = process.argv[index];
  if (argument === "--help") {
    console.log("node build-oldenera-followup.mjs --snapshot PATH --catalog PRISTINE_BASELINE.json [--output PATH]");
    process.exit(0);
  }
  if (!["--snapshot", "--catalog", "--output"].includes(argument)) throw new Error(`Unknown argument: ${argument}`);
  const value = process.argv[++index];
  if (!value || value.startsWith("--")) throw new Error(`Missing value for ${argument}`);
  options[argument.slice(2)] = path.resolve(value);
}
if (!options.snapshot || !options.catalog) {
  throw new Error("Explicit --snapshot and --catalog paths are required; use --help for the reproducible invocation.");
}
const snapshotPath = options.snapshot;
const catalogPath = options.catalog;
const outputPath = options.output;
const sourceUrl = "https://wiki.hoodedhorse.com/Heroes_of_Might_and_Magic_Olden_Era/index.php?title=Heroes_Overview&oldid=32291";
const passiveSchemaUrl = "https://wiki.hoodedhorse.com/Heroes_of_Might_and_Magic_Olden_Era/index.php?title=Template:HeroSpecializationDef&oldid=15885";
const neutralSpellsUrl = "https://wiki.hoodedhorse.com/Heroes_of_Might_and_Magic_Olden_Era/index.php?title=Neutral_Spells&oldid=21359";

const catalog = JSON.parse(fs.readFileSync(catalogPath, "utf8"));
const snapshot = JSON.parse(fs.readFileSync(snapshotPath, "utf8"));
if (outputPath === catalogPath || outputPath === snapshotPath) throw new Error("--output must not overwrite an input file");
if (!Array.isArray(snapshot.rows)) throw new Error("Snapshot requires a rows array");
for (const [index, row] of snapshot.rows.entries()) {
  for (const field of ["hero", "className", "specialty", "description"]) {
    if (typeof row?.[field] !== "string" || !row[field].trim()) throw new Error(`Snapshot row ${index} requires non-empty ${field}`);
  }
}
const sha256 = (value) => createHash("sha256").update(value).digest("hex");
const clean = (value) => value.replace(/\s+/g, " ").replace(/\.([A-Z])/g, ". $1").trim();
const normalizedName = (value) => value.normalize("NFKC")
  .replace(/[‐‑‒–—―]/g, "-").replace(/[‘’]/g, "'").replace(/\s+/g, " ").trim().toLowerCase();

function summarize(row) {
  const source = clean(row.description);
  let match;
  if (/\+5% Movement points for every 8 hero level/.test(source))
    return "Movement points increase by 5% per 8 hero levels, with substantially improved road travel.";
  if (/movement takes no terrain penalties/.test(source))
    return "Ignores terrain movement penalties and gains 1 Sight Radius, plus another 1 per 5 hero levels.";
  match = source.match(/^(.+?) growth in your cities increases by 1\. Under .*? command, (.+?) gain 1 Speed, 1 Initiative, and 20% HP\. Their Attack and Defense increase by 1 for every 3 hero levels, and enemy (.+?) lose an equal amount of Attack and Defense\.$/);
  if (match) return `${match[1]} city growth increases by 1. Commanded ${match[2]} gain 1 Speed, 1 Initiative, and 20% HP; their Attack and Defense rise by 1 per 3 hero levels while enemy ${match[3]} lose the same values.`;
  if (/Friendly creatures have \+1 Morale/.test(source))
    return "Friendly creatures gain 1 Morale and 2% positive-Morale trigger chance per Morale point; that chance bonus increases by 1% per 6 hero levels.";
  match = source.match(/^(?:He|She) produces \+?(\d+) (Gem|Crystals|Mercury) per day, plus another \+?(\d+) for every (\d+) hero level\(s\)\. Increases the amount of (Gems|Crystals|Mercury) found on the map by (\d+)%\.$/);
  if (match) return `Produces ${match[1]} ${match[2]} daily, plus ${match[3]} per ${match[4]} hero levels; map pickups of ${match[5]} yield ${match[6]}% more.`;
  match = source.match(/^(?:He|She) produces \+?(\d+) Gold per day, plus another \+?(\d+) for every (\d+) hero level\(s\)\. Increases the amount of Gold found on the map by (\d+)%\.$/);
  if (match) return `Produces ${match[1]} Gold daily, plus ${match[2]} per ${match[3]} hero levels; Gold pickups on the map yield ${match[4]}% more.`;
  if (/Friendly creatures gain 10% of .* Attack and Defense/.test(source))
    return "Friendly creatures gain 10% of the hero’s Attack and Defense as matching stats, increasing by 5 percentage points per 5 hero levels.";
  if (row.specialty === "Heroic Smite")
    return "Heroic Strike gains 10 damage, plus 5 per 6 hero levels, and makes its target take 10% more damage through the next round; this stacks.";
  if (/each Global Map spell \+1 time/.test(source))
    return "Each Global Map spell gains 1 daily use; maximum mana rises 20%, plus another 5 percentage points per 4 hero levels.";
  if (/additional attribute point/.test(source))
    return "Gains 1 additional attribute point and 5% more experience for every 2 hero levels.";
  match = source.match(/^(?:He|She|They) receives? \+1 level to all (.+?) spells, plus another \+1 for every 10 hero levels\. Casting .+? spells does not prevent .*? from using other spells of the same Magic School\. Enemy hero cannot cast .+? spells\.$/);
  if (match) return `${match[1]} spells gain 1 level, plus another 1 per 10 hero levels; same-school repeat casting remains available, while the enemy hero cannot cast ${match[1]} spells.`;
  match = source.match(/^(?:He|She) starts with the “Masterful (.+?)” spell\. (.+?)(While casting this spell, effective Spell Power is increased by 1 for every 2 hero level\(s\)\.|The cost of this spell is reduced by 1 mana for every 3 hero level\(s\)\.)$/);
  if (match) {
    const effect = match[2].replace(/^This version of the spell /, "Its Masterful version ").replace(/^The effect of this version of the spell /, "Its Masterful effect ");
    const scaling = match[3].startsWith("While")
      ? "Effective Spell Power increases by 1 per 2 hero levels while casting it."
      : "Its mana cost falls by 1 per 3 hero levels.";
    return `Starts with Masterful ${match[1]}. ${effect} ${scaling}`;
  }
  if (/take –10% Damage from basic attacks/.test(source) && /Ranged and Long Reach/.test(source))
    return "Friendly creatures take 10% less basic-attack damage, improving by 1 percentage point per 4 hero levels; Ranged and Long Reach reduction gains another 1 point per 4 levels.";
  if (/keeps? .* army when fleeing/.test(source))
    return "Keeps the army when fleeing neutral battles and gains 10% Diplomacy Persuasion Power, plus another 1 percentage point per 3 hero levels.";
  if (/\+5% Necromancy Power/.test(source))
    return "Necromancy Power increases by 5%, plus another 2 percentage points per 5 hero levels.";
  if (/deal \+10% basic attack Damage/.test(source) && /Ranged and Long Reach/.test(source))
    return "Friendly creatures deal 10% more basic-attack damage, plus 1 percentage point per 4 hero levels; Ranged and Long Reach damage gains another 1 point per 4 levels.";
  if (/\+1 Luck/.test(source) && /Lucky Strike/.test(source))
    return "Gains 1 Luck; friendly creatures gain 3% Lucky Strike chance per Luck point, with another 1 percentage point per 4 hero levels.";
  if (/beginning of each round/.test(source) && /Focus Point/.test(source))
    return "From round two onward, generates 2 Focus Points plus 1 per 3 hero levels, while the enemy loses the same amount.";
  if (/Friendly creatures have \+1 Speed/.test(source))
    return "Friendly creatures gain 1 Speed, plus another 1 per 8 hero levels.";
  if (/Tactics Phase/.test(source) && /creature placement range/.test(source))
    return "During Tactics, deployment range expands by 1 hex and neutral positions are visible; friendly creatures gain 1 Initiative per 6 hero levels.";
  if (/immune to negative effects/.test(source) && /Magic Damage/.test(source))
    return "The hero ignores negative battle and adventure-map effects; friendly creatures take 10% less Magic Damage, improving by 2 percentage points per 3 hero levels.";
  if (/summoned Fire Larva stacks have \+4% health/.test(source))
    return "Summoned Fire Larva stacks gain 4% Health, plus another 2 percentage points per 3 hero levels.";
  if (/deals? \+15% Damage with spells/.test(source))
    return "Spell damage increases by 15%, plus 5 percentage points per 3 hero levels; the opposing hero’s spell damage falls by the same amount.";
  if (/summoned Avatar is immune to Magic Damage/.test(source))
    return "The summoned Avatar is immune to Magic Damage; Summon Avatar gains 1 effective Spell Power per 2 hero levels.";
  if (/summoned Avatar gains a barrier/.test(source))
    return "The summoned Avatar gains a turn-start barrier blocking one damage instance; Summon Avatar gains 1 effective Spell Power per 2 hero levels.";
  if (/deal \+10% basic attack Damage/.test(source) && /Melee Damage/.test(source))
    return "Friendly creatures deal 10% more basic-attack damage, plus 1 percentage point per 4 hero levels; Melee damage gains another 1 point per 4 levels.";
  if (/take –10% basic attack Damage/.test(source) && /Melee attacks/.test(source))
    return "Friendly creatures take 10% less basic-attack damage, improving by 1 percentage point per 4 hero levels; Melee reduction gains another 1 point per 4 levels.";
  if (row.specialty === "Intimidating Strike")
    return "Heroic Strike gains 10 damage, plus 5 per 6 hero levels, and applies a stackable 1 Initiative penalty until battle ends.";
  if (row.specialty === "Stellar Dilation")
    return "Heroic Strike gains 10 damage, plus 5 per 6 hero levels, and applies a stackable 1 Speed penalty until battle ends.";
  if (row.specialty === "True Believer")
    return "Victory grants 1 additional Communion level; maximum Communion also increases by 1 per 8 hero levels.";
  if (row.specialty === "Venomous Strike")
    return "Heroic Strike gains 10 damage plus 5 per 6 levels, then applies stacking battle-long poison dealing 20 + 10% × (hero level − 1) Magic Damage each round.";
  throw new Error(`No summary rule for ${row.hero} / ${row.specialty}: ${source}`);
}

if (snapshot.rows.length !== 108) throw new Error(`Expected 108 official hero rows, found ${snapshot.rows.length}`);
if (!snapshot.revisionLink?.includes("oldid=32291")) throw new Error("Unexpected official source revision");

const heroes = catalog.tables.Hero.filter((row) => row.Game_id === "homm8.game");
const heroByName = new Map(heroes.map((row) => [normalizedName(row.Name), row]));
const heroDetails = new Map(catalog.tables.HeroHOMM8.map((row) => [row._key, row]));
const abilityByKey = new Map(catalog.tables.Ability.map((row) => [row._key, row]));
const detailKeys = new Set(catalog.tables.AbilityHOMM8.map((row) => row._key));
const additions = [];
const fills = [];
const seen = new Set();

for (const sourceRow of snapshot.rows) {
  const hero = heroByName.get(normalizedName(sourceRow.hero));
  if (!hero) throw new Error(`Official hero is absent from H8 catalog: ${sourceRow.hero}`);
  const heroDetail = heroDetails.get(hero._key);
  const key = heroDetail?.SpecializationAbility_id;
  if (!key) throw new Error(`H8 hero has no specialization key: ${sourceRow.hero}`);
  if (seen.has(key)) throw new Error(`Duplicate specialization key: ${key}`);
  seen.add(key);
  const ability = abilityByKey.get(key);
  if (!ability || normalizedName(ability.Name) !== normalizedName(sourceRow.specialty)) {
    throw new Error(`Specialization mismatch for ${sourceRow.hero}: catalog=${ability?.Name}, official=${sourceRow.specialty}`);
  }
  if (ability.Description !== null) throw new Error(`Expected null Ability.Description for ${key}`);
  if (detailKeys.has(key)) throw new Error(`AbilityHOMM8 already exists for ${key}`);
  const summary = clean(summarize(sourceRow));
  const evidence = {
    kind: "official-dated-heroes-overview",
    source: sourceUrl,
    revision: 32291,
    revisionTimestamp: "2026-07-23T15:48:00Z",
    hero: sourceRow.hero,
    className: sourceRow.className,
    officialDescriptionSha256: sha256(clean(sourceRow.description)),
    classificationSource: passiveSchemaUrl,
    classificationEvidence: "HeroSpecializationDef defines every specialization as the hero's unique passive.",
    summaryStyle: "newly worded mechanical summary",
    versionConfidence: "High: the dated official revision predates and is retained by the target 2026-09-29 build snapshot; no later balance is mixed."
  };
  fills.push({ table: "Ability", key, field: "Description", expected: null, value: summary, evidence });
  additions.push({
    table: "AbilityHOMM8",
    row: {
      _key: key,
      AbilityKind: "HeroSpecialization",
      ParentSkill_id: null,
      UnlockMastery: null,
      ChoiceSlot: null,
      IsActive: false,
      IsFocusAction: false,
      IsAlternativeAttack: false,
      FocusChargeCost: null,
      CooldownRounds: null,
      FocusGainRule: null,
      Effect: summary
    },
    evidence
  });
}

const neutralSchoolKey = "homm8.magicschool.neutral";
if (catalog.tables.MagicSchool.some((row) => row._key === neutralSchoolKey)) {
  throw new Error(`${neutralSchoolKey} already exists`);
}
const neutralEvidence = {
  kind: "official-dated-neutral-spell-list",
  source: neutralSpellsUrl,
  revision: 21359,
  revisionTimestamp: "2026-06-01T07:40:00Z",
  sourceClaim: "The official list calls Neutral Magic a school and enumerates the included spell identities.",
  versionConfidence: "High: the dated official revision predates the target 2026-09-29 snapshot."
};
additions.push({
  table: "MagicSchool",
  row: {
    _key: neutralSchoolKey,
    Game_id: "homm8.game",
    Code: "NEUTRAL",
    Name: "Neutral Magic",
    Description: "A fifth spell grouping centered on battle utility and adventure-map movement, transport, information, and support effects.",
    MediaAsset_id: null
  },
  evidence: neutralEvidence
});
const officialNeutralNames = [
  "Magic Arrow", "Necromancer Will", "Back to Town!", "Mana Rite", "Relocation",
  "Pocket Dimension", "Second Wind", "Shadowflight", "Town Portal", "Basic Summon Avatar",
  "Advanced Summon Avatar", "Expert Summon Avatar", "Dimension Door", "Gate of Light"
];
const h8SpellByName = new Map(catalog.tables.Spell.filter((row) => row.Game_id === "homm8.game").map((row) => [row.Name, row]));
const existingSchoolLinks = new Set(catalog.tables.SpellMagicSchool.map((row) => `${row.Spell_id}|${row.MagicSchool_id}`));
for (const name of officialNeutralNames) {
  const spell = h8SpellByName.get(name);
  if (!spell) throw new Error(`Official Neutral Magic spell missing from catalog: ${name}`);
  if (existingSchoolLinks.has(`${spell._key}|${neutralSchoolKey}`)) throw new Error(`Neutral school link already exists: ${spell._key}`);
  additions.push({
    table: "SpellMagicSchool",
    row: {
      _key: `${spell._key}.school.neutral`,
      Game_id: "homm8.game",
      Spell_id: spell._key,
      MagicSchool_id: neutralSchoolKey
    },
    evidence: { ...neutralEvidence, spellName: name }
  });
}

const patch = {
  formatVersion: 1,
  reviewDate: "2026-10-13",
  status: "staged-research-only",
  target: { game: "homm8.game", title: "Heroes of Might and Magic: Olden Era", build: "25061458", snapshotDate: "2026-09-29" },
  scope: {
    officialHeroRows: snapshot.rows.length,
    abilityDescriptionFills: fills.length,
    abilityHOMM8Additions: additions.filter((action) => action.table === "AbilityHOMM8").length,
    magicSchoolAdditions: additions.filter((action) => action.table === "MagicSchool").length,
    spellMagicSchoolAdditions: additions.filter((action) => action.table === "SpellMagicSchool").length,
    totalActions: fills.length + additions.length
  },
  additions,
  fills,
  sources: [
    { id: "heroes-overview-oldid-32291", url: sourceUrl, revision: 32291, revisionTimestamp: "2026-07-23T15:48:00Z", facts: "All 108 released faction heroes, their specialization names, and resolved English mechanics." },
    { id: "hero-specialization-def-oldid-15885", url: passiveSchemaUrl, revision: 15885, facts: "A hero specialization is the unique passive attached to a hero; structured bonus rows compose its mechanics." },
    { id: "neutral-spells-oldid-21359", url: neutralSpellsUrl, revision: 21359, revisionTimestamp: "2026-06-01T07:40:00Z", facts: "Neutral Magic is a source-defined school; this revision enumerates the fourteen staged spell memberships." }
  ],
  held: {
    alternativeAttackDetails: 9,
    reason: "Alternative Attack identity and membership are complete, but the official display does not establish the required IsActive/IsFocusAction combination for all nine shared identities without inferring false from an omitted cost field.",
    magicSchoolHOMM8: "The generic Neutral Magic school and its fourteen official memberships are staged. The required sidecar is held because UsesObservatory and UsesAstrology are not both explicit for Neutral Magic.",
    systems: "FactionLaw, ResourceHOMM8, MagicSchoolHOMM8, AstrologyHOMM8, MapHOMM8 and ScenarioHOMM8 remain governed by the separately documented source/schema blockers."
  }
};

fs.writeFileSync(outputPath, `${JSON.stringify(patch, null, 2)}\n`);
console.log(`Wrote ${path.relative(root, outputPath)}: ${additions.length} additions, ${fills.length} fills.`);
