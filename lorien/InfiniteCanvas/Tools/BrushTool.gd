class_name BrushTool
extends CanvasTool

# -------------------------------------------------------------------------------------------------
const MOVEMENT_THRESHOLD := 1.0
const DOT_MAX_DISTANCE_THRESHOLD := 6.0

# -------------------------------------------------------------------------------------------------
@export var pressure_curve: Curve

# -------------------------------------------------------------------------------------------------
var _current_pressure: float
var _current_velocity: float
var _moved := false
var _last_accepted_position: Vector2

# -------------------------------------------------------------------------------------------------
func tool_event(event: InputEvent) -> void:
	_cursor.set_pressure(1.0)
	if event is InputEventMouseMotion:
		_current_pressure = event.pressure
		if _current_pressure < 0 || is_zero_approx(_current_pressure):
			_current_pressure = 1.0
		
		var screen := DisplayServer.screen_get_size()
		var velocity: Vector2 = event.screen_velocity / Vector2(screen.x, screen.y)
		_current_velocity = velocity.length()
		
		if performing_stroke:
			_moved = true
			_cursor.set_pressure(event.pressure)
		if zooming_detected && performing_stroke:
			end_stroke()

	elif event is InputEventMouseButton && !disable_stroke:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				start_stroke()
			elif performing_stroke:
				if _is_stroke_a_dot():
					_canvas.remove_all_stroke_points()
					_draw_point()
				end_stroke()

# -------------------------------------------------------------------------------------------------
func _process(delta: float) -> void:
	if performing_stroke:
		var pos := _cursor.global_position
		
		if !_moved:
			return
		_moved = false
		
		var diff := pos.distance_squared_to(_last_accepted_position)
		if diff <= MOVEMENT_THRESHOLD:
			return
		
		# Stabilizer smoothing
		var stabilizer_strength: float = Settings.get_value(
			Settings.GENERAL_STABILIZER_STRENGTH, Config.DEFAULT_STABILIZER_STRENGTH
		)
		
		if stabilizer_strength >= 0.01:
			var points := get_current_brush_stroke().points
			if points.size() > 3:
				var p3 := points[-3]
				var p2 := points[-2]
				var p1 := points[-1]
				# t is in [0.5, 1.0] interval depending on stabilizer settings
				var t := 0.5 + (1.0 - stabilizer_strength) * 0.5
				pos = Utils.cubic_bezier(p3, p2, p1, pos, t)
				#pos = Utils.quadratic_bezier(p2, p1, pos, t)
			
			
		# Pressure & velocity
		var sensitivity: float = Settings.get_value(
			Settings.GENERAL_PRESSURE_SENSITIVITY, Config.DEFAULT_PRESSURE_SENSITIVITY
		)
		
		if _current_pressure >= 0.99:
			_current_pressure -= min(_current_velocity * 1.5, 0.33)
		else:
			_current_pressure -= min(_current_velocity, 0.33)
			
		var point_pressure := pressure_curve.sample(_current_pressure) * sensitivity
		
		add_stroke_point(pos, point_pressure)
		
		# If the brush stroke gets too long, we make a new one. This is necessary because Godot limits the number
		# of indices in a Line2D/Polygon
		if get_current_brush_stroke().points.size() >= BrushStroke.MAX_POINTS:
			end_stroke()
			start_stroke()
			add_stroke_point(pos, point_pressure)
			
		_last_accepted_position = pos

# -------------------------------------------------------------------------------------------------
func _is_stroke_a_dot() -> bool:
	var stroke := get_current_brush_stroke()
	
	if stroke.points.size() < 2:
		return true
	
	if stroke.points.size() == 2:
		var dist := stroke.points[0].distance_to(stroke.points[1])
		if dist <= DOT_MAX_DISTANCE_THRESHOLD:
			return true
	
	if stroke.points.size() <= 6:
		var dist := 0.0
		for i in stroke.points.size() - 1:
			dist += stroke.points[i].distance_to(stroke.points[i + 1])
		if dist <= DOT_MAX_DISTANCE_THRESHOLD:
			return true
				
	return false

# -------------------------------------------------------------------------------------------------
func _draw_point() -> void:
	var origin := _cursor.global_position
	var pressure := 0.5
	var offset := 1.5
	
	add_stroke_point(origin, pressure)
	add_stroke_point(origin + Vector2(0, offset), pressure)
	add_stroke_point(origin + Vector2(-offset/2.0, offset/2.0), pressure)
