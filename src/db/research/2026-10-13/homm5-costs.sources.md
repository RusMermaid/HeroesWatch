# Heroes V 3.1 creature and town-building costs

Research date: 2026-10-13. Ruleset: Tribes of the East 3.1, including the
base game and Hammers of Fate content represented by the final handbook.

## Source and scope

The sole factual source for this patch is the
[Heroes V Manual — Tribes of the East 3.1](https://h5.heroes.net.pl/uploaded/download/other/Heroes5-Manual-en-3-1.pdf),
created by the international Heroes community with Ubisoft and Nival support.
No forum, wiki, mod, or inferred faction affinity supplies any value.

- Printed/PDF pp. 161–168: the eight faction creature tables. The `+1` and
  `+2` tier-seven rare-resource components supplement the gold costs already
  in the catalog.
- Printed/PDF pp. 211–242: all eight factions' town-building entries,
  including cost icons and quantities, explicit `Requires` lists, stated
  `An upgrade of ...` relationships, and numeric town-level requirements.
- Printed/PDF p. 191: the labelled rune-cost page used as an independent icon
  legend. It anchors the decoded 16x15 resource images to wood, ore, mercury,
  sulfur, crystal, and gems. Gold is the remaining icon and is also labelled
  in ordinary building-cost prose.

The remote source observed during extraction was 58,182,081 bytes with ETag
`"377c9c1-6042b7303c15b"`. Only selective page PDFs were range-read into a
temporary directory; the 58 MB manual and its prose/art are not stored in the
repository.

## Normalized result

| Result | Rows |
|---|---:|
| Tier-seven `CreatureResourceCost` additions | 24 |
| `BuildingResourceCost` additions | 924 |
| Explicit `BuildingRequirement` additions | 192 |
| Stated `BuildingUpgrade` additions | 133 |
| Source-explicit `TownLevelRequired` null fills | 5 |
| Total additions / fills | 1,273 / 5 |

All 292 Heroes V town buildings matched exactly one manual heading. Of these,
276 have a cost row; the 16 without one are the eight free Village Halls and
the eight Tear of Asha/Grail structures. Every one of the 924 building cost
quantities is paired with a resource icon on the same visual row. Every
faction's tier-seven base creature has one rare resource at quantity 1, and
its standard and alternative upgrades have the same resource at quantity 2.

The creature-page resource transcription is:

| Faction | Base / upgrades resource |
|---|---|
| Academy | Gems |
| Dungeon | Sulfur |
| Haven | Crystal |
| Inferno | Sulfur |
| Necropolis | Mercury |
| Sylvan | Gems |
| Fortress | Crystal |
| Stronghold | Mercury |

## Architecture mapping

- Costs are atomic normalized rows keyed by `(Game, entity, Resource)` rather
  than a JSON object or faction-level default. This preserves PostgreSQL FK
  integrity to both the shared `Resource` and the Heroes V `GameResource`
  membership.
- A manual `Requires` comma list is conjunctive. Each named prerequisite is a
  separate `BuildingRequirement` row; the scalar `Town Level N` stays in
  `BuildingHOMM5.TownLevelRequired`.
- `BuildingUpgrade` records only the manual's explicit `An upgrade of ...`
  statement. It is kept separate from buildability: several upgraded buildings
  state a base building in prose but require a different structure in the
  manual's `Requires` line.
- Exact prerequisite tokens are used. For example, `Dragon Graveyard` does not
  accidentally create a second dependency on the distinct `Graveyard` row.
- The patch never overwrites a non-null fact. The five scalar fills are guarded
  by `expected: null`; 219 already populated town-level values were compared
  against the manual and had no conflicts.

The patch intentionally does not copy effect prose, invent costs for free or
Grail structures, derive hidden prerequisites, or alter the separately reviewed
Heroes V `GameResource` and rune-cost patch.

## Reproduction and verification

`src/db/research/2026-10-13/read-manual-pages.py` creates the temporary
references in two-page ranges (building pages 211–242) and three-page ranges
(creature pages 160–168), each under the helper's 16 MiB transfer cap.
`src/db/tools/research-homm5-costs.py --reference-dir /tmp` then rebuilds the
patch with fixed coverage, icon-digest, row-arity, no-overwrite, and count
assertions.

The resulting patch was dry-run and applied only to a temporary catalog with
the repository patch tool. The temporary result passed the schema/FK validator
at 176 tables and 43,399 rows. The 192 Heroes V prerequisite edges and 133
upgrade edges were separately checked as acyclic; every Heroes V entity/resource
pair is unique. No live database or cumulative catalog was modified by this
research step.
