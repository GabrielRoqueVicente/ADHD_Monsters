extends CharacterBody2D

@export_group("Jump")
@export var jump_velocity := -380.0
@export var coyote_time := 0.12 # Jump after leaving the floor (0.08 → 0.15 seconds)
@export var jump_buffer_time := 0.10  # Buffer jump to trigger on landing (0.08 → 0.12 seconds)

@export_group("Run")
@export var min_speed: float = 40.0
@export var max_speed: float = 620.0
@export var accel: float = 20.0
@export var brake: float = 900.0

@export_group("Animation")
@export var sprint_threshold: float = 320.0
@export var min_anim_scale: float = 0.8
@export var max_anim_scale: float = 1.6

var speed_x: float
var coyote_timer :float
var jump_buffer_timer :float
var run_anim_speed : float

var jumped := false

@export_group("Hit")
@export var invincible_time := 0.8
@export var blink_interval := 0.08
@export var flash_red_time := 0.4

var _invincible := false
var _hit_tween: Tween

@onready var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready() -> void:
	speed_x = min_speed

func _physics_process(delta: float) -> void:
	if is_on_floor():
		coyote_timer = coyote_time
	else:
		coyote_timer = maxf(0.0, coyote_timer - delta)

	if Input.is_action_just_pressed("ui_accept"):
		jump_buffer_timer = jump_buffer_time
	else:
		jump_buffer_timer = maxf(0.0, jump_buffer_timer - delta)
		
# --- horizontal speed control ---
	var braking := Input.is_action_pressed("ui_left") # create Input action "brake"
	if braking:
		speed_x = maxf(min_speed, speed_x - brake * delta)
	elif is_on_floor():
		speed_x = minf(max_speed, speed_x + accel * delta)

	velocity.x = speed_x

	# --- Gravity ---
	if not is_on_floor():
		velocity.y += gravity * delta

	# --- Jump (buffer + coyote) ---
	if jump_buffer_timer > 0.0 and coyote_timer > 0.0:
		velocity.y = jump_velocity
		jump_buffer_timer = 0.0
		coyote_timer = 0.0
		jumped = true

	move_and_slide()

# --- Animation selection
	if not is_on_floor():
		if jumped:
			$AnimatedSprite2D.play("jump" , 1)
			jumped = false
	else:
		run_anim_speed =  lerpf(
			min_anim_scale,
			max_anim_scale,
			inverse_lerp(min_speed, max_speed, speed_x)
		)
		var run_anim := "run" if speed_x <= sprint_threshold else "sprint"
		$AnimatedSprite2D.speed_scale = run_anim_speed
		if $AnimatedSprite2D.animation != run_anim:
			$AnimatedSprite2D.play(run_anim)

func on_hit_reset_speed():
	speed_x = min_speed
	velocity.x = speed_x
	_play_hit_fx()
	
func _play_hit_fx() -> void:
	if _invincible:
		return

	_invincible = true
	
	var sprite = $AnimatedSprite2D

	# Stop previous tween cleanly (prevents stacking bugs)
	if _hit_tween and _hit_tween.is_valid():
		_hit_tween.kill()

	# --- 1) Flash red quickly (color tint) ---
	sprite.visible = true
	sprite.modulate = Color.WHITE

	_hit_tween = create_tween()
	_hit_tween.tween_property(sprite, "modulate", Color(1, 0.2, 0.2, 1), flash_red_time * 0.5)
	_hit_tween.tween_property(sprite, "modulate", Color(1, 1, 1, 1), flash_red_time * 0.5)

	# --- 2) Blink during invincibility ---
	var elapsed := 0.0
	while elapsed < invincible_time:
		sprite.visible = not sprite.visible
		await get_tree().create_timer(blink_interval).timeout
		elapsed += blink_interval

	# Restore
	sprite.visible = true
	sprite.modulate = Color.WHITE
	_invincible = false
