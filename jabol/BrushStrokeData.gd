class_name BrushStrokeData

var color: Color
var size: int
var points: Array
var point_pressures: Array

func _to_string() -> String:
	return "Color: %s, Size: %d, Points: %s" % [color, size, points]
