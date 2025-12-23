extends Node


const CURRENT_VERSION := 1
const SAVE_PATH := "user://save/savegame.res"

func new_save() -> SaveGameResource:
	var s := SaveGameResource.new()
	s.version = CURRENT_VERSION
	s.current_level_id = LevelDb.LevelEnum.LEVEL_2
	s.unlocked_levels = [LevelDb.LevelEnum.LEVEL_2]
	return s

func save_game(s: SaveGameResource) -> Error:
	DirAccess.make_dir_recursive_absolute("user://save")
	s.version = CURRENT_VERSION
	return ResourceSaver.save(s, SAVE_PATH)

func load_or_create() -> SaveGameResource:
	if not ResourceLoader.exists(SAVE_PATH):
		var fresh := new_save()
		save_game(fresh)
		return fresh

	var s := ResourceLoader.load(SAVE_PATH) as SaveGameResource
	if s == null:
		var fresh := new_save()
		save_game(fresh)
		return fresh

	var changed := _migrate_in_place(s)
	if changed:
		save_game(s) # rewrite in the newest format
	return s

func _migrate_in_place(s: SaveGameResource) -> bool:
	if s.version > CURRENT_VERSION:
		push_error("Save is from a newer game version. Can't safely load.")
		return false

	var changed := false

	# Example: v1 -> v2 introduces unlocked_levels default + bumps version
	# if s.version < 2:
	#	if s.unlocked_levels.is_empty():
	#		s.unlocked_levels = [&"world_map_start"]
	#		changed = true
	#	s.version = 2
	#	changed = true

	# If you had more steps: if s.version < 3: ...; s.version = 3

	return changed
