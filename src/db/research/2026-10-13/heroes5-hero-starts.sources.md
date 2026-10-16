# Heroes V 3.1 hero starting data — 2026-10-13

This research emits only `heroes5-hero-starts.patch.json`. It does not edit
`src/db/data/heroeswatch.json`, the schema, or SQL. The patch is intended to be
merged into the current catalog and then passed through the normal validator and
import builder.

## Source and extraction

Primary source: the developer-supported Heroes V (3.1) manual:

`https://h5.heroes.net.pl/uploaded/download/other/Heroes5-Manual-en-3-1.pdf`

The selective range helper `src/db/research/2026-10-13/read-manual-pages.py`
retrieved pages **11–69** in small byte-range runs, each capped at 16 MiB. The
58 MB manual was not downloaded in full. The selected pages were rendered, with
the stat-panel layout spot-checked visually and the remaining pages read through
positioned PDF text; no forum, mod-wiki, or class-default inference was used.

The four stat icons are read in the manual's visual order: sword = Attack,
blue orb = Spell Power, shield = Defense, book = Knowledge. The patch writes
them in the schema order `StartingAttack`, `StartingDefense`,
`StartingSpellPower`, `StartingKnowledge`.

The starting spell is added only when the `Army & Spells` panel names a spell
that already exists in the H5 `Spell` catalog. Starting skills are taken only
from explicit `Basic`, `Advanced`, or `Expert` skill labels that map to an
existing H5 `Skill` row. Specialization abilities and long effect prose are not
turned into `HeroSkill` rows. `StartingArmy` is intentionally outside this
patch's scope.

## Patch coverage

| Item | Count |
|---|---:|
| Current H5 generic hero rows | 124 |
| Manual roster entries on pages 11–69 | 113 |
| Unique manual hero identities represented on pages 11–69 | 106 |
| Scalar `HeroHOMM5` fills | 412 |
| `StartingSpell_id` fills | 44 |
| `HeroSkill` additions | 207 |
| Current H5 identities not represented in selected pages | 18 |

The 18 current identities not represented in these manual roster pages remain
untouched: Amin, Batal, Dgum, Dulgan, Erasial, Ferigl, Gamor, Ghost, Giar,
Glen, Gork, Kraal, Mangu, Ohtar, Saint Isabel, Segref, Stephan, and Toulain.
They need a separate supported source pass; no class-default values are copied
to them here.

## Same-name identities and conflicts

The catalog deliberately shares same-name ruleset/class forms for Nicolai,
Orlando, and Ornella. Their manual forms disagree on starting stats, so the
patch leaves all four scalar fields unset for those shared rows. Their variant
specific starting skills and spells are not merged.

The manual also shows variant forms for Freyda, Isabel, Laszlo, and Raelag. The
shared forms agree on starting stats, so scalar values are filled. Only skills
common to every form are emitted. Starting spells are filled only when every
form agrees: Freyda agrees on Haste; Laszlo and Raelag have conflicting/null
spell panels and remain null. Isabel has no starting spell in the panels.

Raven (PDF p.53) and Arantir (PDF p.55) each display two spells in the same
`Army & Spells` panel. Because `HeroHOMM5` has one `StartingSpell_id` slot, the
patch leaves those fields null rather than selecting one spell or inventing an
additional slot.

All patch fills have `expected: null`, and every addition uses the existing
parent `_key`. No current H5 `HeroSkill` rows existed before this patch.

## Evidence boundary

The manual pages are a game-level 3.1 roster source. They provide the displayed
starting stats, starting skills, and starting spells for the named forms shown
there. They do not establish universal class defaults for heroes absent from the
roster pages, nor do they justify copying one class's values to another hero.
