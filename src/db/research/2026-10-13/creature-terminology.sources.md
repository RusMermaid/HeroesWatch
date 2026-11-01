# H1–H2 creature `Speed`, `SpeedName`, and `Tier`

Research date: **2026-10-13**. Read-only evidence; no catalog, schema, SQL, or
database was changed. The planned detail model is numeric `Speed` plus a
generated game-scoped `SpeedName`; `Movement` remains separate from speed.

## H1: reconstructed retail implementation

Primary labels come from the [3DO/New World Computing H1 manual](https://manualmachine.com/gamespc/heroesofmightandmagic/1118196-user-manual/):
`Slow`, `Medium`, `Fast`, with flying shown separately in displays such as
`Medium/Fly` and `Fast/Fly`. The manual says Speed controls combat order,
distance, and manner of movement.

Pinned public reverse-engineered retail reconstruction (commit
`a3cead98e3b2ab6f5dff14165910b29da173d91a`; reconstructed, not publisher
source): [CreatureSpeed enum](https://github.com/sushi-shi/homm1-decomp/blob/a3cead98e3b2ab6f5dff14165910b29da173d91a/include/SOURCE/creatureTypes.h),
[combat pathfinder](https://github.com/sushi-shi/homm1-decomp/blob/a3cead98e3b2ab6f5dff14165910b29da173d91a/src/SOURCE/FINDPATH.cpp),
and [hero mobility](https://github.com/sushi-shi/homm1-decomp/blob/a3cead98e3b2ab6f5dff14165910b29da173d91a/src/SOURCE/HERO.cpp).

```text
Speed 1 = Slow; Speed 2 = Medium; Speed 3 = Fast; Speed 4 = Blazing (Haste)
Combat path: FindCombatPath/PushCombatPoint rejects distance > speed.
Therefore base H1 combat movement is 1/2/3 hex steps.
Adventure map: CalcMobility uses {40, 50, 60} for Slow/Medium/Fast.
```

`None = 0` and `Blazing = 4` are engine/status or Haste states, not base
creature rows. The current 28 H1 rows are Slow 5, Medium 14, Fast 9.

## H2: manual labels and pinned open-engine implementation

The [3DO/New World Computing H2 manual](https://manualmachine.com/gamespc/heroesofmightandmagicii/1118154-user-manual/)
uses the exact labels `Very Slow`, `Slow`, `Average`, `Fast`, `Very Fast`, and
`Ultra Fast`.

Pinned fheroes2 implementation (commit
`88aa8f404296823a0bdc3bed494d1e045e496e0c`; open reimplementation, not
publisher source): [`speed.h`](https://github.com/ihhub/fheroes2/blob/88aa8f404296823a0bdc3bed494d1e045e496e0c/src/fheroes2/kingdom/speed.h),
[`speed.cpp`](https://github.com/ihhub/fheroes2/blob/88aa8f404296823a0bdc3bed494d1e045e496e0c/src/fheroes2/kingdom/speed.cpp),
[`monster_info.cpp`](https://github.com/ihhub/fheroes2/blob/88aa8f404296823a0bdc3bed494d1e045e496e0c/src/fheroes2/monster/monster_info.cpp),
[`battle_pathfinding.cpp`](https://github.com/ihhub/fheroes2/blob/88aa8f404296823a0bdc3bed494d1e045e496e0c/src/fheroes2/battle/battle_pathfinding.cpp),
and [`heroes.cpp`](https://github.com/ihhub/fheroes2/blob/88aa8f404296823a0bdc3bed494d1e045e496e0c/src/fheroes2/heroes/heroes.cpp).

```text
2 Very Slow   3 Slow   4 Average   5 Fast   6 Very Fast   7 Ultra Fast
8 Blazing and 9 Instant are engine/spell states, not current base rows.
Battle path cost is bounded by _speed; adjacent-cell steps cost 1.
Adventure map points for 2..7 are 1000, 1100, 1200, 1300, 1400, 1500.
```

The current 66 H2 rows are exactly: 2:8, 3:4, 4:22, 5:15, 6:15, 7:2; no
8/9 values. `Flying` stays in `Movement`; `SpeedName` must not become
`Medium/Fly` or create another speed band.

## Planned `Tier` meaning

The current H1/H2 `Level` values 1–6 are the town creature ladder; neutral rows
are NULL. The planned architecture column is `Tier` (same values, no inference
from Speed), avoiding ambiguity with hero, spell, skill, and random-army
levels. Planned domains:

```text
H1: Tier 1..6 or NULL; Speed 1..3; SpeedName generated from game mapping.
H2: Tier 1..6 or NULL; Speed 2..7; SpeedName generated from game mapping.
```

Adventure movement points are separate from combat hex movement. No canonical
data or schema edits were made in this pass.
