class_name SelectionTool
extends CanvasTool

# -------------------------------------------------------------------------------------------------
const META_OFFSET := "offset"

enum State {
	NONE,
	SELECTING,
	MOVING
}

# -------------------------------------------------------------------------------------------------
var _state = State.NONE
var _selecting_start_pos: Vector2 = Vector2.ZERO
var _selecting_end_pos: Vector2 = Vector2.ZERO
var _multi_selecting: bool
var _mouse_moved_during_pressed := false
var _stroke_positions_before_move := {} # BrushStroke -> Vector2

# ------------------------------------------------------------------------------------------------
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			# LMB down - decide if we should select/multiselect or move the selection
			if event.pressed:
				_selecting_start_pos = xform_vector2_relative(event.global_position)
				if event.shift:
					_state = State.SELECTING
					_multi_selecting = true
				elif get_selected_strokes().size() == 0:
					_state = State.SELECTING
					_multi_selecting = false
				else:
					_state = State.MOVING
					_mouse_moved_during_pressed = false
					_offset_selected_strokes(_cursor.global_position)
					for s in get_selected_strokes():
						_stroke_positions_before_move[s] = s.global_position
			# LMB up - stop selection or movement
			else:
				if _state == State.SELECTING:
					_state = State.NONE
					_canvas.update()
				elif _state == State.MOVING:
					_state = State.NONE
					if _mouse_moved_during_pressed:
						_add_undoredo_action_for_moved_strokes()
						_stroke_positions_before_move.clear()
					else:
						deselect_all_strokes()
					_mouse_moved_during_pressed = false
						
		# RMB down - just deselect
		elif event.button_index == BUTTON_RIGHT && event.pressed:
			_state = State.NONE
			deselect_all_strokes()
	
	# Mouse movement: move the selection
	elif event is InputEventMouseMotion:
		_cursor.global_position = xform_vector2(event.global_position)
		if _state == State.SELECTING:
			_selecting_end_pos = xform_vector2_relative(event.global_position)
			compute_selection(_selecting_start_pos, _selecting_end_pos)
			_canvas.update()
		elif _state == State.MOVING:
			_mouse_moved_during_pressed = true
			_move_selected_strokes()

# ------------------------------------------------------------------------------------------------
func compute_selection(start_pos: Vector2, end_pos: Vector2) -> void:
	var rect : Rect2 = Utils.calculate_rect(start_pos, end_pos)
	for stroke in _canvas.get_strokes_in_camera_frustrum():
		# Strokes are selected when the first and last points are in the rect
		var first_point: Vector2 = _get_absolute_stroke_point_pos(stroke.points[0], stroke)
		var last_point: Vector2 = _get_absolute_stroke_point_pos(stroke.points.back(), stroke)
		var is_inside_selection_rect := rect.has_point(first_point) && rect.has_point(last_point)
		_set_stroke_selected(stroke, is_inside_selection_rect)
	_canvas.info.selected_lines = get_selected_strokes().size()

# ------------------------------------------------------------------------------------------------
func _get_absolute_stroke_point_pos(p: Vector2, stroke: BrushStroke) -> Vector2:
	return (p + stroke.position - _canvas.get_camera_offset()) / _canvas.get_camera_zoom()

# ------------------------------------------------------------------------------------------------
func _set_stroke_selected(stroke: BrushStroke, is_inside_rect: bool = true) -> void:
	if is_inside_rect:
		stroke.modulate = Config.DEFAULT_SELECTION_COLOR
		stroke.add_to_group(Types.CANVAS_GROUP_SELECTED_STROKES)
	else:
		if stroke.is_in_group(Types.CANVAS_GROUP_SELECTED_STROKES) && !_multi_selecting:
			stroke.remove_from_group(Types.CANVAS_GROUP_SELECTED_STROKES)
			stroke.modulate = Color.white

# ------------------------------------------------------------------------------------------------
func _add_undoredo_action_for_moved_strokes() -> void:
	var project: Project = ProjectManager.get_active_project()
	project.undo_redo.create_action("Move Strokes")
	for stroke in _stroke_positions_before_move.keys():
		project.undo_redo.add_do_property(stroke, "global_position", stroke.global_position)
		project.undo_redo.add_undo_property(stroke, "global_position", _stroke_positions_before_move[stroke])
	project.undo_redo.commit_action()
	project.dirty = true

# -------------------------------------------------------------------------------------------------
func _offset_selected_strokes(offset: Vector2) -> void:
	for stroke in get_selected_strokes():
		stroke.set_meta(META_OFFSET, stroke.position - offset)

# -------------------------------------------------------------------------------------------------
func _move_selected_strokes() -> void:
	for stroke in get_selected_strokes():
		stroke.global_position = stroke.get_meta(META_OFFSET) + _cursor.global_position

# ------------------------------------------------------------------------------------------------
func deselect_all_strokes() -> void:
	var selected_strokes: Array = get_selected_strokes()
	if selected_strokes.size():
		get_tree().set_group(Types.CANVAS_GROUP_SELECTED_STROKES, "modulate", Color.white)
		for stroke in selected_strokes:
			stroke.remove_from_group(Types.CANVAS_GROUP_SELECTED_STROKES)
	_canvas.info.selected_lines = 0

# ------------------------------------------------------------------------------------------------
func is_selecting() -> bool:
	return _state == State.SELECTING

# ------------------------------------------------------------------------------------------------
func get_selected_strokes() -> Array:
	return get_tree().get_nodes_in_group(Types.CANVAS_GROUP_SELECTED_STROKES)
