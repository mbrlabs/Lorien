extends Camera2D

signal zoom_changed(value)
signal position_changed(value)

const MAX_MOUSE_WHEEL_LEVEL := 99
const MIN_MOUSE_WHEEL_LEVEL := -8
const ZOOM_INCREMENT = 0.1

export var zoom_curve: Curve

var _current_zoom_level := 1.0
var _pan_active := false
var _is_input_enabled := true

var _mouse_wheel_counter := 0

# -------------------------------------------------------------------------------------------------
func set_zoom_level(zoom_level: float) -> void:
	_current_zoom_level = 1.0
	_mouse_wheel_counter = 0
	
	if !is_equal_approx(zoom_level, 1.0):
		var wheel_direction := -1 if (zoom_level < 1.0) else 1
		
		while true:
			_mouse_wheel_counter += wheel_direction
			_current_zoom_level = 1.0 + _mouse_wheel_counter * _calc_zoom_increment()
			
			if wheel_direction < 0:
				if _current_zoom_level <= zoom_level:
					break
			else:
				if _current_zoom_level >= zoom_level:
					break
	zoom = Vector2(_current_zoom_level, _current_zoom_level)

# -------------------------------------------------------------------------------------------------
func _input(event: InputEvent) -> void:
	if _is_input_enabled:
		if event is InputEventMouseButton:
			if event.pressed:
				if event.button_index == BUTTON_WHEEL_DOWN:
					_mouse_wheel_counter += 1
					_do_zoom()
				elif event.button_index == BUTTON_WHEEL_UP:
					_mouse_wheel_counter -= 1
					_do_zoom()
			if event.button_index == BUTTON_MIDDLE:
				_pan_active = event.is_pressed()
		elif event is InputEventMouseMotion:
			if _pan_active:
				_do_pan(event.relative)

# -------------------------------------------------------------------------------------------------
func _do_pan(pan: Vector2) -> void:
	offset -= pan * _current_zoom_level
	emit_signal("position_changed", offset)

# -------------------------------------------------------------------------------------------------
func _do_zoom() -> void:
	var anchor := get_local_mouse_position()

	var old_zoom := _current_zoom_level
	if _mouse_wheel_counter <= MIN_MOUSE_WHEEL_LEVEL:
		_mouse_wheel_counter = MIN_MOUSE_WHEEL_LEVEL
	elif _mouse_wheel_counter >= MAX_MOUSE_WHEEL_LEVEL:
		_mouse_wheel_counter = MAX_MOUSE_WHEEL_LEVEL
	_current_zoom_level = 1.0 + _mouse_wheel_counter * _calc_zoom_increment()
	
	if old_zoom == _current_zoom_level:
		return
	
	var zoom_center = anchor - offset
	var ratio = 1.0 - _current_zoom_level/old_zoom
	offset += zoom_center * ratio
	
	zoom = Vector2(_current_zoom_level, _current_zoom_level)
	emit_signal("zoom_changed", _current_zoom_level)

# -------------------------------------------------------------------------------------------------
func _calc_zoom_increment() -> float:
	var progress: float = _mouse_wheel_counter + abs(MIN_MOUSE_WHEEL_LEVEL)
	progress /= (abs(MIN_MOUSE_WHEEL_LEVEL) + MAX_MOUSE_WHEEL_LEVEL)
	return zoom_curve.interpolate(progress)

# -------------------------------------------------------------------------------------------------
func enable_intput() -> void:
	_is_input_enabled = true

# -------------------------------------------------------------------------------------------------
func disable_intput() -> void:
	_is_input_enabled = false

# -------------------------------------------------------------------------------------------------
func xform(pos: Vector2) -> Vector2:
	return (pos * zoom) + offset
