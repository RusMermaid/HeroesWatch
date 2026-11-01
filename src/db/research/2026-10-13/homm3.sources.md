# Heroes III Complete native-source completion

Research date: 2026-10-13. Scope: the user's installed English Heroes III
Complete data only (Restoration of Erathia, Armageddon's Blade, and Shadow of
Death). Horn of the Abyss, WoG, HD Mod balance changes, community-only values,
and later-game data are excluded.

The portable results are [homm3.patch.json](homm3.patch.json), containing
guarded field fills, and [homm3-rules.patch.json](homm3-rules.patch.json),
containing new typed `ScenarioHOMM3` detail rows. They are merge patches, not a
replacement catalog. This batch does not edit `heroeswatch.json`, generated
SQL, a live database, or the installed game.

## Result

| Completed area | Result |
|---|---:|
| Original campaigns parsed from installed H3C headers | 20 |
| Native campaign prerequisite edges independently recovered | 75 |
| Existing catalog prerequisite edges | 75 |
| Graph differences | 0 |
| `CampaignScenario.AvailabilityCondition` fills | 61 |
| Conflux common-building effect fills | 14 |
| Grail-building effect fills | 9 |
| Total guarded fills | 84 |
| Typed `ScenarioHOMM3` detail additions | 87 |
| Selectable starting-bonus choices | 253 |
| Bonus-choice / hero-choice / crossover scenarios | 84 / 1 / 2 |
| Embedded H3M headers parsed and cross-checked | 87 |
| Victory conditions populated | 87 |
| Loss-condition documents populated | 87 |

The 61 availability documents make the AND semantics of each native H3C
prerequisite mask explicit. Root/initial regions keep a null condition. The
existing 75 `ScenarioConnection` rows already match the installed binary graph
exactly, so no duplicate edges are added and no existing edge is changed.

The Conflux common-building rows were the only classic town band whose common
effects were still entirely null. The patch supplies the same structured
effects already present for the eight other towns: hall income, Capitol limit,
Fort/Citadel/Castle behavior, mage-guild level and offered-spell count,
Marketplace, and Tavern. The nine Grail rows receive only the two mechanics
shared by every installed Grail description: 5,000 gold per day and 50% greater
weekly creature generation. Town-specific Grail abilities remain unencoded
because the current closed JSON contract has no suitable fields for most of
them.

All 87 campaign scenarios now have typed victory, loss, carryover and
starting-option documents. Source-native IDs are retained beside validated
catalog import-key annotations for heroes, creatures, artifacts, spells,
secondary skills, resources, and prior scenarios. Building bonuses retain their original ID plus the corresponding
engine building kind because a campaign's generic building option resolves in
the receiving town and therefore has no single faction-specific `Building` FK.
The closed profiles distinguish ordinary bonus choices, hero crossover, and
explicit hero choices. Victory profiles cover the twelve condition kinds
actually present in the original campaign maps; loss profiles preserve the
universal seven-days-without-a-town rule plus the optional hero-loss or time
limit condition.

These nested import-key strings are provenance annotations, not database
relationships. `_key` is omitted from universal PostgreSQL tables, and the
current importer resolves only declared top-level FK columns; JSONB is written
verbatim. Bundle validation checks that annotations name an existing Heroes III
row, but PostgreSQL does not enforce them and direct SQL JSON edits can bypass
that check. No safe repository API mapping from an annotation to the stored
`(Game_id, Code)` business identity was found. SQL consumers must not join by
parsing annotation text. Use the existing normalized junctions where available
(`ScenarioConnection`, `CreatureAbility`, and others); a future queryable rule
endpoint needs a reviewed relation or persistent import-key registry/rewriter.

## Primary evidence and extraction

The research tool reads the following original records directly from the
installed archives without modifying them:

- `Data/H3bitmap.lod`: fourteen original campaign H3C members plus
  `BLDGNEUT.TXT` and `BLDGSPEC.TXT`.
- `Data/H3ab_bmp.lod`: the six Armageddon's Blade campaign H3C members not in
  the final base archive. Duplicate RoE headers and the obsolete
  `NEUTRAL.H3C` are excluded; `NEUTRAL1.H3C` is the selected Complete version.
- `HOTRAITS.TXT` was inspected for starting-army coverage but is not imported
  for the reasons below.

Each H3C is a concatenated gzip stream. The fill patch reads the first stream
(the campaign header). The rules patch additionally reads the bounded header of
each embedded H3M to recover its format, dimensions, difficulty, and typed
victory/loss conditions. Those three header facts must match the existing
`Map`/`MapHOMM3` row before any rule row is emitted. The parser discards map
bodies, campaign descriptions, region prose, prologue/epilogue prose, video
IDs, and music IDs. The patches record a SHA-256 for every source H3C member.
No original binary, artwork, audio, video, map, or narrative text is committed.

`BLDGNEUT.TXT` has observed SHA-256
`84c3d6f2477c21d16e54f11d13b3ee4464d07f33b69206d1921df2b70fc5c2d0`.
`BLDGSPEC.TXT` has observed SHA-256
`d4f1042bec50755a9520d266b1a9b02a7a01d45cc703d0ace06af0648e902fe1`.
The output patch contains the per-campaign member names and hashes.

The binary layout is cross-checked against VCMI's published original-campaign
reader, specifically `lib/campaign/CampaignHandler.cpp` and
`lib/campaign/CampaignBonus.cpp`. Those files document the H3C header,
prerequisite-mask widths, carryover bitsets, and starting-bonus record sizes.
VCMI is used as a format specification; the gameplay facts come from the
user's installed original files.

## Existing Heroes III coverage intentionally preserved

The current catalog already contains and validates the following sourced
Heroes III bands, so this work does not rescrape, overwrite, or clone them:

- 141 `CreatureHOMM3` rows (126 town creatures plus 15 neutral creatures),
  with resource costs and upgrade edges.
- 103 `Ability`/`AbilityHOMM3` identities and 287 Heroes III
  `CreatureAbility` junctions.
- 70 `SpellHOMM3` rows, 76 school memberships, and 478 Heroes III
  `FactionSpell` junctions.
- 18 hero classes, 156 heroes, 291 Heroes III `HeroSkill` junctions, and the
  already sourced starting-spell fields.
- 318 buildings, 315 Heroes III `BuildingCreature` junctions, 326 building
  prerequisites, 152 building upgrades, and their resource costs.
- 20 campaigns, 87 scenarios/maps, 87 campaign memberships, 75 scenario
  connections, 417 map/terrain memberships, and 5,401 map/object-type links.

Any different value in the advisory text tables is not allowed to overwrite a
recorded runtime-sensitive fact. This patch contains null-only fills, so its
application fails closed if the cumulative catalog has moved.

## Deliberately deferred fields

### Hero starting armies

`HOTRAITS.TXT` supplies three native starting slots per hero, with minimum and
maximum quantity. The original runtime applies inclusion chances by slot, and
some slots are war machines rather than creatures. The current
`HeroHOMM3.StartingArmy` contract accepts only creature keys and quantity
ranges; it cannot retain slot inclusion probability or a war-machine endpoint.
Writing only the creature-looking parts would turn a probability-bearing
template into an apparently unconditional army and would be architecturally
false. The patch therefore proposes a typed slot contract and leaves the field
null until the schema/validator can represent the native meaning.

### Scenario rules

`ScenarioHOMM3.StartingBonuses` and `CarryoverRules` now have narrow closed
profiles with validator tests and are populated by the rules patch.
`VictoryConditions` and `LossConditions` have separate closed profiles populated
from the embedded H3M headers. Artifact, creature and resource conditions retain
native IDs beside validated import-key annotations; location conditions retain bounded map
coordinates. No victory/loss rule is inferred from a map title, narrative, or
campaign ordering.

### Other optional prose and mechanics

Full `HEROBIOS.TXT`, specialty prose, building prose, map narrative, and
campaign narrative are not copied. `HeroHOMM3.SpecialtyEffect` remains null-only
by contract. The existing normalized specialty names and relational spell,
skill, creature, building, and campaign links are preserved.

## Reproduction and verification

From the repository root, with the installed game at its default path:

```sh
python3 src/db/tools/research-homm3-native.py
```

The generator uses `src/db/tools/extract-homm3-lod.py`, reads both archives in
place, reparses all 20 selected campaign headers, requires an exact 75-edge set
match with the catalog, requires every guarded fill target to be null, resolves
every embedded native ID to an existing catalog import key, and then writes both
deterministic patches. It also parses all 87 embedded map headers and requires
their dimensions, format and difficulty to match the current map catalog. These
annotations are checked during generation and bundle validation but are not
rewritten to physical SQL identities. A different installation can be supplied with
`--game-root`; alternate review paths can be supplied with `--output` and
`--rules-output`.

After a parent merge applies the patch to a catalog copy, run the repository's
normal JSON-contract, catalog, graph, generated-SQL, and PostgreSQL integration
checks before treating the fills as deliverable database data.
