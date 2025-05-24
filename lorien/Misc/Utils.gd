extends Node

# -------------------------------------------------------------------------------------------------
const UUID_ALPHABET := "abcdefghijklmnopqrstuvwxyz0123456789"

# -------------------------------------------------------------------------------------------------
func get_native_mouse_position_on_screen() -> Vector2:
	return Vector2(get_window().position) + get_viewport().get_mouse_position()

# -------------------------------------------------------------------------------------------------
func remove_signal_connections(node: Node, signal_name: String) -> void:
	for conn in node.get_signal_connection_list(signal_name):
		node.disconnect(conn["signal"], Callable(conn["target"], conn["method"]))

# -------------------------------------------------------------------------------------------------
func is_mouse_in_control(control: Control) -> bool:
	if control.visible:
		var pos := get_viewport().get_mouse_position()
		var rect := control.get_global_rect()
		return rect.has_point(pos)
	return false

# -------------------------------------------------------------------------------------------------
func is_mouse_on_window(window: Window) -> bool:
	if window.visible:
		var pos := get_viewport().get_mouse_position()
		var rect := window.get_viewport().get_visible_rect()
		return rect.has_point(pos)
	return false

# -------------------------------------------------------------------------------------------------
func calculate_rect(start_pos: Vector2, end_pos: Vector2) -> Rect2:
	var area := Rect2(start_pos, end_pos - start_pos)
	if end_pos.x < start_pos.x && end_pos.y < start_pos.y:
		area.position = end_pos
		area.end = start_pos
	elif end_pos.x < start_pos.x && end_pos.y > start_pos.y:
		area.position = Vector2(end_pos.x, start_pos.y)
		area.end = Vector2(start_pos.x, end_pos.y)
	elif end_pos.x > start_pos.x && end_pos.y < start_pos.y:
		area.position = Vector2(start_pos.x, end_pos.y)
		area.end = Vector2(end_pos.x, start_pos.y)
	return area

# -------------------------------------------------------------------------------------------------
func calculte_bounding_boxes(strokes: Array[BrushStroke], text_boxes: Array[TextBox], margin: float = 0.0) -> Dictionary:
	var result := {}
	for stroke: BrushStroke in strokes:
		var top_left := stroke.position + stroke.top_left_pos
		var bottom_right := stroke.position + stroke.bottom_right_pos
		var bounding_box := calculate_rect(top_left, bottom_right)
		if margin > 0:
			bounding_box = bounding_box.grow(margin)
		result[stroke] = bounding_box
		
	for text_box : TextBox in text_boxes:
		var text_box_bounding_box := text_box.get_global_rect()
		#if margin > 0:
		#	text_box_bounding_box := text_box_bounding_box.grow(margin)
		result[text_box] = text_box_bounding_box
	return result
	
# -------------------------------------------------------------------------------------------------
func return_timestamp_string() -> String:
	var today := Time.get_datetime_dict_from_system()
	return "%s%s%s_%s%s%s" % [today.day, today.month, today.year, today.hour, today.minute, today.second]

# -------------------------------------------------------------------------------------------------
func remove_group_from_all_nodes(group: String) -> void:
	for n in get_tree().get_nodes_in_group(group):
		n.remove_from_group(group)

# -------------------------------------------------------------------------------------------------
func is_valid_lorien_file(filepath: String) -> bool:
	return filepath.ends_with(".lorien")

# -------------------------------------------------------------------------------------------------
func generate_uuid(length: int) -> String:
	var s := ""
	for i: int in length:
		var idx := randf_range(0, UUID_ALPHABET.length()-1)
		s += UUID_ALPHABET[idx]
	return s

# -------------------------------------------------------------------------------------------------
func translate_action(action_name: String) -> String:
	return TranslationServer.translate("ACTION_" + action_name)

# ------------------------------------------------------------------------------------------------
# See: https://github.com/mbrlabs/Lorien/pull/168#discussion_r908251372 for details
# Does an _exact_ match for the given key stroke.
func is_action_pressed(action_name: String, event: InputEvent) -> bool:
	return InputMap.action_has_event(action_name, event) && event.is_pressed() && !event.is_echo()

# -------------------------------------------------------------------------------------------------
func is_action_released(action_name: String, event: InputEvent) -> bool:
	return InputMap.action_has_event(action_name, event) && event.is_released() && !event.is_echo()

# -------------------------------------------------------------------------------------------------
func cubic_bezier(p0: Vector2, p1: Vector2, p2: Vector2, p3: Vector2, t: float) -> Vector2:
	var q0 := p0.lerp(p1, t)
	var q1 := p1.lerp(p2, t)
	var q2 := p2.lerp(p3, t)
	var r0 := q0.lerp(q1, t)
	var r1 := q1.lerp(q2, t)
	return r0.lerp(r1, t)

# -------------------------------------------------------------------------------------------------
func quadratic_bezier(p0: Vector2, p1: Vector2, p2: Vector2, t: float) -> Vector2:
	var q0 := p0.lerp(p1, t)
	var q1 := p1.lerp(p2, t)
	return q0.lerp(q1, t)
