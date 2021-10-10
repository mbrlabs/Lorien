extends Camera2D

signal zoom_changed(value)
signal position_changed(value)

# NOTE: Seems like Krita uses sqrt(2), but that feels a bit high here
# Could be due to my mouse wheel registering twice, though
const ZOOM_INCREMENT := 1.1
const MIN_ZOOM_LEVEL := pow(ZOOM_INCREMENT, -20)
const MAX_ZOOM_LEVEL := 100

var _is_input_enabled := true

var _pan_active := false
var _zoom_active := false

var _current_zoom_level := 1.0
var _start_mouse_pos := Vector2(0.0, 0.0)

# -------------------------------------------------------------------------------------------------
func set_zoom_level(zoom_level: float) -> void:
	_current_zoom_level = _to_nearest_zoom_step(zoom_level)
	zoom = Vector2(_current_zoom_level, _current_zoom_level)

# -------------------------------------------------------------------------------------------------
func _input(event: InputEvent) -> void:
	if _is_input_enabled:
		if event is InputEventMouseButton:
			
			# Scroll wheel up/down to zoom
			if event.button_index == BUTTON_WHEEL_DOWN:
				_do_zoom_scroll(1)
			elif event.button_index == BUTTON_WHEEL_UP:
				_do_zoom_scroll(-1)
			
			# MMB press to begin pan; ctrl+MMB press to begin zoom
			if event.button_index == BUTTON_MIDDLE:
				if !event.control:
					_pan_active = event.is_pressed()
					_zoom_active = false
				else:
					_zoom_active = event.is_pressed()
					_pan_active = false
					_start_mouse_pos = get_local_mouse_position()
					
		elif event is InputEventMouseMotion:
			# MMB drag to pan; ctrl+MMB drag to zoom
			if _pan_active:
				_do_pan(event.relative)
			elif _zoom_active:
				_do_zoom_drag(event.relative.y)

# -------------------------------------------------------------------------------------------------
func _do_pan(pan: Vector2) -> void:
	offset -= pan * _current_zoom_level
	emit_signal("position_changed", offset)

# -------------------------------------------------------------------------------------------------
func _do_zoom_scroll(step: int) -> void:
	# NOTE: This *should* make zooming using scroll after having dragged "snap"
	# to the nearest step, meaning we can always go back to a level of 1.0. 
	# However, my mouse registers twice for each physical step of the wheel, 
	# making this impossible in some cases.
	var new_zoom = _to_nearest_zoom_step(_current_zoom_level) * pow(ZOOM_INCREMENT, step)
	_zoom_canvas(new_zoom, get_local_mouse_position())

# -------------------------------------------------------------------------------------------------
func _do_zoom_drag(delta: float) -> void:
	delta *= _current_zoom_level / 100
	_zoom_canvas(_current_zoom_level + delta, _start_mouse_pos)

# -------------------------------------------------------------------------------------------------
func _zoom_canvas(target_zoom: float, anchor: Vector2) -> void:
	target_zoom = clamp(target_zoom, MIN_ZOOM_LEVEL, MAX_ZOOM_LEVEL)
	
	if target_zoom == _current_zoom_level:
		return

	# Pan canvas to keep content fixed under the cursor
	var zoom_center = anchor - offset
	var ratio = 1.0 - target_zoom/_current_zoom_level
	offset += zoom_center * ratio
	
	_current_zoom_level = target_zoom
	
	zoom = Vector2(_current_zoom_level, _current_zoom_level)
	emit_signal("zoom_changed", _current_zoom_level)

# -------------------------------------------------------------------------------------------------
func _to_nearest_zoom_step(zoom_level: float) -> float:
	zoom_level = clamp(zoom_level, MIN_ZOOM_LEVEL, MAX_ZOOM_LEVEL)
	zoom_level = round(log(zoom_level)/log(ZOOM_INCREMENT))
	return pow(ZOOM_INCREMENT, zoom_level)

# -------------------------------------------------------------------------------------------------
func enable_input() -> void:
	_is_input_enabled = true

# -------------------------------------------------------------------------------------------------

func disable_input() -> void:
	_is_input_enabled = false
# -------------------------------------------------------------------------------------------------
func xform(pos: Vector2) -> Vector2:
	return (pos * zoom) + offset
