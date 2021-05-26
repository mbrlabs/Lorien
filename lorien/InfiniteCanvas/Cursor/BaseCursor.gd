class_name BaseCursor
extends Node2D

var _sprite : Sprite
var _brush_size: int
var _pressure := 1.0

# --------------------------------------------
func set_pressure(pressure: float) -> void:
	pass

# --------------------------------------------
func change_size(value : int) -> void:
	pass

# --------------------------------------------
func _on_zoom_changed(value : float) -> void:
	pass
