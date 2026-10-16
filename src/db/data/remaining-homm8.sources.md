# Olden Era remaining catalog categories

Researched 2026-09-29–30 against the installed **Steam build 25061458**.
The earlier faction, class, hero, building and dwelling records remain intact.
HOMM8 is the repository band for Heroes of Might and Magic: Olden Era.

## Added records

| Category | New records |
|---|---:|
| Ordinary learnable skills | 24 |
| Skill details, including the six existing faction skills | 30 |
| Subskill abilities / details | 180 / 180 |
| Schools | 4 |
| Spells / details | 93 / 93 |
| Spell-school links | 72 |
| New creature identities / creature details | 20 / 146 |
| Creature upgrades / recruitment costs | 84 / 159 |
| Artifacts / details | 302 / 302 |
| Additional named map objects / details | 137 / 137 |
| Campaign groups | 3 |
| Campaign heroes / details / campaign links | 4 / 4 / 4 |
| Standard hero starting-skill links | 210 |

The additive fragment has **2,188 rows**. Creature details extend all 126
existing town creatures and add 20 neutral or summoned identities. Each of the
42 base town creatures has two real alternative upgrade edges. Prices and
growth are populated only for recruitable units with operative recruitment
definitions.

## Primary source and references

The user's installed `Core.zip` is the primary numerical source. Its build
was established from the Steam app manifest. Raw game files and localization
prose remain in ignored research storage; no archives or artwork are committed.

- `DB/units/units_logics` supplies combat attributes, movement and recruitment
  costs; `DB/units/units_views` resolves display-name overrides.
- `DB/objects_logic/cities` and `DB/objects_logic/hires/barracks.json` establish
  actual recruitment, growth, and the two upgrade alternatives.
- `DB/heroes_skills/skills/skills.json` supplies the 30 ordinary/faction skills
  and their three mastery levels. Its referenced subskills define 180 available
  choices. Arena, campaign-specific replacements and obsolete unreferenced
  subskills are not additional standard skills.
- `DB/magics` supplies school, tier, mana and research costs. Masterful spell
  definitions are alternate modes of their ordinary spell identities.
- `DB/items/items` and `DB/items/item_sets` supply equipment slots, rarity,
  upgrade limits, destruction rewards, effects and set membership.
- `DB/objects_logic` supplies named operative adventure sites and visit/reset
  policies. TODO definitions, unnamed script internals, visual variants and
  individual artifact-pickup implementations are excluded.
- `campaigns/mainStory`, `campaigns/tutorial`, `campaigns/tutorial_challenges`
  and the English menu strings establish Main Story, Tutorial and Challenges.
  The four named Act I protagonists are Gunnar, Lafiur, Valentina and Lord
  Galthran. The unnamed fifth protagonist definition is not treated as released
  content. No future campaign acts are added.
- `Lang/english/texts` supplies labels; `DB/info` explains source parameters
  used in the short newly written mechanics summaries.

Public reference pages:

- [Official skills overview](https://wiki.hoodedhorse.com/Heroes_of_Might_and_Magic_Olden_Era/Skills)
- [Official spell catalog](https://wiki.hoodedhorse.com/Heroes_of_Might_and_Magic_Olden_Era/Spells)
- [Official artifact catalog](https://wiki.hoodedhorse.com/Heroes_of_Might_and_Magic_Olden_Era/Artifacts)
- [Official units overview](https://wiki.hoodedhorse.com/Heroes_of_Might_and_Magic_Olden_Era/Units)
- [Single-hex combat footprints](https://heroes3wog.net/good-to-know-about-homm-olden-era/)
- [Official Steam release page](https://store.steampowered.com/app/3105440/Heroes_of_Might__Magic_Olden_Era/)

Online pages can describe newer balance changes. Numerical rows deliberately
use the identified installed build rather than mixing current wiki numbers
with the earlier faction batch.

## Mapping and limits

- Every existing `_key` is reused; no physical IDs are supplied. Subskills are
  `Ability` records with `ParentSkill_id`, mastery and choice slots. Neutral
  spells have no invented fifth school: only Daylight, Nightshade, Arcane and
  Primal receive school identities.
- Five strengths of Summon Avatar have separate named spell identities.
  Faction-specific internal implementations share those displayed identities.
  The Avatar creature similarly has one catalog identity. The alternate
  Peasant implementation is not a second creature.
- Creature statistics describe unmodified source definitions. All combat
  footprints occupy one hex. `Shots` remains null because a finite ammunition
  budget is not established. Growth/costs of summoned or otherwise unpurchasable
  units are not invented. Alternative upgrades are represented through FKs.
- Spell descriptions summarize actual effects. Most optional per-level
  formulas and Masterful effects remain null; the presence of a detail row
  does not claim full numerical simulation. Lightning Bolt's four sourced
  damage formulas are retained. Astrology costs use the source `starDust`
  fields; ordinary research costs use Alchemical Dust.
- Artifact identities include 144 spell-specific ordinary/enchanted scrolls,
  six mythic scroll types and named campaign items. Scroll names are qualified
  by the granted spell where necessary to distinguish them. Two unlocalized
  campaign item definitions remain excluded.
- Equipment slot labels follow the English localization: source `left_hand`
  means Main Hand and `right_hand` means Off Hand. Source limits 999/9999 are
  the game's unlimited-upgrade convention; the public maximum remains null.
- Artifact effects describe the unupgraded item. Bonuses gated behind
  activation level 2 are not added to the base effect. Upgrade and set-bonus
  fields contain only effects whose parameters were safely mapped; other
  optional formulas and upgrade costs remain null. Set fields follow the
  architecture's bounded HOMM8 representation; no fake component assembly
  relations are created.
- Object reset flags use the actual `OnStartDay` and `OnStartWeek` policies.
  A mine's daily production is not a daily visitation reset. Detailed variable
  reward tables, scripted campaign variants and decorative scenery are outside
  the named operative-object catalog.
- Campaign rows describe the released groups; mission progression graphs are
  not inferred from partially shared scripts. Existing standard hero rows are
  untouched; their starting skills are added through `HeroSkill`.

No test suite or separate database-verification pass was run for this batch,
as requested. The integration step still enforces the existing JSON contract
and PostgreSQL constraints while importing.

## Reproduction

Run `node src/db/tools/research-remaining-homm8.mjs EXTRACTED_CORE_DIRECTORY`
before integration. It writes only the ignored `research/remaining-homm8.json`
fragment and a temporary list of filtered source definitions. It skips rows
already present in the cumulative bundle and never connects to PostgreSQL.
