# JSON payload contracts

`../tools/json-contracts.mjs` is the shared source for JSONB ingestion checks and
the generated `data.schema.json`. Every JSONB column has an explicit policy;
adding a new JSONB column without a policy stops generation.

## Reviewed source profiles

Populated payloads use closed objects: unknown field names, wrong scalar types,
wrong containers and oversized values are rejected. Nested objects and arrays
are checked too. Examples include Heroes II artifact modifiers, Heroes III
primary-skill bonuses, Heroes IV spell effects, Heroes VI weapon progression and
Heroes VII spell formulas by mastery. Formulas are bounded text, never executable
expressions.

Two source shapes are deliberately scalar:

- `HeroClassHOMM1.ClassEffect` is a non-empty string.
- `FactionMagicSchoolHOMM5.GuaranteedSlotsPerCircle` is a uniform integer count,
  from zero to five, for each spell circle.

`Lore.SourceLinks` accepts the three existing reference formats: a title and
HTTP(S)/manual locator; a local manual URI and PDF page; or a title, SHA-256 and PDF
page with an optional printed page. Page numbers must be positive. This checks
the reference structure; it does not authenticate the PDF or verify its contents.

The validator additionally checks that primary-skill probabilities total 100,
weapon experience thresholds increase with level, and army quantity ranges are
consistent. These cross-field arithmetic checks supplement JSON Schema.

Campaign availability and scenario-edge conditions require a description and
source locator. Optional `nativeCounters` retain source-native counter names,
an `And`/`Or` operator and typed numeric comparisons. The nested objects are
closed; these counters are script state rather than catalog entity IDs. Scenario
and campaign endpoints continue to use foreign keys.

Heroes III campaign scenario rules use two closed profiles. `StartingBonuses`
distinguishes ordinary bonus choices, prior-scenario hero crossover and explicit
hero selection; `CarryoverRules` stores the native keep mask and the permitted
creature/artifact sets. Native numeric IDs are retained beside verified catalog
import-key annotations. Normal bundle validation requires those annotated hero,
creature, artifact, spell, skill, resource and scenario keys to exist in Heroes
III scope before SQL generation. They are **not PostgreSQL foreign keys**:
universal catalog tables do not store `_key`, and the importer serializes JSONB
verbatim rather than rewriting nested annotations to physical BIGINT IDs.
Direct SQL JSON edits can bypass this application-layer validation. Generic
building bonuses retain their native building kind because they resolve against
the receiving town and have no single faction-specific building endpoint.
`VictoryConditions` and `LossConditions` use separate discriminated profiles for
the original H3M condition kinds, bounded positions and time/resource amounts;
artifact, creature and resource targets use the same native-ID-plus-import-key
annotation pattern.

No repository API resolver currently provides a guaranteed conversion from a
nested import-key annotation to the stored `(Game_id, Code)` business identity.
Treat these strings as validated provenance annotations, not SQL-queryable
relationships. Consumers needing joins should use the existing normalized
junctions (for example `ScenarioConnection` and `CreatureAbility`) or introduce
a reviewed relation/persistent import-key registry instead of parsing `_key`
text.

## Shared structural profiles

Army and guard arrays contain `creatureKey` plus either `count` or a
`minimum`/`maximum` range. Terrain/faction/spell lists contain unique catalog
keys. Footprints use dimensions, optional blocked cells and an entrance;
town-screen hotspots use a rectangle or polygon. These profiles define shape;
embedded catalog keys are not PostgreSQL foreign keys and require source review
before content is added. Prefer relational tables where one already exists.

## Unprofiled source documents

Some columns have no reviewed non-null content or documented source format.
Their contract deliberately rejects every non-null value (`not: {}` in JSON
Schema). Keep these columns SQL `NULL` until a source-specific contract and tests
are added. A null-only policy prevents arbitrary JSON from entering the catalog;
it does **not** mean the underlying gameplay mechanics are complete.

PostgreSQL stores these columns as JSONB. Shape validation is performed by the
bundle validator and JSON Schema, not by PostgreSQL JSON check constraints.
Direct SQL/GUI JSON edits must be exported and passed through the same validator.
