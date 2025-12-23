extends Node

enum LevelEnum {
	NA,
	LEVEL_1,
	LEVEL_2,
	LEVEL_3,
	LEVEL_4,
	LEVEL_5,
	LEVEL_6,
	LEVEL_7,
	LEVEL_8,
	LEVEL_9,
	LEVEL_10,
	LEVEL_11,
}

@export var list: Dictionary = {
	LevelEnum.NA: null,
	LevelEnum.LEVEL_1: "res://parkour/levels/level_01.tscn",
	LevelEnum.LEVEL_2: "res://parkour/levels/level_01.tscn",
	LevelEnum.LEVEL_3: "",
	LevelEnum.LEVEL_4: "",
	LevelEnum.LEVEL_5: "",
	LevelEnum.LEVEL_6: "",
	LevelEnum.LEVEL_7: "",
	LevelEnum.LEVEL_8: "",
	LevelEnum.LEVEL_9: "",
	LevelEnum.LEVEL_10: "",
	LevelEnum.LEVEL_11: ""
}
