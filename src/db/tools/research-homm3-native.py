#!/usr/bin/env python3
"""Build the Heroes III native-source completion patch.

This script is read-only with respect to the installed game.  It extracts only
the requested LOD records in memory, verifies the existing campaign graph
against the original H3C prerequisite masks, and emits a reviewable patch.
"""

from __future__ import annotations

import argparse
import csv
import hashlib
import importlib.util
import io
import json
import re
import struct
import zlib
from collections import defaultdict
from pathlib import Path


ROOT = Path(__file__).resolve().parents[3]
DEFAULT_OUTPUT = ROOT / "src/db/research/2026-10-13/homm3.patch.json"
DEFAULT_RULES_OUTPUT = ROOT / "src/db/research/2026-10-13/homm3-rules.patch.json"


def load_lod_module():
    path = Path(__file__).with_name("extract-homm3-lod.py")
    spec = importlib.util.spec_from_file_location("heroes_watch_lod", path)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"cannot load {path}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


class Reader:
    def __init__(self, data: bytes):
        self.data = data
        self.position = 0

    def take(self, count: int) -> bytes:
        end = self.position + count
        if end > len(self.data):
            raise EOFError("campaign header ended unexpectedly")
        result = self.data[self.position:end]
        self.position = end
        return result

    def u8(self) -> int:
        return self.take(1)[0]

    def i8(self) -> int:
        return struct.unpack("<b", self.take(1))[0]

    def u16(self) -> int:
        return struct.unpack("<H", self.take(2))[0]

    def u32(self) -> int:
        return struct.unpack("<I", self.take(4))[0]

    def i32(self) -> int:
        return struct.unpack("<i", self.take(4))[0]

    def text(self) -> str:
        return self.take(self.u32()).decode("windows-1252")


def normalized(value: str) -> str:
    return re.sub(r"[^a-z0-9]", "", value.lower())


def gzip_blocks(blob: bytes) -> list[bytes]:
    blocks = []
    remaining = blob
    while remaining:
        inflater = zlib.decompressobj(16 + zlib.MAX_WBITS)
        block = inflater.decompress(remaining)
        if not inflater.eof:
            raise ValueError("campaign contains a truncated gzip member")
        blocks.append(block)
        if not inflater.unused_data:
            break
        remaining = inflater.unused_data
    return blocks


def read_position(reader: Reader) -> dict:
    return {"x": reader.u8(), "y": reader.u8(), "level": reader.u8()}


def parse_h3m_conditions(payload: bytes) -> dict:
    reader = Reader(payload)
    format_code = reader.u32()
    if format_code not in (14, 21, 28):
        raise ValueError(f"unsupported original H3M format {format_code}")
    level_ab = format_code >= 21
    level_sod = format_code >= 28
    faction_bytes = 2 if level_ab else 1
    reader.u8()  # any playable players
    size = reader.i32()
    reader.u8()  # underground layer flag
    map_name = reader.text()
    reader.text()  # copyrighted description is not retained
    difficulty = reader.u8()
    if level_ab:
        reader.u8()  # hero level limit
    for _ in range(8):
        reader.take(2)  # human/computer playability
        reader.i8()  # AI tactic
        if level_sod:
            reader.u8()  # unused faction-selectable flag
        reader.take(faction_bytes)
        reader.u8()  # random faction
        if reader.u8():  # main town
            if level_ab:
                reader.take(2)  # generate hero and unused town type
            reader.take(3)  # main town position
        reader.u8()  # random hero
        main_hero = reader.u8()
        if main_hero != 0xFF:
            reader.u8()  # portrait
            reader.text()  # custom name is not retained
        if level_ab:
            reader.u8()  # unused hero-placeholder count
            for _ in range(reader.u32()):
                reader.u8()  # hero ID
                reader.text()  # custom name is not retained

    victory_id = reader.i8()
    victory_names = {
        0: "AcquireArtifact", 1: "AccumulateCreatures", 2: "AccumulateResources", 3: "BuildTown",
        4: "BuildGrail", 5: "DefeatHero", 6: "CaptureTown", 7: "DefeatMonster",
        8: "ControlAllDwellings", 9: "ControlAllMines", 10: "TransportArtifact",
    }
    if victory_id == -1:
        victory = {"kind": "Standard"}
    elif victory_id in victory_names:
        victory = {"kind": victory_names[victory_id], "allowNormalVictory": bool(reader.u8()), "appliesToAI": bool(reader.u8())}
        if victory_id == 0:
            victory["artifactNativeId"] = reader.u16() if level_ab else reader.u8()
        elif victory_id == 1:
            victory["creatureNativeId"] = reader.u16() if level_ab else reader.u8()
            victory["amount"] = reader.i32()
        elif victory_id == 2:
            victory["resourceNativeId"] = reader.i8()
            victory["amount"] = reader.i32()
        elif victory_id == 3:
            victory["position"] = read_position(reader)
            victory["hallLevelNativeId"] = reader.u8()
            victory["fortificationLevelNativeId"] = reader.u8()
        elif victory_id in (4, 5, 6, 7):
            victory["position"] = read_position(reader)
        elif victory_id == 10:
            victory["artifactNativeId"] = reader.u8()
            victory["position"] = read_position(reader)
    else:
        raise ValueError(f"unknown original victory condition {victory_id}")

    loss_id = reader.i8()
    if loss_id == -1:
        special_loss = None
    elif loss_id == 0:
        special_loss = {"kind": "LoseTown", "position": read_position(reader)}
    elif loss_id == 1:
        special_loss = {"kind": "LoseHero", "position": read_position(reader)}
    elif loss_id == 2:
        special_loss = {"kind": "TimeExpires", "days": reader.u16()}
    else:
        raise ValueError(f"unknown original loss condition {loss_id}")
    return {
        "formatCode": format_code,
        "size": size,
        "name": map_name,
        "difficultyNativeId": difficulty,
        "victory": victory,
        "loss": {"standardDaysWithoutTown": 7, "special": special_loss},
    }


def read_bonus(reader: Reader, mode: int) -> dict:
    if mode == 1:  # explicit starting bonus
        bonus_type = reader.u8()
        if bonus_type == 0:
            return {"type": "Spell", "heroNativeId": struct.unpack("<h", reader.take(2))[0], "spellNativeId": reader.u8()}
        if bonus_type == 1:
            return {"type": "Creature", "heroNativeId": struct.unpack("<h", reader.take(2))[0], "creatureNativeId": struct.unpack("<H", reader.take(2))[0], "amount": struct.unpack("<H", reader.take(2))[0]}
        if bonus_type == 2:
            return {"type": "Building", "buildingNativeId": reader.u8()}
        if bonus_type == 3:
            return {"type": "Artifact", "heroNativeId": struct.unpack("<h", reader.take(2))[0], "artifactNativeId": struct.unpack("<H", reader.take(2))[0]}
        if bonus_type == 4:
            return {"type": "SpellScroll", "heroNativeId": struct.unpack("<h", reader.take(2))[0], "spellNativeId": reader.u8()}
        if bonus_type == 5:
            return {"type": "PrimarySkill", "heroNativeId": struct.unpack("<h", reader.take(2))[0], "attack": reader.u8(), "defense": reader.u8(), "power": reader.u8(), "knowledge": reader.u8()}
        if bonus_type == 6:
            return {"type": "SecondarySkill", "heroNativeId": struct.unpack("<h", reader.take(2))[0], "skillNativeId": reader.u8(), "masteryNativeId": reader.u8()}
        if bonus_type == 7:
            return {"type": "Resource", "resourceNativeId": struct.unpack("<b", reader.take(1))[0], "amount": struct.unpack("<i", reader.take(4))[0]}
        raise ValueError(f"unknown campaign bonus type {bonus_type}")
    elif mode == 2:  # hero from prior scenario
        return {"type": "PreviousScenarioHero", "playerColorNativeId": reader.u8(), "scenarioRegionIndex": reader.u8()}
    elif mode == 3:  # explicit hero option
        return {"type": "Hero", "playerColorNativeId": reader.u8(), "heroNativeId": struct.unpack("<h", reader.take(2))[0]}
    else:
        raise ValueError(f"unknown campaign start option {mode}")


def read_bitset(reader: Reader, byte_count: int) -> list[int]:
    payload = reader.take(byte_count)
    return [index for index in range(byte_count * 8) if payload[index // 8] & (1 << (index % 8))]


def parse_scenarios(header: bytes, start: int, version: int, count: int):
    reader = Reader(header)
    reader.position = start
    scenarios = []
    prerequisite_bytes = 2 if count > 8 else 1
    for region_index in range(count):
        map_name = reader.text()
        reader.u32()  # packed embedded-map size
        prerequisites = int.from_bytes(reader.take(prerequisite_bytes), "little")
        color = reader.u8()
        difficulty = reader.u8()
        reader.text()  # region label; copyrighted narrative is not retained
        for _ in range(2):  # prolog, epilog
            if reader.u8():
                reader.take(2)  # video and music IDs
                reader.text()  # copyrighted narrative is not retained
        keeps_mask = reader.u8()
        kept_creature_ids = read_bitset(reader, 19)
        kept_artifact_ids = read_bitset(reader, 17 if version < 6 else 18)
        start_option = reader.u8()
        player_color_id = None
        if start_option == 1:
            player_color_id = reader.u8()
        bonuses = []
        if start_option:
            for _ in range(reader.u8()):
                bonuses.append(read_bonus(reader, start_option))
        scenarios.append(
            {
                "regionIndex": region_index,
                "mapName": map_name,
                "prerequisites": prerequisites,
                "color": color,
                "difficulty": difficulty,
                "carryover": {
                    "keepsMask": keeps_mask,
                    "creatureNativeIds": kept_creature_ids,
                    "artifactNativeIds": kept_artifact_ids,
                },
                "startingBonus": {
                    "modeNativeId": start_option,
                    "playerColorNativeId": player_color_id,
                    "choices": bonuses,
                },
            }
        )
    if reader.position != len(header):
        raise ValueError(f"{len(header) - reader.position} unparsed header bytes")
    return scenarios


def parse_campaign(blob: bytes, expected_nonempty: int):
    blocks = gzip_blocks(blob)
    header = blocks[0]
    reader = Reader(header)
    version = reader.u32()
    if version not in (4, 5, 6):
        raise ValueError(f"unsupported official campaign version {version}")
    region_map_id = reader.u8()
    name = reader.text()
    reader.text()  # campaign description; copyrighted narrative is not retained
    if version > 4:
        reader.u8()  # whether the player may select difficulty
    reader.u8()  # music ID
    start = reader.position

    candidates = []
    for count in range(expected_nonempty, 17):
        try:
            scenarios = parse_scenarios(header, start, version, count)
        except (EOFError, KeyError, ValueError, struct.error):
            continue
        if sum(bool(item["mapName"]) for item in scenarios) == expected_nonempty:
            candidates.append(scenarios)
    if len(candidates) != 1:
        raise ValueError(
            f"{name}: expected one campaign-layout parse, found {len(candidates)}"
        )
    scenarios = candidates[0]
    active = [scenario for scenario in scenarios if scenario["mapName"]]
    if len(blocks) != len(active) + 1:
        raise ValueError(f"{name}: found {len(blocks) - 1} embedded maps for {len(active)} active regions")
    for scenario, map_payload in zip(active, blocks[1:], strict=True):
        scenario["mapHeader"] = parse_h3m_conditions(map_payload)
    return {
        "version": version,
        "regionMapId": region_map_id,
        "name": name,
        "scenarios": scenarios,
    }


def evidence(source_id: str, locator: str, claim: str) -> dict:
    return {"sourceId": source_id, "locator": locator, "claim": claim}


def joined_labels(labels: list[str]) -> str:
    if len(labels) == 1:
        return labels[0]
    if len(labels) == 2:
        return f"{labels[0]} and {labels[1]}"
    return ", ".join(labels[:-1]) + f", and {labels[-1]}"


def tsv_rows(payload: bytes) -> list[list[str]]:
    return list(csv.reader(io.StringIO(payload.decode("windows-1252")), delimiter="\t"))


def catalog_name_index(catalog: dict, table: str) -> dict[str, list[dict]]:
    result = defaultdict(list)
    for row in catalog[table]:
        if row.get("Game_id") == "homm3.game":
            result[normalized(row["Name"])].append(row)
    return result


def native_identity_maps(archive: Path, directory: dict, catalog: dict, lod):
    members = {}
    source_rows = []
    for member in ["HOTRAITS.TXT", "CRTRAITS.TXT", "ARTRAITS.TXT", "SPTRAITS.TXT", "SSTRAITS.TXT"]:
        payload = lod.extract_member(archive, directory[member])
        members[member] = payload
        source_rows.append({
            "id": f"homm3-native-id-{member.removesuffix('.TXT').lower()}",
            "kind": "primary_installed_game_file",
            "title": f"Heroes III Complete {member}",
            "archive": archive.name,
            "member": member,
            "sha256Observed": hashlib.sha256(payload).hexdigest(),
            "notes": "Used only to map source-native numeric IDs to validated catalog import-key annotations. The annotations remain literal JSON, not SQL foreign keys; source prose is not retained.",
        })

    indexes = {table: catalog_name_index(catalog, table) for table in ["Hero", "Creature", "Artifact", "Spell", "Skill"]}

    def unique_key(table: str, name: str) -> str:
        matches = indexes[table].get(normalized(name), [])
        if len(matches) != 1:
            raise ValueError(f"{table} native name {name!r} resolved to {len(matches)} rows")
        return matches[0]["_key"]

    hero_rows = tsv_rows(members["HOTRAITS.TXT"])[2:158]
    hero_map = {}
    for native_id, row in enumerate(hero_rows):
        name = row[0].strip()
        if name == "Lord Haart":
            hero_map[native_id] = (
                "homm3.hero.lord.haart.knight" if native_id == 4 else "homm3.hero.lord.haart.death.knight"
            )
        else:
            hero_map[native_id] = unique_key("Hero", name)

    creature_names = [
        row[0].strip() for row in tsv_rows(members["CRTRAITS.TXT"])[2:]
        if row and row[0].strip()
    ]
    creature_map = {}
    for native_id, name in enumerate(creature_names):
        if name.startswith("NOT USED") or name in {"Catapult", "Ballista", "First Aid Tent", "Ammo Cart", "Arrow Tower"}:
            continue
        creature_map[native_id] = unique_key("Creature", name)

    artifact_aliases = {"The Grail": "Grail"}
    artifact_rows = tsv_rows(members["ARTRAITS.TXT"])[2:146]
    artifact_map = {
        native_id: unique_key("Artifact", artifact_aliases.get(row[0].strip(), row[0].strip()))
        for native_id, row in enumerate(artifact_rows)
        if row[0].strip() and row[0].strip() not in {"Diplomat's Suit", "Mired in Neutrality", "Ironfist of the Ogre"}
    }

    spell_aliases = {
        "Prot. from Water": "Protection from Water",
        "Prot. from Earth": "Protection from Earth",
        "Fire Elemental": "Summon Fire Elemental",
        "Earth Elemental": "Summon Earth Elemental",
        "Water Elemental": "Summon Water Elemental",
        "Air Elemental": "Summon Air Elemental",
    }
    spell_names = [
        row[0].strip() for row in tsv_rows(members["SPTRAITS.TXT"])
        if len(row) > 2 and row[2].strip().isdigit()
    ][:70]
    spell_map = {
        native_id: unique_key("Spell", spell_aliases.get(name, name))
        for native_id, name in enumerate(spell_names)
    }

    skill_rows = tsv_rows(members["SSTRAITS.TXT"])[2:30]
    skill_map = {native_id: unique_key("Skill", row[0].strip()) for native_id, row in enumerate(skill_rows)}
    return {
        "Hero": hero_map,
        "Creature": creature_map,
        "Artifact": artifact_map,
        "Spell": spell_map,
        "Skill": skill_map,
    }, source_rows


def native_ref(native_id: int, mapping: dict[int, str], key_name: str) -> dict:
    if native_id not in mapping:
        raise ValueError(f"unmapped native ID {native_id} for {key_name}")
    return {"nativeId": native_id, key_name: mapping[native_id]}


def hero_target(native_id: int, mappings: dict) -> dict:
    selectors = {-3: "Strongest", -2: "Generated", -1: "Random"}
    if native_id in selectors:
        return {"nativeId": native_id, "selector": selectors[native_id]}
    return native_ref(native_id, mappings["Hero"], "heroKey")


PLAYER_COLORS = ["Red", "Blue", "Tan", "Green", "Orange", "Purple", "Teal", "Pink"]
BUILDING_KINDS = [
    "MageGuild1", "MageGuild2", "MageGuild3", "MageGuild4", "MageGuild5", "Tavern", "Shipyard", "Fort", "Citadel", "Castle",
    "VillageHall", "TownHall", "CityHall", "Capitol", "Marketplace", "ResourceSilo", "Blacksmith", "Special1", "Horde1", "Horde1Upgrade",
    "Ship", "Special2", "Special3", "Special4", "Horde2", "Horde2Upgrade", "Grail", "ExtraTownHall", "ExtraCityHall", "ExtraCapitol",
    "Dwelling1", "Dwelling2", "Dwelling3", "Dwelling4", "Dwelling5", "Dwelling6", "Dwelling7",
    "UpgradedDwelling1", "UpgradedDwelling2", "UpgradedDwelling3", "UpgradedDwelling4", "UpgradedDwelling5", "UpgradedDwelling6", "UpgradedDwelling7",
]
RESOURCE_KEYS = {
    -3: ["resource.wood", "resource.ore"],
    -2: ["resource.mercury", "resource.sulfur", "resource.crystal", "resource.gems"],
    0: ["resource.wood"], 1: ["resource.mercury"], 2: ["resource.ore"], 3: ["resource.sulfur"],
    4: ["resource.crystal"], 5: ["resource.gems"], 6: ["resource.gold"],
}


def player_color(native_id: int) -> dict:
    if not 0 <= native_id < len(PLAYER_COLORS):
        raise ValueError(f"unknown native player color {native_id}")
    return {"nativeId": native_id, "name": PLAYER_COLORS[native_id]}


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--game-root", type=Path, required=True,
                        help="Path to an authorized Heroes III Complete installation (read-only)")
    parser.add_argument("--output", type=Path, default=DEFAULT_OUTPUT)
    parser.add_argument("--rules-output", type=Path, default=DEFAULT_RULES_OUTPUT)
    args = parser.parse_args()

    catalog = json.loads((ROOT / "src/db/data/heroeswatch.json").read_text())[
        "tables"
    ]
    campaigns = {
        row["_key"]: row
        for row in catalog["Campaign"]
        if row["Game_id"] == "homm3.game"
    }
    campaign_by_name = {normalized(row["Name"]): key for key, row in campaigns.items()}
    memberships = defaultdict(list)
    for row in catalog["CampaignScenario"]:
        if row["Game_id"] == "homm3.game":
            memberships[row["Campaign_id"]].append(row)
    for rows in memberships.values():
        rows.sort(key=lambda row: row["SortOrder"])

    current_edges = {
        (row["FromScenario_id"], row["ToScenario_id"])
        for row in catalog["ScenarioConnection"]
        if row["Game_id"] == "homm3.game"
    }
    scenario_names = {
        row["_key"]: row["Name"]
        for row in catalog["Scenario"]
        if row["Game_id"] == "homm3.game"
    }
    graph_evidence = json.loads(
        (ROOT / "src/db/data/touchups-evidence.json").read_text()
    )["sourceEvidence"]["graphs"]["rows"]
    region_by_membership = {}
    for item in graph_evidence:
        if item["table"] != "CampaignScenario" or not item["key"].startswith("homm3."):
            continue
        match = re.search(r"; region=(\d+);", item["source"])
        if not match:
            raise ValueError(f"missing native region locator for {item['key']}")
        region_by_membership[item["key"]] = int(match.group(1))

    lod = load_lod_module()
    archives = [
        args.game_root / "Data/H3bitmap.lod",
        args.game_root / "Data/H3ab_bmp.lod",
    ]
    parsed = {}
    sources = []
    for archive in archives:
        directory = lod.read_directory(archive)
        for member_name, directory_entry in sorted(directory.items()):
            if not member_name.endswith(".H3C") or member_name == "NEUTRAL.H3C":
                continue
            blob = lod.extract_member(archive, directory_entry)
            # The static campaign title can be read before the variable region count.
            inflater = zlib.decompressobj(16 + zlib.MAX_WBITS)
            header = inflater.decompress(blob)
            title_reader = Reader(header)
            title_reader.u32()
            title_reader.u8()
            title = title_reader.text()
            campaign_key = campaign_by_name.get(normalized(title))
            if campaign_key is None or campaign_key in parsed:
                continue
            campaign = parse_campaign(blob, len(memberships[campaign_key]))
            digest = hashlib.sha256(blob).hexdigest()
            source_id = f"homm3-h3c-{normalized(title)}"
            locator = (
                f"installed-game:{archive.name}/{member_name}"
                f"#sha256={digest}; campaign-header"
            )
            campaign.update(
                {
                    "campaignKey": campaign_key,
                    "sourceId": source_id,
                    "locator": locator,
                }
            )
            parsed[campaign_key] = campaign
            sources.append(
                {
                    "id": source_id,
                    "kind": "primary_installed_game_file",
                    "title": f"Heroes III Complete {member_name}",
                    "archive": archive.name,
                    "member": member_name,
                    "sha256Observed": digest,
                    "notes": (
                        "Original campaign header parsed in memory. Embedded maps, "
                        "videos, images, and narrative text are not retained."
                    ),
                }
            )
    if set(parsed) != set(campaigns):
        missing = sorted(set(campaigns) - set(parsed))
        raise ValueError(f"campaigns not found in installed archives: {missing}")
    campaign_sources = list(sources)

    incoming = defaultdict(list)
    extracted_edges = set()
    source_for_scenario = {}
    native_by_scenario = {}
    scenario_by_campaign_region = {}
    for campaign_key, campaign in parsed.items():
        active = [row for row in campaign["scenarios"] if row["mapName"]]
        member_rows = memberships[campaign_key]
        if len(active) != len(member_rows):
            raise ValueError(f"{campaign_key}: scenario count mismatch")
        membership_by_region = {
            region_by_membership[row["_key"]]: row for row in member_rows
        }
        if set(membership_by_region) != {row["regionIndex"] for row in active}:
            raise ValueError(f"{campaign_key}: evidence/native region mismatch")
        by_region = {
            region: membership["Scenario_id"]
            for region, membership in membership_by_region.items()
        }
        scenario_by_campaign_region[campaign_key] = by_region
        for membership in member_rows:
            source_for_scenario[membership["Scenario_id"]] = campaign
        for native in active:
            membership = membership_by_region[native["regionIndex"]]
            target = membership["Scenario_id"]
            native_by_scenario[target] = native
            for region_index, source in by_region.items():
                if native["prerequisites"] & (1 << region_index):
                    incoming[target].append(source)
                    extracted_edges.add((source, target))
    if extracted_edges != current_edges:
        missing = sorted(extracted_edges - current_edges)
        extra = sorted(current_edges - extracted_edges)
        raise ValueError(
            f"native prerequisite graph differs from catalog; missing={missing}, extra={extra}"
        )

    fills = []
    for membership in catalog["CampaignScenario"]:
        if membership["Game_id"] != "homm3.game" or not incoming[membership["Scenario_id"]]:
            continue
        if membership["AvailabilityCondition"] is not None:
            raise ValueError(f"non-null availability condition: {membership['_key']}")
        sources_for_target = sorted(
            incoming[membership["Scenario_id"]], key=lambda key: scenario_names[key]
        )
        labels = [scenario_names[key] for key in sources_for_target]
        campaign = source_for_scenario[membership["Scenario_id"]]
        value = {
            "description": "Available after completing "
            + joined_labels(labels)
            + ".",
            "source": campaign["locator"],
        }
        fills.append(
            {
                "table": "CampaignScenario",
                "key": membership["_key"],
                "field": "AvailabilityCondition",
                "expected": None,
                "value": value,
                "evidence": evidence(
                    campaign["sourceId"],
                    campaign["locator"],
                    "The native prerequisite bitmask requires all listed source regions "
                    "before this campaign region becomes available.",
                ),
            }
        )

    building_by_key = {row["_key"]: row for row in catalog["BuildingHOMM3"]}
    common_effects = {
        "village.hall": {"goldPerDay": 500},
        "town.hall": {"goldPerDay": 1000},
        "city.hall": {"goldPerDay": 2000},
        "capitol": {"goldPerDay": 4000, "limitPerPlayer": 1},
        "fort": {"description": "Adds town walls."},
        "citadel": {
            "creatureGrowthPercent": 50,
            "description": "Adds a moat and the central arrow tower.",
        },
        "castle": {
            "creatureGrowthPercent": 100,
            "description": "Strengthens walls and adds two smaller arrow towers.",
        },
        "mage.guild.level.1": {"spellLevel": 1, "spellsOfferedAtLevel": 5},
        "mage.guild.level.2": {"spellLevel": 2, "spellsOfferedAtLevel": 4},
        "mage.guild.level.3": {"spellLevel": 3, "spellsOfferedAtLevel": 3},
        "mage.guild.level.4": {"spellLevel": 4, "spellsOfferedAtLevel": 2},
        "mage.guild.level.5": {"spellLevel": 5, "spellsOfferedAtLevel": 1},
        "marketplace": {
            "description": "Allows resource trading; exchange rates improve with more controlled marketplaces."
        },
        "tavern": {
            "description": "Allows hero recruitment, rumors, and access to the Thieves Guild."
        },
    }
    text_source_id = "homm3-installed-building-text"
    text_locator = (
        "installed-game:H3bitmap.lod/BLDGNEUT.TXT"
        "#sha256=84c3d6f2477c21d16e54f11d13b3ee4464d07f33b69206d1921df2b70fc5c2d0"
    )
    for suffix, value in common_effects.items():
        key = f"homm3.building.conflux.{suffix}"
        row = building_by_key[key]
        if row["Effect"] is not None:
            raise ValueError(f"expected null effect for {key}")
        fills.append(
            {
                "table": "BuildingHOMM3",
                "key": key,
                "field": "Effect",
                "expected": None,
                "value": value,
                "evidence": evidence(
                    text_source_id,
                    text_locator,
                    "The installed common-building table gives the same effect for this "
                    "Conflux building as for the already populated classic towns.",
                ),
            }
        )

    grail_keys = [
        "homm3.building.castle.colossus",
        "homm3.building.rampart.spirit.guardian",
        "homm3.building.tower.skyship",
        "homm3.building.inferno.deity.of.fire",
        "homm3.building.necropolis.soul.prison",
        "homm3.building.dungeon.guardian.of.earth",
        "homm3.building.stronghold.warlords.monument",
        "homm3.building.fortress.carnivorous.plant",
        "homm3.building.conflux.aurora.borealis",
    ]
    special_source_id = "homm3-installed-special-building-text"
    special_locator = (
        "installed-game:H3bitmap.lod/BLDGSPEC.TXT"
        "#sha256=d4f1042bec50755a9520d266b1a9b02a7a01d45cc703d0ace06af0648e902fe1"
    )
    for key in grail_keys:
        row = building_by_key[key]
        if row["Effect"] is not None:
            raise ValueError(f"expected null effect for {key}")
        fills.append(
            {
                "table": "BuildingHOMM3",
                "key": key,
                "field": "Effect",
                "expected": None,
                "value": {"goldPerDay": 5000, "creatureGrowthPercent": 50},
                "evidence": evidence(
                    special_source_id,
                    special_locator,
                    "The installed special-building table states that this Grail structure "
                    "adds 5,000 gold daily and raises weekly creature generation by 50%.",
                ),
            }
        )

    sources.extend(
        [
            {
                "id": text_source_id,
                "kind": "primary_installed_game_file",
                "title": "Heroes III Complete common building text",
                "archive": "H3bitmap.lod",
                "member": "BLDGNEUT.TXT",
                "sha256Observed": "84c3d6f2477c21d16e54f11d13b3ee4464d07f33b69206d1921df2b70fc5c2d0",
                "notes": "Only concise structured mechanics are retained; the source prose is not copied.",
            },
            {
                "id": special_source_id,
                "kind": "primary_installed_game_file",
                "title": "Heroes III Complete special building text",
                "archive": "H3bitmap.lod",
                "member": "BLDGSPEC.TXT",
                "sha256Observed": "d4f1042bec50755a9520d266b1a9b02a7a01d45cc703d0ace06af0648e902fe1",
                "notes": "Only concise structured Grail mechanics are retained; the source prose is not copied.",
            },
        ]
    )

    output = {
        "formatVersion": 1,
        "researchDate": "2026-10-13",
        "notes": (
            "Read-only completion patch from the installed original Heroes III Complete "
            "data. It does not replace the cumulative catalog and does not include game "
            "binaries or narrative text."
        ),
        "additions": [],
        "fills": fills,
        "sources": sorted(sources, key=lambda item: item["id"]),
        "verification": {
            "campaignsParsed": len(parsed),
            "nativeScenarioPrerequisiteEdges": len(extracted_edges),
            "catalogScenarioPrerequisiteEdges": len(current_edges),
            "availabilityConditionsAdded": sum(
                item["field"] == "AvailabilityCondition" for item in fills
            ),
            "buildingEffectsAdded": sum(item["field"] == "Effect" for item in fills),
            "graphMatchesNative": extracted_edges == current_edges,
        },
        "deferred": [
            {
                "table": "HeroHOMM3",
                "field": "StartingArmy",
                "reason": (
                    "HOTRAITS.TXT has three probability-bearing native slots and includes "
                    "war machines. The current JSON contract stores creature ranges but not "
                    "slot inclusion chances or non-creature war machines; importing a partial "
                    "array would change the meaning."
                ),
                "proposedContract": {
                    "slots": [
                        {
                            "slot": "positive integer",
                            "creatureKey": "catalog creature key or null",
                            "warMachineKey": "catalog artifact/war-machine key or null",
                            "minimum": "non-negative integer",
                            "maximum": "non-negative integer",
                            "inclusionChancePercent": "0..100",
                        }
                    ]
                },
            },
            {
                "table": "ScenarioHOMM3",
                "fields": [
                    "VictoryConditions",
                    "LossConditions",
                    "StartingBonuses",
                    "CarryoverRules",
                ],
                "reason": (
                    "These JSONB columns are deliberately null-only in the current contract. "
                    "The H3C/H3M files support typed data, but importing it first requires "
                    "reviewed closed JSON shapes and validator tests."
                ),
            },
        ],
    }
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(output, indent=2, ensure_ascii=False) + "\n")
    print(json.dumps(output["verification"], indent=2))

    if catalog["ScenarioHOMM3"]:
        raise ValueError("ScenarioHOMM3 is no longer empty; rules patch requires reconciliation")
    base_archive = args.game_root / "Data/H3bitmap.lod"
    base_directory = lod.read_directory(base_archive)
    mappings, mapping_sources = native_identity_maps(base_archive, base_directory, catalog, lod)
    keeps = [(1, "Experience"), (2, "PrimarySkills"), (4, "SecondarySkills"), (8, "Spells"), (16, "Artifacts")]
    mastery = {1: "Basic", 2: "Advanced", 3: "Expert"}
    scenario_rows = {row["_key"]: row for row in catalog["Scenario"] if row["Game_id"] == "homm3.game"}
    map_rows = {row["_key"]: row for row in catalog["Map"] if row["Game_id"] == "homm3.game"}
    map_details = {row["_key"]: row for row in catalog["MapHOMM3"]}
    map_formats = {14: "ROE", 21: "AB", 28: "SoD"}
    difficulties = ["Easy", "Normal", "Hard", "Expert", "Impossible"]

    def convert_bonus(raw: dict, campaign_key: str) -> dict:
        kind = raw["type"]
        if kind == "Spell":
            return {"kind": kind, "hero": hero_target(raw["heroNativeId"], mappings),
                "spell": native_ref(raw["spellNativeId"], mappings["Spell"], "spellKey")}
        if kind == "Creature":
            return {"kind": kind, "hero": hero_target(raw["heroNativeId"], mappings),
                "creature": native_ref(raw["creatureNativeId"], mappings["Creature"], "creatureKey"), "amount": raw["amount"]}
        if kind == "Building":
            native_id = raw["buildingNativeId"]
            if not 0 <= native_id < len(BUILDING_KINDS):
                raise ValueError(f"unknown native building ID {native_id}")
            return {"kind": kind, "nativeId": native_id, "buildingKind": BUILDING_KINDS[native_id]}
        if kind == "Artifact":
            return {"kind": kind, "hero": hero_target(raw["heroNativeId"], mappings),
                "artifact": native_ref(raw["artifactNativeId"], mappings["Artifact"], "artifactKey")}
        if kind == "SpellScroll":
            return {"kind": kind, "hero": hero_target(raw["heroNativeId"], mappings),
                "spell": native_ref(raw["spellNativeId"], mappings["Spell"], "spellKey")}
        if kind == "PrimarySkill":
            return {"kind": kind, "hero": hero_target(raw["heroNativeId"], mappings), "attack": raw["attack"],
                "defense": raw["defense"], "spellPower": raw["power"], "knowledge": raw["knowledge"]}
        if kind == "SecondarySkill":
            if raw["masteryNativeId"] not in mastery:
                raise ValueError(f"unknown native mastery {raw['masteryNativeId']}")
            return {"kind": kind, "hero": hero_target(raw["heroNativeId"], mappings),
                "skill": native_ref(raw["skillNativeId"], mappings["Skill"], "skillKey"),
                "mastery": mastery[raw["masteryNativeId"]]}
        if kind == "Resource":
            native_id = raw["resourceNativeId"]
            if native_id not in RESOURCE_KEYS:
                raise ValueError(f"unknown native resource ID {native_id}")
            return {"kind": kind, "nativeId": native_id, "resourceKeys": RESOURCE_KEYS[native_id], "amount": raw["amount"]}
        if kind == "PreviousScenarioHero":
            region_index = raw["scenarioRegionIndex"]
            if region_index not in scenario_by_campaign_region[campaign_key]:
                raise ValueError(f"unknown prior scenario region {campaign_key}:{region_index}")
            return {"kind": kind, "playerColor": player_color(raw["playerColorNativeId"]),
                "nativeRegionIndex": region_index, "scenarioKey": scenario_by_campaign_region[campaign_key][region_index]}
        if kind == "Hero":
            return {"kind": kind, "playerColor": player_color(raw["playerColorNativeId"]),
                "hero": hero_target(raw["heroNativeId"], mappings)}
        raise ValueError(f"unknown bonus kind {kind}")

    def convert_victory(raw: dict) -> dict:
        result = {key: value for key, value in raw.items()
            if key not in {"artifactNativeId", "creatureNativeId", "resourceNativeId"}}
        if "artifactNativeId" in raw:
            result["artifact"] = native_ref(raw["artifactNativeId"], mappings["Artifact"], "artifactKey")
        if "creatureNativeId" in raw:
            result["creature"] = native_ref(raw["creatureNativeId"], mappings["Creature"], "creatureKey")
        if "resourceNativeId" in raw:
            native_id = raw["resourceNativeId"]
            if native_id not in RESOURCE_KEYS:
                raise ValueError(f"unknown victory resource ID {native_id}")
            result["nativeResourceId"] = native_id
            result["resourceKeys"] = RESOURCE_KEYS[native_id]
        return result

    rule_additions = []
    mode_counts = defaultdict(int)
    victory_counts = defaultdict(int)
    loss_counts = defaultdict(int)
    choice_count = 0
    for campaign_key, member_rows in memberships.items():
        campaign = parsed[campaign_key]
        for membership in member_rows:
            scenario_key = membership["Scenario_id"]
            native = native_by_scenario[scenario_key]
            map_header = native["mapHeader"]
            map_key = scenario_rows[scenario_key]["Map_id"]
            map_row = map_rows[map_key]
            map_detail = map_details[map_key]
            if map_header["size"] != map_row["Width"] or map_header["size"] != map_row["Height"]:
                raise ValueError(f"{scenario_key}: native map size differs from catalog")
            if map_formats[map_header["formatCode"]] != map_detail["MapFormat"]:
                raise ValueError(f"{scenario_key}: native map format differs from catalog")
            if difficulties[map_header["difficultyNativeId"]] != map_detail["Difficulty"]:
                raise ValueError(f"{scenario_key}: native difficulty differs from catalog")
            carry_raw = native["carryover"]
            carryover = {
                "nativeKeepsMask": carry_raw["keepsMask"],
                "heroKeeps": [name for bit, name in keeps if carry_raw["keepsMask"] & bit],
                "keptCreatureTypes": [native_ref(value, mappings["Creature"], "creatureKey") for value in carry_raw["creatureNativeIds"]],
                "keptArtifactTypes": [native_ref(value, mappings["Artifact"], "artifactKey") for value in carry_raw["artifactNativeIds"]],
            }
            start_raw = native["startingBonus"]
            choices = [convert_bonus(value, campaign_key) for value in start_raw["choices"]]
            if start_raw["modeNativeId"] == 1:
                starting = {"selectionMode": "BonusChoices", "playerColor": player_color(start_raw["playerColorNativeId"]), "choices": choices}
            elif start_raw["modeNativeId"] == 2:
                starting = {"selectionMode": "HeroCrossover", "choices": choices}
            elif start_raw["modeNativeId"] == 3:
                starting = {"selectionMode": "HeroChoices", "choices": choices}
            else:
                raise ValueError(f"unsupported starting mode {start_raw['modeNativeId']}")
            mode_counts[starting["selectionMode"]] += 1
            victory = convert_victory(map_header["victory"])
            loss = map_header["loss"]
            victory_counts[victory["kind"]] += 1
            loss_counts[loss["special"]["kind"] if loss["special"] else "Standard"] += 1
            choice_count += len(choices)
            rule_additions.append({
                "table": "ScenarioHOMM3",
                "row": {"_key": scenario_key, "VictoryConditions": victory, "LossConditions": loss,
                    "StartingBonuses": starting, "CarryoverRules": carryover},
                "evidence": evidence(campaign["sourceId"], campaign["locator"],
                    "The original campaign header defines the scenario's selectable starting options and hero carryover flags/type sets; its embedded H3M header defines victory and loss conditions."),
            })

    rules_sources = [{**item, "notes": "Original campaign header and each embedded H3M header parsed in memory. Map bodies, narrative text, audio, video, and images are not retained."}
        for item in campaign_sources] + mapping_sources
    rules_output = {
        "formatVersion": 1,
        "researchDate": "2026-10-13",
        "notes": "Typed ScenarioHOMM3 additions from original Heroes III Complete campaign headers. Native IDs are retained beside validated source-bundle import-key annotations. The annotations are stored as literal JSON, not PostgreSQL foreign keys. No binary or narrative content is included.",
        "additions": rule_additions,
        "fills": [],
        "sources": sorted(rules_sources, key=lambda item: item["id"]),
        "verification": {
            "scenarioDetailsAdded": len(rule_additions),
            "startingBonusChoices": choice_count,
            "selectionModes": dict(sorted(mode_counts.items())),
            "victoryConditionKinds": dict(sorted(victory_counts.items())),
            "lossConditionKinds": dict(sorted(loss_counts.items())),
            "embeddedMapHeadersParsed": len(rule_additions),
            "allNativeImportKeyAnnotationsValidated": True,
            "campaignGraphStillMatchesNative": extracted_edges == current_edges,
        },
        "deferred": [
            {"table": "HeroHOMM3", "field": "StartingArmy",
                "reason": "The native runtime's probability-bearing slots and war-machine entries still cannot be represented faithfully by the current creature-range-only contract."},
        ],
    }
    args.rules_output.parent.mkdir(parents=True, exist_ok=True)
    args.rules_output.write_text(json.dumps(rules_output, indent=2, ensure_ascii=False) + "\n")
    print(json.dumps(rules_output["verification"], indent=2))


if __name__ == "__main__":
    main()
