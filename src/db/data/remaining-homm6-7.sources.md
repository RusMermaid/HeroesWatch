# Remaining Heroes VI and VII catalog data

Research date: 2026-09-30. The import fragment is
`research/remaining-homm6-7.json`. It adds missing rows and references existing
release, faction, class, hero, racial-skill, building, and resource keys. It
does not replace existing records or allocate physical database IDs.

## Sources

### Creatures and recruitment

- [Heroes VI creature roster](https://mightandmagic.fandom.com/wiki/Heroes_VI_creatures)
  and its recursively enumerated faction, neutral, and boss categories supply
  109 named identities. Individual creature articles supply the numerical
  infobox fields and dwelling names.
- [Heroes VII creature roster](https://mightandmagic.fandom.com/wiki/Heroes_VII_creatures)
  and its faction, neutral, warfare, and Trial by Fire categories supply 156
  identities. Individual articles supply stats, tier, costs, and recruitment
  buildings. The displayed primary values of tooltip cells are used; their
  explicitly different campaign/scenario values are not combined with them.
- Creature-upgrade edges come from matching base/upgraded positions in the
  roster templates. Building recruitment links use exact faction and building
  names already present in the cumulative catalog. Resource costs are separate
  `CreatureResourceCost` rows, including the three additional VII resources.
- [Heroes VI manual 0.921](https://www.scribd.com/document/88970592/Mmh6-Manual-Eng-0-921),
  printed pp. 243–245, documents the distinction between defense points and
  resistance percentages. The wiki commonly prints resistance percentages.
  Those percentages are **not** stored directly as defense points. A raw
  integer defense is derived only if exactly one integer satisfies
  `round(100 * (1 - (1 + defense / 100)^(-2.5))) = displayed percentage`.
  Ambiguous values cause the optional creature detail to be omitted.
- The [VI unit comparison table](https://mightandmagicheroesvi.fandom.com/wiki/Unit_Comparison_Table)
  corroborates the explicitly unitless Ghost/Ghoul defense fields, Skeletal
  Spearman ground movement, and Dire Wolf luck. Its older balance numbers are
  otherwise not substituted into later infobox stat blocks.
- The [Scorpicore article](https://mightandmagic.fandom.com/wiki/Scorpicore_(H6))
  establishes flying melee movement for Manticores and Scorpicores.
- [Dynasty weapons](https://mightandmagic.fandom.com/wiki/Dynasty_Weapon)
  establish that the VI Spectral Dragon is a summoned creature. Its generic
  record is not classified as a recruitable town creature.

`CombatSize` records occupied squares: small is 1 and large is 4. VI
`BasicGrowth` and `UpgradeGrowth` hold the reported weekly growth of the base
or upgraded creature respectively; the other field remains null. VI magical
ranged creatures with distinct melee/ranged damage use the source's magic
damage range. These references are not a single patch-pinned game-file dump;
balance differences between editions remain possible.

### Skills, schools, abilities, and spells

- [VI progression overview](https://mightandmagic.fandom.com/wiki/Might_%26_Magic:_Heroes_VI_abilities)
  establishes that VI uses ability trees in place of traditional skills. The
  schema consequently has no `SkillHOMM6`. The five Might branches and seven
  magic branches are represented through their discrete `Ability` /
  `AbilityHOMM6` nodes; empty generic Skill placeholders are not added.
- The VI school pages for
  [Air](https://mightandmagic.fandom.com/wiki/Air_Magic_(H6)),
  [Dark](https://mightandmagic.fandom.com/wiki/Dark_Magic_(H6)),
  [Earth](https://mightandmagic.fandom.com/wiki/Earth_Magic_(H6)),
  [Fire](https://mightandmagic.fandom.com/wiki/Fire_Magic_(H6)),
  [Light](https://mightandmagic.fandom.com/wiki/Light_Magic_(H6)),
  [Prime](https://mightandmagic.fandom.com/wiki/Prime_Magic_(H6)), and
  [Water](https://mightandmagic.fandom.com/wiki/Water_Magic_(H6)), plus Paragon,
  Realm, Tactics, Warcries, and Warfare, supply tier, reputation, active/passive
  type, cooldown, and mana cost. Active magic nodes have Spell identities and
  `SpellHOMM6.Ability_id` links. Explicitly listed faction availability becomes
  `FactionSpell`; no occurrence chance is invented.
- The existing [VI class roster](https://mightandmagic.fandom.com/wiki/Category:Heroes_VI_classes)
  and its individual class ability tables supply neutral and reputation
  abilities, linked through `HeroClassAbility`. Active abilities of Magic
  classes also have spell identities. Repeated heroic-strike names share one
  ability identity. Class stat rows are not changed.
- [VI town portals](https://www.gamepressure.com/mightandmagicheroesvi/portals/zc313e)
  supply the two special adventure spells, with mana and movement costs.
- [VII skill roster](https://mightandmagic.fandom.com/wiki/Category:Heroes_VII_skills)
  supplies all 24 skills: 17 missing ordinary/magic skills plus the seven
  existing faction skills. Perk names and minimum mastery come from each
  skill's ability table. Class access comes from the class lists above those
  tables. A class-to-perk row is added only when its documented maximum
  mastery reaches the perk's minimum mastery. Existing racial skill keys are
  reused, including `homm7.skill.natures.revenge`.
- [VII spell index](https://mightandmagic.fandom.com/wiki/Category:Heroes_VII_spells)
  supplies seven school tables and their 64 spells, including Trial by Fire
  entries marked with the expansion icon. Numeric mastery formulas are kept
  in `EffectByMastery`; source biographies and flavor paragraphs are not
  reproduced. Adventure spells are distinguished from combat spells by their
  documented targets and use.
- [Warcries](https://mightandmagic.fandom.com/wiki/Warcries_(H7)) supplies Advance!,
  Hold Positions!, Open Fire!, Engage!, and Attention!, with their learning
  tiers. These have `SpellKind = Warcry` and no fabricated school assignment.
- The [released Haven campaign walkthrough](https://www.gamepressure.com/mightandmagicheroes7/a-feast-for-the-gods-m12/z1803f)
  documents Reveal Treasure. Its generic identity is included; its required
  numerical spell-circle level is not established, so no detail row is added.

### Artifacts

- [HeroesWorld VI artifacts](https://heroesworld.net/kb/artifact/heroes-6/)
  and [VII artifacts](https://heroesworld.net/kb/artifact/heroes-7/), including
  every pagination page, supply names, slots, rarity, and set membership.
  Per-entry pages identify their provenance as in-game screens. Numeric
  bonuses are extracted where they are unambiguous. Set overview pages are
  not imported as equippable artifacts.
- [VI artifact tables](https://mightandmagic.fandom.com/wiki/List_of_Heroes_VI_artifacts)
  add the documented spell scrolls and 22 campaign quest items.
- [VI dynasty weapon tables](https://mightandmagic.fandom.com/wiki/Dynasty_Weapon)
  add 32 weapons with their five-level progression and experience thresholds.
  Only numerical level bonuses are transcribed; their lengthy stories are
  excluded.
- [VII artifact tables](https://mightandmagic.fandom.com/wiki/List_of_Heroes_VII_artifacts)
  add Shards of Fire; [Tear of Asha](https://mightandmagic.fandom.com/wiki/Tear_of_Asha)
  and Ubisoft's [editor manual](https://ubistatic-a.akamaihd.net/0004/prod/images/160407_LT1_Modding/EditorManual.pdf)
  establish the ultimate artifact and mana-potion identity.

The ordinary artifact references generally do not identify an introduction
release. Their nullable expansion FK stays null. Explicit expansion markers
and campaign introductions are used where available. VII same-name items
with different rarity retain separate stable keys. The existing VII detail
enum has no Scroll or Potion member, and neither VI nor VII has a Quest
rarity member. Those catalog identities remain without incompatible detail
rows; they are not assigned a made-up supported rarity.

### Campaigns and world objects

- [VI campaign navigation](https://mightandmagic.fandom.com/wiki/Template:H6scen)
  and individual campaign pages supply all 11 campaign collections: tutorial,
  five faction campaigns, the final reputation endings, Pirates of the Savage
  Sea, Danse Macabre, and the two Shades of Darkness campaigns.
- [VII campaign navigation](https://mightandmagic.fandom.com/wiki/Template:H7scen)
  and individual campaign pages supply all 11 collections: seven base
  campaigns, both Lost Tales of Axeoth campaigns, and both Trial by Fire
  campaigns. Scenario counts are recorded without mistaking missions for
  separate campaigns. Named protagonists are connected to existing Hero
  records with `CampaignHero`.
- [VI adventure structures](https://mightandmagic.fandom.com/wiki/List_of_adventure_map_structures_in_Heroes_VI)
  supplies 77 additional named structures, after excluding the faction
  dwellings and forts already present. Neutral recruitment sites, creature
  banks, mines, travel structures, services, treasures, and campaign objects
  retain separate catalog identities.
- The contemporaneous VII world-object reference gives exact English labels
  and map-editor defaults in seven sections:
  [resources](https://www.gamersky.com/handbook/201511/683461.shtml),
  [treasure sites](https://www.gamersky.com/handbook/201511/683461_2.shtml),
  [recruitment and control](https://www.gamersky.com/handbook/201511/683461_3.shtml),
  [hero improvements](https://www.gamersky.com/handbook/201511/683461_4.shtml),
  [travel](https://www.gamersky.com/handbook/201511/683461_5.shtml),
  [services](https://www.gamersky.com/handbook/201511/683461_6.shtml), and
  [campaign objects](https://www.gamersky.com/handbook/201511/683461_7.shtml).
  It is dated 2015-11-14 and credits EvilP / HeroesWorld. Full-build town
  renderings are not separate object identities. The 18 base-faction dwelling
  labels already present are reused. Numeric editor defaults describe the
  template and can be overridden by a map author.
- [Runic Forge discussion](https://steamcommunity.com/app/445310/discussions/0/2132869574255510412/)
  and the [Trial by Fire walkthrough](https://www.celestialheavens.com/mmh7-trial-by-fire-campaign-walkthrough)
  establish the expansion's artifact-forging map object and its four-piece
  same-set input rule.

## Limits and preservation

- Existing generic rows, class details, hero records, faction dwellings, and
  other contributions are preserved. The six VI fort names already contain
  unwanted image-filename text; this fragment deliberately avoids creating
  duplicate forts or replacing their stable keys. Correct labels are Dungeon
  Fort, Haven Fort, Inferno Fort, Necropolis Fort, Sanctuary Fort, and
  Stronghold Fort.
- Six Dungeon class details in VI and nine class details in VII remain
  unresolved. No required initial attributes or growth percentages were
  fabricated to create those rows.
- VI Storm Arrows Scroll is described as Storm Winds I by the source table.
  Its spell FK remains null until that contradiction is resolved.
- Several VI boss and special-creature stat blocks are incomplete. VII
  warfare articles often publish arrays of values by warfare rank and omit
  movement or footprint. The scalar creature detail schema cannot safely
  represent such rows by simply taking an arbitrary array element.
- Indexed rosters cover the source catalogs and official expansion entries;
  this research is not an exhaustive audit of every shipped campaign script,
  hidden editor preset, unused asset, or patch revision. Expansion-specific
  map-object additions beyond the documented Runic Forge are not asserted.
- No tests, validator run, database writes, application launch, or publication
  were performed by this research task. The user requested no verification
  pass. Integration and delivery belong to the coordinating task.

<!-- Generated coverage and unresolved field list follow. -->

## Added row counts

| Table | Rows |
|---|---:|
| Creature | 265 |
| CreatureHOMM6 | 89 |
| BuildingCreature | 189 |
| CreatureResourceCost | 252 |
| CreatureUpgrade | 96 |
| CreatureHOMM7 | 136 |
| Resource | 3 |
| GameResource | 11 |
| MagicSchool | 14 |
| MagicSchoolHOMM6 | 7 |
| MagicSchoolHOMM7 | 7 |
| Ability | 406 |
| AbilityHOMM6 | 238 |
| Spell | 159 |
| SpellHOMM6 | 89 |
| SpellMagicSchool | 131 |
| FactionSpell | 237 |
| Skill | 17 |
| SkillHOMM7 | 17 |
| AbilityHOMM7 | 168 |
| HeroClassAbility | 2561 |
| SpellHOMM7 | 69 |
| Artifact | 448 |
| ArtifactHOMM6 | 203 |
| ArtifactHOMM7 | 164 |
| Campaign | 22 |
| CampaignHero | 25 |
| AdventureObject | 197 |
| AdventureObjectHOMM6 | 77 |
| AdventureObjectHOMM7 | 120 |

Total: **6417 new rows**.

## Creature details awaiting required fields

- CreatureHOMM6 homm6.creature.abyssal.worm: detail omitted; unresolved AttackType, MightDefense, MagicDefense, Speed, Initiative, Luck, Movement.
- CreatureHOMM6 homm6.creature.ahribban: detail omitted; unresolved AttackType, MightDefense, MagicDefense, Movement.
- CreatureHOMM6 homm6.creature.avatar.of.the.void: detail omitted; unresolved AttackType, MightDefense, MagicDefense, CombatSize, Movement.
- CreatureHOMM6 homm6.creature.azkaal: detail omitted; unresolved AttackType, MightDefense, MagicDefense, Movement.
- CreatureHOMM6 homm6.creature.breeder.queen: detail omitted; unresolved AttackType, MightDefense, MagicDefense, Movement.
- CreatureHOMM6 homm6.creature.daughter.of.malassa: detail omitted; unresolved AttackType, MightDefense, MagicDefense, Movement.
- CreatureHOMM6 homm6.creature.dragonwraith: detail omitted; unresolved AttackType, MightDefense, Health, CombatSize, Movement.
- CreatureHOMM6 homm6.creature.enraged.kirin: detail omitted; unresolved AttackType, CombatSize, Movement.
- CreatureHOMM6 homm6.creature.hai.ryou: detail omitted; unresolved AttackType, Movement.
- CreatureHOMM6 homm6.creature.michael: detail omitted; unresolved AttackType, DamageMin, DamageMax, MightDefense, MagicDefense, Health, Speed, Initiative, CombatSize, Range, Luck, Movement.
- CreatureHOMM6 homm6.creature.mother.namtaru: detail omitted; unresolved AttackType, CombatSize, Movement.
- CreatureHOMM6 homm6.creature.thunderbird: detail omitted; unresolved AttackType, MightDefense, MagicDefense, CombatSize, Movement.
- CreatureHOMM6 homm6.creature.uriel: detail omitted; unresolved AttackType, MightDefense, MagicDefense, Range, Movement.
- CreatureHOMM6 homm6.creature.shadow.lurker: detail omitted; unresolved MagicDefense, Movement.
- CreatureHOMM6 homm6.creature.shadow.watcher: detail omitted; unresolved MagicDefense, Movement.
- CreatureHOMM6 homm6.creature.radiant.glory: detail omitted; unresolved MightDefense, MagicDefense.
- CreatureHOMM6 homm6.creature.seraph: detail omitted; unresolved MightDefense.
- CreatureHOMM6 homm6.creature.sun.crusader: detail omitted; unresolved MightDefense, MagicDefense.
- CreatureHOMM6 homm6.creature.spectral.dragon: detail omitted; unresolved Range, Movement.
- CreatureHOMM6 homm6.creature.shark.guard: detail omitted; unresolved MightDefense.
- CreatureHOMM7 homm7.creature.great.pyramid: detail omitted; unresolved Defense, DamageMin, DamageMax, Health, Speed, CombatSize, Movement.
- CreatureHOMM7 homm7.creature.healing.tent: detail omitted; unresolved Defense, DamageMin, DamageMax, Health, Speed, Movement.
- CreatureHOMM7 homm7.creature.small.pyramid: detail omitted; unresolved Attack, Defense, DamageMin, DamageMax, Health, Speed, CombatSize, Movement.
- CreatureHOMM7 homm7.creature.cave.wyvern: detail omitted; unresolved Defense, DamageMin, DamageMax, Health, Speed, CombatSize, Movement.
- CreatureHOMM7 homm7.creature.faceless: detail omitted; unresolved Defense, DamageMin, DamageMax, Health, Speed, CombatSize, Movement.
- CreatureHOMM7 homm7.creature.shadow.lurker: detail omitted; unresolved Attack, Defense, DamageMin, DamageMax, Health, Speed, CombatSize, Movement.
- CreatureHOMM7 homm7.creature.ballista: detail omitted; unresolved Attack, Defense, DamageMin, DamageMax, Health, Speed, CombatSize, Movement.
- CreatureHOMM7 homm7.creature.catapult: detail omitted; unresolved Defense, DamageMin, DamageMax, Health, Speed, CombatSize, Movement.
- CreatureHOMM7 homm7.creature.healing.sister: detail omitted; unresolved Defense, DamageMin, DamageMax, Health, Speed, CombatSize, Movement.
- CreatureHOMM7 homm7.creature.namtaru: detail omitted; unresolved Attack, Defense, DamageMin, DamageMax, Health, Speed, Movement.
- CreatureHOMM7 homm7.creature.spitting.spider: detail omitted; unresolved Defense, DamageMin, DamageMax, Health, Speed, Movement.
- CreatureHOMM7 homm7.creature.kraken: detail omitted; unresolved Attack, Defense, DamageMin, DamageMax, Health, Speed, Initiative, CombatSize, Movement.
- CreatureHOMM7 homm7.creature.dreamwalker: detail omitted; unresolved Attack, Defense, DamageMin, DamageMax, Health, Speed, CombatSize, Movement.
- CreatureHOMM7 homm7.creature.tamed.cyclops: detail omitted; unresolved Defense, DamageMin, DamageMax, Health, Speed, CombatSize, Movement.
- CreatureHOMM7 homm7.creature.greater.earth.elemental: detail omitted; unresolved Defense, DamageMin, DamageMax, Health, Speed, Movement.
- CreatureHOMM7 homm7.creature.mother.treant: detail omitted; unresolved Defense, DamageMin, DamageMax, Health, Speed, Movement.
- CreatureHOMM7 homm7.creature.sylvan.ballista: detail omitted; unresolved Attack, Defense, DamageMin, DamageMax, Health, Speed, Movement.
- CreatureHOMM7 homm7.creature.dwarven.ballista: detail omitted; unresolved Attack, Defense, DamageMin, DamageMax, Health, Speed, CombatSize, Movement.
- CreatureHOMM7 homm7.creature.fire.cannon: detail omitted; unresolved Defense, DamageMin, DamageMax, Health, Speed, CombatSize, Movement.
- CreatureHOMM7 homm7.creature.runestone: detail omitted; unresolved Defense, DamageMin, DamageMax, Health, Speed, CombatSize, Movement.
