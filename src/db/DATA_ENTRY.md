# Human data-entry guide

This workflow lets a researcher enter content without manually allocating
database IDs or understanding the SQLDesigner canvas.

## Start a batch

Copy `src/db/data/template.json` to the cumulative working file:

```text
src/db/data/heroeswatch.json
```

Keep every table key in the file. Leave unrelated tables as empty arrays. The
working file is self-contained: every referenced `_key` must exist somewhere
in the same file. Contributors may work on temporary subject files, but merge
them into the cumulative file before final validation and handoff.

Every row requires an import-only `_key`. Use a stable lowercase dotted key:

```text
homm3.game
homm3.faction.castle
homm3.creature.archangel
```

`_key` is never stored as a database column. It lets people write readable
references while the eventual loader resolves physical BIGINT keys.

## Ordinary catalog row

```json
{
  "_key": "homm3.faction.example",
  "Game_id": "homm3.game",
  "Code": "EXAMPLE",
  "Name": "Example",
  "Description": null,
  "IntroducedInExpansion_id": null,
  "MediaAsset_id": null
}
```

The example is structural only; do not import it as game data.

Rules:

- Omit independent BIGINT PK fields; PostgreSQL allocates them.
- Use another row's `_key` in an FK field instead of inventing a number.
- Use exact ENUM spelling and capitalization from the data dictionary.
- Use `null` only for nullable fields.
- Use ISO dates: `YYYY-MM-DD`.
- Keep numbers as JSON numbers and booleans as `true`/`false`.
- Do not put relational IDs or extra ad-hoc fields inside JSONB documents.

## Shared-PK game detail

The generic and detail row use the same `_key`:

```json
{
  "tables": {
    "Faction": [
      {
        "_key": "homm8.faction.example",
        "Game_id": "homm8.game",
        "Code": "EXAMPLE",
        "Name": "Example",
        "Description": null,
        "IntroducedInExpansion_id": null,
        "MediaAsset_id": null
      }
    ],
    "FactionHOMM8": [
      {
        "_key": "homm8.faction.example",
        "NativeTerrain_id": "homm8.terrain.example",
        "SignatureResource_id": "homm8.resource.example",
        "FactionSkill_id": "homm8.skill.example",
        "LawScreenMediaAsset_id": null,
        "NativeTerrainInitiativeBonus": 1,
        "HasFactionLaw": true
      }
    ]
  }
}
```

The physical `Faction_id` is omitted in both rows. The integration step uses
the shared `_key` to give the detail row the generic row's ID.

## `*_cid` junction row

Keep a descriptive `_key` and omit the physical `*_cid` field. The integration
step uses the stable `_key` as the TEXT junction identity. Fill every member
of the declared composite unique key.

```json
{
  "_key": "homm3.creature-ability.example",
  "Game_id": "homm3.game",
  "Creature_id": "homm3.creature.example",
  "Ability_id": "homm3.ability.example"
}
```

## Sources and uncertainty

- Prefer official manuals, official game files, official patch notes, and
  developer publications.
- Preserve the source URL/path in the schema's source fields where available.
- Do not guess a required value. Stop the batch and record the open question.
- Do not encode roadmap or preview content as released content.
- Keep one factual subject or one coherent source set per commit.

## Validate and hand off

```sh
node src/db/tools/validate.mjs src/db/data/heroeswatch.json
```

The validator checks table/field names, required values, scalar types, ENUMs,
duplicate import keys, unique constraints, and references within the bundle.

Pass along:

1. the filled cumulative JSON file;
2. its validation output;
3. a short source list and unresolved questions;
4. no database credentials, local paths, or secrets.

The recipient should review the diff before any database insertion. This
schema-only handoff does not auto-load content. Rows may be entered through a
PostgreSQL GUI, or later application/import code may resolve `_key` values.
Any database application must happen in one transaction with foreign keys
enabled; never disable constraints or delete unrelated rows to make data pass.
