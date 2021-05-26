class_name BaseCursor, "res://Assets/Icons/cursor_icon.png"
extends Sprite

var _brush_size: int
var _pressure := 1.0

# --------------------------------------------
func _ready() -> void:
	pass

# --------------------------------------------
func set_pressure(pressure: float) -> void:
	pass

# --------------------------------------------
func change_size(value : int) -> void:
	pass

# --------------------------------------------
func _on_zoom_changed(value : float) -> void:
	pass

