extends ViewportContainer
class_name InfiniteCanvas

# -------------------------------------------------------------------------------------------------
const DEBUG_POINT_TEXTURE = preload("res://Assets/icon.png")
const STROKE_TEXTURE = preload("res://Assets/Textures/stroke_texture.png")

const DRAW_DEBUG_POINTS := false
const ERASER_SIZE_FACTOR = 3.5

# -------------------------------------------------------------------------------------------------
onready var _brush_tool: BrushTool = $BrushTool
onready var _line_tool: LineTool = $LineTool
onready var _active_tool: CanvasTool = _brush_tool
onready var _line2d_container: Node2D = $Viewport/Strokes
onready var _camera: Camera2D = $Viewport/Camera2D
onready var _viewport: Viewport = $Viewport

var info := Types.CanvasInfo.new()
var _is_enabled := false
var _background_color: Color
var _brush_color := Config.DEFAULT_BRUSH_COLOR
var _brush_size := Config.DEFAULT_BRUSH_SIZE setget set_brush_size
var _current_brush_stroke: BrushStroke
var _current_line_2d: Line2D
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
	_active_tool.enabled = true
	get_tree().get_root().connect("size_changed", self, "_on_window_resized")

# -------------------------------------------------------------------------------------------------
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		info.current_pressure = event.pressure

# -------------------------------------------------------------------------------------------------
func _make_empty_line2d() -> Line2D:
	var line := Line2D.new()
	line.width_curve = Curve.new()
	line.joint_mode = Line2D.LINE_CAP_ROUND
	
	# Anti aliasing
	var aa_mode: int = Settings.get_value(Settings.RENDERING_AA_MODE, Config.DEFAULT_AA_MODE)
	match aa_mode:
		Types.AAMode.OPENGL_HINT:
			line.antialiased = true
		Types.AAMode.TEXTURE_FILL: 
			line.texture = STROKE_TEXTURE
			line.texture_mode = Line2D.LINE_TEXTURE_STRETCH
	
	return line

# -------------------------------------------------------------------------------------------------
func use_tool(tool_type: int) -> void:
	_active_tool.enabled = false
	match tool_type:
		Types.Tool.BRUSH:
			_brush_tool.mode = BrushTool.Mode.DRAW
			_active_tool = _brush_tool
			_use_optimizer = true
		Types.Tool.ERASER:
			_brush_tool.mode = BrushTool.Mode.ERASE
			_active_tool = _brush_tool
			_use_optimizer = true
		Types.Tool.LINE:
			_active_tool = _line_tool
			_use_optimizer = false
		Types.Tool.COLOR_PICKER:
			pass # TODO: add once implemented
	
	_active_tool.enabled = true

# -------------------------------------------------------------------------------------------------
func set_background_color(color: Color) -> void:
	VisualServer.set_default_clear_color(color)
	_background_color = color
	
	if _current_project != null:
		_current_project.dirty = true
		
		# Make the eraser brush strokes have the same color as the background
		for eraser_index in _current_project.eraser_stroke_indices:
			if eraser_index < _line2d_container.get_child_count():
				_line2d_container.get_child(eraser_index).default_color = color
	
# -------------------------------------------------------------------------------------------------
func get_background_color() -> Color:
	return _background_color

# -------------------------------------------------------------------------------------------------
func get_camera() -> Camera2D:
	return _camera

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
func start_stroke(eraser: bool = false) -> void:
	_current_line_2d = _make_empty_line2d()
	
	_current_brush_stroke = BrushStroke.new()
	_current_brush_stroke.eraser = eraser
	
	if eraser:
		_current_line_2d.default_color = _background_color
		_current_brush_stroke.color = Color.black
		_current_line_2d.width = _brush_size * ERASER_SIZE_FACTOR
		_current_brush_stroke.size = _brush_size * ERASER_SIZE_FACTOR
	else:
		_current_line_2d.default_color = _brush_color
		_current_brush_stroke.color = _brush_color
		_current_line_2d.width = _brush_size
		_current_brush_stroke.size = _brush_size
	
	_line2d_container.call_deferred("add_child", _current_line_2d)
	_optimizer.reset()

# -------------------------------------------------------------------------------------------------
func add_stroke_point(point: Vector2, pressure: float = 1.0) -> void:
	_current_brush_stroke.add_point(point, pressure)
	if _use_optimizer:
		_optimizer.optimize(_current_brush_stroke)
	_apply_stroke_to_line(_current_brush_stroke, _current_line_2d)

# -------------------------------------------------------------------------------------------------
func remove_last_stroke_point() -> void:
	if _current_line_2d != null:
		_current_line_2d.points.remove(_current_line_2d.points.size() - 1)
		_current_line_2d.width_curve.remove_point(_current_line_2d.width_curve.get_point_count() - 1)
	if _current_brush_stroke != null:
		_current_brush_stroke.points.pop_back()
		_current_brush_stroke.pressures.pop_back()

# -------------------------------------------------------------------------------------------------
func end_stroke() -> void:
	if _current_line_2d != null:
		if _current_line_2d.points.empty():
			_line2d_container.call_deferred("remove_child", _current_line_2d)
		else:
			if _use_optimizer:
				print("Stroke points: %d (%d removed by optimizer)" % [
					_current_brush_stroke.points.size(), 
					_optimizer.points_removed,
				])
			else:
				print("Stroke points: %d" % _current_brush_stroke.points.size())
			
			# Remove the line temporallaly from the node tree, so the adding is registered in the undo-redo histrory below
			_line2d_container.remove_child(_current_line_2d)
			
			_current_project.undo_redo.create_action("Stroke")
			_current_project.undo_redo.add_undo_method(self, "undo_last_stroke")
			_current_project.undo_redo.add_undo_reference(_current_line_2d) # TODO: not sure about that...
			_current_project.undo_redo.add_do_method(_line2d_container, "add_child", _current_line_2d)
			_current_project.undo_redo.add_do_method(self, "_apply_stroke_to_line", _current_brush_stroke, _current_line_2d)
			_current_project.undo_redo.add_do_property(info, "stroke_count", info.stroke_count + 1)
			_current_project.undo_redo.add_do_property(info, "point_count", info.point_count + _current_line_2d.points.size())
			_current_project.undo_redo.add_do_method(_current_project, "add_stroke", _current_brush_stroke)
			if DRAW_DEBUG_POINTS:
				_current_project.undo_redo.add_do_method(self, "_add_debug_points", _current_line_2d)
			_current_project.undo_redo.commit_action()
		
		_current_line_2d = null
		_current_brush_stroke = null

# -------------------------------------------------------------------------------------------------
func _add_debug_points(line2d: Line2D) -> void:
	for p in line2d.points:
		var s = Sprite.new()
		line2d.add_child(s)
		s.texture = DEBUG_POINT_TEXTURE
		s.scale = Vector2.ONE * (line2d.width * .004)
		s.global_position = p

# -------------------------------------------------------------------------------------------------
func _apply_stroke_to_line(stroke: BrushStroke, line2d: Line2D) -> void:
	var max_pressure := float(BrushStroke.MAX_PRESSURE_VALUE)
	
	line2d.clear_points()
	line2d.width_curve.clear_points()
	
	if stroke.points.empty():
		return

	if stroke.eraser:
		line2d.default_color = _background_color
	else:
		line2d.default_color = stroke.color
		
	line2d.width = stroke.size
	var p_idx := 0
	var curve_step: float = 1.0 / stroke.pressures.size()
	for point in stroke.points:
		line2d.add_point(point)
		var pressure: float = stroke.pressures[p_idx]
		line2d.width_curve.add_point(Vector2(curve_step*p_idx, pressure / max_pressure))
		p_idx += 1
	
	line2d.width_curve.bake()

# -------------------------------------------------------------------------------------------------
func use_project(project: Project) -> void:
	# Cleanup old data
	for l in _line2d_container.get_children():
		_line2d_container.remove_child(l)
	info.point_count = 0
	info.stroke_count = 0
	
	# Apply metda data
	var new_cam_zoom_str: String = project.meta_data.get(Serializer.METADATA_CAMERA_ZOOM, "1.0")
	var new_cam_offset_x_str: String = project.meta_data.get(Serializer.METADATA_CAMERA_OFFSET_X, "0.0")
	var new_cam_offset_y_str: String = project.meta_data.get(Serializer.METADATA_CAMERA_OFFSET_Y, "0.0")
	var new_canvas_color: String = project.meta_data.get(Serializer.CANVAS_COLOR, Config.DEFAULT_CANVAS_COLOR.to_html())
	
	_camera.set_zoom_level(float(new_cam_zoom_str))
	_camera.offset = Vector2(float(new_cam_offset_x_str), float(new_cam_offset_y_str))
	set_background_color(Color(new_canvas_color))
	
	# Add new data
	_current_project = project
	for stroke in _current_project.strokes:
		var line := _make_empty_line2d()
		_apply_stroke_to_line(stroke, line)
		
		_line2d_container.add_child(line)
		if DRAW_DEBUG_POINTS:
			_add_debug_points(line)

		info.stroke_count += 1
		info.point_count += line.points.size()
	
# -------------------------------------------------------------------------------------------------
func undo_last_stroke() -> void:
	if _current_line_2d == null && !_current_project.strokes.empty():
		var line = _line2d_container.get_child(_line2d_container.get_child_count()-1)
		info.stroke_count -= 1
		info.point_count -= line.points.size()
		_line2d_container.remove_child(line)
		_current_project.remove_last_stroke()

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
func clear() -> void:
	for l in _line2d_container.get_children():
		_line2d_container.remove_child(l)
	info.point_count = 0
	info.stroke_count = 0
	_current_project.strokes.clear()
	
# -------------------------------------------------------------------------------------------------
func _on_window_resized() -> void:
	_viewport.size = get_viewport_rect().size
