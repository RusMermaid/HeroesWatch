# Heroes VI factions and expansions

Research date: 2026-09-12. Cumulative data: [heroeswatch.json](heroeswatch.json).
Scope: the original game, Pirates of the Savage Sea, Danse Macabre, and
Shades of Darkness. The faction roster contains five base-game factions
plus Dungeon, introduced in Shades of Darkness.

## Sources

- [Heroes VI release/faction overview](https://mightandmagic.fandom.com/wiki/Might_%26_Magic%3A_Heroes_VI):
  the five original factions, Dungeon's expansion introduction, and the two
  adventure packs. This is a secondary reference.
- [Steam's Shades of Darkness release announcement](https://store.steampowered.com/news/10531/):
  the Dungeon and Necropolis campaigns in the expansion.
- [Steam's Pirates of the Savage Sea announcement](https://store.steampowered.com/oldnews/8390?l=english)
  and [Steam's Danse Macabre product entry](https://help.steampowered.com/en/wizard/HelpWithGameTechnicalIssue?appid=48232):
  the names and DLC status of the adventure packs.
- [Pirates of the Savage Sea guide introduction](https://www.gamepressure.com/mightandmagicheroesvipiratesofthesavagesea/):
  its Stronghold campaign. [Danse Macabre overview](https://www.mobygames.com/game/58033/might-magic-heroes-vi-danse-macabre/)
  identifies the second adventure pack and its Sandro story.
- The original [Heroes VI manual, reproduced on Scribd](https://www.scribd.com/document/265297420/Manual-Might-And-Magic-Heroes-6-ENG-pdf),
  Faction Unique Buildings, printed page 24: each faction offers four unique
  buildings, but only two may be built in one town. The stored limit is 2.
- The six faction-ability references:
  [Guardian Angel](https://mightandmagic.fandom.com/wiki/Guardian_Angel_%28H6%29),
  [Gating](https://mightandmagic.fandom.com/wiki/Gating_%28H6%29),
  [Necromancy](https://mightandmagic.fandom.com/wiki/Necromancy_%28H6%29),
  [Honor](https://w.atwiki.jp/homm/pages/192.html),
  [Bloodrage](https://mightandmagic.fandom.com/wiki/Bloodrage_%28H6%29), and
  [Shroud of Malassa](https://mightandmagic.fandom.com/wiki/Shroud_of_Malassa_%28H6%29).
  These identify the respective faction, activation, and broad combat effect.
  The [faction-ability system reference](https://w.atwiki.jp/homm/pages/194.html)
  explains their combat activation and gauge usage.

## Entered faction values

| Faction | Faction ability | UniqueBuildingLimit | Introduced in |
|---|---|---:|---|
| Haven | Guardian Angel | 2 | Base game |
| Inferno | Gating | 2 | Base game |
| Necropolis | Necromancy | 2 | Base game |
| Sanctuary | Honor | 2 | Base game |
| Stronghold | Bloodrage | 2 | Base game |
| Dungeon | Shroud of Malassa | 2 | Shades of Darkness |

Pirates of the Savage Sea and Danse Macabre add campaigns within the existing
faction roster. No Pirate, Sandro, or other invented faction is added.
Faction identities are reused across releases; introduction provenance is
stored in the generic `Faction` row.

## Schema and format mapping

- One `Game` row uses `SeriesCode: "HOMM6"` and editorial `DisplayOrder: 6`.
- Four `Expansion` rows use `BASE` (`Kind: "BaseGame"`), `POTSS`, `DM`, and
  `SOD` (each `Kind: "Expansion"`). Adventure packs are normalized to the
  existing expansion type; the schema has no `AdventurePack` ENUM value.
  Descriptions distinguish the two DLC packs from the standalone expansion.
- `SOD` means Shades of Darkness within HOMM6. The HOMM3 Shadow of Death
  release is a separate game-scoped record with its own `_key`.
- Six generic `Faction` rows own names, codes, game scope, and provenance.
  Six `FactionHOMM6` rows reuse the faction `_key`, reference the appropriate
  ability, and store `UniqueBuildingLimit: 2` as a JSON number.
- Six generic `Ability` rows hold the names and short, non-quantitative
  descriptions. Six shared-PK `AbilityHOMM6` rows classify them as
  `AbilityKind: "Faction"` with `IsActive: true`.
- All faction and ability references are real foreign-key relationships
  within HOMM6. No IDs or extra fields are hidden in mechanics JSON.
- Ability rank, branch, reputation, cooldown, mana cost, and detailed gauge
  formulas are outside this faction-entry scope and remain null. A rank-varying
  mechanic is not reduced to one guessed scalar value. Release dates and
  media references also remain null.
- The faction detail schema does not declare alignment, native terrain,
  resource, or magic-guild fields. None are invented for this batch.

The batch adds 29 rows: 1 Game, 4 Expansion, 6 Faction, 6 FactionHOMM6,
6 Ability, and 6 AbilityHOMM6. The cumulative bundle contains 162 records and
retains every one of the 173 table arrays.

## Validation and database application

```sh
node src/db/tools/validate.mjs src/db/data/heroeswatch.json
```

Validation output:

```text
Valid HeroesWatch data bundle: 173 tables, 162 rows.
```

Separate checks confirmed the five-plus-one release split, the six distinct
faction/ability mappings, shared parent identities, same-game references,
the limit of two buildings, and active faction-ability classification. The
SQL payload matches all 29 new JSON rows, and all 133 earlier JSON records
match the previous commit exactly.

[homm6-factions.sql](homm6-factions.sql) contains a snapshot of these 29 rows.
It resolves generated or existing IDs, reuses parent IDs for detail rows,
preserves other content, and rejects conflicting existing facts. The complete
batch is applied in one transaction with foreign keys checked before commit.

Use [the faction review](homm6-factions.review.sql) to inspect the six factions
and their abilities, and [the release review](homm6-releases.review.sql) to
inspect the original game and its three add-ons. JSON editing and SQL
application remain separate operations.

On 2026-09-12, the batch was applied successfully to local PostgreSQL 18,
database `HeroesWatch.net`, through its saved pgAdmin 4 connection. Foreign
keys were checked before commit, and the post-commit query returned all six
factions with the expected abilities and building limits.
A separate pgAdmin session confirmed the four committed release records,
including the two adventure packs and Shades of Darkness.
Another fresh session confirmed all six factions, their same-game ability
references, active faction classification, building limit of 2, and original
release provenance after commit.
