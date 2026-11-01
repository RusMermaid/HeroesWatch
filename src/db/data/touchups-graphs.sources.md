# Campaigns, map relationships and faction lore

Reviewed 2026-10-04. This batch adds scenario membership for every previously
unlinked Heroes campaign, uses the existing sixty Heroes V scenarios, and gives
all **83 Heroes campaigns** a path through `CampaignScenario` to `Scenario` and
`Map`. It does not claim complete scripts or placement data for every game.

| Game | Campaigns | Scenarios | Progression edges |
|---|---:|---:|---:|
| I | 1 | 9 | 12 |
| II | 6 | 47 | 54 |
| III | 20 | 87 | 75 |
| IV | 18 | 70 | 52 |
| V | 13 | 60 | 47 |
| VI | 11 | 36 | 24 |
| VII | 11 | 43 | 32 |
| Olden Era | 3 | 21 | 20 |

## Original Heroes III files

The local, licensed Heroes III Complete archives supply the original `.h3c`
campaigns. The parser reads each concatenated gzip stream: the campaign header,
region prerequisites and embedded maps. The published
[VCMI campaign reader](https://github.com/vcmi/vcmi/blob/develop/lib/campaign/CampaignHandler.cpp),
[map reader](https://github.com/vcmi/vcmi/blob/develop/lib/mapping/MapFormatH3M.cpp)
and [H3M format specification](https://github.com/alexanderbelous/h3mtxt/blob/master/doc/h3m_specification.MD)
document the binary layout. Source filenames and SHA-256 values are retained in
[the evidence](touchups-evidence.json). Binary maps and narrative text stay local.

All 87 map streams were parsed through their object records, timed events and
124-byte final padding. This supplies map size, levels, player count, format,
difficulty, **417 map/terrain memberships**, and **5,401 map/object-type links**.
Object links describe placed types that match the existing catalog. Unmapped
decoration/internal types are omitted; template presence alone was not treated
as evidence of an actual placed object.

Native object type/subtype mapping follows the
[map-editor object table](https://heroes.thelazy.net/index.php/Map_Editor_Objects)
and the installed `ObjNames.txt`. Only IDs actually present in the original
maps are used. `HOTRAITS.TXT` identifies heroes, including the two Lord Haart
identities. Fifty campaign/hero links come from human-owned hero placements.
Custom renamed heroes are excluded. A starting scenario is assigned only when
the native prerequisite graph establishes one earliest observed appearance.
These heroes use the `Commander` role; placement alone does not establish a
story protagonist.

Scenario order is a topological ordering of native region prerequisites.
Empty regions do not create scenarios. Both incoming prerequisites of a native
merge remain required. The installed `Neutral1.h3c` is used for Spoils of War;
its older duplicate `Neutral.h3c` is excluded.

## Other campaign progression

- **I:** The [campaign description](https://mightandmagic.fandom.com/wiki/A_Strategic_Quest_(campaign))
  specifies nine maps, with the selected leader's castle omitted. Conditional
  edges preserve the fixed castle order and skip the appropriate confrontation.
- **II:** The [fheroes2 campaign data](https://github.com/ihhub/fheroes2/blob/master/src/fheroes2/campaign/campaign_data.cpp)
  provides all forty-seven scenario names and explicit next-scenario lists,
  including optional routes and betrayal transfers between the two base-game
  campaigns. Alternative paths are marked as choices, not cumulative requirements.
- **IV:** Individual campaign pages explicitly enumerate their scenarios in
  order. The [Last Bastion](https://mightandmagic.fandom.com/wiki/The_Last_Bastion)
  has one scenario, **Last Man Standing**. Its list of five heroes is not a
  scenario list. All five characters receive a start link to that single map;
  the source says the player chooses one and the others are AI-controlled.
- **V:** Existing researched campaign membership and `SortOrder` provide the
  linear mission sequence; see [the original source notes](remaining-homm5.sources.md).
- **VI:** The [scenario navigation](https://mightandmagic.fandom.com/wiki/Template:H6scen)
  has explicit arrows. Its two alternative final scenarios receive membership
  without an invented sequential link between them.
- **VII:** Individual campaign scenario lists and the
  [scenario index](https://mightandmagic.fandom.com/wiki/Template:H7scen)
  supply published mission order. These are documented sequences rather than
  a reconstruction of every native unlock script.

## Olden Era

The cached installed **Early Access build 25061458** supplies
`campaigns/*/storyHub.json`, referenced mission files and English title tokens.
Only referenced missions with actual mission data, a localized title and map
identifier are imported. Map variants become distinct scenarios because
`Scenario.Map_id` identifies one map. No guessed size or placement data is added.

The native activation actions supply progression edges. Conditional counter
tests remain bounded, typed JSON with source provenance. Completing either
Mission 7 route activates Mission 8; the two routes are marked as alternatives.
The independent eight challenges have no invented sequential progression.
Three hub references lack released mission data and remain excluded: Node 9,
Additional 1 and Additional 2. Test mission definitions outside the hub are
also excluded. Mission 1's `fixedHeroesSet` establishes Gunnar's start.

## Starting heroes and faction lore

Twelve additional start links have individual mission evidence: Isabel,
Agrael, Markal, Raelag, Findan, Zehir, Slava, Anastasya, Anton, Irina, Kiril and
Sandor. The evidence records the mission source and starting-position or
initial-hero statement. Zehir's first mission is corroborated by the supplied
Prima guide, PDF page 266 / printed page 265. Its older mission title does not
rename the current catalog entry.

Campaign membership alone is not treated as proof of a first playable mission.
Other uncorroborated starting-scenario fields remain null. The resulting
catalog has **68 starting-scenario links** across 120 campaign/hero records.

Five existing Heroes VI art-book lore entries now have `LoreFull.Faction_id`
subject links. Their faction identity was already explicit in the document
and catalog; the new column makes it available through a foreign-key join.
