class_name RectangleTool
extends CanvasTool

const PRESSURE_MULTIPLIER := 0.25

# -------------------------------------------------------------------------------------------------
export var pressure_curve: Curve
var _start_position_top_left: Vector2

# -------------------------------------------------------------------------------------------------
func _input(event: InputEvent) -> void:
	_cursor.set_pressure(1.0)
	
	if event is InputEventMouseMotion:
		_cursor.global_position = xform_vector2(event.global_position)
		if performing_stroke:
			_cursor.set_pressure(event.pressure)
			remove_all_stroke_points()
			_make_rectangle(PRESSURE_MULTIPLIER)
		
	# Start + End
	elif event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.pressed:
				start_stroke(false)
				_start_position_top_left = _cursor.global_position
				_make_rectangle(PRESSURE_MULTIPLIER)
			elif !event.pressed:
				remove_all_stroke_points()
				_make_rectangle(PRESSURE_MULTIPLIER)
				end_stroke()

# -------------------------------------------------------------------------------------------------
func _add_point_at_mouse_pos(pressure: float) -> Vector2:
	var brush_position: Vector2 = _cursor.global_position
	pressure = pressure_curve.interpolate(pressure)
	add_stroke_point(brush_position, pressure)
	return brush_position

# -------------------------------------------------------------------------------------------------
func _make_rectangle(pressure: float) -> void:
	var bottom_right_point := _cursor.global_position
	var height := bottom_right_point.y - _start_position_top_left.y
	var width := bottom_right_point.x - _start_position_top_left.x
	var top_right_point := _start_position_top_left + Vector2(width, 0)
	var bottom_left_point := _start_position_top_left + Vector2(0, height)
	#var end_point := _start_position_top_left + Vector2(0, 1.0)
	
	add_stroke_point(_start_position_top_left, PRESSURE_MULTIPLIER)
	add_stroke_point(top_right_point, PRESSURE_MULTIPLIER)
	add_stroke_point(bottom_right_point, PRESSURE_MULTIPLIER)
	add_stroke_point(bottom_left_point, PRESSURE_MULTIPLIER)
	add_stroke_point(_start_position_top_left, PRESSURE_MULTIPLIER)
