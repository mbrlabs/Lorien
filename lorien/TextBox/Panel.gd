extends Panel

signal close_click

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				close_click.emit()
				

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		print("CLICK TEST")
