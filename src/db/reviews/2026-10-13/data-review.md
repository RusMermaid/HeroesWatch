# HeroesWatch final data review — 2026-10-13

This is a read-only review of the final HeroesWatch content package at PR
commit `2848f00` (`heroes.watch_data.manipulation`). It does not add or alter
game data, does not deploy to a database, and does not treat the friend's local
pgAdmin receipt as evidence about this Mac's PostgreSQL instance.

## Verified package

The cumulative JSON contains **40,023 rows across 176 table arrays** and **23
games**. The exact PR checkout passed:

- `validate.mjs`: valid bundle, 176 tables and 40,023 rows;
- the 48 Node regression tests;
- deterministic generated-schema verification: 176 tables, 1,304 columns and
  450 foreign keys;
- disposable PostgreSQL bootstrap, cumulative import, and `postgres/verify.sql`;
- the read-only deployment review query: 40,023 rows, 176 tables, 23 games,
  36 PDF-manual records, 525 object/creature links, 275 object/faction links,
  404 prerequisite groups, 715 faction/spell links, 868 creature/ability
  links, 373 campaign/scenario links, 316 scenario edges, 417 map/terrain
  links, 5,401 map/object links, and 68 starting-scenario links.

The reconciliation from baseline `225a96b` preserved all existing `_key`
identities: 9,542 rows were added, no rows were removed, 1,233 previously null
fields were filled, and six fort display labels were corrected. The final
import is structurally stable; this report does not claim that every optional
source fact is complete.

## Coverage and relationships

Creature detail coverage is complete for H1–H5 and H8: 28/28, 66/66, 141/141,
74/74, 177/177 and 146/146 respectively. H6 has 93 of 109 creature details
and H7 has 137 of 156. The remaining 16 H6 and 19 H7 details are withheld for
unresolved required statistics, movement, footprint, or progression evidence.
Six H6 and nine H7 class detail rows remain similarly unresolved. H7 has 22
evidence-backed Hall-of-Heroes flags; the other 110 flags remain unknown because
the source makes eligibility map- and player-specific.

The campaign graph has 83 campaigns, 373 campaign/scenario memberships, and
316 progression edges. All campaigns have scenario membership. There are 68
evidence-backed `CampaignHero.StartingScenario_id` values, and each belongs to
the same campaign. The two Heroes II cross-campaign edges are intentional
betrayal/transfer routes, not same-campaign membership errors.

`Lore` does not directly own entity foreign keys. `LoreFull` currently contains
22 evidence-backed links: five to Hero, twelve to Campaign, and five to Faction.
The schema supports CampaignHero, Scenario, and Map endpoints, but no current
rows populate those three endpoint kinds; this is a coverage gap, not a claim
that the lore graph is complete.

The external-dwelling graph contains 525 object/creature links and 275
object/faction links. Random or variable-roster objects such as Refugee Camp,
Elemental Conflux, and Magic Menagerie do not receive invented fixed-creature
edges.

## Source-bounded gaps

- `ResourceHOMM1To5` currently has no rows. H1/H2 `GameResource.ResourceClass`
  values are also null. No resource classifications, mine yields, or market
  values were invented without primary evidence.
- H8 generic catalogs are populated, but `GameHOMM8`, `CampaignHOMM8`,
  `ScenarioHOMM8`, `MapHOMM8`, `MagicSchoolHOMM8`, `ResourceHOMM8`, and
  `AstrologyHOMM8` remain empty because their required source fields were not
  reviewed. The package therefore does not claim complete H8 mechanics.
- Optional formulas, effects, patch histories, campaign scripts, placements,
  RPG-specific detail bands, and unsupported artifact classifications remain
  intentionally absent or null.
- The five creature identities resolved in the follow-up are explicitly marked
  as resolved in `touchups-late-details.sources.md`; they are not part of the
  remaining 16 H6 + 19 H7 creature gap.

The supplied original PDF manuals are not stored in Git. Git contains their
metadata, SHA-256 checksums, relative URIs, and reviewed observations; the PDF
bytes remain in the ignored local manual library. This review did not silently
replace catalog values with manual disagreements.

## Deployment evidence boundary

The PR's `live-deployment.json` records the friend's reported **2026-10-04
Windows/local pgAdmin** receipt for the overlay-v2/`0002` package. The current
local review checkout contains a later reviewed overlay v3 and migration 0003,
which are pending deployment; the Oct 4 receipt does not verify those changes.

For comparison, the following exact read-only query was run against the
existing PostgreSQL server on **this Mac**, not against the friend's Windows
database and not against a remote HeroesWatch.net server:

```sh
/opt/homebrew/bin/psql -X -h /tmp -d HeroesWatch -P pager=off
```

```sql
SELECT version(), current_user, current_setting('port'),
       current_setting('data_directory');

SELECT
  (SELECT count(*) FROM information_schema.tables
    WHERE table_schema = 'heroes_watch' AND table_type = 'BASE TABLE')
    AS schema_tables,
  (SELECT count(*) FROM heroes_watch."Game") AS games,
  (SELECT count(*) FROM heroes_watch."Creature") AS creatures;
```

Observed on this Mac: PostgreSQL 18.6, port 5432, data directory
the Mac's local PostgreSQL server, database `HeroesWatch`,
**173 tables, 6 games, and 152 creatures**. This is an existing older local
database and is explicitly **not** evidence about the friend's Windows/local
pgAdmin deployment. No write was made to it.
