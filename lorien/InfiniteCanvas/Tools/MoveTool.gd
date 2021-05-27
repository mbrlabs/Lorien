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
			_canvas.offset_selected_strokes_by(_cursor.global_position)

# ------------------------------------------------------------------------------------------------
func _process(delta: float) -> void:
	if _moving:
		_canvas.move_selected_strokes_by(_cursor.global_position)
