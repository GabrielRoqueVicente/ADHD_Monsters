extends Node

var save: SaveGameResource

var current_level: LevelDb.LevelEnum
var unlocked_levels: Array[LevelDb.LevelEnum] = []

func _ready() -> void:
	# Load save (or create a new one) and hydrate runtime variables
	save = SaveManager.load_or_create()
	_hydrate_from_save(save)

func _hydrate_from_save(s: SaveGameResource) -> void:
	current_level = s.current_level
	unlocked_levels = s.unlocked_levels.duplicate()
