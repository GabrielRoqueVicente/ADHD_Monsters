class_name CrossHair extends Sprite2D

@export var reticle_color := Color(1.0, 1.0, 1.0, 0.7)
@export var out_of_range_color := Color(1.0, 0.3, 0.3, 0.5)
@export var max_range := 500.0

var player: CharacterBody2D

func _ready() -> void:
	modulate = reticle_color
	# Find player in parent hierarchy
	var current = get_parent()
	while current and not current is CharacterBody2D:
		current = current.get_parent()
	player = current as CharacterBody2D
	
	# Hide system mouse cursor
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	
	# Set to process even when paused
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(_delta: float) -> void:
	# Position reticle at mouse position in world space
	global_position = get_global_mouse_position()
	
	# Change color if out of range
	if player:
		var distance = player.global_position.distance_to(global_position)
		if distance > max_range:
			modulate = out_of_range_color
		else:
			modulate = reticle_color
