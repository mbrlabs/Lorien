class_name CircleTool
extends CanvasTool

# -------------------------------------------------------------------------------------------------
const STEP_IN_MOTION := 15
const STEP_STATIC := 4

# -------------------------------------------------------------------------------------------------
export var pressure_curve: Curve
var _start_position_top_left: Vector2

# -------------------------------------------------------------------------------------------------
var sin_arr : Array
var cos_arr : Array

func _init():
	sin_arr.resize(360)
	cos_arr.resize(360)
	for i in 360:
		sin_arr[i] = sin(deg2rad(i))
		cos_arr[i] = cos(deg2rad(i))

# -------------------------------------------------------------------------------------------------
func tool_event(event: InputEvent) -> void:
	_cursor.set_pressure(1.0)
	
	var should_draw_circle := Input.is_key_pressed(KEY_SHIFT)
	
	var tool_pressure : float = Settings.get_value(Settings.GENERAL_TOOL_PRESSURE)
	
	if event is InputEventMouseMotion:
		if performing_stroke:
			_cursor.set_pressure(event.pressure)
			remove_all_stroke_points()
			_make_ellipse(tool_pressure, STEP_IN_MOTION, should_draw_circle)
		
	# Start + End
	elif event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.pressed:
				start_stroke()
				_start_position_top_left = _cursor.global_position
				remove_all_stroke_points()
				_make_ellipse(tool_pressure, STEP_IN_MOTION, should_draw_circle)
			elif !event.pressed && performing_stroke:
				remove_all_stroke_points()
				_make_ellipse(tool_pressure, STEP_STATIC, should_draw_circle)
				end_stroke()

# -------------------------------------------------------------------------------------------------
func _make_ellipse(pressure: float, step: int, should_draw_circle: bool) -> void:
	
	pressure = pressure_curve.interpolate(pressure)

	var r1 := 0.5 * abs(_cursor.global_position.x - _start_position_top_left.x)
	var r2 := 0.5 * abs(_cursor.global_position.y - _start_position_top_left.y)

	if(should_draw_circle):
		r1 = max(r1, r2)
		r2 = r1

	var dir := (_cursor.global_position -_start_position_top_left);
	var center : Vector2

	if dir.x >= 0 && dir.y >= 0:
		center = _start_position_top_left + Vector2(r1, r2)
	elif dir.x <= 0 && dir.y >= 0:
		center = _start_position_top_left + Vector2(-r1, r2)
	elif dir.x <= 0 && dir.y <= 0:
		center = _start_position_top_left + Vector2(-r1, -r2)
	else:
		center = _start_position_top_left + Vector2(r1, -r2)

	for i in range(0, 360, step):
		var point := Vector2(
			center.x + r1 * sin_arr[i],
			center.y + r2 * cos_arr[i]
		)
		add_stroke_point(point, pressure)

	add_stroke_point(Vector2(center.x, center.y + r2), pressure)

	add_stroke_point(
		Vector2(
			center.x + r1 * sin_arr[1],
			center.y + r2 * cos_arr[1]
		), 
		pressure
	)
