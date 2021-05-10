extends ViewportContainer
class_name InfiniteCanvas


# -------------------------------------------------------------------------------------------------
class Info:
	var point_count: int
	var stroke_count: int
	var current_pressure: float
	var current_brush_position: Vector2

# -------------------------------------------------------------------------------------------------
onready var _viewport: Viewport = $Viewport
onready var _camera: Camera2D = $Viewport/Camera2D
onready var _cursor: Node2D = $Viewport/BrushCursor

var line_2d_array := []
var _current_line_2d: Line2D
var _brush_strokes := []
var _current_brush_stroke: BrushStroke
var info := Info.new()
var _last_mouse_motion: InputEventMouseMotion
var _current_brush_color := Config.DEFAULT_BRUSH_COLOR
var _current_brush_size := Config.DEFAULT_BRUSH_SIZE
var _is_enabled := false

# -------------------------------------------------------------------------------------------------
func _ready():
	_cursor.change_size(_current_brush_size)

# -------------------------------------------------------------------------------------------------
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		info.current_pressure = event.pressure
		_last_mouse_motion = event
		_cursor.global_position = _camera.xform(event.global_position)
	if _is_enabled:
		if event is InputEventMouseButton:
			if event.button_index == BUTTON_LEFT:
				if event.pressed:
					start_new_line(_current_brush_color, _current_brush_size)
				else:
					end_line()

# -------------------------------------------------------------------------------------------------
func _physics_process(delta: float) -> void:
	if _is_enabled:
		var brush_position: Vector2
		
		if _last_mouse_motion != null:
			brush_position = _camera.xform(_last_mouse_motion.global_position)
			info.current_brush_position = brush_position
		
		if _current_line_2d != null && _last_mouse_motion != null:
			var pressure = _last_mouse_motion.pressure
			add_point(brush_position, pressure)
			_last_mouse_motion = null
		
		if Input.is_action_just_pressed("lorien_undo"):
			undo_last_line()

# -------------------------------------------------------------------------------------------------
func _make_empty_line2d() -> Line2D:
	var line := Line2D.new()
	line.width_curve = Curve.new()
	line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	line.end_cap_mode = Line2D.LINE_CAP_ROUND
	line.joint_mode = Line2D.LINE_JOINT_ROUND
	line.antialiased = true
	return line

# -------------------------------------------------------------------------------------------------
func enable() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	_camera.enable_intput()
	_cursor.show()
	_is_enabled = true
	
# -------------------------------------------------------------------------------------------------
func disable() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	_camera.disable_intput()
	_cursor.hide()
	_is_enabled = false

# -------------------------------------------------------------------------------------------------
func start_new_line(brush_color: Color, brush_size: float = 6) -> void:
	_current_line_2d = _make_empty_line2d()
	_current_line_2d.width = brush_size
	_current_line_2d.default_color = brush_color
	_viewport.call_deferred("add_child", _current_line_2d)
	
	_current_brush_stroke = BrushStroke.new()
	_current_brush_stroke.color = brush_color
	_current_brush_stroke.size = brush_size

# -------------------------------------------------------------------------------------------------
func add_point(point: Vector2, pressure: float = 1.0) -> void:
	_current_brush_stroke.add_point(point, pressure)
	_current_brush_stroke.optimize()
	_current_brush_stroke.apply(_current_line_2d)

# -------------------------------------------------------------------------------------------------
func end_line() -> void:
	if _current_line_2d != null:
		if _current_line_2d.points.empty():
			_viewport.call_deferred("remove_child", _current_line_2d)
		else:
			print("%d; removed: %d" % [_current_brush_stroke.points.size(), _current_brush_stroke.points_removed_during_optimize])
			_current_brush_stroke.apply(_current_line_2d)
			info.stroke_count += 1
			info.point_count += _current_line_2d.points.size()
			line_2d_array.append(_current_line_2d)
			_brush_strokes.append(_current_brush_stroke)
		_current_line_2d = null
		_current_brush_stroke = null

# -------------------------------------------------------------------------------------------------
func add_strokes(strokes: Array) -> void:
	_brush_strokes.append_array(strokes)
	for stroke in strokes:
		var line := _make_empty_line2d()
		stroke.apply(line)
		
		line_2d_array.append(line)
		_viewport.add_child(line)

		info.stroke_count += 1
		info.point_count += line.points.size()

# -------------------------------------------------------------------------------------------------
func undo_last_line() -> void:
	if _current_line_2d == null && !line_2d_array.empty():
		var line = line_2d_array.pop_back()
		info.stroke_count -= 1
		info.point_count -= line.points.size()
		_viewport.remove_child(line)

# -------------------------------------------------------------------------------------------------
func set_brush_color(color: Color) -> void:
	_current_brush_color = color

# -------------------------------------------------------------------------------------------------
func set_brush_size(size: int) -> void:
	_current_brush_size = size
	_cursor.change_size(size)

# -------------------------------------------------------------------------------------------------
func get_camera_zoom() -> float:
	return _camera.zoom.x

# -------------------------------------------------------------------------------------------------
func clear() -> void:
	for l in line_2d_array:
		_viewport.remove_child(l)
	line_2d_array.clear()
	info.point_count = 0
	info.stroke_count = 0
