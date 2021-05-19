extends Node2D

# -------------------------------------------------------------------------------------------------
const COLOR = Color.white

# -------------------------------------------------------------------------------------------------
var _brush_size: int
var _pressure := 1.0

# -------------------------------------------------------------------------------------------------
func _draw():
	var radius := _brush_size/2.0
	draw_arc(Vector2.ZERO, radius*_pressure, 0, PI*2, 64, COLOR, 1.0, true)

# -------------------------------------------------------------------------------------------------
func set_pressure(pressure: float) -> void:
	if pressure <= 1.0:
		_pressure = pressure
		update()

# -------------------------------------------------------------------------------------------------
func change_size(brush_size: int) -> void:
	_brush_size = brush_size
	update()
