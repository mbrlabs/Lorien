class_name BrushStroke

const MAX_PRESSURE_VALUE = 65535

# -------------------------------------------------------------------------------------------------
var color: Color
var size: int
var points: Array
var pressures: Array

var points_removed_during_optimize := 0

# -------------------------------------------------------------------------------------------------
func _to_string() -> String:
	return "Color: %s, Size: %d, Points: %s" % [color, size, points]

# -------------------------------------------------------------------------------------------------
func add_point(point: Vector2, pressure: float) -> void:
	pressure = int(floor(pressure * MAX_PRESSURE_VALUE))
	
	points.append(point)
	pressures.append(pressure)

# -------------------------------------------------------------------------------------------------
func optimize() -> void:
	if points.size() < 3:
		return
	
	var filtered_points := []
	var filtered_pressures := []
	
	filtered_points.append(points.front())
	filtered_pressures.append(pressures.front())
	
	var previous_angle := 0.0
	for i in range(1, points.size()):
		var prev_point: Vector2 = points[i-1]
		var point: Vector2 = points[i]
		var pressure = pressures[i]
		
		# Distance between 2 points must be greater than x
		var distance = prev_point.distance_to(point)
		var distance_cond = distance > 1.0 # TODO: make dependent on zoom level
	
		# Angle between points must be beigger than x deg
		var angle := rad2deg(prev_point.angle_to_point(point))
		var angle_diff = abs(abs(angle) - abs(previous_angle))
		var angle_cond = angle_diff >= 1.0
		previous_angle = angle
		
		var point_too_far_away = distance > 100
		
		if point_too_far_away || (distance_cond && angle_cond):
			filtered_points.append(point)
			filtered_pressures.append(pressure)
		else:
			points_removed_during_optimize += 1

	# add back last point
	if !filtered_points.back().is_equal_approx(points.back()):
		filtered_points.append(points.back())
		filtered_pressures.append(pressures.back())

	points = filtered_points
	pressures = filtered_pressures

# -------------------------------------------------------------------------------------------------
func apply(line2d: Line2D) -> void:
	line2d.clear_points()
	line2d.width_curve.clear_points()
	
	if points.empty():
		return

	line2d.width_curve.bake_resolution = pressures.size()
	
	line2d.default_color = color
	line2d.width = size
	var p_idx := 0
	var curve_step: float = 1.0 / pressures.size()
	for point in points:
		line2d.add_point(point)
		var pressure: float = pressures[p_idx]
		line2d.width_curve.add_point(Vector2(curve_step*p_idx, pressure / float(MAX_PRESSURE_VALUE)))
		p_idx += 1
	
	
	# taper out end smoothly
#	if pressures.size() >= 3:
#		var point_count = line2d.width_curve.get_point_count()
#		var p3 = pressures[pressures.size()-3] / float(MAX_PRESSURE_VALUE)
#		line2d.width_curve.set_point_value(point_count-2, p3*0.5)
#		line2d.width_curve.set_point_value(point_count-1, p3*0.25)
	
	line2d.width_curve.add_point(Vector2(1.0, pressures.back() / MAX_PRESSURE_VALUE))
	line2d.width_curve.bake()
