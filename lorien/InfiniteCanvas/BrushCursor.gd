extends Node2D

var _brush_size: int

# -------------------------------------------------------------------------------------------------
func _draw():
	draw_arc(Vector2.ZERO, _brush_size/2.0, 0, PI*2, 64, Color.white, 1.0, true)

# -------------------------------------------------------------------------------------------------
func change_size(brush_size: int) -> void:
	_brush_size = brush_size
	update()
