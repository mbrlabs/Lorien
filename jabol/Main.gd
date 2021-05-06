extends Control

# -------------------------------------------------------------------------------------------------
onready var _jabol: InfiniteCanvas = $InfiniteCanvas
onready var _ui_statusbar = $UIStatusBar

# -------------------------------------------------------------------------------------------------
func _process(delta):
	_ui_statusbar.set_stroke_count(_jabol.info.stroke_count)
	_ui_statusbar.set_point_count(_jabol.info.point_count)
	_ui_statusbar.set_pressure(_jabol.info.current_pressure)
	_ui_statusbar.set_brush_position(_jabol.info.current_brush_position)
	_ui_statusbar.set_camera_zoom(_jabol.get_camera_zoom())

# -------------------------------------------------------------------------------------------------
func _on_UI_brush_color_changed(color: Color) -> void:
	_jabol.set_brush_color(color)

# -------------------------------------------------------------------------------------------------
func _on_UI_brush_size_changed(size: int) -> void:
	_jabol.set_brush_size(size)

# -------------------------------------------------------------------------------------------------
func _on_UI_clear_canvas() -> void:
	_jabol.clear() 

# -------------------------------------------------------------------------------------------------
func _on_UI_load_project(filepath: String) -> void:
	var result: Array = JabolIO.load_file(filepath)
	_set_window_title(filepath)
	_jabol.clear()
	_jabol.add_strokes(result)
#	for line in result:
#		_jabol.start_new_line(line.color, line.size)
#		var p_idx := 0
#		for point in line.points:
#			_jabol.add_point(point, line.point_pressures[p_idx])
#			p_idx += 1
#		_jabol.end_line()

# -------------------------------------------------------------------------------------------------
func _on_UI_save_project(filepath: String) -> void:
	JabolIO.save_file(filepath, _jabol.lines)
	_set_window_title(filepath)

# -------------------------------------------------------------------------------------------------
func _set_window_title(filepath: String) -> void:
	var split := filepath.split("/")
	var filename := split[split.size()-1]
	OS.set_window_title("%s - Jabol" % filename)
