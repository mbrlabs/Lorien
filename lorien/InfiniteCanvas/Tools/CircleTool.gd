class_name CircleTool
extends CanvasTool

# -------------------------------------------------------------------------------------------------
const PRESSURE := 0.5
const STEP_IN_MOTION = 15
const STEP_STATIC = 4

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
			_make_circle(PRESSURE, STEP_IN_MOTION)
		
	# Start + End
	elif event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.pressed:
				start_stroke(false)
				_start_position_top_left = _cursor.global_position
				_make_circle(PRESSURE, STEP_IN_MOTION)
			elif !event.pressed && performing_stroke:
				remove_all_stroke_points()
				_make_circle(PRESSURE, STEP_STATIC)
				end_stroke()

var sin_arr : Array
var cos_arr : Array

func _init():
	sin_arr.resize(360)
	cos_arr.resize(360)
	for i in range(0, 360):
		sin_arr[i] = sin(deg2rad(i))
		cos_arr[i] = cos(deg2rad(i))


# -------------------------------------------------------------------------------------------------
func _make_circle(pressure: float, step: int) -> void:

	remove_all_stroke_points()
	pressure = pressure_curve.interpolate(pressure)

	var radius := 0.5 * max(
		abs(_cursor.global_position.y - _start_position_top_left.y),
		abs(_cursor.global_position.x - _start_position_top_left.x)
	);

	var dir := (_cursor.global_position -_start_position_top_left);
	var center : Vector2

	if dir.x >= 0 && dir.y >= 0:
		center = _start_position_top_left + Vector2(radius, radius)
	elif dir.x <= 0 && dir.y >= 0:
		center = _start_position_top_left + Vector2(-radius, radius)
	elif dir.x <= 0 && dir.y <= 0:
		center = _start_position_top_left + Vector2(-radius, -radius)
	else:
		center = _start_position_top_left + Vector2(radius, -radius)

	for i in range(0, 360, step):
		var point := Vector2(
			center.x + radius * sin_arr[i],
			center.y + radius * cos_arr[i]
		)
		add_stroke_point(point, pressure)

	add_stroke_point(Vector2(center.x, center.y + radius), pressure)
	add_stroke_point(
		Vector2(
			center.x + radius * sin_arr[1], 
			center.y + radius * cos_arr[1]
		), 
		pressure
	)
