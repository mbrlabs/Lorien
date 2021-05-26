class_name BaseCursor
extends Node2D

export (ImageTexture) var cursor_sprite: ImageTexture
var _brush_size: int
var _pressure := 1.0
var _sprite: Sprite

# --------------------------------------------
func _ready() -> void:
	if has_node("Sprite"):
		_sprite = $Sprite
		

# --------------------------------------------
func set_pressure(pressure: float) -> void:
	pass

# --------------------------------------------
func change_size(value : int) -> void:
	pass

# --------------------------------------------
func _on_zoom_changed(value : float) -> void:
	pass

# --------------------------------------------
func set_cursor_sprite(img : ImageTexture) -> void:
	cursor_sprite = img
	_sprite.texture = load(cursor_sprite)
