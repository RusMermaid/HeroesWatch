# Heroes IV creature abilities — source and architecture record

Research date: 2026-10-13. This is an isolated research overlay for the
existing 74 Heroes IV creature detail rows. It does not edit
`heroeswatch.json`, the SQL schema, JSON contracts, the live database, or
GitHub.

## Deliverable coverage

The companion `heroes4-abilities.patch.json` contains:

| Addition | Count |
|---|---:|
| Canonical `Ability` identities | 76 |
| Shared-PK `AbilityHOMM4` rows | 76 |
| `CreatureAbility` links | 167 |
| H4 creatures covered | 74 |

The 76 identities are deduplicated across creatures. For example, `Flying`,
`Undead`, `Ranged attack`, `No retaliation`, and `Spellcasting` are shared
ability identities, while each creature receives its own FK-backed link. The
project codes are stable identifiers such as `H4_FLYING` and
`homm4.ability.flying`; they are not claimed to be native executable or
internal game IDs.

## Evidence

### Original manual

The [Heroes IV User Manual reproduction](https://manualmachine.com/gamespc/heroesofmightandmagiciv/1119181-user-manual/)
is the official 2002 manual text hosted on a manual archive rather than the
publisher’s original host. Its printed
page 51 / PDF page 26 says that creature information includes a description
of the creature and its abilities, and that every creature has at least one
special ability. The combat section (printed pp. 55–57 / PDF pp. 28–29)
distinguishes melee, ranged and spell attacks from special abilities. This
supports the model’s separation between ordinary creature statistics and
`Ability`/`CreatureAbility` relationships.

The manual is the primary rules reference for the general ability categories
and combat distinctions only. It does **not** directly provide the 76
per-creature ability rows used below. The specific labels and mechanics are
secondary original-ruleset table evidence; they are not claimed to be a
developer data dump or 76 primary-manual records.

### Original-ruleset creature tables

The seven [Jaskinia Behemota Heroes IV creature pages](https://h4.heroes.net.pl/jednostki/neutralne)
are the source pages for the links in the patch:

- [Haven / Life army](https://h4.heroes.net.pl/jednostki/armia-przystani)
- [Preserve / Nature army](https://h4.heroes.net.pl/jednostki/armia-rezerwatu)
- [Asylum / Chaos army](https://h4.heroes.net.pl/jednostki/armia-azylu)
- [Necropolis / Death army](https://h4.heroes.net.pl/jednostki/armia-nekropolis)
- [Academy / Order army](https://h4.heroes.net.pl/jednostki/armia-akademii)
- [Stronghold / Might army](https://h4.heroes.net.pl/jednostki/armia-twierdzy)
- [Neutral creatures and expansion creatures](https://h4.heroes.net.pl/jednostki/neutralne)

These pages expose each creature’s ability icon, localized ability label and
mechanics summary. They separate the original-ruleset table from the
Equilibris section. They are not developer package dumps or forum content, so
the patch identifies them accurately as secondary original-ruleset evidence.

Source-quality count: the manual directly supports the general model (0
per-creature ability rows); the secondary tables support 76 deduplicated
ability identities and 167 creature links. The 74 creature details are
existing catalog rows, not new combat-stat claims.

## Canonicalization and effect kinds

The source icon stems were used only as evidence anchors and normalized into
project-owned English names/codes. No internal game ID was fabricated. The
`AbilityHOMM4.EffectKind` classification is deliberately conservative and is
based on the explicit mechanic text, not on a creature name or artwork:

- `Passive`: always-on immunities, movement/attack traits, mechanical/undead
  traits, resistances, ranged properties, and map traits;
- `Spellcasting`: the source explicitly describes a creature as casting a
  spell list;
- `Activated`: the source describes a mana-cost ability that the player uses;
- `Triggered`: the source describes an on-attack, on-hit, on-death, or
  beginning-of-turn effect;
- `Other`: a source names an ability but does not supply a trustworthy
  mechanic.

`AbilityHOMM4.Mechanics` is left `NULL` because the current repository JSON
contract reserves non-null H4 mechanics JSON. The concise source-backed
summary is held in the generic `Ability.Description`; the patch does not alter
the contract or invent a JSON shape.

Magic Mirror is classified as a triggered reaction because the source says it
responds to an incoming spell. Explicit casting rows are `Spellcasting` or
`Activated`; attack/on-hit/start-of-turn behavior is `Triggered`. The two
placeholder source labels—Zombie Endurance and Behemoth Strength—use the
schema-neutral `Other` bucket only to satisfy the required enum; their
`TriggerType` is explicitly `Unresolved source description` and no effect is
claimed.

Representative links include:

| Creature | Ability relationships captured |
|---|---|
| Squire | Stun |
| Ballista | Siege penetration, Long range, Mechanical, Ranged attack |
| Angel | Resurrection, Flying |
| Phoenix | Fire breath, Fire resistance, Rebirth, Flying |
| Medusa | Stone gaze, Unlimited ammunition, Normal melee, Ranged attack |
| Ghost | Incorporeal, Aging, Flying, Undead |
| Devil | Protection from Life, Summon ice demon, Teleportation |
| Water elemental | Spellcasting, Elemental, Cold attack, Cold resistance |
| Catapult | Incendiary missiles, Siege engine, Mechanical, Ranged attack |

## Explicit source gaps

- The source names Zombie’s `Endurance` and Behemoth’s `Strength`, but their
  descriptions are placeholders rather than mechanics. Both are represented
  as `Ability`/`AbilityHOMM4`/`CreatureAbility` facts with
  `EffectKind=Other` and an unresolved trigger, instead of incorrectly saying
  those creatures have no ability parents.
- Some spellcasting pages list localized spell names, damage snippets, or
  community-noted bugs. The patch records the creature’s ability relationship
  and the broad documented mechanic, but does not invent a spell-child
  relationship or copy an unverified numeric formula into JSONB.
- The manual and these tables do not provide a complete developer-native
  identifier registry. Stable project codes are therefore the only IDs used.

## Verification

The overlay was checked locally with `python3 -m json.tool`. Structural checks
confirmed:

- 76 `Ability` rows each have one matching `AbilityHOMM4` row;
- all 167 `CreatureAbility` rows point to one of those 76 ability keys;
- all 167 creature links target the 74 existing `homm4.creature.*` rows;
- every row is scoped to `homm4.game` and no existing H4 catalog row is
  overwritten.

The manual is credited only for the general ability model (not per-row ability
proof). Per-row labels and links are marked in the JSON evidence as
`secondary-original-ruleset-table`. No row is described as primary-manual or
developer-package verified.

No database application, schema edit, full-game download, or forum source was
used for this overlay.
