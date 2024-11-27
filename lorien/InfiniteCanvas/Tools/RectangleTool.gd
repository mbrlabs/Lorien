class_name RectangleTool
extends CanvasTool

# -------------------------------------------------------------------------------------------------
@export var pressure_curve: Curve
var _start_position_top_left: Vector2

# -------------------------------------------------------------------------------------------------
func tool_event(event: InputEvent) -> void:
	_cursor.set_pressure(1.0)
	var pressure : float = Settings.get_value(
		Settings.GENERAL_TOOL_PRESSURE, 
		Config.DEFAULT_TOOL_PRESSURE
	)
	
	if event is InputEventMouseMotion:
		if performing_stroke:
			_cursor.set_pressure(event.pressure)
			remove_all_stroke_points()
			_make_rectangle(pressure)
		
	# Start + End
	elif event is InputEventMouseButton && !disable_stroke:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				start_stroke()
				_start_position_top_left = _cursor.global_position
				_make_rectangle(pressure)
			elif !event.pressed && performing_stroke:
				remove_all_stroke_points()
				_make_rectangle(pressure)
				end_stroke()

# -------------------------------------------------------------------------------------------------
func _make_rectangle(pressure: float) -> void:
	pressure = pressure_curve.sample(pressure)
	
	var bottom_right_point := _cursor.global_position
	# draw a square if Shift is pressed
	if Input.is_key_pressed(KEY_SHIFT):
		var drag_dir := _cursor.global_position - _start_position_top_left
		bottom_right_point = _start_position_top_left + drag_dir.project(sign(drag_dir))
	var height := bottom_right_point.y - _start_position_top_left.y
	var width := bottom_right_point.x - _start_position_top_left.x
	var top_right_point := _start_position_top_left + Vector2(width, 0)
	var bottom_left_point := _start_position_top_left + Vector2(0, height)
	
	var w_offset := width*0.02
	var h_offset := height*0.02
	
	add_subdivided_line(_start_position_top_left, top_right_point - Vector2(w_offset, 0), pressure)
	add_subdivided_line(top_right_point, bottom_right_point - Vector2(0, h_offset), pressure)
	add_subdivided_line(bottom_right_point, bottom_left_point + Vector2(w_offset, 0), pressure)
	add_subdivided_line(bottom_left_point, _start_position_top_left + Vector2(0, h_offset), pressure)
	add_subdivided_line(_start_position_top_left, _start_position_top_left + Vector2(w_offset, 0), pressure)
