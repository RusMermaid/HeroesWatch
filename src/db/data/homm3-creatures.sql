-- Heroes III: all 126 creatures from the nine original towns, including upgrades.
-- Classic Shadow of Death mechanics with Armageddon's Blade content enabled.
-- Source snapshot: heroeswatch.json; research: homm3-creatures.sources.md.
-- Prerequisite: apply homm3-factions.sql first to the existing heroes_watch schema.
-- Execute this entire script in a fresh query session. No schema changes.
-- Resolves 13 existing game/release/faction rows and imports 465 new content rows.

BEGIN;
SET LOCAL lock_timeout = '5s';
SET LOCAL statement_timeout = '60s';

DO $homm3_creatures_import$
DECLARE
    batch CONSTANT JSONB := $homm3_creatures_data$
{
  "Game": [
    {
      "_key": "homm3.game",
      "SeriesCode": "HOMM3",
      "DisplayOrder": 3,
      "Name": "Heroes of Might and Magic III",
      "ReleaseDate": null,
      "Description": null
    }
  ],
  "Expansion": [
    {
      "_key": "homm3.expansion.roe",
      "Game_id": "homm3.game",
      "Code": "ROE",
      "Name": "The Restoration of Erathia",
      "Kind": "BaseGame",
      "ReleaseDate": null,
      "Description": null
    },
    {
      "_key": "homm3.expansion.ab",
      "Game_id": "homm3.game",
      "Code": "AB",
      "Name": "Armageddon's Blade",
      "Kind": "Expansion",
      "ReleaseDate": null,
      "Description": null
    },
    {
      "_key": "homm3.expansion.sod",
      "Game_id": "homm3.game",
      "Code": "SOD",
      "Name": "The Shadow of Death",
      "Kind": "Expansion",
      "ReleaseDate": null,
      "Description": null
    }
  ],
  "Faction": [
    {
      "_key": "homm3.faction.castle",
      "Game_id": "homm3.game",
      "Code": "CASTLE",
      "Name": "Castle",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.faction.rampart",
      "Game_id": "homm3.game",
      "Code": "RAMPART",
      "Name": "Rampart",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.faction.tower",
      "Game_id": "homm3.game",
      "Code": "TOWER",
      "Name": "Tower",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.faction.inferno",
      "Game_id": "homm3.game",
      "Code": "INFERNO",
      "Name": "Inferno",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.faction.necropolis",
      "Game_id": "homm3.game",
      "Code": "NECROPOLIS",
      "Name": "Necropolis",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.faction.dungeon",
      "Game_id": "homm3.game",
      "Code": "DUNGEON",
      "Name": "Dungeon",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.faction.stronghold",
      "Game_id": "homm3.game",
      "Code": "STRONGHOLD",
      "Name": "Stronghold",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.faction.fortress",
      "Game_id": "homm3.game",
      "Code": "FORTRESS",
      "Name": "Fortress",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.faction.conflux",
      "Game_id": "homm3.game",
      "Code": "CONFLUX",
      "Name": "Conflux",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.ab",
      "MediaAsset_id": null
    }
  ],
  "Resource": [
    {
      "_key": "resource.gold",
      "Code": "GOLD",
      "Name": "Gold",
      "Description": null
    },
    {
      "_key": "resource.mercury",
      "Code": "MERCURY",
      "Name": "Mercury",
      "Description": null
    },
    {
      "_key": "resource.sulfur",
      "Code": "SULFUR",
      "Name": "Sulfur",
      "Description": null
    },
    {
      "_key": "resource.crystal",
      "Code": "CRYSTAL",
      "Name": "Crystal",
      "Description": null
    },
    {
      "_key": "resource.gems",
      "Code": "GEMS",
      "Name": "Gems",
      "Description": null
    }
  ],
  "GameResource": [
    {
      "_key": "homm3.game-resource.gold",
      "Game_id": "homm3.game",
      "Resource_id": "resource.gold",
      "DisplayName": "Gold",
      "ResourceClass": "Currency",
      "DisplayOrder": null,
      "MediaAsset_id": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe"
    },
    {
      "_key": "homm3.game-resource.mercury",
      "Game_id": "homm3.game",
      "Resource_id": "resource.mercury",
      "DisplayName": "Mercury",
      "ResourceClass": "Rare",
      "DisplayOrder": null,
      "MediaAsset_id": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe"
    },
    {
      "_key": "homm3.game-resource.sulfur",
      "Game_id": "homm3.game",
      "Resource_id": "resource.sulfur",
      "DisplayName": "Sulfur",
      "ResourceClass": "Rare",
      "DisplayOrder": null,
      "MediaAsset_id": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe"
    },
    {
      "_key": "homm3.game-resource.crystal",
      "Game_id": "homm3.game",
      "Resource_id": "resource.crystal",
      "DisplayName": "Crystal",
      "ResourceClass": "Rare",
      "DisplayOrder": null,
      "MediaAsset_id": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe"
    },
    {
      "_key": "homm3.game-resource.gems",
      "Game_id": "homm3.game",
      "Resource_id": "resource.gems",
      "DisplayName": "Gems",
      "ResourceClass": "Rare",
      "DisplayOrder": null,
      "MediaAsset_id": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe"
    }
  ],
  "Creature": [
    {
      "_key": "homm3.creature.pikeman",
      "Game_id": "homm3.game",
      "Code": "PIKEMAN",
      "Name": "Pikeman",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.halberdier",
      "Game_id": "homm3.game",
      "Code": "HALBERDIER",
      "Name": "Halberdier",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.archer",
      "Game_id": "homm3.game",
      "Code": "ARCHER",
      "Name": "Archer",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.marksman",
      "Game_id": "homm3.game",
      "Code": "MARKSMAN",
      "Name": "Marksman",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.griffin",
      "Game_id": "homm3.game",
      "Code": "GRIFFIN",
      "Name": "Griffin",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.royal.griffin",
      "Game_id": "homm3.game",
      "Code": "ROYAL_GRIFFIN",
      "Name": "Royal Griffin",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.swordsman",
      "Game_id": "homm3.game",
      "Code": "SWORDSMAN",
      "Name": "Swordsman",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.crusader",
      "Game_id": "homm3.game",
      "Code": "CRUSADER",
      "Name": "Crusader",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.monk",
      "Game_id": "homm3.game",
      "Code": "MONK",
      "Name": "Monk",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.zealot",
      "Game_id": "homm3.game",
      "Code": "ZEALOT",
      "Name": "Zealot",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.cavalier",
      "Game_id": "homm3.game",
      "Code": "CAVALIER",
      "Name": "Cavalier",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.champion",
      "Game_id": "homm3.game",
      "Code": "CHAMPION",
      "Name": "Champion",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.angel",
      "Game_id": "homm3.game",
      "Code": "ANGEL",
      "Name": "Angel",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.archangel",
      "Game_id": "homm3.game",
      "Code": "ARCHANGEL",
      "Name": "Archangel",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.gremlin",
      "Game_id": "homm3.game",
      "Code": "GREMLIN",
      "Name": "Gremlin",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.master.gremlin",
      "Game_id": "homm3.game",
      "Code": "MASTER_GREMLIN",
      "Name": "Master Gremlin",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.stone.gargoyle",
      "Game_id": "homm3.game",
      "Code": "STONE_GARGOYLE",
      "Name": "Stone Gargoyle",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.obsidian.gargoyle",
      "Game_id": "homm3.game",
      "Code": "OBSIDIAN_GARGOYLE",
      "Name": "Obsidian Gargoyle",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.stone.golem",
      "Game_id": "homm3.game",
      "Code": "STONE_GOLEM",
      "Name": "Stone Golem",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.iron.golem",
      "Game_id": "homm3.game",
      "Code": "IRON_GOLEM",
      "Name": "Iron Golem",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.mage",
      "Game_id": "homm3.game",
      "Code": "MAGE",
      "Name": "Mage",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.arch.mage",
      "Game_id": "homm3.game",
      "Code": "ARCH_MAGE",
      "Name": "Arch Mage",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.genie",
      "Game_id": "homm3.game",
      "Code": "GENIE",
      "Name": "Genie",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.master.genie",
      "Game_id": "homm3.game",
      "Code": "MASTER_GENIE",
      "Name": "Master Genie",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.naga",
      "Game_id": "homm3.game",
      "Code": "NAGA",
      "Name": "Naga",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.naga.queen",
      "Game_id": "homm3.game",
      "Code": "NAGA_QUEEN",
      "Name": "Naga Queen",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.giant",
      "Game_id": "homm3.game",
      "Code": "GIANT",
      "Name": "Giant",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.titan",
      "Game_id": "homm3.game",
      "Code": "TITAN",
      "Name": "Titan",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.centaur",
      "Game_id": "homm3.game",
      "Code": "CENTAUR",
      "Name": "Centaur",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.centaur.captain",
      "Game_id": "homm3.game",
      "Code": "CENTAUR_CAPTAIN",
      "Name": "Centaur Captain",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.dwarf",
      "Game_id": "homm3.game",
      "Code": "DWARF",
      "Name": "Dwarf",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.battle.dwarf",
      "Game_id": "homm3.game",
      "Code": "BATTLE_DWARF",
      "Name": "Battle Dwarf",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.wood.elf",
      "Game_id": "homm3.game",
      "Code": "WOOD_ELF",
      "Name": "Wood Elf",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.grand.elf",
      "Game_id": "homm3.game",
      "Code": "GRAND_ELF",
      "Name": "Grand Elf",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.pegasus",
      "Game_id": "homm3.game",
      "Code": "PEGASUS",
      "Name": "Pegasus",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.silver.pegasus",
      "Game_id": "homm3.game",
      "Code": "SILVER_PEGASUS",
      "Name": "Silver Pegasus",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.dendroid.guard",
      "Game_id": "homm3.game",
      "Code": "DENDROID_GUARD",
      "Name": "Dendroid Guard",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.dendroid.soldier",
      "Game_id": "homm3.game",
      "Code": "DENDROID_SOLDIER",
      "Name": "Dendroid Soldier",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.unicorn",
      "Game_id": "homm3.game",
      "Code": "UNICORN",
      "Name": "Unicorn",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.war.unicorn",
      "Game_id": "homm3.game",
      "Code": "WAR_UNICORN",
      "Name": "War Unicorn",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.green.dragon",
      "Game_id": "homm3.game",
      "Code": "GREEN_DRAGON",
      "Name": "Green Dragon",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.gold.dragon",
      "Game_id": "homm3.game",
      "Code": "GOLD_DRAGON",
      "Name": "Gold Dragon",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.imp",
      "Game_id": "homm3.game",
      "Code": "IMP",
      "Name": "Imp",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.familiar",
      "Game_id": "homm3.game",
      "Code": "FAMILIAR",
      "Name": "Familiar",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.gog",
      "Game_id": "homm3.game",
      "Code": "GOG",
      "Name": "Gog",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.magog",
      "Game_id": "homm3.game",
      "Code": "MAGOG",
      "Name": "Magog",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.hell.hound",
      "Game_id": "homm3.game",
      "Code": "HELL_HOUND",
      "Name": "Hell Hound",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.cerberus",
      "Game_id": "homm3.game",
      "Code": "CERBERUS",
      "Name": "Cerberus",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.demon",
      "Game_id": "homm3.game",
      "Code": "DEMON",
      "Name": "Demon",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.horned.demon",
      "Game_id": "homm3.game",
      "Code": "HORNED_DEMON",
      "Name": "Horned Demon",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.pit.fiend",
      "Game_id": "homm3.game",
      "Code": "PIT_FIEND",
      "Name": "Pit Fiend",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.pit.lord",
      "Game_id": "homm3.game",
      "Code": "PIT_LORD",
      "Name": "Pit Lord",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.efreeti",
      "Game_id": "homm3.game",
      "Code": "EFREETI",
      "Name": "Efreeti",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.efreet.sultan",
      "Game_id": "homm3.game",
      "Code": "EFREET_SULTAN",
      "Name": "Efreet Sultan",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.devil",
      "Game_id": "homm3.game",
      "Code": "DEVIL",
      "Name": "Devil",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.arch.devil",
      "Game_id": "homm3.game",
      "Code": "ARCH_DEVIL",
      "Name": "Arch Devil",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.skeleton",
      "Game_id": "homm3.game",
      "Code": "SKELETON",
      "Name": "Skeleton",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.skeleton.warrior",
      "Game_id": "homm3.game",
      "Code": "SKELETON_WARRIOR",
      "Name": "Skeleton Warrior",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.walking.dead",
      "Game_id": "homm3.game",
      "Code": "WALKING_DEAD",
      "Name": "Walking Dead",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.zombie",
      "Game_id": "homm3.game",
      "Code": "ZOMBIE",
      "Name": "Zombie",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.wight",
      "Game_id": "homm3.game",
      "Code": "WIGHT",
      "Name": "Wight",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.wraith",
      "Game_id": "homm3.game",
      "Code": "WRAITH",
      "Name": "Wraith",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.vampire",
      "Game_id": "homm3.game",
      "Code": "VAMPIRE",
      "Name": "Vampire",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.vampire.lord",
      "Game_id": "homm3.game",
      "Code": "VAMPIRE_LORD",
      "Name": "Vampire Lord",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.lich",
      "Game_id": "homm3.game",
      "Code": "LICH",
      "Name": "Lich",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.power.lich",
      "Game_id": "homm3.game",
      "Code": "POWER_LICH",
      "Name": "Power Lich",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.black.knight",
      "Game_id": "homm3.game",
      "Code": "BLACK_KNIGHT",
      "Name": "Black Knight",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.dread.knight",
      "Game_id": "homm3.game",
      "Code": "DREAD_KNIGHT",
      "Name": "Dread Knight",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.bone.dragon",
      "Game_id": "homm3.game",
      "Code": "BONE_DRAGON",
      "Name": "Bone Dragon",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.ghost.dragon",
      "Game_id": "homm3.game",
      "Code": "GHOST_DRAGON",
      "Name": "Ghost Dragon",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.troglodyte",
      "Game_id": "homm3.game",
      "Code": "TROGLODYTE",
      "Name": "Troglodyte",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.infernal.troglodyte",
      "Game_id": "homm3.game",
      "Code": "INFERNAL_TROGLODYTE",
      "Name": "Infernal Troglodyte",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.harpy",
      "Game_id": "homm3.game",
      "Code": "HARPY",
      "Name": "Harpy",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.harpy.hag",
      "Game_id": "homm3.game",
      "Code": "HARPY_HAG",
      "Name": "Harpy Hag",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.beholder",
      "Game_id": "homm3.game",
      "Code": "BEHOLDER",
      "Name": "Beholder",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.evil.eye",
      "Game_id": "homm3.game",
      "Code": "EVIL_EYE",
      "Name": "Evil Eye",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.medusa",
      "Game_id": "homm3.game",
      "Code": "MEDUSA",
      "Name": "Medusa",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.medusa.queen",
      "Game_id": "homm3.game",
      "Code": "MEDUSA_QUEEN",
      "Name": "Medusa Queen",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.minotaur",
      "Game_id": "homm3.game",
      "Code": "MINOTAUR",
      "Name": "Minotaur",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.minotaur.king",
      "Game_id": "homm3.game",
      "Code": "MINOTAUR_KING",
      "Name": "Minotaur King",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.manticore",
      "Game_id": "homm3.game",
      "Code": "MANTICORE",
      "Name": "Manticore",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.scorpicore",
      "Game_id": "homm3.game",
      "Code": "SCORPICORE",
      "Name": "Scorpicore",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.red.dragon",
      "Game_id": "homm3.game",
      "Code": "RED_DRAGON",
      "Name": "Red Dragon",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.black.dragon",
      "Game_id": "homm3.game",
      "Code": "BLACK_DRAGON",
      "Name": "Black Dragon",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.goblin",
      "Game_id": "homm3.game",
      "Code": "GOBLIN",
      "Name": "Goblin",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.hobgoblin",
      "Game_id": "homm3.game",
      "Code": "HOBGOBLIN",
      "Name": "Hobgoblin",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.wolf.rider",
      "Game_id": "homm3.game",
      "Code": "WOLF_RIDER",
      "Name": "Wolf Rider",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.wolf.raider",
      "Game_id": "homm3.game",
      "Code": "WOLF_RAIDER",
      "Name": "Wolf Raider",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.orc",
      "Game_id": "homm3.game",
      "Code": "ORC",
      "Name": "Orc",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.orc.chieftain",
      "Game_id": "homm3.game",
      "Code": "ORC_CHIEFTAIN",
      "Name": "Orc Chieftain",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.ogre",
      "Game_id": "homm3.game",
      "Code": "OGRE",
      "Name": "Ogre",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.ogre.mage",
      "Game_id": "homm3.game",
      "Code": "OGRE_MAGE",
      "Name": "Ogre Mage",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.roc",
      "Game_id": "homm3.game",
      "Code": "ROC",
      "Name": "Roc",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.thunderbird",
      "Game_id": "homm3.game",
      "Code": "THUNDERBIRD",
      "Name": "Thunderbird",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.cyclops",
      "Game_id": "homm3.game",
      "Code": "CYCLOPS",
      "Name": "Cyclops",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.cyclops.king",
      "Game_id": "homm3.game",
      "Code": "CYCLOPS_KING",
      "Name": "Cyclops King",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.behemoth",
      "Game_id": "homm3.game",
      "Code": "BEHEMOTH",
      "Name": "Behemoth",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.ancient.behemoth",
      "Game_id": "homm3.game",
      "Code": "ANCIENT_BEHEMOTH",
      "Name": "Ancient Behemoth",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.gnoll",
      "Game_id": "homm3.game",
      "Code": "GNOLL",
      "Name": "Gnoll",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.gnoll.marauder",
      "Game_id": "homm3.game",
      "Code": "GNOLL_MARAUDER",
      "Name": "Gnoll Marauder",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.lizardman",
      "Game_id": "homm3.game",
      "Code": "LIZARDMAN",
      "Name": "Lizardman",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.lizard.warrior",
      "Game_id": "homm3.game",
      "Code": "LIZARD_WARRIOR",
      "Name": "Lizard Warrior",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.serpent.fly",
      "Game_id": "homm3.game",
      "Code": "SERPENT_FLY",
      "Name": "Serpent Fly",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.dragon.fly",
      "Game_id": "homm3.game",
      "Code": "DRAGON_FLY",
      "Name": "Dragon Fly",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.basilisk",
      "Game_id": "homm3.game",
      "Code": "BASILISK",
      "Name": "Basilisk",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.greater.basilisk",
      "Game_id": "homm3.game",
      "Code": "GREATER_BASILISK",
      "Name": "Greater Basilisk",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.gorgon",
      "Game_id": "homm3.game",
      "Code": "GORGON",
      "Name": "Gorgon",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.mighty.gorgon",
      "Game_id": "homm3.game",
      "Code": "MIGHTY_GORGON",
      "Name": "Mighty Gorgon",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.wyvern",
      "Game_id": "homm3.game",
      "Code": "WYVERN",
      "Name": "Wyvern",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.wyvern.monarch",
      "Game_id": "homm3.game",
      "Code": "WYVERN_MONARCH",
      "Name": "Wyvern Monarch",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.hydra",
      "Game_id": "homm3.game",
      "Code": "HYDRA",
      "Name": "Hydra",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.chaos.hydra",
      "Game_id": "homm3.game",
      "Code": "CHAOS_HYDRA",
      "Name": "Chaos Hydra",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.pixie",
      "Game_id": "homm3.game",
      "Code": "PIXIE",
      "Name": "Pixie",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.ab",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.sprite",
      "Game_id": "homm3.game",
      "Code": "SPRITE",
      "Name": "Sprite",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.ab",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.air.elemental",
      "Game_id": "homm3.game",
      "Code": "AIR_ELEMENTAL",
      "Name": "Air Elemental",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.storm.elemental",
      "Game_id": "homm3.game",
      "Code": "STORM_ELEMENTAL",
      "Name": "Storm Elemental",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.ab",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.water.elemental",
      "Game_id": "homm3.game",
      "Code": "WATER_ELEMENTAL",
      "Name": "Water Elemental",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.ice.elemental",
      "Game_id": "homm3.game",
      "Code": "ICE_ELEMENTAL",
      "Name": "Ice Elemental",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.ab",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.fire.elemental",
      "Game_id": "homm3.game",
      "Code": "FIRE_ELEMENTAL",
      "Name": "Fire Elemental",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.energy.elemental",
      "Game_id": "homm3.game",
      "Code": "ENERGY_ELEMENTAL",
      "Name": "Energy Elemental",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.ab",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.earth.elemental",
      "Game_id": "homm3.game",
      "Code": "EARTH_ELEMENTAL",
      "Name": "Earth Elemental",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.roe",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.magma.elemental",
      "Game_id": "homm3.game",
      "Code": "MAGMA_ELEMENTAL",
      "Name": "Magma Elemental",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.ab",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.psychic.elemental",
      "Game_id": "homm3.game",
      "Code": "PSYCHIC_ELEMENTAL",
      "Name": "Psychic Elemental",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.ab",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.magic.elemental",
      "Game_id": "homm3.game",
      "Code": "MAGIC_ELEMENTAL",
      "Name": "Magic Elemental",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.ab",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.firebird",
      "Game_id": "homm3.game",
      "Code": "FIREBIRD",
      "Name": "Firebird",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.ab",
      "MediaAsset_id": null
    },
    {
      "_key": "homm3.creature.phoenix",
      "Game_id": "homm3.game",
      "Code": "PHOENIX",
      "Name": "Phoenix",
      "Description": null,
      "IntroducedInExpansion_id": "homm3.expansion.ab",
      "MediaAsset_id": null
    }
  ],
  "CreatureHOMM3": [
    {
      "_key": "homm3.creature.pikeman",
      "Faction_id": "homm3.faction.castle",
      "Alignment": "Good",
      "Level": 1,
      "Attack": 4,
      "Defense": 5,
      "DamageMin": 1,
      "DamageMax": 3,
      "Health": 10,
      "Speed": 4,
      "Movement": "Ground",
      "Size": 1,
      "Shots": 0,
      "Growth": 14,
      "AIValue": 80,
      "GoldCost": 60,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.halberdier",
      "Faction_id": "homm3.faction.castle",
      "Alignment": "Good",
      "Level": 1,
      "Attack": 6,
      "Defense": 5,
      "DamageMin": 2,
      "DamageMax": 3,
      "Health": 10,
      "Speed": 5,
      "Movement": "Ground",
      "Size": 1,
      "Shots": 0,
      "Growth": 14,
      "AIValue": 115,
      "GoldCost": 75,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.archer",
      "Faction_id": "homm3.faction.castle",
      "Alignment": "Good",
      "Level": 2,
      "Attack": 6,
      "Defense": 3,
      "DamageMin": 2,
      "DamageMax": 3,
      "Health": 10,
      "Speed": 4,
      "Movement": "Ground",
      "Size": 1,
      "Shots": 12,
      "Growth": 9,
      "AIValue": 126,
      "GoldCost": 100,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.marksman",
      "Faction_id": "homm3.faction.castle",
      "Alignment": "Good",
      "Level": 2,
      "Attack": 6,
      "Defense": 3,
      "DamageMin": 2,
      "DamageMax": 3,
      "Health": 10,
      "Speed": 6,
      "Movement": "Ground",
      "Size": 1,
      "Shots": 24,
      "Growth": 9,
      "AIValue": 184,
      "GoldCost": 150,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.griffin",
      "Faction_id": "homm3.faction.castle",
      "Alignment": "Good",
      "Level": 3,
      "Attack": 8,
      "Defense": 8,
      "DamageMin": 3,
      "DamageMax": 6,
      "Health": 25,
      "Speed": 6,
      "Movement": "Flying",
      "Size": 2,
      "Shots": 0,
      "Growth": 7,
      "AIValue": 351,
      "GoldCost": 200,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.royal.griffin",
      "Faction_id": "homm3.faction.castle",
      "Alignment": "Good",
      "Level": 3,
      "Attack": 9,
      "Defense": 9,
      "DamageMin": 3,
      "DamageMax": 6,
      "Health": 25,
      "Speed": 9,
      "Movement": "Flying",
      "Size": 2,
      "Shots": 0,
      "Growth": 7,
      "AIValue": 448,
      "GoldCost": 240,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.swordsman",
      "Faction_id": "homm3.faction.castle",
      "Alignment": "Good",
      "Level": 4,
      "Attack": 10,
      "Defense": 12,
      "DamageMin": 6,
      "DamageMax": 9,
      "Health": 35,
      "Speed": 5,
      "Movement": "Ground",
      "Size": 1,
      "Shots": 0,
      "Growth": 4,
      "AIValue": 445,
      "GoldCost": 300,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.crusader",
      "Faction_id": "homm3.faction.castle",
      "Alignment": "Good",
      "Level": 4,
      "Attack": 12,
      "Defense": 12,
      "DamageMin": 7,
      "DamageMax": 10,
      "Health": 35,
      "Speed": 6,
      "Movement": "Ground",
      "Size": 1,
      "Shots": 0,
      "Growth": 4,
      "AIValue": 588,
      "GoldCost": 400,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.monk",
      "Faction_id": "homm3.faction.castle",
      "Alignment": "Good",
      "Level": 5,
      "Attack": 12,
      "Defense": 7,
      "DamageMin": 10,
      "DamageMax": 12,
      "Health": 30,
      "Speed": 5,
      "Movement": "Ground",
      "Size": 1,
      "Shots": 12,
      "Growth": 3,
      "AIValue": 485,
      "GoldCost": 400,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.zealot",
      "Faction_id": "homm3.faction.castle",
      "Alignment": "Good",
      "Level": 5,
      "Attack": 12,
      "Defense": 10,
      "DamageMin": 10,
      "DamageMax": 12,
      "Health": 30,
      "Speed": 7,
      "Movement": "Ground",
      "Size": 1,
      "Shots": 24,
      "Growth": 3,
      "AIValue": 750,
      "GoldCost": 450,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.cavalier",
      "Faction_id": "homm3.faction.castle",
      "Alignment": "Good",
      "Level": 6,
      "Attack": 15,
      "Defense": 15,
      "DamageMin": 15,
      "DamageMax": 25,
      "Health": 100,
      "Speed": 7,
      "Movement": "Ground",
      "Size": 2,
      "Shots": 0,
      "Growth": 2,
      "AIValue": 1946,
      "GoldCost": 1000,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.champion",
      "Faction_id": "homm3.faction.castle",
      "Alignment": "Good",
      "Level": 6,
      "Attack": 16,
      "Defense": 16,
      "DamageMin": 20,
      "DamageMax": 25,
      "Health": 100,
      "Speed": 9,
      "Movement": "Ground",
      "Size": 2,
      "Shots": 0,
      "Growth": 2,
      "AIValue": 2100,
      "GoldCost": 1200,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.angel",
      "Faction_id": "homm3.faction.castle",
      "Alignment": "Good",
      "Level": 7,
      "Attack": 20,
      "Defense": 20,
      "DamageMin": 50,
      "DamageMax": 50,
      "Health": 200,
      "Speed": 12,
      "Movement": "Flying",
      "Size": 1,
      "Shots": 0,
      "Growth": 1,
      "AIValue": 5019,
      "GoldCost": 3000,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.archangel",
      "Faction_id": "homm3.faction.castle",
      "Alignment": "Good",
      "Level": 7,
      "Attack": 30,
      "Defense": 30,
      "DamageMin": 50,
      "DamageMax": 50,
      "Health": 250,
      "Speed": 18,
      "Movement": "Flying",
      "Size": 2,
      "Shots": 0,
      "Growth": 1,
      "AIValue": 8776,
      "GoldCost": 5000,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.gremlin",
      "Faction_id": "homm3.faction.tower",
      "Alignment": "Good",
      "Level": 1,
      "Attack": 3,
      "Defense": 3,
      "DamageMin": 1,
      "DamageMax": 2,
      "Health": 4,
      "Speed": 4,
      "Movement": "Ground",
      "Size": 1,
      "Shots": 0,
      "Growth": 16,
      "AIValue": 44,
      "GoldCost": 30,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.master.gremlin",
      "Faction_id": "homm3.faction.tower",
      "Alignment": "Good",
      "Level": 1,
      "Attack": 4,
      "Defense": 4,
      "DamageMin": 1,
      "DamageMax": 2,
      "Health": 4,
      "Speed": 5,
      "Movement": "Ground",
      "Size": 1,
      "Shots": 8,
      "Growth": 16,
      "AIValue": 66,
      "GoldCost": 40,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.stone.gargoyle",
      "Faction_id": "homm3.faction.tower",
      "Alignment": "Good",
      "Level": 2,
      "Attack": 6,
      "Defense": 6,
      "DamageMin": 2,
      "DamageMax": 3,
      "Health": 16,
      "Speed": 6,
      "Movement": "Flying",
      "Size": 1,
      "Shots": 0,
      "Growth": 9,
      "AIValue": 165,
      "GoldCost": 130,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.obsidian.gargoyle",
      "Faction_id": "homm3.faction.tower",
      "Alignment": "Good",
      "Level": 2,
      "Attack": 7,
      "Defense": 7,
      "DamageMin": 2,
      "DamageMax": 3,
      "Health": 16,
      "Speed": 9,
      "Movement": "Flying",
      "Size": 1,
      "Shots": 0,
      "Growth": 9,
      "AIValue": 201,
      "GoldCost": 160,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.stone.golem",
      "Faction_id": "homm3.faction.tower",
      "Alignment": "Good",
      "Level": 3,
      "Attack": 7,
      "Defense": 10,
      "DamageMin": 4,
      "DamageMax": 5,
      "Health": 30,
      "Speed": 3,
      "Movement": "Ground",
      "Size": 1,
      "Shots": 0,
      "Growth": 6,
      "AIValue": 250,
      "GoldCost": 150,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.iron.golem",
      "Faction_id": "homm3.faction.tower",
      "Alignment": "Good",
      "Level": 3,
      "Attack": 9,
      "Defense": 10,
      "DamageMin": 4,
      "DamageMax": 5,
      "Health": 35,
      "Speed": 5,
      "Movement": "Ground",
      "Size": 1,
      "Shots": 0,
      "Growth": 6,
      "AIValue": 412,
      "GoldCost": 200,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.mage",
      "Faction_id": "homm3.faction.tower",
      "Alignment": "Good",
      "Level": 4,
      "Attack": 11,
      "Defense": 8,
      "DamageMin": 7,
      "DamageMax": 9,
      "Health": 25,
      "Speed": 5,
      "Movement": "Ground",
      "Size": 1,
      "Shots": 24,
      "Growth": 4,
      "AIValue": 570,
      "GoldCost": 350,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.arch.mage",
      "Faction_id": "homm3.faction.tower",
      "Alignment": "Good",
      "Level": 4,
      "Attack": 12,
      "Defense": 9,
      "DamageMin": 7,
      "DamageMax": 9,
      "Health": 30,
      "Speed": 7,
      "Movement": "Ground",
      "Size": 1,
      "Shots": 24,
      "Growth": 4,
      "AIValue": 680,
      "GoldCost": 450,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.genie",
      "Faction_id": "homm3.faction.tower",
      "Alignment": "Good",
      "Level": 5,
      "Attack": 12,
      "Defense": 12,
      "DamageMin": 13,
      "DamageMax": 16,
      "Health": 40,
      "Speed": 7,
      "Movement": "Flying",
      "Size": 1,
      "Shots": 0,
      "Growth": 3,
      "AIValue": 884,
      "GoldCost": 550,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.master.genie",
      "Faction_id": "homm3.faction.tower",
      "Alignment": "Good",
      "Level": 5,
      "Attack": 12,
      "Defense": 12,
      "DamageMin": 13,
      "DamageMax": 16,
      "Health": 40,
      "Speed": 11,
      "Movement": "Flying",
      "Size": 1,
      "Shots": 0,
      "Growth": 3,
      "AIValue": 942,
      "GoldCost": 600,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.naga",
      "Faction_id": "homm3.faction.tower",
      "Alignment": "Good",
      "Level": 6,
      "Attack": 16,
      "Defense": 13,
      "DamageMin": 20,
      "DamageMax": 20,
      "Health": 110,
      "Speed": 5,
      "Movement": "Ground",
      "Size": 2,
      "Shots": 0,
      "Growth": 2,
      "AIValue": 2016,
      "GoldCost": 1100,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.naga.queen",
      "Faction_id": "homm3.faction.tower",
      "Alignment": "Good",
      "Level": 6,
      "Attack": 16,
      "Defense": 13,
      "DamageMin": 30,
      "DamageMax": 30,
      "Health": 110,
      "Speed": 7,
      "Movement": "Ground",
      "Size": 2,
      "Shots": 0,
      "Growth": 2,
      "AIValue": 2840,
      "GoldCost": 1600,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.giant",
      "Faction_id": "homm3.faction.tower",
      "Alignment": "Good",
      "Level": 7,
      "Attack": 19,
      "Defense": 16,
      "DamageMin": 40,
      "DamageMax": 60,
      "Health": 150,
      "Speed": 7,
      "Movement": "Ground",
      "Size": 1,
      "Shots": 0,
      "Growth": 1,
      "AIValue": 3718,
      "GoldCost": 2000,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.titan",
      "Faction_id": "homm3.faction.tower",
      "Alignment": "Good",
      "Level": 7,
      "Attack": 24,
      "Defense": 24,
      "DamageMin": 40,
      "DamageMax": 60,
      "Health": 300,
      "Speed": 11,
      "Movement": "Ground",
      "Size": 1,
      "Shots": 24,
      "Growth": 1,
      "AIValue": 7500,
      "GoldCost": 5000,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.centaur",
      "Faction_id": "homm3.faction.rampart",
      "Alignment": "Good",
      "Level": 1,
      "Attack": 5,
      "Defense": 3,
      "DamageMin": 2,
      "DamageMax": 3,
      "Health": 8,
      "Speed": 6,
      "Movement": "Ground",
      "Size": 2,
      "Shots": 0,
      "Growth": 14,
      "AIValue": 100,
      "GoldCost": 70,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.centaur.captain",
      "Faction_id": "homm3.faction.rampart",
      "Alignment": "Good",
      "Level": 1,
      "Attack": 6,
      "Defense": 3,
      "DamageMin": 2,
      "DamageMax": 3,
      "Health": 10,
      "Speed": 8,
      "Movement": "Ground",
      "Size": 2,
      "Shots": 0,
      "Growth": 14,
      "AIValue": 138,
      "GoldCost": 90,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.dwarf",
      "Faction_id": "homm3.faction.rampart",
      "Alignment": "Good",
      "Level": 2,
      "Attack": 6,
      "Defense": 7,
      "DamageMin": 2,
      "DamageMax": 4,
      "Health": 20,
      "Speed": 3,
      "Movement": "Ground",
      "Size": 1,
      "Shots": 0,
      "Growth": 8,
      "AIValue": 138,
      "GoldCost": 120,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.battle.dwarf",
      "Faction_id": "homm3.faction.rampart",
      "Alignment": "Good",
      "Level": 2,
      "Attack": 7,
      "Defense": 7,
      "DamageMin": 2,
      "DamageMax": 4,
      "Health": 20,
      "Speed": 5,
      "Movement": "Ground",
      "Size": 1,
      "Shots": 0,
      "Growth": 8,
      "AIValue": 209,
      "GoldCost": 150,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.wood.elf",
      "Faction_id": "homm3.faction.rampart",
      "Alignment": "Good",
      "Level": 3,
      "Attack": 9,
      "Defense": 5,
      "DamageMin": 3,
      "DamageMax": 5,
      "Health": 15,
      "Speed": 6,
      "Movement": "Ground",
      "Size": 1,
      "Shots": 24,
      "Growth": 7,
      "AIValue": 234,
      "GoldCost": 200,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.grand.elf",
      "Faction_id": "homm3.faction.rampart",
      "Alignment": "Good",
      "Level": 3,
      "Attack": 9,
      "Defense": 5,
      "DamageMin": 3,
      "DamageMax": 5,
      "Health": 15,
      "Speed": 7,
      "Movement": "Ground",
      "Size": 1,
      "Shots": 24,
      "Growth": 7,
      "AIValue": 331,
      "GoldCost": 225,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.pegasus",
      "Faction_id": "homm3.faction.rampart",
      "Alignment": "Good",
      "Level": 4,
      "Attack": 9,
      "Defense": 8,
      "DamageMin": 5,
      "DamageMax": 9,
      "Health": 30,
      "Speed": 8,
      "Movement": "Flying",
      "Size": 2,
      "Shots": 0,
      "Growth": 5,
      "AIValue": 518,
      "GoldCost": 250,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.silver.pegasus",
      "Faction_id": "homm3.faction.rampart",
      "Alignment": "Good",
      "Level": 4,
      "Attack": 9,
      "Defense": 10,
      "DamageMin": 5,
      "DamageMax": 9,
      "Health": 30,
      "Speed": 12,
      "Movement": "Flying",
      "Size": 2,
      "Shots": 0,
      "Growth": 5,
      "AIValue": 532,
      "GoldCost": 275,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.dendroid.guard",
      "Faction_id": "homm3.faction.rampart",
      "Alignment": "Good",
      "Level": 5,
      "Attack": 9,
      "Defense": 12,
      "DamageMin": 10,
      "DamageMax": 14,
      "Health": 55,
      "Speed": 3,
      "Movement": "Ground",
      "Size": 1,
      "Shots": 0,
      "Growth": 3,
      "AIValue": 517,
      "GoldCost": 350,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.dendroid.soldier",
      "Faction_id": "homm3.faction.rampart",
      "Alignment": "Good",
      "Level": 5,
      "Attack": 9,
      "Defense": 12,
      "DamageMin": 10,
      "DamageMax": 14,
      "Health": 65,
      "Speed": 4,
      "Movement": "Ground",
      "Size": 1,
      "Shots": 0,
      "Growth": 3,
      "AIValue": 803,
      "GoldCost": 425,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.unicorn",
      "Faction_id": "homm3.faction.rampart",
      "Alignment": "Good",
      "Level": 6,
      "Attack": 15,
      "Defense": 14,
      "DamageMin": 18,
      "DamageMax": 22,
      "Health": 90,
      "Speed": 7,
      "Movement": "Ground",
      "Size": 2,
      "Shots": 0,
      "Growth": 2,
      "AIValue": 1806,
      "GoldCost": 850,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.war.unicorn",
      "Faction_id": "homm3.faction.rampart",
      "Alignment": "Good",
      "Level": 6,
      "Attack": 15,
      "Defense": 14,
      "DamageMin": 18,
      "DamageMax": 22,
      "Health": 110,
      "Speed": 9,
      "Movement": "Ground",
      "Size": 2,
      "Shots": 0,
      "Growth": 2,
      "AIValue": 2030,
      "GoldCost": 950,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.green.dragon",
      "Faction_id": "homm3.faction.rampart",
      "Alignment": "Good",
      "Level": 7,
      "Attack": 18,
      "Defense": 18,
      "DamageMin": 40,
      "DamageMax": 50,
      "Health": 180,
      "Speed": 10,
      "Movement": "Flying",
      "Size": 2,
      "Shots": 0,
      "Growth": 1,
      "AIValue": 4872,
      "GoldCost": 2400,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.gold.dragon",
      "Faction_id": "homm3.faction.rampart",
      "Alignment": "Good",
      "Level": 7,
      "Attack": 27,
      "Defense": 27,
      "DamageMin": 40,
      "DamageMax": 50,
      "Health": 250,
      "Speed": 16,
      "Movement": "Flying",
      "Size": 2,
      "Shots": 0,
      "Growth": 1,
      "AIValue": 8613,
      "GoldCost": 4000,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.imp",
      "Faction_id": "homm3.faction.inferno",
      "Alignment": "Evil",
      "Level": 1,
      "Attack": 2,
      "Defense": 3,
      "DamageMin": 1,
      "DamageMax": 2,
      "Health": 4,
      "Speed": 5,
      "Movement": "Ground",
      "Size": 1,
      "Shots": 0,
      "Growth": 15,
      "AIValue": 50,
      "GoldCost": 50,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.familiar",
      "Faction_id": "homm3.faction.inferno",
      "Alignment": "Evil",
      "Level": 1,
      "Attack": 4,
      "Defense": 4,
      "DamageMin": 1,
      "DamageMax": 2,
      "Health": 4,
      "Speed": 7,
      "Movement": "Ground",
      "Size": 1,
      "Shots": 0,
      "Growth": 15,
      "AIValue": 60,
      "GoldCost": 60,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.gog",
      "Faction_id": "homm3.faction.inferno",
      "Alignment": "Evil",
      "Level": 2,
      "Attack": 6,
      "Defense": 4,
      "DamageMin": 2,
      "DamageMax": 4,
      "Health": 13,
      "Speed": 4,
      "Movement": "Ground",
      "Size": 1,
      "Shots": 12,
      "Growth": 8,
      "AIValue": 159,
      "GoldCost": 125,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.magog",
      "Faction_id": "homm3.faction.inferno",
      "Alignment": "Evil",
      "Level": 2,
      "Attack": 7,
      "Defense": 4,
      "DamageMin": 2,
      "DamageMax": 4,
      "Health": 13,
      "Speed": 6,
      "Movement": "Ground",
      "Size": 1,
      "Shots": 24,
      "Growth": 8,
      "AIValue": 240,
      "GoldCost": 175,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.hell.hound",
      "Faction_id": "homm3.faction.inferno",
      "Alignment": "Evil",
      "Level": 3,
      "Attack": 10,
      "Defense": 6,
      "DamageMin": 2,
      "DamageMax": 7,
      "Health": 25,
      "Speed": 7,
      "Movement": "Ground",
      "Size": 2,
      "Shots": 0,
      "Growth": 5,
      "AIValue": 357,
      "GoldCost": 200,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.cerberus",
      "Faction_id": "homm3.faction.inferno",
      "Alignment": "Evil",
      "Level": 3,
      "Attack": 10,
      "Defense": 8,
      "DamageMin": 2,
      "DamageMax": 7,
      "Health": 25,
      "Speed": 8,
      "Movement": "Ground",
      "Size": 2,
      "Shots": 0,
      "Growth": 5,
      "AIValue": 392,
      "GoldCost": 250,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.demon",
      "Faction_id": "homm3.faction.inferno",
      "Alignment": "Evil",
      "Level": 4,
      "Attack": 10,
      "Defense": 10,
      "DamageMin": 7,
      "DamageMax": 9,
      "Health": 35,
      "Speed": 5,
      "Movement": "Ground",
      "Size": 1,
      "Shots": 0,
      "Growth": 4,
      "AIValue": 445,
      "GoldCost": 250,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.horned.demon",
      "Faction_id": "homm3.faction.inferno",
      "Alignment": "Evil",
      "Level": 4,
      "Attack": 10,
      "Defense": 10,
      "DamageMin": 7,
      "DamageMax": 9,
      "Health": 40,
      "Speed": 6,
      "Movement": "Ground",
      "Size": 1,
      "Shots": 0,
      "Growth": 4,
      "AIValue": 480,
      "GoldCost": 270,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.pit.fiend",
      "Faction_id": "homm3.faction.inferno",
      "Alignment": "Evil",
      "Level": 5,
      "Attack": 13,
      "Defense": 13,
      "DamageMin": 13,
      "DamageMax": 17,
      "Health": 45,
      "Speed": 6,
      "Movement": "Ground",
      "Size": 1,
      "Shots": 0,
      "Growth": 3,
      "AIValue": 765,
      "GoldCost": 500,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.pit.lord",
      "Faction_id": "homm3.faction.inferno",
      "Alignment": "Evil",
      "Level": 5,
      "Attack": 13,
      "Defense": 13,
      "DamageMin": 13,
      "DamageMax": 17,
      "Health": 45,
      "Speed": 7,
      "Movement": "Ground",
      "Size": 1,
      "Shots": 0,
      "Growth": 3,
      "AIValue": 1224,
      "GoldCost": 700,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.efreeti",
      "Faction_id": "homm3.faction.inferno",
      "Alignment": "Evil",
      "Level": 6,
      "Attack": 16,
      "Defense": 12,
      "DamageMin": 16,
      "DamageMax": 24,
      "Health": 90,
      "Speed": 9,
      "Movement": "Flying",
      "Size": 1,
      "Shots": 0,
      "Growth": 2,
      "AIValue": 1670,
      "GoldCost": 900,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.efreet.sultan",
      "Faction_id": "homm3.faction.inferno",
      "Alignment": "Evil",
      "Level": 6,
      "Attack": 16,
      "Defense": 14,
      "DamageMin": 16,
      "DamageMax": 24,
      "Health": 90,
      "Speed": 13,
      "Movement": "Flying",
      "Size": 1,
      "Shots": 0,
      "Growth": 2,
      "AIValue": 1848,
      "GoldCost": 1100,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.devil",
      "Faction_id": "homm3.faction.inferno",
      "Alignment": "Evil",
      "Level": 7,
      "Attack": 19,
      "Defense": 21,
      "DamageMin": 30,
      "DamageMax": 40,
      "Health": 160,
      "Speed": 11,
      "Movement": "Teleporting",
      "Size": 1,
      "Shots": 0,
      "Growth": 1,
      "AIValue": 5101,
      "GoldCost": 2700,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.arch.devil",
      "Faction_id": "homm3.faction.inferno",
      "Alignment": "Evil",
      "Level": 7,
      "Attack": 26,
      "Defense": 28,
      "DamageMin": 30,
      "DamageMax": 40,
      "Health": 200,
      "Speed": 17,
      "Movement": "Teleporting",
      "Size": 1,
      "Shots": 0,
      "Growth": 1,
      "AIValue": 7115,
      "GoldCost": 4500,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.skeleton",
      "Faction_id": "homm3.faction.necropolis",
      "Alignment": "Evil",
      "Level": 1,
      "Attack": 5,
      "Defense": 4,
      "DamageMin": 1,
      "DamageMax": 3,
      "Health": 6,
      "Speed": 4,
      "Movement": "Ground",
      "Size": 1,
      "Shots": 0,
      "Growth": 12,
      "AIValue": 60,
      "GoldCost": 60,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.skeleton.warrior",
      "Faction_id": "homm3.faction.necropolis",
      "Alignment": "Evil",
      "Level": 1,
      "Attack": 6,
      "Defense": 6,
      "DamageMin": 1,
      "DamageMax": 3,
      "Health": 6,
      "Speed": 5,
      "Movement": "Ground",
      "Size": 1,
      "Shots": 0,
      "Growth": 12,
      "AIValue": 85,
      "GoldCost": 70,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.walking.dead",
      "Faction_id": "homm3.faction.necropolis",
      "Alignment": "Evil",
      "Level": 2,
      "Attack": 5,
      "Defense": 5,
      "DamageMin": 2,
      "DamageMax": 3,
      "Health": 15,
      "Speed": 3,
      "Movement": "Ground",
      "Size": 1,
      "Shots": 0,
      "Growth": 8,
      "AIValue": 98,
      "GoldCost": 100,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.zombie",
      "Faction_id": "homm3.faction.necropolis",
      "Alignment": "Evil",
      "Level": 2,
      "Attack": 5,
      "Defense": 5,
      "DamageMin": 2,
      "DamageMax": 3,
      "Health": 20,
      "Speed": 4,
      "Movement": "Ground",
      "Size": 1,
      "Shots": 0,
      "Growth": 8,
      "AIValue": 128,
      "GoldCost": 125,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.wight",
      "Faction_id": "homm3.faction.necropolis",
      "Alignment": "Evil",
      "Level": 3,
      "Attack": 7,
      "Defense": 7,
      "DamageMin": 3,
      "DamageMax": 5,
      "Health": 18,
      "Speed": 5,
      "Movement": "Flying",
      "Size": 1,
      "Shots": 0,
      "Growth": 7,
      "AIValue": 252,
      "GoldCost": 200,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.wraith",
      "Faction_id": "homm3.faction.necropolis",
      "Alignment": "Evil",
      "Level": 3,
      "Attack": 7,
      "Defense": 7,
      "DamageMin": 3,
      "DamageMax": 5,
      "Health": 18,
      "Speed": 7,
      "Movement": "Flying",
      "Size": 1,
      "Shots": 0,
      "Growth": 7,
      "AIValue": 315,
      "GoldCost": 230,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.vampire",
      "Faction_id": "homm3.faction.necropolis",
      "Alignment": "Evil",
      "Level": 4,
      "Attack": 10,
      "Defense": 9,
      "DamageMin": 5,
      "DamageMax": 8,
      "Health": 30,
      "Speed": 6,
      "Movement": "Flying",
      "Size": 1,
      "Shots": 0,
      "Growth": 4,
      "AIValue": 555,
      "GoldCost": 360,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.vampire.lord",
      "Faction_id": "homm3.faction.necropolis",
      "Alignment": "Evil",
      "Level": 4,
      "Attack": 10,
      "Defense": 10,
      "DamageMin": 5,
      "DamageMax": 8,
      "Health": 40,
      "Speed": 9,
      "Movement": "Flying",
      "Size": 1,
      "Shots": 0,
      "Growth": 4,
      "AIValue": 783,
      "GoldCost": 500,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.lich",
      "Faction_id": "homm3.faction.necropolis",
      "Alignment": "Evil",
      "Level": 5,
      "Attack": 13,
      "Defense": 10,
      "DamageMin": 11,
      "DamageMax": 13,
      "Health": 30,
      "Speed": 6,
      "Movement": "Ground",
      "Size": 1,
      "Shots": 12,
      "Growth": 3,
      "AIValue": 848,
      "GoldCost": 550,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.power.lich",
      "Faction_id": "homm3.faction.necropolis",
      "Alignment": "Evil",
      "Level": 5,
      "Attack": 13,
      "Defense": 10,
      "DamageMin": 11,
      "DamageMax": 15,
      "Health": 40,
      "Speed": 7,
      "Movement": "Ground",
      "Size": 1,
      "Shots": 24,
      "Growth": 3,
      "AIValue": 1079,
      "GoldCost": 600,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.black.knight",
      "Faction_id": "homm3.faction.necropolis",
      "Alignment": "Evil",
      "Level": 6,
      "Attack": 16,
      "Defense": 16,
      "DamageMin": 15,
      "DamageMax": 30,
      "Health": 120,
      "Speed": 7,
      "Movement": "Ground",
      "Size": 2,
      "Shots": 0,
      "Growth": 2,
      "AIValue": 2087,
      "GoldCost": 1200,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.dread.knight",
      "Faction_id": "homm3.faction.necropolis",
      "Alignment": "Evil",
      "Level": 6,
      "Attack": 18,
      "Defense": 18,
      "DamageMin": 15,
      "DamageMax": 30,
      "Health": 120,
      "Speed": 9,
      "Movement": "Ground",
      "Size": 2,
      "Shots": 0,
      "Growth": 2,
      "AIValue": 2382,
      "GoldCost": 1500,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.bone.dragon",
      "Faction_id": "homm3.faction.necropolis",
      "Alignment": "Evil",
      "Level": 7,
      "Attack": 17,
      "Defense": 15,
      "DamageMin": 25,
      "DamageMax": 50,
      "Health": 150,
      "Speed": 9,
      "Movement": "Flying",
      "Size": 2,
      "Shots": 0,
      "Growth": 1,
      "AIValue": 3388,
      "GoldCost": 1800,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.ghost.dragon",
      "Faction_id": "homm3.faction.necropolis",
      "Alignment": "Evil",
      "Level": 7,
      "Attack": 19,
      "Defense": 17,
      "DamageMin": 25,
      "DamageMax": 50,
      "Health": 200,
      "Speed": 14,
      "Movement": "Flying",
      "Size": 2,
      "Shots": 0,
      "Growth": 1,
      "AIValue": 4696,
      "GoldCost": 3000,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.troglodyte",
      "Faction_id": "homm3.faction.dungeon",
      "Alignment": "Evil",
      "Level": 1,
      "Attack": 4,
      "Defense": 3,
      "DamageMin": 1,
      "DamageMax": 3,
      "Health": 5,
      "Speed": 4,
      "Movement": "Ground",
      "Size": 1,
      "Shots": 0,
      "Growth": 14,
      "AIValue": 59,
      "GoldCost": 50,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.infernal.troglodyte",
      "Faction_id": "homm3.faction.dungeon",
      "Alignment": "Evil",
      "Level": 1,
      "Attack": 5,
      "Defense": 4,
      "DamageMin": 1,
      "DamageMax": 3,
      "Health": 6,
      "Speed": 5,
      "Movement": "Ground",
      "Size": 1,
      "Shots": 0,
      "Growth": 14,
      "AIValue": 84,
      "GoldCost": 65,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.harpy",
      "Faction_id": "homm3.faction.dungeon",
      "Alignment": "Evil",
      "Level": 2,
      "Attack": 6,
      "Defense": 5,
      "DamageMin": 1,
      "DamageMax": 4,
      "Health": 14,
      "Speed": 6,
      "Movement": "Flying",
      "Size": 1,
      "Shots": 0,
      "Growth": 8,
      "AIValue": 154,
      "GoldCost": 130,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.harpy.hag",
      "Faction_id": "homm3.faction.dungeon",
      "Alignment": "Evil",
      "Level": 2,
      "Attack": 6,
      "Defense": 6,
      "DamageMin": 1,
      "DamageMax": 4,
      "Health": 14,
      "Speed": 9,
      "Movement": "Flying",
      "Size": 1,
      "Shots": 0,
      "Growth": 8,
      "AIValue": 238,
      "GoldCost": 170,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.beholder",
      "Faction_id": "homm3.faction.dungeon",
      "Alignment": "Evil",
      "Level": 3,
      "Attack": 9,
      "Defense": 7,
      "DamageMin": 3,
      "DamageMax": 5,
      "Health": 22,
      "Speed": 5,
      "Movement": "Ground",
      "Size": 1,
      "Shots": 12,
      "Growth": 7,
      "AIValue": 336,
      "GoldCost": 250,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.evil.eye",
      "Faction_id": "homm3.faction.dungeon",
      "Alignment": "Evil",
      "Level": 3,
      "Attack": 10,
      "Defense": 8,
      "DamageMin": 3,
      "DamageMax": 5,
      "Health": 22,
      "Speed": 7,
      "Movement": "Ground",
      "Size": 1,
      "Shots": 24,
      "Growth": 7,
      "AIValue": 367,
      "GoldCost": 280,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.medusa",
      "Faction_id": "homm3.faction.dungeon",
      "Alignment": "Evil",
      "Level": 4,
      "Attack": 9,
      "Defense": 9,
      "DamageMin": 6,
      "DamageMax": 8,
      "Health": 25,
      "Speed": 5,
      "Movement": "Ground",
      "Size": 2,
      "Shots": 4,
      "Growth": 4,
      "AIValue": 517,
      "GoldCost": 300,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.medusa.queen",
      "Faction_id": "homm3.faction.dungeon",
      "Alignment": "Evil",
      "Level": 4,
      "Attack": 10,
      "Defense": 10,
      "DamageMin": 6,
      "DamageMax": 8,
      "Health": 30,
      "Speed": 6,
      "Movement": "Ground",
      "Size": 2,
      "Shots": 8,
      "Growth": 4,
      "AIValue": 577,
      "GoldCost": 330,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.minotaur",
      "Faction_id": "homm3.faction.dungeon",
      "Alignment": "Evil",
      "Level": 5,
      "Attack": 14,
      "Defense": 12,
      "DamageMin": 12,
      "DamageMax": 20,
      "Health": 50,
      "Speed": 6,
      "Movement": "Ground",
      "Size": 1,
      "Shots": 0,
      "Growth": 3,
      "AIValue": 835,
      "GoldCost": 500,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.minotaur.king",
      "Faction_id": "homm3.faction.dungeon",
      "Alignment": "Evil",
      "Level": 5,
      "Attack": 15,
      "Defense": 15,
      "DamageMin": 12,
      "DamageMax": 20,
      "Health": 50,
      "Speed": 8,
      "Movement": "Ground",
      "Size": 1,
      "Shots": 0,
      "Growth": 3,
      "AIValue": 1068,
      "GoldCost": 575,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.manticore",
      "Faction_id": "homm3.faction.dungeon",
      "Alignment": "Evil",
      "Level": 6,
      "Attack": 15,
      "Defense": 13,
      "DamageMin": 14,
      "DamageMax": 20,
      "Health": 80,
      "Speed": 7,
      "Movement": "Flying",
      "Size": 2,
      "Shots": 0,
      "Growth": 2,
      "AIValue": 1547,
      "GoldCost": 850,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.scorpicore",
      "Faction_id": "homm3.faction.dungeon",
      "Alignment": "Evil",
      "Level": 6,
      "Attack": 16,
      "Defense": 14,
      "DamageMin": 14,
      "DamageMax": 20,
      "Health": 80,
      "Speed": 11,
      "Movement": "Flying",
      "Size": 2,
      "Shots": 0,
      "Growth": 2,
      "AIValue": 1589,
      "GoldCost": 1050,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.red.dragon",
      "Faction_id": "homm3.faction.dungeon",
      "Alignment": "Evil",
      "Level": 7,
      "Attack": 19,
      "Defense": 19,
      "DamageMin": 40,
      "DamageMax": 50,
      "Health": 180,
      "Speed": 11,
      "Movement": "Flying",
      "Size": 2,
      "Shots": 0,
      "Growth": 1,
      "AIValue": 4702,
      "GoldCost": 2500,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.black.dragon",
      "Faction_id": "homm3.faction.dungeon",
      "Alignment": "Evil",
      "Level": 7,
      "Attack": 25,
      "Defense": 25,
      "DamageMin": 40,
      "DamageMax": 50,
      "Health": 300,
      "Speed": 15,
      "Movement": "Flying",
      "Size": 2,
      "Shots": 0,
      "Growth": 1,
      "AIValue": 8721,
      "GoldCost": 4000,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.goblin",
      "Faction_id": "homm3.faction.stronghold",
      "Alignment": "Neutral",
      "Level": 1,
      "Attack": 4,
      "Defense": 2,
      "DamageMin": 1,
      "DamageMax": 2,
      "Health": 5,
      "Speed": 5,
      "Movement": "Ground",
      "Size": 1,
      "Shots": 0,
      "Growth": 15,
      "AIValue": 60,
      "GoldCost": 40,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.hobgoblin",
      "Faction_id": "homm3.faction.stronghold",
      "Alignment": "Neutral",
      "Level": 1,
      "Attack": 5,
      "Defense": 3,
      "DamageMin": 1,
      "DamageMax": 2,
      "Health": 5,
      "Speed": 7,
      "Movement": "Ground",
      "Size": 1,
      "Shots": 0,
      "Growth": 15,
      "AIValue": 78,
      "GoldCost": 50,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.wolf.rider",
      "Faction_id": "homm3.faction.stronghold",
      "Alignment": "Neutral",
      "Level": 2,
      "Attack": 7,
      "Defense": 5,
      "DamageMin": 2,
      "DamageMax": 4,
      "Health": 10,
      "Speed": 6,
      "Movement": "Ground",
      "Size": 2,
      "Shots": 0,
      "Growth": 9,
      "AIValue": 130,
      "GoldCost": 100,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.wolf.raider",
      "Faction_id": "homm3.faction.stronghold",
      "Alignment": "Neutral",
      "Level": 2,
      "Attack": 8,
      "Defense": 5,
      "DamageMin": 3,
      "DamageMax": 4,
      "Health": 10,
      "Speed": 8,
      "Movement": "Ground",
      "Size": 2,
      "Shots": 0,
      "Growth": 9,
      "AIValue": 203,
      "GoldCost": 140,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.orc",
      "Faction_id": "homm3.faction.stronghold",
      "Alignment": "Neutral",
      "Level": 3,
      "Attack": 8,
      "Defense": 4,
      "DamageMin": 2,
      "DamageMax": 5,
      "Health": 15,
      "Speed": 4,
      "Movement": "Ground",
      "Size": 1,
      "Shots": 12,
      "Growth": 7,
      "AIValue": 192,
      "GoldCost": 150,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.orc.chieftain",
      "Faction_id": "homm3.faction.stronghold",
      "Alignment": "Neutral",
      "Level": 3,
      "Attack": 8,
      "Defense": 4,
      "DamageMin": 2,
      "DamageMax": 5,
      "Health": 20,
      "Speed": 5,
      "Movement": "Ground",
      "Size": 1,
      "Shots": 24,
      "Growth": 7,
      "AIValue": 240,
      "GoldCost": 165,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.ogre",
      "Faction_id": "homm3.faction.stronghold",
      "Alignment": "Neutral",
      "Level": 4,
      "Attack": 13,
      "Defense": 7,
      "DamageMin": 6,
      "DamageMax": 12,
      "Health": 40,
      "Speed": 4,
      "Movement": "Ground",
      "Size": 1,
      "Shots": 0,
      "Growth": 4,
      "AIValue": 416,
      "GoldCost": 300,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.ogre.mage",
      "Faction_id": "homm3.faction.stronghold",
      "Alignment": "Neutral",
      "Level": 4,
      "Attack": 13,
      "Defense": 7,
      "DamageMin": 6,
      "DamageMax": 12,
      "Health": 60,
      "Speed": 5,
      "Movement": "Ground",
      "Size": 1,
      "Shots": 0,
      "Growth": 4,
      "AIValue": 672,
      "GoldCost": 400,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.roc",
      "Faction_id": "homm3.faction.stronghold",
      "Alignment": "Neutral",
      "Level": 5,
      "Attack": 13,
      "Defense": 11,
      "DamageMin": 11,
      "DamageMax": 15,
      "Health": 60,
      "Speed": 7,
      "Movement": "Flying",
      "Size": 2,
      "Shots": 0,
      "Growth": 3,
      "AIValue": 1027,
      "GoldCost": 600,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.thunderbird",
      "Faction_id": "homm3.faction.stronghold",
      "Alignment": "Neutral",
      "Level": 5,
      "Attack": 13,
      "Defense": 11,
      "DamageMin": 11,
      "DamageMax": 15,
      "Health": 60,
      "Speed": 11,
      "Movement": "Flying",
      "Size": 2,
      "Shots": 0,
      "Growth": 3,
      "AIValue": 1106,
      "GoldCost": 700,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.cyclops",
      "Faction_id": "homm3.faction.stronghold",
      "Alignment": "Neutral",
      "Level": 6,
      "Attack": 15,
      "Defense": 12,
      "DamageMin": 16,
      "DamageMax": 20,
      "Health": 70,
      "Speed": 6,
      "Movement": "Ground",
      "Size": 1,
      "Shots": 16,
      "Growth": 2,
      "AIValue": 1266,
      "GoldCost": 750,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.cyclops.king",
      "Faction_id": "homm3.faction.stronghold",
      "Alignment": "Neutral",
      "Level": 6,
      "Attack": 17,
      "Defense": 13,
      "DamageMin": 16,
      "DamageMax": 20,
      "Health": 70,
      "Speed": 8,
      "Movement": "Ground",
      "Size": 1,
      "Shots": 24,
      "Growth": 2,
      "AIValue": 1443,
      "GoldCost": 1100,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.behemoth",
      "Faction_id": "homm3.faction.stronghold",
      "Alignment": "Neutral",
      "Level": 7,
      "Attack": 17,
      "Defense": 17,
      "DamageMin": 30,
      "DamageMax": 50,
      "Health": 160,
      "Speed": 6,
      "Movement": "Ground",
      "Size": 2,
      "Shots": 0,
      "Growth": 1,
      "AIValue": 3162,
      "GoldCost": 1500,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.ancient.behemoth",
      "Faction_id": "homm3.faction.stronghold",
      "Alignment": "Neutral",
      "Level": 7,
      "Attack": 19,
      "Defense": 19,
      "DamageMin": 30,
      "DamageMax": 50,
      "Health": 300,
      "Speed": 9,
      "Movement": "Ground",
      "Size": 2,
      "Shots": 0,
      "Growth": 1,
      "AIValue": 6168,
      "GoldCost": 3000,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.gnoll",
      "Faction_id": "homm3.faction.fortress",
      "Alignment": "Neutral",
      "Level": 1,
      "Attack": 3,
      "Defense": 5,
      "DamageMin": 2,
      "DamageMax": 3,
      "Health": 6,
      "Speed": 4,
      "Movement": "Ground",
      "Size": 1,
      "Shots": 0,
      "Growth": 12,
      "AIValue": 56,
      "GoldCost": 50,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.gnoll.marauder",
      "Faction_id": "homm3.faction.fortress",
      "Alignment": "Neutral",
      "Level": 1,
      "Attack": 4,
      "Defense": 6,
      "DamageMin": 2,
      "DamageMax": 3,
      "Health": 6,
      "Speed": 5,
      "Movement": "Ground",
      "Size": 1,
      "Shots": 0,
      "Growth": 12,
      "AIValue": 90,
      "GoldCost": 70,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.lizardman",
      "Faction_id": "homm3.faction.fortress",
      "Alignment": "Neutral",
      "Level": 2,
      "Attack": 5,
      "Defense": 6,
      "DamageMin": 2,
      "DamageMax": 3,
      "Health": 14,
      "Speed": 4,
      "Movement": "Ground",
      "Size": 1,
      "Shots": 12,
      "Growth": 9,
      "AIValue": 126,
      "GoldCost": 110,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.lizard.warrior",
      "Faction_id": "homm3.faction.fortress",
      "Alignment": "Neutral",
      "Level": 2,
      "Attack": 6,
      "Defense": 8,
      "DamageMin": 2,
      "DamageMax": 5,
      "Health": 15,
      "Speed": 5,
      "Movement": "Ground",
      "Size": 1,
      "Shots": 24,
      "Growth": 9,
      "AIValue": 156,
      "GoldCost": 140,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.serpent.fly",
      "Faction_id": "homm3.faction.fortress",
      "Alignment": "Neutral",
      "Level": 3,
      "Attack": 7,
      "Defense": 9,
      "DamageMin": 2,
      "DamageMax": 5,
      "Health": 20,
      "Speed": 9,
      "Movement": "Flying",
      "Size": 1,
      "Shots": 0,
      "Growth": 8,
      "AIValue": 268,
      "GoldCost": 220,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.dragon.fly",
      "Faction_id": "homm3.faction.fortress",
      "Alignment": "Neutral",
      "Level": 3,
      "Attack": 8,
      "Defense": 10,
      "DamageMin": 2,
      "DamageMax": 5,
      "Health": 20,
      "Speed": 13,
      "Movement": "Flying",
      "Size": 1,
      "Shots": 0,
      "Growth": 8,
      "AIValue": 312,
      "GoldCost": 240,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.basilisk",
      "Faction_id": "homm3.faction.fortress",
      "Alignment": "Neutral",
      "Level": 4,
      "Attack": 11,
      "Defense": 11,
      "DamageMin": 6,
      "DamageMax": 10,
      "Health": 35,
      "Speed": 5,
      "Movement": "Ground",
      "Size": 2,
      "Shots": 0,
      "Growth": 4,
      "AIValue": 552,
      "GoldCost": 325,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.greater.basilisk",
      "Faction_id": "homm3.faction.fortress",
      "Alignment": "Neutral",
      "Level": 4,
      "Attack": 12,
      "Defense": 12,
      "DamageMin": 6,
      "DamageMax": 10,
      "Health": 40,
      "Speed": 7,
      "Movement": "Ground",
      "Size": 2,
      "Shots": 0,
      "Growth": 4,
      "AIValue": 714,
      "GoldCost": 400,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.gorgon",
      "Faction_id": "homm3.faction.fortress",
      "Alignment": "Neutral",
      "Level": 5,
      "Attack": 10,
      "Defense": 14,
      "DamageMin": 12,
      "DamageMax": 16,
      "Health": 70,
      "Speed": 5,
      "Movement": "Ground",
      "Size": 2,
      "Shots": 0,
      "Growth": 3,
      "AIValue": 890,
      "GoldCost": 525,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.mighty.gorgon",
      "Faction_id": "homm3.faction.fortress",
      "Alignment": "Neutral",
      "Level": 5,
      "Attack": 11,
      "Defense": 16,
      "DamageMin": 12,
      "DamageMax": 16,
      "Health": 70,
      "Speed": 6,
      "Movement": "Ground",
      "Size": 2,
      "Shots": 0,
      "Growth": 3,
      "AIValue": 1028,
      "GoldCost": 600,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.wyvern",
      "Faction_id": "homm3.faction.fortress",
      "Alignment": "Neutral",
      "Level": 6,
      "Attack": 14,
      "Defense": 14,
      "DamageMin": 14,
      "DamageMax": 18,
      "Health": 70,
      "Speed": 7,
      "Movement": "Flying",
      "Size": 2,
      "Shots": 0,
      "Growth": 2,
      "AIValue": 1350,
      "GoldCost": 800,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.wyvern.monarch",
      "Faction_id": "homm3.faction.fortress",
      "Alignment": "Neutral",
      "Level": 6,
      "Attack": 14,
      "Defense": 14,
      "DamageMin": 18,
      "DamageMax": 22,
      "Health": 70,
      "Speed": 11,
      "Movement": "Flying",
      "Size": 2,
      "Shots": 0,
      "Growth": 2,
      "AIValue": 1518,
      "GoldCost": 1100,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.hydra",
      "Faction_id": "homm3.faction.fortress",
      "Alignment": "Neutral",
      "Level": 7,
      "Attack": 16,
      "Defense": 18,
      "DamageMin": 25,
      "DamageMax": 45,
      "Health": 175,
      "Speed": 5,
      "Movement": "Ground",
      "Size": 2,
      "Shots": 0,
      "Growth": 1,
      "AIValue": 4120,
      "GoldCost": 2200,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.chaos.hydra",
      "Faction_id": "homm3.faction.fortress",
      "Alignment": "Neutral",
      "Level": 7,
      "Attack": 18,
      "Defense": 20,
      "DamageMin": 25,
      "DamageMax": 45,
      "Health": 250,
      "Speed": 7,
      "Movement": "Ground",
      "Size": 2,
      "Shots": 0,
      "Growth": 1,
      "AIValue": 5931,
      "GoldCost": 3500,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.pixie",
      "Faction_id": "homm3.faction.conflux",
      "Alignment": "Neutral",
      "Level": 1,
      "Attack": 2,
      "Defense": 2,
      "DamageMin": 1,
      "DamageMax": 2,
      "Health": 3,
      "Speed": 7,
      "Movement": "Flying",
      "Size": 1,
      "Shots": 0,
      "Growth": 20,
      "AIValue": 55,
      "GoldCost": 25,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.sprite",
      "Faction_id": "homm3.faction.conflux",
      "Alignment": "Neutral",
      "Level": 1,
      "Attack": 2,
      "Defense": 2,
      "DamageMin": 1,
      "DamageMax": 3,
      "Health": 3,
      "Speed": 9,
      "Movement": "Flying",
      "Size": 1,
      "Shots": 0,
      "Growth": 20,
      "AIValue": 95,
      "GoldCost": 30,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.air.elemental",
      "Faction_id": "homm3.faction.conflux",
      "Alignment": "Neutral",
      "Level": 2,
      "Attack": 9,
      "Defense": 9,
      "DamageMin": 2,
      "DamageMax": 8,
      "Health": 25,
      "Speed": 7,
      "Movement": "Ground",
      "Size": 1,
      "Shots": 0,
      "Growth": 6,
      "AIValue": 356,
      "GoldCost": 250,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.storm.elemental",
      "Faction_id": "homm3.faction.conflux",
      "Alignment": "Neutral",
      "Level": 2,
      "Attack": 9,
      "Defense": 9,
      "DamageMin": 2,
      "DamageMax": 8,
      "Health": 25,
      "Speed": 8,
      "Movement": "Ground",
      "Size": 1,
      "Shots": 24,
      "Growth": 6,
      "AIValue": 486,
      "GoldCost": 275,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.water.elemental",
      "Faction_id": "homm3.faction.conflux",
      "Alignment": "Neutral",
      "Level": 3,
      "Attack": 8,
      "Defense": 10,
      "DamageMin": 3,
      "DamageMax": 7,
      "Health": 30,
      "Speed": 5,
      "Movement": "Ground",
      "Size": 2,
      "Shots": 0,
      "Growth": 6,
      "AIValue": 315,
      "GoldCost": 300,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.ice.elemental",
      "Faction_id": "homm3.faction.conflux",
      "Alignment": "Neutral",
      "Level": 3,
      "Attack": 8,
      "Defense": 10,
      "DamageMin": 3,
      "DamageMax": 7,
      "Health": 30,
      "Speed": 6,
      "Movement": "Ground",
      "Size": 2,
      "Shots": 24,
      "Growth": 6,
      "AIValue": 380,
      "GoldCost": 375,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.fire.elemental",
      "Faction_id": "homm3.faction.conflux",
      "Alignment": "Neutral",
      "Level": 4,
      "Attack": 10,
      "Defense": 8,
      "DamageMin": 4,
      "DamageMax": 6,
      "Health": 35,
      "Speed": 6,
      "Movement": "Ground",
      "Size": 1,
      "Shots": 0,
      "Growth": 5,
      "AIValue": 345,
      "GoldCost": 350,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.energy.elemental",
      "Faction_id": "homm3.faction.conflux",
      "Alignment": "Neutral",
      "Level": 4,
      "Attack": 12,
      "Defense": 8,
      "DamageMin": 4,
      "DamageMax": 6,
      "Health": 35,
      "Speed": 8,
      "Movement": "Flying",
      "Size": 1,
      "Shots": 0,
      "Growth": 5,
      "AIValue": 470,
      "GoldCost": 400,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.earth.elemental",
      "Faction_id": "homm3.faction.conflux",
      "Alignment": "Neutral",
      "Level": 5,
      "Attack": 10,
      "Defense": 10,
      "DamageMin": 4,
      "DamageMax": 8,
      "Health": 40,
      "Speed": 4,
      "Movement": "Ground",
      "Size": 1,
      "Shots": 0,
      "Growth": 4,
      "AIValue": 330,
      "GoldCost": 400,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.magma.elemental",
      "Faction_id": "homm3.faction.conflux",
      "Alignment": "Neutral",
      "Level": 5,
      "Attack": 11,
      "Defense": 11,
      "DamageMin": 6,
      "DamageMax": 10,
      "Health": 40,
      "Speed": 6,
      "Movement": "Ground",
      "Size": 1,
      "Shots": 0,
      "Growth": 4,
      "AIValue": 490,
      "GoldCost": 500,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.psychic.elemental",
      "Faction_id": "homm3.faction.conflux",
      "Alignment": "Neutral",
      "Level": 6,
      "Attack": 15,
      "Defense": 13,
      "DamageMin": 10,
      "DamageMax": 20,
      "Health": 75,
      "Speed": 7,
      "Movement": "Ground",
      "Size": 1,
      "Shots": 0,
      "Growth": 2,
      "AIValue": 1669,
      "GoldCost": 750,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.magic.elemental",
      "Faction_id": "homm3.faction.conflux",
      "Alignment": "Neutral",
      "Level": 6,
      "Attack": 15,
      "Defense": 13,
      "DamageMin": 15,
      "DamageMax": 25,
      "Health": 80,
      "Speed": 9,
      "Movement": "Ground",
      "Size": 1,
      "Shots": 0,
      "Growth": 2,
      "AIValue": 2012,
      "GoldCost": 800,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.firebird",
      "Faction_id": "homm3.faction.conflux",
      "Alignment": "Neutral",
      "Level": 7,
      "Attack": 18,
      "Defense": 18,
      "DamageMin": 30,
      "DamageMax": 40,
      "Health": 150,
      "Speed": 15,
      "Movement": "Flying",
      "Size": 2,
      "Shots": 0,
      "Growth": 2,
      "AIValue": 4547,
      "GoldCost": 1500,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    },
    {
      "_key": "homm3.creature.phoenix",
      "Faction_id": "homm3.faction.conflux",
      "Alignment": "Neutral",
      "Level": 7,
      "Attack": 21,
      "Defense": 18,
      "DamageMin": 30,
      "DamageMax": 40,
      "Health": 200,
      "Speed": 21,
      "Movement": "Flying",
      "Size": 2,
      "Shots": 0,
      "Growth": 2,
      "AIValue": 6721,
      "GoldCost": 2000,
      "Recruitable": true,
      "DoubleUpgrade": false,
      "AlternativeUpgrade": false
    }
  ],
  "CreatureUpgrade": [
    {
      "_key": "homm3.creature-upgrade.pikeman.to.halberdier",
      "Game_id": "homm3.game",
      "BaseCreature_id": "homm3.creature.pikeman",
      "UpgradedCreature_id": "homm3.creature.halberdier"
    },
    {
      "_key": "homm3.creature-upgrade.archer.to.marksman",
      "Game_id": "homm3.game",
      "BaseCreature_id": "homm3.creature.archer",
      "UpgradedCreature_id": "homm3.creature.marksman"
    },
    {
      "_key": "homm3.creature-upgrade.griffin.to.royal.griffin",
      "Game_id": "homm3.game",
      "BaseCreature_id": "homm3.creature.griffin",
      "UpgradedCreature_id": "homm3.creature.royal.griffin"
    },
    {
      "_key": "homm3.creature-upgrade.swordsman.to.crusader",
      "Game_id": "homm3.game",
      "BaseCreature_id": "homm3.creature.swordsman",
      "UpgradedCreature_id": "homm3.creature.crusader"
    },
    {
      "_key": "homm3.creature-upgrade.monk.to.zealot",
      "Game_id": "homm3.game",
      "BaseCreature_id": "homm3.creature.monk",
      "UpgradedCreature_id": "homm3.creature.zealot"
    },
    {
      "_key": "homm3.creature-upgrade.cavalier.to.champion",
      "Game_id": "homm3.game",
      "BaseCreature_id": "homm3.creature.cavalier",
      "UpgradedCreature_id": "homm3.creature.champion"
    },
    {
      "_key": "homm3.creature-upgrade.angel.to.archangel",
      "Game_id": "homm3.game",
      "BaseCreature_id": "homm3.creature.angel",
      "UpgradedCreature_id": "homm3.creature.archangel"
    },
    {
      "_key": "homm3.creature-upgrade.gremlin.to.master.gremlin",
      "Game_id": "homm3.game",
      "BaseCreature_id": "homm3.creature.gremlin",
      "UpgradedCreature_id": "homm3.creature.master.gremlin"
    },
    {
      "_key": "homm3.creature-upgrade.stone.gargoyle.to.obsidian.gargoyle",
      "Game_id": "homm3.game",
      "BaseCreature_id": "homm3.creature.stone.gargoyle",
      "UpgradedCreature_id": "homm3.creature.obsidian.gargoyle"
    },
    {
      "_key": "homm3.creature-upgrade.stone.golem.to.iron.golem",
      "Game_id": "homm3.game",
      "BaseCreature_id": "homm3.creature.stone.golem",
      "UpgradedCreature_id": "homm3.creature.iron.golem"
    },
    {
      "_key": "homm3.creature-upgrade.mage.to.arch.mage",
      "Game_id": "homm3.game",
      "BaseCreature_id": "homm3.creature.mage",
      "UpgradedCreature_id": "homm3.creature.arch.mage"
    },
    {
      "_key": "homm3.creature-upgrade.genie.to.master.genie",
      "Game_id": "homm3.game",
      "BaseCreature_id": "homm3.creature.genie",
      "UpgradedCreature_id": "homm3.creature.master.genie"
    },
    {
      "_key": "homm3.creature-upgrade.naga.to.naga.queen",
      "Game_id": "homm3.game",
      "BaseCreature_id": "homm3.creature.naga",
      "UpgradedCreature_id": "homm3.creature.naga.queen"
    },
    {
      "_key": "homm3.creature-upgrade.giant.to.titan",
      "Game_id": "homm3.game",
      "BaseCreature_id": "homm3.creature.giant",
      "UpgradedCreature_id": "homm3.creature.titan"
    },
    {
      "_key": "homm3.creature-upgrade.centaur.to.centaur.captain",
      "Game_id": "homm3.game",
      "BaseCreature_id": "homm3.creature.centaur",
      "UpgradedCreature_id": "homm3.creature.centaur.captain"
    },
    {
      "_key": "homm3.creature-upgrade.dwarf.to.battle.dwarf",
      "Game_id": "homm3.game",
      "BaseCreature_id": "homm3.creature.dwarf",
      "UpgradedCreature_id": "homm3.creature.battle.dwarf"
    },
    {
      "_key": "homm3.creature-upgrade.wood.elf.to.grand.elf",
      "Game_id": "homm3.game",
      "BaseCreature_id": "homm3.creature.wood.elf",
      "UpgradedCreature_id": "homm3.creature.grand.elf"
    },
    {
      "_key": "homm3.creature-upgrade.pegasus.to.silver.pegasus",
      "Game_id": "homm3.game",
      "BaseCreature_id": "homm3.creature.pegasus",
      "UpgradedCreature_id": "homm3.creature.silver.pegasus"
    },
    {
      "_key": "homm3.creature-upgrade.dendroid.guard.to.dendroid.soldier",
      "Game_id": "homm3.game",
      "BaseCreature_id": "homm3.creature.dendroid.guard",
      "UpgradedCreature_id": "homm3.creature.dendroid.soldier"
    },
    {
      "_key": "homm3.creature-upgrade.unicorn.to.war.unicorn",
      "Game_id": "homm3.game",
      "BaseCreature_id": "homm3.creature.unicorn",
      "UpgradedCreature_id": "homm3.creature.war.unicorn"
    },
    {
      "_key": "homm3.creature-upgrade.green.dragon.to.gold.dragon",
      "Game_id": "homm3.game",
      "BaseCreature_id": "homm3.creature.green.dragon",
      "UpgradedCreature_id": "homm3.creature.gold.dragon"
    },
    {
      "_key": "homm3.creature-upgrade.imp.to.familiar",
      "Game_id": "homm3.game",
      "BaseCreature_id": "homm3.creature.imp",
      "UpgradedCreature_id": "homm3.creature.familiar"
    },
    {
      "_key": "homm3.creature-upgrade.gog.to.magog",
      "Game_id": "homm3.game",
      "BaseCreature_id": "homm3.creature.gog",
      "UpgradedCreature_id": "homm3.creature.magog"
    },
    {
      "_key": "homm3.creature-upgrade.hell.hound.to.cerberus",
      "Game_id": "homm3.game",
      "BaseCreature_id": "homm3.creature.hell.hound",
      "UpgradedCreature_id": "homm3.creature.cerberus"
    },
    {
      "_key": "homm3.creature-upgrade.demon.to.horned.demon",
      "Game_id": "homm3.game",
      "BaseCreature_id": "homm3.creature.demon",
      "UpgradedCreature_id": "homm3.creature.horned.demon"
    },
    {
      "_key": "homm3.creature-upgrade.pit.fiend.to.pit.lord",
      "Game_id": "homm3.game",
      "BaseCreature_id": "homm3.creature.pit.fiend",
      "UpgradedCreature_id": "homm3.creature.pit.lord"
    },
    {
      "_key": "homm3.creature-upgrade.efreeti.to.efreet.sultan",
      "Game_id": "homm3.game",
      "BaseCreature_id": "homm3.creature.efreeti",
      "UpgradedCreature_id": "homm3.creature.efreet.sultan"
    },
    {
      "_key": "homm3.creature-upgrade.devil.to.arch.devil",
      "Game_id": "homm3.game",
      "BaseCreature_id": "homm3.creature.devil",
      "UpgradedCreature_id": "homm3.creature.arch.devil"
    },
    {
      "_key": "homm3.creature-upgrade.skeleton.to.skeleton.warrior",
      "Game_id": "homm3.game",
      "BaseCreature_id": "homm3.creature.skeleton",
      "UpgradedCreature_id": "homm3.creature.skeleton.warrior"
    },
    {
      "_key": "homm3.creature-upgrade.walking.dead.to.zombie",
      "Game_id": "homm3.game",
      "BaseCreature_id": "homm3.creature.walking.dead",
      "UpgradedCreature_id": "homm3.creature.zombie"
    },
    {
      "_key": "homm3.creature-upgrade.wight.to.wraith",
      "Game_id": "homm3.game",
      "BaseCreature_id": "homm3.creature.wight",
      "UpgradedCreature_id": "homm3.creature.wraith"
    },
    {
      "_key": "homm3.creature-upgrade.vampire.to.vampire.lord",
      "Game_id": "homm3.game",
      "BaseCreature_id": "homm3.creature.vampire",
      "UpgradedCreature_id": "homm3.creature.vampire.lord"
    },
    {
      "_key": "homm3.creature-upgrade.lich.to.power.lich",
      "Game_id": "homm3.game",
      "BaseCreature_id": "homm3.creature.lich",
      "UpgradedCreature_id": "homm3.creature.power.lich"
    },
    {
      "_key": "homm3.creature-upgrade.black.knight.to.dread.knight",
      "Game_id": "homm3.game",
      "BaseCreature_id": "homm3.creature.black.knight",
      "UpgradedCreature_id": "homm3.creature.dread.knight"
    },
    {
      "_key": "homm3.creature-upgrade.bone.dragon.to.ghost.dragon",
      "Game_id": "homm3.game",
      "BaseCreature_id": "homm3.creature.bone.dragon",
      "UpgradedCreature_id": "homm3.creature.ghost.dragon"
    },
    {
      "_key": "homm3.creature-upgrade.troglodyte.to.infernal.troglodyte",
      "Game_id": "homm3.game",
      "BaseCreature_id": "homm3.creature.troglodyte",
      "UpgradedCreature_id": "homm3.creature.infernal.troglodyte"
    },
    {
      "_key": "homm3.creature-upgrade.harpy.to.harpy.hag",
      "Game_id": "homm3.game",
      "BaseCreature_id": "homm3.creature.harpy",
      "UpgradedCreature_id": "homm3.creature.harpy.hag"
    },
    {
      "_key": "homm3.creature-upgrade.beholder.to.evil.eye",
      "Game_id": "homm3.game",
      "BaseCreature_id": "homm3.creature.beholder",
      "UpgradedCreature_id": "homm3.creature.evil.eye"
    },
    {
      "_key": "homm3.creature-upgrade.medusa.to.medusa.queen",
      "Game_id": "homm3.game",
      "BaseCreature_id": "homm3.creature.medusa",
      "UpgradedCreature_id": "homm3.creature.medusa.queen"
    },
    {
      "_key": "homm3.creature-upgrade.minotaur.to.minotaur.king",
      "Game_id": "homm3.game",
      "BaseCreature_id": "homm3.creature.minotaur",
      "UpgradedCreature_id": "homm3.creature.minotaur.king"
    },
    {
      "_key": "homm3.creature-upgrade.manticore.to.scorpicore",
      "Game_id": "homm3.game",
      "BaseCreature_id": "homm3.creature.manticore",
      "UpgradedCreature_id": "homm3.creature.scorpicore"
    },
    {
      "_key": "homm3.creature-upgrade.red.dragon.to.black.dragon",
      "Game_id": "homm3.game",
      "BaseCreature_id": "homm3.creature.red.dragon",
      "UpgradedCreature_id": "homm3.creature.black.dragon"
    },
    {
      "_key": "homm3.creature-upgrade.goblin.to.hobgoblin",
      "Game_id": "homm3.game",
      "BaseCreature_id": "homm3.creature.goblin",
      "UpgradedCreature_id": "homm3.creature.hobgoblin"
    },
    {
      "_key": "homm3.creature-upgrade.wolf.rider.to.wolf.raider",
      "Game_id": "homm3.game",
      "BaseCreature_id": "homm3.creature.wolf.rider",
      "UpgradedCreature_id": "homm3.creature.wolf.raider"
    },
    {
      "_key": "homm3.creature-upgrade.orc.to.orc.chieftain",
      "Game_id": "homm3.game",
      "BaseCreature_id": "homm3.creature.orc",
      "UpgradedCreature_id": "homm3.creature.orc.chieftain"
    },
    {
      "_key": "homm3.creature-upgrade.ogre.to.ogre.mage",
      "Game_id": "homm3.game",
      "BaseCreature_id": "homm3.creature.ogre",
      "UpgradedCreature_id": "homm3.creature.ogre.mage"
    },
    {
      "_key": "homm3.creature-upgrade.roc.to.thunderbird",
      "Game_id": "homm3.game",
      "BaseCreature_id": "homm3.creature.roc",
      "UpgradedCreature_id": "homm3.creature.thunderbird"
    },
    {
      "_key": "homm3.creature-upgrade.cyclops.to.cyclops.king",
      "Game_id": "homm3.game",
      "BaseCreature_id": "homm3.creature.cyclops",
      "UpgradedCreature_id": "homm3.creature.cyclops.king"
    },
    {
      "_key": "homm3.creature-upgrade.behemoth.to.ancient.behemoth",
      "Game_id": "homm3.game",
      "BaseCreature_id": "homm3.creature.behemoth",
      "UpgradedCreature_id": "homm3.creature.ancient.behemoth"
    },
    {
      "_key": "homm3.creature-upgrade.gnoll.to.gnoll.marauder",
      "Game_id": "homm3.game",
      "BaseCreature_id": "homm3.creature.gnoll",
      "UpgradedCreature_id": "homm3.creature.gnoll.marauder"
    },
    {
      "_key": "homm3.creature-upgrade.lizardman.to.lizard.warrior",
      "Game_id": "homm3.game",
      "BaseCreature_id": "homm3.creature.lizardman",
      "UpgradedCreature_id": "homm3.creature.lizard.warrior"
    },
    {
      "_key": "homm3.creature-upgrade.serpent.fly.to.dragon.fly",
      "Game_id": "homm3.game",
      "BaseCreature_id": "homm3.creature.serpent.fly",
      "UpgradedCreature_id": "homm3.creature.dragon.fly"
    },
    {
      "_key": "homm3.creature-upgrade.basilisk.to.greater.basilisk",
      "Game_id": "homm3.game",
      "BaseCreature_id": "homm3.creature.basilisk",
      "UpgradedCreature_id": "homm3.creature.greater.basilisk"
    },
    {
      "_key": "homm3.creature-upgrade.gorgon.to.mighty.gorgon",
      "Game_id": "homm3.game",
      "BaseCreature_id": "homm3.creature.gorgon",
      "UpgradedCreature_id": "homm3.creature.mighty.gorgon"
    },
    {
      "_key": "homm3.creature-upgrade.wyvern.to.wyvern.monarch",
      "Game_id": "homm3.game",
      "BaseCreature_id": "homm3.creature.wyvern",
      "UpgradedCreature_id": "homm3.creature.wyvern.monarch"
    },
    {
      "_key": "homm3.creature-upgrade.hydra.to.chaos.hydra",
      "Game_id": "homm3.game",
      "BaseCreature_id": "homm3.creature.hydra",
      "UpgradedCreature_id": "homm3.creature.chaos.hydra"
    },
    {
      "_key": "homm3.creature-upgrade.pixie.to.sprite",
      "Game_id": "homm3.game",
      "BaseCreature_id": "homm3.creature.pixie",
      "UpgradedCreature_id": "homm3.creature.sprite"
    },
    {
      "_key": "homm3.creature-upgrade.air.elemental.to.storm.elemental",
      "Game_id": "homm3.game",
      "BaseCreature_id": "homm3.creature.air.elemental",
      "UpgradedCreature_id": "homm3.creature.storm.elemental"
    },
    {
      "_key": "homm3.creature-upgrade.water.elemental.to.ice.elemental",
      "Game_id": "homm3.game",
      "BaseCreature_id": "homm3.creature.water.elemental",
      "UpgradedCreature_id": "homm3.creature.ice.elemental"
    },
    {
      "_key": "homm3.creature-upgrade.fire.elemental.to.energy.elemental",
      "Game_id": "homm3.game",
      "BaseCreature_id": "homm3.creature.fire.elemental",
      "UpgradedCreature_id": "homm3.creature.energy.elemental"
    },
    {
      "_key": "homm3.creature-upgrade.earth.elemental.to.magma.elemental",
      "Game_id": "homm3.game",
      "BaseCreature_id": "homm3.creature.earth.elemental",
      "UpgradedCreature_id": "homm3.creature.magma.elemental"
    },
    {
      "_key": "homm3.creature-upgrade.psychic.elemental.to.magic.elemental",
      "Game_id": "homm3.game",
      "BaseCreature_id": "homm3.creature.psychic.elemental",
      "UpgradedCreature_id": "homm3.creature.magic.elemental"
    },
    {
      "_key": "homm3.creature-upgrade.firebird.to.phoenix",
      "Game_id": "homm3.game",
      "BaseCreature_id": "homm3.creature.firebird",
      "UpgradedCreature_id": "homm3.creature.phoenix"
    }
  ],
  "CreatureResourceCost": [
    {
      "_key": "homm3.creature-cost.pikeman.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.pikeman",
      "Resource_id": "resource.gold",
      "Amount": 60
    },
    {
      "_key": "homm3.creature-cost.halberdier.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.halberdier",
      "Resource_id": "resource.gold",
      "Amount": 75
    },
    {
      "_key": "homm3.creature-cost.archer.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.archer",
      "Resource_id": "resource.gold",
      "Amount": 100
    },
    {
      "_key": "homm3.creature-cost.marksman.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.marksman",
      "Resource_id": "resource.gold",
      "Amount": 150
    },
    {
      "_key": "homm3.creature-cost.griffin.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.griffin",
      "Resource_id": "resource.gold",
      "Amount": 200
    },
    {
      "_key": "homm3.creature-cost.royal.griffin.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.royal.griffin",
      "Resource_id": "resource.gold",
      "Amount": 240
    },
    {
      "_key": "homm3.creature-cost.swordsman.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.swordsman",
      "Resource_id": "resource.gold",
      "Amount": 300
    },
    {
      "_key": "homm3.creature-cost.crusader.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.crusader",
      "Resource_id": "resource.gold",
      "Amount": 400
    },
    {
      "_key": "homm3.creature-cost.monk.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.monk",
      "Resource_id": "resource.gold",
      "Amount": 400
    },
    {
      "_key": "homm3.creature-cost.zealot.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.zealot",
      "Resource_id": "resource.gold",
      "Amount": 450
    },
    {
      "_key": "homm3.creature-cost.cavalier.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.cavalier",
      "Resource_id": "resource.gold",
      "Amount": 1000
    },
    {
      "_key": "homm3.creature-cost.champion.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.champion",
      "Resource_id": "resource.gold",
      "Amount": 1200
    },
    {
      "_key": "homm3.creature-cost.angel.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.angel",
      "Resource_id": "resource.gold",
      "Amount": 3000
    },
    {
      "_key": "homm3.creature-cost.angel.gems",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.angel",
      "Resource_id": "resource.gems",
      "Amount": 1
    },
    {
      "_key": "homm3.creature-cost.archangel.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.archangel",
      "Resource_id": "resource.gold",
      "Amount": 5000
    },
    {
      "_key": "homm3.creature-cost.archangel.gems",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.archangel",
      "Resource_id": "resource.gems",
      "Amount": 3
    },
    {
      "_key": "homm3.creature-cost.gremlin.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.gremlin",
      "Resource_id": "resource.gold",
      "Amount": 30
    },
    {
      "_key": "homm3.creature-cost.master.gremlin.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.master.gremlin",
      "Resource_id": "resource.gold",
      "Amount": 40
    },
    {
      "_key": "homm3.creature-cost.stone.gargoyle.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.stone.gargoyle",
      "Resource_id": "resource.gold",
      "Amount": 130
    },
    {
      "_key": "homm3.creature-cost.obsidian.gargoyle.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.obsidian.gargoyle",
      "Resource_id": "resource.gold",
      "Amount": 160
    },
    {
      "_key": "homm3.creature-cost.stone.golem.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.stone.golem",
      "Resource_id": "resource.gold",
      "Amount": 150
    },
    {
      "_key": "homm3.creature-cost.iron.golem.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.iron.golem",
      "Resource_id": "resource.gold",
      "Amount": 200
    },
    {
      "_key": "homm3.creature-cost.mage.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.mage",
      "Resource_id": "resource.gold",
      "Amount": 350
    },
    {
      "_key": "homm3.creature-cost.arch.mage.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.arch.mage",
      "Resource_id": "resource.gold",
      "Amount": 450
    },
    {
      "_key": "homm3.creature-cost.genie.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.genie",
      "Resource_id": "resource.gold",
      "Amount": 550
    },
    {
      "_key": "homm3.creature-cost.master.genie.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.master.genie",
      "Resource_id": "resource.gold",
      "Amount": 600
    },
    {
      "_key": "homm3.creature-cost.naga.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.naga",
      "Resource_id": "resource.gold",
      "Amount": 1100
    },
    {
      "_key": "homm3.creature-cost.naga.queen.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.naga.queen",
      "Resource_id": "resource.gold",
      "Amount": 1600
    },
    {
      "_key": "homm3.creature-cost.giant.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.giant",
      "Resource_id": "resource.gold",
      "Amount": 2000
    },
    {
      "_key": "homm3.creature-cost.giant.gems",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.giant",
      "Resource_id": "resource.gems",
      "Amount": 1
    },
    {
      "_key": "homm3.creature-cost.titan.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.titan",
      "Resource_id": "resource.gold",
      "Amount": 5000
    },
    {
      "_key": "homm3.creature-cost.titan.gems",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.titan",
      "Resource_id": "resource.gems",
      "Amount": 2
    },
    {
      "_key": "homm3.creature-cost.centaur.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.centaur",
      "Resource_id": "resource.gold",
      "Amount": 70
    },
    {
      "_key": "homm3.creature-cost.centaur.captain.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.centaur.captain",
      "Resource_id": "resource.gold",
      "Amount": 90
    },
    {
      "_key": "homm3.creature-cost.dwarf.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.dwarf",
      "Resource_id": "resource.gold",
      "Amount": 120
    },
    {
      "_key": "homm3.creature-cost.battle.dwarf.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.battle.dwarf",
      "Resource_id": "resource.gold",
      "Amount": 150
    },
    {
      "_key": "homm3.creature-cost.wood.elf.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.wood.elf",
      "Resource_id": "resource.gold",
      "Amount": 200
    },
    {
      "_key": "homm3.creature-cost.grand.elf.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.grand.elf",
      "Resource_id": "resource.gold",
      "Amount": 225
    },
    {
      "_key": "homm3.creature-cost.pegasus.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.pegasus",
      "Resource_id": "resource.gold",
      "Amount": 250
    },
    {
      "_key": "homm3.creature-cost.silver.pegasus.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.silver.pegasus",
      "Resource_id": "resource.gold",
      "Amount": 275
    },
    {
      "_key": "homm3.creature-cost.dendroid.guard.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.dendroid.guard",
      "Resource_id": "resource.gold",
      "Amount": 350
    },
    {
      "_key": "homm3.creature-cost.dendroid.soldier.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.dendroid.soldier",
      "Resource_id": "resource.gold",
      "Amount": 425
    },
    {
      "_key": "homm3.creature-cost.unicorn.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.unicorn",
      "Resource_id": "resource.gold",
      "Amount": 850
    },
    {
      "_key": "homm3.creature-cost.war.unicorn.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.war.unicorn",
      "Resource_id": "resource.gold",
      "Amount": 950
    },
    {
      "_key": "homm3.creature-cost.green.dragon.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.green.dragon",
      "Resource_id": "resource.gold",
      "Amount": 2400
    },
    {
      "_key": "homm3.creature-cost.green.dragon.crystal",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.green.dragon",
      "Resource_id": "resource.crystal",
      "Amount": 1
    },
    {
      "_key": "homm3.creature-cost.gold.dragon.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.gold.dragon",
      "Resource_id": "resource.gold",
      "Amount": 4000
    },
    {
      "_key": "homm3.creature-cost.gold.dragon.crystal",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.gold.dragon",
      "Resource_id": "resource.crystal",
      "Amount": 2
    },
    {
      "_key": "homm3.creature-cost.imp.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.imp",
      "Resource_id": "resource.gold",
      "Amount": 50
    },
    {
      "_key": "homm3.creature-cost.familiar.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.familiar",
      "Resource_id": "resource.gold",
      "Amount": 60
    },
    {
      "_key": "homm3.creature-cost.gog.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.gog",
      "Resource_id": "resource.gold",
      "Amount": 125
    },
    {
      "_key": "homm3.creature-cost.magog.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.magog",
      "Resource_id": "resource.gold",
      "Amount": 175
    },
    {
      "_key": "homm3.creature-cost.hell.hound.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.hell.hound",
      "Resource_id": "resource.gold",
      "Amount": 200
    },
    {
      "_key": "homm3.creature-cost.cerberus.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.cerberus",
      "Resource_id": "resource.gold",
      "Amount": 250
    },
    {
      "_key": "homm3.creature-cost.demon.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.demon",
      "Resource_id": "resource.gold",
      "Amount": 250
    },
    {
      "_key": "homm3.creature-cost.horned.demon.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.horned.demon",
      "Resource_id": "resource.gold",
      "Amount": 270
    },
    {
      "_key": "homm3.creature-cost.pit.fiend.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.pit.fiend",
      "Resource_id": "resource.gold",
      "Amount": 500
    },
    {
      "_key": "homm3.creature-cost.pit.lord.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.pit.lord",
      "Resource_id": "resource.gold",
      "Amount": 700
    },
    {
      "_key": "homm3.creature-cost.efreeti.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.efreeti",
      "Resource_id": "resource.gold",
      "Amount": 900
    },
    {
      "_key": "homm3.creature-cost.efreet.sultan.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.efreet.sultan",
      "Resource_id": "resource.gold",
      "Amount": 1100
    },
    {
      "_key": "homm3.creature-cost.devil.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.devil",
      "Resource_id": "resource.gold",
      "Amount": 2700
    },
    {
      "_key": "homm3.creature-cost.devil.mercury",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.devil",
      "Resource_id": "resource.mercury",
      "Amount": 1
    },
    {
      "_key": "homm3.creature-cost.arch.devil.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.arch.devil",
      "Resource_id": "resource.gold",
      "Amount": 4500
    },
    {
      "_key": "homm3.creature-cost.arch.devil.mercury",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.arch.devil",
      "Resource_id": "resource.mercury",
      "Amount": 2
    },
    {
      "_key": "homm3.creature-cost.skeleton.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.skeleton",
      "Resource_id": "resource.gold",
      "Amount": 60
    },
    {
      "_key": "homm3.creature-cost.skeleton.warrior.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.skeleton.warrior",
      "Resource_id": "resource.gold",
      "Amount": 70
    },
    {
      "_key": "homm3.creature-cost.walking.dead.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.walking.dead",
      "Resource_id": "resource.gold",
      "Amount": 100
    },
    {
      "_key": "homm3.creature-cost.zombie.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.zombie",
      "Resource_id": "resource.gold",
      "Amount": 125
    },
    {
      "_key": "homm3.creature-cost.wight.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.wight",
      "Resource_id": "resource.gold",
      "Amount": 200
    },
    {
      "_key": "homm3.creature-cost.wraith.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.wraith",
      "Resource_id": "resource.gold",
      "Amount": 230
    },
    {
      "_key": "homm3.creature-cost.vampire.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.vampire",
      "Resource_id": "resource.gold",
      "Amount": 360
    },
    {
      "_key": "homm3.creature-cost.vampire.lord.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.vampire.lord",
      "Resource_id": "resource.gold",
      "Amount": 500
    },
    {
      "_key": "homm3.creature-cost.lich.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.lich",
      "Resource_id": "resource.gold",
      "Amount": 550
    },
    {
      "_key": "homm3.creature-cost.power.lich.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.power.lich",
      "Resource_id": "resource.gold",
      "Amount": 600
    },
    {
      "_key": "homm3.creature-cost.black.knight.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.black.knight",
      "Resource_id": "resource.gold",
      "Amount": 1200
    },
    {
      "_key": "homm3.creature-cost.dread.knight.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.dread.knight",
      "Resource_id": "resource.gold",
      "Amount": 1500
    },
    {
      "_key": "homm3.creature-cost.bone.dragon.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.bone.dragon",
      "Resource_id": "resource.gold",
      "Amount": 1800
    },
    {
      "_key": "homm3.creature-cost.ghost.dragon.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.ghost.dragon",
      "Resource_id": "resource.gold",
      "Amount": 3000
    },
    {
      "_key": "homm3.creature-cost.ghost.dragon.mercury",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.ghost.dragon",
      "Resource_id": "resource.mercury",
      "Amount": 1
    },
    {
      "_key": "homm3.creature-cost.troglodyte.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.troglodyte",
      "Resource_id": "resource.gold",
      "Amount": 50
    },
    {
      "_key": "homm3.creature-cost.infernal.troglodyte.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.infernal.troglodyte",
      "Resource_id": "resource.gold",
      "Amount": 65
    },
    {
      "_key": "homm3.creature-cost.harpy.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.harpy",
      "Resource_id": "resource.gold",
      "Amount": 130
    },
    {
      "_key": "homm3.creature-cost.harpy.hag.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.harpy.hag",
      "Resource_id": "resource.gold",
      "Amount": 170
    },
    {
      "_key": "homm3.creature-cost.beholder.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.beholder",
      "Resource_id": "resource.gold",
      "Amount": 250
    },
    {
      "_key": "homm3.creature-cost.evil.eye.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.evil.eye",
      "Resource_id": "resource.gold",
      "Amount": 280
    },
    {
      "_key": "homm3.creature-cost.medusa.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.medusa",
      "Resource_id": "resource.gold",
      "Amount": 300
    },
    {
      "_key": "homm3.creature-cost.medusa.queen.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.medusa.queen",
      "Resource_id": "resource.gold",
      "Amount": 330
    },
    {
      "_key": "homm3.creature-cost.minotaur.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.minotaur",
      "Resource_id": "resource.gold",
      "Amount": 500
    },
    {
      "_key": "homm3.creature-cost.minotaur.king.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.minotaur.king",
      "Resource_id": "resource.gold",
      "Amount": 575
    },
    {
      "_key": "homm3.creature-cost.manticore.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.manticore",
      "Resource_id": "resource.gold",
      "Amount": 850
    },
    {
      "_key": "homm3.creature-cost.scorpicore.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.scorpicore",
      "Resource_id": "resource.gold",
      "Amount": 1050
    },
    {
      "_key": "homm3.creature-cost.red.dragon.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.red.dragon",
      "Resource_id": "resource.gold",
      "Amount": 2500
    },
    {
      "_key": "homm3.creature-cost.red.dragon.sulfur",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.red.dragon",
      "Resource_id": "resource.sulfur",
      "Amount": 1
    },
    {
      "_key": "homm3.creature-cost.black.dragon.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.black.dragon",
      "Resource_id": "resource.gold",
      "Amount": 4000
    },
    {
      "_key": "homm3.creature-cost.black.dragon.sulfur",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.black.dragon",
      "Resource_id": "resource.sulfur",
      "Amount": 2
    },
    {
      "_key": "homm3.creature-cost.goblin.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.goblin",
      "Resource_id": "resource.gold",
      "Amount": 40
    },
    {
      "_key": "homm3.creature-cost.hobgoblin.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.hobgoblin",
      "Resource_id": "resource.gold",
      "Amount": 50
    },
    {
      "_key": "homm3.creature-cost.wolf.rider.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.wolf.rider",
      "Resource_id": "resource.gold",
      "Amount": 100
    },
    {
      "_key": "homm3.creature-cost.wolf.raider.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.wolf.raider",
      "Resource_id": "resource.gold",
      "Amount": 140
    },
    {
      "_key": "homm3.creature-cost.orc.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.orc",
      "Resource_id": "resource.gold",
      "Amount": 150
    },
    {
      "_key": "homm3.creature-cost.orc.chieftain.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.orc.chieftain",
      "Resource_id": "resource.gold",
      "Amount": 165
    },
    {
      "_key": "homm3.creature-cost.ogre.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.ogre",
      "Resource_id": "resource.gold",
      "Amount": 300
    },
    {
      "_key": "homm3.creature-cost.ogre.mage.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.ogre.mage",
      "Resource_id": "resource.gold",
      "Amount": 400
    },
    {
      "_key": "homm3.creature-cost.roc.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.roc",
      "Resource_id": "resource.gold",
      "Amount": 600
    },
    {
      "_key": "homm3.creature-cost.thunderbird.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.thunderbird",
      "Resource_id": "resource.gold",
      "Amount": 700
    },
    {
      "_key": "homm3.creature-cost.cyclops.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.cyclops",
      "Resource_id": "resource.gold",
      "Amount": 750
    },
    {
      "_key": "homm3.creature-cost.cyclops.king.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.cyclops.king",
      "Resource_id": "resource.gold",
      "Amount": 1100
    },
    {
      "_key": "homm3.creature-cost.behemoth.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.behemoth",
      "Resource_id": "resource.gold",
      "Amount": 1500
    },
    {
      "_key": "homm3.creature-cost.ancient.behemoth.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.ancient.behemoth",
      "Resource_id": "resource.gold",
      "Amount": 3000
    },
    {
      "_key": "homm3.creature-cost.ancient.behemoth.crystal",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.ancient.behemoth",
      "Resource_id": "resource.crystal",
      "Amount": 1
    },
    {
      "_key": "homm3.creature-cost.gnoll.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.gnoll",
      "Resource_id": "resource.gold",
      "Amount": 50
    },
    {
      "_key": "homm3.creature-cost.gnoll.marauder.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.gnoll.marauder",
      "Resource_id": "resource.gold",
      "Amount": 70
    },
    {
      "_key": "homm3.creature-cost.lizardman.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.lizardman",
      "Resource_id": "resource.gold",
      "Amount": 110
    },
    {
      "_key": "homm3.creature-cost.lizard.warrior.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.lizard.warrior",
      "Resource_id": "resource.gold",
      "Amount": 140
    },
    {
      "_key": "homm3.creature-cost.serpent.fly.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.serpent.fly",
      "Resource_id": "resource.gold",
      "Amount": 220
    },
    {
      "_key": "homm3.creature-cost.dragon.fly.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.dragon.fly",
      "Resource_id": "resource.gold",
      "Amount": 240
    },
    {
      "_key": "homm3.creature-cost.basilisk.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.basilisk",
      "Resource_id": "resource.gold",
      "Amount": 325
    },
    {
      "_key": "homm3.creature-cost.greater.basilisk.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.greater.basilisk",
      "Resource_id": "resource.gold",
      "Amount": 400
    },
    {
      "_key": "homm3.creature-cost.gorgon.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.gorgon",
      "Resource_id": "resource.gold",
      "Amount": 525
    },
    {
      "_key": "homm3.creature-cost.mighty.gorgon.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.mighty.gorgon",
      "Resource_id": "resource.gold",
      "Amount": 600
    },
    {
      "_key": "homm3.creature-cost.wyvern.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.wyvern",
      "Resource_id": "resource.gold",
      "Amount": 800
    },
    {
      "_key": "homm3.creature-cost.wyvern.monarch.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.wyvern.monarch",
      "Resource_id": "resource.gold",
      "Amount": 1100
    },
    {
      "_key": "homm3.creature-cost.hydra.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.hydra",
      "Resource_id": "resource.gold",
      "Amount": 2200
    },
    {
      "_key": "homm3.creature-cost.chaos.hydra.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.chaos.hydra",
      "Resource_id": "resource.gold",
      "Amount": 3500
    },
    {
      "_key": "homm3.creature-cost.chaos.hydra.sulfur",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.chaos.hydra",
      "Resource_id": "resource.sulfur",
      "Amount": 1
    },
    {
      "_key": "homm3.creature-cost.pixie.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.pixie",
      "Resource_id": "resource.gold",
      "Amount": 25
    },
    {
      "_key": "homm3.creature-cost.sprite.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.sprite",
      "Resource_id": "resource.gold",
      "Amount": 30
    },
    {
      "_key": "homm3.creature-cost.air.elemental.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.air.elemental",
      "Resource_id": "resource.gold",
      "Amount": 250
    },
    {
      "_key": "homm3.creature-cost.storm.elemental.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.storm.elemental",
      "Resource_id": "resource.gold",
      "Amount": 275
    },
    {
      "_key": "homm3.creature-cost.water.elemental.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.water.elemental",
      "Resource_id": "resource.gold",
      "Amount": 300
    },
    {
      "_key": "homm3.creature-cost.ice.elemental.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.ice.elemental",
      "Resource_id": "resource.gold",
      "Amount": 375
    },
    {
      "_key": "homm3.creature-cost.fire.elemental.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.fire.elemental",
      "Resource_id": "resource.gold",
      "Amount": 350
    },
    {
      "_key": "homm3.creature-cost.energy.elemental.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.energy.elemental",
      "Resource_id": "resource.gold",
      "Amount": 400
    },
    {
      "_key": "homm3.creature-cost.earth.elemental.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.earth.elemental",
      "Resource_id": "resource.gold",
      "Amount": 400
    },
    {
      "_key": "homm3.creature-cost.magma.elemental.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.magma.elemental",
      "Resource_id": "resource.gold",
      "Amount": 500
    },
    {
      "_key": "homm3.creature-cost.psychic.elemental.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.psychic.elemental",
      "Resource_id": "resource.gold",
      "Amount": 750
    },
    {
      "_key": "homm3.creature-cost.magic.elemental.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.magic.elemental",
      "Resource_id": "resource.gold",
      "Amount": 800
    },
    {
      "_key": "homm3.creature-cost.firebird.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.firebird",
      "Resource_id": "resource.gold",
      "Amount": 1500
    },
    {
      "_key": "homm3.creature-cost.phoenix.gold",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.phoenix",
      "Resource_id": "resource.gold",
      "Amount": 2000
    },
    {
      "_key": "homm3.creature-cost.phoenix.mercury",
      "Game_id": "homm3.game",
      "Creature_id": "homm3.creature.phoenix",
      "Resource_id": "resource.mercury",
      "Amount": 1
    }
  ]
}
$homm3_creatures_data$::JSONB;
    entry JSONB;
    resolved JSONB := '{}'::JSONB;
    current_id BIGINT;
    current_cid TEXT;
BEGIN
    -- Game: 1 existing prerequisites, resolved without changes.
    FOR entry IN SELECT value FROM jsonb_array_elements(batch -> 'Game') LOOP
        SELECT "Game_id" INTO STRICT current_id
        FROM heroes_watch."Game"
        WHERE "SeriesCode" = (entry ->> 'SeriesCode')
        FOR SHARE;
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

    -- Expansion: 3 existing prerequisites, resolved without changes.
    FOR entry IN SELECT value FROM jsonb_array_elements(batch -> 'Expansion') LOOP
        SELECT "Expansion_id" INTO STRICT current_id
        FROM heroes_watch."Expansion"
        WHERE "Game_id" = (resolved ->> (entry ->> 'Game_id'))::BIGINT AND "Code" = (entry ->> 'Code')
        FOR SHARE;
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

    -- Faction: 9 existing prerequisites, resolved without changes.
    FOR entry IN SELECT value FROM jsonb_array_elements(batch -> 'Faction') LOOP
        SELECT "Faction_id" INTO STRICT current_id
        FROM heroes_watch."Faction"
        WHERE "Game_id" = (resolved ->> (entry ->> 'Game_id'))::BIGINT AND "Code" = (entry ->> 'Code')
        FOR SHARE;
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

    -- Resource: 5 rows.
    FOR entry IN SELECT value FROM jsonb_array_elements(batch -> 'Resource') LOOP
        INSERT INTO heroes_watch."Resource" AS existing
            ("Code", "Name", "Description")
        VALUES (
            (entry ->> 'Code'),
            (entry ->> 'Name'),
            (entry ->> 'Description')
        )
        ON CONFLICT ("Code") DO UPDATE SET
            "Description" = COALESCE(existing."Description", EXCLUDED."Description");
        SELECT "Resource_id" INTO STRICT current_id
        FROM heroes_watch."Resource"
        WHERE "Code" = (entry ->> 'Code')
        FOR UPDATE;
        resolved := resolved || jsonb_build_object(entry ->> '_key', current_id);
        IF NOT EXISTS (
            SELECT 1 FROM heroes_watch."Resource"
            WHERE "Resource_id" = current_id
              AND "Code" IS NOT DISTINCT FROM (entry ->> 'Code')
              AND "Name" IS NOT DISTINCT FROM (entry ->> 'Name')
              AND (entry -> 'Description' = 'null'::JSONB OR "Description" IS NOT DISTINCT FROM (entry ->> 'Description'))
        ) THEN
            RAISE EXCEPTION 'Existing Resource conflicts with %; transaction aborted.', entry ->> '_key';
        END IF;
    END LOOP;

    -- GameResource: 5 rows.
    FOR entry IN SELECT value FROM jsonb_array_elements(batch -> 'GameResource') LOOP
        INSERT INTO heroes_watch."GameResource" AS existing
            ("GameResource_cid", "Game_id", "Resource_id", "DisplayName", "ResourceClass", "DisplayOrder", "MediaAsset_id", "IntroducedInExpansion_id")
        VALUES (
            (entry ->> '_key'),
            (resolved ->> (entry ->> 'Game_id'))::BIGINT,
            (resolved ->> (entry ->> 'Resource_id'))::BIGINT,
            (entry ->> 'DisplayName'),
            (entry ->> 'ResourceClass')::heroes_watch."Enum__GameResource__ResourceClass",
            (entry ->> 'DisplayOrder')::SMALLINT,
            (resolved ->> (entry ->> 'MediaAsset_id'))::BIGINT,
            (resolved ->> (entry ->> 'IntroducedInExpansion_id'))::BIGINT
        )
        ON CONFLICT ("Game_id", "Resource_id") DO UPDATE SET
            "DisplayName" = COALESCE(existing."DisplayName", EXCLUDED."DisplayName"),
            "ResourceClass" = COALESCE(existing."ResourceClass", EXCLUDED."ResourceClass"),
            "DisplayOrder" = COALESCE(existing."DisplayOrder", EXCLUDED."DisplayOrder"),
            "MediaAsset_id" = COALESCE(existing."MediaAsset_id", EXCLUDED."MediaAsset_id"),
            "IntroducedInExpansion_id" = COALESCE(existing."IntroducedInExpansion_id", EXCLUDED."IntroducedInExpansion_id");
        SELECT "GameResource_cid" INTO STRICT current_cid
        FROM heroes_watch."GameResource"
        WHERE "Game_id" = (resolved ->> (entry ->> 'Game_id'))::BIGINT AND "Resource_id" = (resolved ->> (entry ->> 'Resource_id'))::BIGINT
        FOR UPDATE;
        resolved := resolved || jsonb_build_object(entry ->> '_key', current_cid);
        IF NOT EXISTS (
            SELECT 1 FROM heroes_watch."GameResource"
            WHERE "GameResource_cid" = current_cid
              AND "Game_id" IS NOT DISTINCT FROM (resolved ->> (entry ->> 'Game_id'))::BIGINT
              AND "Resource_id" IS NOT DISTINCT FROM (resolved ->> (entry ->> 'Resource_id'))::BIGINT
              AND (entry -> 'DisplayName' = 'null'::JSONB OR "DisplayName" IS NOT DISTINCT FROM (entry ->> 'DisplayName'))
              AND (entry -> 'ResourceClass' = 'null'::JSONB OR "ResourceClass" IS NOT DISTINCT FROM (entry ->> 'ResourceClass')::heroes_watch."Enum__GameResource__ResourceClass")
              AND (entry -> 'DisplayOrder' = 'null'::JSONB OR "DisplayOrder" IS NOT DISTINCT FROM (entry ->> 'DisplayOrder')::SMALLINT)
              AND (entry -> 'MediaAsset_id' = 'null'::JSONB OR "MediaAsset_id" IS NOT DISTINCT FROM (resolved ->> (entry ->> 'MediaAsset_id'))::BIGINT)
              AND (entry -> 'IntroducedInExpansion_id' = 'null'::JSONB OR "IntroducedInExpansion_id" IS NOT DISTINCT FROM (resolved ->> (entry ->> 'IntroducedInExpansion_id'))::BIGINT)
        ) THEN
            RAISE EXCEPTION 'Existing GameResource conflicts with %; transaction aborted.', entry ->> '_key';
        END IF;
    END LOOP;

    -- Creature: 126 rows.
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

    -- CreatureHOMM3: 126 rows.
    FOR entry IN SELECT value FROM jsonb_array_elements(batch -> 'CreatureHOMM3') LOOP
        IF NOT EXISTS (
            SELECT 1 FROM heroes_watch."FactionHOMM3" fd
            WHERE fd."Faction_id" = (resolved ->> (entry ->> 'Faction_id'))::BIGINT
              AND fd."Alignment"::TEXT = entry ->> 'Alignment'
        ) THEN
            RAISE EXCEPTION 'Missing or conflicting Heroes III faction detail for %.', entry ->> '_key';
        END IF;
        INSERT INTO heroes_watch."CreatureHOMM3" AS existing
            ("Creature_id", "Faction_id", "Alignment", "Level", "Attack", "Defense", "DamageMin", "DamageMax", "Health", "Speed", "Movement", "Size", "Shots", "Growth", "AIValue", "GoldCost", "Recruitable", "DoubleUpgrade", "AlternativeUpgrade")
        VALUES (
            (resolved ->> (entry ->> '_key'))::BIGINT,
            (resolved ->> (entry ->> 'Faction_id'))::BIGINT,
            (entry ->> 'Alignment')::heroes_watch."Enum__CreatureHOMM3__Alignment",
            (entry ->> 'Level')::SMALLINT,
            (entry ->> 'Attack')::SMALLINT,
            (entry ->> 'Defense')::SMALLINT,
            (entry ->> 'DamageMin')::SMALLINT,
            (entry ->> 'DamageMax')::SMALLINT,
            (entry ->> 'Health')::INTEGER,
            (entry ->> 'Speed')::SMALLINT,
            (entry ->> 'Movement')::heroes_watch."Enum__CreatureHOMM3__Movement",
            (entry ->> 'Size')::SMALLINT,
            (entry ->> 'Shots')::SMALLINT,
            (entry ->> 'Growth')::SMALLINT,
            (entry ->> 'AIValue')::INTEGER,
            (entry ->> 'GoldCost')::INTEGER,
            (entry ->> 'Recruitable')::BOOLEAN,
            (entry ->> 'DoubleUpgrade')::BOOLEAN,
            (entry ->> 'AlternativeUpgrade')::BOOLEAN
        )
        ON CONFLICT ("Creature_id") DO UPDATE SET
            "Faction_id" = COALESCE(existing."Faction_id", EXCLUDED."Faction_id"),
            "Alignment" = COALESCE(existing."Alignment", EXCLUDED."Alignment"),
            "Level" = COALESCE(existing."Level", EXCLUDED."Level"),
            "Attack" = COALESCE(existing."Attack", EXCLUDED."Attack"),
            "Defense" = COALESCE(existing."Defense", EXCLUDED."Defense"),
            "DamageMin" = COALESCE(existing."DamageMin", EXCLUDED."DamageMin"),
            "DamageMax" = COALESCE(existing."DamageMax", EXCLUDED."DamageMax"),
            "Health" = COALESCE(existing."Health", EXCLUDED."Health"),
            "Speed" = COALESCE(existing."Speed", EXCLUDED."Speed"),
            "Movement" = COALESCE(existing."Movement", EXCLUDED."Movement"),
            "Size" = COALESCE(existing."Size", EXCLUDED."Size"),
            "Shots" = COALESCE(existing."Shots", EXCLUDED."Shots"),
            "Growth" = COALESCE(existing."Growth", EXCLUDED."Growth"),
            "AIValue" = COALESCE(existing."AIValue", EXCLUDED."AIValue"),
            "GoldCost" = COALESCE(existing."GoldCost", EXCLUDED."GoldCost"),
            "Recruitable" = COALESCE(existing."Recruitable", EXCLUDED."Recruitable");
        current_id := (resolved ->> (entry ->> '_key'))::BIGINT;
        IF NOT EXISTS (
            SELECT 1 FROM heroes_watch."CreatureHOMM3"
            WHERE "Creature_id" = current_id
              AND (entry -> 'Faction_id' = 'null'::JSONB OR "Faction_id" IS NOT DISTINCT FROM (resolved ->> (entry ->> 'Faction_id'))::BIGINT)
              AND (entry -> 'Alignment' = 'null'::JSONB OR "Alignment" IS NOT DISTINCT FROM (entry ->> 'Alignment')::heroes_watch."Enum__CreatureHOMM3__Alignment")
              AND (entry -> 'Level' = 'null'::JSONB OR "Level" IS NOT DISTINCT FROM (entry ->> 'Level')::SMALLINT)
              AND (entry -> 'Attack' = 'null'::JSONB OR "Attack" IS NOT DISTINCT FROM (entry ->> 'Attack')::SMALLINT)
              AND (entry -> 'Defense' = 'null'::JSONB OR "Defense" IS NOT DISTINCT FROM (entry ->> 'Defense')::SMALLINT)
              AND (entry -> 'DamageMin' = 'null'::JSONB OR "DamageMin" IS NOT DISTINCT FROM (entry ->> 'DamageMin')::SMALLINT)
              AND (entry -> 'DamageMax' = 'null'::JSONB OR "DamageMax" IS NOT DISTINCT FROM (entry ->> 'DamageMax')::SMALLINT)
              AND (entry -> 'Health' = 'null'::JSONB OR "Health" IS NOT DISTINCT FROM (entry ->> 'Health')::INTEGER)
              AND (entry -> 'Speed' = 'null'::JSONB OR "Speed" IS NOT DISTINCT FROM (entry ->> 'Speed')::SMALLINT)
              AND (entry -> 'Movement' = 'null'::JSONB OR "Movement" IS NOT DISTINCT FROM (entry ->> 'Movement')::heroes_watch."Enum__CreatureHOMM3__Movement")
              AND (entry -> 'Size' = 'null'::JSONB OR "Size" IS NOT DISTINCT FROM (entry ->> 'Size')::SMALLINT)
              AND (entry -> 'Shots' = 'null'::JSONB OR "Shots" IS NOT DISTINCT FROM (entry ->> 'Shots')::SMALLINT)
              AND (entry -> 'Growth' = 'null'::JSONB OR "Growth" IS NOT DISTINCT FROM (entry ->> 'Growth')::SMALLINT)
              AND (entry -> 'AIValue' = 'null'::JSONB OR "AIValue" IS NOT DISTINCT FROM (entry ->> 'AIValue')::INTEGER)
              AND (entry -> 'GoldCost' = 'null'::JSONB OR "GoldCost" IS NOT DISTINCT FROM (entry ->> 'GoldCost')::INTEGER)
              AND (entry -> 'Recruitable' = 'null'::JSONB OR "Recruitable" IS NOT DISTINCT FROM (entry ->> 'Recruitable')::BOOLEAN)
              AND "DoubleUpgrade" IS NOT DISTINCT FROM (entry ->> 'DoubleUpgrade')::BOOLEAN
              AND "AlternativeUpgrade" IS NOT DISTINCT FROM (entry ->> 'AlternativeUpgrade')::BOOLEAN
        ) THEN
            RAISE EXCEPTION 'Existing CreatureHOMM3 conflicts with %; transaction aborted.', entry ->> '_key';
        END IF;
    END LOOP;

    -- CreatureUpgrade: 63 rows.
    FOR entry IN SELECT value FROM jsonb_array_elements(batch -> 'CreatureUpgrade') LOOP
        INSERT INTO heroes_watch."CreatureUpgrade" AS existing
            ("CreatureUpgrade_cid", "Game_id", "BaseCreature_id", "UpgradedCreature_id")
        VALUES (
            (entry ->> '_key'),
            (resolved ->> (entry ->> 'Game_id'))::BIGINT,
            (resolved ->> (entry ->> 'BaseCreature_id'))::BIGINT,
            (resolved ->> (entry ->> 'UpgradedCreature_id'))::BIGINT
        )
        ON CONFLICT ("Game_id", "BaseCreature_id", "UpgradedCreature_id") DO NOTHING;
        SELECT "CreatureUpgrade_cid" INTO STRICT current_cid
        FROM heroes_watch."CreatureUpgrade"
        WHERE "Game_id" = (resolved ->> (entry ->> 'Game_id'))::BIGINT AND "BaseCreature_id" = (resolved ->> (entry ->> 'BaseCreature_id'))::BIGINT AND "UpgradedCreature_id" = (resolved ->> (entry ->> 'UpgradedCreature_id'))::BIGINT
        FOR UPDATE;
        resolved := resolved || jsonb_build_object(entry ->> '_key', current_cid);
        IF NOT EXISTS (
            SELECT 1 FROM heroes_watch."CreatureUpgrade"
            WHERE "CreatureUpgrade_cid" = current_cid
              AND "Game_id" IS NOT DISTINCT FROM (resolved ->> (entry ->> 'Game_id'))::BIGINT
              AND "BaseCreature_id" IS NOT DISTINCT FROM (resolved ->> (entry ->> 'BaseCreature_id'))::BIGINT
              AND "UpgradedCreature_id" IS NOT DISTINCT FROM (resolved ->> (entry ->> 'UpgradedCreature_id'))::BIGINT
        ) THEN
            RAISE EXCEPTION 'Existing CreatureUpgrade conflicts with %; transaction aborted.', entry ->> '_key';
        END IF;
    END LOOP;

    -- CreatureResourceCost: 140 rows.
    FOR entry IN SELECT value FROM jsonb_array_elements(batch -> 'CreatureResourceCost') LOOP
        INSERT INTO heroes_watch."CreatureResourceCost" AS existing
            ("CreatureResourceCost_cid", "Game_id", "Creature_id", "Resource_id", "Amount")
        VALUES (
            (entry ->> '_key'),
            (resolved ->> (entry ->> 'Game_id'))::BIGINT,
            (resolved ->> (entry ->> 'Creature_id'))::BIGINT,
            (resolved ->> (entry ->> 'Resource_id'))::BIGINT,
            (entry ->> 'Amount')::INTEGER
        )
        ON CONFLICT ("Game_id", "Creature_id", "Resource_id") DO NOTHING;
        SELECT "CreatureResourceCost_cid" INTO STRICT current_cid
        FROM heroes_watch."CreatureResourceCost"
        WHERE "Game_id" = (resolved ->> (entry ->> 'Game_id'))::BIGINT AND "Creature_id" = (resolved ->> (entry ->> 'Creature_id'))::BIGINT AND "Resource_id" = (resolved ->> (entry ->> 'Resource_id'))::BIGINT
        FOR UPDATE;
        resolved := resolved || jsonb_build_object(entry ->> '_key', current_cid);
        IF NOT EXISTS (
            SELECT 1 FROM heroes_watch."CreatureResourceCost"
            WHERE "CreatureResourceCost_cid" = current_cid
              AND "Game_id" IS NOT DISTINCT FROM (resolved ->> (entry ->> 'Game_id'))::BIGINT
              AND "Creature_id" IS NOT DISTINCT FROM (resolved ->> (entry ->> 'Creature_id'))::BIGINT
              AND "Resource_id" IS NOT DISTINCT FROM (resolved ->> (entry ->> 'Resource_id'))::BIGINT
              AND "Amount" IS NOT DISTINCT FROM (entry ->> 'Amount')::INTEGER
        ) THEN
            RAISE EXCEPTION 'Existing CreatureResourceCost conflicts with %; transaction aborted.', entry ->> '_key';
        END IF;
    END LOOP;

END
$homm3_creatures_import$;

SET CONSTRAINTS ALL IMMEDIATE;
COMMIT;

-- Read-only: expect 14 creatures and 7 upgrade links for each of the nine factions.
-- Cost rows include gold for every creature plus any rare-resource requirement.
WITH roster AS (
    SELECT f."Name", f."Code", c."Creature_id", g."Game_id",
           (SELECT COUNT(*) FROM heroes_watch."CreatureUpgrade" u
            WHERE u."Game_id" = g."Game_id" AND u."BaseCreature_id" = c."Creature_id") AS upgrades,
           (SELECT COUNT(*) FROM heroes_watch."CreatureResourceCost" rc
            WHERE rc."Game_id" = g."Game_id" AND rc."Creature_id" = c."Creature_id") AS costs,
           (
               num_nonnulls(d."Faction_id", d."Alignment", d."Level", d."Attack", d."Defense",
                   d."DamageMin", d."DamageMax", d."Health", d."Speed", d."Movement",
                   d."Size", d."Shots", d."Growth", d."AIValue", d."GoldCost",
                   d."Recruitable", d."DoubleUpgrade", d."AlternativeUpgrade") = 18
               AND d."Alignment"::TEXT = fd."Alignment"::TEXT
               AND d."Level" BETWEEN 1 AND 7
               AND d."DamageMin" <= d."DamageMax"
               AND d."Size" IN (1, 2)
               AND d."Recruitable" AND NOT d."DoubleUpgrade" AND NOT d."AlternativeUpgrade"
               AND e."Game_id" = g."Game_id"
               AND EXISTS (
                   SELECT 1 FROM heroes_watch."CreatureResourceCost" rc
                   JOIN heroes_watch."Resource" r ON r."Resource_id" = rc."Resource_id"
                   JOIN heroes_watch."GameResource" gr ON gr."Resource_id" = r."Resource_id"
                       AND gr."Game_id" = g."Game_id"
                   WHERE rc."Game_id" = g."Game_id" AND rc."Creature_id" = c."Creature_id"
                     AND r."Code" = 'GOLD' AND rc."Amount" = d."GoldCost"
               )
           ) AS valid
    FROM heroes_watch."Creature" c
    JOIN heroes_watch."Game" g ON g."Game_id" = c."Game_id"
    JOIN heroes_watch."CreatureHOMM3" d ON d."Creature_id" = c."Creature_id"
    JOIN heroes_watch."Faction" f ON f."Faction_id" = d."Faction_id" AND f."Game_id" = g."Game_id"
    JOIN heroes_watch."FactionHOMM3" fd ON fd."Faction_id" = f."Faction_id"
    JOIN heroes_watch."Expansion" e ON e."Expansion_id" = c."IntroducedInExpansion_id"
    WHERE g."SeriesCode" = 'HOMM3'
      AND f."Code" IN ('CASTLE','TOWER','RAMPART','INFERNO','NECROPOLIS','DUNGEON','STRONGHOLD','FORTRESS','CONFLUX')
)
SELECT "Name" AS "Faction", COUNT(*) AS "Creatures",
       SUM(upgrades) AS "Upgrade links", SUM(costs) AS "Cost rows",
       BOOL_AND(valid) AS "Valid details"
FROM roster
GROUP BY "Name", "Code"
ORDER BY array_position(ARRAY['CASTLE','TOWER','RAMPART','INFERNO','NECROPOLIS','DUNGEON','STRONGHOLD','FORTRESS','CONFLUX'], "Code");
