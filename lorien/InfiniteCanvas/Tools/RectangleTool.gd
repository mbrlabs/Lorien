class_name RectangleTool
extends CanvasTool

# -------------------------------------------------------------------------------------------------
export var pressure_curve: Curve
var _start_position_top_left: Vector2

# -------------------------------------------------------------------------------------------------
func _input(event: InputEvent) -> void:
	_cursor.set_pressure(1.0)
	if event is InputEventMouseMotion:
		_cursor.global_position = xform_vector2(event.global_position)
