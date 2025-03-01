extends AcceptDialog

# ------------------------------------------------------------------------------------------------
func _ready() -> void:
	close_requested.connect(hide)
# ------------------------------------------------------------------------------------------------
func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode==KEY_ESCAPE:
			hide()
