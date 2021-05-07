extends Node

func get_native_mouse_position_on_screen() -> Vector2:
	return OS.window_position + get_viewport().get_mouse_position()
