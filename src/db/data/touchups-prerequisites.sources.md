# Heroes V ability prerequisites

Source: [Heroes V community manual, Tribes of the East 3.1](https://h5.heroes.net.pl/uploaded/download/other/Heroes5-Manual-en-3-1.pdf), printed/PDF pages 105–142.
The cached PDF SHA-256 is `7cdd706b9b3e5634a3015e8704c818a92a7127b3f743f7066b8a6295104fd678`.

The manual explicitly lists required abilities separately for each hero class.
This batch supplies all 404 class-specific lists in that page range. It adds
404 `HeroClassAbilityRequirementGroup` rows and 114 additional
`HeroClassAbility` atoms. It fills `RequiredAbility_id`, `RequirementSet`, and
`RequirementMode` on 404 existing association rows, for 1,212 guarded null fills.
No existing key, parent skill, granted ability, class, or availability value changes.

Each documented list becomes requirement set 1 with mode `All`. One required
ability occupies each atom. Additional atoms retain the original granted
ability's `Skill_id`; a prerequisite may belong to a different skill branch.
The schema can represent alternative sets, but none are invented here.
`MinimumMastery` remains unchanged because these named prerequisite lists do
not establish its value. Unlisted associations remain ungrouped and are not
asserted to have no prerequisites.

Examples checked on rendered pages:

- Demon Lord / Flaming Arrows (p. 105): Battle Frenzy, Hellfire and Excruciating Strike.
- Ranger / Retribution (p. 106): Battle Frenzy, Battle Commander and Rain of Arrows.
- Wizard / Seal of Darkness (p. 107): Magic mirror, using the existing ability identity.
- Wizard / Empathy (p. 116): Diplomacy and Arcane Exaltation.
- Wizard / Arcane Omniscience (p. 135): Mentoring, Arcane Excellence and Tremors.
- Warlock / Rage of the Elements (p. 138): six named prerequisites, including all three Destructive Magic masteries.
- Runemage / Absolute Protection (p. 141): Preparation, Runic Armour and Sap Magic.
- Knight / Unstoppable Charge (p. 142): Guardian Angel, Last Stand and Empathy.

PDF text extraction preserves the class-specific lists. Publisher headers,
footers, and the Barbarian exclusion notice were discarded at the boundary
after the final prerequisite. Ability names resolve to existing catalog
identities; case differences such as “Magic mirror” do not create duplicates.

The evidence JSON records the original association key, requirement-group key,
page numbers, and every required ability. Every prerequisite is already available
to the corresponding class in the catalog. The graphs for all eight classes
are acyclic. A scratch merge passes the current 176-table schema validator.

This batch records prerequisite relationships only. It does not import the
manual's ability-effect prose or infer undocumented hero-level/mastery limits.
