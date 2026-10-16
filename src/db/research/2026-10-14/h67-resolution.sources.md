# Follow-up: Hall flags, class defaults and conflicting statistics

Baseline: `9450e79`, 45,560 rows. This follow-up adds **56 detail rows**, fills
**20 null availability fields** and supplies **nine absent JSON stat values**.
The resulting catalog has **45,616 rows**. Existing IDs and established
numerical values are preserved.

## Hall flags: 50 supported additions, 60 still unknown

The wiki's [standard-hero roster](https://mightandmagic.fandom.com/wiki/Template:H7char?oldid=171605)
explicitly lists 70 standard heroes. Twenty already had detail rows from the
editor manual; those gain `Availability=Standard`. The other fifty gain
`HeroHOMM7` rows with `IsHallHero=true` and `Availability=Standard`.

The two other previously verified editor-list heroes retain their existing
true flags. There are now **72 supported flags out of 132**. The
[complete review matrix](h67-hall-review.json) names all sixty still unknown.
The roster is incomplete: it even omits two heroes positively shown in the
editor manual. Its omissions therefore cannot establish a false flag.
Campaign participation also cannot establish exclusion: several explicitly
standard heroes are campaign protagonists or antagonists.

Hall eligibility describes the catalog identity. Actual enabling remains a
map/player choice, and some heroes have edition or unlock restrictions. This
does not claim that every true hero is available in every map or account.

## Four VI class defaults: derived base-lineage templates

| Promoted class | Base class | Path | Might power / defense, magic power / defense, leadership, destiny |
|---|---|---|---|
| Shadow Slayer | Darkblade | Blood | 3 / 1, 2 / 1, 1, 1 |
| Trickster | Darkblade | Tears | 3 / 1, 2 / 1, 1, 1 |
| Dark Prophet | Sorcerer | Blood | 2 / 1, 2 / 2, 1, 1 |
| Shadow Weaver | Sorcerer | Tears | 2 / 1, 2 / 2, 1, 1 |

These are **derived starting templates**, following the existing promoted-class
model. They are not measured attributes at the moment of promotion and do not
imply that promotion resets a hero's statistics. The base pages publish the
initial numbers and the reputation paths. The [Reputation article](https://mightandmagic.fandom.com/wiki/Reputation?oldid=173314)
states that non-campaign heroes begin neutral. [Eruina's gameplay section](https://mightandmagic.fandom.com/wiki/Eruina?oldid=174224)
explicitly distinguishes her displayed Dark Prophet dynasty class from her
Sorcerer default in a new game. The developer's [alignment Q&A](https://www.gamespot.com/articles/might-and-magic-heroes-vi-updated-qanda-alignment-and-the-future-of-might-and-magic/1100-6336620/)
also states that faction and Might/Magic affinity are permanent, while
reputation can change. The patch records this derivation on every class row.

## Canonical wiki values and retained alternatives

The user asked to resolve the remaining fields using wiki sources. The catalog
now follows the explicit, revision-pinned Russian wiki stat tables for these
disputed fields. This is a documented source-precedence decision, not proof
that the alternate source is erroneous or that a particular game package was
inspected. Full revisions and hashes accompany the actions.

| Field | Catalog value | Retained alternative |
|---|---|---|
| VI Shadow Lurker/Watcher raw magic defense | 10.5 | Japanese Dungeon table: 11 |
| VII Haven Ballista defense, levels 1–5 | 10, 15, 25, 30, 40 | English wiki: 10, 15, 20, 25, 30 |
| VII Healing Sister defense, levels 1–5 | 5, 10, 15, 20, 25 | English wiki: 10, 15, 20, 25, 30 |
| VII Dreamwalker healing at level 5 | 600 | Acid Cave: 300 |

The [VI Lurker](https://mightandmagic.fandom.com/ru/wiki/Вестовщик_(HoMM_VI)?oldid=121374)
and [Watcher](https://mightandmagic.fandom.com/ru/wiki/Соглядатай_(HoMM_VI)?oldid=121375)
tables explicitly distinguish raw **10.5** from displayed **22%** resistance.
Migration **0008** changes `CreatureHOMM6.MagicDefense` to bounded PostgreSQL
`NUMERIC`; it preserves prior integer values and prevents silent rounding.
Both ordinary creature profiles retain the existing required-field checks.

The [Ballista](https://mightandmagic.fandom.com/ru/wiki/Баллиста_Альянса_Света?oldid=121731),
[Healing Sister](https://mightandmagic.fandom.com/ru/wiki/Послушница_Эльрата?oldid=121739)
and [Dreamwalker](https://mightandmagic.fandom.com/ru/wiki/Сноходец_(HoMM_VII)?oldid=121741)
tables label all five levels and distinguish healing from attack damage.
Acid Cave independently corroborates Healing Sister's level-one defense of 5.
All nine new JSON facts fill absent properties; no earlier numerical fact is
changed. [Exact before/after profiles](h67-resolution-enrichment.json).

## Reproduction and delivery

The dated research set now contains five accepted patches. The existing VI/VII
reference patch has been enriched with the nine explicit values and their
resolution evidence; its original state remains at commit `9450e79`.
`build-heroes6-7.mjs` applies the checked-in resolution after reconstructing
the original source tables. The cumulative audit retains every patch hash.

For a 45,560-row database at migration 0007, apply **0008**, then
`data/h67-profile-enrichment.sql`, then the current `research-gaps-import.sql`.
The guarded enrichment accepts only the recorded old or final JSON profiles;
unexpected local edits abort the transaction. New empty databases use the
current schema and full catalog normally.

The old October 14 deployment receipt remains historical. The latest result
is recorded in [the follow-up delivery record](../../reviews/2026-10-14/RESOLUTION.md).
