# Heroes III artifacts, campaigns, and adventure objects

Research date: 2026-09-29. Scope: The Restoration of Erathia,
Armageddon's Blade, and The Shadow of Death, with the classic SoD ruleset.

## Coverage

| Catalog | Rows | Coverage |
|---|---:|---|
| Artifact | 141 | 134 ordinary/combination artifacts plus seven special items |
| ArtifactHOMM3 | 141 | Class, slot, price, class-based AI value, and sourced primary-stat bonuses |
| ArtifactComponent | 49 | Components of all 12 SoD combination artifacts |
| ArtifactResourceCost | 138 | Gold prices where a fixed price is established |
| Campaign | 20 | Seven RoE, six AB, seven SoD campaigns |
| AdventureObject | 187 | 106 general interactive types plus 81 distinct external dwellings |
| AdventureObjectHOMM3 | 187 | Object category and external-dwelling interaction rules |

## Sources

- [Artifact list](https://heroes.thelazy.net/index.php/List_of_artifacts):
  identities, release markers, class, slot, gold price, primary statistics,
  and component membership.
- [Artifact mechanics](https://heroes.thelazy.net/index.php/Artifact):
  slot mapping, AI values by class, and the 12 official combination artifacts.
- Dedicated [Armageddon's Blade](https://heroes.thelazy.net/index.php/Armageddon%27s_Blade_(artifact))
  and [Vial of Dragon Blood](https://heroes.thelazy.net/index.php/Vial_of_Dragon_Blood)
  entries correct misleading summary-table statistics: the Blade supplies
  3 Attack, 3 Defense, 3 Power, and 6 Knowledge; the Vial's +5 Attack and
  Defense apply to allied dragons rather than the hero's primary attributes.
- [War machines](https://heroes.thelazy.net/index.php/War_machine):
  Ballista, Ammo Cart, First Aid Tent, and Catapult. The Ammo Cart costs 1,000
  gold in its dedicated entry; the summary adventure-object table's 500 is
  not used.
- [Spell Book](https://heroes.thelazy.net/index.php/Spell_Book),
  [Spell Scroll](https://heroes.thelazy.net/index.php/Spell_Scroll), and
  [Grail](https://heroes.thelazy.net/index.php/Grail): special inventory items.
- [Campaign index](https://heroes.thelazy.net/index.php/Campaign):
  all campaign identities and release grouping.
- [Adventure objects](https://heroes.thelazy.net/index.php/List_of_adventure_map_objects):
  interactive object identities, original release markers, and categories.
- [External dwellings](https://heroes.thelazy.net/index.php/Creature_dwelling#External_dwellings):
  all classic external dwelling types, including neutral creatures and the
  elemental conflux variants.
- [Freelancer's Guild](https://heroes.thelazy.net/index.php/Freelancer%27s_Guild):
  the adventure-map version was introduced in AB. Its RoE town counterpart
  does not establish the introduction release of the external object.

## Normalization

Only rows explicitly marked RoE, AB, or SoD are admitted. HotA-only rows,
inline HotA changes, unreleased combination artifacts, and mods are excluded.
The four abbreviated tome labels are expanded to their full artifact names.
Weapon/Shield/Helmet/Cape/Necklace map to RightHand/LeftHand/Head/Shoulders/Neck.
A combination artifact records its principal slot; its components are real
`ArtifactComponent` links. No component identities are embedded in JSONB.

The seven special inventory items are Spell Book, Spell Scroll, Grail, Ballista,
Ammo Cart, First Aid Tent, and Catapult. Variable or inapplicable AI values,
prices, and equipment slots remain null. Gold cost relationships reuse the
existing shared `resource.gold` identity. Ordinary artifact AI values describe
class-based map-generation valuation, not gold prices.

`Effect.primarySkillBonuses` is a bounded numeric document with attack,
defense, power, and knowledge keys. `Effect.alliedDragonBonuses` distinguishes
the Vial's creature-specific bonuses. These are partial mechanics fields:
non-stat artifact effects are not fully transcribed in this batch. An absent
effect does not mean an artifact has no effect. No wiki biographies, event
messages, or media are copied.

Campaigns have separate identities from releases, including the identically
named Armageddon's Blade campaign. This batch adds the campaign catalog;
mission maps and scenario progression are not claimed. Heroes Chronicles is a
separate series of standalone releases and is outside the specified expansions.

Adventure-object identities describe gameplay types rather than individual
sprite, terrain, color, or facing variants. Both generic Creature dwelling and
Refugee Camp are dwelling types; the 81 individually named dwellings are in
addition to those two. Golem Factory occurs in both town-affiliated and neutral
sections of the source but has one identity. Crystal Cave (a dragon dwelling)
and Crystal Cavern (a resource mine) remain separate. Market of Time is retained
as an inert original map object. Decorative scenery and map-editor random
placeholders are outside this interactive-object catalog.

The current schema has no adventure-object-to-faction or adventure-object-to-
creature junction. This batch does not hide those relationships inside JSONB or
reuse `BuildingCreature` with an object ID. Categories and known interaction
flags live in `AdventureObjectHOMM3`; unverified footprints, guards, reward
tables, and detailed effects remain null. A future diagram-approved junction
would be needed for relational dwelling recruitment links.

All generic/detail pairs share their `_key`. Physical IDs are allocated and
resolved by the content importer. The schema and initial migration are unchanged.
