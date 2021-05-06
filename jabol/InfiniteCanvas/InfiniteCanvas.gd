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

var lines := []
var info := Info.new()
var _last_mouse_motion: InputEventMouseMotion
var _current_line: Line2D
var _current_brush_color := Color.white
var _current_brush_size := 4

# -------------------------------------------------------------------------------------------------
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.pressed:
				start_new_line(_current_brush_color, _current_brush_size)
			else:
				end_line()
	elif event is InputEventMouseMotion:
		_last_mouse_motion = event
		info.current_pressure = event.pressure

# -------------------------------------------------------------------------------------------------
func _process(delta: float) -> void:
	var brush_position: Vector2
	
	if _last_mouse_motion != null:
		brush_position = _camera.xform(_last_mouse_motion.global_position)
		info.current_brush_position = brush_position
	
	if _current_line != null && _last_mouse_motion != null:
		if _last_mouse_motion.relative.length_squared() > 0.0:
			#var pressure = _last_mouse_motion.pressure
			#var pressure_16 = int(round(65536*pressure))
			#var pressure_8 = int(round(255*pressure))
			#print("Pressure: %f (%d -> %f)" % [pressure, pressure_16, pressure_16/65536.0])
			add_point(brush_position)
			_last_mouse_motion = null
	
	if Input.is_action_just_pressed("jabol_undo"):
		undo_last_line()

# -------------------------------------------------------------------------------------------------
func start_new_line(brush_color: Color, brush_size: float = 6) -> void:
	_current_line = Line2D.new()
	#_current_line.antialiased = true
	_current_line.default_color = brush_color
	_current_line.width = brush_size
	_current_line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	_current_line.end_cap_mode = Line2D.LINE_CAP_ROUND
	_current_line.joint_mode = Line2D.LINE_JOINT_ROUND
	_viewport.call_deferred("add_child", _current_line)

# -------------------------------------------------------------------------------------------------
func add_point(point: Vector2) -> void:
	_current_line.add_point(point)
	info.point_count += 1

# -------------------------------------------------------------------------------------------------
func end_line() -> void:
	if _current_line != null:
		if _current_line.points.empty():
			_viewport.call_deferred("remove_child", _current_line)
		else:
			info.stroke_count += 1
			lines.append(_current_line)
		_current_line = null

# -------------------------------------------------------------------------------------------------
func undo_last_line() -> void:
	if _current_line == null && !lines.empty():
		var line = lines.pop_back()
		info.stroke_count -= 1
		info.point_count -= line.points.size()
		_viewport.remove_child(line)

# -------------------------------------------------------------------------------------------------
func set_brush_color(color: Color) -> void:
	_current_brush_color = color

# -------------------------------------------------------------------------------------------------
func set_brush_size(size: int) -> void:
	_current_brush_size = size

# -------------------------------------------------------------------------------------------------
func get_camera_zoom() -> float:
	return _camera.zoom.x

# -------------------------------------------------------------------------------------------------
func clear() -> void:
	for l in lines:
		_viewport.remove_child(l)
	lines.clear()
	info.point_count = 0
	info.stroke_count = 0
