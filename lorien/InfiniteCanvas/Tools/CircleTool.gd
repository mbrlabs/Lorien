class_name CircleTool
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
			#_make_circle(PRESSURE)
			_make_line(PRESSURE)
		
	# Start + End
	elif event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.pressed:
				start_stroke(false)
				_start_position_top_left = _cursor.global_position
				#_make_circle(PRESSURE)
			elif !event.pressed:
				remove_all_stroke_points()
				_make_circle(PRESSURE)
				end_stroke()

# -------------------------------------------------------------------------------------------------
func _make_line(pressure: float) -> void:
	pressure = pressure_curve.interpolate(pressure)
	add_stroke_point(_start_position_top_left, pressure)
	add_stroke_point(_cursor.global_position, pressure)
	
	
func _make_circle(pressure: float) -> void:
	pressure = pressure_curve.interpolate(pressure)
	var centre := _start_position_top_left
	var radius := (_cursor.global_position - centre).length()
	
	var point := _cursor.global_position
	
	var theta := float(0)
	while theta <= 2*PI:
		point = centre + Vector2(radius*cos(theta), radius*sin(theta))	
		add_stroke_point(point, pressure)
		theta += float(0.01)
	
	#add_stroke_point(point + Vector2(0,10), pressure)
	#add_subdivided_line(centre, point, pressure)
	
#	var bottom_right_point := _cursor.global_position
#	var height := bottom_right_point.y - _start_position_top_left.y
#	var width := bottom_right_point.x - _start_position_top_left.x
#	var top_right_point := _start_position_top_left + Vector2(width, 0)
#	var bottom_left_point := _start_position_top_left + Vector2(0, height)
#
#	var w_offset := width*0.02
#	var h_offset := height*0.02
#	add_subdivided_line(_start_position_top_left, top_right_point - Vector2(w_offset, 0), pressure)
#	add_subdivided_line(top_right_point, bottom_right_point - Vector2(0, h_offset), pressure)
#	add_subdivided_line(bottom_right_point, bottom_left_point + Vector2(w_offset, 0), pressure)
#	add_subdivided_line(bottom_left_point, _start_position_top_left + Vector2(0, h_offset), pressure)
#	add_subdivided_line(_start_position_top_left, _start_position_top_left + Vector2(w_offset, 0), pressure)
