# Heroes VI and VII detail follow-up

Reviewed 2026-10-04. This pass adds **27 detail rows**: four Heroes VI creatures,
the Heroes VII Kraken and 22 Heroes VII Hall heroes. It replaces no existing
non-null value and keeps the schema's required fields intact.

## Creature additions

The earlier VI import intentionally rejected ambiguous defense values. Raw
defense points and displayed resistance percentages are different quantities.
This pass uses explicit raw-point references for four previously omitted rows:

| Creature | Might defense | Magic defense | Evidence |
|---|---:|---:|---|
| Radiant Glory | 12 | 14 | [Raw/percentage table](https://www.might-and-magic.ru/articles/_/heroes6/creatures/h6_haven_units), [unit comparison](https://mightandmagicheroesvi.fandom.com/wiki/Unit_Comparison_Table) and [current article](https://mightandmagic.fandom.com/wiki/Radiant_glory_(H6)) |
| Seraph | 37 | 29 | [Explicit point table](https://mightandmagicheroesvi.fandom.com/wiki/Unit_Comparison_Table), corroborating the [article's](https://mightandmagic.fandom.com/wiki/Seraph_(H6)) 54%/47% resistance |
| Sun Crusader | 22 | 11 | [Patch 1.5 notes](https://www.moddb.com/games/heroes-vi/downloads/patch-1-4-to-1-5-1) and [explicit raw/percentage reference](https://mightandmagic.fandom.com/ru/wiki/Крестоносец_Солнца) |
| Shark Guard | 4 | 2 | [Patch 1.5 notes](https://www.gry-online.pl/download/might-magic-heroes-vi-v15-eng-patch/z39c43) explicitly lower both defenses |

Radiant Glory keeps the later 70 HP and 7 morale, matching the patch notes;
the older table's 65 HP and 9 morale are not copied. Seraph's patch entry leaves
its characteristics unchanged. Sun Crusader's English article prints 39 and 23
without units; the corroborating reference identifies them as percentages.

Shark Guard's English article prints 6% might resistance, which conflicts with
the explicit patch value of four defense points. The patch value is used for
the new row. No previous scalar defense value existed to overwrite. These
references support the stated profiles; they are not a fresh game-file dump of
every later patch.

The [Kraken article](https://mightandmagic.fandom.com/wiki/Kraken_(H7)) already
contained all required statistics. The former extraction expected the infobox
closing braces on a separate line, while this page closes after `size=Large`.
The new row uses the main profile: attack/defense 30/30, 650 HP, damage 70–90,
initiative 15, speed 5, ground movement and four occupied squares. The tooltip's
campaign/scenario alternatives remain separate from this profile.

## Hall hero eligibility

The official [Ubisoft editor manual](https://ubistatic-a.akamaihd.net/0004/prod/images/160407_LT1_Modding/EditorManual.pdf),
PDF page 64, was rendered and inspected. Its Hall of Heroes list contains:

- Academy: Aali, Asad, Gloria, Johari, Masfar, Minasli, Mirym, Saabira,
  Theodorus and Yasir.
- Dungeon: Ashbeth, Darkstorm, Eruina, Lethos, Sinitar, Sorshan, Sylsai,
  Yeshtar, Yrbeth and Yrris.
- Haven: Amilcar and Edric.

For these 22 existing identities, `HeroHOMM7.IsHallHero = true` means the hero
can appear in the Hall selection list. The manual explicitly makes enabling a
hero a per-map, per-player choice. `Availability` therefore remains null;
the unchecked Lethos example does not establish a universal exclusion. The
screenshot's `Myrim` label maps to the existing Academy Enchanter `Mirym`,
preserving that row's name and stable key. Other hero details remain null.

## Remaining gaps

**16 VI creatures, 19 VII creatures and 15 class details still lack a supported
complete row.** The other 110 VII heroes do not yet have documented Hall flags.
The following tables list the required fields preventing insertion.

All 19 remaining VII creatures are warfare units. Their source records contain
stat vectors that vary with progression. Several lack an occupied-square size;
their speed or movement type is also missing. A stationary warfare unit cannot
be assigned `Ground`, `Flying` or `Teleporting` from its appearance alone.
The [Dungeon warfare reference](https://www.heroes-centrum.com/h7/kobka-jednotky)
provides some baseline values and zero speed, but does not establish all required
fields or a complete rank model. These rows are not filled with invented zeros.

The [Shadow Lurker/Watcher game screenshots](https://www.gamepressure.com/mightandmagicheroesvishadesofdarkness/shadow-lurker-shadow-watcher/z24ea8)
show 22% magic resistance, which does not identify an integer raw defense under
the existing documented conversion. Their movement type is also unconfirmed.
Michael's inline-closing creature template now yields damage, HP, speed,
initiative, size, range and luck, but still leaves required fields unresolved.

The six VI Dungeon classes have known faction and reputation associations, but
their initial six attributes remain unverified. For VII, a [community growth
table](https://www.reddit.com/r/HoMM/comments/10afobg) supplies candidate numbers
for eight missing classes. Its discussion involves the Unofficial Community
Patch and does not establish unmodified game-file provenance. Archon/Embalmer
focus labels also disagree between article text and category/skill information.
The candidates are withheld; Hell Knight is absent from that table entirely.

### Missing creature fields

| Record | Required fields still unresolved |
|---|---|
| [homm6.creature.abyssal.worm](https://mightandmagic.fandom.com/wiki/Abyssal_worm_(H6)) | AttackType, MightDefense, MagicDefense, Speed, Initiative, Luck, Movement |
| [homm6.creature.ahribban](https://mightandmagic.fandom.com/wiki/Ahribban) | AttackType, MightDefense, MagicDefense, Movement |
| [homm6.creature.avatar.of.the.void](https://mightandmagic.fandom.com/wiki/Avatar_of_the_Void) | AttackType, MightDefense, MagicDefense, CombatSize, Movement |
| [homm6.creature.azkaal](https://mightandmagic.fandom.com/wiki/Azkaal) | AttackType, MightDefense, MagicDefense, Movement |
| [homm6.creature.breeder.queen](https://mightandmagic.fandom.com/wiki/Breeder_Queen) | AttackType, MightDefense, MagicDefense, Movement |
| [homm6.creature.daughter.of.malassa](https://mightandmagic.fandom.com/wiki/Daughter_of_Malassa) | AttackType, MightDefense, MagicDefense, Movement |
| [homm6.creature.dragonwraith](https://mightandmagic.fandom.com/wiki/Dragonwraith) | AttackType, MightDefense, Health, CombatSize, Movement |
| [homm6.creature.enraged.kirin](https://mightandmagic.fandom.com/wiki/Enraged_Kirin) | AttackType, CombatSize, Movement |
| [homm6.creature.hai.ryou](https://mightandmagic.fandom.com/wiki/Hai_Ryou) | AttackType, Movement |
| [homm6.creature.michael](https://mightandmagic.fandom.com/wiki/Michael_(H6)) | AttackType, MightDefense, MagicDefense, Movement |
| [homm6.creature.mother.namtaru](https://mightandmagic.fandom.com/wiki/Mother_Namtaru) | AttackType, CombatSize, Movement |
| [homm6.creature.thunderbird](https://mightandmagic.fandom.com/wiki/Thunderbird_(H6)) | AttackType, MightDefense, MagicDefense, CombatSize, Movement |
| [homm6.creature.uriel](https://mightandmagic.fandom.com/wiki/Uriel) | AttackType, MightDefense, MagicDefense, Range, Movement |
| [homm6.creature.shadow.lurker](https://mightandmagic.fandom.com/wiki/Shadow_lurker_(H6)) | MagicDefense, Movement |
| [homm6.creature.shadow.watcher](https://mightandmagic.fandom.com/wiki/Shadow_watcher_(H6)) | MagicDefense, Movement |
| [homm6.creature.spectral.dragon](https://mightandmagic.fandom.com/wiki/Spectral_dragon_(H6)) | Range, Movement |
| [homm7.creature.great.pyramid](https://mightandmagic.fandom.com/wiki/Great_pyramid) | Defense, DamageMin, DamageMax, Health, Speed, CombatSize, Movement |
| [homm7.creature.healing.tent](https://mightandmagic.fandom.com/wiki/Healing_tent) | Defense, DamageMin, DamageMax, Health, Speed, Movement |
| [homm7.creature.small.pyramid](https://mightandmagic.fandom.com/wiki/Small_pyramid) | Attack, Defense, DamageMin, DamageMax, Health, Speed, CombatSize, Movement |
| [homm7.creature.cave.wyvern](https://mightandmagic.fandom.com/wiki/Cave_wyvern) | Defense, DamageMin, DamageMax, Health, Speed, CombatSize, Movement |
| [homm7.creature.faceless](https://mightandmagic.fandom.com/wiki/Faceless_(H7)) | Defense, DamageMin, DamageMax, Health, Speed, CombatSize, Movement |
| [homm7.creature.shadow.lurker](https://mightandmagic.fandom.com/wiki/Shadow_lurker_(H7)) | Attack, Defense, DamageMin, DamageMax, Health, Speed, CombatSize, Movement |
| [homm7.creature.ballista](https://mightandmagic.fandom.com/wiki/Ballista_(H7)) | Attack, Defense, DamageMin, DamageMax, Health, Speed, CombatSize, Movement |
| [homm7.creature.catapult](https://mightandmagic.fandom.com/wiki/Catapult_(H7)) | Defense, DamageMin, DamageMax, Health, Speed, CombatSize, Movement |
| [homm7.creature.healing.sister](https://mightandmagic.fandom.com/wiki/Healing_sister_(H7)) | Defense, DamageMin, DamageMax, Health, Speed, CombatSize, Movement |
| [homm7.creature.namtaru](https://mightandmagic.fandom.com/wiki/Namtaru_(H7)) | Attack, Defense, DamageMin, DamageMax, Health, Speed, Movement |
| [homm7.creature.spitting.spider](https://mightandmagic.fandom.com/wiki/Spitting_spider) | Defense, DamageMin, DamageMax, Health, Speed, Movement |
| [homm7.creature.dreamwalker](https://mightandmagic.fandom.com/wiki/Dreamwalker_(H7)) | Attack, Defense, DamageMin, DamageMax, Health, Speed, CombatSize, Movement |
| [homm7.creature.tamed.cyclops](https://mightandmagic.fandom.com/wiki/Tamed_cyclops) | Defense, DamageMin, DamageMax, Health, Speed, CombatSize, Movement |
| [homm7.creature.greater.earth.elemental](https://mightandmagic.fandom.com/wiki/Greater_earth_elemental_(H7)) | Defense, DamageMin, DamageMax, Health, Speed, Movement |
| [homm7.creature.mother.treant](https://mightandmagic.fandom.com/wiki/Mother_treant_(H7)) | Defense, DamageMin, DamageMax, Health, Speed, Movement |
| [homm7.creature.sylvan.ballista](https://mightandmagic.fandom.com/wiki/Sylvan_ballista) | Attack, Defense, DamageMin, DamageMax, Health, Speed, Movement |
| [homm7.creature.dwarven.ballista](https://mightandmagic.fandom.com/wiki/Dwarven_ballista) | Attack, Defense, DamageMin, DamageMax, Health, Speed, CombatSize, Movement |
| [homm7.creature.fire.cannon](https://mightandmagic.fandom.com/wiki/Fire_cannon) | Defense, DamageMin, DamageMax, Health, Speed, CombatSize, Movement |
| [homm7.creature.runestone](https://mightandmagic.fandom.com/wiki/Runestone) | Defense, DamageMin, DamageMax, Health, Speed, CombatSize, Movement |

### Missing class fields

| Record | Required fields still unresolved |
|---|---|
| [homm6.heroclass.dark.prophet](https://mightandmagic.fandom.com/wiki/Dark_Prophet_(H6)) | DefaultMightPower, DefaultMightDefense, DefaultMagicPower, DefaultMagicDefense, DefaultLeadership, DefaultDestiny |
| [homm6.heroclass.darkblade](https://mightandmagic.fandom.com/wiki/Darkblade_(H6)) | DefaultMightPower, DefaultMightDefense, DefaultMagicPower, DefaultMagicDefense, DefaultLeadership, DefaultDestiny |
| [homm6.heroclass.shadow.slayer](https://mightandmagic.fandom.com/wiki/Shadow_Slayer_(H6)) | DefaultMightPower, DefaultMightDefense, DefaultMagicPower, DefaultMagicDefense, DefaultLeadership, DefaultDestiny |
| [homm6.heroclass.shadow.weaver](https://mightandmagic.fandom.com/wiki/Shadow_Weaver) | DefaultMightPower, DefaultMightDefense, DefaultMagicPower, DefaultMagicDefense, DefaultLeadership, DefaultDestiny |
| [homm6.heroclass.sorcerer](https://mightandmagic.fandom.com/wiki/Sorcerer_(H6)) | DefaultMightPower, DefaultMightDefense, DefaultMagicPower, DefaultMagicDefense, DefaultLeadership, DefaultDestiny |
| [homm6.heroclass.trickster](https://mightandmagic.fandom.com/wiki/Trickster_(H6)) | DefaultMightPower, DefaultMightDefense, DefaultMagicPower, DefaultMagicDefense, DefaultLeadership, DefaultDestiny |
| [homm7.heroclass.archon](https://mightandmagic.fandom.com/wiki/Archon) | MightGrowthPct, DefenseGrowthPct, MagicGrowthPct, SpiritGrowthPct |
| [homm7.heroclass.embalmer](https://mightandmagic.fandom.com/wiki/Embalmer_(H7)) | MightGrowthPct, DefenseGrowthPct, MagicGrowthPct, SpiritGrowthPct |
| [homm7.heroclass.engraver](https://mightandmagic.fandom.com/wiki/Engraver) | MightGrowthPct, DefenseGrowthPct, MagicGrowthPct, SpiritGrowthPct |
| [homm7.heroclass.firebrander](https://mightandmagic.fandom.com/wiki/Firebrander) | MightGrowthPct, DefenseGrowthPct, MagicGrowthPct, SpiritGrowthPct |
| [homm7.heroclass.hell.knight](https://mightandmagic.fandom.com/wiki/Hell_Knight) | MightGrowthPct, DefenseGrowthPct, MagicGrowthPct, SpiritGrowthPct |
| [homm7.heroclass.jarl](https://mightandmagic.fandom.com/wiki/Jarl_(H7)) | MightGrowthPct, DefenseGrowthPct, MagicGrowthPct, SpiritGrowthPct |
| [homm7.heroclass.runelord](https://mightandmagic.fandom.com/wiki/Runelord_(H7)) | MightGrowthPct, DefenseGrowthPct, MagicGrowthPct, SpiritGrowthPct |
| [homm7.heroclass.thane](https://mightandmagic.fandom.com/wiki/Thane_(H7)) | MightGrowthPct, DefenseGrowthPct, MagicGrowthPct, SpiritGrowthPct |
| [homm7.heroclass.warlord](https://mightandmagic.fandom.com/wiki/Warlord_(H7_class)) | MightGrowthPct, DefenseGrowthPct, MagicGrowthPct, SpiritGrowthPct |
