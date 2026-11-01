# Follow-up on the remaining VI/VII fields

The catalog now contains **45,616 rows**. Compared with `9450e79`, this update
adds **56 detail rows**, fills **20 null fields**, and enriches three JSON
profiles with **nine previously absent numerical values**.

## Result

- **50 additional VII Hall flags** are supported by the wiki's explicit
  standard-hero roster. Together with the prior editor evidence, **72 of 132
  flags are known**. The other **60 remain unknown**, with every affected hero
  named in the [review matrix](../../research/2026-10-14/h67-hall-review.json).
- **All four VI class-default rows** are added as documented derivations of
  their neutral base-lineage starting templates. They do not describe current
  attributes at promotion or imply a stat reset.
- **Both VI Shadow Lurker/Watcher profiles** preserve the Russian wiki's raw
  magic defense of **10.5**. Migration 0008 changes the field to bounded NUMERIC
  without rounding prior data. All 109 VI creatures now have a detail row;
  the previously identified boss-field gaps still remain.
- **Nine VII profile facts** use the explicit per-level wiki tables: three
  Ballista defense values, five Healing Sister defense values and Dreamwalker
  level-five healing. Conflicting published values are retained in the audit.

These statistics are canonical **wiki-snapshot choices**, not proof that every
conflicting source is wrong. [Source policy, alternatives and derivations](../../research/2026-10-14/h67-resolution.sources.md).

## Validation and deployment

The schema retains 176 tables, 1,309 columns and 452 foreign keys. Migrations
0001–0007 remain unchanged. The existing Node suite passed: 116 passed,
zero failed, one Windows file-symlink permission skip.

PostgreSQL 18.4 fresh/repeated imports and populated upgrades through 0008
passed, comparing 267,563 supplied fields and 180,672 FK references. A restored
copy of the actual 45,560-row database retained every original ID. A deliberately
conflicting third JSON profile rolled back the earlier enrichments in the same
transaction. Repeating the enrichment and content import changed no rows or IDs.

For a database already at migration 0007 and 45,560 rows, apply:

1. `0008_fractional_magic_defense.sql` once.
2. `h67-profile-enrichment.sql`.
3. The current `research-gaps-import.sql`.

The full catalog is current for new databases. The cumulative October 14 audit
now contains five patches and describes 1,684 additions and 211 null fills over
the original 43,932-row research baseline. The prior 45,560-row receipt remains
historical evidence for commit `9450e79`.

**Live deployment completed:** pgAdmin returned 45,616 rows, 72 supported Hall
flags, 60 unknown flags, 36 VI class details, 109 VI creature profiles, both
10.5 defense values and the reviewed VII values. The three-step script completed
in **6.253 seconds**. See the [follow-up receipt](resolution-deployment.json)
and [verification](resolution-verification.json).
