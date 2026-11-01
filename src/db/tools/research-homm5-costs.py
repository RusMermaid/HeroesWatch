#!/usr/bin/env python3
"""Build the Heroes V creature/building cost and building-graph research patch.

This reads only the selectively extracted pages of the developer-supported
Heroes V 3.1 manual.  It does not download or retain the full manual, change
the cumulative catalog, or connect to PostgreSQL.

Expected reference files (created with read-manual-pages.py):
  h5-creatures-160-162.pdf, h5-creatures-163-165.pdf,
  h5-creatures-166-168.pdf, and h5-buildings-211-212.pdf through
  h5-buildings-241-242.pdf (two-page increments).
"""

from __future__ import annotations

import argparse
import hashlib
import json
import re
from pathlib import Path

from pypdf import PdfReader
from pypdf.generic import ContentStream


MANUAL_URL = "https://h5.heroes.net.pl/uploaded/download/other/Heroes5-Manual-en-3-1.pdf"
SOURCE_BYTES = 58_182_081
SOURCE_ETAG = '"377c9c1-6042b7303c15b"'
FACTIONS = "academy dungeon fortress haven inferno necropolis stronghold sylvan".split()
CREATURE_PAGE_FACTIONS = "academy dungeon haven inferno necropolis sylvan fortress stronghold".split()

# SHA-256 prefixes of the decoded 16x15 resource images.  The six non-gold
# mappings are independently anchored by the ten labelled rune costs on page
# 191.  Gold is the only remaining icon and is also labelled in ordinary cost
# prose throughout the manual.
RESOURCE_IMAGE_HASHES = {
    "5724d304c9625c23": "gold",
    "af69e354dcacc92e": "wood",
    "c4d78fc2ebb02156": "ore",
    "a185f18caeabe80c": "mercury",
    "d4518af30ea2a0e1": "sulfur",
    "a2014909f61c62c3": "crystal",
    "43e68ad81f542702": "gems",
}


def arguments() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--reference-dir", type=Path, default=Path("/tmp"))
    parser.add_argument(
        "--catalog",
        type=Path,
        default=Path(__file__).resolve().parents[1] / "data" / "heroeswatch.json",
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=Path(__file__).resolve().parents[1]
        / "research"
        / "2026-10-13"
        / "homm5-costs.patch.json",
    )
    return parser.parse_args()


def load_pages(reference_dir: Path, pattern: str) -> dict[int, object]:
    pages: dict[int, object] = {}
    files = sorted(reference_dir.glob(pattern))
    if not files:
        raise FileNotFoundError(f"No selective references match {reference_dir / pattern}")
    for filename in files:
        match = re.search(r"-(\d+)-(\d+)\.pdf$", filename.name)
        if not match:
            continue
        first, last = map(int, match.groups())
        reader = PdfReader(filename, strict=True)
        if len(reader.pages) != last - first + 1:
            raise AssertionError(f"Page count mismatch in {filename}")
        for offset, page in enumerate(reader.pages):
            number = first + offset
            if number in pages:
                raise AssertionError(f"Duplicate extracted page {number}")
            pages[number] = page
    return pages


def image_resource(page, name: str) -> str | None:
    image = page["/Resources"]["/XObject"][name].get_object()
    if image.get("/Subtype") != "/Image":
        return None
    if int(image.get("/Width", 10_000)) > 20 or int(image.get("/Height", 10_000)) > 20:
        return None
    digest = hashlib.sha256(image.get_data()).hexdigest()[:16]
    return RESOURCE_IMAGE_HASHES.get(digest)


def cost_icon_groups(page) -> list[list[str]]:
    """Return the resource icons in each cost row, in visual left-to-right order."""
    operations = ContentStream(page.get_contents(), page.pdf).operations
    placements: list[tuple[float, float, str]] = []
    for index, (operands, operator) in enumerate(operations):
        if operator != b"Do":
            continue
        resource = image_resource(page, operands[0])
        if not resource:
            continue
        matrix = next(
            (values for values, op in reversed(operations[max(0, index - 7) : index]) if op == b"cm"),
            None,
        )
        if matrix is None:
            raise AssertionError("Resource icon without a local placement matrix")
        placements.append((float(matrix[5]), float(matrix[4]), resource))

    groups: list[tuple[float, list[tuple[float, str]]]] = []
    for y, x, resource in placements:
        if not groups or abs(groups[-1][0] - y) > 0.1:
            groups.append((y, []))
        groups[-1][1].append((x, resource))
    return [[resource for _, resource in sorted(items)] for _, items in groups]


def building_headers(lines: list[str], names: list[str]) -> list[tuple[int, str]]:
    headers: list[tuple[int, str]] = []
    for index, line in enumerate(lines):
        folded = line.casefold()
        matches = [
            name
            for name in names
            if folded == name.casefold() or folded.startswith(name.casefold() + " - ")
        ]
        if len(matches) > 1:
            raise AssertionError(f"Ambiguous building header: {line}")
        if matches:
            headers.append((index, matches[0]))
    return headers


def source_evidence(page: int, building: str | None = None) -> dict:
    subject = f", {building}" if building else ""
    return {
        "sourceId": "h5-manual-3.1-buildings",
        "locator": f"Heroes V 3.1 manual, PDF/printed p.{page}{subject}",
        "claim": "The cost icons and quantities, explicit prerequisites, upgrade statement, and town-level requirement are transcribed from this entry.",
    }


def parse_buildings(tables: dict, pages: dict[int, object]) -> tuple[list[dict], list[dict], dict]:
    generic = {row["_key"]: row for row in tables["Building"]}
    details = {row["_key"]: row for row in tables["BuildingHOMM5"]}
    additions: list[dict] = []
    fills: list[dict] = []
    seen_buildings: set[str] = set()
    costed_buildings = cost_rows = requirement_rows = upgrade_rows = 0

    for faction_index, faction in enumerate(FACTIONS):
        faction_id = f"homm5.faction.{faction}"
        keys = [row["_key"] for row in tables["BuildingHOMM5"] if row["Faction_id"] == faction_id]
        names_to_keys = {generic[key]["Name"]: key for key in keys}
        names = list(names_to_keys)
        if len(names) != len(keys):
            raise AssertionError(f"Duplicate building name in {faction}")

        for page_number in range(211 + faction_index * 4, 215 + faction_index * 4):
            page = pages[page_number]
            lines = [line.strip() for line in page.extract_text().splitlines()]
            headers = building_headers(lines, names)
            page_costs: list[tuple[str, list[int], dict]] = []

            for header_index, (line_index, name) in enumerate(headers):
                key = names_to_keys[name]
                if key in seen_buildings:
                    raise AssertionError(f"Building appears more than once: {key}")
                seen_buildings.add(key)
                stop = headers[header_index + 1][0] if header_index + 1 < len(headers) else len(lines)
                block = " ".join(lines[line_index + 1 : stop])
                evidence = source_evidence(page_number, name)

                cost = re.search(r"» Cost:\s*((?:\d+[,.]?\s*)+)", block)
                if cost:
                    page_costs.append((key, [int(value) for value in re.findall(r"\d+", cost.group(1))], evidence))

                requires = re.search(r"» Requires:\s*(.*)", block)
                requirement_text = requires.group(1) if requires else ""
                # The grammar on these pages is a comma-separated AND list.
                # Exact-token matching matters: for example, "Dragon Graveyard"
                # must not also create a dependency on the distinct "Graveyard".
                requirement_list = re.split(
                    r"Heroes of Might|\b(?:Academy|Dungeon|Fortress|Haven|Inferno|Necropolis|Stronghold|Sylvan) "
                    r"(?:Standard |Magic |Special )?Buildings\b|\b\d+ Ubisoft:",
                    requirement_text,
                )[0]
                names_casefold = {candidate.casefold(): candidate for candidate in names}
                for requirement in requirement_list.split(","):
                    token = requirement.strip().rstrip(".").strip()
                    if not token or re.fullmatch(r"Town Level \d+", token, re.IGNORECASE):
                        continue
                    required_name = names_casefold.get(token.casefold())
                    if required_name is None:
                        raise AssertionError(f"Unknown prerequisite {token!r} for {key}")
                    required_key = names_to_keys[required_name]
                    additions.append(
                        {
                            "table": "BuildingRequirement",
                            "row": {
                                "_key": f"{key}.requires.{required_key.removeprefix('homm5.building.')}",
                                "Game_id": "homm5.game",
                                "Building_id": key,
                                "RequiredBuilding_id": required_key,
                                "Condition": None,
                            },
                            "evidence": evidence,
                        }
                    )
                    requirement_rows += 1

                town_level = re.search(r"Town Level (\d+)", requirement_text, re.IGNORECASE)
                if town_level:
                    value = int(town_level.group(1))
                    current = details[key].get("TownLevelRequired")
                    if current is None:
                        fills.append(
                            {
                                "table": "BuildingHOMM5",
                                "key": key,
                                "field": "TownLevelRequired",
                                "expected": None,
                                "value": value,
                                "evidence": evidence,
                            }
                        )
                    elif current != value:
                        raise AssertionError(f"Town-level conflict for {key}: catalog {current}, manual {value}")

                upgrade = re.search(r"An upgrade of (?:the )?([^.]*)\.", block, re.IGNORECASE)
                if upgrade:
                    phrase = upgrade.group(1).strip()
                    candidates = [candidate for candidate in names if candidate.casefold() == phrase.casefold()]
                    if not candidates:
                        candidates = [
                            candidate
                            for candidate in names
                            if candidate.casefold().endswith(" " + phrase.casefold())
                            or phrase.casefold().endswith(" " + candidate.casefold())
                        ]
                    if len(candidates) != 1:
                        raise AssertionError(f"Cannot resolve upgrade base {phrase!r} for {key}: {candidates}")
                    base_key = names_to_keys[candidates[0]]
                    additions.append(
                        {
                            "table": "BuildingUpgrade",
                            "row": {
                                "_key": f"{key}.upgrades.{base_key.removeprefix('homm5.building.')}",
                                "Game_id": "homm5.game",
                                "BaseBuilding_id": base_key,
                                "UpgradedBuilding_id": key,
                            },
                            "evidence": evidence,
                        }
                    )
                    upgrade_rows += 1

            icon_groups = cost_icon_groups(page)
            if len(page_costs) != len(icon_groups):
                raise AssertionError(
                    f"Cost/icon-row count differs on p.{page_number}: {len(page_costs)} != {len(icon_groups)}"
                )
            for (key, amounts, evidence), resources in zip(page_costs, icon_groups, strict=True):
                if len(amounts) != len(resources):
                    raise AssertionError(
                        f"Cost quantity/icon count differs for {key}: {amounts} vs {resources}"
                    )
                if len(resources) != len(set(resources)):
                    raise AssertionError(f"Duplicate resource icon in one cost row for {key}")
                costed_buildings += 1
                for resource, amount in zip(resources, amounts, strict=True):
                    additions.append(
                        {
                            "table": "BuildingResourceCost",
                            "row": {
                                "_key": f"{key}.cost.{resource}",
                                "Game_id": "homm5.game",
                                "Building_id": key,
                                "Resource_id": f"resource.{resource}",
                                "Amount": amount,
                            },
                            "evidence": evidence,
                        }
                    )
                    cost_rows += 1

    expected_buildings = {row["_key"] for row in tables["BuildingHOMM5"] if row["_key"].startswith("homm5.")}
    if seen_buildings != expected_buildings:
        raise AssertionError(
            f"Building page coverage mismatch; missing={sorted(expected_buildings-seen_buildings)}, "
            f"extra={sorted(seen_buildings-expected_buildings)}"
        )
    counts = {
        "buildingsSeen": len(seen_buildings),
        "costedBuildings": costed_buildings,
        "buildingCostRows": cost_rows,
        "buildingRequirementRows": requirement_rows,
        "buildingUpgradeRows": upgrade_rows,
        "townLevelFills": len(fills),
    }
    expected = {
        "buildingsSeen": 292,
        "costedBuildings": 276,
        "buildingCostRows": 924,
        "buildingRequirementRows": 192,
        "buildingUpgradeRows": 133,
        "townLevelFills": 5,
    }
    if counts != expected:
        raise AssertionError(f"Unexpected building extraction counts: {counts} != {expected}")
    return additions, fills, counts


def parse_creature_costs(tables: dict, pages: dict[int, object]) -> tuple[list[dict], dict]:
    creatures = {row["_key"]: row for row in tables["Creature"]}
    details = {row["_key"]: row for row in tables["CreatureHOMM5"]}
    upgrades = [row for row in tables["CreatureUpgrade"] if row["Game_id"] == "homm5.game"]
    base_keys = {row["BaseCreature_id"] for row in upgrades}
    target_keys = {row["UpgradedCreature_id"] for row in upgrades}
    additions: list[dict] = []

    for faction_index, faction in enumerate(CREATURE_PAGE_FACTIONS):
        page_number = 161 + faction_index
        page = pages[page_number]
        tier_seven = [
            key
            for key, row in details.items()
            if row["Faction_id"] == f"homm5.faction.{faction}" and row.get("Tier") == 7
        ]
        base = [key for key in tier_seven if key in base_keys]
        upgraded = [key for key in tier_seven if key in target_keys]
        if len(base) != 1 or len(upgraded) != 2:
            raise AssertionError(f"Unexpected tier-seven graph for {faction}: {tier_seven}")
        upgraded.sort(key=lambda key: bool(details[key].get("AlternativeUpgrade")))

        groups = cost_icon_groups(page)
        if len(groups) != 2 or len(groups[0]) != 1 or len(groups[1]) != 2:
            raise AssertionError(f"Unexpected rare-cost icon layout on p.{page_number}: {groups}")
        resources = groups[0] + groups[1]
        if len(set(resources)) != 1:
            raise AssertionError(f"Tier-seven forms use inconsistent resources on p.{page_number}: {resources}")

        # Text extraction retains the explicit +1 / +2 quantities.  Require the
        # exact three markers before pairing them with the base/upgrade graph.
        text = page.extract_text()
        plus_values = [int(value) for value in re.findall(r"\+(\d+)", text)]
        if plus_values != [1, 2, 2]:
            raise AssertionError(f"Unexpected tier-seven quantities on p.{page_number}: {plus_values}")

        for key, amount, resource in zip(base + upgraded, plus_values, resources, strict=True):
            evidence = {
                "sourceId": "h5-manual-3.1-creatures",
                "locator": f"Heroes V 3.1 manual, PDF/printed p.{page_number}, {creatures[key]['Name']} cost row",
                "claim": "The rare-resource icon and +quantity supplement the already-cataloged gold recruitment cost.",
            }
            additions.append(
                {
                    "table": "CreatureResourceCost",
                    "row": {
                        "_key": f"{key}.cost.{resource}",
                        "Game_id": "homm5.game",
                        "Creature_id": key,
                        "Resource_id": f"resource.{resource}",
                        "Amount": amount,
                    },
                    "evidence": evidence,
                }
            )

    if len(additions) != 24:
        raise AssertionError(f"Expected 24 tier-seven rare-resource rows, got {len(additions)}")
    return additions, {"creatureCostRows": len(additions), "creaturePages": 8}


def validate_against_catalog(tables: dict, additions: list[dict]) -> None:
    keys_by_table = {name: {row["_key"] for row in rows} for name, rows in tables.items()}
    new_keys: set[tuple[str, str]] = set()
    for action in additions:
        table, row = action["table"], action["row"]
        identity = (table, row["_key"])
        if identity in new_keys:
            raise AssertionError(f"Duplicate patch key: {identity}")
        new_keys.add(identity)
        if row["_key"] in keys_by_table[table]:
            raise AssertionError(f"Patch would overwrite existing {table} row {row['_key']}")
        if row.get("Amount") is not None and row["Amount"] <= 0:
            raise AssertionError(f"Non-positive amount in {identity}")


def main() -> None:
    args = arguments()
    tables = json.loads(args.catalog.read_text(encoding="utf-8"))["tables"]
    building_pages = load_pages(args.reference_dir, "h5-buildings-2??-2??.pdf")
    creature_pages = load_pages(args.reference_dir, "h5-creatures-1??-1??.pdf")
    if set(building_pages) != set(range(211, 243)):
        raise AssertionError(f"Expected building pages 211-242, got {sorted(building_pages)}")
    if set(creature_pages) != set(range(160, 169)):
        raise AssertionError(f"Expected creature pages 160-168, got {sorted(creature_pages)}")

    building_additions, fills, building_counts = parse_buildings(tables, building_pages)
    creature_additions, creature_counts = parse_creature_costs(tables, creature_pages)
    additions = creature_additions + building_additions
    validate_against_catalog(tables, additions)

    bundle = {
        "formatVersion": 1,
        "researchDate": "2026-10-13",
        "notes": "Heroes V 3.1 rare creature recruitment costs plus the complete town-building resource costs, explicit building prerequisites, stated upgrade graph, and five source-explicit town-level fills. No prose effects are copied and no null fact is inferred.",
        "additions": additions,
        "fills": fills,
        "sources": [
            {
                "id": "h5-manual-3.1-creatures",
                "title": "Heroes V Manual — Tribes of the East 3.1, creature tables",
                "url": MANUAL_URL,
                "provenance": "Community handbook supported by Ubisoft and Nival; final 3.1 ruleset reference used by this project.",
                "pdfPages": "161-168",
                "sourceBytes": SOURCE_BYTES,
                "observedETag": SOURCE_ETAG,
                "method": "Selective range extraction; cost quantities from text and resource identities from page-image digests anchored to labelled page-191 rune costs.",
                "visualCheck": "Rendered pages 161-168 and the page-191 legend were inspected; the tier-seven +1/+2 icons align with the same decoded resource images.",
            },
            {
                "id": "h5-manual-3.1-buildings",
                "title": "Heroes V Manual — Tribes of the East 3.1, town buildings",
                "url": MANUAL_URL,
                "provenance": "Community handbook supported by Ubisoft and Nival; final 3.1 ruleset reference used by this project.",
                "pdfPages": "211-242",
                "sourceBytes": SOURCE_BYTES,
                "observedETag": SOURCE_ETAG,
                "method": "Selective two-page range extractions; all 292 catalog building headings matched exactly once. Resource icon/quantity arity is checked for every cost row.",
                "visualCheck": "Rendered page 212 was inspected at 180 dpi; gold, wood, ore, mercury, crystal, sulfur, and gems appear in the same left-to-right order produced by the digest map.",
            },
        ],
        "verification": {
            **creature_counts,
            **building_counts,
            "additionRows": len(additions),
            "fillRows": len(fills),
            "catalogModified": False,
            "databaseModified": False,
        },
    }
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(bundle, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(bundle["verification"], indent=2))


if __name__ == "__main__":
    main()
