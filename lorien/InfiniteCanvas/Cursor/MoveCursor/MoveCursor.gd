class_name MoveCursor
extends CursorClass

# -------------------------------------------------------------------------------------------------

func _ready() -> void:
	_sprite = $CursorIcon

func _on_zoom_changed(zoom_value : float) -> void:
	_sprite.scale = Vector2.ONE * zoom_value
	update()
