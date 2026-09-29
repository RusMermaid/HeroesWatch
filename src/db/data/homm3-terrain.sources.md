# Heroes III terrain additions

Reviewed on 2026-09-29. Adds 13 Terrain identities and matching TerrainHOMM3
details: the three missing base surfaces and ten classic magical overlays.
The seven existing faction terrains are preserved unchanged. After merging,
the Heroes III terrain catalog contains ten base surfaces and ten overlays.

## Sources

- [Terrain inventory and effects](https://heroes.thelazy.net/index.php/Terrain):
  base surfaces, magical overlays, release attribution and original rules.
- [Movement](https://heroes.thelazy.net/index.php/Movement): movement-point units
  and the effect of direction, terrain, roads and other modifiers.

| Import key suffix | Source section |
|---|---|
| sand | [Sand](https://heroes.thelazy.net/index.php/Terrain#Basic_Terrains) |
| water | [Water](https://heroes.thelazy.net/index.php/Terrain#Basic_Terrains) |
| rock | [Rock](https://heroes.thelazy.net/index.php/Terrain#Basic_Terrains) |
| magic.plains | [Magic Plains](https://heroes.thelazy.net/index.php/Terrain#Magic_Plains) |
| cursed.ground | [Cursed Ground](https://heroes.thelazy.net/index.php/Terrain#Cursed_Ground) |
| rockland | [Rockland](https://heroes.thelazy.net/index.php/Terrain#Rockland) |
| fiery.fields | [Fiery Fields](https://heroes.thelazy.net/index.php/Terrain#Fiery_Fields) |
| lucid.pools | [Lucid Pools](https://heroes.thelazy.net/index.php/Terrain#Lucid_Pools) |
| magic.clouds | [Magic Clouds](https://heroes.thelazy.net/index.php/Terrain#Magic_Clouds) |
| holy.ground | [Holy Ground](https://heroes.thelazy.net/index.php/Terrain#Holy_Ground) |
| evil.fog | [Evil Fog](https://heroes.thelazy.net/index.php/Terrain#Evil_Fog) |
| clover.field | [Clover Field](https://heroes.thelazy.net/index.php/Terrain#Clover_Field) |
| favorable.winds | [Favorable Winds](https://heroes.thelazy.net/index.php/Terrain#Favorable_Winds) |

## Mapping and limits

The prefix for every row is `homm3.terrain.`. Generic rows own identity and
classification; the same key identifies each title-specific detail.
`Effect.rulesText` holds a short rule summary without embedded entity IDs.
Magic-school identities remain in MagicSchool; a text effect does not create
another school catalog or an unsupported terrain-school relation.

`MovementCost` uses movement points per ordinary straight, off-road tile
before modifiers. Only Sand receives a numeric value. Water depends on travel
mode, Rock is impassable, and overlays modify the underlying surface, so their
movement cost remains null. No zero-cost traversal is inferred from missing data.

Rules describe classic Complete/SoD mechanics. Cursed Ground originally also
blocked level-1 hero spells in RoE; its RoE provenance does not imply the
later effect applied in that release. The elemental overlays preserve the
original distinction between hero and creature spellcasting. HotA terrains
and behavior changes are excluded. Roads, rivers and decorative sprite
variants remain outside this terrain addition.

`research/homm3-terrain.json` is a merge fragment. It must be merged into the
cumulative bundle before validation and SQL generation.
