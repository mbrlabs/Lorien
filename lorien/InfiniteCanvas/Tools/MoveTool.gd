class_name MoveTool
extends CanvasTool

# ------------------------------------------------------------------------------------------------
var moving := false setget set_moving, is_moving
var offset: Vector2

# ------------------------------------------------------------------------------------------------
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_cursor.global_position = xform_vector2(event.global_position)
	
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			set_moving(event.is_pressed())
			_canvas.offset_selected_lines_by(_cursor.global_position)

# ------------------------------------------------------------------------------------------------
func _process(delta: float) -> void:
	if is_moving():
		_canvas.move_selected_lines_by(_cursor.global_position)

# ------------------------------------------------------------------------------------------------
func set_moving(_moving: bool) -> void:
	moving = _moving

# ------------------------------------------------------------------------------------------------
func is_moving() -> bool:
	return moving
