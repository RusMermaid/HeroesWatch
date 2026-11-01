# Manual comparison

Research date: **2026-09-30**. Baseline: the **27,915-row cumulative JSON
catalog before the manual import**.

The comparison found **six unresolved conflicts with existing values**.
Most other differences reflect older editions, inconsistent manual text, or
alternative names. The research fragments contain supported missing information;
**the audit calls for zero replacements of existing non-null values**.

This report records research against the baseline. Live database application
and delivery status are tracked in [CATALOG_STATUS.md](CATALOG_STATUS.md).
The comparison baseline is the saved JSON, not an independent live-database query.

## Results

| Result | Observations | Research decision |
|---|---:|---|
| Matches | 6,286 | Retain existing values |
| Supported missing information | 794 | Fill supported nulls or add missing relationships/identities |
| Differences between editions or references | 163 | Preserve the selected catalog ruleset |
| Manual errors, internal contradictions or omissions | 8 | Retain supported existing values |
| Unresolved conflicts with existing values | 6 | Retain existing values pending stronger evidence |
| Ambiguous potential fills | 3 | Leave the affected fields null |
| Different source names | 2 | Keep existing identities |
| Spelling or spacing variants | 2 | Keep existing identities |
| **Total** | **7,264** | |

These are evidence observations, not unique entities or verified PostgreSQL
cells. The total combines **5,402** I–III observations and **1,862** IV–VI
observations. Repeated facts in different manuals remain separate; some text
matches were reviewed semantically, and one cost comparison is explicitly
identified as an inference.

The Heroes fragments contain **774 fills of previously null fields** and
**57 new rows**. Missing-information observations can repeat the same fact,
so their count is different from the import totals.

The [machine-readable report](manual-comparison.json) preserves all original
comparison fields, baseline values, classifications, notes and source pages.
It adds consistent result categories and evidence fields. Original-record
hashes allow the preservation check to be repeated.

## Six unresolved conflicts

| Game and field | Existing catalog | Manual | Source: PDF / printed page |
|---|---|---|---|
| I — Orc speed | Medium | Slow | `manual.c1d7c0b2da69`: 82 / 82 |
| I — Gargoyle attack | 3 | 4 | `manual.c1d7c0b2da69`: 86 / 86 |
| I — Knight Jousting Arena gold cost | 3,000 | 4,000 | `manual.c1d7c0b2da69`: 81 / 81 |
| I — Barbarian Bridge gold cost | 4,000 | 3,000 | `manual.c1d7c0b2da69`: 83 / 83 |
| II — Giant gold cost | 2,000 | 1,250 | `manual.a99f53fdd378`: 90 / 89 |
| IV — Giant Strength mana cost | 3 | 2 | `manual.1082fde64d0e`: 40 / 79 |

These are documented source disagreements. The available evidence does not
establish whether each comes from a printing error, a release change or an
incorrect earlier source. The values above remain unchanged. Full keys and
field names are retained in the machine-readable report and the
[I–III](manual-homm1-3.sources.md) and [IV–VI](manual-homm4-6.sources.md) notes.

## Observed edition and reference differences

**Heroes III: 16 observations.** The RoE manual differs from the selected
final-expansion rules for Lizardmen, Lizard Warriors, Serpent Flies, Dragon
Flies, Cerberus damage and Angel/Archangel gem costs. SoD explicitly documents
the Fortress and Angel changes on PDF/printed pp24–25
(`manual.72054a12f6f3`). The retained creature values also agree with the
previously extracted classic game `CRTRAITS.TXT` data.

**Heroes V: 147 observations.** The downloaded 1.4 community manual and 2006
Prima guide differ from the catalog’s Tribes of the East 3.1 reference.
Examples:

| Field | Catalog | Older source | Source: PDF / printed page |
|---|---:|---:|---|
| Djinn health | 40 | 33 | `manual.51831bb63b83`: 98 / 98 |
| Peasant speed | 4 | 3 | `manual.7348cd0dc5c8`: 48 / 47 |
| Sword of Might gold value | 5,000 | 4,000 | `manual.51831bb63b83`: 112 / 112 |
| Curse of the Netherworld mana | 15 | 9 | `manual.51831bb63b83`: 108 / 108 |
| Firewall level | 3 | 4 | `manual.51831bb63b83`: 111 / 111 |

This classification identifies differing references. It does not establish
which official patch caused every change. New V artifact effects and town
requirements were separately corroborated against the existing 3.1 source
before being prepared as null-field fills; see the [IV–VI notes](manual-homm4-6.sources.md).

## Manual errors and internal contradictions

| Observation | Decision and evidence |
|---|---|
| III Rust Dragon costs 5,000 gold in SoD | Retain 15,000. AB p19 and classic game data agree; SoD p23 drops the leading 1. Sources: `manual.b549fa666ab4`, `manual.72054a12f6f3`. |
| I Resurrect icon says level 3 | Retain level 4. User manual p92 conflicts with the strategy guide PDF p130 / printed p120. Sources: `manual.c1d7c0b2da69`, `manual.f61bf353fde6`. |
| I Teleport icon says level 1 | Retain level 3. User manual p92 conflicts with guide PDF p126 / printed p116. Same sources. |
| I View Resources icon says level 3 | Retain level 1. User manual p93 conflicts with guide PDF p121 / printed p111. Same sources. |
| III Teleport omits special mastery costs | Retain Expert cost 3. A cost of 12 is inferred from RoE p63’s general discount rule, **not printed in Teleport’s own entry** on p79. Source: `manual.78affabf067d`. |
| IV Witch King prerequisites disagree inside the manual | Retain Chaos + Nobility. The matrix on printed p41 / PDF p21 agrees with the catalog; prose on printed p120 / PDF p60 adds Death. Source: `manual.1082fde64d0e`. |
| The Gathering Storm calls an artifact Ring of Life and Ring of Light | Retain Ring of Light. The artifact list on printed p6 / PDF p4 supports it; campaign prose on printed p5 uses Life. Source: `manual.2801bd7a47f5`. |
| VI art book prints Fate Spiner | Retain Fate spinner. Source: `manual.479b30ff7027`, PDF p46 / printed p90. |

### Three fills withheld

- **I Caster’s Bracelet:** the guide prints +2 Power, but this has not been
  reconciled with game behavior. Source `manual.f61bf353fde6`, PDF p55 /
  printed p45.
- **II Paralyze duration:** the manual says “1 rnd / level,” unlike nearby
  durations using Power. Source `manual.a99f53fdd378`, PDF p67 / printed p66.
- **IV Demonologist bonus:** the manual prints +50 without a unit or percent
  sign. Source `manual.1082fde64d0e`, PDF p59 / printed p117.

### Source labels kept separate from identities

The VI art book uses **Shadow Elemental** for the catalog’s Darkness elemental
(PDF p67 / printed p132) and **Dragon Eel** for Hai Ryou (PDF p73 / printed
p144). These remain source-name differences. **Hellhound/Hell hound** and
**Spectre/Specter** are spacing/spelling variants. All four come from
`manual.479b30ff7027`; none creates a duplicate creature or changes combat data.

## Coverage and source gaps

- **I–III:** all 235 current creatures and 28 classes; 145 III heroes; 29 I,
  65 II and 69 ordinary III spells; 467 buildings; all 14 II secondary skills;
  documented artifacts, campaign summaries and expansion map interactions.
- **IV–VI:** all 147 IV spell-table entries; 90 V creatures; 70 V artifact
  class/value pairs; 167 V building requirements; six V class-growth profiles;
  43 V spell level/mana pairs; 33 IV expansion-ownership checks; 69 VI labels.
- VI evidence is an **art book**, useful for lore and labels rather than
  numeric combat statistics. Invisible template text and placeholders were
  excluded after rendered-page inspection.
- **No authentic Heroes VII or Olden Era/Heroes VIII manual was found** in
  the supplied collection. The document `manual.c008a9d5236c` is an imagined
  Heroes VIII fan design and is excluded from released-game facts.
- Might and Magic VII and VIII **RPG manuals are different titles**. They
  are not used as Heroes VII/VIII evidence.

The [inventory](manual-inventory.json) registers **38 located files / 36
distinct PDFs**. Separate scans or copies are not independent corroboration.
The file named “Heroes of Might and Magic Compendium” is the I Official
Strategy Guide; the RPG Compendium credits Caroline Spector. Original PDFs
remain in the private local library, outside Git.

This pass does not claim that every mechanic or every paragraph has been
encoded. In particular, all III mastery formulas, every map or incidental
character, and source-absent fields remain outside the documented checks.

## Might and Magic RPG source issues

These are internal problems in the RPG references, not disagreements with
Heroes data. RPG entries use separate `MM1`–`MM10` and `MMSX` identities.
The [RPG source notes](manual-mm-rpg.sources.md) document the full mapping.

| Issue | Treatment | Evidence: PDF page |
|---|---|---|
| VIII Cleric promotion: Priest of the Sun / Priest of Light | One promotion, with alternate wording documented | `manual.eb84de7ed6f7`: 6, 9 |
| VIII Mind spells under a Spirit heading | Assign to Mind using their text and surrounding section | `manual.eb84de7ed6f7`: 30 |
| IX Item Repair repeats Perception text | Exclude the copied trap/treasure effects | `manual.17823a4ec782`: 22 |
| Gnome starting skill: Direction Sense / Danger Sense | No starting-skill relation inferred | `manual.f689c35452ff`: 27; `manual.41d42851ae76`: 21 |
| III Shadow Rogue armor class printed `1t` | Leave the number unresolved | `manual.5f642828a326`: 102 |
| V Royal Vampire experience printed `400,00` | No normalized numeric reward asserted | `manual.5f642828a326`: 344 |
| III Pain and Mega Volts reuse other spell descriptions | Withhold suspect effects; retain supported costs and levels | `manual.5f642828a326`: 110, 114 |

The current schema has no RPG-specific mechanics layer. Supported RPG facts
use generic catalogs and concise descriptions; Heroes detail tables are not
reused. Short manuals omit many creatures, items and spells, especially X.
No entries are invented to fill those omissions.
