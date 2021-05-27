class_name SelectTool
extends CanvasTool

var _selecting: bool
var _selecting_start_pos: Vector2 = Vector2.ZERO
var _selecting_end_pos: Vector2 = Vector2.ZERO
var multi_selecting : bool

# ------------------------------------------------------------------------------------------------
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if !is_selecting():
				if event.is_pressed():
					_selecting_start_pos = xform_vector2_relative(event.global_position)
			_set_selecting(event.is_pressed())
	
	if event is InputEventKey:
		if event.scancode == KEY_SHIFT:
			multi_selecting = event.pressed
	
	if event is InputEventMouseMotion:
		_cursor.global_position = xform_vector2(event.global_position)
		if is_selecting():
			_selecting_end_pos = xform_vector2_relative(event.global_position)
			compute_selection(_selecting_start_pos, _selecting_end_pos)
			_canvas.update()

# ------------------------------------------------------------------------------------------------
func _confirm_selections() -> void:
	for stroke in get_tree().get_nodes_in_group(Types.CANVAS_GROUP_SELECTED_STROKES):
		stroke.set_meta("was_selected", true)

# ------------------------------------------------------------------------------------------------
func _set_selecting(value: bool) -> void:
	_selecting = value
	if !_selecting:
		_canvas.update()
		_selecting_start_pos = Vector2.ZERO
		_selecting_end_pos = _selecting_start_pos
		_confirm_selections()
	else:
		if !multi_selecting:
			deselect_all_strokes()

# Check if a stroke is inside the selection rectangle
# For performance reasons && implementation ease, to consider a stroke inside the selection rectangle the first && last points of the Line2D should be inside it
# ------------------------------------------------------------------------------------------------
func compute_selection(start_pos: Vector2, end_pos: Vector2) -> void:
	var rect : Rect2 = Utils.calculate_rect(start_pos, end_pos)
	for stroke in _canvas.get_strokes_in_camera_frustrum():
		var first_point: Vector2 = _get_absolute_stroke_point_pos(stroke.points[0], stroke)
		var last_point: Vector2 = _get_absolute_stroke_point_pos(stroke.points.back(), stroke)
		_set_stroke_selected(stroke, rect.has_point(first_point) && rect.has_point(last_point))
		
	# TODO: add this info back in?
	#info.selected_lines = get_tree().get_nodes_in_group(Types.CANVAS_GROUP_SELECTED_STROKES).size()
	_canvas.info.selected_lines = get_tree().get_nodes_in_group(Types.CANVAS_GROUP_SELECTED_STROKES).size()

# Returns the absolute position of a point in a Line2D through camera parameters
# ------------------------------------------------------------------------------------------------
func _get_absolute_stroke_point_pos(p: Vector2, stroke: BrushStroke) -> Vector2:
	return (p + stroke.position - _canvas.get_camera_offset()) / _canvas.get_camera_zoom()

# Sets a stroke selected or not, adding it to a group
# This will facilitate managing only selected line2ds, without computing any operation on non-selected ones
# ------------------------------------------------------------------------------------------------
func _set_stroke_selected(stroke: BrushStroke, is_inside_rect: bool = true) -> void:
	if is_inside_rect:
		stroke.modulate = Color.rebeccapurple
		stroke.add_to_group(Types.CANVAS_GROUP_SELECTED_STROKES)
	else:
		if stroke.is_in_group(Types.CANVAS_GROUP_SELECTED_STROKES):
			if !stroke.has_meta("was_selected"):
				stroke.modulate = Color.white
				stroke.remove_from_group(Types.CANVAS_GROUP_SELECTED_STROKES)

# ------------------------------------------------------------------------------------------------
func _deselect_stroke(stroke: BrushStroke) -> void:
	stroke.set_meta("was_selected", null)
	stroke.remove_from_group(Types.CANVAS_GROUP_SELECTED_STROKES)

# ------------------------------------------------------------------------------------------------
func deselect_all_strokes() -> void:
	var selected_strokes: Array = get_tree().get_nodes_in_group(Types.CANVAS_GROUP_SELECTED_STROKES)
	if selected_strokes.size():
		get_tree().set_group(Types.CANVAS_GROUP_SELECTED_STROKES, "modulate", Color.white)
		for stroke in selected_strokes:
			_deselect_stroke(stroke)
	
	# TODO: add this info back in?
	#info.selected_lines = 0
	_canvas.info.selected_lines = 0

# -------------------------------------------------------------
func is_selecting() -> bool:
	return _selecting

