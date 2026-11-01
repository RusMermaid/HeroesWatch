# Local manual library

The supplied Downloads PDFs are registered in the database's `MediaAsset`
table. [The inventory](../data/manual-inventory.json) lists 38 source files,
deduplicated by SHA-256 to 36 documents. Identical copies share one record.

Each source is copied locally to `files/<first-12-sha256-characters>/manual.pdf`.
The database URI `manuals/files/<id>/manual.pdf` resolves relative to `src/db`.
PostgreSQL stores the document's metadata and URI; the PDF bytes stay on disk.
These local copies are excluded from Git because redistribution rights have
not been established. A fresh checkout contains metadata but requires the
same user-supplied PDFs to restore the local library.

See [the comparison report](../data/MANUAL_COMPARISON.md), its
[field observations](../data/manual-comparison.json), and
[content evidence](../data/manual-content-evidence.json) for extracted facts
and page references. PDF page numbers are one-based; printed pagination may
differ, especially in scans containing two printed pages per PDF page.

The KOGWIN imagined Heroes VIII design and Third Upgrade Mod manuals have
source records only. They do not supply official-game facts. The repository's
`HOMM8` code continues to mean Olden Era.
