class_name Claw extends Node2D

signal creature_captured(creature: Node2D)

@export var max_range := 500.0
@export var claw_speed := 800.0
@export var hook_color := Color(0.8, 0.8, 0.8)
@export var rope_width := 2.0

var is_grappling := false
var grapple_target: Vector2
var hook_position: Vector2
var hit_creature: Node2D
var track_crosshair := true # Whether to update target to mouse position

@onready var line: Line2D = $Rope
@onready var hook_sprite: Sprite2D = $ClawSprite

func _ready() -> void:
	line.default_color = hook_color
	line.width = rope_width
	line.visible = false
	hook_sprite.visible = false

func _physics_process(delta: float) -> void:
	if is_grappling:
		_update_grapple(delta)
	
	# Update line from player to hook in global coordinates
	if line.visible:
		line.clear_points()
		line.add_point(to_local(global_position)) # Start at claw position
		line.add_point(to_local(hook_position)) # End at hook position

func shoot_grapple(target_pos: Vector2) -> bool:
	if is_grappling:
		return false
	
	var distance = global_position.distance_to(target_pos)
	if distance > max_range:
		target_pos = global_position + (target_pos - global_position).normalized() * max_range
	
	grapple_target = target_pos
	hook_position = global_position
	is_grappling = true
	line.visible = true
	hook_sprite.visible = true
	hit_creature = null
	
	return true

func _update_grapple(delta: float) -> void:
	# Update target to current mouse position if tracking
	if track_crosshair:
		var mouse_pos = get_global_mouse_position()
		var distance = global_position.distance_to(mouse_pos)
		if distance > max_range:
			grapple_target = global_position + (mouse_pos - global_position).normalized() * max_range
		else:
			grapple_target = mouse_pos
	
	var direction = (grapple_target - hook_position).normalized()
	var distance_to_target = hook_position.distance_to(grapple_target)
	
	if distance_to_target < claw_speed * delta:
		# Reached target
		hook_position = grapple_target
		_check_creature_hit()
		_retract_grapple()
	else:
		# Move hook toward target
		hook_position += direction * claw_speed * delta
		hook_sprite.global_position = hook_position
		_check_creature_hit()

func _check_creature_hit() -> void:
	if hit_creature:
		return # Already hit something
	
	# Check for creatures in range of the hook
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = hook_position
	query.collide_with_areas = true
	query.collision_mask = 0b0100 # Layer 3 for creatures (adjust as needed)
	
	var results = space_state.intersect_point(query, 1)
	if results.size() > 0:
		var creature = results[0].collider
		if creature.is_in_group("creatures"):
			hit_creature = creature
			creature_captured.emit(creature)
			_retract_grapple()

func _retract_grapple() -> void:
	is_grappling = false
	line.visible = false
	hook_sprite.visible = false

func cancel_grapple() -> void:
	if is_grappling:
		_retract_grapple()
