# Heroes I–III manual comparison and additions

Researched 2026-09-30 against the cumulative **27,915-row** JSON catalog.
The manuals were supplied locally by the user. Supported additions are merged
into the cumulative JSON; existing non-null values are preserved.

## Outputs

- `research/manual-homm1-3-additions.json`: 456 rows for merging, including
  **451 existing rows with 568 previously empty fields filled** and **five new
  building-prerequisite relationships**.
- `research/manual-homm1-3-changes.json`: every field/relationship comparison,
  its source page, coverage counts, unresolved items, and an empty corrections
  list. No non-null overwrite was sufficiently established to propose one.

There are **5,402 comparisons**: **4,799 matches**, **577 observations of
missing data**, and **26 differences**. Repeated observations from different
manuals remain separate evidence records; these are not counts of unique
facts. Two proposed fills were withheld. The import fragment contains only
supported additions.

## Source registry

| MediaAsset import key | Document | Main sections used |
|---|---|---|
| `manual.c1d7c0b2da69` | Heroes of Might and Magic I — A Strategic Quest user manual | PDF/printed pp22–23, 79–88, 90–93 |
| `manual.f61bf353fde6` | Heroes of Might and Magic: The Official Strategy Guide | PDF pp54–57, 60, 121–131; printed pages are ten lower |
| `manual.a99f53fdd378` | Heroes II Gold manual, including Price of Loyalty supplement | PDF pp45, 47–50, 61–114, 134, 137–139; printed pages are one lower |
| `manual.78affabf067d` | Heroes III: The Restoration of Erathia manual | PDF/printed pp63–80, 82–117, 118–133 |
| `manual.b549fa666ab4` | Heroes III: Armageddon’s Blade manual | PDF/printed pp9–23 |
| `manual.72054a12f6f3` | Heroes III: The Shadow of Death manual | PDF/printed pp13–27 |
| `manual.5c7c2c47942b` | Alternate scan of The Shadow of Death manual | Registered as another file edition; not counted as independent corroboration of identical content |

The filename “Heroes of Might and Magic Compendium.pdf” is misleading:
`f61bf353fde6` contains the **Heroes I Official Strategy Guide**. It is not
a Heroes II/III compendium.

PDFs remain in the ignored local manual library. Their checksums and edition
identities are registered by the parent import. No PDF, page raster, full
extracted text, or personal Downloads path is included in this fragment.

## Coverage

| Category | Compared or enriched |
|---|---|
| Creatures | Every current Heroes I creature (28), Heroes II creature (66), and Heroes III creature (141); available attack, defense, damage, health, speed, growth, shots, movement and recruitment prices |
| Classes | All 4 I, 6 II and 18 III classes; starting attributes; II primary advancement probabilities, secondary-skill weights and four starting-spell links |
| Heroes | Initial attributes and listed starting skills for 128 RoE heroes and 17 AB Conflux/new heroes; 271 existing HeroSkill relationships checked |
| Buildings | All 60 I buildings; 123 II buildings; 284 III buildings; 77 II prerequisite relationships and 234 III construction-resource amounts |
| Spells | All 29 I spells; all 65 II spells; all 69 ordinary III spells represented in the RoE manual, including 75 school memberships because some spells belong to multiple schools |
| Skills | All 14 II secondary skills at all three mastery levels; descriptions reviewed semantically |
| Artifacts | I standard/ultimate effect table; all 12 SoD combinations and their 49 component links; seven previously empty combination effects |
| Campaigns | 18 concise descriptions across I, II Price of Loyalty, III AB and III SoD |
| Map objects | Nine II expansion-object descriptions |

New field groups include I spell and artifact effects, II spell targets,
durations and effects, II class advancement rules, I/II class starting data,
II/III building effects, campaign summaries and expansion map interactions.
For non-shooting II creatures, explicit printed `Shots: 0` fills 47 null
shot-count fields.

This is not a claim that every possible field in these games is complete.
The audit does not fully adjudicate every III spell mastery formula, copy all
strategy prose, create scenario/map records from mere mentions, or treat
war machines as ordinary creatures. Titan’s Lightning Bolt is not an ordinary
spell entry in the RoE manual. H3 decorative objects and source-absent
building fields remain outside this pass.

## Differences and retained values

### Release differences: 16 observations

RoE creature tables precede the selected final-expansion ruleset. The differing
values concern Lizardmen, Lizard Warriors, Serpent Flies, Dragon Flies,
Cerberus damage, and Angel/Archangel gem costs. SoD pp24–25 explicitly list
the Fortress and Angel changes. The existing game-data extraction
`H3bitmap.lod/CRTRAITS.TXT` confirms the retained final creature values,
including Cerberus damage **2–7**. Older values are preserved in the audit;
none replace the catalog’s final ruleset.

### Manual errors or omissions: five observations

- **Rust Dragon cost:** SoD p23 prints **5,000 gold**; AB p19 and the installed
  classic game table say **15,000**. Retain 15,000.
- **Heroes I Resurrect:** the user-manual p92 icon says level 3. The strategy
  guide PDF p130 / printed p120 puts it under level IV, matching the database.
- **Heroes I Teleport:** the user-manual p92 icon says level 1. The guide PDF
  p126 / printed p116 explicitly places it under level III, matching the database.
- **Heroes I View Resources:** the user-manual p93 icon says level 3. The
  guide PDF p121 / printed p111 places it under level I, matching the database.
- **Heroes III Teleport cost:** the manual’s general expertise discount rule
  would imply 12 at Expert, but its Teleport entry omits the spell’s special
  mastery costs. **12 is an inference from that general rule, not a value
  printed in the Teleport entry.** The explicit existing Expert cost of 3 is
  retained; this comparison is marked `inference_from_general_rule`.

### Unresolved differences: five observations

| Existing field | Catalog | Manual | Evidence |
|---|---:|---:|---|
| I Orc `Speed` | Medium | Slow | User manual p82 |
| I Gargoyle `Attack` | 3 | 4 | User manual p86 |
| II Giant `GoldCost` | 2,000 | 1,250 | Gold manual PDF p90 / printed p89 |
| I Knight Jousting Arena `GoldCost` | 3,000 | 4,000 | User manual p81 |
| I Barbarian Bridge `GoldCost` | 4,000 | 3,000 | User manual p83 |

These are genuine source disagreements, not assumed database errors. Existing
values came from the previously documented reference sources. The available
manual evidence does not establish whether the difference is a printing error,
release change, or an incorrect earlier source. Existing values remain intact.

### Two withheld fills

- The I strategy guide prints **+2 Power** for Caster’s Bracelet of Magic
  (PDF p55 / printed p45). The effect remains null pending reconciliation
  with game behavior.
- II Paralyze’s duration is printed as **“1 rnd / level”** (PDF p67 / printed
  p66), where other spell durations use Power. Duration remains null pending
  ruleset confirmation. Its supported target and general effect are added.

## Matching and extraction decisions

- Names are matched within their own game and category; stable existing keys
  are retained. H2 **Orc Chieftan** maps to Orc Chief, **Archeological Dig** to
  Excavation, **Boar Pen** to Pen, and **Perpetual Storm** to Storm.
- The II manual calls all three dragon-dwelling stages Black Tower, Black Tower
  Upgrade, and Black Tower Upgrade 2. Their produced creatures establish the
  mapping to the current Green, Red and Black Tower identities. A naive name
  match would incorrectly report 15,000 versus 5,000 gold.
- H3 combination names use documented aliases such as Hips/Loins of Legion,
  Orb/Mystic Orb of Mana, and Cloak/Cape of Conjuring. No duplicate items are
  created.
- Lord Haart’s RoE Knight row is matched explicitly; the AB Death Knight
  identity is distinct. Hero names alone are not always unique within a game.
- The SoD p19 table has vertically misaligned labels in the PDF itself.
  Rendering and its ordered value columns, checked against AB, prevent false
  Attack/Defense/Health discrepancies for Rogue, Boar and elementals.
- Exact effect prose is summarized. JSONB effects remain bounded mechanic
  documents. Relational prerequisites use `BuildingRequirement`, and spells
  use existing `SpellMagicSchool` relationships.

## Review and validation

Relevant pages were rendered with Poppler and inspected, including the
material price/stat discrepancies, Heroes I illustrated spell icons, the
guide’s corresponding spell headings, and the shifted SoD p19 table.

A temporary merge rejected every attempted change to an existing non-null
field, then passed the repository validator:

```text
newRows: 5
filledFields: 568
Valid HeroesWatch data bundle: 173 tables, 27920 rows.
```

The cumulative import and live PostgreSQL result are documented in
[CATALOG_STATUS.md](CATALOG_STATUS.md). The public comparison and content
evidence files preserve the research observations and merged field changes.
