# Heroes V rune-resource completion

The developer-supported **Heroes V 3.1 handbook**, PDF/printed page 191, was
read as a rendered page. Resource icons were inspected visually rather than
guessed from text extraction, which drops the icons.

| Rune | Base resources per activation |
|---|---|
| Charge | 1 Wood |
| Berserking | 1 Ore |
| Magic Control | 1 Gems |
| Exorcism | 1 Sulfur |
| Elemental Immunity | 1 Mercury |
| Etherealness | 1 Crystal |
| Thunderclap | 1 Wood + 1 Mercury |
| Resurrection | 1 Ore + 1 Gems |
| Battle Rage | 1 Ore + 1 Crystal |
| Dragonform | 1 Wood + 1 Sulfur |

These become 14 `SpellResourceCostHOMM5` rows and six missing H5 `GameResource`
memberships, reusing global resource identities. `Ruleset=TribesOfTheEast`
means the described 3.1 ruleset; the page's Hammers of Fate badges identify
when runes were introduced, not a separate historical numeric dataset.

The rows describe base activation costs. Skill discounts, refreshing/reusing
runes, and special hero/perk modifiers are not extra base-cost rows. No mana
cost is inferred. Resource introduction-release fields remain NULL because
this page establishes current usage, not when each resource first appeared.

Source: [Heroes V 3.1 handbook](https://h5.heroes.net.pl/uploaded/download/other/Heroes5-Manual-en-3-1.pdf),
p.191. HTTP entity tag `"377c9c1-6042b7303c15b"`, size 58,182,081 bytes. Only
selected ranges and a 469,390-byte local visual reference PDF were retained,
not the whole handbook. No forum or community-mod data was used.

Reproduce the factual patch with `node src/db/tools/research-homm5-rune-costs.mjs`
against the reviewed pre-completion catalog. The output is a staged research
patch; it does not itself modify the catalog or PostgreSQL.
