extends Node

signal loading_started(path: String)
signal loading_progress(path: String, progress: float)
signal loading_finished(path: String, level: Node)
signal loading_failed(path: String, error: int)

var _current_level: Node
@export var level_container_path: NodePath = ^"/root/Main/CurrentLevel"

func get_container() -> Node:
	return get_node(level_container_path)

func load_level(path: String, keep_old := false) -> void:
	emit_signal("loading_started", path)

	# Threaded load request
	var err := ResourceLoader.load_threaded_request(path)
	if err != OK:
		emit_signal("loading_failed", path, err)
		return

	var progress := [0.0]
	while true:
		var status := ResourceLoader.load_threaded_get_status(path, progress)
		emit_signal("loading_progress", path, float(progress[0]))

		if status == ResourceLoader.THREAD_LOAD_LOADED:
			break
		if status == ResourceLoader.THREAD_LOAD_FAILED or status == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			emit_signal("loading_failed", path, ERR_CANT_OPEN)
			return

		await get_tree().process_frame

	var packed: PackedScene = ResourceLoader.load_threaded_get(path)
	if packed == null:
		emit_signal("loading_failed", path, ERR_CANT_OPEN)
		return

	var container := get_container()

	if not keep_old and is_instance_valid(_current_level):
		_current_level.queue_free()
		_current_level = null

	var level := packed.instantiate()
	container.add_child(level)
	_current_level = level

	emit_signal("loading_finished", path, level)

func unload_level() -> void:
	if is_instance_valid(_current_level):
		_current_level.queue_free()
		_current_level = null
