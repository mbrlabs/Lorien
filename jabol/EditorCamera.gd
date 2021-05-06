extends Camera2D

const MAX_ZOOM_LEVEL = 100.0
const MIN_ZOOM_LEVEL = 0.1
const ZOOM_INCREMENT = 0.1

var _current_zoom_level := 1.0
var _drag := false

# -------------------------------------------------------------------------------------------------
func _input(event):
	if event is InputEventMouseButton:
		var increment := max(ZOOM_INCREMENT + _current_zoom_level * ZOOM_INCREMENT, ZOOM_INCREMENT)
		
		if event.button_index == BUTTON_WHEEL_DOWN:
			_do_zoom(increment, get_local_mouse_position())
		elif event.button_index == BUTTON_WHEEL_UP:
			_do_zoom(-increment, get_local_mouse_position())
		elif event.button_index == BUTTON_MIDDLE:
			_drag = event.is_pressed()
	
	if event is InputEventMouseMotion:
		if _drag:
			_do_drag(event.relative)

# -------------------------------------------------------------------------------------------------
func _do_drag(drag: Vector2) -> void:
	offset -= drag * _current_zoom_level

# -------------------------------------------------------------------------------------------------
func _do_zoom(incr: float, zoom_anchor: Vector2) -> void:
	var old_zoom := _current_zoom_level
	_current_zoom_level += incr
	if _current_zoom_level < MIN_ZOOM_LEVEL:
		_current_zoom_level = MIN_ZOOM_LEVEL
	elif _current_zoom_level > MAX_ZOOM_LEVEL:
		_current_zoom_level = MAX_ZOOM_LEVEL
	if old_zoom == _current_zoom_level:
		return
	
	var zoom_center = zoom_anchor - offset
	var ratio = 1.0 - _current_zoom_level/old_zoom
	offset += zoom_center * ratio
	
	zoom = Vector2(_current_zoom_level, _current_zoom_level)

# -------------------------------------------------------------------------------------------------
func xform(pos: Vector2) -> Vector2:
	return (pos * zoom) + offset
