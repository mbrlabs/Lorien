class_name ColorPickerTool extends CanvasTool


# -------------------------------------------------------------------------------------------------
func tool_event(event: InputEvent) -> void:
	if (
		event is InputEventMouseButton
		&& event.button_index == MOUSE_BUTTON_LEFT
		&& event.is_pressed()
	):
		var mouseEvent := event as InputEventMouseButton
		var picked_color := _pick_color(mouseEvent.position)
		if picked_color != Color.TRANSPARENT:
			GlobalSignals.color_changed.emit(picked_color)


# -------------------------------------------------------------------------------------------------
func _pick_color(pos: Vector2) -> Color:
	var colorPicked := _canvas._viewport.get_texture().get_image().get_pixel(pos.x, pos.y)
	# the exact color picked may be a hue of the original stroke because of antialiasing
	# to fix this, search along every stroke for the color that has an more equal color the picked one
	var minDelta := 0.5
	var bestColorMatch := Color.TRANSPARENT
	var strokes := _canvas.get_all_strokes()
	for stroke in strokes:
		var c := stroke.color
		var colorDelta: float = (
			abs(colorPicked.r - c.r) + abs(colorPicked.g - c.g) + abs(colorPicked.b - c.b)
		)
		if colorDelta < minDelta:
			bestColorMatch = c
			minDelta = colorDelta
	return bestColorMatch
