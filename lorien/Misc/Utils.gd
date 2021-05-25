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
func calculate_rect_flips(rect : Rect2) -> Rect2:
	var area : Rect2 = rect
	if area.position.x > area.end.x and area.position.y > area.end.y: area = Rect2(area.end, area.position)
	elif area.position.x > area.end.x and area.position.y < area.end.y: area = Rect2(area.end.x, area.position.y, area.position.x, area.end.y)
	elif area.position.x < area.end.x and area.position.y > area.end.y: area = Rect2(area.position.x, area.end.y, area.end.x, area.position.y)
	return area

func return_timestamp_string() -> String:
	var today : Dictionary = OS.get_datetime()
	return "%s%s%s_%s%s%s" % [today.day, today.month, today.year, today.hour, today.minute, today.second]
