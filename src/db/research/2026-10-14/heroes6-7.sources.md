# Heroes VI and VII: wiki-backed gap additions

Research date: **2026-10-14**. This patch follows the user's clarification to
use the project's wiki references. It adds published facts without claiming a
retained game-package extraction or overwriting existing non-null values.

## Added content

| Table | Additions |
|---|---:|
| Ability | 335 |
| CreatureAbility | 826 |
| BuildingCreature | 12 |
| CreatureHOMM6 | 14 |
| CreatureHOMM7 | 19 |
| HeroClassHOMM6 | 2 |
| HeroClassHOMM7 | 9 |
| **Total** | **1,217** |

There are also **14 null-only VI growth fills**. The patch is
`heroes6-7.patch.json`; every action carries a source and section. The companion
`heroes6-7.wiki-revisions.json` pins wiki revision IDs, revision dates and
SHA-256 digests. `build-heroes6-7.mjs` reproduces the patch from these revisions;
`--fetch` retrieves missing revision text into the ignored research cache.
After integration, use `--input` with the pre-merge catalog at commit
`7ad2a6b` to reproduce this exact addition set.
Source text and artwork are not copied into the public catalog.

## Named creature abilities

The English [VI](https://mightandmagic.fandom.com/wiki/Heroes_VI_creatures) and
[VII](https://mightandmagic.fandom.com/wiki/Heroes_VII_creatures) creature
articles explicitly list the imported ability names. The extractor reads only
the `Abilities` heading and its children, stopping at the next heading of the
same or higher level. Table heading cells and definition-list terms provide
names; bold numbers inside descriptions, achievements, tactics and minion
sections are excluded. Repeated names across alternate forms are deduplicated.

- VI: **577 links across all 109 catalogued creatures**.
- VII: **249 links across 136 creatures**, including seven warfare units.
- Eight VII ordinary creatures explicitly have no abilities: Crossbowman,
  Defender, Gnoll, Hunter, Kobold Scout, Pixie, Sentinel and Stalker. No invented
  ability row is inserted to make their junction count nonzero.
- Eight further VII warfare units explicitly have no abilities in their
  Russian articles: Great Pyramid, Small Pyramid, Greater Earth Elemental,
  Spitting Spider, Cave Wyvern, Shadow Lurker, Tamed Cyclops and Fire Cannon.
  The other four warfare pages do not publish an ability list. Absence of a
  list is not treated as proof that a unit has no mechanic.

These are named relationships. Numeric effects, active/passive classification
and form restrictions are not automatically inferred from prose. `Parameters`
and generic ability descriptions remain null where no reviewed typed summary
was added. Consequently these additions do not claim complete mechanics.
Creature mechanics have their own `CREATURE_*` codes; a same-name hero spell
or skill perk is not silently substituted for a creature ability.

## Heroes VI creature profiles

Thirteen existing boss identities now have partial stat profiles from their
English wiki gameplay infoboxes. The new `MightResistancePercent` and
`MagicResistancePercent` fields preserve the displayed percentage directly.
Raw `MightDefense` and `MagicDefense` remain null: a displayed resistance is
not a defense-point value, and inversion can be ambiguous.

Known damage, maximum health, speed, initiative, luck, morale and range are
transcribed. An explicitly printed single damage value is a constant range
(`DamageMin = DamageMax`). `Dragonwraith.Health = 70000` is maximum health;
the source separately reports 35,000 starting health. Boss movement and
occupied-square footprint remain null, including where the article merely
says `Large` or `Huge`. Abyssal Worm also lacks speed, initiative and luck;
Uriel lacks range. These rows are useful partial profiles, not full statistics.

The [Russian Spectral Dragon page](https://mightandmagic.fandom.com/ru/wiki/Фантомный_дракон)
supplies a complete ordinary summoned-creature profile: raw defenses 27/28,
55–61 damage, 315 health, speed 7, flying movement, initiative 45, luck 7,
morale 0 and no ranged attack. Large uses the catalog's ordinary 2×2 convention.
The wiki explicitly identifies growth as a game-file value while saying this
creature is not recruited normally; `Recruitable` therefore remains false.

**Shadow Lurker and Shadow Watcher remain unresolved.** Their published magic
resistance is 22%, but the Russian wiki prints 10.5 raw defense and the
[Japanese Dungeon table](https://w.atwiki.jp/homm/pages/206.html) prints 11.
The ordinary-town constraints still require integer raw defenses, so neither
conflicting value is fabricated or rounded into a new row.

## Heroes VI classes and growth

The Russian [Darkblade](https://mightandmagic.fandom.com/ru/wiki/Клинок_Тьмы_(класс_героя,_HoMM_VI))
and [Sorcerer](https://mightandmagic.fandom.com/ru/wiki/Колдун_(класс_героя,_HoMM_VI))
pages give initial attributes in this order: Might Power, Might Defense,
Magic Power, Magic Defense, Leadership, Destiny.

| Class | Initial attributes |
|---|---|
| Darkblade | 3, 1, 2, 1, 1, 1 |
| Sorcerer | 2, 1, 2, 2, 1, 1 |

The four promoted classes have documented faction, base-class and reputation
paths, but their pages do not publish separate initial attributes or prove an
inheritance rule. Their required numeric detail rows remain absent.

The [Haven](https://w.atwiki.jp/homm/pages/154.html) and
[Dungeon](https://w.atwiki.jp/homm/pages/206.html) pair tables supply the 14
null-only growth fills. Existing populated values are preserved. Praetorian
growth 14 is also explicitly documented in the official
[September 2012 update](https://store.steampowered.com/oldnews/8931).

## All nine missing Heroes VII class rows

The [Russian wiki class category](https://mightandmagic.fandom.com/ru/wiki/Категория:Классы_героев_HoMM_VII)
links separate articles with explicit level-up attribute percentages. Each row
uses one article's complete four-value table, with the exact revision pinned
in the patch. No Unofficial Community Patch table is used.

| Class | Might | Defense | Magic | Spirit |
|---|---:|---:|---:|---:|
| Archon | 5 | 25 | 25 | 45 |
| Embalmer | 10 | 15 | 35 | 40 |
| Engraver | 15 | 15 | 35 | 35 |
| Firebrander | 15 | 10 | 40 | 35 |
| Hell Knight | 35 | 35 | 10 | 20 |
| Jarl | 30 | 35 | 20 | 15 |
| Runelord | 15 | 15 | 35 | 35 |
| Thane | 25 | 40 | 15 | 20 |
| Warlord | 40 | 30 | 15 | 15 |

Archon is recorded as defensive and Embalmer as balanced, following the
articles' descriptions and skillwheel roles. Their English category labels
were inconsistent with that content. Hell Knight is the special Dungeon
class used by Agrael and Ergal; its ordinary offense/balanced/defense focus is
left null. Skill-probability tables are not confused with attribute growth.

## Heroes VII warfare profiles and recruitment

All nineteen warfare identities now have a detail row. Their five-element
stat vectors are preserved in typed `WarfareStats.profiles`, with one-based
source positions. The corresponding Russian articles explicitly label these
positions as warfare levels 1–5. The [Warfare skill article](https://mightandmagic.fandom.com/ru/wiki/Искусство_войны_(HoMM_VII))
also gives the progression: Novice grants level 2, Expert level 3, Master
level 4 and Perfect Warfare level 5. The JSON retains the source-list order
without adding an inferred mastery FK.

Rank-varying scalar columns remain null. Explicit invariant attack zero and
initiative are stored normally. **All nineteen Russian profiles explicitly
say the unit does not move**, so `Movement = Stationary` and `Speed = 0` are
supported. Their footprint is labelled absent; that does not prove a numerical
occupied-square count, so `CombatSize` remains null.

The Russian ability sections distinguish support effects from normal attack
damage and supply these progressions, with a conflicting value withheld:

| Warfare unit | `supportEffect` | Amount at levels 1–5 |
|---|---|---|
| Healing Tent | Healing | 30, 50, 100, 200, 400 |
| Healing Sister | Healing | 30, 50, 100, 150, 250 |
| Mother Treant | Renewal | 20, 40, 60, 120, 300 |
| Runestone | Healing | 11, 14, 17, 20, 50 |
| Dreamwalker | Healing | 20, 40, 60, 120; level 5 unresolved |
| Faceless | DeathCloak | 30, 45, 60, 90, 120 |
| Namtaru | DarkTouch | 1, 1, 1, 1, 2 |

`DeathCloak` means Dark damage dealt to an attacker by the applied cloak;
`DarkTouch` means additional Dark damage per creature in the targeted stack.
Namtaru and Dreamwalker are `AttackAndSupport`, and their profiles retain both
normal damage ranges and their separate support amounts. The English
Runestone damage range is not imported as an attack; the Russian article
explicitly says it does not attack and gives healing amounts separately.

### Cross-language disagreements

| Field | English wiki | Russian wiki | Import decision |
|---|---|---|---|
| Haven Ballista defense, levels 1–5 | 10, 15, 20, 25, 30 | 10, 15, 25, 30, 40 | Keep agreeing levels 1–2; leave defense absent for levels 3–5. |
| Healing Sister defense, levels 1–5 | 10, 15, 20, 25, 30 | 5, 10, 15, 20, 25 | Leave defense absent at every level. |
| Dreamwalker initiative | 100 | 21 | Use 21, also corroborated by the independent [Acid Cave Stronghold table](https://www.heroes7.acidcave.net/creatures_stronghold.html). |

The Acid Cave table prints Dreamwalker level-five healing as 300, while the
Russian wiki prints 600. That profile's `effectAmount` is left absent. Its
normal attack range and other known values are still recorded.

The other published attack, defense and health vectors agree between both wiki
languages. No existing value is overwritten by these decisions. A wiki
transcription remains distinct from a version-pinned game-file verification.

The seven faction pages explicitly establish these twelve purchase edges:

| Faction | Building | Warfare unit |
|---|---|---|
| Academy | Workshop | Healing Tent |
| Academy | Pyramidal Craft | Small Pyramid |
| Dungeon | Chamber of Whispers | Faceless |
| Dungeon | Pillar of Eyes | Shadow Lurker |
| Fortress | Rune Designer | Runestone |
| Fortress | Armory | Dwarven Ballista |
| Haven | Blacksmith | Ballista |
| Haven | Convent of Elrath | Healing Sister |
| Necropolis | Namtaru Nest | Namtaru |
| Stronghold | Dream Lodge | Dreamwalker |
| Sylvan | Blacksmith | Sylvan Ballista |
| Sylvan | Garden of the Sacred Seed | Mother Treant |

The source aliases `Fortress Ballistae`, `Sister healers` and `Rune Stones`
map to the existing faction-specific identities above. All seven Russian
siege-unit profiles explicitly say they cannot be recruited and describe use
during town sieges. Their missing town-purchase edges are therefore not
automatically an error.

## Remaining boundaries

- Four VI promoted-class defaults and two VI ordinary-creature raw defenses
  remain unresolved.
- Thirteen VI boss profiles and all nineteen VII warfare profiles still have
  explicitly unknown fields; a populated detail row does not mean every field
  is complete.
- This patch does not set the 110 unresolved VII Hall flags. A campaign role
  or hero article is not sufficient evidence of global Hall eligibility.
- Wiki revision dates identify the transcription version, not a verified
  original-game patch. Balance disagreements are reported rather than hidden.

The patch passed the existing schema-aware dry-run merge with schema overlay
7: **1,217 additions, 14 fills**, with no baseline deletion or non-null
replacement. Database application and PR delivery are handled by the parent
task.
