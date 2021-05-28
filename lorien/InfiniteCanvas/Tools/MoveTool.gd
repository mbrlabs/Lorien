class_name MoveTool
extends CanvasTool

# ------------------------------------------------------------------------------------------------
const META_OFFSET := "offset"

# ------------------------------------------------------------------------------------------------
var _moving := false

# ------------------------------------------------------------------------------------------------
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_cursor.global_position = xform_vector2(event.global_position)
	
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			_moving = event.pressed
			_offset_selected_strokes(_cursor.global_position)

# ------------------------------------------------------------------------------------------------
func _process(delta: float) -> void:
	if _moving:
		_move_selected_strokes()

# -------------------------------------------------------------------------------------------------
func _offset_selected_strokes(offset: Vector2) -> void:
	var selected_strokes: Array = get_tree().get_nodes_in_group(Types.CANVAS_GROUP_SELECTED_STROKES)
	if selected_strokes.size():
		for stroke in selected_strokes:
			stroke.set_meta(META_OFFSET, stroke.position - offset)

# -------------------------------------------------------------------------------------------------
func _move_selected_strokes() -> void:
	var selected_strokes: Array = get_tree().get_nodes_in_group(Types.CANVAS_GROUP_SELECTED_STROKES)
	if selected_strokes.size():
		for stroke in selected_strokes:
			stroke.global_position = stroke.get_meta(META_OFFSET) + _cursor.global_position
