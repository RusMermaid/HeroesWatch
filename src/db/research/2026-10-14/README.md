# October 14 catalog additions

Four reviewed patches extend the 43,932-row catalog at `7ad2a6b` to **45,560
rows**: 1,628 additions and 191 null fills. Existing identities and non-null
facts are preserved. Source disagreements are retained in the evidence.

| Patch | Additions | Null fills | Evidence |
|---|---:|---:|---|
| Heroes IV abilities | 319 | 0 | [IV/V sources](heroes45.sources.md) |
| Heroes V starts | 22 | 114 | [IV/V sources](heroes45.sources.md) |
| Heroes VI/VII | 1,217 | 14 | [VI/VII sources](heroes6-7.sources.md) |
| Olden Era | 70 | 63 | [Olden Era sources](olden.sources.md) |

The [audit](../../data/research-2026-10-14-evidence.json) preserves exact rows,
field fills, source references and patch hashes. To reproduce, use the pristine
43,932-row baseline with `apply-research-patches.mjs --input BASELINE
--patch-dir src/db/research/2026-10-14 --output CANDIDATE --evidence-output AUDIT
--apply`. Never apply these additions to a catalog that already contains them.

After review, `node src/db/tools/build-research-sql.mjs` generates the latest
[2,377-row import](../../data/research-gaps-import.sql), including dependencies.
The default builder now targets this dated package. The October 13 audit and
`research-import.sql` remain historical artifacts; reproducing that SQL requires
its original catalog and explicit `--research-root src/db/research/2026-10-13`,
`--evidence` and `--output` arguments.

Migration **0007** stores warfare progression profiles and source-unknown
exceptional fields without weakening ordinary creature requirements. See the
[architecture](../../ARCHITECTURE.md) and [delivery review](../../reviews/2026-10-14/COMPLETION.md).
