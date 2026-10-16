# October 14 catalog update

This records the initial 45,560-row delivery. The subsequent
[VI/VII resolution](RESOLUTION.md) brings the catalog to 45,616 rows.

The catalog contains **45,560 rows**. Four reviewed patches add **1,628 rows**
and fill **191 null fields** over `7ad2a6b`, preserving existing identities and
non-null facts. [Exact research audit](../../data/research-2026-10-14-evidence.json).

| Area | Added or completed |
|---|---|
| Heroes IV | 76 abilities, 76 detail rows and 167 links covering 74 creatures; wiki evidence with licensed official-guide corroboration |
| Heroes V | 103 starting armies, 11 specialty names and 22 starting-skill links |
| Heroes VI | 14 creature profiles, two class details, 14 growth fills and 577 creature-ability links |
| Heroes VII | All nine missing classes, 19 warfare profiles, 12 recruitment links and 249 creature-ability links |
| Olden Era | Nine alternative attacks, five schools, eleven resources, Astrology, 21 map/scenario details and two tutorial/challenge campaign details |

The VI/VII links use 335 new creature-ability identities. VI boss profiles are
partial: resistance percentages are stored separately from raw defense. VII
warfare profiles preserve published progression values, including stationary
movement and distinct support effects. Disputed values remain absent.

## Architecture and validation

Migration **0007** retains **176 tables and 452 foreign keys**, with **1,309
columns**. It adds resistance and warfare fields, nullable exceptional-source
fields, and checks retaining ordinary creature requirements. The new JSONB
profile has closed keys, bounded numerical values and semantic validation.
Migrations **0001–0006 remain unchanged**.

- Node suite: **116 passed, zero failed, one skipped** because this Windows
  environment denied file-symlink creation. That test still runs on supported
  environments.
- PostgreSQL **18.4** fresh and repeated imports passed, with exact comparison
  of **266,781 supplied fields and 180,606 FK references**.
- Populated upgrades through 0007 passed. Invalid baselines rolled back
  migrations 0006 and 0007 atomically. Concurrency and isolation probes passed.
- The actual Windows database backup was restored to a disposable database.
  Its upgrade preserved **all 40,023 original IDs**, removed no rows, and
  changed no unexpected non-null values. The 32 reviewed changes were 28 H1
  speed conversions and four H3 dragon tiers. Repeating the delta changed no
  rows or IDs.

[Machine-readable verification](verification.json).

## Deployment

The validated upgrade sequence for the Windows database at migration 0002 is:

1. Migrations 0003, 0004 and 0005.
2. `creature-tier-corrections.sql`, then the historical `research-import.sql`.
3. Migrations 0006 and 0007.
4. `research-gaps-import.sql`.

The historical research catch-up supplies resource memberships before migration
0006 validates the newer guards. Existing databases already at a later stage
must apply only the missing steps. Never rerun a migration or a bootstrap over
an already migrated schema.

**Live deployment completed on 2026-10-14** to the local **HeroesWatch.net**
database owned by **postgres**. pgAdmin reported successful execution in
**20.312 seconds** and returned all 20 review metrics, including 45,560 rows
and 1,309 columns. A private custom-format backup was made and restored for
preflight before execution. pgAdmin remains open on the final report.
See [the deployment receipt](deployment.json). The source documents below identify
the remaining gaps independently of deployment status.

## Remaining gaps and disagreements

- VI: four promoted-class defaults and two ordinary-creature raw defenses;
  boss footprints and some other statistics remain unknown.
- VII: 110 Hall-availability flags, warfare footprints and conflicting values
  in Ballista/Healing Sister defense and Dreamwalker support progression.
- IV: original executable verification is not claimed; the licensed guide
  predates the expansions and has some discrepancies with the wiki.
- V: unresolved hero variants and unsupported scenario-specific numerical
  starts remain documented.
- Olden Era: unknown optional mode/resource flags and nonuniform Astrology
  thresholds remain null. Advanced Tutorial has inconsistent difficulty-index
  definitions. Build 25061458 rules are distinguished from newer wiki systems.
- The six previously recorded manual disagreements remain unresolved.

Sources: [IV/V](../../research/2026-10-14/heroes45.sources.md),
[VI/VII](../../research/2026-10-14/heroes6-7.sources.md),
[Olden Era](../../research/2026-10-14/olden.sources.md).
