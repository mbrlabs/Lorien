class_name BrushTool
extends CanvasTool

# -------------------------------------------------------------------------------------------------
const MOVEMENT_THRESHOLD := 1.0
const MIN_PRESSURE := 0.1

# -------------------------------------------------------------------------------------------------
export var pressure_curve: Curve

# -------------------------------------------------------------------------------------------------
var _current_position: Vector2
var _current_pressure: float
var _last_accepted_position: Vector2
var _first_point := false

# -------------------------------------------------------------------------------------------------
func tool_event(event: InputEvent) -> void:
	_cursor.set_pressure(1.0)
	
	if event is InputEventMouseMotion:
		_cursor.global_position = xform_vector2(event.global_position)
		_current_position = event.position
		_current_pressure = event.pressure
		if performing_stroke:
			_cursor.set_pressure(event.pressure)

	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.pressed:
				start_stroke()
				_first_point = true
			elif !event.pressed && performing_stroke:
				end_stroke()

# -------------------------------------------------------------------------------------------------
func _process(delta: float) -> void:
	if performing_stroke:
		# Basic smoothing
		var diff := _current_position.distance_squared_to(_last_accepted_position)
		if diff <= MOVEMENT_THRESHOLD || _current_pressure <= MIN_PRESSURE:
			return
			
		var sensitivity: float = Settings.get_value(Settings.GENERAL_PRESSURE_SENSITIVITY, Config.DEFAULT_PRESSURE_SENSITIVITY)
		var point_pressure = pressure_curve.interpolate(_current_pressure) * sensitivity
		if _first_point:
			point_pressure *= 1.4
			_first_point = false
		var point_position := xform_vector2(_current_position)
		
		add_stroke_point(point_position, point_pressure)
		
		# If the brush stroke gets too long, we make a new one. This is necessary because Godot limits the number
		# of indices in a Line2D/Polygon
		if get_current_brush_stroke().points.size() >= BrushStroke.MAX_POINTS:
			end_stroke()
			start_stroke()
			add_stroke_point(point_position, point_pressure)
			
		_last_accepted_position = _current_position

