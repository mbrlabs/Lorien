extends Node2D
class_name SelectionRectangle

const OUTLINE_COLOR = Color.white
const FILL_COLOR = Color(1.0, 1.0, 1.0, 0.05)

# -------------------------------------------------------------------------------------------------
onready var _canvas: Control = get_parent()
var start_position: Vector2
var end_position: Vector2

# -------------------------------------------------------------------------------------------------
func reset() -> void:
	start_position = Vector2.ZERO
	end_position = Vector2.ZERO

# -------------------------------------------------------------------------------------------------
func _draw():
	material.set_shader_param("background_color", _canvas.get_background_color())
	draw_rect(Rect2(start_position, end_position - start_position), FILL_COLOR)
	draw_rect(Rect2(start_position, end_position - start_position), OUTLINE_COLOR, false, 1.0)

