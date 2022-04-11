class_name BrushTool
extends CanvasTool

# -------------------------------------------------------------------------------------------------
enum Mode {
	DRAW,
	ERASE
}

# -------------------------------------------------------------------------------------------------
export var pressure_curve: Curve
var mode: int = Mode.DRAW
var _last_mouse_motion: InputEventMouseMotion

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
			elif !event.pressed && performing_stroke:
				end_stroke()

# -------------------------------------------------------------------------------------------------
func _process(delta: float) -> void:
	if performing_stroke && _last_mouse_motion != null:
		var brush_position: Vector2 = xform_vector2(_last_mouse_motion.global_position)
		var pressure = _last_mouse_motion.pressure
		var sensitivity: float = Settings.get_value(Settings.GENERAL_PRESSURE_SENSITIVITY, Config.DEFAULT_PRESSURE_SENSITIVITY)
		pressure = pressure_curve.interpolate(pressure) * sensitivity
		add_stroke_point(brush_position, pressure)
		_last_mouse_motion = null
		
		# If the brush stroke gets too long, we make a new one. This is necessary because Godot limits the number
		# of indices in a Line2D/Polygon
		if get_current_brush_stroke().points.size() >= BrushStroke.MAX_POINTS:
			end_stroke()
			start_stroke(mode == Mode.ERASE)
			add_stroke_point(brush_position, pressure)
