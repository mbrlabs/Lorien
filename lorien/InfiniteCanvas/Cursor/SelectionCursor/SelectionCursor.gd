class_name SelectionCursor
extends BaseCursor

# -------------------------------------------------------------------------------------------------
const CROSS_LENGTH: float = 10.0
const MOVE_TEXTURE = preload("res://Assets/Cursors/move_cursor.png")

enum Mode {
	MOVE,
	SELECT
}

# -------------------------------------------------------------------------------------------------
var _cross_length: float = CROSS_LENGTH
var mode = Mode.SELECT setget set_mode, get_mode

# -------------------------------------------------------------------------------------------------
func _draw() -> void: 
	if mode == Mode.SELECT:
		draw_line(-Vector2(0, _cross_length), Vector2(0, _cross_length), Color.white, 1)
		draw_line(-Vector2(_cross_length, 0), Vector2(_cross_length, 0), Color.white, 1)

# -------------------------------------------------------------------------------------------------
func _on_zoom_changed(zoom_value: float) -> void:
	_cross_length = CROSS_LENGTH * zoom_value
	if mode == Mode.SELECT:
		update()
	elif mode == Mode.MOVE:
		scale = Vector2.ONE * zoom_value

# -------------------------------------------------------------------------------------------------
func set_mode(m: int) -> void:
	mode = m
	match mode:
		Mode.MOVE: texture = MOVE_TEXTURE
		_: texture = null

# -------------------------------------------------------------------------------------------------
func get_mode() -> int:
	return mode
