class_name RectangleTool
extends CanvasTool

# -------------------------------------------------------------------------------------------------
const PRESSURE := 0.5

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
			_make_rectangle(PRESSURE, false)
		
	# Start + End
	elif event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.pressed:
				start_stroke(false)
				_start_position_top_left = _cursor.global_position
				_make_rectangle(PRESSURE, false)
			elif !event.pressed:
				remove_all_stroke_points()
				_make_rectangle(PRESSURE, true)
				end_stroke()

# -------------------------------------------------------------------------------------------------
func _make_rectangle(pressure: float, subdivided: bool) -> void:
	pressure = pressure_curve.interpolate(pressure)
	var bottom_right_point := _cursor.global_position
	var height := bottom_right_point.y - _start_position_top_left.y
	var width := bottom_right_point.x - _start_position_top_left.x
	var top_right_point := _start_position_top_left + Vector2(width, 0)
	var bottom_left_point := _start_position_top_left + Vector2(0, height)
	
	if subdivided:
		add_subdivided_line(_start_position_top_left, top_right_point, pressure)
		add_subdivided_line(top_right_point, bottom_right_point, pressure)
		add_subdivided_line(bottom_right_point, bottom_left_point, pressure)
		add_subdivided_line(bottom_left_point, _start_position_top_left, pressure)
	else:
		add_stroke_point(_start_position_top_left, pressure)
		add_stroke_point(top_right_point, pressure)
		add_stroke_point(bottom_right_point, pressure)
		add_stroke_point(bottom_left_point, pressure)
		add_stroke_point(_start_position_top_left, pressure)
