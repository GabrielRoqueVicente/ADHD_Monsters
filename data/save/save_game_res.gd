class_name SaveGameResource extends Resource


@export var version : int = 1

@export var current_level: LevelDb.LevelEnum = LevelDb.LevelEnum.LEVEL_2
@export var unlocked_levels: Array[LevelDb.LevelEnum] = [LevelDb.LevelEnum.LEVEL_1, LevelDb.LevelEnum.LEVEL_2]
