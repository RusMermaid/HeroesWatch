# Heroes VII final source-recovery pass

Research date: 2026-10-13. This pass is deliberately data-first: it searches
for a small, auditable final source for the remaining H7 values instead of
copying secondary tables into the catalog. It found the official depot's exact
small package inventory, but not publicly readable package bytes or a complete
row-level extraction. No catalog, schema, database, GitHub, or existing
research file was changed.

## Concrete result

The public [SteamDB depot manifest](https://steamdb.info/depot/321961/subs/)
identifies the final-looking H7 content depot as depot `321961`, build
`11478242`, manifest `1024892792009479968` (last public update 2023-06-15).
The depot itself is large, but the relevant editor/data packages are small and
separately named. SteamDB is only a third-party manifest index; it is not
Ubisoft or Valve and does not expose the field values in this audit.

The [Ubisoft Modding Manual](https://ubistatic-a.akamaihd.net/0004/prod/images/160407_LT1_Modding/ModdingManual.pdf)
confirms that H7 content is data-driven through archetypes/packages. The
[Ubisoft Editor Manual](https://ubistatic-a.akamaihd.net/0004/prod/images/160407_LT1_Modding/EditorManual.pdf)
confirms that hero enablement is map/player-scoped. Those primary manuals tell
us how to interpret an export; they do not publish the missing row values.

## Small source files to obtain, in priority order

### 1. Warfare units, abilities, and building recruitment

Request these exact files from an existing licensed H7 install/editor export:

| File | Manifest size | Needed for |
|---|---:|---|
| `MMH7Game/CookedPC/Editor/Templates/Warfare/H7WarfareUnits.upk` | 40.65 KiB | 19 warfare archetypes, rank/stat/effect references |
| `MMH7Game/CookedPC/Editor/Templates/Warfare/H7WarfareUnits_Fortress.upk` | 9.66 KiB | Fortress warfare additions |
| `MMH7Game/CookedPC/Editor/Templates/Warfare/H7WarfareUnitAbilities.upk` | 2.43 MiB | vanilla warfare ability objects |
| `MMH7Game/CookedPC/Editor/Templates/Warfare/H7WarfareUnitAbilities_F.upk` | 460.09 KiB | Fortress warfare abilities |
| `MMH7Game/CookedPC/Editor/Templates/Buildings/H7TownBuildingDungeon.upk` | 278.09 KiB | Dungeon recruitment references |
| `.../H7TownBuildingSylvan.upk` | 266.25 KiB | Sylvan recruitment references |
| `.../H7TownBuildingsAcademy.upk` | 259.90 KiB | Academy recruitment references |
| `.../H7TownBuildingsFortress.upk` | 289.05 KiB | Fortress recruitment references |
| `.../H7TownBuildingsHaven.upk` | 323.74 KiB | Haven recruitment references |
| `.../H7TownBuildingsNecropolis.upk` | 399.13 KiB | Necropolis recruitment references |
| `.../H7TownBuildingsStronghold.upk` | 362.78 KiB | Stronghold recruitment references |

The building files are required even where a secondary article appears to name
a mapping. A building name or a resource cost is not itself a `BuildingCreature`
foreign-key edge. Only an explicit package archetype reference or recruitment
array should create that junction row.

Do not flatten rank vectors into the existing scalar `CreatureHOMM7` row. Do not
translate a printed stationary value into `Ground`, `Flying`, or `Teleporting`,
and do not translate textual `Large`/`Huge` into occupied combat squares.

### 2. Creature ability graph

Request:

| File | Manifest size | Needed for |
|---|---:|---|
| `MMH7Game/CookedPC/Editor/Templates/CreatureAbilities/H7CrAbilitiesDefault.upk` | 539.46 KiB | default ability objects |
| `MMH7Game/CookedPC/Editor/Templates/CreatureAbilities/H7CrAbilitiesSpecial.upk` | 4.02 MiB | special ability objects |
| `MMH7Game/CookedPC/Editor/Templates/Creatures/{Academy,Dungeon,Fortress,Haven,Necropolis,Neutral,Stronghold,Sylvan}/Creature_*.upk` | individual packages, mostly 5.74–9.47 KiB | explicit creature-to-ability references |

The current audit is **137 detailed H7 creatures without links**, not “137
missing relationships.” One creature may have zero, one, or many ability edges.
Create a `CreatureAbility` row only when the creature archetype explicitly
references a named ability object. Ability names alone are not enough to infer
passive/triggered/activated semantics.

### 3. Nine HeroClassHOMM7 detail rows

Request:

| File | Manifest size |
|---|---:|
| `MMH7Game/CookedPC/Data/H7HeroClasses.upk` | 160.83 KiB |
| `MMH7Game/CookedPC/Data/H7HeroClasses_2.upk` | 31.50 KiB |

The affected keys are:

`archon`, `embalmer`, `engraver`, `firebrander`, `hell.knight`, `jarl`,
`runelord`, `thane`, and `warlord` under `homm7.heroclass.*`.

The localization companions
`Localization/Content/HUN/H7HeroClasses.HUN` (8.34 KiB) and
`H7HeroClasses_2.HUN` (930 B) are useful for names only. They cannot supply
growth percentages or skill weights. All four growth fields must come from the
same final package revision; do not combine conflicting dated secondary tables.

### 4. 110 missing HeroHOMM7/catalog eligibility values

Request the global configuration and all small hero archetype packages:

| File | Manifest size | Scope |
|---|---:|---|
| `MMH7Game/CookedPC/Data/H7Config.upk` | 91.25 KiB | global availability/config candidate |
| `.../Editor/Templates/Heroes/H7Heroes.upk` | 185.27 KiB | standard hero archetypes |
| `.../H7Heroes_2.upk` | 34.42 KiB | additional hero archetypes |
| `.../H7Heroes_3.upk` | 25.95 KiB | additional hero archetypes |
| `.../H7DefaultHeroes.upk` | 111.30 KiB | default hero set |
| `.../H7DefaultHeroes_2.upk` | 20.98 KiB | additional default heroes |
| `.../H7DuelHeroes.upk` | 75.64 KiB | duel availability scope |
| `.../H7StoryHeroes.upk` | 70.74 KiB | campaign/story scope |
| `.../H7StoryHeroes_2.upk` | 34.80 KiB | additional story heroes |
| `.../H7Councilors.upk` | 19.17 KiB | councilor/story scope |

The export must distinguish package-level catalog membership from the editor's
map/player availability. The 110 unverified heroes must not be assigned global
`IsHallHero = false` merely because they are absent from the 22-row screenshot.
If the source only provides map/player flags, that is evidence for a future
map/player junction, not a global catalog fill.

## What was and was not found

Public search found no raw official package export and no complete audited
JSON/CSV dataset for these H7 rows. The public GitHub H7 modding repository
([LukaOo/Might-And-Magic-Heroes-VII-Mods](https://github.com/LukaOo/Might-And-Magic-Heroes-VII-Mods))
contains tooling/UDK scripts, not the official data values. UCP and other
community-mod packages are explicitly excluded as vanilla truth because they
change abilities, stats, costs, or availability.

The H6 side search found no stronger small official row source than the
existing evidence-only `heroes6.patch.json`; it is unchanged. H7 remains the
priority and is blocked only on the exact source packages above.

## Merge gate

This follow-up emits zero additions and zero fills. It is a precise request for
the source files needed to finish the data correctly, not a claim that the
missing catalog work is complete. Once a small export is supplied, the next
pass can hash the files, parse the relevant archetypes, record package paths
and object names as evidence, and emit only deterministic rows.
