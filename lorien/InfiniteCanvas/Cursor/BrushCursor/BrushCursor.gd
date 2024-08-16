class_name BrushCursor
extends BaseCursor

# -------------------------------------------------------------------------------------------------
func _draw():
	var radius := _brush_size/2.0
	draw_arc(Vector2.ZERO, radius*_pressure, 0, PI*2, 32, Color.BLACK, 1.0, true)
	draw_circle(Vector2.ZERO, radius*0.08, Color.BLACK)

# -------------------------------------------------------------------------------------------------
func set_pressure(pressure: float) -> void:
	if pressure <= 1.0:
		_pressure = pressure
		queue_redraw()

# -------------------------------------------------------------------------------------------------
func change_size(brush_size: int) -> void:
	_brush_size = brush_size
	queue_redraw()
