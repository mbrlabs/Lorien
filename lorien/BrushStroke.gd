class_name BrushStroke

const MAX_PRESSURE_VALUE := 255

# -------------------------------------------------------------------------------------------------
var color: Color
var size: int
var points: Array
var pressures: Array

# -------------------------------------------------------------------------------------------------
func _to_string() -> String:
	return "Color: %s, Size: %d, Points: %s" % [color, size, points]

# -------------------------------------------------------------------------------------------------
func add_point(point: Vector2, pressure: float) -> void:
	var converted_pressure := int(floor(pressure * MAX_PRESSURE_VALUE))
	
	points.append(point)
	pressures.append(converted_pressure)

# -------------------------------------------------------------------------------------------------
func apply(line2d: Line2D) -> void:	
	line2d.clear_points()
	line2d.width_curve.clear_points()
	
	if points.empty():
		return

	line2d.default_color = color
	line2d.width = size
	var p_idx := 0
	var curve_step: float = 1.0 / pressures.size()
	for point in points:
		line2d.add_point(point)
		var pressure: float = pressures[p_idx]
		line2d.width_curve.add_point(Vector2(curve_step*p_idx, pressure / float(MAX_PRESSURE_VALUE)))
		p_idx += 1
	line2d.width_curve.add_point(Vector2(1.0, (pressures.back()/float(MAX_PRESSURE_VALUE)) * 0.75))
	
	line2d.width_curve.bake_resolution = pressures.size() * 2.0
	line2d.width_curve.bake()
