extends Camera2D

# -------------------------------------------------------------------------------------------------
signal zooming_toggled(value: bool)
signal zoom_changed(value: float)
signal panning_toggled(value: bool)
signal position_changed(value: Vector2)

# -------------------------------------------------------------------------------------------------
const ZOOM_INCREMENT := 1.1
const MIN_ZOOM_LEVEL := 0.1
const MAX_ZOOM_LEVEL := 100
const KEYBOARD_PAN_CONSTANT := 20

# -------------------------------------------------------------------------------------------------
var _is_input_enabled := true
var _pan_active := false
var _zoom_active := false
var _current_zoom_level := 1.0
var _start_mouse_pos := Vector2(0.0, 0.0)

# -------------------------------------------------------------------------------------------------
var _touch_events = {}
var _touch_last_drag_distance := 0.0
var _touch_last_drag_median := Vector2.ZERO
var _multidrag_valid = false

# -------------------------------------------------------------------------------------------------
func set_zoom_level(zoom_level: float) -> void:
	_current_zoom_level = _to_nearest_zoom_step(zoom_level)
	zoom = Vector2(_current_zoom_level, _current_zoom_level)

# -------------------------------------------------------------------------------------------------
func do_center(screen_space_center_point: Vector2) -> void:
	#var screen_space_center := get_viewport().get_size() / 2
	
	# TODO(gd4): no idea if this is the eqivialnt of the above line
	var screen_space_center := Vector2(DisplayServer.window_get_size().x, DisplayServer.window_get_size().y)
	
	var delta := screen_space_center - screen_space_center_point
	get_viewport().warp_mouse(screen_space_center)
	_do_pan(delta)
	
	
func touch_event(event):
	# Keep track of the fingers on the screen
	if event is InputEventScreenTouch:
		if event.pressed:
			_touch_events[event.index] = event
			_multidrag_valid = false
		else:
			_touch_events.erase(event.index)
			#_touch_last_drag_distance = 0
		get_viewport().set_input_as_handled()

	if event is InputEventScreenDrag:
		_touch_events[event.index] = event
		# At least one fing drag
		if _touch_events.size() == 1:
			_do_pan(event.relative)
		if _touch_events.size() == 2:
			var events = []
			for key in _touch_events.keys():
				events.append(_touch_events.get(key))

			var median_point = Vector2.ZERO
			for e in events:
				median_point += e.position
			median_point /= events.size()
			if _multidrag_valid:
				_do_pan(median_point - _touch_last_drag_median)
			_touch_last_drag_median = median_point
			median_point = get_canvas_transform().affine_inverse() * median_point
			median_point = get_global_transform().affine_inverse() * median_point

			var drag_distance = events[0].position.distance_to(events[1].position)
			var delta = (drag_distance - _touch_last_drag_distance) * _current_zoom_level / 800
			if _multidrag_valid:
				_zoom_canvas(_current_zoom_level + delta, median_point)
			_touch_last_drag_distance = drag_distance
			_multidrag_valid = true
		get_viewport().set_input_as_handled()

func _input(event):
	touch_event(event)

# -------------------------------------------------------------------------------------------------
func tool_event(event: InputEvent) -> void:
	if _is_input_enabled:
		if event is InputEventKey:
			if Utils.is_action_pressed("canvas_pan_key", event):
				_pan_active = true
				panning_toggled.emit(true)
			if Utils.is_action_released("canvas_pan_key", event):
				_pan_active = false
				panning_toggled.emit(false)
		if event is InputEventMouseButton:
			
			# Scroll wheel up/down to zoom
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				if event.pressed:
					_do_zoom_scroll(-1)
			elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
				if event.pressed:
					_do_zoom_scroll(1)
			
			# MMB press to begin pan; ctrl+MMB press to begin zoom
			if event.button_index == MOUSE_BUTTON_MIDDLE:
				if !event.ctrl_pressed:
					_pan_active = event.is_pressed()
					panning_toggled.emit(_pan_active)
					_zoom_active = false
					zooming_toggled.emit(false)
				else:
					_zoom_active = event.is_pressed()
					zooming_toggled.emit(_zoom_active)
					_pan_active = false
					panning_toggled.emit(false)
					_start_mouse_pos = get_local_mouse_position()
					
		elif event is InputEventMouseMotion:
			# MMB drag to pan; ctrl+MMB drag to zoom
			if _pan_active:
				_do_pan(event.relative)
			elif _zoom_active:
				_do_zoom_drag(event.relative.y)

# -------------------------------------------------------------------------------------------------
func _do_pan(pan: Vector2) -> void:
	offset -= pan * (1.0 / _current_zoom_level)
	position_changed.emit(offset)

# -------------------------------------------------------------------------------------------------
func _do_zoom_scroll(step: int) -> void:
	var new_zoom := _to_nearest_zoom_step(_current_zoom_level) * pow(ZOOM_INCREMENT, step)
	_zoom_canvas(new_zoom, get_local_mouse_position())

# -------------------------------------------------------------------------------------------------
func _do_zoom_drag(delta: float) -> void:
	delta *= _current_zoom_level / 100
	_zoom_canvas(_current_zoom_level - delta, _start_mouse_pos)

# -------------------------------------------------------------------------------------------------
func _zoom_canvas(target_zoom: float, anchor: Vector2) -> void:
	target_zoom = clamp(target_zoom, MIN_ZOOM_LEVEL, MAX_ZOOM_LEVEL)
	
	if target_zoom == _current_zoom_level:
		return

	# Pan canvas to keep content fixed under the cursor
	var zoom_center := anchor - offset
	var ratio := _current_zoom_level / target_zoom - 1.0
	offset -= zoom_center * ratio
	
	_current_zoom_level = target_zoom
	
	zoom = Vector2(_current_zoom_level, _current_zoom_level)
	zoom_changed.emit(_current_zoom_level)

# -------------------------------------------------------------------------------------------------
func _to_nearest_zoom_step(zoom_level: float) -> float:
	zoom_level = clamp(zoom_level, MIN_ZOOM_LEVEL, MAX_ZOOM_LEVEL)
	zoom_level = round(log(zoom_level) / log(ZOOM_INCREMENT))
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

#--------------------------------------------------------------------------------------------------
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_MOUSE_EXIT:
		_pan_active = false
