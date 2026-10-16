// Enumerate only reviewed import-key annotations in ScenarioHOMM3 JSON.
// These values are validated ingestion provenance, not PostgreSQL foreign keys:
// PostgreSQL stores the JSONB verbatim and does not persist portable `_key`s.
export function scenarioHomm3Annotations(row) {
  const references = [];
  const add = (table, key, path, requiresGameResource = false) => {
    if (key !== null && key !== undefined) references.push({ table, key, path, requiresGameResource });
  };
  const victory = row?.VictoryConditions;
  if (victory?.creature) add("Creature", victory.creature.creatureKey, "VictoryConditions.creature");
  if (victory?.artifact) add("Artifact", victory.artifact.artifactKey, "VictoryConditions.artifact");
  for (const key of victory?.resourceKeys ?? []) add("Resource", key, "VictoryConditions.resourceKeys", true);

  for (const reference of row?.CarryoverRules?.keptCreatureTypes ?? [])
    add("Creature", reference.creatureKey, "CarryoverRules.keptCreatureTypes");
  for (const reference of row?.CarryoverRules?.keptArtifactTypes ?? [])
    add("Artifact", reference.artifactKey, "CarryoverRules.keptArtifactTypes");

  for (const choice of row?.StartingBonuses?.choices ?? []) {
    if (choice.hero?.heroKey) add("Hero", choice.hero.heroKey, "StartingBonuses.choices.hero");
    if (choice.creature) add("Creature", choice.creature.creatureKey, "StartingBonuses.choices.creature");
    if (choice.artifact) add("Artifact", choice.artifact.artifactKey, "StartingBonuses.choices.artifact");
    if (choice.spell) add("Spell", choice.spell.spellKey, "StartingBonuses.choices.spell");
    if (choice.skill) add("Skill", choice.skill.skillKey, "StartingBonuses.choices.skill");
    if (choice.scenarioKey) add("Scenario", choice.scenarioKey, "StartingBonuses.choices.scenarioKey");
    for (const key of choice.resourceKeys ?? []) add("Resource", key, "StartingBonuses.choices.resourceKeys", true);
  }
  return references;
}
