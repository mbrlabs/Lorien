extends Control

# -------------------------------------------------------------------------------------------------
export var canvas_color := Color.black

onready var _canvas: InfiniteCanvas = $InfiniteCanvas
onready var _ui_statusbar: UIStatusbar = $UIStatusBar
onready var _ui_titlebar: UITitlebar = $UITitlebar
onready var _ui_toolbar: UIToolbar = $UIToolbar

onready var _window_border_top: Control = $WindowBorderTop
onready var _window_border_bottom: Control = $WindowBorderBottom
onready var _window_border_left: Control = $WindowBorderLeft
onready var _window_border_right: Control = $WindowBorderRight

# -------------------------------------------------------------------------------------------------
func _ready():
	VisualServer.set_default_clear_color(canvas_color)
	#Input.set_use_accumulated_input(false)
	_canvas.enable()
	
	# Window borders: mouse enter/exit events
	_window_border_top.connect("mouse_entered", self, "_on_mouse_entered_window_border")
	#_window_border_top.connect("mouse_exited", self, "_on_mouse_exited_window_border")
	_window_border_bottom.connect("mouse_entered", self, "_on_mouse_entered_window_border")
	#_window_border_bottom.connect("mouse_exited", self, "_on_mouse_exited_window_border")
	_window_border_left.connect("mouse_entered", self, "_on_mouse_entered_window_border")
	_window_border_left.connect("mouse_exited", self, "_on_mouse_exited_window_border")
	_window_border_right.connect("mouse_entered", self, "_on_mouse_entered_window_border")
	_window_border_right.connect("mouse_exited", self, "_on_mouse_exited_window_border")
	
	# Window borders: gui events (like click and drag)
	_window_border_top.connect("gui_input", self, "_on_top_window_border_gui_input")
	_window_border_bottom.connect("gui_input", self, "_on_bottom_window_border_gui_input")
	_window_border_left.connect("gui_input", self, "_on_left_window_border_gui_input")
	_window_border_right.connect("gui_input", self, "_on_right_window_border_gui_input")
	
	# UI Signals
	_ui_titlebar.connect("close_requested", self, "_on_close_requested")
	_ui_toolbar.connect("clear_canvas", self, "_on_clear_canvas")
	_ui_toolbar.connect("open_file", self, "_on_load_file")
	_ui_toolbar.connect("save_file", self, "_on_save_file")
	_ui_toolbar.connect("brush_color_changed", self, "_on_brush_color_changed")
	_ui_toolbar.connect("brush_size_changed", self, "_on_brush_size_changed")

# -------------------------------------------------------------------------------------------------
func _physics_process(delta):
	_ui_statusbar.set_stroke_count(_canvas.info.stroke_count)
	_ui_statusbar.set_point_count(_canvas.info.point_count)
	_ui_statusbar.set_pressure(_canvas.info.current_pressure)
	_ui_statusbar.set_brush_position(_canvas.info.current_brush_position)
	_ui_statusbar.set_camera_zoom(_canvas.get_camera_zoom())

# -------------------------------------------------------------------------------------------------
func _set_window_title(filepath: String) -> void:
	var split := filepath.split("/")
	var filename := split[split.size()-1]
	OS.set_window_title("%s - Jabol" % filename)

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
func _on_load_file(filepath: String) -> void:
	var result: Array = JabolIO.load_file(filepath)
	_set_window_title(filepath)
	_canvas.clear()
	_canvas.add_strokes(result)

# -------------------------------------------------------------------------------------------------
func _on_save_file(filepath: String) -> void:
	JabolIO.save_file(filepath, _canvas.lines)
	_set_window_title(filepath)

# -------------------------------------------------------------------------------------------------
func _on_close_requested() -> void:
	# TODO: ask to save unsaved project
	get_tree().quit()

# -------------------------------------------------------------------------------------------------
func _on_top_window_border_gui_input(event: InputEvent):
	if Input.is_mouse_button_pressed(BUTTON_LEFT) && event is InputEventMouseMotion:
		OS.window_position.y += event.relative.y
		OS.window_size.y -= event.relative.y

# -------------------------------------------------------------------------------------------------
func _on_bottom_window_border_gui_input(event: InputEvent):
	if Input.is_mouse_button_pressed(BUTTON_LEFT) && event is InputEventMouseMotion:
		OS.window_size.y += event.relative.y

# -------------------------------------------------------------------------------------------------
func _on_left_window_border_gui_input(event: InputEvent):
	if Input.is_mouse_button_pressed(BUTTON_LEFT) && event is InputEventMouseMotion:
		OS.window_position.x += event.relative.x
		OS.window_size.x -= event.relative.x

# -------------------------------------------------------------------------------------------------
func _on_right_window_border_gui_input(event: InputEvent):
	if Input.is_mouse_button_pressed(BUTTON_LEFT) && event is InputEventMouseMotion:
		OS.window_size.x += event.relative.x

# -------------------------------------------------------------------------------------------------
func _on_mouse_entered_window_border() -> void:
	_canvas.disable()

# -------------------------------------------------------------------------------------------------
func _on_mouse_exited_window_border() -> void:
	_canvas.enable()

# -------------------------------------------------------------------------------------------------
func _on_InfiniteCanvas_mouse_entered():
	_canvas.enable()

# -------------------------------------------------------------------------------------------------
func _on_InfiniteCanvas_mouse_exited():
	_canvas.disable()

# -------------------------------------------------------------------------------------------------
func _on_UITitlebar_window_maximized():
	_window_border_top.hide()
	_window_border_bottom.hide()
	_window_border_left.hide()
	_window_border_right.hide()

# -------------------------------------------------------------------------------------------------
func _on_UITitlebar_window_demaximized():
	_window_border_top.show()
	_window_border_bottom.show()
	_window_border_left.show()
	_window_border_right.show()
