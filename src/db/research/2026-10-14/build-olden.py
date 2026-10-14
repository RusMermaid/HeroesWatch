"""Build a bounded Olden Era research patch from the user's installed files.

Usage: python build-olden.py --assets STREAMING_ASSETS --manifest APPMANIFEST
       --catalog heroeswatch.json --schema heroeswatch.schema.json --output PATCH
Raw archives, localization, map bytes and scripts are never copied to output.
"""
import argparse
import collections
import gzip
import hashlib
import json
import pathlib
import re
import zipfile

p = argparse.ArgumentParser()
for arg in ("assets", "manifest", "catalog", "schema", "output"):
    p.add_argument("--" + arg, required=True, type=pathlib.Path)
a = p.parse_args()
manifest = a.manifest.read_text(encoding="utf-8-sig")
assert re.search(r'"buildid"\s+"25061458"', manifest), "Expected installed build 25061458"
catalog = json.loads(a.catalog.read_text(encoding="utf-8-sig"))["tables"]
schema = {t["name"]: t for t in json.loads(a.schema.read_text(encoding="utf-8-sig"))["tables"]}
archive = zipfile.ZipFile(a.assets / "Core.zip")
source_hashes = {}

def digest(data):
    return hashlib.sha256(data).hexdigest()

def read(source):
    data = archive.read(source)
    source_hashes[source] = digest(data)
    return json.loads(data.decode("utf-8-sig"))

def records(prefix):
    for source in archive.namelist():
        if source.startswith(prefix) and source.endswith(".json"):
            for item in read(source).get("array", []):
                yield source, item

loc = {}
for source in archive.namelist():
    if source.startswith("Lang/english/texts/") and source.endswith(".json"):
        for token in read(source).get("tokens", []):
            loc[token["sid"]] = token["text"]

patch = {
    "formatVersion": 1, "reviewDate": "2026-10-14",
    "target": {"game": "homm8.game", "build": "25061458", "versionPolicy": "Installed build only; modern wiki balance is not merged."},
    "additions": [], "fills": [], "sources": [], "held": []
}

def evidence(paths, claim, **extra):
    return {"kind": "installed-game", "build": "25061458", "paths": [
        {"path": x, "sha256": source_hashes[x]} for x in sorted(set(paths))
    ], "claim": claim, **extra}

def add(table, key, values, ev):
    assert not any(r["_key"] == key for r in catalog[table]), (table, key)
    row = {"_key": key, **{c["name"]: None for c in schema[table]["columns"] if not c["primaryKey"]}, **values}
    patch["additions"].append({"table": table, "row": row, "evidence": ev})

def fill(table, key, field, value, ev):
    row = next(r for r in catalog[table] if r["_key"] == key)
    assert row[field] is None, (table, key, field)
    patch["fills"].append({"table": table, "key": key, "field": field, "expected": None, "value": value, "evidence": ev})

# Alternative basic attacks are an explicit engine family, separate from abilities.
# IsActive describes the player's action; IsFocusAction describes the ability family.
units = {r["id"]: (source, r) for source, r in records("DB/units/units_logics/")}
views = {r["id"]: (source, r) for source, r in records("DB/units/units_views/")}
detail_keys = {r["_key"] for r in catalog["AbilityHOMM8"]}
missing = [r for r in catalog["Ability"] if r["_key"].startswith("homm8.") and r["_key"] not in detail_keys]
assert len(missing) == 9
normalize = lambda text: re.sub(r"[^a-z0-9]", "", text.lower())
for ability in missing:
    links = [r for r in catalog["CreatureAbility"] if r["Ability_id"] == ability["_key"]]
    sources, memberships = [], []
    explicit_free = ability["Name"].startswith("Fighting Style:")
    for link in links:
        creature = next(r for r in catalog["Creature"] if r["_key"] == link["Creature_id"])
        native = creature["Code"].lower()
        upath, unit = units[native]
        vpath, view = views[native]
        matches = [i for i, attack in enumerate(view.get("alternativeAttacks", []))
                   if normalize(loc.get(attack.get("name"), "")) == normalize(ability["Name"])]
        assert len(matches) == 1, (native, ability["Name"], matches)
        i = matches[0]
        native_attack = unit["alternativeAttacks"][i]
        assert "basic_attack" in native_attack["damageDealer"]["tags"]
        assert "energyLevel" not in native_attack and native_attack.get("cd") in (None, -1)
        if explicit_free:
            text = " ".join(loc.get(view["alternativeAttacks"][i].get(k), "") for k in ("additionalDescription", "infoDescription"))
            assert "Does not spend Focus Charges" in text, (native, text)
        sources.extend([upath, vpath])
        memberships.append({"creature": creature["_key"], "nativeId": native, "alternativeAttackIndex": i})
    ev = evidence(sources + ["Lang/english/texts/unitsAbility.json"],
        "Every existing member maps to the named alternativeAttacks basic_attack entry, distinct from the Focus abilities array. IsActive means player-chosen action; IsFocusAction means dedicated Focus-ability family.",
        members=memberships)
    add("AbilityHOMM8", ability["_key"], {
        "AbilityKind": "Creature", "IsActive": True, "IsFocusAction": False,
        "IsAlternativeAttack": True, "FocusChargeCost": 0 if explicit_free else None,
        "Effect": ability["Description"]
    }, ev)

# Same-build tutorial and UI resolve the point/Insight relationship that newer
# Neutral Magic wiki documentation describes differently.
tutorial = loc["tutorial_M_28_3_5_new"]
assert all(x in tutorial for x in ("Astrology points", "Insight", "learn or upgrade"))
assert "Astrology points" in loc["help_text_spells"]
astro_path = "DB/astrology_exp/astrology_exp.json"
astro_tables = read(astro_path)["array"]
neutral_path = "DB/magics/world_neutral_magics.json"
neutral = read(neutral_path)["array"]
insight_spells = [r for r in neutral if r.get("upgradeRes") == "starDust"]
assert len(insight_spells) == 6
city_path = "DB/objects_logic/cities/human_city.json"
city = read(city_path)["array"][0]
city_income = [next(int(b["parameters"][0]) for b in level["bonuses"] if b["type"] == "astrologyExp") for level in city["mains"][0]["bonusesPerLevel"]]
add("AstrologyHOMM8", "homm8.game", {
    "NeutralMagicSchool_id": "homm8.magicschool.neutral",
    "AstrologyPointResource_id": "resource.astrology.points",
    "InsightResource_id": "resource.insight", "MaximumSpellLevel": 4,
    "IncomeRule": f"City main-building levels supply {', '.join(map(str, city_income))} Astrology Points per day respectively; skills, faction laws and scenario settings can modify income. Accumulated points grant Insight. The installed build contains several threshold tables, so no universal first threshold or fixed increment is asserted.",
    "UnlockRule": "Spend Insight in the Magic Observatory to learn eligible high Neutral spells for the kingdom. Heroes must satisfy the spell's own level requirement. Insight can also be gained from an Altar of Insight. This is the build-25061458 system described by its tutorial.",
    "UpgradeRule": "Spend the spell's defined Insight upgrade cost to improve supported Global Map spells, up to the spell's available level. The source's starDust learn/upgrade costs identify Insight; this is separate from ordinary school-spell research and Alchemical Dust upgrades."
}, evidence([astro_path, neutral_path, city_path, "Lang/english/texts/tutorial.json", "Lang/english/texts/ui.json", "Lang/english/texts/mapObjects.json"],
    "The same-build tutorial directly connects city Astrology Point income, accumulated Insight, and spending Insight to learn or upgrade high Neutral Global Map spells. Threshold definitions are variants, not one constant-increment series.",
    localizationTokens=["tutorial_M_28_3_5_new", "help_text_spells", "tutorial_C6_1", "mystical_tower_description"],
    thresholdTables=[{"id": r["id"], "firstThreshold": r["values"][1], "thresholdCount": len(r["values"])-1} for r in astro_tables]))

skills_path = "DB/heroes_skills/skills/skills.json"
skills = {r["id"]: r for r in read(skills_path)["array"]}
for school in catalog["MagicSchool"]:
    if school["Game_id"] != "homm8.game":
        continue
    native = school["_key"].split(".")[-1]
    regular = native != "neutral"
    if regular:
        skill_key = "homm8.skill.skill.magic." + native
        assert "skill_magic_" + native in skills
    add("MagicSchoolHOMM8", school["_key"], {
        "SchoolKind": "Regular" if regular else "Neutral",
        "SchoolSkill_id": skill_key if regular else None,
        "MaxSpellTier": 5 if regular else 4, "MaximumSpellLevel": 4,
        "UsesObservatory": True, "UsesAstrology": not regular,
        "ProgressionRule": (
            "Mage Guilds unlock ordinary school spells; their mastery skill allows high-tier learning. Observatory upgrades use Alchemical Dust. Effective spell levels are capped at four. Astrology's Insight progression applies to high Neutral spells, not this regular school."
            if regular else
            "High Neutral Global Map spells use Astrology Point income and Insight learning/upgrading in the Magic Observatory in build 25061458. Other Neutral spells come from skills, starting spellbooks or artifacts; Astrology is not required for every Neutral spell."
        )
    }, evidence([skills_path, neutral_path, "Lang/english/texts/tutorial.json", "Lang/english/texts/ui.json"],
        "UsesAstrology means the school has spells governed by the build's Astrology/Insight progression, not that every spell requires it. Regular-school progression and high Neutral progression are separate.",
        corroboration="https://wiki.hoodedhorse.com/Heroes_of_Might_and_Magic_Olden_Era/Spellcasting"))

# Positive flags only. No missing resource behavior is turned into false.
resource_path = "DB/res/resources_info.json"
read(resource_path)
exchange_path = "DB/resources_exchange.json"
exchange = {r["resName"] for r in read(exchange_path)["resources"]}
mine_path = "DB/objects_logic/res_mines/mines.json"
mines = {r["resName"]: r["resValue"] for r in read(mine_path)["array"]}
resource_native = {"gold": "gold", "wood": "wood", "ore": "ore", "crystal": "crystals", "gems": "gemstones", "mercury": "mercury", "alchemical.dust": "dust", "grail": "graal", "law.points": "faction_laws_points", "astrology.points": "astrology_exp", "insight": "starDust"}
mechanics = {
    "grail": "Obtained from the Mirage encounter and spent to construct the faction's Grail building.",
    "law.points": "Kingdom progression meter for gaining Law Seals; points and spendable seals are different quantities.",
    "astrology.points": "Kingdom progression meter generated by city main buildings and other bonuses; accumulated points grant Insight in this build.",
    "insight": "The starDust resource pays the defined learning and upgrading costs of high Neutral Global Map spells. An Altar of Insight can also grant it."
}
for membership in catalog["GameResource"]:
    if membership["Game_id"] != "homm8.game":
        continue
    resource = membership["Resource_id"]
    short = resource.removeprefix("resource.")
    native = resource_native[short]
    text = mechanics.get(short, "Kingdom treasury resource used by building, recruitment, spell or artifact costs as defined by each purchase.")
    if native in mines:
        text += f" An ordinary {membership['DisplayName']} mine produces {mines[native]} per day; this is per owned mine, not unconditional kingdom income."
    add("ResourceHOMM8", resource, {
        "ResourceRole": "Meter" if short.endswith(".points") else "Quest" if short == "grail" else "Upgrade" if short == "insight" else "Stockpile",
        "Scope": "Kingdom", "IsTradeable": True if native in exchange else None,
        "IsMineProduced": True if native in mines else None,
        "IsPersistent": None, "Mechanics": text
    }, evidence([resource_path, exchange_path, mine_path, "Lang/english/texts/tutorial.json", "Lang/english/texts/ui.json", "Lang/english/texts/mapObjects.json"],
        "Positive exchange and mine-production flags come from operative source definitions. Other flags and persistence remain unknown; absence does not become false. Daily mine yield is described per mine, not put in DefaultDailyIncome.", nativeId=native))

def map_header(path):
    raw = path.read_bytes()
    data = gzip.decompress(raw)
    cursor = 0
    def string():
        nonlocal cursor
        count, shift = 0, 0
        while True:
            value = data[cursor]
            cursor += 1
            count |= (value & 127) << shift
            if value < 128:
                break
            shift += 7
            assert shift < 35
        result = data[cursor:cursor + count].decode("utf-8")
        cursor += count
        return result
    map_hash, version = string(), string()
    format_number = int.from_bytes(data[cursor:cursor + 2], "little")
    cursor += 2
    header = json.loads(string())
    assert header["hashSum"] == map_hash
    assert header["sizeX"] > 0 and header["sizeZ"] > 0
    return header, version, format_number, digest(raw)

faction_names = {"human": "Temple", "undead": "Necropolis", "nature": "Grove", "demon": "Hive", "unfrozen": "Schism", "dungeon": "Dungeon"}
objectives = {
    "c_M1": "Investigate the unusual fire in Garner Hills.",
    "c_M2": "Travel to Silverwood, locate survivors, and clear the Tethers.",
    "c_M3": "Defeat Necropolis by taking its cities and overcoming its heroes.",
    "c_M3b": "Defeat Temple by taking its cities and overcoming its heroes.",
    "c_M4": "Investigate the energy leakage, find the druid, defeat Grove, and reach the energy source.",
    "c_M4b": "Investigate the energy leakage, find the druid, defeat Temple, and reach the energy source.",
    "c_M5": "Locate Galthran and awaken him.",
    "c_M6": "Locate Valentina and free her from captivity.",
    "c_M9": "Open the four directional gates, regain the keep, and defeat Galthran.",
    "c_M9b": "Open the four directional gates, regain the keep, and defeat Valentina.",
    "c_M10": "Assemble troops, protect the city, and prepare for successive enemy assaults.",
    "t_M_basic": "Take the city in the map's northeastern corner.",
    "t_M": "Complete the intermediate tutorial tasks and overcome the enemy.",
    "t_C1": "Arrive at the destination before the following day starts.",
    "t_C2": "Use trading to collect at least 10 Crystal, 10 Gems, and 10 Mercury before the day ends.",
    "t_C3": "Secure dwellings, begin the new week, and overcome the opposing army before week 2 day 2.",
    "t_C4": "Overcome the opposing force before the following day starts.",
    "t_C5": "Use spellcasting to overcome the opposing army before the following day starts.",
    "t_C6": "Use adventure spells to reach the nearby island's destination before the following day starts.",
    "t_C7": "Overcome the opposing hero before the following day starts.",
    "t_C8": "Overcome the opposing hero before day 3 starts."
}
mission_index = {}
for source, mission in records("campaigns/"):
    if "/missions/" not in source:
        continue
    for variant_number, variant in enumerate(mission.get("variants", []), 1):
        if variant.get("mapSid"):
            mission_index.setdefault(variant["mapSid"], []).append((source, mission, variant_number, variant))

for scenario in catalog["Scenario"]:
    if scenario["Game_id"] != "homm8.game":
        continue
    native_map = re.search(r"native map ([^.]+)\.", scenario["Description"])[1]
    matches = [m for m in mission_index[native_map] if m[1]["id"].startswith(("Campaign_Start_Phase_", "Tutorial_"))]
    assert len(matches) == 1, (native_map, len(matches))
    source, mission, variant_number, variant = matches[0]
    mappath = a.assets / "maps/Story_maps" / (native_map + ".map")
    header, map_version, format_number, map_sha = map_header(mappath)
    scriptpath = mappath.with_suffix(".json")
    script_data = scriptpath.read_bytes()
    script = json.loads(script_data.decode("utf-8-sig"))
    source_hashes["maps/Story_maps/" + mappath.name] = map_sha
    source_hashes["maps/Story_maps/" + scriptpath.name] = digest(script_data)
    ev = evidence([source, "maps/Story_maps/" + mappath.name, "maps/Story_maps/" + scriptpath.name, "Lang/english/texts/tutorial.json", "Lang/english/texts/campaign.json"],
        "Mission is selected by its native mapSid and exact variant; .NET length-prefixed gzip map header supplies dimensions, player-slot count and editor version. Mission sides and enabled difficulties supply scenario rules. Header session defaults do not establish mode capability flags.",
        missionId=mission["id"], variant=variant_number, mapFormatVersion=format_number)
    for field, value in (("Width", header["sizeX"]), ("Height", header["sizeZ"]), ("PlayerCount", header["spawns"]["playersCount"])):
        fill("Map", scenario["Map_id"], field, value, ev)
    allowed = [d for d in mission.get("difficultiesParameters", []) if d.get("isAvailable") is True]
    diffs = ", ".join(loc.get(d["nameSid"], f"difficulty {d['index'] + 1}") for d in allowed)
    players = [s for s in variant["sides"] if s["type"] == "Player"]
    bots = [s for s in variant["sides"] if s["type"] == "Bot"]
    rules = [f"Enabled difficulties: {diffs}.", f"The mission assigns {len(players)} human-controlled side(s) and {len(bots)} computer-controlled side(s)."]
    for field, label in (("disableFactionLaws", "Faction Laws"), ("disableMagicGuild", "Mage Guild"), ("isCustomLearningBlocked", "Custom spell learning")):
        if field in mission:
            rules.append(f"{label} {'disabled' if mission[field] else 'enabled'}.")
    if mission.get("bannedMagics"):
        rules.append(f"The mission bans {len(mission['bannedMagics'])} explicitly listed spell definitions.")
    rules.append(f"The mission requires {mission['requiredHeroesCount']} selected hero(s).")
    starting = []
    for d in variant.get("difficulties", []):
        if d["index"] not in {x["index"] for x in allowed}:
            continue
        costs = d.get("economic", {}).get("playerStartResources")
        if costs is not None:
            labels = {"gold": "Gold", "wood": "Wood", "ore": "Ore", "gemstones": "Gems", "crystals": "Crystal", "mercury": "Mercury", "alchemicalDust": "Alchemical Dust"}
            amounts = ", ".join(f"{labels[k]} {v}" for k, v in costs.items())
            starting.append(f"Difficulty {d['index'] + 1}: {amounts}.")
    is_main = "/mainStory/" in source
    kind = "Campaign" if is_main else "Challenge" if "tutorial_challenges/" in source else "Tutorial"
    add("ScenarioHOMM8", scenario["_key"], {
        "ActNumber": 1 if is_main else None,
        "MissionNumber": int(re.search(r"Mission_(\d+)", mission["id"])[1]),
        "Availability": "Available", "ScenarioKind": kind, "GameMode": "Scenario",
        "AllowsSinglePlayer": True, "StartingState": " ".join(starting) or None,
        "Objectives": objectives[native_map],
        "Rules": " ".join(rules)
    }, ev)
    add("MapHOMM8", scenario["Map_id"], {
        "MapKind": "Campaign", "SupportsSinglePlayer": True,
        "DefinitionVersion": map_version,
        "Rules": f"Authored map for {scenario['Name']}; mission settings override stored map defaults. The map package contains a separate quest script. Terrain levels and optional game-mode capabilities are not established by the decoded metadata."
    }, ev)

for group, key, narrative in (
    ("tutorial", "homm8.campaign.tutorial", "Two guided tutorial missions. Completing the first activates the second; both hub nodes are repeatable."),
    ("tutorial_challenges", "homm8.campaign.tutorial.challenges", "Eight focused gameplay challenges selected from the challenge hub.")
):
    source = "campaigns/" + group + "/storyHub.json"
    hub = read(source)
    mission_nodes = [n for n in hub["nodes"] if any(x["type"] == "OpenMissionsPrologue" for x in n.get("interactionActions", []))]
    assert len(mission_nodes) == (2 if group == "tutorial" else 8)
    add("CampaignHOMM8", key, {
        "Availability": "Available", "AvailableActCount": None,
        "NarrativeStructure": narrative,
        "Rules": "An instructional mission group without an act structure. AvailableActCount is inapplicable, not zero. " +
                 ("Hero progress is not transferred from a completed session." if hub.get("transferHeroProgressFromSession") is False else "Mission-specific progression is retained by the campaign hub.")
    }, evidence([source], "Explicit hub mission nodes and transferHeroProgressFromSession define the tutorial grouping; no numbered acts are defined."))

patch["held"] = [
    {"area": "Map and scenario capabilities", "reason": "Unknown support flags and map level counts remain null. The installed .map header stores session defaults, not all supported modes; no false flags are invented."},
    {"area": "Resource flags", "reason": "Trade/mine true flags are sourced. Negative flags and persistence remain null pending explicit contract and source evidence."},
    {"area": "Astrology thresholds", "reason": "Five differently shaped build threshold tables are retained in evidence; active selection is not established and the progression is not one fixed increment."},
    {"area": "Advanced Tutorial starting treasury", "reason": "Tutorial_Mission_1 advertises difficulty index 1 but all supplied variant difficulty records use index 0. StartingState stays null rather than guessing which record the engine selects."},
    {"area": "Full scripts", "reason": "Objectives, mission rules and supported starting treasuries are summarized. Optional Scripts stay null; raw mission scripts are not copied into catalog JSON."}
]
patch["sources"] = [
    {"id": "installed-olden-25061458", "kind": "installed-game", "build": "25061458", "archive": "HeroesOldenEra_Data/StreamingAssets/Core.zip", "sha256": digest((a.assets / "Core.zip").read_bytes()), "scope": "Selected primary definitions are hashed on every action. The Steam manifest's installed buildid was checked; queued TargetBuildID is not used."},
    {"id": "official-file-layout", "kind": "official-documentation", "url": "https://wiki.hoodedhorse.com/Heroes_of_Might_and_Magic_Olden_Era/Help:Game_Files", "scope": "Core.zip and game-data layout."},
    {"id": "official-spellcasting", "kind": "official-documentation", "url": "https://wiki.hoodedhorse.com/Heroes_of_Might_and_Magic_Olden_Era/Spellcasting", "scope": "Corroborates four regular-school constellations, five tiers and four effective spell levels; build-specific Astrology rules use installed tutorial instead of newer neutral-progression text."}
]
a.output.parent.mkdir(parents=True, exist_ok=True)
a.output.write_text(json.dumps(patch, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
print(json.dumps({"additions": len(patch["additions"]), "fills": len(patch["fills"]), "tables": dict(collections.Counter(x["table"] for x in patch["additions"]))}))
