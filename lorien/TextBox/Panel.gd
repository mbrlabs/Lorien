extends Panel

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		print("CLICK TEST")
