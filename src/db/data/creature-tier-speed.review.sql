-- Read-only check of current creature tiers and numeric speeds.
WITH stats AS (
  SELECT 1 AS display_order, 'HOMM3'::TEXT AS "Game", c."Name", d."Tier", d."Speed", NULL::TEXT AS "SpeedName"
  FROM heroes_watch."CreatureHOMM3" d JOIN heroes_watch."Creature" c USING ("Creature_id")
  WHERE c."Code" IN ('FAERIE_DRAGON', 'RUST_DRAGON', 'CRYSTAL_DRAGON', 'AZURE_DRAGON')
  UNION ALL
  SELECT 2, 'HOMM1', c."Name", d."Tier", d."Speed", d."SpeedName"
  FROM heroes_watch."CreatureHOMM1" d JOIN heroes_watch."Creature" c USING ("Creature_id")
  UNION ALL
  SELECT 3, 'HOMM2', c."Name", d."Tier", d."Speed", d."SpeedName"
  FROM heroes_watch."CreatureHOMM2" d JOIN heroes_watch."Creature" c USING ("Creature_id")
)
SELECT "Game", "Name", "Tier", "Speed", "SpeedName"
FROM stats ORDER BY display_order, "Tier", "Name";
