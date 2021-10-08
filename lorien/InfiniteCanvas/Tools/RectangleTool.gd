class_name RectangleTool
extends CanvasTool

# -------------------------------------------------------------------------------------------------
const PRESSURE := 0.5
const SUBDIVISION_LENGTH := 50.0

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
			_make_rectangle(PRESSURE)
		
	# Start + End
	elif event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.pressed:
				start_stroke(false)
				_start_position_top_left = _cursor.global_position
				_make_rectangle(PRESSURE)
			elif !event.pressed:
				remove_all_stroke_points()
				_make_rectangle(PRESSURE)
				end_stroke()

# -------------------------------------------------------------------------------------------------
func _make_rectangle(pressure: float) -> void:
	pressure = pressure_curve.interpolate(pressure)
	var bottom_right_point := _cursor.global_position
	var height := bottom_right_point.y - _start_position_top_left.y
	var width := bottom_right_point.x - _start_position_top_left.x
	var top_right_point := _start_position_top_left + Vector2(width, 0)
	var bottom_left_point := _start_position_top_left + Vector2(0, height)
	
	_make_subdivided_line(_start_position_top_left, top_right_point, pressure)
	_make_subdivided_line(top_right_point, bottom_right_point, pressure)
	_make_subdivided_line(bottom_right_point, bottom_left_point, pressure)
	_make_subdivided_line(bottom_left_point, _start_position_top_left, pressure)

# -------------------------------------------------------------------------------------------------
func _make_subdivided_line(from: Vector2, to: Vector2, pressure: float) -> void:
	var dist := from.distance_to(to)
	var dir := from.direction_to(to).normalized()
	var subdiv_count := int(dist / SUBDIVISION_LENGTH)
	for i in subdiv_count:
		var point: Vector2 = from + dir*SUBDIVISION_LENGTH*i
		add_stroke_point(point, pressure)
		
	if subdiv_count == 0:
		add_stroke_point(from, pressure)
	add_stroke_point(to, pressure)

