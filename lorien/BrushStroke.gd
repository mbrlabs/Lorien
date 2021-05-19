class_name BrushStroke

const MAX_PRESSURE_VALUE := 255

# -------------------------------------------------------------------------------------------------
var eraser := false
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
