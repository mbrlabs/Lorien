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
	
	# ignore picking color from the background or the background grid
	if (
		_color_delta(colorPicked, _canvas._background_color) < 0.01
		|| _color_delta(colorPicked, _canvas._grid._grid_color) < 0.01
	):
		return Color.TRANSPARENT
	
	for stroke in _canvas.get_all_strokes():
		var delta = _color_delta(stroke.color, colorPicked)
		if delta < minDelta:
			bestColorMatch = stroke.color
			minDelta = delta
	return bestColorMatch


func _color_delta(a: Color, b: Color) -> float:
	return abs(a.r - b.r) + abs(a.g - b.g) + abs(a.b - b.b)
