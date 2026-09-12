# Heroes IV factions and non-town creatures

Research date: 2026-09-12. Content: [heroeswatch.json](heroeswatch.json).
Ruleset: the unmodified game with The Gathering Storm and Winds of War
installed. No Equilibris, Arena, or Ultimate balance changes are included.

## Sources

- The original [Heroes IV manual, reproduced by ManualMachine](https://manualmachine.com/gamespc/heroesofmightandmagiciv/1119181-user-manual/),
  printed pages 31, 36, 43, and 45: native terrain, town alignments, alliances,
  and magic guilds.
- The original [The Gathering Storm manual, reproduced by ManualShelf](https://www.manualshelf.com/manual/games-pc/heroes-of-might-and-magic-iv-the-gathering-storm/user-guide-english.html),
  New Creatures section: Goblin Knight, Evil Sorceress, Gargantuan, and Dark
  Champion introduction and statistics.
- [Jaskinia Behemota's original Heroes IV neutral creature tables](https://h4.heroes.net.pl/jednostki/neutralne):
  complete roster, melee statistics, movement abilities, and expansion labels.
  This is the original-game section; the site lists Equilibris separately.
- [Age of Heroes neutral tables, mirrored by Ring of Saturn](https://www.ringofsaturn.com/games/heroes4/creatures_neutral.shtml):
  cross-check for ten base-game external creatures and the inability to
  recruit Mermaid and Sea Monster.
- [Heroes Portal: Winds of War creatures](https://heroesportal.net/library/heroes-4-winds-units):
  Catapult, Frenzied Gnasher, and Megadragon statistics and introduction.
- [Heroes IV overview](https://mightandmagic.fandom.com/wiki/Heroes_of_Might_and_Magic_IV):
  non-town creatures retain alignment affiliations; the eight Creature Portal
  creatures are outside the standard town lineups; creatures have no upgrades.
- [Ice Demon](https://mightandmagic.fandom.com/wiki/Ice_demon) and
  [Evil Sorceress](https://mightandmagic.fandom.com/wiki/Evil_sorceress):
  cross-checks for external recruitment, statistics, and teleportation.
- [The Gathering Storm overview](https://mightandmagic.fandom.com/wiki/Heroes_of_Might_and_Magic_IV%3A_The_Gathering_Storm)
  and [Winds of War walkthrough introduction](https://gamefaqs.gamespot.com/pc/563599-heroes-of-might-and-magic-iv-winds-of-war/faqs/71413):
  the four Gathering Storm creatures receive adventure-map dwellings with
  Winds of War.

Game facts were checked against the sources above. Keys, codes, the title's
`DisplayOrder: 4`, and field mapping are project conventions. Optional release
dates, media, growth values, experience values, and spell power remain null.

## Factions and expansion scope

| Faction | Alignment | Native terrain | Magic guild | Allied factions |
|---|---|---|---|---|
| Haven | Life | Grass | Yes | Academy, Preserve |
| Academy | Order | Snow | Yes | Haven, Necropolis |
| Necropolis | Death | Volcanic | Yes | Academy, Asylum |
| Asylum | Chaos | Swamp | Yes | Necropolis, Preserve |
| Preserve | Nature | Grass | Yes | Haven, Asylum |
| Stronghold | Might | Rough | No | None |

All six factions were introduced in the base game. Their generic identities
are shared across both expansions; they are not duplicated per release.
Three `Expansion` records distinguish `BASE`, `TGS`, and `WOW` within HOMM4.
The five magic schools are separate `MagicSchool` rows. Stronghold has no
native magic school and no allied faction references. The nullable A/B ally
fields follow the manual's order and point to same-game faction records.

## Neutral roster and format mapping

In this batch, "neutral" means outside the standard eight-creature lineup of
each town. It does not mean absence of alignment or a seventh town faction.
Each of the 26 creatures has a real `Faction_id` linking its alignment to the
appropriate Heroes IV faction. The eight Creature Portal units are included
in this roster. Descriptions and the explicit review-query roster identify
this recruitment distinction; no unsupported `IsNeutral` or `CreatureKind`
field is added to `CreatureHOMM4`.

| Release | Creatures |
|---|---|
| Base game (19) | Peasant, Leprechaun, Troglodyte, Pirate, Zombie, Satyr, Evil Eye, Troll, Mummy, Gargoyle, Mermaid, Waspwort, Fire Elemental, Air Elemental, Water Elemental, Earth Elemental, Ice Demon, Mantis, Sea Monster |
| The Gathering Storm (4) | Goblin Knight, Evil Sorceress, Gargantuan, Dark Champion |
| Winds of War (3) | Catapult, Frenzied Gnasher, Megadragon |

Field decisions:

- `Attack` and `Defense` store melee attack and melee defense. For example,
  Evil Eye has melee attack 8, while its ranged attack is 16; the JSON uses 8.
  The current schema has no separate ranged-attack or ranged-defense fields.
- `DamageMin` and `DamageMax` split the listed damage range into integers.
  Pirate values are the ordinary land values, before its conditional sea bonus.
- `Speed` is combat speed/turn order, not movement distance. Catapult's speed
  is legitimately 0; it is not replaced with a guessed positive value.
- `Movement` is an ENUM: `Flying` for Evil Eye, Gargoyle, Air Elemental, and
  Mantis; `Teleporting` for Evil Sorceress; `Ground` for the other creatures.
  `Ground` distinguishes their combat movement from flying/teleporting. It
  does not assert that aquatic creatures can travel on land. The schema has
  no separate aquatic-travel or numeric combat-distance field.
- `Shots` and `SpellPoints` use numbers, with 0 for an absent ranged attack
  or spell-point pool. Spell points are 3 for Leprechaun, 6 for Satyr, 24 for
  Water Elemental, 50 for Evil Sorceress, and 18 for Dark Champion.
- `Recruitable` means purchasable through a dwelling or the Creature Portal
  in the selected unmodified Winds of War ruleset. It is false for Mermaid,
  Sea Monster, and Megadragon. It is true for the other 23, including the four
  Gathering Storm creatures whose dwellings were added in Winds of War.
  Scripted gifts, summons, and editor placement are not recruitment.
- `DoubleUpgrade` and `AlternativeUpgrade` are false. Heroes IV's choice
  between creature dwellings is not a creature-upgrade relationship.
- Growth rates can depend on an external dwelling versus the Creature Portal,
  and actual recruitment accumulates daily. Growth fields remain null instead
  of importing a weekly rate as a daily amount or rounding a fractional rate.
- Optional experience values are omitted because some references disagree
  (for example, Mummy). The required combat statistics were cross-checked.

## Architecture and verification

This adds 78 rows: 1 Game, 3 Expansion, 5 MagicSchool, 5 Terrain, 6 Faction,
6 FactionHOMM4, 26 Creature, and 26 CreatureHOMM4. Immediately after this batch,
the cumulative total was 107 rows, including 29 Heroes III rows. All 173 table arrays remain
present. Generic/detail pairs share `_key`; independent physical IDs are
omitted. Every new relationship resolves inside the bundle and stays in HOMM4.

```sh
node src/db/tools/validate.mjs src/db/data/heroeswatch.json
```

Validation output when this batch was added:

```text
Valid HeroesWatch data bundle: 173 tables, 107 rows.
```

A separate architecture check confirmed the 78-row HOMM4 inventory, the
19/4/3 creature introduction split, shared primary keys, same-game references,
reciprocal town alliances, Stronghold's lack of magic/allies, and the three
non-purchasable creatures. It also compared every existing HOMM3 JSON row
against the previous commit and verified that the SQL payload exactly matches
the new JSON records.

[homm4-factions.sql](homm4-factions.sql) is a snapshot of these 78 HOMM4 rows.
It resolves generated or existing IDs, fills nullable sourced values where
missing, checks required and sourced facts, and aborts on conflicting existing
data. It applies the complete batch in one transaction, checks foreign keys
before commit, and preserves the HOMM3 content. Later JSON changes require a
corresponding reviewed SQL/application update.

Use [the faction review](homm4-factions.review.sql) for the six towns and
[the creature review](homm4-creatures.review.sql) for all 26 non-town creatures.
The schema, data dictionary, and initial migrations remain the same contract.

On 2026-09-12, the import completed successfully in local PostgreSQL 18,
database `HeroesWatch.net`, through its saved pgAdmin 4 connection. Foreign
keys were checked before commit, and the result displayed all six factions.
A fresh pgAdmin query session independently returned all 26 creatures after
the commit, including their faction alignments and required combat statistics.
