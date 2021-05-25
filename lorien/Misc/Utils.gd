extends Node

# -------------------------------------------------------------------------------------------------
func get_native_mouse_position_on_screen() -> Vector2:
	return OS.window_position + get_viewport().get_mouse_position()

# -------------------------------------------------------------------------------------------------
func remove_signal_connections(node: Node, signal_name: String) -> void:
	for conn in node.get_signal_connection_list(signal_name):
		node.disconnect(conn.signal, conn.target, conn.method)

# -------------------------------------------------------------------------------------------------
func is_mouse_in_control(control: Control) -> bool:
	var pos = get_viewport().get_mouse_position()
	var rect = control.get_global_rect()
	return rect.has_point(pos)

# -------------------------------------------------------------------------------------------------
func calculate_rect(start_pos : Vector2, end_pos : Vector2) -> Rect2:
	var area : Rect2 = Rect2(start_pos, end_pos - start_pos)
	if end_pos.x < start_pos.x and end_pos.y < start_pos.y :
		area.position = end_pos
		area.end = start_pos
	elif end_pos.x < start_pos.x and end_pos.y > start_pos.y:
		area.position = Vector2(end_pos.x, start_pos.y)
		area.end = Vector2(start_pos.x, end_pos.y)
	elif end_pos.x > start_pos.x and end_pos.y < start_pos.y:
		area.position = Vector2(start_pos.x, end_pos.y)
		area.end = Vector2(end_pos.x, start_pos.y)
	return area

func return_timestamp_string() -> String:
	var today : Dictionary = OS.get_datetime()
	return "%s%s%s_%s%s%s" % [today.day, today.month, today.year, today.hour, today.minute, today.second]
