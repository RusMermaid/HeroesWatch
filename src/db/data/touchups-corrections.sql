-- Reviewed label corrections. Run after migration 0002 and before touchup parts.
-- Changes are guarded by their recorded old values; unknown edits abort.
BEGIN;
SET LOCAL standard_conforming_strings = on;
SET LOCAL lock_timeout = '15s';
LOCK TABLE heroes_watch."AdventureObject" IN SHARE ROW EXCLUSIVE MODE;
DO $corrections$
DECLARE existing_name text;
BEGIN
  SELECT o."Name" INTO existing_name FROM heroes_watch."AdventureObject" o, heroes_watch."Game" g WHERE o."Game_id" = g."Game_id" AND g."SeriesCode" = E'HOMM6' AND o."Code" = E'DUNGEON_FILE_DUNGEON_FORT_ICON_PNG_DUNGEON_FORT';
  IF FOUND THEN
    IF existing_name IS DISTINCT FROM E'File:Dungeon Fort icon.png Dungeon Fort' AND existing_name IS DISTINCT FROM E'Dungeon Fort' THEN
      RAISE EXCEPTION 'Unrecognized existing label for %; correction aborted', E'homm6.adventureobject.dungeon.file.dungeon.fort.icon.png.dungeon.fort';
    END IF;
    UPDATE heroes_watch."AdventureObject" o SET "Name" = E'Dungeon Fort' FROM heroes_watch."Game" g WHERE o."Game_id" = g."Game_id" AND g."SeriesCode" = E'HOMM6' AND o."Code" = E'DUNGEON_FILE_DUNGEON_FORT_ICON_PNG_DUNGEON_FORT' AND o."Name" = E'File:Dungeon Fort icon.png Dungeon Fort';
  END IF;
  SELECT o."Name" INTO existing_name FROM heroes_watch."AdventureObject" o, heroes_watch."Game" g WHERE o."Game_id" = g."Game_id" AND g."SeriesCode" = E'HOMM6' AND o."Code" = E'HAVEN_FILE_HAVEN_FORT_ICON_PNG_HAVEN_FORT';
  IF FOUND THEN
    IF existing_name IS DISTINCT FROM E'File:Haven Fort icon.png Haven Fort' AND existing_name IS DISTINCT FROM E'Haven Fort' THEN
      RAISE EXCEPTION 'Unrecognized existing label for %; correction aborted', E'homm6.adventureobject.haven.file.haven.fort.icon.png.haven.fort';
    END IF;
    UPDATE heroes_watch."AdventureObject" o SET "Name" = E'Haven Fort' FROM heroes_watch."Game" g WHERE o."Game_id" = g."Game_id" AND g."SeriesCode" = E'HOMM6' AND o."Code" = E'HAVEN_FILE_HAVEN_FORT_ICON_PNG_HAVEN_FORT' AND o."Name" = E'File:Haven Fort icon.png Haven Fort';
  END IF;
  SELECT o."Name" INTO existing_name FROM heroes_watch."AdventureObject" o, heroes_watch."Game" g WHERE o."Game_id" = g."Game_id" AND g."SeriesCode" = E'HOMM6' AND o."Code" = E'INFERNO_FILE_INFERNO_FORT_ICON_PNG_INFERNO_FORT';
  IF FOUND THEN
    IF existing_name IS DISTINCT FROM E'File:Inferno Fort icon.png Inferno Fort' AND existing_name IS DISTINCT FROM E'Inferno Fort' THEN
      RAISE EXCEPTION 'Unrecognized existing label for %; correction aborted', E'homm6.adventureobject.inferno.file.inferno.fort.icon.png.inferno.fort';
    END IF;
    UPDATE heroes_watch."AdventureObject" o SET "Name" = E'Inferno Fort' FROM heroes_watch."Game" g WHERE o."Game_id" = g."Game_id" AND g."SeriesCode" = E'HOMM6' AND o."Code" = E'INFERNO_FILE_INFERNO_FORT_ICON_PNG_INFERNO_FORT' AND o."Name" = E'File:Inferno Fort icon.png Inferno Fort';
  END IF;
  SELECT o."Name" INTO existing_name FROM heroes_watch."AdventureObject" o, heroes_watch."Game" g WHERE o."Game_id" = g."Game_id" AND g."SeriesCode" = E'HOMM6' AND o."Code" = E'NECROPOLIS_FILE_NECRO_FORT_ICON_PNG_NECROPOLIS_FORT';
  IF FOUND THEN
    IF existing_name IS DISTINCT FROM E'File:Necro Fort icon.png Necropolis Fort' AND existing_name IS DISTINCT FROM E'Necropolis Fort' THEN
      RAISE EXCEPTION 'Unrecognized existing label for %; correction aborted', E'homm6.adventureobject.necropolis.file.necro.fort.icon.png.necropolis.fort';
    END IF;
    UPDATE heroes_watch."AdventureObject" o SET "Name" = E'Necropolis Fort' FROM heroes_watch."Game" g WHERE o."Game_id" = g."Game_id" AND g."SeriesCode" = E'HOMM6' AND o."Code" = E'NECROPOLIS_FILE_NECRO_FORT_ICON_PNG_NECROPOLIS_FORT' AND o."Name" = E'File:Necro Fort icon.png Necropolis Fort';
  END IF;
  SELECT o."Name" INTO existing_name FROM heroes_watch."AdventureObject" o, heroes_watch."Game" g WHERE o."Game_id" = g."Game_id" AND g."SeriesCode" = E'HOMM6' AND o."Code" = E'SANCTUARY_FILE_SANCTUARY_FORT_ICON_PNG_SANCTUARY_FORT';
  IF FOUND THEN
    IF existing_name IS DISTINCT FROM E'File:Sanctuary Fort icon.png Sanctuary Fort' AND existing_name IS DISTINCT FROM E'Sanctuary Fort' THEN
      RAISE EXCEPTION 'Unrecognized existing label for %; correction aborted', E'homm6.adventureobject.sanctuary.file.sanctuary.fort.icon.png.sanctuary.fort';
    END IF;
    UPDATE heroes_watch."AdventureObject" o SET "Name" = E'Sanctuary Fort' FROM heroes_watch."Game" g WHERE o."Game_id" = g."Game_id" AND g."SeriesCode" = E'HOMM6' AND o."Code" = E'SANCTUARY_FILE_SANCTUARY_FORT_ICON_PNG_SANCTUARY_FORT' AND o."Name" = E'File:Sanctuary Fort icon.png Sanctuary Fort';
  END IF;
  SELECT o."Name" INTO existing_name FROM heroes_watch."AdventureObject" o, heroes_watch."Game" g WHERE o."Game_id" = g."Game_id" AND g."SeriesCode" = E'HOMM6' AND o."Code" = E'STRONGHOLD_FILE_STRONGHOLD_FORT_ICON_PNG_STRONGHOLD_FORT';
  IF FOUND THEN
    IF existing_name IS DISTINCT FROM E'File:Stronghold Fort icon.png Stronghold Fort' AND existing_name IS DISTINCT FROM E'Stronghold Fort' THEN
      RAISE EXCEPTION 'Unrecognized existing label for %; correction aborted', E'homm6.adventureobject.stronghold.file.stronghold.fort.icon.png.stronghold.fort';
    END IF;
    UPDATE heroes_watch."AdventureObject" o SET "Name" = E'Stronghold Fort' FROM heroes_watch."Game" g WHERE o."Game_id" = g."Game_id" AND g."SeriesCode" = E'HOMM6' AND o."Code" = E'STRONGHOLD_FILE_STRONGHOLD_FORT_ICON_PNG_STRONGHOLD_FORT' AND o."Name" = E'File:Stronghold Fort icon.png Stronghold Fort';
  END IF;
END
$corrections$;
COMMIT;
