# Might and Magic RPG facts from the supplied manuals

This batch adds **2,156 rows** under independent `MM1`–`MM10` and `MMSX`
game identities. These are the role-playing games, not the Heroes strategy
installments. Existing Heroes records are not changed by this fragment.

The original PDFs are private local assets. Their registered media keys are
`manual.<document-id>`. Page references below mean PDF page numbers, not the
printed page number. Some documents contain two printed pages per PDF page.

## Source inventory

| Document ID | Source | Catalog use |
|---|---|---|
| `39781a0a67cd` | Might and Magic I: Secret of the Inner Sanctum manual | Classes pp. 6, 23; towns p. 9; spell lists pp. 28–41 |
| `77a24173895a` | Might and Magic II: Gates to Another World manual | Classes pp. 20–21; skills p. 23; towns pp. 10–11; spell lists pp. 26–43 |
| `6a4506beab9e` | Might and Magic III: A Passage Through the Isles | Classes pp. 16–20; narrative identities pp. 2, 28–29; OCR required |
| `77a19276e09d` | Might and Magic III: Isles of Terra, Commodore Amiga reference card | Skills pp. 3–4; town services p. 4; OCR required |
| `e024a484059b` | Might and Magic IV: Clouds of Xeen manual | Classes pp. 10–11; skills pp. 18–19; opening-story characters pp. 4–6 |
| `f689c35452ff` | World of Xeen manual | Classes pp. 23–25; race information pp. 25, 27; skills pp. 43–44; shared IV/V spell lists pp. 51–65; services pp. 68, 70; numerous pages required OCR |
| `3a942be9936b` | Might and Magic VI: The Mandate of Heaven manual | Classes and promotions pp. 25–26; skills and schools pp. 27–29; 99-spell roster pp. 42–54 |
| `647fa3fa5ad4` | Might and Magic VII: For Blood and Honor manual | All 36 class ranks pp. 14–16; skills pp. 38–41; 99 spells with mana costs and mastery requirements pp. 44–58 |
| `eb84de7ed6f7` | Might and Magic VIII: Day of the Destroyer manual | All 16 class ranks pp. 6–9; skills pp. 20–23; 99 school spells and 12 racial abilities pp. 24–34 |
| `17823a4ec782` | Might and Magic IX manual | Fourteen classes pp. 18–19; skills and four magic schools pp. 21–23; 48 spells with multiple school memberships pp. 23–25 |
| `aa38fdd345c0` | Might and Magic X: Legacy manual | All twelve race-specific classes pp. 12–14; this short manual has no full spell, creature, or item catalog |
| `41d42851ae76` | Swords of Xeen manual | Classes pp. 17–19; skills pp. 37–38; 76 unique spells pp. 45–59; tavern pp. 9, 13, 23 and bank balance p. 32 |
| `5f642828a326` | Caroline Spector, Might and Magic Compendium, Prima Publishing, 1994 | MMIII–V bestiaries, spell tables, base-equipment tables and town maps; narrative retrospective for I/II |

The Compendium filename attributes it to John Van Caneghem, but the title
page credits **Caroline Spector** (PDF p. 5). It is an authorized strategy
guide, not a New World Computing instruction manual. Its I/II section is a
short narrative retrospective; the detailed reference sections cover III–V.

## Structured coverage

Counts are distinct catalog identities. A spell repeated in more than one
class list is one Spell row with both eligibility descriptions.

| Game | Class ranks | Spells | Skills | Creatures | Base item types | Town maps |
|---|---:|---:|---:|---:|---:|---:|
| MM I | 6 | 91 | 0 | 0 | 0 | 5 |
| MM II | 8 | 94 | 15 | 0 | 0 | 5 |
| MM III | 10 | 76 | 4 | 90 | 74 | 5 |
| MM IV | 10 | 76 | 10 | 86 | 64 | 5 |
| MM V | 10 | 76 | 10 | 94 | 64 | 5 |
| MM VI | 18 | 99 | 29 | 0 | 0 | 0 |
| MM VII | 36 | 99 | 34 | 0 | 0 | 0 |
| MM VIII | 16 | 99 | 35 | 0 | 0 | 0 |
| MM IX | 14 | 48 | 22 | 0 | 0 | 0 |
| MM X | 12 | 0 | 0 | 0 | 0 | 0 |
| Swords of Xeen | 10 | 76 | 10 | 0 | 0 | 0 |

Additional rows contain 31 real magic schools, 396 spell-school relationships,
12 MMVIII racial abilities, 21 town-service object types, 14 narrative
characters, 8 race/progression lore entries, 11 games and 13 releases. The
two World of Xeen compilation records are game-scoped entries for IV and V.

The early spell lists contain 94 class-list entries for MM I, 96 for MM II,
100 for MM III, and 78 each for IV, V and Swords of Xeen. Cleric, Sorcerer
and Druid are caster classes in these sources, so they are **not** inserted
as independent MagicSchool records. Their eligibility remains in spell
descriptions. The schema has no generic class-to-spell junction.

MMVI–VIII explicitly establish nine schools. MMIX establishes four and uses
multi-school spells; its school memberships are real `SpellMagicSchool`
rows. MMVIII racial powers are Ability rows, separate from its nine schools.

## Architecture choices

- All physical BIGINT identifiers are omitted. Import-only `_key` values
  resolve relationships.
- Generic rows use Game, Expansion, HeroClass, Hero, Skill, Spell,
  MagicSchool, Creature, Artifact, Ability, AdventureObject, Map and Lore.
- No RPG record is inserted into a `*HOMM*` detail table. The current schema
  has no RPG-specific stat or cost detail layer, so supported numeric facts
  are retained in concise descriptions with source pages.
- Basic RPG equipment types use the shared Artifact catalog. They are
  labeled as base equipment; rarity, enchantment combinations and unique
  relic status are not invented.
- Town maps have names and provenance. Dimensions, player counts, map files
  and runtime placements are left null.
- Original document assets may be referenced by generic `MediaAsset_id`.
  They are never assigned as character portraits or playable map files.
- Release dates remain null when the source does not establish an exact day.

## Source inconsistencies and limitations

These concern the RPG sources themselves and do not imply a discrepancy
with a Heroes game:

1. **MMVIII Cleric promotion:** the prose says *Priest of the Sun* (PDF p. 6),
   while the charts say *Priest of Light* (p. 9). One promotion identity is
   retained, with the alternate wording documented in its description.
2. **MMVIII Mind spells:** the heading preceding Mass Fear, Cure Insanity
   and Psychic Shock reads *Spirit Spells: Master Level* (p. 30). Their text
   and the surrounding section identify Mind magic. They are assigned to
   Mind; the heading is treated as a print error.
3. **MMIX Item Repair:** the normal-rank sentence describes avoiding traps
   and noticing treasure (p. 22), repeating Perception rather than repair.
   The entry records repair as the purpose and explicitly flags the faulty
   sentence. It does not apply those Perception effects to Item Repair.
4. **World of Xeen / Swords of Xeen Gnome skill:** the race prose says
   *Direction Sense*, but the adjacent table says *Danger Sense* (World of
   Xeen p. 27; Swords p. 21). No starting-skill relationship is inferred.
5. **MMIII Shadow Rogue armor class:** the Compendium actually prints
   `1t` (PDF p. 102), confirmed on the rendered page. This is recorded as
   unresolved rather than guessed as 11 or 14.
6. **MMV Royal Vampire experience:** the Compendium prints `400,00`
   (PDF p. 344), confirmed on the rendered page. No normalized numeric
   reward is asserted.
7. **Compendium spell effects:** MMIII *Pain* repeats poison-suppression
   wording (p. 110), while *Mega Volts* repeats the Inferno fire-damage text
   (p. 114). Those suspect effects are not imported. Costs and level
   requirements are retained as printed source facts.

This is coverage of the supplied reference sections, not a claim that each
PDF contains every game entity. The short manuals often omit complete
bestiaries, named-character rosters, unique artifact lists and spells.
MMX's manual describes its classes and systems but does not enumerate its
spells or equipment. The Compendium's room-by-room walkthrough coordinates,
all incidental named NPCs, reward instances, item-suffix permutations and
all dungeon maps have not been turned into additional catalogs. No fictional
rows were added to fill these gaps.

Full RPG mechanics would need approved RPG detail tables for attributes,
class skill caps, promotion edges, spell costs/mastery effects, item material
modifiers and equipment restrictions. Existing Heroes tables are not reused
for these mechanics.

## Outputs

- `research/manual-mm-rpg-additions.json`: the import fragment.
- `research/manual-mm-rpg-evidence.json`: source/page associations per row.

The records are merged into the cumulative JSON. The public
[content evidence](manual-content-evidence.json) retains the per-row source
associations. See [CATALOG_STATUS.md](CATALOG_STATUS.md) for PostgreSQL application
and delivery.
