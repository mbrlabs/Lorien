extends Control

# -------------------------------------------------------------------------------------------------
export var canvas_color := Color.black

onready var _canvas: InfiniteCanvas = $InfiniteCanvas
onready var _ui_statusbar: UIStatusbar = $UIStatusBar
onready var _ui_titlebar: UITitlebar = $UITitlebar
onready var _ui_toolbar: UIToolbar = $UIToolbar

onready var _file_dialog: FileDialog = $FileDialog

# -------------------------------------------------------------------------------------------------
func _ready():
	VisualServer.set_default_clear_color(canvas_color)
	_file_dialog.current_dir = Config.DEFAULT_FILE_DIALOG_PATH
	
	# UI Signals
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
	_ui_statusbar.set_fps(Engine.get_frames_per_second())

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
	var result: Array = LorienIO.load_file(filepath)
	_canvas.clear()
	_canvas.add_strokes(result, Config.DRAW_DEBUG_POINTS)

# -------------------------------------------------------------------------------------------------
func _on_save_file(filepath: String) -> void:
	var test_meta_data = {"Lorien": "is nice", "Mordor": "is shit"}
	LorienIO.save_file(filepath, _canvas._brush_strokes, test_meta_data)

# -------------------------------------------------------------------------------------------------
func _on_InfiniteCanvas_mouse_entered():
	_canvas.enable()

# -------------------------------------------------------------------------------------------------
func _on_InfiniteCanvas_mouse_exited():
	_canvas.disable()
