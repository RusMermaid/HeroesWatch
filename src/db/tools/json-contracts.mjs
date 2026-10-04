// Reviewed source profiles, not a generic JSON escape hatch. Keep schema generation
// and ingestion on the same contract. Nullability belongs to the SQL column.
const text = { type: "string", minLength: 1, maxLength: 16000 };
const label = { type: "string", minLength: 1, maxLength: 256 };
const number = { type: "number", minimum: -1e12, maximum: 1e12 };
const integer = { type: "integer", minimum: -2147483648, maximum: 2147483647 };
const natural = { type: "integer", minimum: 0, maximum: 2147483647 };
const positive = { type: "integer", minimum: 1, maximum: 2147483647 };
const boolean = { type: "boolean" };
const nullable = (schema) => ({ anyOf: [schema, { type: "null" }] });
const enumeration = (...values) => ({ type: "string", enum: values });
const array = (items, maxItems = 256) => ({ type: "array", items, minItems: 1, maxItems });
const object = (properties, required = []) => ({
  type: "object", properties, required, additionalProperties: false, minProperties: 1,
});
const fields = (names, schema) => Object.fromEntries(names.split(/\s+/).filter(Boolean).map((name) => [name, schema]));
const numericFields = (names) => fields(names, number);
const boolFields = (names) => fields(names, boolean);
const rank4 = enumeration("Basic", "Advanced", "Expert", "Master", "Grandmaster");
const primary = object(fields("Attack Defense Power Knowledge", { type: "integer", minimum: 0, maximum: 100 }),
  ["Attack", "Defense", "Power", "Knowledge"]);
const growthChances = object({ levels2To9: primary, levels10Plus: primary }, ["levels2To9", "levels10Plus"]);
const modifier = object({
  kind: { type: "string", pattern: "^[a-z][a-z0-9_]*$", maxLength: 128 },
  value: nullable(number), isCurse: boolean,
}, ["kind", "value", "isCurse"]);
const attributeBonus = object({ attribute: label, value: number, unit: enumeration("points", "percent"), level: positive },
  ["attribute", "value"]);
const sourceReference = { anyOf: [
  object({ title: label, url: { ...text, pattern: "^(https?://|manual:)[^\\s]+$" } }, ["title", "url"]),
  object({ uri: { ...text, pattern: "^manuals/files/[a-f0-9]{12}/manual\\.pdf$" }, pdfPage: positive }, ["uri", "pdfPage"]),
  object({ title: label, sha256: { type: "string", pattern: "^[a-f0-9]{64}$" }, pdfPage: positive, printedPage: positive },
    ["title", "sha256", "pdfPage"]),
] };

const contracts = {};
function register(names, schema) {
  for (const name of names.split(/\s+/).filter(Boolean)) {
    if (Object.hasOwn(contracts, name)) throw new Error(`Duplicate JSON contract: ${name}`);
    contracts[name] = schema;
  }
}

register("AbilityHOMM6.Mechanics", object({ reputationPoints: natural, movementCost: natural }));
register("AdventureObjectHOMM3.Interaction", object({ weeklyAccumulation: boolean, requiresHeroVisit: boolean },
  ["weeklyAccumulation", "requiresHeroVisit"]));
register("AdventureObjectHOMM6.Effect", object({ resource: label, dailyIncome: natural }, ["resource", "dailyIncome"]));
const adventureStats = fields("Might Defense Magic Spirit Destiny Leadership Morale", number);
register("AdventureObjectHOMM7.Effect", object({
  ...adventureStats,
  ...fields("revealRadius durationBattles defaultGoldCost defaultOreCost defaultWoodCost dailyIncome minimum maximum increment artifactCount requiredSetPieces levelIncrease experience", natural),
  ...numericFields("currentMovementBonus movement maximumManaMultiplier navalMovementBonusPercent maximumMovementBonus upgradeCostMultiplier"),
  restoreMana: boolean, resource: label, reveal: enumeration("CurrentMapLayer"), duration: enumeration("EndOfWeek"),
  choice: array(object(adventureStats), 8),
  choices: array(object({ gold: natural, experience: natural }, ["gold", "experience"]), 16),
}));
register("ArtifactHOMM1.Effect", object({
  ...numericFields("attackBonus defenseBonus knowledgeBonus spellPowerBonus goldPerDay moraleBonus luckBonus catapultShotsPerTurn"),
  effect: text,
}));
register("ArtifactHOMM2.Effect", object({ modifiers: array(modifier, 64) }, ["modifiers"]));
const lowerPrimary = object(numericFields("attack defense power knowledge"));
register("ArtifactHOMM3.Effect", object({
  primarySkillBonuses: lowerPrimary, alliedDragonBonuses: lowerPrimary,
  ...numericFields("spellDurationBonusRounds healthBonusPercent townCreatureGrowthBonusPercent"),
  ...boolFields("removesBoardingAndDisembarkingPenalty convertsRemainingLandAndSeaMovement restoresAllSpellPointsDaily allowsAdjacentRangedAttacks removesDistanceAndObstaclePenalties regeneration worksOutsideTown excludesExternalDwellings"),
  excludes: array(label, 32), dailyResources: object(fields("gold wood ore crystal gem mercury sulfur", natural)),
}));
register("ArtifactHOMM5.Effect", object({
  ...numericFields(`attackBonus lightningSpellBonusPercent defenseBonus coldSpellProtectionPercent enemyCreatureInitiativeReductionPercent
    fireSpellProtectionPercent smallCreatureInitiativeBonusPercent luckBonus magicResistancePercent earthSpellDamageBonusPercent
    armyCreatureSpeedBonus spellPowerBonus groundMeleeCreatureInitiativeBonusPercent knowledgeBonus experienceBonusPercent
    warMachineInitiativeBonusPercent moraleBonus largeCreatureInitiativeBonusPercent armyMagicResistancePercent dailyGold
    enemyEarthSpellDamageReductionPercent fireSpellBonusPercent flyingCreatureInitiativeBonusPercent enemyMoraleBonus enemyLuckBonus
    lightningSpellProtectionPercent armyCreatureMaximumHealthBonus armyCreatureInitiativeBonusPercent rangedCreatureInitiativeBonusPercent
    heroSpellManaCostMultiplier coldSpellBonusPercent armyCreatureDamageBonus casterCreatureInitiativeBonusPercent manaGainedPerEnemyManaSpent`),
  ...boolFields("armyShootersIgnoreRangePenalty preventsRetreatForBothCombatants ignoresRoughTerrainMovementPenalties allowsWaterWalking negatesEnemyMindEffectImmunity allowsAdventureFlight"),
}));
register("ArtifactHOMM6.Effect", object({
  maxLevel: positive, experienceThresholds: array(natural, 100), bonuses: array(attributeBonus, 100),
}, ["bonuses"]));
register("ArtifactHOMM7.Effect", object({ bonuses: array(attributeBonus, 100) }, ["bonuses"]));
register("ArtifactSetBonusHOMM5.Effect", object({
  ...numericFields(`ShooterAtbRecoveryReductionPercent HeroShootingAtbRecoveryReductionPercent ArmyMagicProofPercent
    OpeningBlessingsDurationTurns SpellPowerPercent MinimumSpellPowerBonus EnemySpeed EnemyAttackPercentOnNegativeMorale
    EnemyDefensePercentOnNegativeMorale BansheeHowlEnemyMorale BansheeHowlEnemyLuck BansheeHowlEnemyInitiativePercent BansheeHowlAtbCostPercent
    NecromancyCostPercent HeroAtbGainPercentOnPositiveMorale HeroAtbLossPercentOnNegativeMorale EnemyMoraleOnHeroAttack AllPrimaryAttributes
    TierSevenAttack TierSevenDefense TierSevenHealth DailyTierSevenCreatures ElementalVisionEffectMultiplier ArmyCasterManaMultiplier
    ArmyCasterSpellPowerMultiplier HeroSpellAtbRecoveryReductionPercent ExperienceBonusPercent ArmyAttack ArmyHealth
    HeroAttackAtbRecoveryReductionPercent HeroAttack GatingCreatureBonusPercent`),
  OpeningBlessings: text, OpeningBlessingsMastery: enumeration("None", "Basic", "Advanced", "Expert"),
}));
register("BuildingHOMM2.Effect", object({ description: text, necromancyBonusPercentagePoints: number, maximumNecromancyPercent: number }));
register("BuildingHOMM3.Effect", object({
  description: text, goldPerDay: natural, limitPerPlayer: positive, creatureGrowthPercent: number,
  spellLevel: { type: "integer", minimum: 1, maximum: 5 }, spellsOfferedAtLevel: natural,
}));
register("BuildingHOMM4.Effect", object({
  ...boolFields("transportsCreaturesFromTownsAndDwellings addsDefensiveMoat addsDefensiveTowers addsDefensiveWalls enablesCreatureDwellings capturingTownFreesPrisoners holdsDefeatedEnemyHeroes allowsShipConstruction"),
  heroRecruitmentLimit: natural, recruitmentPeriodDays: positive,
}));
// The source records a uniform number per circle, not a map keyed by circle.
register("FactionMagicSchoolHOMM5.GuaranteedSlotsPerCircle", { type: "integer", minimum: 0, maximum: 5 });
register("HeroClassHOMM1.ClassEffect", text);
register("HeroClassHOMM2.PrimarySkillChances HeroClassHOMM3.PrimarySkillChances", growthChances);
const weights2 = ["Archery", "Ballistics", "Diplomacy", "Eagle Eye", "Estates", "Leadership", "Logistics", "Luck", "Mysticism", "Navigation", "Necromancy", "Pathfinding", "Scouting", "Wisdom"];
const weights3 = [...weights2, "Air Magic", "Armorer", "Artillery", "Earth Magic", "Fire Magic", "First Aid", "Intelligence", "Learning", "Offense", "Resistance", "Scholar", "Sorcery", "Tactics", "Water Magic"];
for (const [game, names] of [[2, weights2], [3, weights3]]) register(`HeroClassHOMM${game}.SecondarySkillWeights`,
  object(Object.fromEntries(names.map((name) => [name, { type: "integer", minimum: 0, maximum: 100 }])), names));
register("HeroClassHOMM4.ClassBonus", object({
  ...numericFields(`spellEffectBonusPercent speedBonus movementBonus wolfSummoningBonusPercent whiteTigerSummoningBonusPercent
    resurrectionBonusPercentagePoints meleeLifeDrainFraction summoningBonusPercent illusionBonusPercent friendlyCreatureMeleeAttackBonusPercent
    friendlyCreatureRangedAttackBonusPercent fireSpellEffectBonusPercent fireAttackDamageMultiplier friendlyCreatureMoraleBonus stunDurationTurns
    chaosSpellResistancePercent defenseBonusPercentAgainstChaos deathSpellResistancePercent defenseBonusPercentAgainstDeath meleeDefenseBonusPercent
    rangedDefenseBonusPercent rangedAttackBonus meleeDamageBonusPercent scoutingRadiusBonus dailySummoningExperienceBonus
    friendlyCreatureMeleeDefenseBonusPercent friendlyCreatureRangedDefenseBonusPercent spellPointBonus dailySpellPointRecoveryBonus meleeAttackBonus spellPointCostReduction`),
  ...boolFields(`hasClassAbility luckAlwaysMaximum moraleAlwaysMaximum meleeAttackSetsTargetMoraleToMinimum immuneToFireSpells
    meleeAttackCanStun ignoresWards meleeAttackPoisons poisonStartsOnHitTurn permanentFireShield grantsRangedAttack meleeAttackCausesFear
    preventsTargetRetaliation meleeAttackSetsTargetLuckToMinimum`),
  poisonDuration: enumeration("Combat"),
}));
register("Lore.SourceLinks", array(sourceReference, 128));
const spellLevel4 = object({ maximumSpellLevel: { type: "integer", minimum: 1, maximum: 5 } }, ["maximumSpellLevel"]);
register("SkillHOMM4.MasteryEffects", object(fields("Basic Advanced Expert Master Grandmaster", spellLevel4),
  ["Basic", "Advanced", "Expert", "Master", "Grandmaster"]));
register("SpellHOMM2.Effect", object({ description: text }, ["description"]));
register("SpellHOMM4.Effect", object({
  ...numericFields(`rangedDefenseBonusPercent displacementYards rangedAttackBonusPercent durationTurns spellPointCostMultiplier speedMultiplier
    movementMultiplier damageBonusPercentAgainstLevel4 spellPointCostReduction meleeDamageBonusPercent speedBonus movementBonus meleeDefenseBonusPercent`),
  ...boolFields(`removesAllSpellEffects ignoresRangePenalty ignoresWallPenalty ignoresObstaclePenalty revealsExactArmyCounts revealsEnemyHeroSkills
    cannotAttackStacksWithMoreTotalHitPoints grantsFlight transfersBeneficialSpellFromEnemyToRandomAlly preventsRangedAttacks affectsAllFriendlyTargets
    affectsAllTargets relocatesTargetWithinBattlefield skipsNextAction grantsFirstStrike affectsBothArmies setsLuckToMinimum
    removesAdventureTerrainMovementPenalties summonsCreatures removesCombatTerrainMovementPenalties setsLuckToMaximum spellImmunity`),
  duration: enumeration("Combat"), quantityScaling: enumeration("CasterLevel"), requiresNatureMagic: rank4, requiresDemonology: rank4,
}));
register("SpellHOMM7.EffectByMastery", object(fields("Unskilled Novice Expert Master", object({ formula: text }, ["formula"])),
  ["Unskilled", "Novice", "Expert", "Master"]));
register("TerrainHOMM3.Effect", object({ rulesText: text }, ["rulesText"]));
// Campaign branching keeps native story counters as scalar predicates. Catalog
// endpoint identities remain in the surrounding relational fields.
const campaignCondition = object({
  description: text,
  source: text,
  nativeCounters: object({
    logicOperation: enumeration("And", "Or"),
    array: array(object({
      counterSid: label,
      operation: enumeration("==", "!=", ">", ">=", "<", "<="),
      value: number,
    }, ["counterSid", "operation", "value"]), 128),
  }, ["logicOperation", "array"]),
}, ["description", "source"]);
register("CampaignScenario.AvailabilityCondition ScenarioConnection.Condition", campaignCondition);

// Shared structural profiles: these describe catalog payloads, not game facts.
const key = { type: "string", minLength: 1, maxLength: 256, pattern: "^[A-Za-z0-9_.:-]+$" };
const stack = object({ creatureKey: key, count: natural, minimum: natural, maximum: natural }, ["creatureKey"]);
register("HeroClassHOMM1.StartingArmy HeroClassHOMM2.StartingArmy HeroHOMM3.StartingArmy HeroHOMM5.StartingArmy HeroHOMM6.StartingArmy HeroHOMM7.StartingArmy", array(stack, 16));
register("AdventureObjectHOMM1.Guards AdventureObjectHOMM2.Guards AdventureObjectHOMM3.Guards AdventureObjectHOMM4.Guards AdventureObjectHOMM5.Guards", array(stack, 16));
register("HeroHOMM7.StartingSpells", { ...array(key, 256), uniqueItems: true });
register("AdventureObjectHOMM1.AllowedTerrains AdventureObjectHOMM2.AllowedTerrains AdventureObjectHOMM3.AllowedTerrains AdventureObjectHOMM4.AllowedTerrains ArtifactHOMM7.AllowedFactions", { ...array(key, 128), uniqueItems: true });
const point = object({ x: integer, y: integer }, ["x", "y"]);
register("AdventureObjectHOMM1.Footprint AdventureObjectHOMM2.Footprint AdventureObjectHOMM3.Footprint AdventureObjectHOMM4.Footprint",
  object({ width: positive, height: positive, blockedCells: array(point, 4096), entrance: point }, ["width", "height"]));
register("TownScreenBuilding.Hotspot", { anyOf: [
  object({ x: natural, y: natural, width: positive, height: positive }, ["x", "y", "width", "height"]),
  object({ polygon: { ...array(point, 256), minItems: 3 } }, ["polygon"]),
] });

// No reviewed non-null payload exists for these columns. Rejecting values is
// intentional: a new source needs a documented contract before it is imported.
// SQL NULL remains accepted for all nullable columns by the enclosing row schema.
const reserved = { not: {}, description: "Reserved: no reviewed source JSON profile. Keep SQL NULL until a documented profile is added." };
register(`AbilityHOMM1.Effect AbilityHOMM2.Effect AbilityHOMM3.Effect AbilityHOMM4.Mechanics AbilityHOMM5.Mechanics AbilityHOMM7.Mechanics
  AdventureObjectHOMM1.Rewards AdventureObjectHOMM1.Effect AdventureObjectHOMM2.Interaction AdventureObjectHOMM2.Rewards AdventureObjectHOMM2.Effect
  AdventureObjectHOMM3.Rewards AdventureObjectHOMM3.Effect AdventureObjectHOMM4.Interaction AdventureObjectHOMM4.Rewards AdventureObjectHOMM4.Effect
  AdventureObjectHOMM4.ScriptHooks AdventureObjectHOMM5.Rewards AdventureObjectHOMM5.Effect AdventureObjectHOMM5.ScriptHooks AdventureObjectHOMM8.ScriptDefinition
  ArtifactHOMM4.EquipmentSlots ArtifactHOMM4.Effect ArtifactHOMM6.SetBonuses ArtifactHOMM7.SetBonuses
  BuildingHOMM1.Effect BuildingHOMM2.Requirements BuildingHOMM3.Requirements BuildingHOMM5.Effect BuildingHOMM6.Effect BuildingHOMM7.Effect BuildingRequirement.Condition
  CampaignHOMM1.WarlordSelection CampaignHOMM1.CarryoverRules CampaignHOMM1.RatingRule CampaignHOMM2.SelectableBonuses CampaignHOMM2.CampaignAwards
  CampaignHOMM2.CarryoverRules CampaignHOMM4.CarryoverRules CampaignHOMM4.SelectableBonuses CreatureAbility.Parameters
  FactionHOMM5.TownMechanic FactionNativeTerrainHOMM5.CombatBonus HeroClassHOMM1.PrimarySkillChances HeroClassHOMM2.StartingSkills
  HeroClassHOMM4.StartingSkills HeroClassHOMM4.SkillWeights HeroClassHOMM4.StartingCombatStats HeroClassHOMM5.SkillWeights HeroClassHOMM7.SkillWeights
  HeroHOMM3.SpecialtyEffect HeroHOMM5.SpecialtyEffect HeroHOMM6.SpecialtyEffect MapHOMM8.TemplateDefinition Patch.Changes
  ScenarioHOMM1.VictoryConditions ScenarioHOMM1.LossConditions ScenarioHOMM1.StartingState ScenarioHOMM2.VictoryConditions ScenarioHOMM2.LossConditions ScenarioHOMM2.StartingBonuses
  ScenarioHOMM3.VictoryConditions ScenarioHOMM3.LossConditions ScenarioHOMM3.StartingBonuses ScenarioHOMM3.CarryoverRules ScenarioHOMM4.VictoryConditions ScenarioHOMM4.LossConditions ScenarioHOMM4.CarryoverRules
  ScenarioHOMM5.VictoryConditions ScenarioHOMM5.LossConditions ScenarioHOMM5.StartingState ScenarioHOMM5.CarryoverRules ScenarioHOMM6.VictoryConditions ScenarioHOMM6.LossConditions
  ScenarioHOMM6.StartingState ScenarioHOMM6.CarryoverRules ScenarioHOMM7.VictoryConditions ScenarioHOMM7.LossConditions ScenarioHOMM7.StartingState ScenarioHOMM7.CarryoverRules
  ScenarioHOMM8.Scripts Screenshot.Subjects SkillHOMM7.EffectByMastery SpellHOMM1.Formula SpellHOMM5.EffectByMastery
  TerrainHOMM1.Effect TerrainHOMM2.PathfindingCosts TerrainHOMM2.Effect TerrainHOMM4.Effect TerrainHOMM5.Effect`, reserved);

export function jsonColumnSchema(tableName, columnName) {
  const name = `${tableName}.${columnName}`;
  if (!Object.hasOwn(contracts, name)) throw new Error(`No JSON contract registered for ${name}`);
  return structuredClone(contracts[name]);
}

// Small evaluator for exactly the JSON Schema vocabulary used above. Unsupported
// keywords throw, so a contract change cannot silently weaken runtime validation.
const supported = new Set(["type", "minLength", "maxLength", "pattern", "enum", "minimum", "maximum", "anyOf", "not", "description",
  "items", "minItems", "maxItems", "uniqueItems", "properties", "required", "additionalProperties", "minProperties"]);
export function validateJsonSchema(schema, value, at = "value") {
  for (const keyword of Object.keys(schema)) if (!supported.has(keyword)) throw new Error(`Unsupported JSON contract keyword: ${keyword}`);
  if (schema.not) return `${at} has no reviewed JSON profile; keep SQL NULL`;
  if (schema.anyOf) {
    const alternatives = schema.anyOf.map((alternative) => validateJsonSchema(alternative, value, at));
    return alternatives.some((error) => !error) ? null : `${at} does not match any allowed profile (${alternatives.join("; ")})`;
  }
  const type = value === null ? "null" : Array.isArray(value) ? "array" : typeof value;
  if (schema.type && !(schema.type === type || schema.type === "integer" && Number.isInteger(value))) return `${at} must be ${schema.type}`;
  if (schema.enum && !schema.enum.includes(value)) return `${at} must be one of: ${schema.enum.join(", ")}`;
  if (type === "number") {
    if (!Number.isFinite(value)) return `${at} must be finite`;
    if (schema.minimum !== undefined && value < schema.minimum) return `${at} must be >= ${schema.minimum}`;
    if (schema.maximum !== undefined && value > schema.maximum) return `${at} must be <= ${schema.maximum}`;
  }
  if (type === "string") {
    if (schema.minLength !== undefined && value.length < schema.minLength) return `${at} is too short`;
    if (schema.maxLength !== undefined && value.length > schema.maxLength) return `${at} is too long`;
    if (schema.pattern && !new RegExp(schema.pattern).test(value)) return `${at} has an invalid format`;
  }
  if (type === "array") {
    if (schema.minItems !== undefined && value.length < schema.minItems) return `${at} needs at least ${schema.minItems} item(s)`;
    if (schema.maxItems !== undefined && value.length > schema.maxItems) return `${at} has too many items`;
    if (schema.uniqueItems && new Set(value.map((item) => JSON.stringify(item))).size !== value.length) return `${at} must have unique items`;
    for (const [index, item] of value.entries()) {
      const error = validateJsonSchema(schema.items, item, `${at}[${index}]`);
      if (error) return error;
    }
  }
  if (type === "object") {
    if (schema.minProperties !== undefined && Object.keys(value).length < schema.minProperties) return `${at} must not be empty`;
    for (const required of schema.required ?? []) if (!Object.hasOwn(value, required)) return `${at}.${required} is required`;
    for (const [name, item] of Object.entries(value)) {
      if (!Object.hasOwn(schema.properties ?? {}, name)) return `${at}.${name} is not an allowed field`;
      const error = validateJsonSchema(schema.properties[name], item, `${at}.${name}`);
      if (error) return error;
    }
  }
  return null;
}

export function validateJsonColumn(tableName, columnName, value) {
  const error = validateJsonSchema(jsonColumnSchema(tableName, columnName), value);
  if (error) return error;
  if (/^HeroClassHOMM[23]$/.test(tableName) && columnName === "PrimarySkillChances") {
    for (const [range, chances] of Object.entries(value)) if (Object.values(chances).reduce((sum, chance) => sum + chance, 0) !== 100) return `${range} probabilities must total 100`;
  }
  if (tableName === "ArtifactHOMM6" && columnName === "Effect") {
    if ((value.maxLevel === undefined) !== (value.experienceThresholds === undefined)) return "maxLevel and experienceThresholds must be supplied together";
    if (value.maxLevel !== undefined && (value.experienceThresholds.length !== value.maxLevel || value.experienceThresholds[0] !== 0 ||
      value.experienceThresholds.some((xp, index, values) => index > 0 && xp <= values[index - 1]))) return "experienceThresholds must start at zero and increase once per level";
    if (value.maxLevel !== undefined && value.bonuses.some((bonus) => bonus.level > value.maxLevel)) return "bonus level exceeds maxLevel";
  }
  if (Array.isArray(value) && ["StartingArmy", "Guards"].includes(columnName)) {
    for (const stack of value) {
      if (stack.count === undefined && (stack.minimum === undefined || stack.maximum === undefined)) return "each stack requires count or both minimum and maximum";
      if (stack.count !== undefined && (stack.minimum !== undefined || stack.maximum !== undefined)) return "a stack cannot combine count and a range";
      if (stack.minimum > stack.maximum) return "stack minimum exceeds maximum";
    }
  }
  return null;
}
