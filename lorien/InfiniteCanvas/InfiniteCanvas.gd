extends ViewportContainer
class_name InfiniteCanvas

# -------------------------------------------------------------------------------------------------
const BRUSH_STROKE = preload("res://BrushStroke/BrushStroke.tscn")
const PLAYER = preload("res://Misc/Player/Player.tscn")

# -------------------------------------------------------------------------------------------------
onready var _brush_tool: BrushTool = $BrushTool
onready var _highlighter_tool: BrushTool = $HighlighterTool
onready var _rectangle_tool: RectangleTool = $RectangleTool
onready var _line_tool: LineTool = $LineTool
onready var _circle_tool: CircleTool = $CircleTool
onready var _eraser_tool: EraserTool = $EraserTool
onready var _selection_tool: SelectionTool = $SelectionTool
onready var _active_tool: CanvasTool = _brush_tool
onready var _strokes_brush: Node2D = $Viewport/Strokes_Brush
onready var _strokes_highlighter: Node2D = $Viewport/Strokes_Highlighter
onready var _camera: Camera2D = $Viewport/Camera2D
onready var _viewport: Viewport = $Viewport
onready var _grid: InfiniteCanvasGrid = $Viewport/Grid

var info := Types.CanvasInfo.new()
var _is_enabled := false
var _background_color: Color
var _brush_color := Config.DEFAULT_BRUSH_COLOR
var _brush_size := Config.DEFAULT_BRUSH_SIZE setget set_brush_size
var _current_stroke: BrushStroke
var _current_project: Project
var _use_optimizer := true
var _player: Player = null
var _player_enabled := false
var _colliders_enabled := false
var _optimizer: BrushStrokeOptimizer
var _scale := Config.DEFAULT_UI_SCALE

# -------------------------------------------------------------------------------------------------
func _ready():
	_optimizer = BrushStrokeOptimizer.new()
	_brush_size = Settings.get_value(Settings.GENERAL_DEFAULT_BRUSH_SIZE, Config.DEFAULT_BRUSH_SIZE)
	_active_tool._on_brush_size_changed(_brush_size)
	_active_tool.enabled = false
		
	_highlighter_tool.set_layer(1)
		
	get_tree().get_root().connect("size_changed", self, "_on_window_resized")
	
	for child in $Viewport.get_children():
		if child is BaseCursor:
			_camera.connect("zoom_changed", child, "_on_zoom_changed")
			_camera.connect("position_changed", child, "_on_canvas_position_changed")
	
	_camera.connect("zoom_changed", self, "_on_zoom_changed")
	_camera.connect("position_changed", self, "_on_camera_moved")
	_viewport.size = OS.window_size

# -------------------------------------------------------------------------------------------------
func _unhandled_key_input(event: InputEventKey) -> void:
	_process_event(event)

# -------------------------------------------------------------------------------------------------
func _gui_input(event: InputEvent) -> void:
	_process_event(event)

# -------------------------------------------------------------------------------------------------
func _process_event(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		info.current_pressure = event.pressure

	if event.is_action("deselect_all_strokes"):
		if _active_tool == _selection_tool:
			_selection_tool.deselect_all_strokes()

	if event.is_action("delete_selected_strokes"):
		if _active_tool == _selection_tool:
			_delete_selected_strokes()
	
	if ! get_tree().is_input_handled():
		_camera.tool_event(event)
	if ! get_tree().is_input_handled():
		if _active_tool.enabled:
			_active_tool.tool_event(event)

# -------------------------------------------------------------------------------------------------
func center_to_mouse() -> void:
	if _active_tool != null:
		var screen_space_cursor_pos := _viewport.get_mouse_position()
		_camera.do_center(screen_space_cursor_pos)

# -------------------------------------------------------------------------------------------------
func use_tool(tool_type: int) -> void:
	var prev_tool := _active_tool
	var prev_status := prev_tool.enabled

	match tool_type:
		Types.Tool.BRUSH:
			_active_tool = _brush_tool
			_use_optimizer = true
		Types.Tool.HIGHLIGHTER:
			_active_tool = _highlighter_tool
			_use_optimizer = true
		Types.Tool.RECTANGLE:
			_active_tool = _rectangle_tool
			_use_optimizer = false
		Types.Tool.CIRCLE:
			_active_tool = _circle_tool
			_use_optimizer = false
		Types.Tool.LINE:
			_active_tool = _line_tool
			_use_optimizer = false
		Types.Tool.ERASER:
			_active_tool = _eraser_tool
			_use_optimizer = false
		Types.Tool.SELECT:
			_active_tool = _selection_tool
			_use_optimizer = false

	if prev_tool != _active_tool:
		prev_tool.enabled = false
		prev_tool.reset()
	_active_tool.enabled = prev_status
	_active_tool.get_cursor()._on_zoom_changed(_camera.zoom.x)


# -------------------------------------------------------------------------------------------------
func set_background_color(color: Color) -> void:
	_background_color = color
	VisualServer.set_default_clear_color(_background_color)
	_grid.set_canvas_color(_background_color)

# -------------------------------------------------------------------------------------------------
func enable_colliders(enable: bool) -> void:
	if _colliders_enabled != enable:
		_colliders_enabled = enable
		for stroke in _strokes_brush.get_children():
			stroke.enable_collider(enable)

# -------------------------------------------------------------------------------------------------
func enable_player(enable: bool) -> void:
	if _player_enabled != enable:
		_player_enabled = enable
		if enable:
			if _player == null:
				_player = PLAYER.instance()
			_player.reset(_active_tool.get_cursor().global_position)
			_viewport.add_child(_player)
		else:
			_viewport.remove_child(_player)

# -------------------------------------------------------------------------------------------------
func enable_grid(e: bool) -> void:
	_grid.enable(e)

# -------------------------------------------------------------------------------------------------
func get_background_color() -> Color:
	return _background_color

# -------------------------------------------------------------------------------------------------
func get_camera() -> Camera2D:
	return _camera

# -------------------------------------------------------------------------------------------------
func get_strokes_in_camera_frustrum() -> Array:
	return get_tree().get_nodes_in_group(BrushStroke.GROUP_ONSCREEN)

# -------------------------------------------------------------------------------------------------
func get_all_strokes() -> Array:
	return _current_project.strokes

# -------------------------------------------------------------------------------------------------
func enable() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	_camera.enable_input()
	_active_tool.enabled = true
	_is_enabled = true
	
# -------------------------------------------------------------------------------------------------
func disable() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	_camera.disable_input()
	_active_tool.enabled = false
	_is_enabled = false

# -------------------------------------------------------------------------------------------------
func take_screenshot() -> Image:
	return _viewport.get_texture().get_data()

# -------------------------------------------------------------------------------------------------
func start_stroke() -> void:
	var _selected_layer := _active_tool.get_layer()
	_current_stroke = BRUSH_STROKE.instance()
	_current_stroke.layer = _selected_layer
	
	if _selected_layer == 1 :
		_current_stroke.size = _brush_size * 10
		_current_stroke.color = Color(_brush_color.r,_brush_color.g,_brush_color.b,0.8)
		_strokes_highlighter.add_child(_current_stroke)
	else :
		_current_stroke.size = _brush_size
		_current_stroke.color = _brush_color
		_strokes_brush.add_child(_current_stroke)
		
	_optimizer.reset()
	
# -------------------------------------------------------------------------------------------------
func add_stroke(stroke: BrushStroke) -> void:
	if _current_project != null:
		_current_project.strokes.append(stroke)
		if stroke.layer == 1 :
			_strokes_highlighter.add_child(stroke)
		else :
			_strokes_brush.add_child(stroke)
		info.point_count += stroke.points.size()
		info.stroke_count += 1

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
func remove_all_stroke_points() -> void:
	_current_stroke.remove_all_points()

# -------------------------------------------------------------------------------------------------
func end_stroke() -> void:
	if _current_stroke != null:
		var points: Array = _current_stroke.points
		if points.size() <= 1 || (points.size() == 2 && points.front().is_equal_approx(points.back())):
			if _current_stroke.layer == 1 :
				_strokes_highlighter.remove_child(_current_stroke)
			else :
				_strokes_brush.remove_child(_current_stroke)
			
			_current_stroke.queue_free()
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
			
			# Colliders for the platformer easter-egg
			if _colliders_enabled:
				_current_stroke.enable_collider(true)
			
			# Remove the line temporally from the node tree, so the adding is registered in the undo-redo histrory below
			if _current_stroke.layer == 1 :
				_strokes_highlighter.remove_child(_current_stroke)
			else :
				_strokes_brush.remove_child(_current_stroke)
			
			_current_project.undo_redo.create_action("Stroke")
			_current_project.undo_redo.add_undo_method(self, "undo_last_stroke")
			_current_project.undo_redo.add_undo_reference(_current_stroke)
			_current_project.undo_redo.add_do_property(info, "stroke_count", info.stroke_count + 1)
			_current_project.undo_redo.add_do_property(info, "point_count", info.point_count + _current_stroke.points.size())
			if _current_stroke.layer == 1 :
				_current_project.undo_redo.add_do_method(_strokes_highlighter, "add_child", _current_stroke)
				_current_project.undo_redo.add_do_method(_current_project, "add_stroke", _current_stroke)
			else :
				_current_project.undo_redo.add_do_method(_strokes_brush, "add_child", _current_stroke)
				_current_project.undo_redo.add_do_method(_current_project, "add_stroke", _current_stroke)

			_current_project.undo_redo.commit_action()
		
		_current_stroke = null

# -------------------------------------------------------------------------------------------------
func add_strokes(strokes: Array) -> void:
	_current_project.undo_redo.create_action("Add Strokes")
	var point_count := 0
	for stroke in strokes:
		point_count += stroke.points.size()
		_current_project.undo_redo.add_undo_method(self, "undo_last_stroke")
		_current_project.undo_redo.add_undo_reference(stroke)
		if 	stroke.layer == 1 :
			_current_project.undo_redo.add_do_method(_strokes_highlighter, "add_child", stroke)
			_current_project.undo_redo.add_do_method(_current_project, "add_stroke", stroke)
		else :
			_current_project.undo_redo.add_do_method(_strokes_brush, "add_child", stroke)
			_current_project.undo_redo.add_do_method(_current_project, "add_stroke", stroke)

	_current_project.undo_redo.add_do_property(info, "stroke_count", info.stroke_count + strokes.size())
	_current_project.undo_redo.add_do_property(info, "point_count", info.point_count + point_count)
	_current_project.undo_redo.commit_action()

# -------------------------------------------------------------------------------------------------
func use_project(project: Project) -> void:
	# Cleanup old data
	for stroke in _strokes_brush.get_children():
		_strokes_brush.remove_child(stroke)
	for stroke in _strokes_highlighter.get_children():
		_strokes_highlighter.remove_child(stroke)
	info.point_count = 0
	info.stroke_count = 0
	
	# Apply metdadata
	ProjectMetadata.apply_from_dict(project.meta_data, self)
	_active_tool.get_cursor()._on_zoom_changed(_camera.zoom.x)
	
	# Add new data
	_current_project = project
	for stroke in _current_project.strokes:
		if stroke.layer==1:
			_strokes_highlighter.add_child(stroke)
		else:
			_strokes_brush.add_child(stroke)
		info.stroke_count += 1
		info.point_count += stroke.points.size()
	
	_grid.update()
	
# -------------------------------------------------------------------------------------------------
func undo_last_stroke() -> void:
	if _current_stroke == null && !_current_project.strokes.empty():
		var stroke = _current_project.strokes.back()
		if stroke.layer == 1 :
			_strokes_highlighter.remove_child(stroke)
		else :
			_strokes_brush.remove_child(stroke)
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
func _on_zoom_changed(zoom: float) -> void:
	_current_project.meta_data[ProjectMetadata.CAMERA_ZOOM] = str(zoom)
	_current_project.dirty = true

# -------------------------------------------------------------------------------------------------
func _on_camera_moved(pos: Vector2) -> void:
	_current_project.meta_data[ProjectMetadata.CAMERA_OFFSET_X] = str(pos.x)
	_current_project.meta_data[ProjectMetadata.CAMERA_OFFSET_Y] = str(pos.y)
	_current_project.dirty = true

# -------------------------------------------------------------------------------------------------
func _delete_selected_strokes() -> void:
	var strokes := _selection_tool.get_selected_strokes()
	if !strokes.empty():
		_current_project.undo_redo.create_action("Delete Selection")
		for stroke in strokes:
			_current_project.undo_redo.add_do_method(self, "_do_delete_stroke", stroke)
			_current_project.undo_redo.add_undo_reference(stroke)
			_current_project.undo_redo.add_undo_method(self, "_undo_delete_stroke", stroke)
		_selection_tool.deselect_all_strokes()
		_current_project.undo_redo.commit_action()
		_current_project.dirty = true

# -------------------------------------------------------------------------------------------------
func _do_delete_stroke(stroke: BrushStroke) -> void:
	var index := _current_project.strokes.find(stroke)
	_current_project.strokes.remove(index)
	if stroke.layer==1 :
		_strokes_highlighter.remove_child(stroke)
	else :
		_strokes_brush.remove_child(stroke)
	info.point_count -= stroke.points.size()
	info.stroke_count -= 1

# FIXME: this adds strokes at the back and does not preserve stroke order; not sure how to do that except saving before
# and after versions of the stroke arrays which is a nogo.
# -------------------------------------------------------------------------------------------------
func _undo_delete_stroke(stroke: BrushStroke) -> void:
	_current_project.strokes.append(stroke)
	if stroke.layer == 1 :
		_strokes_highlighter.add_child(stroke)		
	else :
		_strokes_brush.add_child(stroke)
		
	info.point_count += stroke.points.size()
	info.stroke_count += 1

# -------------------------------------------------------------------------------------------------
func _on_window_resized() -> void:
	# Stops viewport from resetting scale when root viewport changes size
	set_canvas_scale(_scale)

# -------------------------------------------------------------------------------------------------
func set_canvas_scale(scale: float) -> void:
	_scale = scale
	_grid.set_grid_scale(scale)
	# Needed to stop stretching of the canvas
	_viewport.set_size(get_viewport().get_size())
	
# -------------------------------------------------------------------------------------------------
func get_canvas_scale() -> float:
	return _scale
