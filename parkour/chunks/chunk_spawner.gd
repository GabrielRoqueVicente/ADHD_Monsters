extends Node2D

## Spawns chunks dynamically as the camera/player moves forward

@export var chunk_scenes: Array[PackedScene] = []
@export var chunk_width: float = 640.0 # Width of a chunk at scale 1.0
@export var chunk_scale: float = 0.75
@export var spawn_distance: float = 1200.0 # Distance ahead of camera to spawn chunks
@export var despawn_distance: float = 800.0 # Distance behind camera to remove chunks
@export var starting_chunks: int = 5 # Number of chunks to spawn at start

var spawned_chunks: Array[Node2D] = []
var next_spawn_position: float = 0.0
var camera: Camera2D

func _ready() -> void:
	# Find the camera in the scene
	camera = get_viewport().get_camera_2d()
	
	# Spawn initial chunks
	for i in range(starting_chunks):
		spawn_chunk()

func _process(_delta: float) -> void:
	if not camera:
		return
	
	var camera_x = camera.get_screen_center_position().x
	
	# Spawn new chunks ahead
	while next_spawn_position < camera_x + spawn_distance:
		spawn_chunk()
	
	# Despawn chunks that are far behind
	despawn_old_chunks(camera_x)

func spawn_chunk() -> void:
	if chunk_scenes.is_empty():
		push_warning("No chunk scenes assigned to ChunkSpawner!")
		return
	
	# Pick a random chunk from the available scenes
	var chunk_scene = chunk_scenes[randi() % chunk_scenes.size()]
	var chunk = chunk_scene.instantiate() as Node2D
	
	if chunk:
		chunk.position = Vector2(next_spawn_position, 200)
		chunk.scale = Vector2(chunk_scale, chunk_scale)
		add_child(chunk)
		spawned_chunks.append(chunk)
		
		# Update next spawn position
		next_spawn_position += chunk_width * chunk_scale

func despawn_old_chunks(camera_x: float) -> void:
	# Remove chunks that are too far behind the camera
	var chunks_to_remove: Array[Node2D] = []
	
	for chunk in spawned_chunks:
		if chunk.position.x < camera_x - despawn_distance:
			chunks_to_remove.append(chunk)
	
	for chunk in chunks_to_remove:
		spawned_chunks.erase(chunk)
		chunk.queue_free()

func get_last_chunk_position() -> float:
	return next_spawn_position
