class_name WorldMap extends Node2D

const ACTION_TO_DIR := {
	"ui_up": Dir.Cardinal.UP,
	"ui_down": Dir.Cardinal.DOWN,
	"ui_left": Dir.Cardinal.LEFT,
	"ui_right": Dir.Cardinal.RIGHT,
}

var _current_level: LevelDb.LevelEnum:
	set(value):
		var pin = _find_pin_by_level(value)
		if pin.disabled: return
		_current_pin = pin 
		_current_level = value
		
var _current_pin: LocationPin:
	set(value):
		_current_pin = value
		if(value):
			value.call_deferred("grab_focus")
		
var _location_pins: Array[Node]

func _ready() -> void:
	_location_pins = $LocationPins.get_children()
	_set_location_pins_state()
	_current_level = GameState.current_level
	
func _unhandled_input(event: InputEvent) -> void:
	for action in ACTION_TO_DIR.keys():
		if event.is_action_pressed(action):
			_move_current_level(ACTION_TO_DIR[action])
			get_viewport().set_input_as_handled()
			return
	
func _move_current_level(dir: Dir.Cardinal):
	match dir:
		Dir.Cardinal.UP:
			if _current_pin.neighbour_top:
				_current_level = _current_pin.neighbour_top
		Dir.Cardinal.DOWN:
			if _current_pin.neighbour_bottom:
				_current_level = _current_pin.neighbour_bottom
		Dir.Cardinal.RIGHT:
			if _current_pin.neighbour_right:
				_current_level = _current_pin.neighbour_right
		Dir.Cardinal.LEFT:
			if _current_pin.neighbour_left:
				_current_level = _current_pin.neighbour_left
	
func _set_location_pins_state():
	for pin in _location_pins:
		if GameState.unlocked_levels.has(pin.level):
			pin.disabled = false
		else:
			pin.disabled = true
			pin.focus_mode = Control.FOCUS_NONE
	
func _find_pin_by_level(level: LevelDb.LevelEnum) -> LocationPin:
	for pin in _location_pins:
		if pin and pin.level == level:
			return pin
	return null
