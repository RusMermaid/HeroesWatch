# Might and Magic spin-off manual additions

Research date: 2026-09-30. These records describe **Crusaders of Might and
Magic**, **Warriors of Might and Magic**, **Shifters**, and **Legends of Might
and Magic**. They do not supply missing combat statistics for Heroes games.

## Sources

| Source key | Edition | Principal pages used |
|---|---|---|
| `manual.b92ed7197fac` | Crusaders, Windows | PDF 18 and 24–32: attributes, figures, factions, creatures, items and spells |
| `manual.02f7327cf60a` | Crusaders, PlayStation | Printed 18–26 / PDF 19–27: figures, creatures, equipment, schools, talismans and spells |
| `manual.882374cdc325` | Warriors, PlayStation | PDF 7–9, 14–16, 20, 22–23: setting, items, map objects and spells |
| `manual.179dc3d51105` | Shifters, PlayStation 2 | Printed 11–24 / PDF 13–26: attributes, forms, elements, equipment and spells |
| `manual.b88c497fe5ab` | Legends, Prima guide | Printed 5, 31–60 and 81–158 / PDF 7, 33–62 and 83–160: classes, gear, monster table and map names |

The evidence sidecar records each catalog row's manual key, PDF page and
platform. Original PDFs and research renders are excluded from Git.

## Added records

The fragment contains **316 rows across 15 existing tables**:

| Table | Rows |
|---|---:|
| Game / Expansion | 4 / 4 |
| Hero / HeroClass | 14 / 6 |
| Faction | 10 |
| Creature | 48 |
| Artifact | 102 |
| Skill | 7 |
| Ability | 24 |
| Spell / MagicSchool / SpellMagicSchool | 46 / 9 / 8 |
| AdventureObject | 7 |
| Map | 20 |
| Lore | 7 |

By game: Crusaders 124 rows, Warriors 26, Shifters 60 and Legends 106.

Crusaders has ten Windows spells with their named progression stages. Its
PlayStation manual adds six spell identities and two platform-specific
descriptions for existing identities, yielding sixteen distinct spell rows.
The PlayStation edition's nine schools are Earth, Air, Fire, Water, Mind,
Body, Spirit, Light and Dark. Its eight documented spells have actual school
junctions; Drake refuses to learn Dark magic.

Shifters contributes six transformation families with four forms each. These
are `Ability` records, not invented selectable classes. Legends contributes
six selectable classes, 31 monster entries from its statistical table and
20 multiplayer maps.

## Differences and corrections made during source review

- **Crusaders Heroism:** Windows describes a Might/melee-damage bonus;
  PlayStation describes a character-level and weapon-rank increase, excluding
  spell ranks. Both descriptions remain on one identity and name their edition.
- **Crusaders Snap Freeze:** Windows describes a target and named progression;
  PlayStation describes an area around the caster. These are recorded as
  platform variants, not a contradiction requiring one version to be deleted.
- **Shared Crusaders names** such as Prince Dain Stoneheart, Tamris, Necros,
  Battle Axe, Longsword, Warhammer, Dark Mage and Dark Warlord reuse existing
  rows in this fragment. Armor/Armour spelling variants are also combined.
  Differently named equipment is not assigned a speculative cross-platform
  identity. The Warren Queen is explicitly labeled an unconfirmed legend.
- **Shifters Imprison** is included from printed p. 15 / PDF p. 17. It is
  restricted to the Efreet form. Its name alone does not justify inventing
  damage, duration or targeting values.
- **Shifters Axe of Vim** was verified visually on printed p. 19 / PDF p. 21.
  The manual names Vim; no alternative character name was substituted.
- **Legends map names** were checked against page images and the contents:
  Fahl'Tee Tower, Stoneham, The Hideout, Spiders' Den and Temple of Bark.
  Earlier OCR guesses of Fang's Tower, Hide Out, Spider's Den and Temple of
  Dark were removed before integration.
- **Legends Jump Scroll** replaces an unsupported Iron Feet Scroll guess.
  Teleport and Lava Protection are on printed p. 55 / PDF p. 57. Leather
  Armor and Chain Mail are on printed p. 52 / PDF p. 54.

## Model boundaries

Only existing generic catalogs and junctions are used. No HOMM detail table
is borrowed for an action game, and no new schema is introduced. Where the
schema lacks a matching typed field, a short factual description preserves
the manual's parameters. For example, Legends' monster descriptions record
health, attack damage, speed and gold reward with units and qualifications;
they do not pretend to be Heroes turn-based creature statistics.

The shared spell-school junction has no platform column. The linked
Crusaders school descriptions and evidence therefore explicitly identify the
PlayStation source; those associations are not inferred for Windows.
Full attack formulas, complete encounter scripts and every walkthrough step
are outside this extraction. Missing values remain unknown.

The scratch merge of the cumulative catalog, RPG fragment, spin-off fragment
and manual registry passed schema validation: **173 tables, 30,423 rows**.
The final records are merged into the cumulative catalog. See
[CATALOG_STATUS.md](CATALOG_STATUS.md) for PostgreSQL application and delivery.
