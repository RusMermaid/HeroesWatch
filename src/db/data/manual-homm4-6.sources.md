# Downloaded Heroes IV–VI manuals: additions and comparison

Research date: 2026-09-30. The comparison uses the existing catalog as its
baseline. It does not replace Heroes V's **Tribes of the East 3.1** statistics
with values from older books.

## Sources and page references

| Source key | Document | Scope used |
|---|---|---|
| `manual.1082fde64d0e` | Heroes of Might and Magic IV PC manual | Printed pp. 40–47: classes and towns; pp. 65–88: spell tables; pp. 98–113: magic skills; pp. 116–120: class abilities |
| `manual.29e01fadc898` | Heroes IV — Axeoth User Manual | All 64 extracted pages match the first IV manual after whitespace normalization; retained as a separate file identity, not a second vote or content import |
| `manual.2801bd7a47f5` | The Gathering Storm manual | Printed pp. 3–6: campaigns, heroes, creatures, objects and artifacts |
| `manual.476d68352bdc` | Winds of War manual | Printed pp. 3–6: campaigns, heroes and creatures |
| `manual.51831bb63b83` | Heroes V community manual, 1.4 edition | pp. 97–100: creatures; pp. 107–115: schools, spells and artifacts; pp. 123–146: buildings; p. 184: class growth |
| `manual.7348cd0dc5c8` | Heroes V Prima Official Game Guide, 2006 | Printed pp. 47–48, PDF pp. 48–49: a four-creature sample from its earlier statistical snapshot |
| `manual.479b30ff7027` | Ubisoft Heroes VI art book, 2011 | Faction and protagonist introductions; 69 illustrated creature labels |

The IV base manual contains two printed pages per PDF page: printed pages
`2n−1` and `2n` are on PDF page `n`. The VI art book's paired pages are usually
`2n−2` and `2n−1`. Every comparison carries both locators.

For 55 artifact effect fills and 14 missing town-level requirements, the
downloaded Heroes V 1.4 reference was also checked against the project's
existing [3.1 manual source](https://h5.heroes.net.pl/uploaded/download/other/Heroes5-Manual-en-3-1.pdf),
printed pp. 194–198 and 211–242. Individual corroborating pages are recorded in
the change notes. Only values supported by the later ruleset are filled.

## Output

`research/manual-homm4-6-additions.json` contains **52 new rows**:

- 12 faction/school relationships explicitly scoped to the `BaseGame` ruleset;
- the missing generic **Tear of Asha** artifact identity;
- 22 short, newly written lore entries: 12 IV expansion campaign summaries,
  five VI faction descriptions, and five VI protagonist accounts;
- 17 lore-to-campaign or lore-to-hero relationships.

`research/manual-homm4-6-changes.json` contains **206 null-field fills** with
`expected: null`: 55 Heroes V artifact effects, 45 Heroes IV class bonuses,
44 IV building effects, 43 IV spell effects, 14 V building requirements and
five IV magic-skill mastery tables. No existing non-null value is overwritten.

There are **1,862 comparison records**, including:

| Result | Count |
|---|---:|
| Matches, ignoring capitalization where stated | 1,487 |
| Missing fields, filled | 206 |
| Differences between V editions or references | 147 |
| Missing faction/school relationships | 12 |
| Missing artifact identity | 1 |
| Internally inconsistent IV manuals | 2 |
| Unresolved IV spell-cost conflict | 1 |
| Ambiguous IV class-bonus value | 1 |
| VI source naming differences | 2 |
| VI spacing/spelling variants | 2 |
| VI printed typo | 1 |

The quantitative coverage includes all 90 creatures shared with the V 1.4
tables, all 147 entries in the IV spell tables (level and mana), 70 V artifact
class/value pairs, 167 V building requirements, six V class growth profiles,
43 V spell level/mana pairs, expansion ownership for 33 IV heroes/creatures/
artifacts, and 69 VI creature labels. These are field comparisons, not a claim
that every sentence or mechanic in every manual has been encoded.

## Inconsistencies and decisions

- **Heroes IV Giant Strength:** the manual prints a mana cost of **2** on
  printed p. 79 / PDF p. 40; the database has **3**. Keep 3 pending confirmation
  from the game's relevant ruleset. Its effect was not filled as part of this
  disputed spell check.
- **Heroes IV Witch King prerequisites:** the same manual's p. 120 prose
  lists Chaos, Nobility and Death. Its p. 41 matrix says **Chaos + Nobility**,
  matching the database. Preserve the two-skill rule.
- **The Gathering Storm ring name:** campaign prose on p. 5 calls it
  **Ring of Life**, but the artifact list on p. 6 calls it **Ring of Light**.
  Preserve the existing Ring of Light identity; do not create a duplicate.
- **Heroes IV Demonologist:** p. 117 prints a summoning bonus of **+50**
  without a unit or percent sign. Leave its numerical class bonus null.
- **Heroes V older values:** 147 differences remain evidence rather than
  corrections. Examples include Djinn health **33** in 1.4 versus **40** in the
  current catalog, Peasant speed **3** in Prima versus **4**, Sword of Might
  value **4,000** versus **5,000**, Curse of the Netherworld mana **9** versus
  **15**, and Firewall level **4** versus **3**. This category identifies
  differing editions/references; it does not prove that every difference was
  caused by a particular official patch.
- **Heroes VI labels:** the art book visibly prints **Fate Spiner** (p. 90),
  **Spectre** (p. 83), **Hellhound** (p. 14), **Shadow Elemental** (p. 132),
  and **Dragon Eel** (p. 144). The catalog uses Fate spinner, Specter,
  Hell hound, Darkness elemental and Hai Ryou. Preserve the current identities;
  keep the last two as source-label differences rather than asserting new
  creature types or changing combat data.

## Architecture and extraction limits

- The Tear of Asha has a generic `Artifact` row. `ArtifactHOMM5.Class` has no
  `Grail` value and its `Slot` enum has no `Inventory` value, so no misleading
  detail row is fabricated. The old manual's million-gold figure is not
  inserted; the 3.1 reference lists a different value.
- `LoreFull` has hero and campaign links, but no faction FK. Faction lore uses
  the existing `LoreKind=Faction` and game scope instead of hiding a faction
  identity inside JSON.
- VI art-book text extraction includes invisible template text, duplicated
  French phrases and placeholder Latin. Rendered pages were inspected; these
  hidden text layers are excluded. The book supplies lore and artwork labels,
  not verified numeric combat statistics.
- Effects are short structured factual parameters. They are not full copied
  descriptions, and optional effects not established by these checks remain
  null. Battle Mage's more complex spell relationships and the ambiguous
  Demonologist value are not filled.
- The imagined Heroes VIII fan manual is excluded from this batch. It is not
  evidence for Olden Era gameplay.
- Original PDFs and rendered research images remain outside Git. The public
  source records use stable file hashes and document metadata, not private
  Downloads paths. No database credentials are present.

The supported additions are merged into the cumulative JSON. See
[CATALOG_STATUS.md](CATALOG_STATUS.md) for PostgreSQL application and delivery.

Validation of a scratch merge with the seven relevant manual records passed:
**173 tables, 27,974 rows**. All 206 expected-null preconditions and unique
field-update checks passed. The cumulative file was not changed by this check.
