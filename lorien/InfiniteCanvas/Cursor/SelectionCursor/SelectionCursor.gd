class_name SelectionCursor
extends BaseCursor

# -------------------------------------------------------------------------------------------------
const CROSS_LENGTH: float = 10.0
const MOVE_TEXTURE = preload("res://Assets/Cursors/move_cursor.png")
const SELECT_TEXTURE = preload("res://Assets/Textures/selection_cursor.png")

enum Mode {
	MOVE,
	SELECT
}

# -------------------------------------------------------------------------------------------------
var _cross_length: float = CROSS_LENGTH
var mode = Mode.SELECT setget set_mode, get_mode

# -------------------------------------------------------------------------------------------------
func _on_zoom_changed(zoom_value: float) -> void:
	scale = Vector2.ONE * zoom_value

# -------------------------------------------------------------------------------------------------
func set_mode(m: int) -> void:
	mode = m
	match mode:
		Mode.MOVE: texture = MOVE_TEXTURE
		_: texture = SELECT_TEXTURE

# -------------------------------------------------------------------------------------------------
func get_mode() -> int:
	return mode
