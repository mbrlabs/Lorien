class_name SelectTool
extends CanvasTool

var selecting: bool = false setget set_selecting, is_selecting
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
			set_selecting(event.is_pressed())
	
	if event is InputEventKey:
		if event.scancode == KEY_SHIFT:
			multi_selecting = event.pressed
	
	if event is InputEventMouseMotion:
		_cursor.global_position = xform_vector2(event.global_position)
		if is_selecting():
			_selecting_end_pos = xform_vector2_relative(event.global_position)
			_canvas.compute_selection(_selecting_start_pos, _selecting_end_pos)
			_canvas.update()

# ------------------------------------------------------------------------------------------------
func set_selecting(value: bool) -> void:
	selecting = value
	if !selecting:
		_canvas.update()
		_selecting_start_pos = Vector2.ZERO
		_selecting_end_pos = _selecting_start_pos
		_canvas.confirm_selections()
	else:
		if !multi_selecting:
			_canvas.deselect_all_line2d()

# -------------------------------------------------------------
func is_selecting() -> bool:
	return selecting

