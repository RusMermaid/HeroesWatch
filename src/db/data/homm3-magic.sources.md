# Heroes III skills and magic research

Reviewed on 2026-09-29 for The Restoration of Erathia, Armageddon's Blade,
and The Shadow of Death / Complete. Horn of the Abyss and Wake of Gods
content and balance changes are excluded.

## Coverage

| Table | Rows | Coverage |
|---|---:|---|
| Skill | 32 | Four primary and all 28 original secondary skills |
| SkillHOMM3 | 28 | Basic, Advanced and Expert effects for secondary skills |
| MagicSchool | 4 | Air, Earth, Fire and Water |
| Spell | 70 | 69 RoE spells and Titan's Lightning Bolt from SoD |
| SpellHOMM3 | 70 | Levels, context, mana costs and all three mastery effects |
| SpellMagicSchool | 76 | One school per spell; Magic Arrow and Visions each have four |

Of the 70 spells, 60 are combat spells and ten are adventure spells.
Armageddon's Blade retains the RoE spell and skill catalogs; its creatures and
heroes can use those existing spells. Titan's Lightning Bolt is an actual
SoD spell granted by Titan's Thunder and is included with SoD provenance.
The disabled [Fear spell](https://heroes.thelazy.net/index.php/Fear_(spell))
and creature-only abilities are excluded from the learnable/artifact spell catalog.

The contributor file `research/homm3-magic.json` is a merge fragment, not a
standalone import bundle. Merge its table arrays into `heroeswatch.json` and
validate the complete bundle before database insertion. The reproducible,
offline generator is `../tools/research-homm3-magic.mjs`; it writes only the
fragment. It does not fetch new values or update reviewed records implicitly.

## Source method and interpretation

The [spell inventory](https://heroes.thelazy.net/index.php/List_of_spells),
[secondary skill inventory](https://heroes.thelazy.net/index.php/Secondary_skill),
and individual pages below were inspected through the wiki's MediaWiki API.
Descriptions in the data are concise paraphrases of game mechanics. Wiki
markup, image links, template names, unrelated mods, and commentary are not
imported. Every spell's level and both stored mana costs were compared with
its individual page. Schools were checked against the individual spell pages.

The wiki currently mixes HotA and original mechanics. The original branch of
`swh` templates was selected deliberately. In particular:

- Armageddon uses `50 * Spell Power`, Fire Wall uses `10 * Spell Power`, and
  Earth/Fire Elemental summoning uses multipliers 2/3/4.
- Protection spells reduce their school's damage by 30%/50%/50%. Advanced
  and Expert Slow leave 50% Speed, without HotA's additional point.
- Original Estates is 125/250/500 gold; Logistics is 10%/20%/30%; Necromancy is
  10%/20%/30%; Intelligence is 25%/50%/100%; Scouting is +1/+2/+3; Sorcery and
  Learning are 5%/10%/15%; Mysticism restores a total of 2/3/4 mana per day.
- Eagle Eye keeps its original post-victory 40%/50%/60% chance and level
  2/3/4 limits. First Aid restores 1-50/1-75/1-100 HP without a health bonus.
  Original war-machine skills do not grant HotA damage caps or Cannon control.
- [Forgetfulness](https://heroes.thelazy.net/index.php/Forgetfulness) follows
  original engine behavior: Advanced already affects all eligible enemy
  shooters, and all grades also reduce melee contribution. This differs from
  its in-game description and the corrected HotA behavior.
- [Curse](https://heroes.thelazy.net/index.php/Curse) uses minimum damage minus
  one at Advanced/Expert, with a floor of one. The manual's extra 80% multiplier
  is incorrect. Wisdom governs learning spells, not casting already known spells.
- [Teleport](https://heroes.thelazy.net/index.php/Teleport) permits crossing
  moats at Advanced, and walls at Expert. Its mana costs are 15/12/6/3.
- Berserk area wording is normalized to 1/7/19 hexes; the wiki's inclusive
  radius wording is ambiguous. The range definitions `0`, `0-1`, `0-2` in
  [VCMI's spell implementation](https://github.com/vcmi/vcmi/blob/develop/config/spells/timed.json)
  corroborate the geometry. VCMI is used only for this check, because it fixes
  some original bugs such as Advanced Forgetfulness.
- Slayer includes Firebirds/Phoenixes and the AB neutral dragons. Their
  eligibility is documented by the [King trait](https://heroes.thelazy.net/index.php/King).
  The per-spell page and King inventory are more precise than the summary list.

## Architecture mapping and limits

- Universal Skill, MagicSchool and Spell rows own identity. SkillHOMM3 and
  SpellHOMM3 reuse those keys; no generated SQL or schema file is edited.
- Primary skills have only universal Skill rows because the HOMM3 detail
  table describes secondary-skill mastery tiers. Their descriptions identify
  them explicitly; no Basic/Advanced/Expert primary tiers are invented.
- Schools are distinct from the four similarly named learnable skills.
  SpellMagicSchool contains actual FK relationships, including both spells
  that belong to all four schools.
- `ManaCost` means untrained mana cost; `ExpertManaCost` means Expert mana
  cost. Basic and Advanced normally share the discounted Expert value.
  Teleport's exceptional Basic/Advanced costs are preserved in its effect
  text because the schema has no separate columns for them.
- Most untrained effects match Basic. Dimension Door's untrained daily limit
  differs and is retained in the universal description.
- These are base effects for the original Complete rules. Specialties,
  artifacts, creature immunities, and map conditions can modify outcomes.
  Individual creature immunity links and faction mage-guild probabilities
  are separate relationships and are outside this skill/spell batch.
- The catalog is not a historical patch matrix. Documented original-game
  quirks are retained where they affect a listed mastery effect. Full numeric
  Ballistics hit tables, specialist formulas, and every interaction are not
  represented by the existing scalar effect fields.
- No unresolved required fields remain for these six tables. No source URL
  columns exist on them, so this sidecar supplies per-row source provenance.

## Individual source pages

| Import key | Source |
|---|---|
| `homm3.skill.air.magic` | [Air Magic](https://heroes.thelazy.net/index.php/Air_Magic) |
| `homm3.skill.archery` | [Archery](https://heroes.thelazy.net/index.php/Archery) |
| `homm3.skill.armorer` | [Armorer](https://heroes.thelazy.net/index.php/Armorer) |
| `homm3.skill.artillery` | [Artillery](https://heroes.thelazy.net/index.php/Artillery) |
| `homm3.skill.attack` | [Primary skill](https://heroes.thelazy.net/index.php/Primary_skill) |
| `homm3.skill.ballistics` | [Ballistics](https://heroes.thelazy.net/index.php/Ballistics) |
| `homm3.skill.defense` | [Primary skill](https://heroes.thelazy.net/index.php/Primary_skill) |
| `homm3.skill.diplomacy` | [Diplomacy](https://heroes.thelazy.net/index.php/Diplomacy) |
| `homm3.skill.eagle.eye` | [Eagle Eye](https://heroes.thelazy.net/index.php/Eagle_Eye) |
| `homm3.skill.earth.magic` | [Earth Magic](https://heroes.thelazy.net/index.php/Earth_Magic) |
| `homm3.skill.estates` | [Estates](https://heroes.thelazy.net/index.php/Estates) |
| `homm3.skill.fire.magic` | [Fire Magic](https://heroes.thelazy.net/index.php/Fire_Magic) |
| `homm3.skill.first.aid` | [First Aid](https://heroes.thelazy.net/index.php/First_Aid) |
| `homm3.skill.intelligence` | [Intelligence](https://heroes.thelazy.net/index.php/Intelligence) |
| `homm3.skill.knowledge` | [Primary skill](https://heroes.thelazy.net/index.php/Primary_skill) |
| `homm3.skill.leadership` | [Leadership](https://heroes.thelazy.net/index.php/Leadership) |
| `homm3.skill.learning` | [Learning](https://heroes.thelazy.net/index.php/Learning) |
| `homm3.skill.logistics` | [Logistics](https://heroes.thelazy.net/index.php/Logistics) |
| `homm3.skill.luck` | [Luck (secondary skill)](https://heroes.thelazy.net/index.php/Luck_(secondary_skill)) |
| `homm3.skill.mysticism` | [Mysticism](https://heroes.thelazy.net/index.php/Mysticism) |
| `homm3.skill.navigation` | [Navigation](https://heroes.thelazy.net/index.php/Navigation) |
| `homm3.skill.necromancy` | [Necromancy](https://heroes.thelazy.net/index.php/Necromancy) |
| `homm3.skill.offense` | [Offense](https://heroes.thelazy.net/index.php/Offense) |
| `homm3.skill.pathfinding` | [Pathfinding](https://heroes.thelazy.net/index.php/Pathfinding) |
| `homm3.skill.resistance` | [Resistance](https://heroes.thelazy.net/index.php/Resistance) |
| `homm3.skill.scholar` | [Scholar](https://heroes.thelazy.net/index.php/Scholar) |
| `homm3.skill.scouting` | [Scouting](https://heroes.thelazy.net/index.php/Scouting) |
| `homm3.skill.sorcery` | [Sorcery](https://heroes.thelazy.net/index.php/Sorcery) |
| `homm3.skill.spell.power` | [Primary skill](https://heroes.thelazy.net/index.php/Primary_skill) |
| `homm3.skill.tactics` | [Tactics](https://heroes.thelazy.net/index.php/Tactics) |
| `homm3.skill.water.magic` | [Water Magic](https://heroes.thelazy.net/index.php/Water_Magic) |
| `homm3.skill.wisdom` | [Wisdom](https://heroes.thelazy.net/index.php/Wisdom) |
| `homm3.magic-school.air` | [School of Air Magic](https://heroes.thelazy.net/index.php/School_of_Air_Magic) |
| `homm3.magic-school.earth` | [School of Earth Magic](https://heroes.thelazy.net/index.php/School_of_Earth_Magic) |
| `homm3.magic-school.fire` | [School of Fire Magic](https://heroes.thelazy.net/index.php/School_of_Fire_Magic) |
| `homm3.magic-school.water` | [School of Water Magic](https://heroes.thelazy.net/index.php/School_of_Water_Magic) |
| `homm3.spell.air.shield` | [Air Shield](https://heroes.thelazy.net/index.php/Air_Shield) |
| `homm3.spell.animate.dead` | [Animate Dead](https://heroes.thelazy.net/index.php/Animate_Dead) |
| `homm3.spell.anti.magic` | [Anti-Magic](https://heroes.thelazy.net/index.php/Anti-Magic) |
| `homm3.spell.armageddon` | [Armageddon](https://heroes.thelazy.net/index.php/Armageddon) |
| `homm3.spell.berserk` | [Berserk](https://heroes.thelazy.net/index.php/Berserk) |
| `homm3.spell.bless` | [Bless](https://heroes.thelazy.net/index.php/Bless) |
| `homm3.spell.blind` | [Blind](https://heroes.thelazy.net/index.php/Blind) |
| `homm3.spell.bloodlust` | [Bloodlust](https://heroes.thelazy.net/index.php/Bloodlust) |
| `homm3.spell.chain.lightning` | [Chain Lightning](https://heroes.thelazy.net/index.php/Chain_Lightning) |
| `homm3.spell.clone` | [Clone](https://heroes.thelazy.net/index.php/Clone) |
| `homm3.spell.counterstrike` | [Counterstrike](https://heroes.thelazy.net/index.php/Counterstrike) |
| `homm3.spell.cure` | [Cure](https://heroes.thelazy.net/index.php/Cure) |
| `homm3.spell.curse` | [Curse](https://heroes.thelazy.net/index.php/Curse) |
| `homm3.spell.death.ripple` | [Death Ripple](https://heroes.thelazy.net/index.php/Death_Ripple) |
| `homm3.spell.destroy.undead` | [Destroy Undead](https://heroes.thelazy.net/index.php/Destroy_Undead) |
| `homm3.spell.dimension.door` | [Dimension Door](https://heroes.thelazy.net/index.php/Dimension_Door) |
| `homm3.spell.disguise` | [Disguise](https://heroes.thelazy.net/index.php/Disguise) |
| `homm3.spell.dispel` | [Dispel](https://heroes.thelazy.net/index.php/Dispel) |
| `homm3.spell.disrupting.ray` | [Disrupting Ray](https://heroes.thelazy.net/index.php/Disrupting_Ray) |
| `homm3.spell.earthquake` | [Earthquake](https://heroes.thelazy.net/index.php/Earthquake) |
| `homm3.spell.fire.shield` | [Fire Shield](https://heroes.thelazy.net/index.php/Fire_Shield) |
| `homm3.spell.fire.wall` | [Fire Wall](https://heroes.thelazy.net/index.php/Fire_Wall) |
| `homm3.spell.fireball` | [Fireball](https://heroes.thelazy.net/index.php/Fireball) |
| `homm3.spell.fly` | [Fly](https://heroes.thelazy.net/index.php/Fly) |
| `homm3.spell.force.field` | [Force Field](https://heroes.thelazy.net/index.php/Force_Field) |
| `homm3.spell.forgetfulness` | [Forgetfulness](https://heroes.thelazy.net/index.php/Forgetfulness) |
| `homm3.spell.fortune` | [Fortune](https://heroes.thelazy.net/index.php/Fortune) |
| `homm3.spell.frenzy` | [Frenzy](https://heroes.thelazy.net/index.php/Frenzy) |
| `homm3.spell.frost.ring` | [Frost Ring](https://heroes.thelazy.net/index.php/Frost_Ring) |
| `homm3.spell.haste` | [Haste](https://heroes.thelazy.net/index.php/Haste) |
| `homm3.spell.hypnotize` | [Hypnotize](https://heroes.thelazy.net/index.php/Hypnotize) |
| `homm3.spell.ice.bolt` | [Ice Bolt](https://heroes.thelazy.net/index.php/Ice_Bolt) |
| `homm3.spell.implosion` | [Implosion](https://heroes.thelazy.net/index.php/Implosion) |
| `homm3.spell.inferno` | [Inferno (spell)](https://heroes.thelazy.net/index.php/Inferno_(spell)) |
| `homm3.spell.land.mine` | [Land Mine](https://heroes.thelazy.net/index.php/Land_Mine) |
| `homm3.spell.lightning.bolt` | [Lightning Bolt](https://heroes.thelazy.net/index.php/Lightning_Bolt) |
| `homm3.spell.magic.arrow` | [Magic Arrow](https://heroes.thelazy.net/index.php/Magic_Arrow) |
| `homm3.spell.magic.mirror` | [Magic Mirror](https://heroes.thelazy.net/index.php/Magic_Mirror) |
| `homm3.spell.meteor.shower` | [Meteor Shower](https://heroes.thelazy.net/index.php/Meteor_Shower) |
| `homm3.spell.mirth` | [Mirth](https://heroes.thelazy.net/index.php/Mirth) |
| `homm3.spell.misfortune` | [Misfortune](https://heroes.thelazy.net/index.php/Misfortune) |
| `homm3.spell.prayer` | [Prayer](https://heroes.thelazy.net/index.php/Prayer) |
| `homm3.spell.precision` | [Precision](https://heroes.thelazy.net/index.php/Precision) |
| `homm3.spell.protection.from.air` | [Protection from Air](https://heroes.thelazy.net/index.php/Protection_from_Air) |
| `homm3.spell.protection.from.earth` | [Protection from Earth](https://heroes.thelazy.net/index.php/Protection_from_Earth) |
| `homm3.spell.protection.from.fire` | [Protection from Fire](https://heroes.thelazy.net/index.php/Protection_from_Fire) |
| `homm3.spell.protection.from.water` | [Protection from Water](https://heroes.thelazy.net/index.php/Protection_from_Water) |
| `homm3.spell.quicksand` | [Quicksand](https://heroes.thelazy.net/index.php/Quicksand) |
| `homm3.spell.remove.obstacle` | [Remove Obstacle](https://heroes.thelazy.net/index.php/Remove_Obstacle) |
| `homm3.spell.resurrection` | [Resurrection](https://heroes.thelazy.net/index.php/Resurrection) |
| `homm3.spell.sacrifice` | [Sacrifice](https://heroes.thelazy.net/index.php/Sacrifice) |
| `homm3.spell.scuttle.boat` | [Scuttle Boat](https://heroes.thelazy.net/index.php/Scuttle_Boat) |
| `homm3.spell.shield` | [Shield](https://heroes.thelazy.net/index.php/Shield) |
| `homm3.spell.slayer` | [Slayer](https://heroes.thelazy.net/index.php/Slayer) |
| `homm3.spell.slow` | [Slow](https://heroes.thelazy.net/index.php/Slow) |
| `homm3.spell.sorrow` | [Sorrow](https://heroes.thelazy.net/index.php/Sorrow) |
| `homm3.spell.stone.skin` | [Stone Skin](https://heroes.thelazy.net/index.php/Stone_Skin) |
| `homm3.spell.summon.air.elemental` | [Summon Air Elemental](https://heroes.thelazy.net/index.php/Summon_Air_Elemental) |
| `homm3.spell.summon.boat` | [Summon Boat](https://heroes.thelazy.net/index.php/Summon_Boat) |
| `homm3.spell.summon.earth.elemental` | [Summon Earth Elemental](https://heroes.thelazy.net/index.php/Summon_Earth_Elemental) |
| `homm3.spell.summon.fire.elemental` | [Summon Fire Elemental](https://heroes.thelazy.net/index.php/Summon_Fire_Elemental) |
| `homm3.spell.summon.water.elemental` | [Summon Water Elemental](https://heroes.thelazy.net/index.php/Summon_Water_Elemental) |
| `homm3.spell.teleport` | [Teleport](https://heroes.thelazy.net/index.php/Teleport) |
| `homm3.spell.titans.lightning.bolt` | [Titan's Lightning Bolt](https://heroes.thelazy.net/index.php/Titan%27s_Lightning_Bolt) |
| `homm3.spell.town.portal` | [Town Portal](https://heroes.thelazy.net/index.php/Town_Portal) |
| `homm3.spell.view.air` | [View Air](https://heroes.thelazy.net/index.php/View_Air) |
| `homm3.spell.view.earth` | [View Earth](https://heroes.thelazy.net/index.php/View_Earth) |
| `homm3.spell.visions` | [Visions](https://heroes.thelazy.net/index.php/Visions) |
| `homm3.spell.water.walk` | [Water Walk](https://heroes.thelazy.net/index.php/Water_Walk) |
| `homm3.spell.weakness` | [Weakness](https://heroes.thelazy.net/index.php/Weakness) |
