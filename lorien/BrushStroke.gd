class_name BrushStroke

const MAX_PRESSURE_VALUE = 65535
const MIN_PRESSURE_VALUE = int(MAX_PRESSURE_VALUE * 0.25)

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
	pressure = max(MIN_PRESSURE_VALUE, pressure)
	
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
		var distance_cond = distance > 2.0
	
		# Angle between points must be beigger than x deg
		var angle := rad2deg(prev_point.angle_to_point(point))
		var angle_diff = abs(abs(angle) - abs(previous_angle))
		var angle_cond = angle_diff >= 1.0
		previous_angle = angle
		
		if distance_cond && angle_cond:
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
	
	line2d.default_color = color
	line2d.width = size
	var p_idx := 0
	var curve_step: float = 1.0 / pressures.size()
	for point in points:
		line2d.add_point(point)
		var pressure: float = pressures[p_idx]
		line2d.width_curve.add_point(Vector2(curve_step*p_idx, pressure / MAX_PRESSURE_VALUE))
		p_idx += 1
	line2d.width_curve.add_point(Vector2(1.0, pressures.back() / MAX_PRESSURE_VALUE))
	line2d.width_curve.bake()
