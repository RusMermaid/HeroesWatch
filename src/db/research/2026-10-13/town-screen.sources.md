# Heroes III Complete town-screen junction review

Review date: 2026-10-13. Source: the user's installed, unmodified Heroes III
Complete data archives. HotA, WoG, ERA and other mod archives were excluded.
The install was inspected read-only with `src/db/tools/extract-homm3-lod.py`;
no art was copied into the repository.

## Result

`town-screen.patch.json` stages:

- nine `TownScreen` parent rows, one for every classic Complete faction;
- 318 `TownScreenBuilding` membership rows, exactly one for every current H3
  `Building`/`BuildingHOMM3` pair.

This resolves the previously empty H3 town-screen junction without inventing
screen coordinates, click polygons, exported artwork, or media URIs.

## Native archive evidence

The audited installation contains these background members in
`Data/H3bitmap.lod`:

| Faction | Background member | Native dimensions |
|---|---|---:|
| Castle | `TBCSBACK.PCX` | 800 × 374 |
| Rampart | `TBRMBACK.PCX` | 800 × 374 |
| Tower | `TBTWBACK.PCX` | 800 × 374 |
| Inferno | `TBINBACK.PCX` | 800 × 374 |
| Necropolis | `TBNCBACK.PCX` | 800 × 374 |
| Dungeon | `TBDNBACK.PCX` | 800 × 374 |
| Stronghold | `TBSTBACK.PCX` | 800 × 374 |
| Fortress | `TBFRBACK.PCX` | 800 × 374 |
| Conflux | `TBELBACK.PCX` | 800 × 374 |

The dimensions come from the native PCX record header: 800 width, 374 height,
and 897,600 pixel bytes. They describe the town artwork area, not the complete
game window and lower UI chrome.

`Data/H3sprite.lod` contains separate faction-prefixed town-building layers:
`TBCS*`, `TBRM*`, `TBTW*`, `TBIN*`, `TBNC*`, `TBDN*`, `TBST*`, `TBFR*`, and
`TBEL*`. The stable native suffix families include:

- `DW_0`–`DW_6` and `UP_0`–`UP_6` for the seven base and upgraded dwellings;
- `MAGE`, `MAG2`–`MAG5` for Mage Guild levels;
- `CSTL`, `CAS2`, `CAS3` for fortification stages;
- `HALL`, `HAL2`, `HAL3`, `HAL4` for hall stages;
- `BLAK`, `MARK`, `SILO`, `TVRN`, and `HOLY` for common structures and the
  Grail layer;
- faction-specific `SPEC`, `EXT*`, `HRD*`, `BOAT`, `DOCK`, and `WTRW`
  families for special, horde, shipyard and Fortress water layers.

The native name/description tables `DWELLING.TXT`, `BLDGNEUT.TXT`,
`BLDGSPEC.TXT`, and `BUILDING.TXT` were inspected alongside those sprite
families. The existing H3 catalog was originally normalized from those same
classic tables and records 318 buildings with faction ownership. Combining the
native name tables with the matching faction-prefixed sprite family establishes
town-screen membership; `BuildingHOMM3.Faction_id` was not used by itself.

Automated cross-checks confirmed:

- all nine background members exist;
- all 283 exact background and sprite-member references emitted by the patch
  exist in the audited archives, as do all four referenced native text tables;
- 44 faction-specific special/horde/shipyard rows resolve to an existing
  faction sprite family rather than a guessed individual suffix;
- every one of the 318 H3 building identities appears exactly once in the
  proposed junction and no non-H3 building appears.

## What the relation means

`TownScreenBuilding` means that a building has a native visual layer on the
faction's town screen. It does not mean every layer is visible simultaneously.
Base/upgraded dwellings, hall and fortification stages, ship states, horde
variants, and Grail structures remain conditional on game state. The current
junction has no condition or edition column, so the patch records membership
only and does not flatten those conditions into false booleans.

`Hotspot` remains null on all 318 rows. The LOD directories and DEF layers do
not provide a reviewed click rectangle or polygon mapping, and no executable
offset table was reverse-engineered for this review. Coordinates must not be
estimated from visible pixels.

`BackgroundMediaAsset_id` also remains null. An archive member is not a durable
standalone URI under the current `MediaAsset` contract. Adding a pretend file
path would point to no repository asset. A future archive-member media scheme
could model archive path, member name, source checksum and optional extraction
without copying the copyrighted art into Git.

## Counts by faction

| Faction | Current H3 buildings | Proposed screen links |
|---|---:|---:|
| Castle | 35 | 35 |
| Rampart | 36 | 36 |
| Tower | 36 | 36 |
| Inferno | 36 | 36 |
| Necropolis | 36 | 36 |
| Dungeon | 36 | 36 |
| Stronghold | 34 | 34 |
| Fortress | 34 | 34 |
| Conflux | 35 | 35 |
| **Total** | **318** | **318** |

## Reproduction

The inspection used only directory reads and selected small members. For
example:

```sh
python3 src/db/tools/extract-homm3-lod.py \
  "<Heroes III Complete>/Data/H3bitmap.lod" /tmp/hw-town-audit \
  TBCSBACK.PCX DWELLING.TXT BLDGNEUT.TXT BLDGSPEC.TXT BUILDING.TXT
```

The repository patch contains names and relationships only, never the extracted
bytes. The installed archive relative paths are recorded in the patch source
registry; the user's absolute local path is not persisted.

## Validation

A temporary merge of this patch alone passed the repository validator and SQL
builder:

```text
screens 9 links 318 rows 40350
Valid HeroesWatch data bundle: 176 tables, 40350 rows.
Built heroeswatch-townscreen-catalog.sql (40350 rows). No database connection was opened.
```

No catalog file, generated SQL, live database, installed game archive or
diagram was modified.
