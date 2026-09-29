# Heroes I–IV: remaining category data

Researched 2026-09-29. This batch adds 2,849 rows in
`research/remaining-homm1-4.json`; existing cumulative rows are not replaced.
Names, statistics, classifications and relationships are retained. Source
article prose, images, flavour text and binary game resources are not included.

## New catalog identities

| Category | Heroes I | Heroes II | Heroes III | Heroes IV |
|---|---:|---:|---:|---:|
| Creatures | 28 | 66 | 15 neutral | 48 town creatures |
| Skills | 4 primary attributes | 14 secondary | — | 9 primary and 27 secondary |
| Spells | 29 | 65 | — | 151 |
| Artifacts | 39 | 99 | — | 205 |
| Campaigns | 1 | 6 | — | 18 |
| Other adventure objects | 34 | 67 | — | 144 |

The 151 Heroes IV spells consist of 142 ordinary spells, five Nature/Demonology
summons and four distinct creature spell identities. Potion effects and passive
creature abilities are not counted as learnable spells. The existing five magic
schools receive their HOMM4 detail records. Heroes I and II do not have magic
schools, so no school identities are invented for them.

Supporting rows include 181 creature resource costs, 258 town recruitment and
production links, 21 creature upgrades, 151 spell-school links, 28 creature-spell
links, 88 Heroes IV class/primary-skill relationships, 26 campaign-hero links,
and the three components of the Battle Garb of Anduran.

## Sources

### Creature catalogs and mechanics

- [Heroes I creatures](https://mightandmagic.fandom.com/wiki/Heroes_I_creatures),
  [Heroes II creatures](https://mightandmagic.fandom.com/wiki/Heroes_II_creatures),
  and [Heroes IV creatures](https://mightandmagic.fandom.com/wiki/Heroes_IV_creatures).
  Each named creature's linked page supplies its CreatureInfobox statistics,
  faction, dwelling, cost and movement ability. All 28 I, 66 II and 48 IV town
  creature templates are included in the extraction.
- Heroes III Complete, installed English `Data/H3bitmap.lod`, `CRTRAITS.TXT`:
  attack, defense, damage, health, speed, shots, growth, AI value and costs for
  the 15 missing neutral creatures. These are the original official game data.
  The `Attributes` column is explicitly advisory and is not used to override
  actual movement or footprint; Crystal Dragons walk.
- [Neutral creatures](https://heroes.thelazy.net/index.php/Neutral_creature) and
  the corresponding `Template:Creature/<name>` records on that wiki: native
  movement, footprint, levels and release membership. Gold and Diamond Golems
  originate in Restoration of Erathia; the other 13 originate in Armageddon's
  Blade. HotA, Factory, Cove and other fan content are excluded.
- [Heroes IV skills](https://mightandmagic.fandom.com/wiki/Category:Heroes_IV_secondary_skills),
  including all nine primary-skill pages and their advanced-class combinations:
  parent skills and FK-backed class requirements.

### Magic and skills

- [Heroes I magic](https://mightandmagic.fandom.com/wiki/Magic_(H1)) and
  [Heroes II magic](https://mightandmagic.fandom.com/wiki/Magic_(H2)):
  spell names, levels, contexts and II mana costs.
- [Heroes II skills](https://mightandmagic.fandom.com/wiki/Category:Heroes_II_skills)
  and all 14 linked skill pages: numerical mastery summaries. Navigation is
  +50%, +100%, +150%; those values differ from Heroes III.
- Heroes IV school spell lists:
  [Life](https://mightandmagic.fandom.com/wiki/Life_Magic_spells),
  [Order](https://mightandmagic.fandom.com/wiki/Order_Magic_spells),
  [Death](https://mightandmagic.fandom.com/wiki/Death_Magic_spells),
  [Chaos](https://mightandmagic.fandom.com/wiki/Chaos_Magic_spells),
  [Nature](https://mightandmagic.fandom.com/wiki/Nature_Magic_spells).
  Ordinary spell costs are 2/3/5/8/12 by level. Demonology summons have separate
  5/8/12/18/24 costs and matching Nature/Demonology mastery requirements.
  The Devil's Summon Ice Demon is a separate identity from the hero spell.

### Artifacts

- [Heroes I artifacts](https://mightandmagic.fandom.com/wiki/List_of_Heroes_I_artifacts)
  and [RPGClassics Heroes I artifacts](https://tartarus.rpgclassics.com/homm1/artifacts.php):
  roster and full in-game labels. The
  [spellbook](https://mightandmagic.fandom.com/wiki/Spellbook) and
  [Eye of Goros](https://mightandmagic.fandom.com/wiki/Eye_of_Goros) are additional
  identities absent from the overview table.
- [Heroes I artifact rules](https://h1.heroes.net.pl/artefakty): artifacts are
  exchangeable except the spellbook and Fizbin of Misfortune.
- [fheroes2 artifact identifiers](https://github.com/ihhub/fheroes2/blob/master/src/fheroes2/resource/artifact.h),
  [artifact data](https://github.com/ihhub/fheroes2/blob/master/src/fheroes2/resource/artifact_info.cpp),
  and [artifact classifications](https://github.com/ihhub/fheroes2/blob/master/src/fheroes2/resource/artifact.cpp):
  independently implemented reference for full original Heroes II names,
  numerical modifiers, rarity, expansion membership and Anduran components.
  The 99 actual items exclude Invalid Artifact, Ultimate Artifact editor selector
  and three Dummy entries. No Resurrection-mod content is added. Cross-reference:
  [Heroes II artifact overview](https://mightandmagic.fandom.com/wiki/List_of_Heroes_II_artifacts).
- [Heroes IV artifacts](https://mightandmagic.fandom.com/wiki/List_of_Heroes_IV_artifacts):
  base and expansion names, native classifications, and The Gathering Storm
  campaign artifacts. All 205 table entries are represented.

### Campaigns and map objects

- [Campaign index](https://mightandmagic.fandom.com/wiki/Campaign), the
  [A Strategic Quest campaign](https://mightandmagic.fandom.com/wiki/A_Strategic_Quest_(campaign)),
  and individual I/II/IV campaign pages: campaign identities and IV protagonists.
  Wizard's Land is a scenario trilogy, not a campaign, and is not added as one.
- Adventure-object lists for
  [Heroes I](https://mightandmagic.fandom.com/wiki/List_of_adventure_map_structures_in_Heroes_I),
  [Heroes II](https://mightandmagic.fandom.com/wiki/List_of_adventure_map_structures_in_Heroes_II),
  and [Heroes IV](https://mightandmagic.fandom.com/wiki/List_of_adventure_map_structures_in_Heroes_IV).
  Previously entered dwellings are reused. Heroes I Genie Lamp is an alias of
  the existing Magic Lamp. Heroes II expansion labels become provenance, not
  part of the object name; Hut and Eye of the Magi are separate objects.
- [The Gathering Storm manual](https://manualmachine.com/gamespc/heroesofmightandmagicivthegatheringstorm/1119131-user-manual/):
  five distinct school Conservatories and the two Coliseums originate in the
  expansion. The generic Conservatory heading is expanded into those five
  identities.

## Modeling limits and fields left open

- This is complete against the named catalog rosters above, not an extraction
  of every decorative map-editor sprite, scenario, campaign map, or asset variant.
- The schema's `ArtifactHOMM4.ItemClass` has no `Treasure` or ordinary equipment
  class. The 41 affected items retain generic Artifact identities without false
  detail classifications. The Eye of Goros similarly keeps a generic identity;
  there is no Heroes I quest-item class. Native rarity values should be added
  to the schema before these details can be entered faithfully.
- Four creature-only Heroes IV spells have no established hero spell level.
  They retain generic Spell rows, school and creature relations; a mandatory
  numeric level is not guessed in `SpellHOMM4`.
- Heroes IV's detail schema has one Attack and Defense pair, so the recorded
  values are melee attack and defense. It cannot separately store ranged attack,
  ranged defense or adventure-map movement. Its Speed is combat initiative.
  Infinite Medusa ammunition remains null because `Shots` is a finite integer.
- Heroes III neutral dragons use runtime tier 7. The editor's tier 8–10 labels
  are a different classification and are not substituted for the runtime tier.
- Optional descriptions, formulas, mastery effects, object rewards and some
  source-absent quantities remain null. Spell context records its main use;
  the current enum cannot represent a spell usable in both combat and adventure.
- Tests, PostgreSQL application and post-import verification are not performed
  by this research batch, following the user's instruction to skip verification.

## Assembly

`src/db/tools/research-remaining-homm1-4.mjs` assembles the fragment using cached
factual references in the ignored `.codex-tmp/remaining-early` directory. It
reads the cumulative bundle to reuse existing identities and emits only new
rows. The parent delivery task merges this fragment before transactional import.
