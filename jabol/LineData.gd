class_name LineData

var points: Array
var color: Color

func _to_string() -> String:
	return "Color: %s, Points: %s" % [color, points]
