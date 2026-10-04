# Catalog corrections and recruitment relationships

Reviewed 2026-10-04. The original Heroes III ruleset remains Complete / Shadow
of Death with Armageddon's Blade content. No HotA or other mod abilities are
included. Olden Era relationships refer to the previously imported Steam build
25061458 snapshot from 2026-09-29.

## Corrections

| Record | Field | Previous value | Reviewed value | Evidence |
|---|---|---|---|---|
| Heroes I Gargoyle | Growth | null | 6 | Original manual `manual.c1d7c0b2da69`, PDF and printed p.86; rendered page checked |
| Heroes I Genie | GoldCost | null | 650 | Same manual, PDF and printed p.88; rendered page shows 650 gold and one gem |
| Heroes VI Dungeon Fort | Name | Filename followed by fort name | Dungeon Fort | [External structures](https://mightandmagic.fandom.com/wiki/List_of_adventure_map_structures_in_Heroes_VI#Dwellings_and_Forts) |
| Heroes VI Haven Fort | Name | Filename followed by fort name | Haven Fort | Same table |
| Heroes VI Inferno Fort | Name | Filename followed by fort name | Inferno Fort | Same table |
| Heroes VI Necropolis Fort | Name | Filename followed by fort name | Necropolis Fort | Same table |
| Heroes VI Sanctuary Fort | Name | Filename followed by fort name | Sanctuary Fort | Same table |
| Heroes VI Stronghold Fort | Name | Filename followed by fort name | Stronghold Fort | Same table |
| Olden Era campaign M4 burning-man object | Description | null | Explicit unresolved-name explanation | Installed `Lang/english/texts/mapObjects.json`, token `campaign_M4_burning_man_name`; German and French agree |

Gargoyle growth was a supported manual fill that the earlier merge omitted.
Its disputed **Attack** value is a different field and remains unchanged.
Genie's scalar `GoldCost` now mirrors the gold component already present in
`CreatureResourceCost`. The existing one-gem cost remains part of the complete
recruitment price. The earlier “missing data” observation described the empty
scalar, not an absence of all cost data.

The six fort corrections change display names only. Their existing `_key`,
`Code`, database identity and references are preserved. The old filename in a
stable code is harmless historical identity, not a display label.

The Olden Era name remains `???` because this is the literal installed source
text, not an extraction failure. Its description now makes that unresolved
status explicit. The internal identifier does not prove an official display
name. No name was invented.

The six prior manual disputes remain unresolved: Heroes I Orc speed, Gargoyle
attack, Jousting Arena gold cost and Bridge gold cost; Heroes II Giant gold
cost; and Heroes IV Giant Strength mana cost. These nine patches do not
overwrite any of those disputed values.

## Heroes III faction spells

The installed `H3bitmap.lod` archive's `SPTRAITS.TXT` supplies per-town spell
selection weights. These are **relative weights**, so they populate the new
`FactionSpell.SelectionWeight` field. `OccurrenceChance` remains null. A
weight is not the probability that a complete mage guild will contain a spell;
the draw depends on spell level, available slots, other candidates and map
settings.

Only positive-weight spells within the town's mage-guild ceiling are linked:
Castle level 4; Stronghold and Fortress level 3; the other six towns level 5.
The [mage-guild reference](https://heroes.thelazy.net/index.php/Mage_Guild)
corroborates these limits and the weighted selection process. The resulting
478 links describe ordinary mage-guild availability. They do not imply that
heroes of that faction are forbidden from acquiring other spells, and they do
not model Conflux's Aurora Borealis exception or map-editor overrides.

Native spell names are matched to the existing classic spell identities.
Disabled spells, zero-weight entries, creature-only spell actions and spells
above a town's guild ceiling do not produce ordinary guild links.

## Heroes III creature abilities

The batch adds 103 shared ability identities, their 103 Heroes III detail
rows, and 287 `CreatureAbility` links. They cover 123 of the 141 existing
classic creature identities. The remaining 18 ordinary melee creatures have
no intrinsic special ability in this inventory; no artificial “no ability”
row is added.

Primary evidence is the installed `H3bitmap.lod` `CRTRAITS.TXT` ability text.
The existing [creature source list](homm3-creatures.sources.md) supplies the
reviewed pair pages. Their classic branches were used to fill traits that the
short in-game text omits, including elemental classifications, breath attacks,
Pikeman jousting immunity and neutral-creature traits. The `onlyhota` content
was excluded. Movement and shooting relationships agree with the existing
typed creature statistics.

The archive's **reference-only** attribute flags are not treated as reliable
movement statistics: for example, some ground creatures carry a flying flag
in that text table. Its old Storm Elemental “no melee penalty” label also does
not become a new relation. The reviewed classic creature behavior takes
precedence over those textual artifacts.

Neutral-creature references:
[Azure Dragon](https://heroes.thelazy.net/index.php/Azure_Dragon),
[Crystal Dragon](https://heroes.thelazy.net/index.php/Crystal_Dragon),
[Faerie Dragon](https://heroes.thelazy.net/index.php/Faerie_Dragon),
[Rust Dragon](https://heroes.thelazy.net/index.php/Rust_Dragon),
[Enchanter](https://heroes.thelazy.net/index.php/Enchanter),
[Sharpshooter](https://heroes.thelazy.net/index.php/Sharpshooter),
[Halfling](https://heroes.thelazy.net/index.php/Halfling),
[Mummy](https://heroes.thelazy.net/index.php/Mummy),
[Nomad](https://heroes.thelazy.net/index.php/Nomad),
[Rogue](https://heroes.thelazy.net/index.php/Rogue),
and [Troll](https://heroes.thelazy.net/index.php/Troll).

Abilities have concise mechanical descriptions. This establishes the
creature-to-named-ability query path; it does not encode every trigger,
probability, duration, target exception or combat formula. `AbilityHOMM3.Effect`
and `CreatureAbility.Parameters` remain null where a structured contract has
not been populated. Numeric variants with distinct behavior, such as dwarf
resistance and golem spell-damage reduction, have explicit names.

## External dwellings

`AdventureObjectCreature` describes a creature **type** associated with an
object type. `Relation = Recruits` identifies its recruitment pool; `Guards`
identifies native guard types where imported. It does not represent current
stock, placed stack sizes, an owning player, or a guarantee that every
supported upgrade is available at once. Those qualifications are recorded in
the relationship notes. `AdventureObjectFaction` describes the faction form
or alignment of the object, independent of current player ownership.

| Game | Recruit links | Guard links | Faction links |
|---|---:|---:|---:|
| Heroes I | 7 | 0 | 4 |
| Heroes II | 22 | 0 | 13 |
| Heroes III | 87 | 0 | 68 |
| Heroes IV | 71 | 0 | 71 |
| Heroes V | 60 | 0 | 32 |
| Heroes VI | 42 | 0 | 24 |
| Heroes VII | 56 | 0 | 21 |
| Olden Era | 141 | 39 | 42 |
| **Total** | **486** | **39** | **275** |

### Sources and interpretation by game

- **I:** Existing reviewed [map objects](https://www.h1.acidcave.net/map_objects.html)
  and the original manual p.88. Seven external recruitment sites are linked.
  The snow-hut label is an existing editorial qualifier. Neutral recruitment
  sites do not receive an invented faction.
- **II:** The explicit recruit lists in the
  [adventure structures table](https://mightandmagic.fandom.com/wiki/List_of_adventure_map_structures_in_Heroes_II#Dwellings)
  cover all 22 cataloged sites, including Price of Loyalty additions. Troll
  Bridge recruits Trolls, not its War Troll guards; Dragon City recruits Red
  Dragons, not every dragon in its initial guard. City of the Dead recruits
  Power Liches. An Ancient Lamp has finite stock.
- **III:** The [external dwelling table](https://heroes.thelazy.net/index.php/Creature_dwelling#External_dwellings)
  explicitly separates recruits from guards. All 81 named fixed dwellings
  are linked. Golem Factory supplies Stone, Iron, Gold and Diamond Golems;
  Elemental Conflux supplies the four base elementals. Ordinary external
  sites supply base creatures even when their art resembles an upgraded
  building. Refugee Camp and the generic Creature Dwelling placeholder are
  excluded from this fixed-pool batch. No HotA dwelling is included.
- **IV:** The complete 71-site
  [creature-dwelling table](https://mightandmagic.fandom.com/wiki/List_of_adventure_map_structures_in_Heroes_IV#Creature_dwellings)
  supplies direct recruitment and alignment. Plurals are reconciled to
  existing creature identities, including Ballistae, Cerberi, Efreeti and
  Ogre Magi. All six Winds of War dwellings retain their existing expansion
  provenance. No town-building relation is substituted for an object link.
- **V:** The [3.1 community manual](https://h5.heroes.net.pl/uploaded/download/other/Heroes5-Manual-en-3-1.pdf),
  printed pp.266–268, lists the 24 low-tier faction dwellings, eight military
  posts and Elemental Conflux. Each military post supports that faction's
  four base creatures from tiers 4–7. The random Refugee Camp pool is left
  outside this fixed-pool batch. These links use the final 3.1 reference,
  not the older 1.4 manual in the local manual library.
- **VI:** The [external structure table](https://mightandmagic.fandom.com/wiki/List_of_adventure_map_structures_in_Heroes_VI#Dwellings_and_Forts)
  enumerates the 42 direct base recruits of 18 faction dwellings. All 18
  dwellings and six convertible forts receive faction links. Upgraded
  recruitment and empire-wide shared recruitment pools are not inferred.
- **VII:** The [dwelling rules](https://mightandmagic.fandom.com/wiki/Dwelling)
  and the seven faction rosters establish the standard base creatures of
  each Core, Elite and Champion dwelling. The 56 links cover the original
  eight-unit lineup of each faction. Map stock, alternate scenario units and
  upgrade availability are not implied. The existing object names remain
  explicitly editorial until English localization is verified.
- **Olden Era:** Installed `Core.zip`,
  `DB/objects_logic/hires/barracks.json`, supplies exact native object and
  creature identifiers, faction IDs, supported recruitment variants and
  guard types. Only identifiers already present in the reviewed catalog
  are linked. All three variants of a faction creature can be represented
  as supported variants; this is not a claim that all three are offered
  simultaneously. Native guard amounts and difficulty modifiers are not
  flattened into type relationships.

Two additional Heroes VII upgrade links complete the base-roster mapping:
[Hunter → Master Hunter](https://mightandmagic.fandom.com/wiki/Sylvan_(H7)) and
[Stalker → Tracker](https://mightandmagic.fandom.com/wiki/Dungeon_(H7)). The
paired base and upgrade fields in the cached faction tables establish both.

## Regression assertion

`catalog.test.mjs` now counts Heroes III combination artifacts within
`Game_id = homm3.game`. Its expected twelve combinations no longer include
Heroes II's valid Battle Garb of Anduran. The cross-game component integrity
assertion continues to check every game.

## Follow-up cost and town-recruitment audit

Before applying the touch-up patches, the audit compared **897 populated
scalar `GoldCost` fields** on creature, building and artifact detail rows
with their normalized resource-cost rows.
It found **895 matching gold relationships, two missing relationships and no
contradictions**. The missing rows are:

| Relationship | Existing sourced field | Gold amount |
|---|---|---:|
| Heroes I Rogue → Gold | `CreatureHOMM1`, `homm1.creature.rogue`, `GoldCost` | 50 |
| Heroes I Spell Book → Gold | `ArtifactHOMM1`, `homm1.artifact.spellbook`, `GoldCost` | 500 |

Both fields describe an actual recruitment or purchase price. Their scalar
values are preserved; the additions make the already-sourced gold component
available through the corresponding resource-cost relationship. Gold is
already available to Heroes I through `GameResource`, so no resource or
membership row is added.

Genie's separately documented scalar fill adds one populated `GoldCost`
field after this baseline audit; its existing 650-gold relationship already
matches the manual value.

`ArtifactHOMM5.GoldValue`, AI values, experience values, sale values and upgrade
cost text were excluded. A valuation is not evidence of a purchase price.
Missing or nested JSON costs were not invented. This check reconciles the
existing sourced scalar prices; it does not claim every possible game cost
has been supplied.

Seven additional direct town recruitment links are explicitly supported by
the faction structure tables:

| Game | Town | Building | Recruited creature | Source |
|---|---|---|---|---|
| VI | Haven | Priory | Sister | [Haven structure table](https://mightandmagic.fandom.com/wiki/Haven_(H6)) |
| VI | Inferno | Hall of Forbiden Desires | Lilim | [Inferno structure table](https://mightandmagic.fandom.com/wiki/Inferno_(H6)) |
| VI | Sanctuary | Reef rampart | Wanizame | [Sanctuary structure table](https://mightandmagic.fandom.com/wiki/Sanctuary_(H6)) |
| VII | Fortress | Blackbear cages | Blackbear | [Fortress structure table](https://mightandmagic.fandom.com/wiki/Fortress_(H7)) |
| VII | Stronghold | War pavilion | Crusher | [Stronghold structure table](https://mightandmagic.fandom.com/wiki/Stronghold_(H7)) |
| VII | Fortress | Hearth of giants | Fire giant | [Fortress structure table](https://mightandmagic.fandom.com/wiki/Fortress_(H7)) |
| VII | Haven | Justicar's tower | Justicar | [Haven structure table](https://mightandmagic.fandom.com/wiki/Haven_(H7)) |

These links retain the existing building labels and identities. The faction
structure descriptions resolve inconsistent individual infobox labels such
as `War pavillion`, and references to the lower-tier Bear cages or Guardian's
tower instead of their upgraded structures. No additional spelling patch is
implied by these relationship additions.

The standard faction upgrade inventory has 21 edges in Heroes II, 63 in III,
112 in V, 42 in VI, 56 in VII after the two earlier corrections, and 84 in
Olden Era. Heroes I and IV do not have a standard creature-upgrade system.
No further missing standard upgrade edge was found. Heroes VII's White Tiger
and Olden Era's Lava Larva are not treated as missing standard upgrade pairs.
The follow-up fragment therefore contains **nine rows**: one creature gold
cost, one artifact gold cost and seven `BuildingCreature` relationships.
