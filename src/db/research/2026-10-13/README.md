# Reviewed research patches — 2026-10-13

This directory is a staging area for small, evidence-backed catalog additions
and null-field fills. A patch is review input, not authority to change the
catalog. Empty research does not count as completion, and the merge tool never
changes files unless `--apply` is supplied explicitly.

## Patch format

Use a uniquely named `*.patch.json` file:

```json
{
  "additions": [
    {
      "table": "Game",
      "row": {
        "_key": "example.game",
        "SeriesCode": "EXAMPLE",
        "DisplayOrder": 99,
        "Name": "Example",
        "ReleaseDate": null,
        "Description": null
      },
      "evidence": {
        "source": "Official manual",
        "locator": "manual:example#pdf-page=1"
      }
    }
  ],
  "fills": [
    {
      "table": "Game",
      "key": "existing.game",
      "field": "Description",
      "expected": null,
      "value": "A sourced description.",
      "evidence": {
        "source": "Official manual",
        "locator": "manual:example#pdf-page=2"
      }
    }
  ],
  "sources": [
    {
      "title": "Official manual",
      "locator": "manual:example",
      "scope": "Pages 1–2"
    }
  ]
}
```

The example is structural only; do not import it as game data.

Researchers may add bounded descriptive metadata such as `formatVersion: 1`,
`researchDate`, `scope`, `verification`, or `blockedFacts`. Metadata is retained
in the evidence audit but is inert: only `additions` and `fills` can alter the
prospective catalog.

Rules:

- Every patch needs at least one addition or fill and at least one source.
- Every action needs non-empty evidence. Evidence may be a string or a bounded
  nested object/array so multiple source locators can be preserved. Each
  evidence value must contain at least one non-empty text citation or claim.
- Additions use `_key` as their only supplied identity and omit the physical PK.
  They cannot replace an existing row.
- Fills identify an existing row by its exact `_key`, require
  `"expected": null`, and can only replace an explicitly null non-identity
  field with a non-null value.
- Put all fields for a new row in its addition; do not fill a row introduced by
  the same patch set.
- Duplicate additions, duplicate/conflicting fills, unknown tables or fields,
  identity changes, and unsupported action properties are rejected.
- The complete prospective catalog must pass `validate.mjs`, including all FK,
  unique-key, same-game, resource-membership, and JSON-contract checks.

## Review workflow

The default scans every staging patch and writes nothing:

```sh
node src/db/tools/apply-research-patches.mjs
```

This directory deliberately includes held/empty research candidates. Therefore
the default all-patch scan is not an approved completion recipe and fails closed.
The final accepted list is recorded in `data/research-2026-10-13-evidence.json`.
The current catalog already contains that merge: do not apply the additions to
it again. Reproduction requires the pristine final-PR catalog as `--input` and
explicit selection of the 16 accepted patches, with separate output paths.
First run `prepare-catalog-v5.mjs --input PR_BASELINE --output PREPARED_BASELINE`
to apply the reviewed Tier naming, numeric speed mapping and dragon tiers.
Then use that prepared file as the research merger's input. The research
audit's input hash refers to this prepared baseline, not the unchanged PR file.

To validate or apply only an explicitly reviewed subset, repeat `--patch`:

```sh
node src/db/tools/apply-research-patches.mjs \
  --patch src/db/research/2026-10-13/resources.patch.json \
  --patch src/db/research/2026-10-13/homm3.patch.json
```

An explicitly selected empty patch is rejected; it is never silently skipped.

Review every patch diff and its cited sources. Then, and only then, apply the
validated merge:

```sh
node src/db/tools/apply-research-patches.mjs \
  --input /path/to/pr-baseline.json \
  --output /path/to/reviewed-catalog.json \
  --evidence-output /path/to/reviewed-evidence.json \
  --patch src/db/research/2026-10-13/resources.patch.json \
  --apply
```

The default apply target is `src/db/data/heroeswatch.json`. The deterministic
audit trail is written to
`src/db/data/research-2026-10-13-evidence.json`. Use `--output` and
`--evidence-output` to stage both files elsewhere for review. Apply prepares and
validates the entire result before replacing either target; failures leave the
targets unchanged. Immediately before apply, the tool rechecks that the input
catalog and any pre-existing custom outputs have not changed since validation,
and refuses symbolic-link or aliased output targets. The evidence audit retains
the exact added rows and each patch file's SHA-256 so the applied snapshot can be
reconstructed even if a staging patch is later revised.

After an approved apply, regenerate the reviewed SQL artifacts and run the full
Node and isolated PostgreSQL verification suites. The patch merger does not
connect to PostgreSQL, create migrations, invent missing facts, or modify GitHub.

For a smaller, reproducible research-only import, build from the final evidence
audit and verify the accepted patch hashes rather than selecting all staging
candidates:

```sh
node src/db/tools/build-research-sql.mjs
node src/db/tools/build-research-sql.mjs --check
```

This produces `src/db/data/research-import.sql`. Its closure contains every
audited addition/fill and ordinary relational dependency. For `ScenarioHOMM3`,
it also includes only the reviewed native-rule import-key annotations documented
in `schema/JSON_CONTRACTS.md`, including the matching Heroes III `GameResource`
memberships. Those nested keys remain ingestion annotations—not PostgreSQL
foreign keys—and arbitrary JSON key-shaped strings are not traversed.
