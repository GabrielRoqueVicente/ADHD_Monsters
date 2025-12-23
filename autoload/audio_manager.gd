extends Node

# Audio buses
const BUS_MASTER = "Master"
const BUS_MUSIC = "Music"
const BUS_SFX = "SFX"

# Audio players pool
var _sfx_players: Array[AudioStreamPlayer] = []
var _music_player: AudioStreamPlayer
var _current_music: AudioStream

@export var max_sfx_players := 16  # Maximum simultaneous sound effects

func _ready() -> void:
	# Create music player
	_music_player = AudioStreamPlayer.new()
	_music_player.bus = BUS_MUSIC
	add_child(_music_player)
	
	# Create SFX player pool
	for i in max_sfx_players:
		var player = AudioStreamPlayer.new()
		player.bus = BUS_SFX
		add_child(player)
		_sfx_players.append(player)

## Play a sound effect
## Returns the AudioStreamPlayer used (null if none available)
func play_sfx(sound: AudioStream, volume_db := 0.0, pitch_scale := 1.0) -> AudioStreamPlayer:
	var player = _get_available_sfx_player()
	if not player:
		push_warning("No available SFX player")
		return null
	
	player.stream = sound
	player.volume_db = volume_db
	player.pitch_scale = pitch_scale
	player.play()
	return player

## Play music (replaces current music)
func play_music(music: AudioStream, volume_db := 0.0, fade_in_duration := 0.0) -> void:
	if _current_music == music and _music_player.playing:
		return  # Already playing this music
	
	_current_music = music
	_music_player.stream = music
	
	if fade_in_duration > 0.0:
		_music_player.volume_db = -80.0
		_music_player.play()
		var tween = create_tween()
		tween.tween_property(_music_player, "volume_db", volume_db, fade_in_duration)
	else:
		_music_player.volume_db = volume_db
		_music_player.play()

## Stop music with optional fade out
func stop_music(fade_out_duration := 0.0) -> void:
	if fade_out_duration > 0.0:
		var tween = create_tween()
		tween.tween_property(_music_player, "volume_db", -80.0, fade_out_duration)
		tween.tween_callback(_music_player.stop)
	else:
		_music_player.stop()
	_current_music = null

## Stop all sound effects
func stop_all_sfx() -> void:
	for player in _sfx_players:
		player.stop()

## Set volume for a bus (0.0 to 1.0)
func set_bus_volume(bus_name: String, volume: float) -> void:
	var bus_idx = AudioServer.get_bus_index(bus_name)
	if bus_idx >= 0:
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(volume))

## Mute/unmute a bus
func set_bus_mute(bus_name: String, mute: bool) -> void:
	var bus_idx = AudioServer.get_bus_index(bus_name)
	if bus_idx >= 0:
		AudioServer.set_bus_mute(bus_idx, mute)

## Get an available SFX player from the pool
func _get_available_sfx_player() -> AudioStreamPlayer:
	for player in _sfx_players:
		if not player.playing:
			return player
	return null
