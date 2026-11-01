# Heroes II starting secondary skills

Research date: **2026-10-13**. This is a non-destructive research overlay. It
does not edit `heroeswatch.json`, the generated SQL, the schema, or a live
database.

The companion patch adds **90 `HeroSkill` rows for 54 Recruitable Heroes II
heroes**. The current catalog has nine Recruitable heroes in each of the six
classes, so the class defaults produce one row for Barbarian and Wizard
heroes, and two rows for Knight, Necromancer, Sorceress, and Warlock heroes.
The 19 `CampaignOnly` and four `MapOnly` heroes are deliberately excluded.

## Primary source

The [3DO/New World Computing Heroes II manual reproduction at
ManualMachine](https://manualmachine.com/gamespc/heroesofmightandmagicii/1118154-user-manual/)
has the class defaults in the **Types** table on printed p.44 (PDF page 45).
The table introduces the rows as the attributes and skills with which heroes
start, then gives these six class rules:

| Hero class | Starting secondary skills | Materialized mastery |
| --- | --- | --- |
| Barbarian | Pathfinding | Advanced |
| Knight | Ballistics; Leadership | Basic; Basic |
| Necromancer | Wisdom; Necromancy | Basic; Basic |
| Sorceress | Wisdom; Navigation | Basic; Advanced |
| Warlock | Wisdom; Scouting | Basic; Advanced |
| Wizard | Wisdom | Advanced |

The [Old Games Download manual text mirror](https://oldgamesdownload.com/manual/heroes-of-might-and-magic-ii-dos-manual-english/)
provides a second searchable reproduction of the same class pages. The
manual's later **Secondary Skill Advancement** table (printed p.49 / PDF
page 50) describes weighted *future level-up choices*; it is not used as
evidence for starting skills. This distinction prevents `SecondarySkillWeights`
from being mistaken for hero assignments.

## Roster and junction scope

The current catalog was independently counted before creating the patch:

```text
HeroHOMM2.Availability = Recruitable: 54
  Barbarian: 9   Knight: 9   Necromancer: 9
  Sorceress: 9   Warlock: 9   Wizard: 9
CampaignOnly: 19
MapOnly:       4
HeroSkill rows already present for HOMM2: 0
Rows added: 90
```

Each row follows the existing generic `HeroSkill` junction contract:
`Game_id = homm2.game`, the canonical `Hero_id`, the existing `Skill_id`, and
the existing `Mastery` enum (`Basic` or `Advanced`). The stable `_key` is the
project's descriptive import identity, for example
`homm2.hero.gwenneth.skill.ballistics`; it is not a native executable ID.

The resulting query path is:

```text
HeroHOMM2 (Recruitable)
  -> Hero.HeroClass_id
  -> HeroSkill (starting assignment)
  -> Skill (Mastery)
```

No `HeroSkillHOMM2` table is required by the current architecture; the
cross-game `HeroSkill` junction carries the game discriminator and existing
game/hero/skill integrity checks.

## Why `StartingSkills` remains NULL

`HeroClassHOMM2.StartingSkills` is a nullable JSONB profile, while the current
reviewed JSON contract does not define a canonical object shape for class skill
profiles. Filling it with an ad-hoc array would duplicate the normalized
foreign-key assignments and could diverge from the actual `HeroSkill` rows.
This patch therefore records the usable query path in `HeroSkill` and leaves
all six class profile fields unchanged.

If a future contract needs a class-level denormalized profile, a precise
versioned shape should be approved first, for example:

```json
{
  "version": 1,
  "skills": [
    { "skill_id": "homm2.skill.ballistics", "mastery": "Basic" }
  ]
}
```

That is a proposal only and is not part of this patch.

## Validation

The patch was merged only in memory with the repository's validator:

```text
Dry run valid: 1 patch file(s), 90 addition(s), 0 fill(s), 40113 resulting rows. No files written.
```

The cumulative catalog remains unchanged. No campaign/map-only skill rows were
created, and no starting skill was inferred from `SecondarySkillWeights`.

## Remaining boundary

The manual establishes class defaults, not scenario-specific overrides or the
historical initial skills of campaign/map-only protagonists. Those heroes need
separate scenario evidence and remain outside this overlay by design.
