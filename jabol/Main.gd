extends Control

# -------------------------------------------------------------------------------------------------
onready var _jabol: JabolCanvas = $ViewportContainer/Viewport

# -------------------------------------------------------------------------------------------------
func _on_UI_brush_color_changed(color: Color) -> void:
	_jabol.set_brush_color(color)

# -------------------------------------------------------------------------------------------------
func _on_UI_brush_size_changed(size: float) -> void:
	_jabol.set_brush_size(size)

# -------------------------------------------------------------------------------------------------
func _on_UI_clear_canvas() -> void:
	_jabol.clear() 

# -------------------------------------------------------------------------------------------------
func _on_UI_load_project(filepath: String) -> void:
	var result: Array = JabolIO.load_file(filepath)
	_set_window_title(filepath)
	_jabol.clear()
	for line in result:
		_jabol.start_new_line(line.color, line.size)
		for point in line.points:
			_jabol.add_point(point)
		_jabol.end_line()

# -------------------------------------------------------------------------------------------------
func _on_UI_save_project(filepath: String) -> void:
	JabolIO.save_file(filepath, _jabol.lines)
	_set_window_title(filepath)

# -------------------------------------------------------------------------------------------------
func _set_window_title(filepath: String) -> void:
	var split := filepath.split("/")
	var filename := split[split.size()-1]
	OS.set_window_title("%s - Jabol" % filename)
