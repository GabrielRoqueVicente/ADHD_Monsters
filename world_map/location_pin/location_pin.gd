class_name LocationPin extends TextureButton

@export var level: LevelDb.LevelEnum

@export_category('Neighbour')
@export var neighbour_top: LevelDb.LevelEnum
@export var neighbour_bottom: LevelDb.LevelEnum
@export var neighbour_left: LevelDb.LevelEnum
@export var neighbour_right: LevelDb.LevelEnum

func _ready() -> void:
	disabled = true

func _on_pressed() -> void:
	LevelLoader.load_level(LevelDb.list[level])

func _on_focus_entered() -> void:
	if disabled:
		return
	$ButtonMashSprite.show()
	$ButtonMashSprite.play("default")
	
func _on_focus_exited() -> void:
	$ButtonMashSprite.stop()
	$ButtonMashSprite.hide()
