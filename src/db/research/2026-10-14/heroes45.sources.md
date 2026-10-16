# Heroes IV and V gap follow-up

Research date: 2026-10-14. Baseline: the 43,932-row catalog at `7ad2a6b`.
These two patches add 341 rows and fill 114 null fields. They preserve all
existing identities and non-null values and require no schema changes.

## Heroes IV abilities

`heroes4.patch.json` adds 76 `Ability` identities, 76 shared-key `AbilityHOMM4`
details and 167 `CreatureAbility` links covering all 74 existing creatures.
The earlier 2026-10-13 candidate was held research, so these rows were still
absent from the catalog. Do not apply both candidates.

The current [Might and Magic Wiki creature roster](https://mightandmagic.fandom.com/wiki/Heroes_IV_creatures)
and all 74 linked creature pages were retrieved through the wiki's public API.
The patch pins each relevant page revision and its ability label. These pages
support **166 of 167 links**. The remaining link, Genie to Flying, is supported
by the licensed guide below and the original candidate's creature table.

The [Prima Official Strategy Guide](https://archive.org/details/Heroes_of_Might_and_Magic_IV_Prima_Official_eGuide),
Steve Honeywell and Greg Kramer, 2002, ISBN 0-7615-3798-8, supplies the original
67-creature quality tables on printed pages 12–17 / PDF pages 15–20, with
definitions on printed pages 18–23 / PDF pages 21–26. Matching names and
qualities across the facing table pages corroborate **137 links**. The exact
PDF checksum and page pairs are in the patch. Text extraction was checked
against rendered quality tables and definitions.

This is **wiki evidence with licensed guide corroboration**. It is not a claim
that the original executable or every expansion mechanic was inspected.
The guide predates The Gathering Storm and Winds of War, so expansion links
retain their secondary-source classification. The official base manual and
the two local expansion manuals establish the general ability model and
expansion creature rosters, but do not list their complete ability mechanics.
The original quick-reference-card archive link returned “File Not Found.”

### Corrections before importing the held candidate

- Zombie's English ability is **Toughness**. Its hit-point effect and
  Behemoth's damage-enhancing **Strength** are supported by the wiki and the
  guide. Both receive passive classification; no extra percentage is invented.
- Shared Magic resistance describes the mechanic without assigning every
  creature 50% resistance: the wiki explicitly gives Dwarf 50% and Gold Golem
  75%. Other creature-dependent quantities are likewise kept out of generic
  descriptions. Their optional mechanics JSON remains null.
- Long range ignores distance penalties. It is distinct from Ballista's
  obstacle-penalty ability and Catapult's combined siege capability.
- Creature stack keys and ability keys are preserved from the candidate.
  Physical PK fields are omitted from import rows as required by the patch
  contract. `Mechanics` and `Parameters` remain null; no unreviewed JSON shape
  or inferred numerical formula is introduced.

### Differences retained in the evidence

The guide labels Bone Dragon's quality “Terror”; the wiki distinguishes its
**Fear** attack from Nightmare's cast **Terror**. Separate ability identities
are retained, and the guide is not credited as corroboration of the Fear link.
The Phoenix guide row lists Fire Attack while the wiki lists Fire Resistance.
The patch follows the wiki's Fire Resistance relationship and does not claim
guide agreement for that link. This older guide also contains combat-stat
differences and typesetting anomalies; no creature statistics are overwritten.

### October 16 evidence clarifications

- The recorded wiki label for Unicorn's Blind link says `Blinding attack`.
  Pinned revision 180200 labels it `Blind`; the canonical ability link already
  points to Blind. This is a label erratum, not a different creature ability.
- Terror's two-turn duration follows the reviewed wiki/rules tables. Prima's
  definition gives one turn, so that book must not be credited as corroborating
  the selected duration. The historical patch evidence remains preserved.
- `Summon ice demon` is a descriptive catalog label for the source ability
  `Summon Demons`; it retains the original `ICEDEAMON` code for identity
  stability. A source alias is not a second mechanic.
- The short Long Weapon description states its extended melee reach but omits
  the guide's non-adjacent targeting and no-retaliation rule (printed page 20).
  Those details remain a mechanics-enrichment task, not a new ability identity.
- The four Gathering Storm creatures and their later Winds of War adventure
  dwellings have different introduction dates. The existing descriptions make
  that distinction correctly; creature and dwelling releases must not be merged.

## Heroes V starting data

`heroes45.patch.json` supplies:

| Change | Count |
|---|---:|
| `HeroHOMM5.StartingArmy` fills | 103 |
| Missing hero specialty-name fills | 11 |
| Explicit starting `HeroSkill` links | 22 |

The [community-compiled 3.1 manual](https://h5.heroes.net.pl/uploaded/download/other/Heroes5-Manual-en-3-1.pdf)
has 113 hero panels on pages 11–69, representing 106 shared catalog identities.
Its [hosting page](https://h5.heroes.net.pl/download/latki-programy-i-inne)
identifies it as a fan-made manual. It is not a publisher's original manual;
developer endorsement is not established by this source record.
Every panel's named creature stacks and quantities were extracted. Fixed
numbers use `count`; intervals use `minimum` and `maximum`. Zero lower bounds
and repeated stack slots are preserved. Tieru has two stacks; the other panels
have three. Rendered pages were checked for repeated stacks and variant forms.
War machines have no H5 Creature identities in the catalog, so they are not
inserted into this creature-stack field.

The army panels agree across the shared forms of Freyda, Isabel, Laszlo and
Raelag. Nicolai, Orlando and Ornella have different armies in different class
forms and remain null. Their exact competing armies and page references are
retained in patch metadata. No variant is silently chosen or merged.

Revision-pinned wiki gameplay tables supply the additional skills and
specialties for Erasial, Segref, Glen, Giar, Ohtar, Gamor, Toulain, Dulgan,
Mangu, Ghost and Saint Isabel. Saint Isabel uses only the named subsection of
[Biara's page](https://mightandmagic.fandom.com/wiki/Biara), keeping its data
separate from Biara and Shadya. No values are inferred from a reused portrait.

### Remaining H5 limits

The 18 identities absent from the manual still lack explicit scalar starting
stats: Amin, Batal, Dgum, Dulgan, Erasial, Ferigl, Gamor, Ghost, Giar, Glen,
Gork, Kraal, Mangu, Ohtar, Saint Isabel, Segref, Stephan and Toulain. Reviewed
wiki pages provide various skills and specialties but no explicit numeric
starting attributes or creature counts for these identities. A “copy of”
character note is not used to import a different hero's 3.1 army or statistics.

Nicolai, Orlando and Ornella still have conflicting class-specific starts.
Raven and Arantir each have two starting spells in the manual, while the schema
provides one `StartingSpell_id`; those fields stay null. Laszlo and Raelag also
have differing spell panels. These are source/model limitations, not missing
values that can safely be filled with zero or an arbitrary first spell.

## Validation

A dry run of the existing patch merger with both new patches passed all catalog
and JSON contract checks: **341 additions, 114 null fills, 44,273 resulting
rows** when applied by themselves to the stated baseline. It wrote no shared
catalog, SQL, live database or Git metadata. Delivery and combined totals are
handled by the parent integration task.

Raw wiki text, PDFs, extraction caches and rendered pages stay outside Git.
Only factual names, classifications, short newly written mechanics, stack
quantities and source evidence are included in the patches.
