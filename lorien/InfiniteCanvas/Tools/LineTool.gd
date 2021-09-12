class_name LineTool
extends CanvasTool

# -------------------------------------------------------------------------------------------------
const SNAP_STEP := deg2rad(90.0 / 6.0) # = 15 deg
const SUBDIVISION_LENGTH := 50.0

# -------------------------------------------------------------------------------------------------
export var pressure_curve: Curve
var _snapping_enabled := false
var _head: Vector2
var _tail: Vector2

# -------------------------------------------------------------------------------------------------
func _input(event: InputEvent) -> void:
	_cursor.set_pressure(1.0)
	
	# Snap modifier
	if event is InputEventKey:
		if event.scancode == KEY_SHIFT:
			_snapping_enabled = event.pressed
	
	# Moving the tail
	elif event is InputEventMouseMotion:
		_cursor.global_position = xform_vector2(event.global_position)
		if performing_stroke:
			_cursor.set_pressure(event.pressure)
			remove_last_stroke_point()
			if _snapping_enabled:
				_tail = _add_point_at_snap_pos(0.5)
			else:
				_tail = _add_point_at_mouse_pos(0.5)
	
	# Start + End
	elif event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.pressed:
				start_stroke(false)
				_head = _add_point_at_mouse_pos(0.5)
				_tail = _add_point_at_mouse_pos(0.5)
			elif !event.pressed:
				remove_last_stroke_point()
				_make_final_line(0.5)

# -------------------------------------------------------------------------------------------------
func _make_final_line(pressure: float) -> void:
	pressure = pressure_curve.interpolate(pressure)
	var dist := _head.distance_to(_tail)
	if dist >= 1.0:
		var dir := _head.direction_to(_tail).normalized()
		var subdiv_count := int(dist / SUBDIVISION_LENGTH)
		for i in range(1, subdiv_count):
			var point := _head + dir*SUBDIVISION_LENGTH*i
			add_stroke_point(point, pressure)
	
	add_stroke_point(_tail, pressure)
	end_stroke()

# -------------------------------------------------------------------------------------------------
func _add_point_at_mouse_pos(pressure: float) -> Vector2:
	var brush_position: Vector2 = _cursor.global_position
	pressure = pressure_curve.interpolate(pressure)
	add_stroke_point(brush_position, pressure)
	return brush_position

# -------------------------------------------------------------------------------------------------
func _add_point_at_snap_pos(pressure: float) -> Vector2:
	var mouse_angle := _head.angle_to_point(_cursor.global_position) + (SNAP_STEP / 2.0)
	var snapped_angle := floor(mouse_angle / SNAP_STEP) * SNAP_STEP
	var line_length := _head.distance_to(_cursor.global_position)
	var new_tail := Vector2(-line_length, 0).rotated(snapped_angle) + _head
	pressure = pressure_curve.interpolate(pressure)
	add_stroke_point(new_tail, pressure)
	return new_tail
