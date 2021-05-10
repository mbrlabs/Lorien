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

	for i in range(1, points.size()):
		var point: Vector2 = points[i]
		var pressure = pressures[i]

		var last_valid_point: Vector2 = filtered_points.back()

		var dist_cond := last_valid_point.distance_squared_to(point) >= 25.0

		if dist_cond:
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
