extends Viewport
class_name JabolCanvas

# -------------------------------------------------------------------------------------------------
onready var _camera: Camera2D = $Camera2D

var lines := []
var _last_mouse_motion: InputEventMouseMotion
var _current_line: Line2D
var _current_zoom_level = 1

# -------------------------------------------------------------------------------------------------
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.pressed:
				start_new_line()
			else:
				end_line()
	elif event is InputEventMouseMotion:
		_last_mouse_motion = event

# -------------------------------------------------------------------------------------------------
func _process(delta: float) -> void:
	if _current_line != null && _last_mouse_motion != null:
		if _last_mouse_motion.relative.length_squared() > 0.0:
			var pos = _last_mouse_motion.global_position
			#var pressure = _last_mouse_motion.pressure
			_current_line.add_point(_camera.xform(pos))
			_last_mouse_motion = null
	
	if Input.is_action_just_pressed("jabol_undo"):
		undo_last_line()

# -------------------------------------------------------------------------------------------------
func start_new_line(color: Color = Color.white) -> void:
	_current_line = Line2D.new()
	_current_line.width = 6
	_current_line.antialiased = true
	_current_line.default_color = color
	_current_line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	_current_line.end_cap_mode = Line2D.LINE_CAP_ROUND
	_current_line.joint_mode = Line2D.LINE_JOINT_ROUND
	call_deferred("add_child", _current_line)

# -------------------------------------------------------------------------------------------------
func add_point(point: Vector2) -> void:
	_current_line.add_point(point)

# -------------------------------------------------------------------------------------------------
func end_line() -> void:
	if _current_line != null:
		if _current_line.points.empty():
			call_deferred("remove_child", _current_line)
		else:
			lines.append(_current_line)
		_current_line = null

# -------------------------------------------------------------------------------------------------
func undo_last_line() -> void:
	if _current_line == null && !lines.empty():
		remove_child(lines.pop_back())

# -------------------------------------------------------------------------------------------------
func clear() -> void:
	for l in lines:
		remove_child(l)
	lines.clear()
