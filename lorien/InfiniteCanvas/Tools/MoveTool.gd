class_name MoveTool
extends CanvasTool

# ------------------------------------------------------------------------------------------------
var _moving := false

# ------------------------------------------------------------------------------------------------
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_cursor.global_position = xform_vector2(event.global_position)
	
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			_moving = event.pressed
			offset_selected_strokes_by(_cursor.global_position)

# ------------------------------------------------------------------------------------------------
func _process(delta: float) -> void:
	if _moving:
		move_selected_strokes_by(_cursor.global_position)

# -------------------------------------------------------------------------------------------------
func offset_selected_strokes_by(offset_by: Vector2) -> void:
	var selected_strokes: Array = get_tree().get_nodes_in_group(Types.CANVAS_GROUP_SELECTED_STROKES)
	if selected_strokes.size():
		for stroke in selected_strokes:
			stroke.set_meta("offset", stroke.position - offset_by)

# -------------------------------------------------------------------------------------------------
func move_selected_strokes_by(cursor_pos: Vector2) -> void:
	var selected_strokes: Array = get_tree().get_nodes_in_group(Types.CANVAS_GROUP_SELECTED_STROKES)
	if selected_strokes.size():
		for stroke in selected_strokes:
			stroke.global_position = stroke.get_meta("offset") + cursor_pos
