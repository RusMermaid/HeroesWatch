# Heroes VII final follow-up — source and architecture record

Research date: 2026-10-13. This is a non-destructive research overlay for the
final-catalog review. It adds no rows to `heroeswatch.json`, changes no SQL, and
does not write to a PostgreSQL database. The companion
`heroes7.patch.json` intentionally has empty `additions` and `fills`: a
partial warfare row or a guessed Hall flag would violate the project’s
architecture and source policy.

## What remains in the repository

The current cumulative JSON contains:

| Table | Existing Heroes VII rows | Missing rows |
|---|---:|---:|
| `CreatureHOMM7` | 137 | 19 warfare identities |
| `HeroClassHOMM7` | 35 | 9 class details |
| `HeroHOMM7` | 22 | 110 hero details |

The 19 missing creature identities are the three Academy warfare units, three
Haven units, three Dungeon units, two Necropolis units, two Stronghold units,
three Sylvan units, and three Fortress units. The 9 missing class identities
are Archon, Embalmer, Engraver, Firebrander, Hell Knight, Jarl, Runelord,
Thane, and Warlord.

## Authoritative evidence

### Ubisoft editor: Hall availability is not a global hero attribute

The [official Heroes VII Editor Manual](https://ubistatic-a.akamaihd.net/0004/prod/images/160407_LT1_Modding/EditorManual.pdf),
§10.5, says the Heroes tab enables or disables heroes “in this map per
player.” Its screenshot shows the existing 22 Academy, Dungeon, and Haven
rows and one disabled example (Lethos). This is direct evidence for the
catalog’s current positive rows, but not evidence that every other hero is
globally unavailable.

The same manual’s Hero Tool section says custom heroes are added to the map’s
hero list and then become available in that map’s Hall of Heroes. This does not
invalidate the existing 22 positive `HeroHOMM7.IsHallHero` values if that field
is read as catalog eligibility/default availability; it only proves that a
future map/player override is a separate concern. A junction such as
`MapHeroHOMM7(Map_id, Hero_id, PlayerNumber, IsEnabled, SourceMediaAsset_id)`
is therefore an optional extension if the project starts recording map
overrides. The current PostgreSQL column is `NOT NULL`; relax it only if
unknown catalog-level eligibility must be represented. Do not mark the other
110 heroes `false` merely because no map-specific evidence was collected.

### Ubisoft modding manual: the missing source is the game/editor package

The [official Heroes VII Modding Manual](https://ubistatic-a.akamaihd.net/0004/prod/images/160407_LT1_Modding/ModdingManual.pdf)
describes the game as data-driven. An H7 creature is an archetype with
configured stats and visuals, and the authoritative values live in the game
packages used by the editor. No H7 installation or package dump is present in
this checkout, and this task did not download the full game. Accordingly,
these rows are not synthesized from screenshots, artwork, or a single wiki
table.

### Ubisoft-authored Shadow Council posts: Fortress identity and version
scope

The [rssing.com mirror](https://shadow1705.rssing.com/chan-52808156/latest.php)
reproduces Ubisoft-authored July 2016 “Fortress Warfare Units” and “Fortress
Heroes” posts. `rssing.com` is a third-party mirror, not Ubisoft and not a
primary host. The mirrored article names
Runestone, Fire Cannon, and Dwarven Ballista and describes their support,
siege, and ranged roles. The adjacent “Fortress Heroes” article names the
classes Warlord, Jarl, Thane, Firebrander, Runelord, and Engraver and gives
their main skill focus. These facts are safe to retain as identities and
roles; they do not publish the four numeric growth percentages required by
`HeroClassHOMM7`.

The same mirrored Ubisoft posts reproduce later balance and bug-fix revisions—
for example, changes to Warlord’s Fury and warfare-unit behavior—so a final
import must identify the final game/editor package or patch revision. A
pre-release or community-mod table is not a substitute.

The existing generic catalog already preserves the concrete relationships that
can be represented without a detail sidecar: the 19 named heroes listed in the
JSON overlay point to the nine unresolved class identities, and generic class
descriptions already carry the faction/focus labels for Archon, Embalmer, Hell
Knight, and the six Fortress classes. The current `HeroClassHOMM7` table has no
`MainSkills` or `ClassMechanics` column, so the mirrored Ubisoft main-skill
lists are evidence-only and are not written into an invented field.

The concrete Fortress main-skill evidence reproduced by the mirror is:

| Class | Main skills in the mirrored Ubisoft-authored post |
|---|---|
| Warlord | Warfare, Offense, Exploration, Leadership |
| Jarl | Economy, Paragon, Fire Magic, Destiny |
| Thane | Defense, Fire Magic, Warcries, Economy |
| Firebrander | Fire Magic, Warfare, Air Magic, Exploration |
| Runelord | Fire Magic, Paragon, Prime Magic, Economy |
| Engraver | Fire Magic, Earth Magic, Defense, Destiny |

The existing generic `Hero` rows already preserve these relationships to
unresolved class identities: Anastasya→Embalmer, Lyla→Archon,
Aslaug/Haegeir→Warlord, Bart Brimstone/Brigid→Runelord, Ergal/Raelag→Hell
Knight, Fasolt/Hedwig/Tolghar→Thane, Fredrik/Hathor/Vilma→Jarl,
Geisli/Gerdi/Kari→Engraver, and Hangvul/Svea→Firebrander. These are existing
`Hero.HeroClass_id` links, not new data guessed from the class-growth gap.
The mirrored Ubisoft Skillwheel article also explicitly identifies Lyla as an
Archon, corroborating that existing link. It does not provide the missing
four-number growth vector.

## Warfare data recovered for the next package-backed pass

Published secondary unit pages expose rank 1–5 vectors for most warfare units.
The values below are retained as cross-check evidence only. They are **not**
inserted into the current scalar `CreatureHOMM7` table because doing so would
discard four ranks and would misrepresent support effects as ordinary damage.

`Damage` arrays are `[min, max]`; arrays of five values are ranks 1–5.

| Identity | Role | Rank-varying evidence retained |
|---|---|---|
| Great pyramid | Siege | Attack 0; Defense 10/20/30/40/50; Damage 70–110, 90–140, 120–180, 160–220, 220–260; Health 3000/5000/7000/10000/15000; Initiative 100 |
| Healing tent | Support | Attack 0; Defense 5/10/15/20/25; healing 30/50/100/200/400; Health 300/400/500/600/800; Initiative 8; published size Large |
| Small pyramid | Attack | Attack and Defense 5/10/15/20/25; Damage 16–24, 29–41, 38–52, 42–58, 60–80; Health 500/600/700/800/1000; Initiative 15 |
| Cave wyvern | unresolved | Independent page gives baseline Attack 0, Defense 10, Damage 70–110, Health 3000, Initiative 100; rank vector, movement and footprint unresolved |
| Faceless | Support | Attack 0; Defense 5/10/15/20/25; support effect 30/45/60/90/120; Health 300/400/500/600/700; Initiative 35 |
| Shadow lurker | unresolved | Independent page gives baseline Attack 5, Defense 5, Damage 16–23, Health 250, Initiative 25; rank vector, movement and footprint unresolved |
| Haven ballista | Attack | Attack 5/10/15/20/25; Defense 10/15/20/25/30; Damage 16–24, 29–41, 38–52, 42–58, 60–80; Health 250/350/450/550/700; Initiative 19 |
| Catapult | Siege | Attack 0; Defense 12; Damage 75–115, 100–150, 135–195, 180–240, 245–285; Health 3900/6500/9100/11700/19500; Initiative 100 |
| Healing sister | Support | Attack 0; Defense 10/15/20/25/30; healing 30/50/100/150/250; Health 300/400/500/600/700; Initiative 11 |
| Namtaru | Attack and support | Attack and Defense 5/10/15/20/25; Damage 16–24, 29–41, 38–52, 42–58, 60–80; Health 600/700/800/800/900; Initiative 18; published size Large |
| Spitting spider | Siege | Attack 0; Defense 8/16/24/32/40; Damage 65–105, 80–130, 105–165, 140–200, 195–235; Health 2100/3500/4900/6300/10500; Initiative 100; published size Large |
| Dreamwalker | unresolved | Independent page gives baseline Attack 5, Defense 5, Damage 20–28, Health 1500, Initiative 21; rank vector, movement and footprint unresolved |
| Tamed cyclops | Siege | Attack 0; Defense 12/24/36/48/60; Damage 75–115, 100–150, 135–195, 180–240, 245–285; Health 3900/6500/9100/11700/19500; Initiative 100 |
| Greater earth elemental | Siege | Attack 0; Defense 8/16/24/32/40; Damage 65–105, 80–130, 105–165, 140–200, 195–235; Health 2100/3500/4900/6300/10500; Initiative 100; published size Large |
| Mother treant | Support | Attack 0; Defense 5/10/15/20/25; renewal 20/40/60/120/300; Health 300/400/500/600/700; Initiative 12; published size Large |
| Sylvan ballista | Attack | Attack 5/10/15/20/25; Defense 5/10/20/25/35; Damage 16–24, 29–41, 38–52, 42–58, 60–80; Health 250/350/450/550/700; Initiative 27; published size Large |
| Dwarven ballista | Attack | Attack 5/10/15/20/25; Defense 10/15/25/30/40; Damage 14–22, 25–38, 32–49, 36–54, 50–75; Health 300/400/500/600/800; Initiative 17 |
| Fire cannon | Siege | Attack 0; Defense 12/24/36/48/60; Damage 65–105, 80–130, 105–165, 140–200, 195–235; Health 3000/5000/7000/9000/15000; Initiative 100 |
| Runestone | Support | Attack 0; Defense 5/10/15/20/25; Health 300/400/500/600/700; Initiative 9; the published Rune Heal text is percentage-based, so the secondary page’s damage-like vector is not imported as damage |

The rank profiles are cross-checked against the [Heroes VII warfare roster](https://mightandmagic.fandom.com/wiki/Heroes_VII_creatures)
and its linked unit pages. For the Haven baseline, the independent [Heroes
Centrum unit table](https://www.heroes-centrum.com/h7/azyl-jednotky) prints
Healing Sister, Ballista, and Catapult values and reports movement `0`.
That printed value is not silently converted to the current enum’s
`Ground`/`Flying`/`Teleporting`, and no combat-square count is inferred from
the visual size label.

## Class details: no safe numeric merge yet

The dated [GamerSky 2015 class table](https://www.gamersky.com/handbook/201510/671280_24.shtml)
prints candidate percentages for Archon (`5/25/25/45`) and Embalmer
(`10/15/35/40`) in Might/Defense/Magic/Spirit order. The existing catalog
research records conflicting secondary values, and the official Ubisoft
material found here gives class roles and skills but not these four
percentages. Therefore the candidate values are evidence-only and are not
applied. The six Fortress classes are confirmed as identities and roles by the
mirror of Ubisoft-authored posts; their required numeric values still need the
final `H7HeroClasses` package. Hell Knight likewise remains unresolved.

## Candidate architecture extensions (not approved merge requirements)

1. If rank-level warfare detail is a project requirement, consider adding a
   normalized `CreatureWarfareRankHOMM7` child table keyed by
   `(Creature_id, Rank)` with rank-specific Attack, Defense, DamageMin,
   DamageMax, Health, and a typed support-effect value. Keep Initiative on the
   base detail only when it is truly rank-invariant.
2. If the package-backed data confirms stationary warfare units and unknown
   footprints, consider adding a representation for them. Current
   `CreatureHOMM7.Movement` is a required enum with no `Stationary`
   member, `Speed` is required, and `CombatSize` is required. The import must
   not manufacture values to satisfy those constraints.
3. If map-specific Hall overrides become part of the product scope, consider
   adding `MapHeroHOMM7` for map/player availability. Existing catalog-level
   `IsHallHero` values do not need to be removed solely because this junction
   does not yet exist.
4. Once the final game/editor package is available, add complete class-detail
   rows only when all required growth fields are resolved together. Do not
   merge Archon/Embalmer candidates independently.

## Verification status

- Repository JSON was counted locally: 19 missing H7 warfare details, 9
  missing H7 class details, and 110 missing H7 hero details.
- Official Ubisoft manuals were opened and cited; the historical Ubisoft-authored
  class/warfare posts were accessed only through a third-party mirror.
- No full game download, package extraction, SQL import, live database write,
  or GitHub write was performed.
- The overlay is **not safe to merge directly** until package-backed source
  data is available; the architecture extensions above remain optional design
  candidates for review.
