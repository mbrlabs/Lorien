class_name LineTool
extends CanvasTool

# -------------------------------------------------------------------------------------------------
func _input(event: InputEvent) -> void:
	_cursor.set_pressure(1.0)
	
	if event is InputEventMouseMotion:
		_cursor.global_position = xform_vector2(event.global_position)
		if performing_stroke:
			_cursor.set_pressure(event.pressure)
			remove_last_stroke_point()
			_add_point_at_current_mouse_pos(0.5)
	
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.pressed:
				start_stroke(false)
				_add_point_at_current_mouse_pos(0.5)
				_add_point_at_current_mouse_pos(0.5)
			elif !event.pressed:
				end_stroke()

# -------------------------------------------------------------------------------------------------
func _add_point_at_current_mouse_pos(pressure: float) -> void:
	var brush_position: Vector2 = _cursor.global_position
	pressure = pressure_curve.interpolate(pressure)
	add_stroke_point(brush_position, pressure)
