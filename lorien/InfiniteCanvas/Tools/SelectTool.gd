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
func _set_selecting(value: bool) -> void:
	_selecting = value
	if !_selecting:
		_canvas.update()
		_selecting_start_pos = Vector2.ZERO
		_selecting_end_pos = _selecting_start_pos
	else:
		if !multi_selecting:
			deselect_all_strokes()

# ------------------------------------------------------------------------------------------------
func compute_selection(start_pos: Vector2, end_pos: Vector2) -> void:
	var rect : Rect2 = Utils.calculate_rect(start_pos, end_pos)
	for stroke in _canvas.get_strokes_in_camera_frustrum():
		# Strokes are selected when the first and last points are in the rect
		var first_point: Vector2 = _get_absolute_stroke_point_pos(stroke.points[0], stroke)
		var last_point: Vector2 = _get_absolute_stroke_point_pos(stroke.points.back(), stroke)
		var is_inside_selection_rect := rect.has_point(first_point) && rect.has_point(last_point)
		_set_stroke_selected(stroke, is_inside_selection_rect)
	_canvas.info.selected_lines = get_tree().get_nodes_in_group(Types.CANVAS_GROUP_SELECTED_STROKES).size()

# Returns the absolute position of a point in a Line2D through camera parameters
# ------------------------------------------------------------------------------------------------
func _get_absolute_stroke_point_pos(p: Vector2, stroke: BrushStroke) -> Vector2:
	return (p + stroke.position - _canvas.get_camera_offset()) / _canvas.get_camera_zoom()

# ------------------------------------------------------------------------------------------------
func _set_stroke_selected(stroke: BrushStroke, is_inside_rect: bool = true) -> void:
	if is_inside_rect:
		stroke.modulate = Color.rebeccapurple
		stroke.add_to_group(Types.CANVAS_GROUP_SELECTED_STROKES)
	else:
		if stroke.is_in_group(Types.CANVAS_GROUP_SELECTED_STROKES) && !multi_selecting:
			stroke.remove_from_group(Types.CANVAS_GROUP_SELECTED_STROKES)
			stroke.modulate = Color.white

# ------------------------------------------------------------------------------------------------
func deselect_all_strokes() -> void:
	var selected_strokes: Array = get_tree().get_nodes_in_group(Types.CANVAS_GROUP_SELECTED_STROKES)
	if selected_strokes.size():
		get_tree().set_group(Types.CANVAS_GROUP_SELECTED_STROKES, "modulate", Color.white)
		for stroke in selected_strokes:
			stroke.remove_from_group(Types.CANVAS_GROUP_SELECTED_STROKES)
	_canvas.info.selected_lines = 0

# -------------------------------------------------------------
func is_selecting() -> bool:
	return _selecting
