# Heroes I–II creature abilities and junctions

Research date: **2026-10-13**. This is a non-destructive research overlay for
the final-catalog review. It does not edit `heroeswatch.json`, generated SQL,
the schema, or a live database.

The companion patch contributes **45 descriptive ability identities** (12 for
Heroes I and 33 for Heroes II) and **87 `CreatureAbility` edges** (18 for
Heroes I and 69 for Heroes II). It deliberately does **not** add empty
`AbilityHOMM1`/`AbilityHOMM2` shared-PK rows: their only non-PK field is the
currently reserved `Effect` payload, so an all-NULL detail row would add no
classification and would falsely imply that a structured effect had been
verified. It does not add ordinary attack edges, infer abilities from movement
or shot counts, or claim that the project codes are native game IDs.

## Primary evidence

### Heroes I

The [official Heroes of Might and Magic user manual mirror](https://retrogamer.biz/wp-content/uploads/2015/10/Heroes_of_Might_and_Magic_-_Manual_-_PC.pdf)
is a scan of the New World Computing/3DO manual. Its creature tables on PDF
pages 82–88 explicitly document:

- Wolf: attacks twice per round;
- Troll: regenerates hit points/damage between turns;
- Cyclops: 20% paralyzation and an attack spanning two spaces;
- Paladin: two attacks per round;
- Sprite and Rogue: attacked creatures cannot retaliate;
- Dwarf: 25% magic resistance;
- Elf: two shots per round;
- Unicorn: 20% chance to blind;
- Phoenix: attack spans two spaces;
- Griffin: unlimited retaliation;
- Hydra: attacks all adjacent spaces and prevents retaliation;
- Dragon: attack spans two spaces and is immune to spells;
- Genie: 10% chance to halve an enemy group; and
- Ghost: each creature killed by a Ghost becomes a Ghost.

The same manual's combat rules on PDF p.50 explicitly identify the Troll
regeneration, Sprite/Rogue/Hydra retaliation exceptions, and unlimited Griffin
retaliation. The source is also available through the [Best Old Games manual
mirror](https://www.bestoldgames.net/download/games/heroes-of-might-and-magic/heroes-of-might-and-magic-manual.pdf).

### Heroes II

The [official Heroes II Gold manual mirror](https://www.scribd.com/document/176070062/Heroes-of-Might-Magic-2-Manual-UK)
and the equivalent [ManualMachine mirror](https://manualmachine.com/gamespc/heroesofmightandmagicii/1118154-user-manual/)
preserve the 3DO/New World Computing manual. Creature tables on printed pages
77–92 explicitly document the H2 mechanics represented in the patch:

- Barbarian/Knight: Wolf/Troll/Cyclops and Paladin/Crusader special attacks;
- Crusader: Curse immunity and double damage against undead;
- Necromancer: the complete Necromancer roster plus Ghost is undead, immune to
  mind-affecting spells, Bless, and Curse, with neutral morale;
- Mummy/Royal Mummy: 20%/30% Curse chance;
- Vampire/Vampire Lord: no retaliation; Vampire Lord life drain;
- Lich/Power Lich: ranged Death Cloud affecting adjacent hexes;
- Bone Dragon: lowers opposing morale;
- Sprite, Rogue, and Hydra: no retaliation;
- Dwarf: 25% magic resistance (the manual prints the same wording again below
  Battle Dwarf, but the final Battle Dwarf value is held back pending an
  original-engine or retained-game-data check; see the unresolved discrepancy
  below);
- Elf/Grand Elf: two shots per round;
- Unicorn: 20% Blind chance;
- Phoenix: two-space attack and the literal manual wording “Immune to elemental
  spells.” The patch retains this printed scope only; it does not generalize
  the claim to all spells or to named edge cases such as Armageddon;
- Griffin: unlimited retaliation;
- Green/Red/Black Dragon: two-space attack and spell immunity;
- Mage/Archmage/Titan: no adjacent ranged penalty; Archmage additionally has
  20% beneficial-spell dispel chance;
- Giant/Titan: immunity to mind-affecting spells;
- Genie: 10% chance to halve an enemy group;
- Medusa: 20% chance to turn the victim to stone; and
- Air, Earth, Fire, and Water Elementals: neutral morale, mind-spell
  immunity, and their explicitly printed elemental immunities/vulnerabilities.

The [official-manual text mirror](https://oldgamesdownload.com/manual/heroes-of-might-and-magic-ii-dos-manual-english/)
provides the same creature pages in searchable form. The repository's source
registry identifies the user-supplied H2 Gold manual as
`manual.a99f53fdd378`; the patch retains page-level locators instead of
committing the source PDF.

## Modeling decisions

Each ability receives a descriptive, game-scoped project key such as
`homm2.ability.death.cloud` and a stable `Code` such as
`SPECIAL_DEATH_CLOUD`. These are catalog identifiers, not claims about a
native executable or editor identifier. The human-readable mechanic is kept
in `Ability.Description`.

`AbilityHOMM1.Effect`, `AbilityHOMM2.Effect`, and
`CreatureAbility.Parameters` are deliberately left unused by this overlay. The
repository's JSON contract currently marks all three payload families as
reserved, so placing ad-hoc effect shapes in them would make the import less
trustworthy. The primary manuals prove the mechanics and the normalized
junction membership; structured numeric parameters should be added later under
an approved JSON contract (for example, a versioned chance/target/effect
schema). No shared-PK detail row is created solely to carry a NULL payload.

`Double Shot` is included only because the manuals explicitly say that Elves
fire two shots per round. The ordinary `Shots` column is not converted into a
generic ability. Likewise, flying, ground movement, size, and standard melee
attacks remain in the existing detail tables and do not create ability edges.

The H2 `Undead` edge is applied to the ten Necromancer creatures and Ghost
because the manual explicitly scopes the rule to “all Necromancer units (and
ghosts).” Elemental immunity edges use the manual's four elemental entries,
not a blanket assumption about neutral creatures.

## Literal source wording and disputed edge cases

The searchable reproduction of the 3DO manual at the [ManualMachine H2
manual](https://manualmachine.com/gamespc/heroesofmightandmagicii/1118154-user-manual/)
places both Dwarf and Battle Dwarf on printed p.81 and prints “25% Magic
resistance” for each entry. That is useful primary manual evidence, but it is
not enough to erase the known manual-versus-engine discrepancy flagged in the
coordinating review: the unresolved candidate is **Dwarf 25% and Battle Dwarf
40%** rather than the repeated 25% wording. No authoritative original
executable extraction or reproducible battle test is available in this
checkout, so the patch adds only the Dwarf edge. The Battle Dwarf value is an
explicit unresolved candidate, not a verified omission or a silently assumed
25%.

The same manual's printed p.83 Phoenix entry says “Flies. Attack affects two
hexes. Immune to elemental spells.” The patch records only the elemental-spell
wording as an ability. It must not be read as immunity to every spell, as a
statement about Armageddon, or as proof that every engine/build implements the
manual phrase identically. Those interpretations remain unverified until
original game data or a reproducible retained-build test is available.

## Validation

A temporary in-memory merge of the patch into the current catalog passed the
repository validator:

```text
Valid HeroesWatch data bundle: 176 tables, 40,155 rows.
```

The current cumulative catalog remains unchanged. This overlay contributes 132
rows (45 `Ability` identities and 87 `CreatureAbility` edges) only when the
coordinating task explicitly merges it.

## Remaining boundary

This pass does not claim that every undocumented H1/H2 combat behavior has
been recovered. It excludes mechanics that appear only in secondary strategy
guides or fan tables, unnamed engine flags, parameter values not printed by
the primary manual, and the ordinary attack/retaliation rules shared by all
creatures. Those facts require a retained original-game data extraction or a
separately approved source-backed schema extension.
