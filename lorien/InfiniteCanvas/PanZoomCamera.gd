extends Camera2D

# -------------------------------------------------------------------------------------------------
signal zoom_changed(value: float)
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

@onready var _topbar : VBoxContainer = get_node("/root/Main/Topbar")
@onready var _statusbar : Panel = get_node("/root/Main/Statusbar")
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
	
# -------------------------------------------------------------------------------------------------
func reset_to_center():
	offset = Vector2(0.0,0.0)
	emit_signal("position_changed", offset)
	_zoom_canvas(1.0, Vector2(0.0,0.0))
	
# -------------------------------------------------------------------------------------------------
func zoom_to_drawing():
	var max_dim : Vector2 = BrushStroke.MIN_VECTOR2
	var min_dim : Vector2 = BrushStroke.MAX_VECTOR2
	var project: Project = ProjectManager.get_active_project()
	var zoom_steps_x : int = 0
	var zoom_steps_y : int = 0
	var zoom_x : float = 1
	var zoom_y :float = 1
	var final_zoom : float
	var zoomed_viewport_size : Vector2 = get_viewport().size

	print(project.strokes.size())
	if project.strokes.is_empty():
		reset_to_center()
	else:
		#subtract UI size from viewport if it is visible
		if _topbar.visible && _statusbar.visible:
			zoomed_viewport_size.y = zoomed_viewport_size.y-(_topbar.get_rect().size.y+_statusbar.get_rect().size.y)
		for stroke in project.strokes:
			min_dim.x = min(min_dim.x, stroke.top_left_pos.x)
			min_dim.y = min(min_dim.y, stroke.top_left_pos.y)
			max_dim.x = max(max_dim.x, stroke.bottom_right_pos.x)
			max_dim.y = max(max_dim.y, stroke.bottom_right_pos.y)

		var diff_max_dim = Vector2(abs(max_dim.x-min_dim.x), abs(max_dim.y-min_dim.y))

		while diff_max_dim.x > zoomed_viewport_size.x:
			zoomed_viewport_size.x = zoomed_viewport_size.x * 1.1
			zoom_x = zoom_x/1.1
			zoom_steps_x = zoom_steps_x + 1

		while diff_max_dim.y > zoomed_viewport_size.y:
			zoomed_viewport_size.y = zoomed_viewport_size.y * 1.1
			zoom_y = zoom_y/1.1
			zoom_steps_y = zoom_steps_y +1

		if zoom_steps_x > zoom_steps_y:
			final_zoom = zoom_x
		else:
			final_zoom = zoom_y

		var anchor = Vector2(min_dim.x+get_viewport().size.x/2, min_dim.y+get_viewport().size.y/2)

		final_zoom = final_zoom / 1.1
		var center_offset : Vector2
		center_offset.x = ((1/final_zoom)*get_viewport().size.x)-diff_max_dim.x
		center_offset.y = ((1/final_zoom)*(get_viewport().size.y))-diff_max_dim.y

		_zoom_canvas(final_zoom, anchor)
		offset = min_dim
		offset.y = offset.y-((center_offset.y)/2)
		offset.x = offset.x-(center_offset.x/2)
		emit_signal("position_changed", offset)

# -------------------------------------------------------------------------------------------------
func tool_event(event: InputEvent) -> void:
	if _is_input_enabled:
		if event is InputEventKey:
			if Utils.is_action_pressed("canvas_pan_key", event):
				_pan_active = true
			if Utils.is_action_released("canvas_pan_key", event):
				_pan_active = false
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
func _notification(what):
	if what == NOTIFICATION_WM_MOUSE_EXIT:
		_pan_active = false
