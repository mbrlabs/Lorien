class_name BrushCursor
extends BaseCursor

# -------------------------------------------------------------------------------------------------
func _draw() -> void:
	var radius := _brush_size/2.0
	draw_arc(Vector2.ZERO, radius*_pressure, 0, PI*2, 32, Color.BLACK, 0.5, true)
	#draw_circle(Vector2.ZERO, radius*0.08, Color.BLACK)

# -------------------------------------------------------------------------------------------------
func set_pressure(pressure: float) -> void:
	if pressure <= 1.0:
		_pressure = pressure
		queue_redraw()

# -------------------------------------------------------------------------------------------------
func change_size(brush_size: int) -> void:
	super(brush_size)
	queue_redraw()
