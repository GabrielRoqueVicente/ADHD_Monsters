class_name Claw extends Node2D

signal creature_captured(creature: Node2D)

@export var extend_time := 0.3 # Time in seconds for claw to reach target
@export var retract_time := 0.2 # Time in seconds for claw to return
@export var hook_color := Color(0.8, 0.8, 0.8)
@export var rope_width := 2.0

var is_grappling := false
var grapple_target: Vector2
var hook_position: Vector2
var hit_creature: Node2D
var track_crosshair := true # Whether to update target to mouse position
var is_retracting := false # Whether claw is coming back
var grapple_timer := 0.0 # Time elapsed since grapple started
var grapple_start_pos: Vector2 # Where the player was when grapple started
var initial_distance := 0.0 # Distance to target when grapple starts

@onready var line: Line2D = $Rope
@onready var hook_sprite: Sprite2D = $ClawSprite

func _ready() -> void:
	line.default_color = hook_color
	line.width = rope_width
	line.visible = false
	hook_sprite.visible = false

func _process(delta: float) -> void:
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
	
	grapple_target = target_pos
	hook_position = global_position
	grapple_start_pos = global_position
	is_grappling = true
	is_retracting = false
	grapple_timer = 0.0
	line.visible = true
	hook_sprite.visible = true
	hit_creature = null
	initial_distance = distance
	
	return true

func _update_grapple(delta: float) -> void:
	grapple_timer += delta
	
	var total_time = extend_time + retract_time
	
	# Force complete if time exceeded
	if grapple_timer >= total_time:
		_finish_retract()
		return
	
	if grapple_timer < extend_time:
		# Extending phase: interpolate from start to current mouse position
		# Update target to track mouse during extension
		if track_crosshair:
			var mouse_pos = get_global_mouse_position()
			grapple_target = mouse_pos
		
		var t = grapple_timer / extend_time
		hook_position = grapple_start_pos.lerp(grapple_target, t)
		hook_sprite.global_position = hook_position
		_check_creature_hit()
		
		if not is_retracting and t >= 1.0:
			is_retracting = true
	else:
		# Retracting phase: interpolate from target back to player
		var retract_progress = (grapple_timer - extend_time) / retract_time
		hook_position = grapple_target.lerp(global_position, retract_progress)
		hook_sprite.global_position = hook_position
		
		if retract_progress >= 1.0:
			_finish_retract()

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
			_finish_retract()

func _finish_retract() -> void:
	is_grappling = false
	is_retracting = false
	line.visible = false
	hook_sprite.visible = false

func cancel_grapple() -> void:
	if is_grappling:
		_finish_retract()
