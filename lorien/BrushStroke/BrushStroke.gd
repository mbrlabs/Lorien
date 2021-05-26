class_name BrushStroke

const MAX_PRESSURE_VALUE := 255
const MIN_PRESSURE_VALUE := 30
const MAX_PRESSURE_DIFF := 20

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
	
	# Smooth out pressure values (on Linux i sometimes get really high pressure spikes)
	if !pressures.empty():
		var last_pressure: int = pressures.back()
		var pressure_diff := converted_pressure - last_pressure
		if abs(pressure_diff) > MAX_PRESSURE_DIFF:
			converted_pressure = last_pressure + sign(pressure_diff) * MAX_PRESSURE_DIFF
	converted_pressure = clamp(converted_pressure, MIN_PRESSURE_VALUE, MAX_PRESSURE_VALUE)
	
	points.append(point)
	pressures.append(converted_pressure)

# -------------------------------------------------------------------------------------------------
func clear() -> void:
	points.clear()
	pressures.clear()
