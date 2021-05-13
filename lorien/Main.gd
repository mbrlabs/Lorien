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
	_canvas.set_background_color(canvas_color)
	_file_dialog.current_dir = Config.DEFAULT_FILE_DIALOG_PATH
	
	# UI Signals
	_ui_toolbar.connect("clear_canvas", self, "_on_clear_canvas")
	_ui_toolbar.connect("open_file", self, "_on_load_file")
	_ui_toolbar.connect("save_file", self, "_on_save_file")
	_ui_toolbar.connect("brush_color_changed", self, "_on_brush_color_changed")
	_ui_toolbar.connect("brush_size_changed", self, "_on_brush_size_changed")
	_ui_toolbar.connect("canvas_background_changed", self, "_on_canvas_background_changed")

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
	_canvas.brush_color = color

# -------------------------------------------------------------------------------------------------
func _on_brush_size_changed(size: int) -> void:
	_canvas.set_brush_size(size)

# -------------------------------------------------------------------------------------------------
func _on_clear_canvas() -> void:
	_canvas.clear() 

# -------------------------------------------------------------------------------------------------
func _on_load_file(filepath: String) -> void:
	var savefile: LorienIO.Savefile = LorienIO.load_file(filepath)
	
	# read metadata
	var zoom_str: String = savefile.meta_data[LorienIO.METADATA_CAMERA_ZOOM]
	var offset_x_str: String = savefile.meta_data[LorienIO.METADATA_CAMERA_OFFSET_X]
	var offset_y_str: String = savefile.meta_data[LorienIO.METADATA_CAMERA_OFFSET_Y]
	var canvas_color: String = savefile.meta_data[LorienIO.CANVAS_COLOR]
	
	# apply metadata
	var cam: Camera2D = _canvas.get_camera()
	cam.set_zoom_level(float(zoom_str))
	cam.offset = Vector2(float(offset_x_str), float(offset_y_str))
	_canvas.set_background_color(Color(canvas_color))
	
	# add strokes to canvas
	_canvas.clear()
	_canvas.add_strokes(savefile.strokes)

# -------------------------------------------------------------------------------------------------
func _on_save_file(filepath: String) -> void:
	var cam: Camera2D = _canvas.get_camera()
	var meta_data = {
		LorienIO.METADATA_CAMERA_OFFSET_X: str(cam.offset.x),
		LorienIO.METADATA_CAMERA_OFFSET_Y: str(cam.offset.y),
		LorienIO.METADATA_CAMERA_ZOOM: str(cam.zoom.x),
		LorienIO.CANVAS_COLOR: _canvas.get_background_color().to_html(false),
	}
	
	LorienIO.save_file(filepath, _canvas._brush_strokes, meta_data)

# -------------------------------------------------------------------------------------------------
func _on_canvas_background_changed(color: Color) -> void:
	_canvas.set_background_color(color)
	 
# -------------------------------------------------------------------------------------------------
func _on_InfiniteCanvas_mouse_entered():
	_canvas.enable()

# -------------------------------------------------------------------------------------------------
func _on_InfiniteCanvas_mouse_exited():
	_canvas.disable()
