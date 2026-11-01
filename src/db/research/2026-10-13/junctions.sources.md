# HeroesWatch junction completion review — HOMM1, HOMM2, HOMM4 and HOMM5

Review date: 2026-10-13. Baseline: 176 tables and 40,023 reviewed rows.
This review does not edit `heroeswatch.json`, generated SQL, a live database,
or the SQLDesigner diagram. The companion `junctions.patch.json` is a staged,
evidence-carrying proposal.

## Result

The current catalog already contains the mechanically derivable H1/H2 gold
cost relationships and the sourced dwelling, campaign-scenario, scenario-graph,
upgrade and spell-school edges. The safe patch adds 47 rows:

- four canonical H1 campaign-warlord `Hero` identities;
- four H1 `CampaignHero` relationships;
- eight H5 `Terrain` identities;
- eight shared-PK `TerrainHOMM5` detail rows;
- nine `FactionNativeTerrainHOMM5` relationships (Fortress has two native
  terrains in the source);
- fourteen 3.1 `FactionMagicSchoolHOMM5` relationships: two schools for each
  non-Stronghold faction in the Tribes of the East ruleset snapshot.

There are no scalar fills. Null still means unknown, not none. In particular,
no campaign-hero starting scenario, hero skill, map placement, building
prerequisite, or faction spell was inferred from a name, sort order, class
weight, or broad faction association.

## Status vocabulary

- **C** — complete for the explicitly sourced catalog scope.
- **P** — populated, but broader relationship research remains incomplete.
- **AE** — applicable but empty/incomplete; no safe row was established.
- **NA** — not applicable to that game's mechanics or to the current parent
  catalog.
- **ADD** — supported additions are present in `junctions.patch.json`.
- **X** — resource-family work is owned by the separate resource review.
- **GAP** — faithful representation needs an additional model or JSON
  contract; no lossy row was added.

## All 29 junctions by game

Counts are current pre-patch row counts.

| Junction | HOMM1 | HOMM2 | HOMM4 | HOMM5 | Review conclusion |
|---|---:|---:|---:|---:|---|
| `AdventureObjectCreature` | 7 C | 22 C | 71 C | 60 C | Fixed-roster dwellings are covered. H5 Refugee Camp remains unlinked because its roster is variable. |
| `AdventureObjectFaction` | 4 C | 13 C | 71 C | 32 C | Neutral sites correctly have no faction edge. |
| `ArtifactComponent` | 0 NA | 3 C | 0 NA | 0 NA | H2 Battle Garb of Anduran has its three components. H5 equipped sets use `ArtifactHOMM5.ArtifactSetHOMM5_id`, not component assembly. |
| `ArtifactResourceCost` | 1 X | 0 X | 0 X | 0 X | H5 `GoldValue` is not assumed to be a purchase cost. |
| `BuildingCreature` | 48 C | 114 C | 96 C | 168 C | Every supported fixed dwelling has `Produces` and `Recruits` edges. H4 Creature Portal's variable selection is intentionally unlinked. |
| `BuildingRequirement` | 63 C | 194 C | 0 AE | 0 AE | H4/H5 prerequisite extraction is still required. `TownLevelRequired` does not name a prerequisite building. |
| `BuildingResourceCost` | 185 X | 468 X | 0 X | 0 X | Separate resource review. |
| `BuildingUpgrade` | 12 C | 45 C | 0 NA | 0 AE | H4 dwelling choices are alternatives, not upgrades. H5 building upgrade chains require source-backed extraction. |
| `CampaignHero` | 0 ADD | 0 AE | 26 C | 15 C | Add the four manual-named H1 selectable warlords through canonical `Hero` rows. H2 roles/branches still need review. H4/H5 current sourced protagonist links are covered. |
| `CampaignScenario` | 9 C | 47 C | 70 C | 60 C | Every current scenario belongs to its campaign. |
| `CreatureAbility` | 0 AE | 0 AE | 0 AE | 581 C | H1/H2/H4 creatures have special mechanics, but need sourced `Ability` identities before links. Movement/shots scalar fields are not duplicated as guessed abilities. |
| `CreatureResourceCost` | 30 X | 74 X | 59 X | 177 X | Separate resource review. |
| `CreatureSpell` | 0 NA | 0 AE | 28 C | 60 C | No H2 creature-spell source was established. H4/H5 match their researched spellbook-link sets. |
| `CreatureUpgrade` | 0 NA | 21 C | 0 NA | 112 C | H1 has no upgrade system; H4 creature choices are not upgrade edges. |
| `FactionMagicSchoolHOMM5` | 0 NA | 0 NA | 0 NA | 12 ADD | Preserve the 12 historical `BaseGame` rows and add the complete 14-row `TribesOfTheEast` 3.1 snapshot. Stronghold has no regular-school alignment in that table. |
| `FactionNativeTerrainHOMM5` | 0 NA | 0 NA | 0 NA | 0 ADD | Add nine exact faction/terrain memberships after adding the eight referenced terrain identities. |
| `FactionSpell` | 0 GAP | 0 GAP | 0 NA | 0 AE | Guild-school access and random slots do not entail a deterministic faction/spell roster. H1/H2 would need a guild-level spell-pool model rather than a complete bipartite guess. |
| `GameResource` | 7 X | 7 X | 7 X | 1 X | Separate resource review. |
| `HeroClassAbility` | 0 NA | 0 NA | 0 NA | 901 C | H4 advanced-class formation uses its dedicated primary-skill junction. H5 grouped and ungrouped atoms retain their documented semantics. |
| `HeroClassAbilityRequirementGroup` | 0 NA | 0 NA | 0 NA | 404 C | Every current H5 group has matching atoms and mode. |
| `HeroClassPrimarySkillHOMM4` | 0 NA | 0 NA | 88 C | 0 NA | Covers 36 advanced classes, 11 starting classes, and Archmage's five schools. |
| `HeroSkill` | 0 NA | 0 AE | 0 AE | 0 AE | Class defaults and skill weights are not hero assignments. H2 public lists need a separately preserved row-level source extraction. |
| `LoreFull` | 0 AE | 0 AE | 12 P | 0 AE | H4's 12 current lore rows all link indirectly to campaigns. Broader hero/scenario/map lore remains future research. Missing `Lore` parents in the other games are a content-coverage gap, not proof that lore links are mechanically inapplicable. |
| `MapObjectPresence` | 0 AE | 0 AE | 0 AE | 0 AE | Requires shipped-map parsing or equivalent per-map evidence. Object catalog membership is not placement. |
| `MapTerrain` | 0 AE | 0 AE | 0 AE | 0 AE | Requires per-map evidence. A game's terrain catalog does not identify each map's terrain set. |
| `ScenarioConnection` | 12 C | 54 C | 52 C | 47 C | Current sourced campaign graphs are covered; no edge is inferred only from sort order. |
| `SpellMagicSchool` | 0 NA | 0 NA | 151 C | 74 C | H1/H2 have no magic-school catalog. All H4 spells are linked. H5's six unlinked spells are warcries, not school spells. |
| `SpellResourceCostHOMM5` | 0 NA | 0 NA | 0 NA | 0 X | H5 rune-resource work is owned by the separate resource/manual review. |
| `TownScreenBuilding` | 0 AE | 0 AE | 0 AE | 0 AE | These games have town screens; missing parent rows and building memberships are coverage gaps. Hotspot geometry still requires separate source evidence. |

## Safe derivation checks

`src/db/tools/junction-coverage.mjs` reproduces the counts and checks the only
direct scalar-to-junction derivations in this scope:

- H1 artifact `GoldCost`: 1/1 normalized gold-cost relationship, no mismatch;
- H1 building `GoldCost`: 60/60, no mismatch;
- H2 building `GoldCost`: 165/165, no mismatch;
- H1 creature `GoldCost`: 27/27, no mismatch;
- H2 creature `GoldCost`: 66/66, no mismatch;
- all non-null `CampaignHero.StartingScenario_id` values point to a
  `CampaignScenario` row for the same game and campaign;
- H4 has 151/151 spell-school links;
- H5's only school-unlinked spells are the six cataloged warcries.

Therefore this patch does not duplicate any already-normalized scalar fact.

## H5 additions and source interpretation

The developer-supported 3.1 community manual's **Terrain Types and Effects**
table identifies these exact memberships and movement costs:

| Terrain | Movement cost | Native faction/class |
|---|---:|---|
| Grass | 100% | Haven / Knights; Sylvan / Rangers |
| Dirt | 125% | Necropolis / Necromancers |
| Sand | 150% | Academy / Wizards |
| Lava | 125% | Inferno / Demon Lords |
| Snow | 150% | Fortress / Runemages |
| Dwarven Subterranean | 100% | Fortress / Runemages |
| Taga | 125% | Stronghold / Barbarians |
| Subterranean | 125% | Dungeon / Warlocks |

The source spelling **Taga** is retained instead of silently normalizing it.
The same section states that native heroes ignore the movement penalty and
native creatures receive +1 Attack and +1 Defense in combat.
`IgnoreMovementPenalty=true` and the closed, typed
`CombatBonus={"attack": 1, "defense": 1}` are therefore stored on each
relationship. The JSON contract accepts only integer `attack` and `defense`
deltas within -100 through 100 and rejects extra fields; no SQL table change is
required.

The 3.1 manual's **Faction - Magic School alignments** table supplies a current
Tribes of the East snapshot: Academy (Summoning, Light), Haven (Light, Dark),
Sylvan (Light, Destructive), Fortress (Light, Destructive), Inferno
(Destructive, Dark), Dungeon (Destructive, Summoning), and Necropolis (Dark,
Summoning). Stronghold has no regular-school entries in the same table and uses
warcries instead.

`Ruleset` records the ruleset whose values the row describes; it is not an
introduction-release field. Consequently the patch adds all fourteen pairs as
`TribesOfTheEast`, including Fortress, and leaves the existing twelve
`BaseGame` rows unchanged. Reusing those base rows for 3.1 equality-filtered
queries would silently produce an incomplete seven-faction result. No
`HammersOfFate` row is inferred from the later 3.1 manual.

## H1 campaign-warlord identities

The supplied official H1 manual's Campaign Game section (PDF/printed p. 23)
names the four characters the player can select for the whole campaign and
states their starting castle factions: Lord Ironfist/Knight, Lord
Slayer/Barbarian, Queen Lamanda/Sorceress, and Lord Alamar/Warlock. The patch
therefore creates the four missing generic `Hero` identities and then links
them to `A Strategic Quest` through `CampaignHero`.

The manual proves which castle/faction the player receives, not that each ruler
is a regular recruitable combat hero of the correspondingly named class.
`Hero.HeroClass_id` therefore remains null for all four. Their descriptions
retain the sourced starting-castle association and explicitly identify them as
campaign-ruler rather than regular-recruitable entries.

All four use `CampaignRole=Commander`, the non-branch-specific role available
in the current enum. Any one can become the player's protagonist, while the
others become opposing commanders, so assigning all four `Protagonist` or
`Antagonist` would be false. `StartingScenario_id` remains null because the
manual establishes campaign-wide selection, not a distinct per-warlord
starting-scenario relation.

## Important unresolved work

1. **H2 campaign heroes:** 19 campaign-only heroes exist, but roles and
   conditional branch membership need row-level evidence. Campaign membership
   alone does not establish `StartingScenario_id`.
2. **H2/H4/H5 named-hero skills:** class defaults, JSON skill weights, and
   racial-skill FKs do not entail `HeroSkill` rows.
3. **H4/H5 building graphs:** costs, prerequisites and H5 upgrade edges need
   their own source extraction.
4. **Map junctions:** no large game archives were downloaded. Per-map terrain
   and object placements remain unknown rather than being inferred from map or
   object names.
5. **Variable rosters:** H4 Creature Portal and H5 Refugee Camp cannot be
   represented honestly as fixed `BuildingCreature` or
   `AdventureObjectCreature` rows. If queryable variable pools become a product
   requirement, add a condition/ruleset-bearing pool model instead of false
   fixed edges.

## Sources

- Supplied official H1 manual `manual.c1d7c0b2da69`, Campaign Game,
  PDF/printed p. 23: selectable campaign characters and their starting castle
  classes.
- [Heroes V 3.1 manual](https://h5.heroes.net.pl/uploaded/download/other/Heroes5-Manual-en-3-1.pdf),
  Terrain Types and Effects (printed p. 259) and Faction - Magic School
  alignments (printed p. 182). The repository already treats this community manual as supported
  by Ubisoft and Nival and uses it for the H5 3.1 ruleset.
- `src/db/data/homm1-homm2-catalog.sources.md`: H1/H2 classes, heroes,
  buildings, costs, upgrade graphs and external dwellings.
- `src/db/data/manual-homm1-3.sources.md`: supplied manual comparisons and
  exact H1/H2 scalar cost coverage.
- `src/db/data/touchups-graphs.sources.md`: sourced H1/H2 campaign graph and
  branching semantics.
- `src/db/data/homm4-catalog.sources.md`: H4 classes, buildings and dwellings;
  explicitly excluded prerequisites and map placements.
- `src/db/data/manual-homm4-6.sources.md`: H4/H5 manual reconciliation and H5
  faction-school extraction.
- `src/db/data/homm5-catalog.sources.md` and
  `src/db/data/remaining-homm5.sources.md`: H5 catalog/junction counts and
  stated unresearched fields.

Public engine implementations such as fheroes2 are treated as primary evidence
for their own implemented behavior and as a reproducibility cross-check, not
automatically as original game documentation.

## Validation

The 47 proposed rows were merged into a temporary copy only. Validation passed:

```text
Valid HeroesWatch data bundle: 176 tables, 40070 rows.
Built heroeswatch-junction-catalog.sql (40070 rows). No database connection was opened.
```

No repository catalog, generated SQL, live database or diagram was changed.
