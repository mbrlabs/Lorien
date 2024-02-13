extends Camera2D

signal zoom_changed(value)
signal position_changed(value)

const ZOOM_INCREMENT := 1.1 	# Feel free to modify (Krita uses sqrt(2))
const MIN_ZOOM_LEVEL := 0.1
const MAX_ZOOM_LEVEL := 100
const KEYBOARD_PAN_CONSTANT := 20

var _is_input_enabled := true

var _pan_active := false
var _zoom_active := false

var _current_zoom_level := 1.0
var _start_mouse_pos := Vector2(0.0, 0.0)

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
	var screen_space_center := get_viewport().get_size() / 2
	var delta := screen_space_center - screen_space_center_point
	get_viewport().warp_mouse(screen_space_center)
	_do_pan(delta)

# -------------------------------------------------------------------------------------------------
func _process(delta):
	_touch_events
	pass
	
# -------------------------------------------------------------------------------------------------
func touch_event(event):
		# Keep track of the fingers on the screen
		if event is InputEventScreenTouch:
			if event.pressed:
				_touch_events[event.index] = event
				_multidrag_valid = false
			else:
				_touch_events.erase(event.index)
				#_touch_last_drag_distance = 0
			get_tree().set_input_as_handled()
			
		if event is InputEventScreenDrag:
			_touch_events[event.index] = event
			# At least one finger to drag
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
				median_point = get_canvas_transform().affine_inverse().xform(median_point)
				median_point = get_global_transform().affine_inverse().xform(median_point)
				
				var drag_distance = events[0].position.distance_to(events[1].position)
				var delta = -(drag_distance - _touch_last_drag_distance) * _current_zoom_level / 800
				if _multidrag_valid:
					_zoom_canvas(_current_zoom_level + delta, median_point)
				_touch_last_drag_distance = drag_distance
				_multidrag_valid = true
			get_tree().set_input_as_handled()

func _input(event):
	touch_event(event)

# -------------------------------------------------------------------------------------------------
func tool_event(event: InputEvent) -> void:
	if _is_input_enabled:
		if event is InputEventMouseButton:
			
			# Scroll wheel up/down to zoom
			if event.button_index == BUTTON_WHEEL_DOWN:
				if event.pressed:
					_do_zoom_scroll(1)
			elif event.button_index == BUTTON_WHEEL_UP:
				if event.pressed:
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
		
		elif Utils.event_pressed_bug_workaround("canvas_zoom_in", event):
			_do_zoom_scroll(-1)
			get_tree().set_input_as_handled()
		
		elif Utils.event_pressed_bug_workaround("canvas_zoom_out", event):
			_do_zoom_scroll(1)
			get_tree().set_input_as_handled()
		
		elif Utils.event_pressed_bug_workaround("canvas_pan_left", event):
			_do_pan(-Vector2.LEFT * KEYBOARD_PAN_CONSTANT)
			get_tree().set_input_as_handled()

		elif Utils.event_pressed_bug_workaround("canvas_pan_right", event):
			_do_pan(-Vector2.RIGHT * KEYBOARD_PAN_CONSTANT)
			get_tree().set_input_as_handled()

		elif Utils.event_pressed_bug_workaround("canvas_pan_up", event):
			_do_pan(-Vector2.UP * KEYBOARD_PAN_CONSTANT)
			get_tree().set_input_as_handled()

		elif Utils.event_pressed_bug_workaround("canvas_pan_down", event):
			_do_pan(-Vector2.DOWN * KEYBOARD_PAN_CONSTANT)
			get_tree().set_input_as_handled()

# -------------------------------------------------------------------------------------------------
func _do_pan(pan: Vector2) -> void:
	offset -= pan * _current_zoom_level
	emit_signal("position_changed", offset)

# -------------------------------------------------------------------------------------------------
func _do_zoom_scroll(step: int) -> void:
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
	var ratio = 1.0 - target_zoom / _current_zoom_level
	offset += zoom_center * ratio
	
	_current_zoom_level = target_zoom
	
	zoom = Vector2(_current_zoom_level, _current_zoom_level)
	emit_signal("zoom_changed", _current_zoom_level)

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
