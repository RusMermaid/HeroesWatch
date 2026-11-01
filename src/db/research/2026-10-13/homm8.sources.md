# Heroes VIII / Olden Era completion evidence

Review date: **2026-10-13**. Target snapshot: **Olden Era Early Access,
Steam build 25061458**, extracted on 2026-09-29. `HOMM8` is the repository's
series code for Olden Era.

## Result

`homm8.patch.json` adds the one detail row whose every required field can still
be proved from retained build-specific evidence:

- `CampaignHOMM8` for Main Story: available, one released act, with the
  branching structure already represented by `CampaignScenario` and
  `ScenarioConnection`.

The proposed Tutorial, Challenges, and 21 `ScenarioHOMM8` rows were withdrawn
after a field-level review. The architecture requires values that the retained
evidence does not state: an act count for non-act tutorial groupings, semantic
act/mission numbers, `GameMode`, and negative hotseat/multiplayer/matchmaking/
ranked flags. Source-key numbering and absence of a field are not evidence.

The patch does not change the shared catalog, schema, cumulative JSON, generated
SQL, or a live database. It is an additive research artifact for the integration
stage. All `_key` values reuse their existing shared-PK parents.

## Retained build-specific sources

The earlier local extraction is no longer present, but its evidence is retained
in the repository:

- `src/db/data/touchups-evidence.json` records each Olden Era `Map`, `Scenario`,
  `CampaignScenario`, `ScenarioConnection`, and relevant `CampaignHero` row with
  its original `campaigns/*/storyHub.json` or mission source.
- `src/db/data/touchups-graphs.sources.md` documents the 3 campaigns, 21
  scenarios, and 20 scenario connections derived from build 25061458.
- `src/db/data/remaining-homm8.sources.md` identifies the same installed build
  and documents the existing skills, spells, creatures, artifacts, adventure
  objects, campaign identities, and source paths.

The official game-files guide says Core.zip contains four directories and then
states: "campaigns is single-player data (including tutorials)". It also says
the `DB` JSON files are farmed by Obelisk Bot into the official Cargo data:

- <https://wiki.hoodedhorse.com/Heroes_of_Might_and_Magic_Olden_Era/Help:Game_Files>

Those statements support the source family and positive single-player status;
they do not independently prove every negative per-scenario mode flag. No
current balance value is copied into the build-25061458 patch.

## Official game-data revision findings

The official wiki exposes game-derived Cargo pages with native IDs. Their
revision boundary matters:

The official patch-data procedure tells maintainers to refresh Cargo from game
data and compare the previous and latest `Core.zip` whenever a patch is
applied. That establishes game-file provenance, but the Cargo revision itself
does not expose the Steam build number needed for an exact equality claim.

- `Data:Law` oldid 14065 is the initial Obelisk-bot upload from **2026-05-13
  02:36**. It exposes production/test Law IDs and describes a five-tier tree.
- `Data:Resource` oldid 14420 is the initial Obelisk-bot upload from
  **2026-05-13 02:48**. It lists native IDs including `astrology_exp`,
  `faction_laws_points`, and `starDust`.
- The individual native-ID pages at oldids 14421, 14424, and 14434 preserve
  those three identities from the same upload.
- The current `Data:CargoCoverage` page explicitly says it represents the
  "latest extract". It cannot be assumed to match the target 2026-09-29
  snapshot.
- `Data:Unit/angel` oldid 41239 is dated **2026-09-30 16:45**, one day after
  the target snapshot, and exposes native active `angel_1` and passive
  `angel_passive_1` ability IDs. `Data:Unit/angel_upg` oldid 41390 is dated
  **2026-10-02 20:46** and exposes `angel_upg_1`, `angel_upg_2`, and
  `angel_upg_passive_1`.

These May revisions predate build 25061458. They are strong identity
corroboration, especially because the retained September extractor also reads
`starDust`, but they are not used for September balance values or ability
membership.

The near-target unit revisions make official Cargo a promising lightweight
source for creature-ability junctions. They still do not state the source Steam
build, so a revision-to-build link is required before using them as a complete
build-25061458 ability snapshot.

A version-alignment sample is stronger: the official Angel article revision
38099 is dated **2026-08-06**, before the target snapshot. Its 225 HP, 30
Attack, 30 Defense, 50-75 Damage, 8 Initiative, and 4 Speed all match the
retained build-25061458 row. The same revision identifies Forging Perfection,
an alternative melee attack, and Refract and Reflect at one Focus Charge with a
one-round cooldown. This supports those Angel facts, but one matching creature
is not evidence that all 146 ability graphs were unchanged.

- <https://wiki.hoodedhorse.com/Heroes_of_Might_and_Magic_Olden_Era/index.php?oldid=14065&title=Data:Law>
- <https://wiki.hoodedhorse.com/Heroes_of_Might_and_Magic_Olden_Era/index.php?oldid=14420&title=Data:Resource>
- <https://wiki.hoodedhorse.com/Heroes_of_Might_and_Magic_Olden_Era/Data:CargoCoverage>
- <https://wiki.hoodedhorse.com/Heroes_of_Might_and_Magic_Olden_Era/index.php?oldid=41239&title=Data:Unit/angel>
- <https://wiki.hoodedhorse.com/Heroes_of_Might_and_Magic_Olden_Era/index.php?oldid=41390&title=Data:Unit/angel_upg>
- <https://wiki.hoodedhorse.com/Heroes_of_Might_and_Magic_Olden_Era/index.php?oldid=38099&title=Angel>
- <https://wiki.hoodedhorse.com/Heroes_of_Might_and_Magic_Olden_Era/Help:Applying_Patches>

This also exposes two architecture blockers, rather than merely missing values:

1. `AstrologyHOMM8` requires FKs to Astrology Point and Insight resources, but
   the shared `Resource`/`GameResource` catalogs omit source parents for
   `astrology_exp` and `starDust`.
2. `AstrologyHOMM8` requires a `NeutralMagicSchool_id`, while the retained
   build extractor intentionally creates four regular schools and leaves
   neutral spells without an invented fifth school. The required FK must be
   reconciled with the actual source model before a row is inserted.

## Existing H8 relationship coverage

The current cumulative JSON already contains the following H8 relationships:

| Relationship | Rows |
|---|---:|
| `HeroSkill` | 210 |
| `SpellMagicSchool` | 72 |
| `CreatureUpgrade` | 84 |
| `CreatureResourceCost` | 159 |
| `BuildingRequirement` | 180 |
| `BuildingUpgrade` | 88 |
| `BuildingCreature` | 168 |
| `CampaignScenario` | 21 |
| `ScenarioConnection` | 20 |
| `CampaignHero` | 4 |

Thus the building requirement, upgrade, and recruitment junction families are
not empty. The remaining structural gaps are `CreatureAbility`,
`HeroClassAbility`, and `TownScreenBuilding`; all currently have zero H8 rows.

The current H8 detail coverage is 180 of 288 `Ability` identities, all 146
`Creature` identities, and all 206 `Building` identities. Of the 180 ability
details, 159 optional `Effect` fields remain null; all 206 optional building
`Effect` fields remain null. Null optional prose is not treated as a broken FK,
but active/focus classification and junction absence are material coverage gaps.

## Why the other empty bands are not populated here

The schema intentionally makes the following fields non-null. Filling them from
entity names, generic display metadata, or newer wiki balance would create
false precision and could mix a later Early Access patch into build 25061458.

| Target | Required evidence not retained |
|---|---|
| `CampaignHOMM8` tutorial groups | `AvailableActCount` is required, but non-act tutorial groupings do not prove zero rather than inapplicable |
| `ScenarioHOMM8` | Mission metadata explicitly defining act/mission numbers, game mode, and hotseat/multiplayer/matchmaking/ranked support |
| `GameHOMM8` and `Patch` | App manifest plus build global settings for focus conversion/cap, maximum hero skills, Law Seal cap, and each Law tier threshold |
| `ResourceHOMM8` | Per-resource definitions proving role, scope, tradeability, mine production, persistence, and default income; shared parents are also missing for `astrology_exp` and `starDust` |
| `MagicSchoolHOMM8` | Build definitions proving Observatory/Astrology participation and the exact meaning of maximum spell level |
| `AstrologyHOMM8` | Insight thresholds, unlock/upgrade rules, and reconciliation of the required neutral-school FK with the four-school source model |
| `MapHOMM8` | Campaign map definitions proving level count, underground state, and every supported-mode flag |
| `AbilityHOMM8` / `CreatureAbility` | Creature and hero ability definitions proving activity, Focus cost/gain, cooldown, target restrictions, and actual membership |
| `HeroClassAbility` | Class/skill prerequisite definitions, including grouped `All`/`Any` semantics |
| `TownScreenBuilding` | Town layout coordinates and placement definitions |

Current official wiki pages confirm that these systems exist, but are not used
as substitutes for the missing snapshot because they may describe a newer
balance revision:

- <https://wiki.hoodedhorse.com/Heroes_of_Might_and_Magic_Olden_Era/Resources>
- <https://wiki.hoodedhorse.com/Heroes_of_Might_and_Magic_Olden_Era/Focus>
- <https://wiki.hoodedhorse.com/Heroes_of_Might_and_Magic_Olden_Era/Laws>

## Minimal source package needed to finish the blocked rows

A full game download is not required for the next pass. The smallest useful
input is the build-25061458 `Core.zip`, or an extracted subset containing:

1. `DB/units/units_logics` and the referenced creature ability definitions;
2. `DB/heroes_abilities`, `DB/heroes_skills`, and prerequisite definitions;
3. `DB/magics` plus Magic Observatory and Astrology configuration;
4. resource definitions containing `gold`, `wood`, `ore`, `gemstones`,
   `crystals`, `mercury`, `dust`, `graal`, `astrology_exp`, and `starDust`;
5. `DB/objects_logic/cities` including requirements, hires, choices, and layout;
6. retained campaign mission/map JSON and `generator` templates;
7. `Lang/english/texts` for display labels;
8. `appmanifest_3105440.acf` to prove the build number.

The archive or extracted directory should be supplied locally. It must not be
committed: raw game data, localization prose, and artwork stay outside the
repository; only normalized facts and per-row evidence belong in the patch.

## Integration rules

- Apply catalog/shared parents before shared-PK detail rows.
- Reuse the existing `_key`; do not allocate a second identity.
- Validate every H8 cross-game FK against `homm8.game`.
- Use one `*_cid` row per real junction edge and preserve the composite unique
  business key.
- Do not create a generic "creature ability" row merely because an ability name
  appears in prose; membership must come from a unit definition.
- Do not infer `All` versus `Any` prerequisite groups.
- Re-run the repository validator and PostgreSQL import in a fresh temporary
  database before merging the patch into `heroeswatch.json`.
