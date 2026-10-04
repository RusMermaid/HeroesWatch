# Heroes III faction entry: sources and mapping

Researched on 2026-09-06. Cumulative content file: [heroeswatch.json](heroeswatch.json).

The user supplied these nine names: Castle, Rampart, Tower, Inferno,
Necropolis, Dungeon, Stronghold, Fortress, and Conflux. The entry uses the
classic Shadow of Death rules with Armageddon's Blade content enabled.

## Scope and release provenance

The first eight factions originated in The Restoration of Erathia. Conflux
was introduced by Armageddon's Blade, as documented in the original
[Armageddon's Blade manual, page 13, transcribed by the wiki](https://heroes.thelazy.net/index.php/Armageddon%27s_Blade_Manual_Page_13).
The wiki's [Town overview](https://heroes.thelazy.net/index.php/Town) corroborates
the original eight plus Conflux roster.

The [Shadow of Death overview](https://heroes.thelazy.net/index.php/The_Shadow_of_Death)
states that a standalone Shadow of Death installation needs Armageddon's
Blade installed to enable Conflux. The requested nine-faction roster is
therefore recorded with that content enabled. It does not imply that
Conflux originated in Shadow of Death or is playable in every standalone
installation. The schema has introduction provenance, but no faction-to-edition
availability junction; no extra field or duplicate faction was invented.

## Entered mechanics

The [Alignment table](https://heroes.thelazy.net/index.php/Alignment) supplies
the alignment values. Its good/evil/neutral labels are normalized to the
schema's exact ENUM values `Good`, `Evil`, and `Neutral`.

The [Terrain table](https://heroes.thelazy.net/index.php/Terrain#Basic_Terrains)
supplies the basic-terrain classification and native-terrain relationships.
These are secondary wiki sources, not direct extraction from installed game
files. Their mod-specific entries are excluded from this batch.

| Faction | Alignment | Native terrain | Introduced in |
|---|---|---|---|
| Castle | Good | Grass | The Restoration of Erathia |
| Rampart | Good | Grass | The Restoration of Erathia |
| Tower | Good | Snow | The Restoration of Erathia |
| Inferno | Evil | Lava | The Restoration of Erathia |
| Necropolis | Evil | Dirt | The Restoration of Erathia |
| Dungeon | Evil | Subterranean | The Restoration of Erathia |
| Stronghold | Neutral | Rough | The Restoration of Erathia |
| Fortress | Neutral | Swamp | The Restoration of Erathia |
| Conflux | Neutral | Grass | Armageddon's Blade |

The [Conflux page](https://heroes.thelazy.net/index.php/Conflux) explicitly
distinguishes Grass for Shadow of Death from Highlands for Horn of the Abyss.
This batch uses Grass. No HotA or other mod factions or mechanics are included.

## Architecture mapping

- One `Game` row uses the `homm3.game` identity and `SeriesCode: "HOMM3"`.
  `DisplayOrder: 3` is an editorial ordering value for the third series title,
  not a researched game mechanic.
- Three `Expansion` rows distinguish the base game (`Kind: "BaseGame"`),
  Armageddon's Blade, and The Shadow of Death (`Kind: "Expansion"`).
  Codes `ROE`, `AB`, and `SOD` are stable project identifiers, not physical IDs.
- Nine `Faction` rows own names, game ownership, and introduction provenance.
  Faction codes use uppercase versions of the user-supplied names.
- Nine `FactionHOMM3` rows reuse the corresponding faction `_key` and store
  `Alignment` and `NativeTerrain_id`. They do not allocate another identity.
- Seven `Terrain` rows are shared by the nine faction details; each reference
  resolves within the same bundle and game. These terrain names describe
  basic land types already present in the base game.
- All 173 table arrays remain present. Other tables are empty. Numeric primary
  keys and physical shared primary keys are omitted. No ad-hoc fields, embedded
  relational-ID documents, or schema changes are needed.
- Nullable descriptions, media references, and release dates remain `null`.
  No release dates, descriptive lore, media assets, or terrain movement costs
  were researched for this faction batch. There are no missing required values.
- The cumulative file uses the documented `heroeswatch.json` filename and
  the exact Game field names from the data dictionary.

These decisions follow [ARCHITECTURE.md](../ARCHITECTURE.md),
[DATA_ENTRY.md](../DATA_ENTRY.md), and [DATA_DICTIONARY.md](../DATA_DICTIONARY.md).
The faction tables have no dedicated source columns, so provenance is kept in
this companion document, as permitted by the handoff workflow.

## Validation and handoff

Run from the repository root:

```sh
node src/db/tools/validate.mjs src/db/data/heroeswatch.json
```

Validation passed for the initial Heroes III-only bundle on 2026-09-06:

```text
Valid HeroesWatch data bundle: 173 tables, 29 rows.
```

The total comprises 1 game, 3 releases, 9 factions, 9 faction details, and
7 terrains. A separate architecture check passed for the requested roster,
shared keys, same-game references, original release provenance, and the
Shadow of Death Conflux terrain. The current validator does not enforce all
of these domain semantics.

The checked-in generator's raw `--check` comparison is sensitive to CRLF.
Regenerating into a temporary directory confirmed that all 10 generated
artifacts match this checkout after normalizing Windows line endings; no
schema-content discrepancy was found.

## PostgreSQL application

[homm3-factions.sql](homm3-factions.sql) is the batch-specific application
script corresponding to this JSON entry. It resolves references to generated
or existing PostgreSQL IDs, reuses parent IDs in `FactionHOMM3`, fills only
missing sourced values in existing rows, and aborts if existing non-null
facts disagree with the batch. Descriptions, media, release dates, and other
content already present are preserved. Constraints stay enabled and are
checked before the transaction commits.

On 2026-09-06, the script was applied successfully to the local
`HeroesWatch.net` database through its existing PostgreSQL 18 connection in
pgAdmin 4. The preflight schema counts were 173 tables, 1,285 columns, and
349 foreign keys. The import returned all nine requested factions. A fresh
pgAdmin query session independently returned the same nine rows after the
commit, with faction IDs 1 through 9 and the alignment, terrain, and release
values shown above.

[homm3-factions.review.sql](homm3-factions.review.sql) is a read-only query
joining the game, generic factions, shared-PK details, terrains, and releases
for verification in pgAdmin. JSON editing and database insertion remain
separate operations; editing the JSON later does not automatically update
the server.
