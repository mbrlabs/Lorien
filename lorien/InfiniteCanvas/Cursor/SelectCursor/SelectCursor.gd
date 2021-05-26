class_name SelectCursor
extends BaseCursor

# -------------------------------------------------------------------------------------------------
const CROSS_LENGTH: float = 6.0
var _cross_length: float = CROSS_LENGTH

# -------------------------------------------------------------------------------------------------
func _draw() -> void: 
	draw_line(-Vector2(0, _cross_length), Vector2(0, _cross_length), Color.white, 1, false)
	draw_line(-Vector2(_cross_length, 0), Vector2(_cross_length, 0), Color.white, 1, false)

# -------------------------
func _on_zoom_changed(zoom_value: float) -> void:
	_cross_length = CROSS_LENGTH * zoom_value
	update()
