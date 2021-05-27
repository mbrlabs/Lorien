extends ViewportContainer
class_name InfiniteCanvas

# -------------------------------------------------------------------------------------------------
const BRUSH_STROKE = preload("res://BrushStroke/BrushStroke.tscn")
const ERASER_SIZE_FACTOR = 3.5

# -------------------------------------------------------------------------------------------------
onready var _brush_tool: BrushTool = $BrushTool
onready var _line_tool: LineTool = $LineTool
onready var _select_tool: SelectTool = $SelectTool
onready var _move_tool: MoveTool = $MoveTool
onready var _active_tool: CanvasTool = _brush_tool
onready var _strokes_parent: Node2D = $Viewport/Strokes
onready var _camera: Camera2D = $Viewport/Camera2D
onready var _viewport: Viewport = $Viewport

var info := Types.CanvasInfo.new()
var _is_enabled := false
var _background_color: Color
var _brush_color := Config.DEFAULT_BRUSH_COLOR
var _brush_size := Config.DEFAULT_BRUSH_SIZE setget set_brush_size
var _current_stroke: BrushStroke
var _current_project: Project
var _use_optimizer := true
var _optimizer: BrushStrokeOptimizer

# -------------------------------------------------------------------------------------------------
func _ready():
	_optimizer = BrushStrokeOptimizer.new()
	_brush_size = Settings.get_value(Settings.GENERAL_DEFAULT_BRUSH_SIZE, Config.DEFAULT_BRUSH_SIZE)
	_brush_color = Settings.get_value(Settings.GENERAL_DEFAULT_BRUSH_COLOR, Config.DEFAULT_BRUSH_COLOR)
	_active_tool._on_brush_color_changed(_brush_color)
	_active_tool._on_brush_size_changed(_brush_size)
	_active_tool.enabled = false
	
	get_tree().get_root().connect("size_changed", self, "_on_window_resized")
	_camera.connect("zoom_changed", $Viewport/SelectCursor, "_on_zoom_changed")
	_camera.connect("zoom_changed", $Viewport/MoveCursor, "_on_zoom_changed")

# -------------------------------------------------------------------------------------------------
func _draw():
	if _select_tool.is_selecting():
		draw_selection_rect(_select_tool._selecting_start_pos, _select_tool._selecting_end_pos)

# -------------------------------------------------------------------------------------------------
func draw_selection_rect(start_pos: Vector2, end_pos: Vector2) -> void:
	draw_rect(Rect2(start_pos, end_pos - start_pos), Color.whitesmoke, false, true)

# -------------------------------------------------------------------------------------------------
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		info.current_pressure = event.pressure

# -------------------------------------------------------------------------------------------------
func use_tool(tool_type: int) -> void:
	_active_tool.enabled = false
	
	match tool_type:
		Types.Tool.BRUSH:
			_brush_tool.mode = BrushTool.Mode.DRAW
			_active_tool = _brush_tool
			_use_optimizer = true
			_select_tool.deselect_all_strokes()
		Types.Tool.ERASER:
			_brush_tool.mode = BrushTool.Mode.ERASE
			_active_tool = _brush_tool
			_use_optimizer = true
			_select_tool.deselect_all_strokes()
		Types.Tool.LINE:
			_active_tool = _line_tool
			_use_optimizer = false
			_select_tool.deselect_all_strokes()
		Types.Tool.SELECT:
			_active_tool = _select_tool
			_use_optimizer = false
		Types.Tool.MOVE:
			_active_tool = _move_tool
			_use_optimizer = false
		Types.Tool.COLOR_PICKER:
			_select_tool.deselect_all_strokes()
			# TODO: implemented
			
	_active_tool.enabled = true

# -------------------------------------------------------------------------------------------------
func set_background_color(color: Color) -> void:
	VisualServer.set_default_clear_color(color)
	_background_color = color
	
	if _current_project != null:
		# Make the eraser brush strokes have the same color as the background
		for eraser_index in _current_project.eraser_stroke_indices:
			if eraser_index < _strokes_parent.get_child_count():
				_strokes_parent.get_child(eraser_index).color = color
	
# -------------------------------------------------------------------------------------------------
func get_background_color() -> Color:
	return _background_color

# -------------------------------------------------------------------------------------------------
func get_camera() -> Camera2D:
	return _camera

# -------------------------------------------------------------------------------------------------
func get_strokes_in_camera_frustrum() -> Array:
	# FIXME: this currently returns every stroke. 
	return _current_project.strokes

# -------------------------------------------------------------------------------------------------
func enable() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	_camera.enable_intput()
	_active_tool.enabled = true
	_is_enabled = true
	
# -------------------------------------------------------------------------------------------------
func disable() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	_camera.disable_intput()
	_active_tool.enabled = false
	_is_enabled = false

# -------------------------------------------------------------------------------------------------
func take_screenshot() -> Image:
	return _viewport.get_texture().get_data()

# -------------------------------------------------------------------------------------------------
func start_stroke(eraser: bool = false) -> void:
	_current_stroke = BRUSH_STROKE.instance()
	_current_stroke.eraser = eraser
	_current_stroke.size = _brush_size
	
	if eraser:
		_current_stroke.color = _background_color
		_current_stroke.size *= ERASER_SIZE_FACTOR
	else:
		_current_stroke.color = _brush_color
	
	_strokes_parent.call_deferred("add_child", _current_stroke)
	_optimizer.reset()

# -------------------------------------------------------------------------------------------------
func add_stroke_point(point: Vector2, pressure: float = 1.0) -> void:
	_current_stroke.add_point(point, pressure)
	if _use_optimizer:
		_optimizer.optimize(_current_stroke)
	_current_stroke.refresh()

# -------------------------------------------------------------------------------------------------
func remove_last_stroke_point() -> void:
	_current_stroke.remove_last_point()

# -------------------------------------------------------------------------------------------------
func end_stroke() -> void:
	if _current_stroke != null:
		if _current_stroke.points.empty():
			# FIXME: memory leak right here!
			_strokes_parent.call_deferred("remove_child", _current_stroke)
		else:
			if _use_optimizer:
				print("Stroke points: %d (%d removed by optimizer)" % [
					_current_stroke.points.size(), 
					_optimizer.points_removed,
				])
			else:
				print("Stroke points: %d" % _current_stroke.points.size())
			
			# TODO: not sure if needed here
			_current_stroke.refresh()
			
			# Remove the line temporally from the node tree, so the adding is registered in the undo-redo histrory below
			_strokes_parent.remove_child(_current_stroke)
			
			_current_project.undo_redo.create_action("Stroke")
			_current_project.undo_redo.add_undo_method(self, "undo_last_stroke")
			_current_project.undo_redo.add_undo_reference(_current_stroke)
			_current_project.undo_redo.add_do_method(_strokes_parent, "add_child", _current_stroke)
			_current_project.undo_redo.add_do_property(info, "stroke_count", info.stroke_count + 1)
			_current_project.undo_redo.add_do_property(info, "point_count", info.point_count + _current_stroke.points.size())
			_current_project.undo_redo.add_do_method(_current_project, "add_stroke", _current_stroke)
			_current_project.undo_redo.commit_action()
		
		_current_stroke = null

# -------------------------------------------------------------------------------------------------
func use_project(project: Project) -> void:
	# Cleanup old data
	for stroke in _strokes_parent.get_children():
		_strokes_parent.remove_child(stroke)
	info.point_count = 0
	info.stroke_count = 0
	
	# Apply metdadata
	ProjectMetadata.apply_from_dict(project.meta_data, self)
	
	# Add new data
	_current_project = project
	for stroke in _current_project.strokes:
		_strokes_parent.add_child(stroke)
		info.stroke_count += 1
		info.point_count += stroke.points.size()
	
# -------------------------------------------------------------------------------------------------
func undo_last_stroke() -> void:
	if _current_stroke == null && !_current_project.strokes.empty():
		var stroke = _strokes_parent.get_child(_strokes_parent.get_child_count() - 1)
		_strokes_parent.remove_child(stroke)
		_current_project.remove_last_stroke()
		info.point_count -= stroke.points.size()
		info.stroke_count -= 1

# -------------------------------------------------------------------------------------------------
func set_brush_size(size: int) -> void:
	_brush_size = size
	if _active_tool != null:
		_active_tool._on_brush_size_changed(_brush_size)

# -------------------------------------------------------------------------------------------------
func set_brush_color(color: Color) -> void:
	_brush_color = color
	if _active_tool != null:
		_active_tool._on_brush_color_changed(_brush_color)

# -------------------------------------------------------------------------------------------------
func get_camera_zoom() -> float:
	return _camera.zoom.x

# -------------------------------------------------------------------------------------------------
func get_camera_offset() -> Vector2:
	return _camera.offset

# -------------------------------------------------------------------------------------------------
func _on_window_resized() -> void:
	_viewport.size = get_viewport_rect().size
