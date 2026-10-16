# Classic shared resources research — 2026-10-13

This research owns only the portable resource patch in
`resources.patch.json`. It does not edit `src/db/data/heroeswatch.json` and it
does not add SQL or binary media. The coordinating task should merge the patch
into the cumulative bundle, run the normal validator, and regenerate the
transactional import.

## Proposed completion

The architecture has one global `Resource` identity and a shared-PK
`ResourceHOMM1To5` detail band. The patch adds exactly seven detail rows using
the seven classic resource identities already present in `Resource`:

| Resource | `ResourceHOMM1To5.ResourceClass` | Optional mine/market/pile fields |
|---|---|---|
| Gold | Gold | left `NULL` |
| Wood | Basic | left `NULL` |
| Ore | Basic | left `NULL` |
| Mercury | Rare | left `NULL` |
| Sulfur | Rare | left `NULL` |
| Crystal | Rare | left `NULL` |
| Gems | Rare | left `NULL` |

The original Heroes III player manual names all seven resources in the
“Resource Mines and Loose Resources” section (PDF p.17) and shows the seven
mine/resource types in “Resource Information” (PDF p.57). The rendered pages
were inspected, not inferred from text extraction alone. The local PDF and its
observed checksum are recorded in the patch's `sources` array; the PDF itself
is not committed.

`ResourceClass` is a normalized cross-game category, not a claim that the
games have identical prices, mine yields, market exchange rates, or loose-pile
ranges. Those optional fields remain `NULL` because a single value across
HOMM1–HOMM5 would conflate game and edition rules. `NULL` here means
“not established for this shared detail,” not zero and not a measured absence.

## H1/H2 membership fills

The cumulative catalog already has all seven `GameResource` memberships for
HOMM1 and all seven for HOMM2. No new membership junction rows are needed.
The patch fills only their 14 missing `ResourceClass` values:

- Gold → `Currency`;
- Wood and Ore → `Common`;
- Mercury, Sulfur, Crystal, and Gems → `Rare`.

The H1/H2 official-manual-backed catalog note records the building-cost
resource usage and its primary/manual cross-checks in
`src/db/data/homm1-homm2-catalog.sources.md`. The classification labels follow
the already trusted classic taxonomy used by existing HOMM3 `GameResource`
rows, whose source note identifies the same global resource identities. This is
a derived normalization of established resource names and classes, not a new
game-value claim.

## Junction audit and exclusions

The patch intentionally adds no `GameResource` membership rows:

- HOMM1: 7 existing memberships;
- HOMM2: 7 existing memberships;
- HOMM3: existing memberships and cost junctions are already populated;
- H1 Rogue → Gold and H1 Spell Book → Gold cost junctions are already present;
- the existing H1/H2 building and creature cost junctions resolve to the
  existing memberships.

No HOMM5 rare-resource memberships or costs are invented here. The existing
HOMM5 source extraction explicitly leaves additional rare-resource icons out
when the source text does not identify them. Filling those would require a
separate primary source pass and a broader resource-cost review.

## Evidence boundary

Primary evidence used directly for this patch:

1. The original Heroes III manual, `Heroes3_Manual.pdf`, PDF
   pages 17 and 57, with the observed SHA-256 recorded in the patch.
2. The repository's existing H1/H2 source reconciliation and manual registry,
   which preserve the official manual identifiers and page-level research
   provenance.
3. The repository's existing trusted HOMM3 resource memberships and source
   note, used only for the shared normalization labels.

This patch does not claim that the H3 manual is an H1/H2 manual; it uses the
H1/H2 source note to establish applicability and the original H3 manual to
confirm the shared classic resource vocabulary. It does not assign optional
quantities where the evidence is game-dependent.
