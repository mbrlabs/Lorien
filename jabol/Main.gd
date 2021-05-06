extends Control

# -------------------------------------------------------------------------------------------------
export var canvas_color := Color.black

onready var _canvas: InfiniteCanvas = $InfiniteCanvas
onready var _ui: UI = $UI

# -------------------------------------------------------------------------------------------------
func _ready():
	VisualServer.set_default_clear_color(canvas_color)
	_canvas.enable()
	
	_ui.tools.connect("clear_canvas", self, "_on_clear_canvas")
	_ui.tools.connect("brush_color_changed", self, "_on_brush_color_changed")
	_ui.tools.connect("brush_size_changed", self, "_on_brush_size_changed")
	_ui.tools.connect("load_project", self, "_on_load_project")
	_ui.tools.connect("save_project", self, "_on_save_project")
	_ui.titlebar.connect("close_requested", self, "_on_close_requested")

# -------------------------------------------------------------------------------------------------
func _process(delta):
	_ui.statusbar.set_stroke_count(_canvas.info.stroke_count)
	_ui.statusbar.set_point_count(_canvas.info.point_count)
	_ui.statusbar.set_pressure(_canvas.info.current_pressure)
	_ui.statusbar.set_brush_position(_canvas.info.current_brush_position)
	_ui.statusbar.set_camera_zoom(_canvas.get_camera_zoom())

# -------------------------------------------------------------------------------------------------
func _on_brush_color_changed(color: Color) -> void:
	_canvas.set_brush_color(color)

# -------------------------------------------------------------------------------------------------
func _on_brush_size_changed(size: int) -> void:
	_canvas.set_brush_size(size)

# -------------------------------------------------------------------------------------------------
func _on_clear_canvas() -> void:
	_canvas.clear() 

# -------------------------------------------------------------------------------------------------
func _on_load_project(filepath: String) -> void:
	var result: Array = JabolIO.load_file(filepath)
	_set_window_title(filepath)
	_canvas.clear()
	_canvas.add_strokes(result)

# -------------------------------------------------------------------------------------------------
func _on_save_project(filepath: String) -> void:
	JabolIO.save_file(filepath, _canvas.lines)
	_set_window_title(filepath)

# -------------------------------------------------------------------------------------------------
func _on_close_requested() -> void:
	# TODO: ask to save unsaved project
	get_tree().quit()

# -------------------------------------------------------------------------------------------------
func _set_window_title(filepath: String) -> void:
	var split := filepath.split("/")
	var filename := split[split.size()-1]
	OS.set_window_title("%s - Jabol" % filename)

# -------------------------------------------------------------------------------------------------
func _on_UI_window_borders_entered():
	_canvas.disable()
	
# -------------------------------------------------------------------------------------------------
func _on_UI_window_borders_exited():
	_canvas.enable()

# -------------------------------------------------------------------------------------------------
func _on_UI_ui_entered():
	_canvas.disable()

# -------------------------------------------------------------------------------------------------
func _on_UI_ui_exited():
	_canvas.enable()
