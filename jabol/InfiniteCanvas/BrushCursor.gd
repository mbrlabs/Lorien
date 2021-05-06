extends Control

var _brush_size: int

func _draw():
	draw_arc(Vector2.ZERO, _brush_size, 0, 360, 20, Color.white, 1.0, true)

func change_size(brush_size: int) -> void:
	_brush_size = brush_size
	update()
