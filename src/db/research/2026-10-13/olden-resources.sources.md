# Olden Era resources and Astrology completion

Research date: **2026-10-13**. Target: Heroes of Might and Magic: Olden Era
Early Access, retained build `25061458` (snapshot 2026-09-29). This overlay
does not edit the canonical catalog, schema, SQL, GitHub, or a live database.

## What is now source-backed

The patch adds two rows and keeps the Astrology sidecar held:

| Table | Key | Result |
|---|---|---|
| `Resource` | `resource.insight` | Native key `starDust`, staged with the official English gameplay label `Insight` |
| `GameResource` | `homm8.resource.insight` | H8 membership, `Other` class, base Early Access expansion |

The existing `resource.astrology.points` and
`homm8.resource.astrology.points` rows are reused; no duplicate Astrology
Points identity is introduced. The existing `homm8.magicschool.neutral` parent
is also reused.

## `starDust` and “Insight”

The official [Data:Resource index revision 14420](https://wiki.hoodedhorse.com/Heroes_of_Might_and_Magic_Olden_Era/index.php?oldid=14420&title=Data:Resource)
lists `Data:Resource/starDust`. The [resource entry revision 14434](https://wiki.hoodedhorse.com/Heroes_of_Might_and_Magic_Olden_Era/index.php?oldid=14434&title=Data:Resource/starDust)
confirms the native entry `resource/starDust`, but exposes no localized English
display string. The current [CargoCoverage page](https://wiki.hoodedhorse.com/Heroes_of_Might_and_Magic_Olden_Era/Data:CargoCoverage)
lists the resource with no article candidate.

The official English [Map Objects page](https://wiki.hoodedhorse.com/Heroes_of_Might_and_Magic_Olden_Era/Map_Objects)
states that an **Altar of Insight** grants 1 Insight and that Insight is used
to learn or upgrade Global Map spells. The retained build extractor also reads
the native `starDust` key from spell learn/upgrade costs in
[`research-remaining-homm8.mjs`](../../tools/research-remaining-homm8.mjs).

Therefore the semantic correspondence is strong enough for the shared FK
parent: `starDust` is the resource represented by the gameplay label Insight.
The patch does **not** claim that `Insight` is the exact missing localization
token; that remains explicitly unresolved because the public Cargo page does
not expose it. This is also distinct from the separate official `Insight`
hero skill (`skill_enlightenment`), which increases XP and has unrelated
subskills; see the [official Insight page](https://wiki.hoodedhorse.com/Heroes_of_Might_and_Magic_Olden_Era/Insight).

## Why `AstrologyHOMM8` remains held

The official [Wisdom page](https://wiki.hoodedhorse.com/Heroes_of_Might_and_Magic_Olden_Era/Wisdom)
states that Stargazer grants **+500 Astrology Points per day**, doubled by
Scouting. This establishes the existing Astrology Points resource identity and
its skill-generated income, but does not say that `astrology_exp` is the
neutral-spell progression meter.

The official [Neutral Spells page](https://wiki.hoodedhorse.com/Heroes_of_Might_and_Magic_Olden_Era/Neutral_Spells)
states that neutral spells **gain** progression points from actions: unlocking
a normal spell grants 1 point, leveling a normal spell grants 1 point,
constructing a building grants 2 points, and constructing a Mage Guild grants
6 points. It also places neutral spell tiers at hero levels 1, 3, 6, 9 and 12.
Individual neutral spell levels are 1–4. The page does not identify this
progression meter as `astrology_exp` or `starDust`.

The retained extractor identifies `starDust` in spell learn/upgrade cost
entries, but that does not prove that `starDust`, Astrology Points, and the
unnamed neutral progression points are the same ledger. `AstrologyHOMM8` is
therefore held until a build-matched configuration maps both resource FKs, the
gain progression, and the schema's threshold/rule fields. No thresholds, cost
direction, or cross-resource join is invented.

## ResourceHOMM8 boundary

No `ResourceHOMM8` row is staged. Its required `IsTradeable`, `IsMineProduced`
and `IsPersistent` booleans are not all explicitly established for the target
build by the reviewed official pages. Resource identity, H8 membership, and
Astrology FK semantics can be completed without turning absence into false;
the detail flags remain held for a build-matched resource definition. The two
shared identity rows remain valid independently of those detail flags.

## Verification

The patch JSON contains 2 additions and 0 fills. Repository dry-run:

```text
Dry run valid: 1 patch file(s), 2 addition(s), 0 fill(s), 43738 resulting rows. No files written.
```
