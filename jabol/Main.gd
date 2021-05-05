extends Control

# -------------------------------------------------------------------------------------------------
const FILENAME = "C:/Users/mbrla/Desktop/lol.jabol"

# -------------------------------------------------------------------------------------------------
var _last_mouse_motion: InputEventMouseMotion
var _current_line: Line2D

var _lines := []

# -------------------------------------------------------------------------------------------------
func _unhandled_input(event: InputEvent) -> void:
	#print(get_viewport().get_mouse_position())
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.pressed:
				_start_new_line()
			else:
				_end_line()
	elif event is InputEventMouseMotion:
		_last_mouse_motion = event
		print(event.relative)

# -------------------------------------------------------------------------------------------------
func _process(delta: float) -> void:
	if _current_line != null && _last_mouse_motion != null:
		if _last_mouse_motion.relative.length_squared() > 0.0:
			var pos = _last_mouse_motion.global_position
			var pressure = _last_mouse_motion.pressure
			_current_line.add_point(pos)
			_last_mouse_motion = null
			#print(_current_line.points.size())
	
	if Input.is_action_just_pressed("jabol_undo"):
		_undo_last_line()

# -------------------------------------------------------------------------------------------------
func _start_new_line() -> void:
	_current_line = Line2D.new()
	_current_line.width = 6
	_current_line.antialiased = true
	_current_line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	_current_line.end_cap_mode = Line2D.LINE_CAP_ROUND
	_current_line.joint_mode = Line2D.LINE_JOINT_ROUND
	call_deferred("add_child", _current_line)

# -------------------------------------------------------------------------------------------------
func _end_line() -> void:
	if _current_line != null:
		if _current_line.points.empty():
			call_deferred("remove_child", _current_line)
		else:
			_lines.append(_current_line)
		_current_line = null

# -------------------------------------------------------------------------------------------------
func _undo_last_line() -> void:
	if _current_line == null && !_lines.empty():
		remove_child(_lines.pop_back())

# -------------------------------------------------------------------------------------------------
func _clear() -> void:
	for l in _lines:
		remove_child(l)
	_lines.clear()

# -------------------------------------------------------------------------------------------------
func _on_SaveButton_pressed():
	JabolIO.save_file(FILENAME, _lines)

# -------------------------------------------------------------------------------------------------
func _on_LoadButton_pressed():
	var result: Array = JabolIO.load_file(FILENAME)
	_clear()
	for line in result:
		_start_new_line()
		_current_line.default_color = line.color
		for point in line.points:
			_current_line.add_point(point)
		_end_line()
			
# -------------------------------------------------------------------------------------------------
func _on_ClearButton_pressed():
	_clear()
