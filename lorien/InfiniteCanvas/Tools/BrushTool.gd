class_name BrushTool
extends CanvasTool

# -------------------------------------------------------------------------------------------------
enum Mode {
	DRAW,
	ERASE
}

# -------------------------------------------------------------------------------------------------
var mode: int = Mode.DRAW
var _last_mouse_motion: InputEventMouseMotion

# -------------------------------------------------------------------------------------------------
func _ready():
	_cursor = get_node(brush_cursor_path)

# -------------------------------------------------------------------------------------------------
func _on_brush_size_changed(size: int) -> void:
	_cursor.change_size(size)

# -------------------------------------------------------------------------------------------------
func set_enabled(e: bool) -> void:
	.set_enabled(e)
	if e:
		_cursor.global_position = xform_vector2(get_viewport().get_mouse_position())
		_cursor.show()
	else:
		_cursor.hide()

# -------------------------------------------------------------------------------------------------
func _input(event: InputEvent) -> void:
	_cursor.set_pressure(1.0)
	
	if event is InputEventMouseMotion:
		_last_mouse_motion = event
		_cursor.global_position = xform_vector2(event.global_position)
		if performing_stroke:
			_cursor.set_pressure(event.pressure)

	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.pressed && _last_mouse_motion != null:
				_last_mouse_motion.global_position = event.global_position
				_last_mouse_motion.position = event.position
				start_stroke(mode == Mode.ERASE)
			elif !event.pressed:
				end_stroke()

# -------------------------------------------------------------------------------------------------
func _process(delta: float) -> void:
	if performing_stroke && _last_mouse_motion != null:
		var brush_position: Vector2 = xform_vector2(_last_mouse_motion.global_position)
		var pressure = _last_mouse_motion.pressure
		pressure = pressure_curve.interpolate(pressure)
		add_stroke_point(brush_position, pressure)
		_last_mouse_motion = null
