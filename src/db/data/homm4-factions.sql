-- Heroes IV factions and non-town creatures, using original Winds of War rules.
-- Snapshot of HOMM4 rows in heroeswatch.json; sources: homm4-factions.sources.md.
-- Execute the whole script in a fresh query session on the existing schema.
-- Resolves identities, preserves other content, and rejects conflicting facts.

BEGIN;
SET LOCAL lock_timeout = '5s';
SET LOCAL statement_timeout = '60s';

DO $homm4_import$
DECLARE
    batch CONSTANT JSONB := $homm4_data$
{
  "Game": [
    {
      "_key": "homm4.game",
      "SeriesCode": "HOMM4",
      "DisplayOrder": 4,
      "Name": "Heroes of Might and Magic IV",
      "ReleaseDate": null,
      "Description": null
    }
  ],
  "Expansion": [
    {
      "_key": "homm4.expansion.base",
      "Game_id": "homm4.game",
      "Code": "BASE",
      "Name": "Heroes of Might and Magic IV",
      "Kind": "BaseGame",
      "ReleaseDate": null,
      "Description": null
    },
    {
      "_key": "homm4.expansion.tgs",
      "Game_id": "homm4.game",
      "Code": "TGS",
      "Name": "The Gathering Storm",
      "Kind": "Expansion",
      "ReleaseDate": null,
      "Description": null
    },
    {
      "_key": "homm4.expansion.wow",
      "Game_id": "homm4.game",
      "Code": "WOW",
      "Name": "Winds of War",
      "Kind": "Expansion",
      "ReleaseDate": null,
      "Description": null
    }
  ],
  "MagicSchool": [
    {
      "_key": "homm4.magicschool.life",
      "Game_id": "homm4.game",
      "Code": "LIFE",
      "Name": "Life",
      "Description": null,
      "MediaAsset_id": null
    },
    {
      "_key": "homm4.magicschool.order",
      "Game_id": "homm4.game",
      "Code": "ORDER",
      "Name": "Order",
      "Description": null,
      "MediaAsset_id": null
    },
    {
      "_key": "homm4.magicschool.death",
      "Game_id": "homm4.game",
      "Code": "DEATH",
      "Name": "Death",
      "Description": null,
      "MediaAsset_id": null
    },
    {
      "_key": "homm4.magicschool.chaos",
      "Game_id": "homm4.game",
      "Code": "CHAOS",
      "Name": "Chaos",
      "Description": null,
      "MediaAsset_id": null
    },
    {
      "_key": "homm4.magicschool.nature",
      "Game_id": "homm4.game",
      "Code": "NATURE",
      "Name": "Nature",
      "Description": null,
      "MediaAsset_id": null
    }
  ],
  "Terrain": [
    {
      "_key": "homm4.terrain.grass",
      "Game_id": "homm4.game",
      "Code": "GRASS",
      "Name": "Grass",
      "Kind": "Basic",
      "Description": null,
      "IntroducedInExpansion_id": "homm4.expansion.base",
      "MediaAsset_id": null
    },
    {
      "_key": "homm4.terrain.snow",
      "Game_id": "homm4.game",
      "Code": "SNOW",
      "Name": "Snow",
      "Kind": "Basic",
      "Description": null,
      "IntroducedInExpansion_id": "homm4.expansion.base",
      "MediaAsset_id": null
    },
    {
      "_key": "homm4.terrain.volcanic",
      "Game_id": "homm4.game",
      "Code": "VOLCANIC",
      "Name": "Volcanic",
      "Kind": "Basic",
      "Description": null,
      "IntroducedInExpansion_id": "homm4.expansion.base",
      "MediaAsset_id": null
    },
    {
      "_key": "homm4.terrain.swamp",
      "Game_id": "homm4.game",
      "Code": "SWAMP",
      "Name": "Swamp",
      "Kind": "Basic",
      "Description": null,
      "IntroducedInExpansion_id": "homm4.expansion.base",
      "MediaAsset_id": null
    },
    {
      "_key": "homm4.terrain.rough",
      "Game_id": "homm4.game",
      "Code": "ROUGH",
      "Name": "Rough",
      "Kind": "Basic",
      "Description": null,
      "IntroducedInExpansion_id": "homm4.expansion.base",
      "MediaAsset_id": null
    }
  ],
  "Faction": [
    {
      "_key": "homm4.faction.haven",
      "Game_id": "homm4.game",
      "Code": "HAVEN",
      "Name": "Haven",
      "Description": null,
      "IntroducedInExpansion_id": "homm4.expansion.base",
      "MediaAsset_id": null
    },
    {
      "_key": "homm4.faction.academy",
      "Game_id": "homm4.game",
      "Code": "ACADEMY",
      "Name": "Academy",
      "Description": null,
      "IntroducedInExpansion_id": "homm4.expansion.base",
      "MediaAsset_id": null
    },
    {
      "_key": "homm4.faction.necropolis",
      "Game_id": "homm4.game",
      "Code": "NECROPOLIS",
      "Name": "Necropolis",
      "Description": null,
      "IntroducedInExpansion_id": "homm4.expansion.base",
      "MediaAsset_id": null
    },
    {
      "_key": "homm4.faction.asylum",
      "Game_id": "homm4.game",
      "Code": "ASYLUM",
      "Name": "Asylum",
      "Description": null,
      "IntroducedInExpansion_id": "homm4.expansion.base",
      "MediaAsset_id": null
    },
    {
      "_key": "homm4.faction.preserve",
      "Game_id": "homm4.game",
      "Code": "PRESERVE",
      "Name": "Preserve",
      "Description": null,
      "IntroducedInExpansion_id": "homm4.expansion.base",
      "MediaAsset_id": null
    },
    {
      "_key": "homm4.faction.stronghold",
      "Game_id": "homm4.game",
      "Code": "STRONGHOLD",
      "Name": "Stronghold",
      "Description": null,
      "IntroducedInExpansion_id": "homm4.expansion.base",
      "MediaAsset_id": null
    }
  ],
  "FactionHOMM4": [
    {
      "_key": "homm4.faction.haven",
      "Alignment": "Life",
      "NativeMagicSchool_id": "homm4.magicschool.life",
      "NativeTerrain_id": "homm4.terrain.grass",
      "AlliedFactionA_id": "homm4.faction.academy",
      "AlliedFactionB_id": "homm4.faction.preserve",
      "HasMagicGuild": true
    },
    {
      "_key": "homm4.faction.academy",
      "Alignment": "Order",
      "NativeMagicSchool_id": "homm4.magicschool.order",
      "NativeTerrain_id": "homm4.terrain.snow",
      "AlliedFactionA_id": "homm4.faction.haven",
      "AlliedFactionB_id": "homm4.faction.necropolis",
      "HasMagicGuild": true
    },
    {
      "_key": "homm4.faction.necropolis",
      "Alignment": "Death",
      "NativeMagicSchool_id": "homm4.magicschool.death",
      "NativeTerrain_id": "homm4.terrain.volcanic",
      "AlliedFactionA_id": "homm4.faction.academy",
      "AlliedFactionB_id": "homm4.faction.asylum",
      "HasMagicGuild": true
    },
    {
      "_key": "homm4.faction.asylum",
      "Alignment": "Chaos",
      "NativeMagicSchool_id": "homm4.magicschool.chaos",
      "NativeTerrain_id": "homm4.terrain.swamp",
      "AlliedFactionA_id": "homm4.faction.necropolis",
      "AlliedFactionB_id": "homm4.faction.preserve",
      "HasMagicGuild": true
    },
    {
      "_key": "homm4.faction.preserve",
      "Alignment": "Nature",
      "NativeMagicSchool_id": "homm4.magicschool.nature",
      "NativeTerrain_id": "homm4.terrain.grass",
      "AlliedFactionA_id": "homm4.faction.haven",
      "AlliedFactionB_id": "homm4.faction.asylum",
      "HasMagicGuild": true
    },
    {
      "_key": "homm4.faction.stronghold",
      "Alignment": "Might",
      "NativeMagicSchool_id": null,
      "NativeTerrain_id": "homm4.terrain.rough",
      "AlliedFactionA_id": null,
      "AlliedFactionB_id": null,
      "HasMagicGuild": false
    }
  ],
  "Creature": [
    {
      "_key": "homm4.creature.peasant",
      "Game_id": "homm4.game",
      "Code": "PEASANT",
      "Name": "Peasant",
      "Description": "Outside the standard town creature lineup; recruitable from an adventure-map dwelling.",
      "IntroducedInExpansion_id": "homm4.expansion.base",
      "MediaAsset_id": null
    },
    {
      "_key": "homm4.creature.leprechaun",
      "Game_id": "homm4.game",
      "Code": "LEPRECHAUN",
      "Name": "Leprechaun",
      "Description": "Outside the standard town creature lineup; available through the Preserve's Creature Portal.",
      "IntroducedInExpansion_id": "homm4.expansion.base",
      "MediaAsset_id": null
    },
    {
      "_key": "homm4.creature.troglodyte",
      "Game_id": "homm4.game",
      "Code": "TROGLODYTE",
      "Name": "Troglodyte",
      "Description": "Outside the standard town creature lineup; recruitable from an adventure-map dwelling.",
      "IntroducedInExpansion_id": "homm4.expansion.base",
      "MediaAsset_id": null
    },
    {
      "_key": "homm4.creature.pirate",
      "Game_id": "homm4.game",
      "Code": "PIRATE",
      "Name": "Pirate",
      "Description": "Outside the standard town creature lineup; recruitable from an adventure-map dwelling.",
      "IntroducedInExpansion_id": "homm4.expansion.base",
      "MediaAsset_id": null
    },
    {
      "_key": "homm4.creature.zombie",
      "Game_id": "homm4.game",
      "Code": "ZOMBIE",
      "Name": "Zombie",
      "Description": "Outside the standard town creature lineup; recruitable from an adventure-map dwelling.",
      "IntroducedInExpansion_id": "homm4.expansion.base",
      "MediaAsset_id": null
    },
    {
      "_key": "homm4.creature.satyr",
      "Game_id": "homm4.game",
      "Code": "SATYR",
      "Name": "Satyr",
      "Description": "Outside the standard town creature lineup; available through the Preserve's Creature Portal.",
      "IntroducedInExpansion_id": "homm4.expansion.base",
      "MediaAsset_id": null
    },
    {
      "_key": "homm4.creature.evil.eye",
      "Game_id": "homm4.game",
      "Code": "EVIL_EYE",
      "Name": "Evil Eye",
      "Description": "Outside the standard town creature lineup; recruitable from an adventure-map dwelling.",
      "IntroducedInExpansion_id": "homm4.expansion.base",
      "MediaAsset_id": null
    },
    {
      "_key": "homm4.creature.troll",
      "Game_id": "homm4.game",
      "Code": "TROLL",
      "Name": "Troll",
      "Description": "Outside the standard town creature lineup; recruitable from an adventure-map dwelling.",
      "IntroducedInExpansion_id": "homm4.expansion.base",
      "MediaAsset_id": null
    },
    {
      "_key": "homm4.creature.mummy",
      "Game_id": "homm4.game",
      "Code": "MUMMY",
      "Name": "Mummy",
      "Description": "Outside the standard town creature lineup; recruitable from an adventure-map dwelling.",
      "IntroducedInExpansion_id": "homm4.expansion.base",
      "MediaAsset_id": null
    },
    {
      "_key": "homm4.creature.gargoyle",
      "Game_id": "homm4.game",
      "Code": "GARGOYLE",
      "Name": "Gargoyle",
      "Description": "Outside the standard town creature lineup; recruitable from an adventure-map dwelling.",
      "IntroducedInExpansion_id": "homm4.expansion.base",
      "MediaAsset_id": null
    },
    {
      "_key": "homm4.creature.mermaid",
      "Game_id": "homm4.game",
      "Code": "MERMAID",
      "Name": "Mermaid",
      "Description": "Outside the standard town creature lineup; cannot be purchased from a dwelling in the unmodified game.",
      "IntroducedInExpansion_id": "homm4.expansion.base",
      "MediaAsset_id": null
    },
    {
      "_key": "homm4.creature.waspwort",
      "Game_id": "homm4.game",
      "Code": "WASPWORT",
      "Name": "Waspwort",
      "Description": "Outside the standard town creature lineup; available through the Preserve's Creature Portal.",
      "IntroducedInExpansion_id": "homm4.expansion.base",
      "MediaAsset_id": null
    },
    {
      "_key": "homm4.creature.fire.elemental",
      "Game_id": "homm4.game",
      "Code": "FIRE_ELEMENTAL",
      "Name": "Fire Elemental",
      "Description": "Outside the standard town creature lineup; available through the Preserve's Creature Portal.",
      "IntroducedInExpansion_id": "homm4.expansion.base",
      "MediaAsset_id": null
    },
    {
      "_key": "homm4.creature.air.elemental",
      "Game_id": "homm4.game",
      "Code": "AIR_ELEMENTAL",
      "Name": "Air Elemental",
      "Description": "Outside the standard town creature lineup; available through the Preserve's Creature Portal.",
      "IntroducedInExpansion_id": "homm4.expansion.base",
      "MediaAsset_id": null
    },
    {
      "_key": "homm4.creature.water.elemental",
      "Game_id": "homm4.game",
      "Code": "WATER_ELEMENTAL",
      "Name": "Water Elemental",
      "Description": "Outside the standard town creature lineup; available through the Preserve's Creature Portal.",
      "IntroducedInExpansion_id": "homm4.expansion.base",
      "MediaAsset_id": null
    },
    {
      "_key": "homm4.creature.earth.elemental",
      "Game_id": "homm4.game",
      "Code": "EARTH_ELEMENTAL",
      "Name": "Earth Elemental",
      "Description": "Outside the standard town creature lineup; available through the Preserve's Creature Portal.",
      "IntroducedInExpansion_id": "homm4.expansion.base",
      "MediaAsset_id": null
    },
    {
      "_key": "homm4.creature.ice.demon",
      "Game_id": "homm4.game",
      "Code": "ICE_DEMON",
      "Name": "Ice Demon",
      "Description": "Outside the standard town creature lineup; recruitable from an adventure-map dwelling.",
      "IntroducedInExpansion_id": "homm4.expansion.base",
      "MediaAsset_id": null
    },
    {
      "_key": "homm4.creature.mantis",
      "Game_id": "homm4.game",
      "Code": "MANTIS",
      "Name": "Mantis",
      "Description": "Outside the standard town creature lineup; available through the Preserve's Creature Portal.",
      "IntroducedInExpansion_id": "homm4.expansion.base",
      "MediaAsset_id": null
    },
    {
      "_key": "homm4.creature.sea.monster",
      "Game_id": "homm4.game",
      "Code": "SEA_MONSTER",
      "Name": "Sea Monster",
      "Description": "Outside the standard town creature lineup; cannot be purchased from a dwelling in the unmodified game.",
      "IntroducedInExpansion_id": "homm4.expansion.base",
      "MediaAsset_id": null
    },
    {
      "_key": "homm4.creature.goblin.knight",
      "Game_id": "homm4.game",
      "Code": "GOBLIN_KNIGHT",
      "Name": "Goblin Knight",
      "Description": "Outside the standard town creature lineup; its adventure-map dwelling becomes available with Winds of War.",
      "IntroducedInExpansion_id": "homm4.expansion.tgs",
      "MediaAsset_id": null
    },
    {
      "_key": "homm4.creature.evil.sorceress",
      "Game_id": "homm4.game",
      "Code": "EVIL_SORCERESS",
      "Name": "Evil Sorceress",
      "Description": "Outside the standard town creature lineup; its adventure-map dwelling becomes available with Winds of War.",
      "IntroducedInExpansion_id": "homm4.expansion.tgs",
      "MediaAsset_id": null
    },
    {
      "_key": "homm4.creature.gargantuan",
      "Game_id": "homm4.game",
      "Code": "GARGANTUAN",
      "Name": "Gargantuan",
      "Description": "Outside the standard town creature lineup; its adventure-map dwelling becomes available with Winds of War.",
      "IntroducedInExpansion_id": "homm4.expansion.tgs",
      "MediaAsset_id": null
    },
    {
      "_key": "homm4.creature.dark.champion",
      "Game_id": "homm4.game",
      "Code": "DARK_CHAMPION",
      "Name": "Dark Champion",
      "Description": "Outside the standard town creature lineup; its adventure-map dwelling becomes available with Winds of War.",
      "IntroducedInExpansion_id": "homm4.expansion.tgs",
      "MediaAsset_id": null
    },
    {
      "_key": "homm4.creature.catapult",
      "Game_id": "homm4.game",
      "Code": "CATAPULT",
      "Name": "Catapult",
      "Description": "Outside the standard town creature lineup; recruitable from an adventure-map dwelling.",
      "IntroducedInExpansion_id": "homm4.expansion.wow",
      "MediaAsset_id": null
    },
    {
      "_key": "homm4.creature.frenzied.gnasher",
      "Game_id": "homm4.game",
      "Code": "FRENZIED_GNASHER",
      "Name": "Frenzied Gnasher",
      "Description": "Outside the standard town creature lineup; recruitable from an adventure-map dwelling.",
      "IntroducedInExpansion_id": "homm4.expansion.wow",
      "MediaAsset_id": null
    },
    {
      "_key": "homm4.creature.megadragon",
      "Game_id": "homm4.game",
      "Code": "MEGADRAGON",
      "Name": "Megadragon",
      "Description": "Outside the standard town creature lineup; cannot be purchased from a dwelling in the unmodified game.",
      "IntroducedInExpansion_id": "homm4.expansion.wow",
      "MediaAsset_id": null
    }
  ],
  "CreatureHOMM4": [
    {
      "_key": "homm4.creature.peasant",
      "Faction_id": "homm4.faction.haven",
      "Level": 1,
      "Attack": 6,
      "Defense": 7,
      "DamageMin": 2,
      "DamageMax": 3,
      "Health": 10,
      "Speed": 2,
      "Movement": "Ground",
      "Shots": 0,
      "SpellPoints": 0,
      "SpellPower": null,
      "GrowthAmount": null,
      "GrowthPeriod": null,
      "ExperienceValue": null,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm4.creature.leprechaun",
      "Faction_id": "homm4.faction.preserve",
      "Level": 1,
      "Attack": 10,
      "Defense": 10,
      "DamageMin": 1,
      "DamageMax": 2,
      "Health": 8,
      "Speed": 6,
      "Movement": "Ground",
      "Shots": 0,
      "SpellPoints": 3,
      "SpellPower": null,
      "GrowthAmount": null,
      "GrowthPeriod": null,
      "ExperienceValue": null,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm4.creature.troglodyte",
      "Faction_id": "homm4.faction.asylum",
      "Level": 1,
      "Attack": 11,
      "Defense": 9,
      "DamageMin": 2,
      "DamageMax": 3,
      "Health": 14,
      "Speed": 5,
      "Movement": "Ground",
      "Shots": 0,
      "SpellPoints": 0,
      "SpellPower": null,
      "GrowthAmount": null,
      "GrowthPeriod": null,
      "ExperienceValue": null,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm4.creature.pirate",
      "Faction_id": "homm4.faction.asylum",
      "Level": 1,
      "Attack": 11,
      "Defense": 9,
      "DamageMin": 1,
      "DamageMax": 2,
      "Health": 10,
      "Speed": 5,
      "Movement": "Ground",
      "Shots": 0,
      "SpellPoints": 0,
      "SpellPower": null,
      "GrowthAmount": null,
      "GrowthPeriod": null,
      "ExperienceValue": null,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm4.creature.zombie",
      "Faction_id": "homm4.faction.necropolis",
      "Level": 1,
      "Attack": 8,
      "Defense": 10,
      "DamageMin": 2,
      "DamageMax": 4,
      "Health": 24,
      "Speed": 1,
      "Movement": "Ground",
      "Shots": 0,
      "SpellPoints": 0,
      "SpellPower": null,
      "GrowthAmount": null,
      "GrowthPeriod": null,
      "ExperienceValue": null,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm4.creature.satyr",
      "Faction_id": "homm4.faction.preserve",
      "Level": 2,
      "Attack": 14,
      "Defense": 13,
      "DamageMin": 5,
      "DamageMax": 8,
      "Health": 36,
      "Speed": 6,
      "Movement": "Ground",
      "Shots": 0,
      "SpellPoints": 6,
      "SpellPower": null,
      "GrowthAmount": null,
      "GrowthPeriod": null,
      "ExperienceValue": null,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm4.creature.evil.eye",
      "Faction_id": "homm4.faction.asylum",
      "Level": 2,
      "Attack": 8,
      "Defense": 15,
      "DamageMin": 3,
      "DamageMax": 7,
      "Health": 26,
      "Speed": 6,
      "Movement": "Flying",
      "Shots": 15,
      "SpellPoints": 0,
      "SpellPower": null,
      "GrowthAmount": null,
      "GrowthPeriod": null,
      "ExperienceValue": null,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm4.creature.troll",
      "Faction_id": "homm4.faction.asylum",
      "Level": 2,
      "Attack": 16,
      "Defense": 15,
      "DamageMin": 6,
      "DamageMax": 12,
      "Health": 45,
      "Speed": 3,
      "Movement": "Ground",
      "Shots": 0,
      "SpellPoints": 0,
      "SpellPower": null,
      "GrowthAmount": null,
      "GrowthPeriod": null,
      "ExperienceValue": null,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm4.creature.mummy",
      "Faction_id": "homm4.faction.necropolis",
      "Level": 2,
      "Attack": 15,
      "Defense": 16,
      "DamageMin": 5,
      "DamageMax": 8,
      "Health": 30,
      "Speed": 4,
      "Movement": "Ground",
      "Shots": 0,
      "SpellPoints": 0,
      "SpellPower": null,
      "GrowthAmount": null,
      "GrowthPeriod": null,
      "ExperienceValue": null,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm4.creature.gargoyle",
      "Faction_id": "homm4.faction.necropolis",
      "Level": 2,
      "Attack": 14,
      "Defense": 16,
      "DamageMin": 4,
      "DamageMax": 6,
      "Health": 22,
      "Speed": 7,
      "Movement": "Flying",
      "Shots": 0,
      "SpellPoints": 0,
      "SpellPower": null,
      "GrowthAmount": null,
      "GrowthPeriod": null,
      "ExperienceValue": null,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm4.creature.mermaid",
      "Faction_id": "homm4.faction.stronghold",
      "Level": 2,
      "Attack": 15,
      "Defense": 13,
      "DamageMin": 5,
      "DamageMax": 8,
      "Health": 38,
      "Speed": 5,
      "Movement": "Ground",
      "Shots": 0,
      "SpellPoints": 0,
      "SpellPower": null,
      "GrowthAmount": null,
      "GrowthPeriod": null,
      "ExperienceValue": null,
      "Recruitable": false,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm4.creature.waspwort",
      "Faction_id": "homm4.faction.preserve",
      "Level": 3,
      "Attack": 11,
      "Defense": 22,
      "DamageMin": 10,
      "DamageMax": 14,
      "Health": 60,
      "Speed": 4,
      "Movement": "Ground",
      "Shots": 20,
      "SpellPoints": 0,
      "SpellPower": null,
      "GrowthAmount": null,
      "GrowthPeriod": null,
      "ExperienceValue": null,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm4.creature.fire.elemental",
      "Faction_id": "homm4.faction.preserve",
      "Level": 3,
      "Attack": 10,
      "Defense": 18,
      "DamageMin": 7,
      "DamageMax": 10,
      "Health": 50,
      "Speed": 6,
      "Movement": "Ground",
      "Shots": 20,
      "SpellPoints": 0,
      "SpellPower": null,
      "GrowthAmount": null,
      "GrowthPeriod": null,
      "ExperienceValue": null,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm4.creature.air.elemental",
      "Faction_id": "homm4.faction.preserve",
      "Level": 3,
      "Attack": 16,
      "Defense": 32,
      "DamageMin": 6,
      "DamageMax": 10,
      "Health": 40,
      "Speed": 7,
      "Movement": "Flying",
      "Shots": 0,
      "SpellPoints": 0,
      "SpellPower": null,
      "GrowthAmount": null,
      "GrowthPeriod": null,
      "ExperienceValue": null,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm4.creature.water.elemental",
      "Faction_id": "homm4.faction.preserve",
      "Level": 3,
      "Attack": 17,
      "Defense": 17,
      "DamageMin": 6,
      "DamageMax": 9,
      "Health": 38,
      "Speed": 5,
      "Movement": "Ground",
      "Shots": 0,
      "SpellPoints": 24,
      "SpellPower": null,
      "GrowthAmount": null,
      "GrowthPeriod": null,
      "ExperienceValue": null,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm4.creature.earth.elemental",
      "Faction_id": "homm4.faction.preserve",
      "Level": 3,
      "Attack": 18,
      "Defense": 20,
      "DamageMin": 9,
      "DamageMax": 14,
      "Health": 50,
      "Speed": 1,
      "Movement": "Ground",
      "Shots": 0,
      "SpellPoints": 0,
      "SpellPower": null,
      "GrowthAmount": null,
      "GrowthPeriod": null,
      "ExperienceValue": null,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm4.creature.ice.demon",
      "Faction_id": "homm4.faction.necropolis",
      "Level": 3,
      "Attack": 30,
      "Defense": 30,
      "DamageMin": 12,
      "DamageMax": 16,
      "Health": 70,
      "Speed": 5,
      "Movement": "Ground",
      "Shots": 0,
      "SpellPoints": 0,
      "SpellPower": null,
      "GrowthAmount": null,
      "GrowthPeriod": null,
      "ExperienceValue": null,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm4.creature.mantis",
      "Faction_id": "homm4.faction.preserve",
      "Level": 4,
      "Attack": 34,
      "Defense": 34,
      "DamageMin": 34,
      "DamageMax": 50,
      "Health": 210,
      "Speed": 8,
      "Movement": "Flying",
      "Shots": 0,
      "SpellPoints": 0,
      "SpellPower": null,
      "GrowthAmount": null,
      "GrowthPeriod": null,
      "ExperienceValue": null,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm4.creature.sea.monster",
      "Faction_id": "homm4.faction.stronghold",
      "Level": 4,
      "Attack": 35,
      "Defense": 34,
      "DamageMin": 45,
      "DamageMax": 65,
      "Health": 275,
      "Speed": 5,
      "Movement": "Ground",
      "Shots": 0,
      "SpellPoints": 0,
      "SpellPower": null,
      "GrowthAmount": null,
      "GrowthPeriod": null,
      "ExperienceValue": null,
      "Recruitable": false,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm4.creature.goblin.knight",
      "Faction_id": "homm4.faction.asylum",
      "Level": 3,
      "Attack": 20,
      "Defense": 26,
      "DamageMin": 16,
      "DamageMax": 30,
      "Health": 120,
      "Speed": 7,
      "Movement": "Ground",
      "Shots": 0,
      "SpellPoints": 0,
      "SpellPower": null,
      "GrowthAmount": null,
      "GrowthPeriod": null,
      "ExperienceValue": null,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm4.creature.evil.sorceress",
      "Faction_id": "homm4.faction.academy",
      "Level": 4,
      "Attack": 28,
      "Defense": 28,
      "DamageMin": 20,
      "DamageMax": 34,
      "Health": 100,
      "Speed": 7,
      "Movement": "Teleporting",
      "Shots": 0,
      "SpellPoints": 50,
      "SpellPower": null,
      "GrowthAmount": null,
      "GrowthPeriod": null,
      "ExperienceValue": null,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm4.creature.gargantuan",
      "Faction_id": "homm4.faction.preserve",
      "Level": 4,
      "Attack": 32,
      "Defense": 32,
      "DamageMin": 28,
      "DamageMax": 40,
      "Health": 300,
      "Speed": 4,
      "Movement": "Ground",
      "Shots": 16,
      "SpellPoints": 0,
      "SpellPower": null,
      "GrowthAmount": null,
      "GrowthPeriod": null,
      "ExperienceValue": null,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm4.creature.dark.champion",
      "Faction_id": "homm4.faction.necropolis",
      "Level": 4,
      "Attack": 40,
      "Defense": 40,
      "DamageMin": 30,
      "DamageMax": 42,
      "Health": 200,
      "Speed": 6,
      "Movement": "Ground",
      "Shots": 0,
      "SpellPoints": 18,
      "SpellPower": null,
      "GrowthAmount": null,
      "GrowthPeriod": null,
      "ExperienceValue": null,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm4.creature.catapult",
      "Faction_id": "homm4.faction.haven",
      "Level": 4,
      "Attack": 14,
      "Defense": 28,
      "DamageMin": 20,
      "DamageMax": 34,
      "Health": 200,
      "Speed": 0,
      "Movement": "Ground",
      "Shots": 12,
      "SpellPoints": 0,
      "SpellPower": null,
      "GrowthAmount": null,
      "GrowthPeriod": null,
      "ExperienceValue": null,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm4.creature.frenzied.gnasher",
      "Faction_id": "homm4.faction.stronghold",
      "Level": 4,
      "Attack": 40,
      "Defense": 40,
      "DamageMin": 40,
      "DamageMax": 55,
      "Health": 300,
      "Speed": 4,
      "Movement": "Ground",
      "Shots": 0,
      "SpellPoints": 0,
      "SpellPower": null,
      "GrowthAmount": null,
      "GrowthPeriod": null,
      "ExperienceValue": null,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm4.creature.megadragon",
      "Faction_id": "homm4.faction.asylum",
      "Level": 4,
      "Attack": 50,
      "Defense": 50,
      "DamageMin": 50,
      "DamageMax": 100,
      "Health": 1000,
      "Speed": 7,
      "Movement": "Ground",
      "Shots": 0,
      "SpellPoints": 0,
      "SpellPower": null,
      "GrowthAmount": null,
      "GrowthPeriod": null,
      "ExperienceValue": null,
      "Recruitable": false,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    }
  ]
}
$homm4_data$::JSONB;
    entry JSONB;
    resolved JSONB := '{}'::JSONB;
    current_id BIGINT;
BEGIN
    -- Game: 1 rows.
    FOR entry IN SELECT value FROM jsonb_array_elements(batch -> 'Game') LOOP
        INSERT INTO heroes_watch."Game" AS existing
            ("SeriesCode", "DisplayOrder", "Name", "ReleaseDate", "Description")
        VALUES (
            (entry ->> 'SeriesCode'),
            (entry ->> 'DisplayOrder')::SMALLINT,
            (entry ->> 'Name'),
            (entry ->> 'ReleaseDate')::DATE,
            (entry ->> 'Description')
        )
        ON CONFLICT ("SeriesCode") DO UPDATE SET
            "ReleaseDate" = COALESCE(existing."ReleaseDate", EXCLUDED."ReleaseDate"),
            "Description" = COALESCE(existing."Description", EXCLUDED."Description");
        SELECT "Game_id" INTO STRICT current_id
        FROM heroes_watch."Game"
        WHERE "SeriesCode" = (entry ->> 'SeriesCode')
        FOR UPDATE;
        resolved := resolved || jsonb_build_object(entry ->> '_key', current_id);
        IF NOT EXISTS (
            SELECT 1 FROM heroes_watch."Game"
            WHERE "Game_id" = current_id
              AND "SeriesCode" IS NOT DISTINCT FROM (entry ->> 'SeriesCode')
              AND "DisplayOrder" IS NOT DISTINCT FROM (entry ->> 'DisplayOrder')::SMALLINT
              AND "Name" IS NOT DISTINCT FROM (entry ->> 'Name')
              AND (entry -> 'ReleaseDate' = 'null'::JSONB OR "ReleaseDate" IS NOT DISTINCT FROM (entry ->> 'ReleaseDate')::DATE)
              AND (entry -> 'Description' = 'null'::JSONB OR "Description" IS NOT DISTINCT FROM (entry ->> 'Description'))
        ) THEN
            RAISE EXCEPTION 'Existing Game conflicts with %; transaction aborted.', entry ->> '_key';
        END IF;
    END LOOP;

    -- Expansion: 3 rows.
    FOR entry IN SELECT value FROM jsonb_array_elements(batch -> 'Expansion') LOOP
        INSERT INTO heroes_watch."Expansion" AS existing
            ("Game_id", "Code", "Name", "Kind", "ReleaseDate", "Description")
        VALUES (
            (resolved ->> (entry ->> 'Game_id'))::BIGINT,
            (entry ->> 'Code'),
            (entry ->> 'Name'),
            (entry ->> 'Kind')::heroes_watch."Enum__Expansion__Kind",
            (entry ->> 'ReleaseDate')::DATE,
            (entry ->> 'Description')
        )
        ON CONFLICT ("Game_id", "Code") DO UPDATE SET
            "ReleaseDate" = COALESCE(existing."ReleaseDate", EXCLUDED."ReleaseDate"),
            "Description" = COALESCE(existing."Description", EXCLUDED."Description");
        SELECT "Expansion_id" INTO STRICT current_id
        FROM heroes_watch."Expansion"
        WHERE "Game_id" = (resolved ->> (entry ->> 'Game_id'))::BIGINT AND "Code" = (entry ->> 'Code')
        FOR UPDATE;
        resolved := resolved || jsonb_build_object(entry ->> '_key', current_id);
        IF NOT EXISTS (
            SELECT 1 FROM heroes_watch."Expansion"
            WHERE "Expansion_id" = current_id
              AND "Game_id" IS NOT DISTINCT FROM (resolved ->> (entry ->> 'Game_id'))::BIGINT
              AND "Code" IS NOT DISTINCT FROM (entry ->> 'Code')
              AND "Name" IS NOT DISTINCT FROM (entry ->> 'Name')
              AND "Kind" IS NOT DISTINCT FROM (entry ->> 'Kind')::heroes_watch."Enum__Expansion__Kind"
              AND (entry -> 'ReleaseDate' = 'null'::JSONB OR "ReleaseDate" IS NOT DISTINCT FROM (entry ->> 'ReleaseDate')::DATE)
              AND (entry -> 'Description' = 'null'::JSONB OR "Description" IS NOT DISTINCT FROM (entry ->> 'Description'))
        ) THEN
            RAISE EXCEPTION 'Existing Expansion conflicts with %; transaction aborted.', entry ->> '_key';
        END IF;
    END LOOP;

    -- MagicSchool: 5 rows.
    FOR entry IN SELECT value FROM jsonb_array_elements(batch -> 'MagicSchool') LOOP
        INSERT INTO heroes_watch."MagicSchool" AS existing
            ("Game_id", "Code", "Name", "Description", "MediaAsset_id")
        VALUES (
            (resolved ->> (entry ->> 'Game_id'))::BIGINT,
            (entry ->> 'Code'),
            (entry ->> 'Name'),
            (entry ->> 'Description'),
            (resolved ->> (entry ->> 'MediaAsset_id'))::BIGINT
        )
        ON CONFLICT ("Game_id", "Code") DO UPDATE SET
            "Description" = COALESCE(existing."Description", EXCLUDED."Description"),
            "MediaAsset_id" = COALESCE(existing."MediaAsset_id", EXCLUDED."MediaAsset_id");
        SELECT "MagicSchool_id" INTO STRICT current_id
        FROM heroes_watch."MagicSchool"
        WHERE "Game_id" = (resolved ->> (entry ->> 'Game_id'))::BIGINT AND "Code" = (entry ->> 'Code')
        FOR UPDATE;
        resolved := resolved || jsonb_build_object(entry ->> '_key', current_id);
        IF NOT EXISTS (
            SELECT 1 FROM heroes_watch."MagicSchool"
            WHERE "MagicSchool_id" = current_id
              AND "Game_id" IS NOT DISTINCT FROM (resolved ->> (entry ->> 'Game_id'))::BIGINT
              AND "Code" IS NOT DISTINCT FROM (entry ->> 'Code')
              AND "Name" IS NOT DISTINCT FROM (entry ->> 'Name')
              AND (entry -> 'Description' = 'null'::JSONB OR "Description" IS NOT DISTINCT FROM (entry ->> 'Description'))
              AND (entry -> 'MediaAsset_id' = 'null'::JSONB OR "MediaAsset_id" IS NOT DISTINCT FROM (resolved ->> (entry ->> 'MediaAsset_id'))::BIGINT)
        ) THEN
            RAISE EXCEPTION 'Existing MagicSchool conflicts with %; transaction aborted.', entry ->> '_key';
        END IF;
    END LOOP;

    -- Terrain: 5 rows.
    FOR entry IN SELECT value FROM jsonb_array_elements(batch -> 'Terrain') LOOP
        INSERT INTO heroes_watch."Terrain" AS existing
            ("Game_id", "Code", "Name", "Kind", "Description", "IntroducedInExpansion_id", "MediaAsset_id")
        VALUES (
            (resolved ->> (entry ->> 'Game_id'))::BIGINT,
            (entry ->> 'Code'),
            (entry ->> 'Name'),
            (entry ->> 'Kind')::heroes_watch."Enum__Terrain__Kind",
            (entry ->> 'Description'),
            (resolved ->> (entry ->> 'IntroducedInExpansion_id'))::BIGINT,
            (resolved ->> (entry ->> 'MediaAsset_id'))::BIGINT
        )
        ON CONFLICT ("Game_id", "Code") DO UPDATE SET
            "Description" = COALESCE(existing."Description", EXCLUDED."Description"),
            "IntroducedInExpansion_id" = COALESCE(existing."IntroducedInExpansion_id", EXCLUDED."IntroducedInExpansion_id"),
            "MediaAsset_id" = COALESCE(existing."MediaAsset_id", EXCLUDED."MediaAsset_id");
        SELECT "Terrain_id" INTO STRICT current_id
        FROM heroes_watch."Terrain"
        WHERE "Game_id" = (resolved ->> (entry ->> 'Game_id'))::BIGINT AND "Code" = (entry ->> 'Code')
        FOR UPDATE;
        resolved := resolved || jsonb_build_object(entry ->> '_key', current_id);
        IF NOT EXISTS (
            SELECT 1 FROM heroes_watch."Terrain"
            WHERE "Terrain_id" = current_id
              AND "Game_id" IS NOT DISTINCT FROM (resolved ->> (entry ->> 'Game_id'))::BIGINT
              AND "Code" IS NOT DISTINCT FROM (entry ->> 'Code')
              AND "Name" IS NOT DISTINCT FROM (entry ->> 'Name')
              AND "Kind" IS NOT DISTINCT FROM (entry ->> 'Kind')::heroes_watch."Enum__Terrain__Kind"
              AND (entry -> 'Description' = 'null'::JSONB OR "Description" IS NOT DISTINCT FROM (entry ->> 'Description'))
              AND (entry -> 'IntroducedInExpansion_id' = 'null'::JSONB OR "IntroducedInExpansion_id" IS NOT DISTINCT FROM (resolved ->> (entry ->> 'IntroducedInExpansion_id'))::BIGINT)
              AND (entry -> 'MediaAsset_id' = 'null'::JSONB OR "MediaAsset_id" IS NOT DISTINCT FROM (resolved ->> (entry ->> 'MediaAsset_id'))::BIGINT)
        ) THEN
            RAISE EXCEPTION 'Existing Terrain conflicts with %; transaction aborted.', entry ->> '_key';
        END IF;
    END LOOP;

    -- Faction: 6 rows.
    FOR entry IN SELECT value FROM jsonb_array_elements(batch -> 'Faction') LOOP
        INSERT INTO heroes_watch."Faction" AS existing
            ("Game_id", "Code", "Name", "Description", "IntroducedInExpansion_id", "MediaAsset_id")
        VALUES (
            (resolved ->> (entry ->> 'Game_id'))::BIGINT,
            (entry ->> 'Code'),
            (entry ->> 'Name'),
            (entry ->> 'Description'),
            (resolved ->> (entry ->> 'IntroducedInExpansion_id'))::BIGINT,
            (resolved ->> (entry ->> 'MediaAsset_id'))::BIGINT
        )
        ON CONFLICT ("Game_id", "Code") DO UPDATE SET
            "Description" = COALESCE(existing."Description", EXCLUDED."Description"),
            "IntroducedInExpansion_id" = COALESCE(existing."IntroducedInExpansion_id", EXCLUDED."IntroducedInExpansion_id"),
            "MediaAsset_id" = COALESCE(existing."MediaAsset_id", EXCLUDED."MediaAsset_id");
        SELECT "Faction_id" INTO STRICT current_id
        FROM heroes_watch."Faction"
        WHERE "Game_id" = (resolved ->> (entry ->> 'Game_id'))::BIGINT AND "Code" = (entry ->> 'Code')
        FOR UPDATE;
        resolved := resolved || jsonb_build_object(entry ->> '_key', current_id);
        IF NOT EXISTS (
            SELECT 1 FROM heroes_watch."Faction"
            WHERE "Faction_id" = current_id
              AND "Game_id" IS NOT DISTINCT FROM (resolved ->> (entry ->> 'Game_id'))::BIGINT
              AND "Code" IS NOT DISTINCT FROM (entry ->> 'Code')
              AND "Name" IS NOT DISTINCT FROM (entry ->> 'Name')
              AND (entry -> 'Description' = 'null'::JSONB OR "Description" IS NOT DISTINCT FROM (entry ->> 'Description'))
              AND (entry -> 'IntroducedInExpansion_id' = 'null'::JSONB OR "IntroducedInExpansion_id" IS NOT DISTINCT FROM (resolved ->> (entry ->> 'IntroducedInExpansion_id'))::BIGINT)
              AND (entry -> 'MediaAsset_id' = 'null'::JSONB OR "MediaAsset_id" IS NOT DISTINCT FROM (resolved ->> (entry ->> 'MediaAsset_id'))::BIGINT)
        ) THEN
            RAISE EXCEPTION 'Existing Faction conflicts with %; transaction aborted.', entry ->> '_key';
        END IF;
    END LOOP;

    -- Creature: 26 rows.
    FOR entry IN SELECT value FROM jsonb_array_elements(batch -> 'Creature') LOOP
        INSERT INTO heroes_watch."Creature" AS existing
            ("Game_id", "Code", "Name", "Description", "IntroducedInExpansion_id", "MediaAsset_id")
        VALUES (
            (resolved ->> (entry ->> 'Game_id'))::BIGINT,
            (entry ->> 'Code'),
            (entry ->> 'Name'),
            (entry ->> 'Description'),
            (resolved ->> (entry ->> 'IntroducedInExpansion_id'))::BIGINT,
            (resolved ->> (entry ->> 'MediaAsset_id'))::BIGINT
        )
        ON CONFLICT ("Game_id", "Code") DO UPDATE SET
            "Description" = COALESCE(existing."Description", EXCLUDED."Description"),
            "IntroducedInExpansion_id" = COALESCE(existing."IntroducedInExpansion_id", EXCLUDED."IntroducedInExpansion_id"),
            "MediaAsset_id" = COALESCE(existing."MediaAsset_id", EXCLUDED."MediaAsset_id");
        SELECT "Creature_id" INTO STRICT current_id
        FROM heroes_watch."Creature"
        WHERE "Game_id" = (resolved ->> (entry ->> 'Game_id'))::BIGINT AND "Code" = (entry ->> 'Code')
        FOR UPDATE;
        resolved := resolved || jsonb_build_object(entry ->> '_key', current_id);
        IF NOT EXISTS (
            SELECT 1 FROM heroes_watch."Creature"
            WHERE "Creature_id" = current_id
              AND "Game_id" IS NOT DISTINCT FROM (resolved ->> (entry ->> 'Game_id'))::BIGINT
              AND "Code" IS NOT DISTINCT FROM (entry ->> 'Code')
              AND "Name" IS NOT DISTINCT FROM (entry ->> 'Name')
              AND (entry -> 'Description' = 'null'::JSONB OR "Description" IS NOT DISTINCT FROM (entry ->> 'Description'))
              AND (entry -> 'IntroducedInExpansion_id' = 'null'::JSONB OR "IntroducedInExpansion_id" IS NOT DISTINCT FROM (resolved ->> (entry ->> 'IntroducedInExpansion_id'))::BIGINT)
              AND (entry -> 'MediaAsset_id' = 'null'::JSONB OR "MediaAsset_id" IS NOT DISTINCT FROM (resolved ->> (entry ->> 'MediaAsset_id'))::BIGINT)
        ) THEN
            RAISE EXCEPTION 'Existing Creature conflicts with %; transaction aborted.', entry ->> '_key';
        END IF;
    END LOOP;

    -- FactionHOMM4: 6 rows.
    FOR entry IN SELECT value FROM jsonb_array_elements(batch -> 'FactionHOMM4') LOOP
        INSERT INTO heroes_watch."FactionHOMM4" AS existing
            ("Faction_id", "Alignment", "NativeMagicSchool_id", "NativeTerrain_id", "AlliedFactionA_id", "AlliedFactionB_id", "HasMagicGuild")
        VALUES (
            (resolved ->> (entry ->> '_key'))::BIGINT,
            (entry ->> 'Alignment')::heroes_watch."Enum__FactionHOMM4__Alignment",
            (resolved ->> (entry ->> 'NativeMagicSchool_id'))::BIGINT,
            (resolved ->> (entry ->> 'NativeTerrain_id'))::BIGINT,
            (resolved ->> (entry ->> 'AlliedFactionA_id'))::BIGINT,
            (resolved ->> (entry ->> 'AlliedFactionB_id'))::BIGINT,
            (entry ->> 'HasMagicGuild')::BOOLEAN
        )
        ON CONFLICT ("Faction_id") DO UPDATE SET
            "NativeMagicSchool_id" = COALESCE(existing."NativeMagicSchool_id", EXCLUDED."NativeMagicSchool_id"),
            "NativeTerrain_id" = COALESCE(existing."NativeTerrain_id", EXCLUDED."NativeTerrain_id"),
            "AlliedFactionA_id" = COALESCE(existing."AlliedFactionA_id", EXCLUDED."AlliedFactionA_id"),
            "AlliedFactionB_id" = COALESCE(existing."AlliedFactionB_id", EXCLUDED."AlliedFactionB_id");
        current_id := (resolved ->> (entry ->> '_key'))::BIGINT;
        IF NOT EXISTS (
            SELECT 1 FROM heroes_watch."FactionHOMM4"
            WHERE "Faction_id" = current_id
              AND "Alignment" IS NOT DISTINCT FROM (entry ->> 'Alignment')::heroes_watch."Enum__FactionHOMM4__Alignment"
              AND "NativeMagicSchool_id" IS NOT DISTINCT FROM (resolved ->> (entry ->> 'NativeMagicSchool_id'))::BIGINT
              AND "NativeTerrain_id" IS NOT DISTINCT FROM (resolved ->> (entry ->> 'NativeTerrain_id'))::BIGINT
              AND "AlliedFactionA_id" IS NOT DISTINCT FROM (resolved ->> (entry ->> 'AlliedFactionA_id'))::BIGINT
              AND "AlliedFactionB_id" IS NOT DISTINCT FROM (resolved ->> (entry ->> 'AlliedFactionB_id'))::BIGINT
              AND "HasMagicGuild" IS NOT DISTINCT FROM (entry ->> 'HasMagicGuild')::BOOLEAN
        ) THEN
            RAISE EXCEPTION 'Existing FactionHOMM4 conflicts with %; transaction aborted.', entry ->> '_key';
        END IF;
    END LOOP;

    -- CreatureHOMM4: 26 rows.
    FOR entry IN SELECT value FROM jsonb_array_elements(batch -> 'CreatureHOMM4') LOOP
        INSERT INTO heroes_watch."CreatureHOMM4" AS existing
            ("Creature_id", "Faction_id", "Level", "Attack", "Defense", "DamageMin", "DamageMax", "Health", "Speed", "Movement", "Shots", "SpellPoints", "SpellPower", "GrowthAmount", "GrowthPeriod", "ExperienceValue", "Recruitable", "DoubleUpgrade", "AlternativeUpgrade")
        VALUES (
            (resolved ->> (entry ->> '_key'))::BIGINT,
            (resolved ->> (entry ->> 'Faction_id'))::BIGINT,
            (entry ->> 'Level')::SMALLINT,
            (entry ->> 'Attack')::SMALLINT,
            (entry ->> 'Defense')::SMALLINT,
            (entry ->> 'DamageMin')::SMALLINT,
            (entry ->> 'DamageMax')::SMALLINT,
            (entry ->> 'Health')::INTEGER,
            (entry ->> 'Speed')::SMALLINT,
            (entry ->> 'Movement')::heroes_watch."Enum__CreatureHOMM4__Movement",
            (entry ->> 'Shots')::SMALLINT,
            (entry ->> 'SpellPoints')::SMALLINT,
            (entry ->> 'SpellPower')::SMALLINT,
            (entry ->> 'GrowthAmount')::SMALLINT,
            (entry ->> 'GrowthPeriod')::heroes_watch."Enum__CreatureHOMM4__GrowthPeriod",
            (entry ->> 'ExperienceValue')::INTEGER,
            (entry ->> 'Recruitable')::BOOLEAN,
            (entry ->> 'DoubleUpgrade')::BOOLEAN,
            (entry ->> 'AlternativeUpgrade')::BOOLEAN
        )
        ON CONFLICT ("Creature_id") DO UPDATE SET
            "Faction_id" = COALESCE(existing."Faction_id", EXCLUDED."Faction_id"),
            "Shots" = COALESCE(existing."Shots", EXCLUDED."Shots"),
            "SpellPoints" = COALESCE(existing."SpellPoints", EXCLUDED."SpellPoints"),
            "SpellPower" = COALESCE(existing."SpellPower", EXCLUDED."SpellPower"),
            "GrowthAmount" = COALESCE(existing."GrowthAmount", EXCLUDED."GrowthAmount"),
            "GrowthPeriod" = COALESCE(existing."GrowthPeriod", EXCLUDED."GrowthPeriod"),
            "ExperienceValue" = COALESCE(existing."ExperienceValue", EXCLUDED."ExperienceValue");
        current_id := (resolved ->> (entry ->> '_key'))::BIGINT;
        IF NOT EXISTS (
            SELECT 1 FROM heroes_watch."CreatureHOMM4"
            WHERE "Creature_id" = current_id
              AND "Faction_id" IS NOT DISTINCT FROM (resolved ->> (entry ->> 'Faction_id'))::BIGINT
              AND "Level" IS NOT DISTINCT FROM (entry ->> 'Level')::SMALLINT
              AND "Attack" IS NOT DISTINCT FROM (entry ->> 'Attack')::SMALLINT
              AND "Defense" IS NOT DISTINCT FROM (entry ->> 'Defense')::SMALLINT
              AND "DamageMin" IS NOT DISTINCT FROM (entry ->> 'DamageMin')::SMALLINT
              AND "DamageMax" IS NOT DISTINCT FROM (entry ->> 'DamageMax')::SMALLINT
              AND "Health" IS NOT DISTINCT FROM (entry ->> 'Health')::INTEGER
              AND "Speed" IS NOT DISTINCT FROM (entry ->> 'Speed')::SMALLINT
              AND "Movement" IS NOT DISTINCT FROM (entry ->> 'Movement')::heroes_watch."Enum__CreatureHOMM4__Movement"
              AND (entry -> 'Shots' = 'null'::JSONB OR "Shots" IS NOT DISTINCT FROM (entry ->> 'Shots')::SMALLINT)
              AND (entry -> 'SpellPoints' = 'null'::JSONB OR "SpellPoints" IS NOT DISTINCT FROM (entry ->> 'SpellPoints')::SMALLINT)
              AND (entry -> 'SpellPower' = 'null'::JSONB OR "SpellPower" IS NOT DISTINCT FROM (entry ->> 'SpellPower')::SMALLINT)
              AND (entry -> 'GrowthAmount' = 'null'::JSONB OR "GrowthAmount" IS NOT DISTINCT FROM (entry ->> 'GrowthAmount')::SMALLINT)
              AND (entry -> 'GrowthPeriod' = 'null'::JSONB OR "GrowthPeriod" IS NOT DISTINCT FROM (entry ->> 'GrowthPeriod')::heroes_watch."Enum__CreatureHOMM4__GrowthPeriod")
              AND (entry -> 'ExperienceValue' = 'null'::JSONB OR "ExperienceValue" IS NOT DISTINCT FROM (entry ->> 'ExperienceValue')::INTEGER)
              AND "Recruitable" IS NOT DISTINCT FROM (entry ->> 'Recruitable')::BOOLEAN
              AND "DoubleUpgrade" IS NOT DISTINCT FROM (entry ->> 'DoubleUpgrade')::BOOLEAN
              AND "AlternativeUpgrade" IS NOT DISTINCT FROM (entry ->> 'AlternativeUpgrade')::BOOLEAN
        ) THEN
            RAISE EXCEPTION 'Existing CreatureHOMM4 conflicts with %; transaction aborted.', entry ->> '_key';
        END IF;
    END LOOP;
END
$homm4_import$;

SET CONSTRAINTS ALL IMMEDIATE;
COMMIT;

-- Read-only: the six Heroes IV towns, shared across the base game and expansions.
SELECT f."Name" AS "Faction", d."Alignment"::TEXT AS "Alignment",
       t."Name" AS "Native terrain", m."Name" AS "Magic school",
       d."HasMagicGuild" AS "Magic guild",
       concat_ws(', ', a."Name", b."Name") AS "Allied factions"
FROM heroes_watch."Faction" f
JOIN heroes_watch."Game" g ON g."Game_id" = f."Game_id"
JOIN heroes_watch."FactionHOMM4" d ON d."Faction_id" = f."Faction_id"
JOIN heroes_watch."Terrain" t ON t."Terrain_id" = d."NativeTerrain_id" AND t."Game_id" = g."Game_id"
LEFT JOIN heroes_watch."MagicSchool" m ON m."MagicSchool_id" = d."NativeMagicSchool_id" AND m."Game_id" = g."Game_id"
LEFT JOIN heroes_watch."Faction" a ON a."Faction_id" = d."AlliedFactionA_id" AND a."Game_id" = g."Game_id"
LEFT JOIN heroes_watch."Faction" b ON b."Faction_id" = d."AlliedFactionB_id" AND b."Game_id" = g."Game_id"
WHERE g."SeriesCode" = 'HOMM4'
  AND f."Code" IN ('HAVEN', 'ACADEMY', 'NECROPOLIS', 'ASYLUM', 'PRESERVE', 'STRONGHOLD')
ORDER BY array_position(ARRAY['HAVEN','ACADEMY','NECROPOLIS','ASYLUM','PRESERVE','STRONGHOLD'], f."Code");
