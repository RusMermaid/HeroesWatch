# Heroes VI final follow-up — source and architecture record

Research date: **2026-10-13**. This is a non-destructive research overlay for
the final-catalog review. It does not edit `heroeswatch.json`, generated SQL,
or a live database. The companion patch intentionally has empty `additions`
and `fills`: it records six class-detail candidates, fourteen nullable-growth
candidates, one complete-looking Spectral Dragon profile, and the remaining
creature blockers, but none is mergeable without primary package/UI evidence.

## What is supported as a candidate

The patch records six Dungeon class-sidecar candidates:

| Class | Path | Base class | Default six attributes (Might Power, Might Defense, Magic Power, Magic Defense, Leadership, Destiny) |
|---|---|---|---|
| Darkblade | Neutral | — | 3, 1, 2, 1, 1, 1 |
| Shadow Slayer | Blood | Darkblade | 3, 1, 2, 1, 1, 1 |
| Trickster | Tears | Darkblade | 3, 1, 2, 1, 1, 1 |
| Sorcerer | Neutral | — | 2, 1, 2, 2, 1, 1 |
| Dark Prophet | Blood | Sorcerer | 2, 1, 2, 2, 1, 1 |
| Shadow Weaver | Tears | Sorcerer | 2, 1, 2, 2, 1, 1 |

The Russian Darkblade and Sorcerer pages print the initial attribute tables.
The four promoted-class pages identify the exact base class and reputation
path. Copying the base defaults into the non-null sidecar is only a candidate
normalization choice: the repository's existing promotion rows suggest this
pattern, but the source pages do not prove a universal numeric-inheritance
rule. These are secondary game references, not an assertion that an
unavailable final editor package was dumped, and the patch does not add them.

The patch records fourteen null-growth candidates with direct values in the
secondary table:

| Pair | Base growth | Upgrade growth | Applied fields |
|---|---:|---:|---|
| Haven Sentinel → Praetorian | 9 | 14 | `Praetorian.UpgradeGrowth` (Sentinel's 9 already present) |
| Haven Sister → Vestal | 7 | 11 | `Sister.BasicGrowth` (Vestal's 11 already present) |
| Dungeon Assassin → Shade | 7 | 11 | both null fields |
| Dungeon Stalker → Chakram Dancer | 7 | 10 | both null fields |
| Dungeon Minotaur → Minotaur Guard | 3 | 4 | both null fields |
| Dungeon Manticore → Scorpicore | 4 | 5 | both null fields |
| Dungeon Faceless → Faceless Puppeteer | 3 | 5 | both null fields |
| Dungeon Shadow Dragon → Black Dragon | 1 | 2 | both null fields |

The current catalog has separate Haven `Praetorian` and `Vestal` identities;
the table's names are therefore mapped through the existing `CreatureUpgrade`
edges rather than by replacing names or keys. These candidates also remain
unmerged until final package/UI evidence is available.

The same standard requires the complete-looking Spectral Dragon profile to
remain a candidate: its public page is explicit and includes a note about game
file provenance, but no game-file bytes or final editor package are retained in
this checkout. The candidate row would be `CreatureKind=Summoned`,
`Movement=Flying`, `CombatSize=4`, `Recruitable=false`, with raw defenses 27/28
and the other scalar values listed in the patch.

## Existing VI junctions checked while preparing this patch

The cumulative bundle already contains the expected direct relationships for
the six class identities: two `HeroClassAbility` rows per Dungeon class (72
Heroes VI rows total), 42 creature-upgrade edges, 84 town recruitment rows,
and 68 creature-resource-cost rows. This patch does not duplicate those
junctions. If the class candidates later pass primary-source review, their
sidecars would attach to those existing class and ability identities through
shared `_key` references.

## Why the remaining fifteen creature details remain blocked (plus one candidate)

The current schema's `CreatureHOMM6` sidecar requires non-null
`AttackType`, raw integer `MightDefense` and `MagicDefense`, combat stats,
enum `Movement` (`Ground`, `Flying`, or `Teleporting`), and numeric
`CombatSize` (occupied squares). The public boss pages do not provide all of
those fields in a package-pinned form.

The individual pages do publish useful candidate facts—for example, Avatar of
the Void has 250,000 HP, Magic damage, 7,500–10,000 damage, speed 0, initiative
10, range None, and textual size Huge; Thunderbird has 65,000 HP, Magic damage,
450–520 damage, speed 99, initiative 45, range None, and textual size Huge.
Those facts are recorded as evidence-only in the patch's blocker record. They
are not converted into a row because:

- displayed resistances are percentages, not raw defense points;
- the manual formula can yield multiple integer raw defenses (for example,
  64% is compatible with 50 or 51 under the documented rounding);
- `Huge`/`Large` is not a safe conversion to occupied squares;
- the pages omit or script boss movement, and the enum has no stationary or
  scripted value; and
- Shadow Lurker/Watcher specifically conflict across public tables: the
  Russian pages print raw Magic Defense 10.5 (22%), while the Japanese table
  prints 11 (22%). `SMALLINT` cannot preserve that disagreement.

The correct next input is a final-game/editor package or a retained native
data extraction containing raw defense, movement, and footprint. No boss row
is filled from artwork, from a guessed Ground/Flying value, or by copying a
different creature's defenses.

## Sources

### Dungeon classes

- [Darkblade — Russian class page](https://mightandmagic.fandom.com/ru/wiki/%D0%9A%D0%BB%D0%B8%D0%BD%D0%BE%D0%BA_%D0%A2%D1%8C%D0%BC%D1%8B_%28%D0%BA%D0%BB%D0%B0%D1%81%D1%81_%D0%B3%D0%B5%D1%80%D0%BE%D1%8F%2C_HoMM_VI%29) prints the initial six-attribute table and neutral identity.
- [Sorcerer — Russian class page](https://mightandmagic.fandom.com/ru/wiki/%D0%9A%D0%BE%D0%BB%D0%B4%D1%83%D0%BD_%28%D0%BA%D0%BB%D0%B0%D1%81%D1%81_%D0%B3%D0%B5%D1%80%D0%BE%D1%8F%2C_HoMM_VI%29) prints the initial six-attribute table and neutral identity.
- [Shadow Slayer](https://mightandmagic.fandom.com/ru/wiki/%D0%A3%D0%B1%D0%B8%D0%B9%D1%86%D0%B0-%D0%B2-%D0%A2%D0%B5%D0%BD%D0%B8_%28%D0%BA%D0%BB%D0%B0%D1%81%D1%81_%D0%B3%D0%B5%D1%80%D0%BE%D1%8F%2C_HoMM_VI%29), [Trickster](https://mightandmagic.fandom.com/ru/wiki/%D0%9B%D0%BE%D0%B2%D0%BA%D0%B0%D1%87_%28%D0%BA%D0%BB%D0%B0%D1%81%D1%81_%D0%B3%D0%B5%D1%80%D0%BE%D1%8F%2C_HoMM_VI%29), [Dark Prophet](https://mightandmagic.fandom.com/ru/wiki/%D0%A2%D1%91%D0%BC%D0%BD%D1%8B%D0%B9_%D0%BF%D1%80%D0%BE%D1%80%D0%BE%D0%BA_%28%D0%BA%D0%BB%D0%B0%D1%81%D1%81_%D0%B3%D0%B5%D1%80%D0%BE%D1%8F%2C_HoMM_VI%29), and [Shadow Weaver](https://mightandmagic.fandom.com/ru/wiki/%D0%A2%D0%BA%D0%B0%D1%87_%D0%A2%D0%B5%D0%BD%D0%B8_%28%D0%BA%D0%BB%D0%B0%D1%81%D1%81_%D0%B3%D0%B5%D1%80%D0%BE%D1%8F%2C_HoMM_VI%29) identify the four promotions and their Blood/Tears paths.

### Creature growth tables

- The dated [Haven table](https://w.atwiki.jp/homm/pages/154.html) prints Sentinel/Praetorian growth 9/14 and Sister/Vestal 7/11.
- The dated [Dungeon table](https://w.atwiki.jp/homm/pages/206.html) prints Assassin/Shade 7/11, Stalker/Chakram Dancer 7/10, Shadow Lurker/Shadow Watcher 6/9, Minotaur/Minotaur Guard 3/4, Manticore/Scorpicore 4/5, Faceless/Faceless Puppeteer 3/5, and Shadow Dragon/Black Dragon 1/2.

These are secondary tables, but they are explicit pair-level values and are
recorded only as null-only fill candidates. No displayed defense percentages
are copied, and no candidate is merged by this patch.

### Defense and candidate boss facts

- The published [Heroes VI manual 0.921](https://www.scribd.com/document/88970592/Mmh6-Manual-Eng-0-921), pp. 243–244, explains the integer defense/resistance conversion used to reject ambiguous boss percentages. This is the same manual reference already cited by `remaining-homm6-7.sources.md`.
- The [Heroes VI creature roster](https://mightandmagic.fandom.com/wiki/Heroes_VI_creatures) and linked individual pages identify the fifteen remaining blocked records and publish candidate boss profiles. They are retained as secondary evidence only.
- The [Russian Spectral Dragon page](https://mightandmagic.fandom.com/ru/wiki/%D0%A4%D0%B0%D0%BD%D1%82%D0%BE%D0%BC%D0%BD%D1%8B%D0%B9_%D0%B4%D1%80%D0%B0%D0%BA%D0%BE%D0%BD) provides one complete-looking profile—raw 27/28 defenses, explicit flying movement, size, range, health, initiative, luck, morale, and growth—but it is still a secondary transcription and is therefore recorded as a candidate, not an addition.
- The [Japanese Dungeon table](https://w.atwiki.jp/homm/pages/206.html) prints Shadow Lurker/Watcher Magic Defense 11 (22%), while the [Russian Shadow Lurker](https://mightandmagic.fandom.com/ru/wiki/%D0%92%D0%B5%D1%81%D1%82%D0%BE%D0%B2%D1%89%D0%B8%D0%BA_%28HoMM_VI%29) and [Shadow Watcher](https://mightandmagic.fandom.com/ru/wiki/%D0%A1%D0%BE%D0%B3%D0%BB%D1%8F%D0%B4%D0%B0%D1%82%D0%B0%D0%B9_%28HoMM_VI%29) pages print 10.5 (22%). The conflict is deliberately left unresolved.
- Ubisoft's [official 2.1 update notes](https://store.steampowered.com/oldnews/?appgroupname=Ubisoft+Collection&appids=48240%2C201870%2C208480%2C13520%2C19900%2C33460%2C214250%2C48220%2C207490%2C212630&feed=steam_updates) confirm that creature behavior and ability values were patch-sensitive: the notes mention Ahribban's `Ill Blood`, Imperial Griffin, Dreamwalker, and Blazing Glory fixes. They do not publish the missing raw boss fields, so they are used as a version boundary rather than as a stat source.

## Next primary/package requirement

To finish the remaining fifteen blocked `CreatureHOMM6` sidecars and verify
the Spectral Dragon candidate, provide a small
retained extraction of final Heroes VI game/editor definitions rather than a
full game archive. The minimum useful records are the boss raw defenses,
attack mode, movement behavior, and occupied-square footprint, plus the final
Shadow Lurker/Watcher raw Magic Defense representation. Until then, a partial
candidate row is less reliable than an explicit gap.
