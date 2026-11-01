# Heroes VII factions and expansions

Research date: 2026-09-12. Cumulative data: [heroeswatch.json](heroeswatch.json).
Scope: the six original factions, Lost Tales of Axeoth, and Trial by Fire.
Fortress is the seventh faction, introduced by Trial by Fire.

## Sources and entered values

The faction references below supply both the required alignment and racial
skill. They are secondary references. Alignment uses their coarse faction
classification; it does not describe every hero's behavior or diplomacy.

| Faction reference | Alignment | Racial skill | Introduced in |
|---|---|---|---|
| [Haven](https://mightandmagic.fandom.com/wiki/Haven_%28H7%29) | Good | Righteousness | Base game |
| [Academy](https://mightandmagic.fandom.com/wiki/Academy_%28H7%29) | Good | Metamagic | Base game |
| [Necropolis](https://mightandmagic.fandom.com/wiki/Necropolis_%28H7%29) | Evil | Necromancy | Base game |
| [Stronghold](https://mightandmagic.fandom.com/wiki/Stronghold_%28H7%29) | Neutral | Bloodrage | Base game |
| [Sylvan](https://mightandmagic.fandom.com/wiki/Sylvan_%28H7%29) | Good | Nature's Revenge | Base game |
| [Dungeon](https://mightandmagic.fandom.com/wiki/Dungeon_%28H7%29) | Evil | Shroud of Malassa | Base game |
| [Fortress](https://mightandmagic.fandom.com/wiki/Fortress_%28H7%29) | Neutral | Rune Magic | Trial by Fire |

- [The Trial by Fire product page](https://store.steampowered.com/app/445310/)
  identifies it as a standalone expansion and confirms the new dwarf Fortress
  faction and Rune Magic.
- [The publisher's Unity announcement](https://store.steampowered.com/oldnews/?appgroupname=Might+%26+Magic%C2%AE+Heroes%C2%AE+VII+Complete+Edition&appids=321960&feed=steam_community_announcements&headlines=1),
  dated 2016-02-18, introduces the first free Lost Tales of Axeoth campaign.
  [Ubisoft's Every Dog Has His Day announcement](https://steamcommunity.com/app/321960/discussions/0/368542585858718723/),
  dated 2016-04-14, identifies the second episode and completion of the package.
  [The Lost Tales reference](https://mightandmagic.fandom.com/wiki/Lost_Tales_of_Axeoth)
  also groups these two campaigns under that package.

All seven racial skills support Grandmaster mastery. This is confirmed by
the skill entries or a class that can reach that rank:
[Righteousness](https://mightandmagic.fandom.com/wiki/Righteousness_%28H7%29),
[Enchanter's Metamagic](https://mightandmagic.fandom.com/wiki/Enchanter_%28H7%29),
[Necromancy](https://mightandmagic.fandom.com/wiki/Necromancy_%28H7%29),
[Warmonger's Bloodrage](https://mightandmagic.fandom.com/wiki/Warmonger_%28H7%29),
[Starsinger's Nature's Revenge](https://mightandmagic.fandom.com/wiki/Starsinger),
[Shroud of Malassa](https://mightandmagic.fandom.com/wiki/Shroud_of_Malassa_%28H7%29),
and [Runelord's Rune Magic](https://mightandmagic.fandom.com/wiki/Runelord_%28H7%29).
`MaxMastery` records the skill's maximum available rank, not a starting rank
or a claim that every hero class can attain it.

## Schema and format mapping

- One `Game` row uses `SeriesCode: "HOMM7"` and editorial `DisplayOrder: 7`.
- Three `Expansion` rows represent the base game (`BASE`, `Kind: "BaseGame"`),
  Lost Tales of Axeoth (`LTOA`), and Trial by Fire (`TBF`). The last two use
  `Kind: "Expansion"`, the existing type for gameplay content packages.
  Descriptions distinguish the free campaign package from the standalone
  expansion.
- Lost Tales of Axeoth is one package covering Unity and Every Dog Has His
  Day. This follows the repository's existing `LostTalesOfAxeoth` edition
  label in `SoundtrackHOMM7`. It reuses existing factions. Individual campaign
  records and compilation editions are outside this faction-entry scope.
- Seven generic `Faction` rows hold names, codes, game scope, and introduction
  provenance. Their seven `FactionHOMM7` rows reuse the faction `_key` and
  store the required `Alignment` and `RacialSkill_id` relationship.
- Seven generic `Skill` rows hold the racial skill identities and provenance.
  Seven shared-PK `SkillHOMM7` rows classify them as `SkillKind: "Faction"`
  with `MaxMastery: "Grandmaster"`. They belong to HOMM7 even when an earlier
  game uses the same displayed skill name.
- Fortress and Rune Magic reference `homm7.expansion.tbf`. All six original
  factions and their skills reference `homm7.expansion.base`.
- The [Rune Magic reference](https://mightandmagic.fandom.com/wiki/Rune_Magic)
  distinguishes Heroes VII's skill from Heroes V's Runelore. This batch uses
  the Heroes VII name. The architecture models these as skills, unlike the
  separate `AbilityHOMM6` faction abilities used for Heroes VI.
- Keys are stable dotted strings, foreign keys reference the appropriate
  parent `_key`, and independent generated database IDs are omitted. Enum
  strings retain the exact declared spelling and case. Nature's Revenge uses
  an ordinary apostrophe in its name and `NATURES_REVENGE` as its code.
- Release dates, media, descriptions beyond package scope, magic-school
  references, and detailed mastery effects remain null where not entered.
  In particular, no inferred relational IDs are embedded in `EffectByMastery`.

The batch adds 32 rows: 1 Game, 3 Expansion, 7 Faction, 7 FactionHOMM7,
7 Skill, and 7 SkillHOMM7. At the time of this batch, the cumulative bundle
contained 194 records and retained all 173 table arrays.

## Validation and database application

```sh
node src/db/tools/validate.mjs src/db/data/heroeswatch.json
```

Validation output at the time of this batch:

```text
Valid HeroesWatch data bundle: 173 tables, 194 rows.
```

Separate checks confirmed the six-plus-one release split, the seven distinct
faction/skill mappings, shared parent identities, same-game references,
faction skill classification, and Grandmaster maximum mastery. The SQL payload
matches all 32 new JSON rows, and all 162 earlier JSON records match the
previous commit exactly.

[homm7-factions.sql](homm7-factions.sql) contains a snapshot of the 32 rows.
It resolves generated or existing IDs, reuses parent IDs for detail rows,
preserves other content, and rejects conflicting existing facts. The entire
batch runs in one transaction with foreign keys checked before commit.

Use [the faction review](homm7-factions.review.sql) to inspect the seven
factions, alignments, skills, maximum mastery, and introduction releases.
The query requires same-game skill and release references, faction skill
classification, and matching faction/skill provenance.
Use [the release review](homm7-releases.review.sql) to inspect the three
release records. JSON editing and SQL application are separate operations.

On 2026-09-12, the batch was applied successfully to local PostgreSQL 18,
database `HeroesWatch.net`, through its saved pgAdmin 4 connection. Foreign
keys were checked before commit. Independent pgAdmin query sessions confirmed
the three committed release records and all seven factions with the expected
alignments, racial skills, Grandmaster mastery, and release provenance.
