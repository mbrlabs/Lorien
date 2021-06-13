extends Node2D
class_name BrushStroke

# ------------------------------------------------------------------------------------------------
const STROKE_TEXTURE = preload("res://Assets/Textures/stroke_texture.png")

# ------------------------------------------------------------------------------------------------
const MAX_POINTS 		:= 1000
const MAX_PRESSURE_VALUE := 255
const MIN_PRESSURE_VALUE := 30
const MAX_PRESSURE_DIFF := 20

# ------------------------------------------------------------------------------------------------
signal camera_frustrum_change(inside_frustrum)

# ------------------------------------------------------------------------------------------------
onready var _line2d: Line2D = $Line2D
var eraser := false
var color: Color setget set_color, get_color
var size: int
var points: Array
var pressures: Array

# ------------------------------------------------------------------------------------------------
func _ready():
	_line2d.width_curve = Curve.new()
	_line2d.joint_mode = Line2D.LINE_CAP_ROUND
	
	# Anti aliasing
	var aa_mode: int = Settings.get_value(Settings.RENDERING_AA_MODE, Config.DEFAULT_AA_MODE)
	match aa_mode:
		Types.AAMode.OPENGL_HINT:
			_line2d.antialiased = true
		Types.AAMode.TEXTURE_FILL: 
			_line2d.texture = STROKE_TEXTURE
			_line2d.texture_mode = Line2D.LINE_TEXTURE_STRETCH
	
	refresh()

# ------------------------------------------------------------------------------------------------
func _on_VisibilityNotifier2D_viewport_entered(viewport: Viewport) -> void: emit_signal("camera_frustrum_change", true)
func _on_VisibilityNotifier2D_viewport_exited(viewport: Viewport) -> void: emit_signal("camera_frustrum_change", false)

# -------------------------------------------------------------------------------------------------
func _to_string() -> String:
	return "Color: %s, Size: %d, Points: %s" % [color, size, points]

# -------------------------------------------------------------------------------------------------
func add_point(point: Vector2, pressure: float) -> void:
	var converted_pressure := int(floor(pressure * MAX_PRESSURE_VALUE))
	
	# Smooth out pressure values (on Linux i sometimes get really high pressure spikes)
	if !pressures.empty():
		var last_pressure: int = pressures.back()
		var pressure_diff := converted_pressure - last_pressure
		if abs(pressure_diff) > MAX_PRESSURE_DIFF:
			converted_pressure = last_pressure + sign(pressure_diff) * MAX_PRESSURE_DIFF
	converted_pressure = clamp(converted_pressure, MIN_PRESSURE_VALUE, MAX_PRESSURE_VALUE)
	
	points.append(point)
	pressures.append(converted_pressure)

# ------------------------------------------------------------------------------------------------
func remove_last_point() -> void:
	if !points.empty():
		points.pop_back()
		pressures.pop_back()
		_line2d.points.remove(_line2d.points.size() - 1)
		_line2d.width_curve.remove_point(_line2d.width_curve.get_point_count() - 1)

# ------------------------------------------------------------------------------------------------
func refresh() -> void:

	var max_pressure := float(MAX_PRESSURE_VALUE)
	
	_line2d.clear_points()
	_line2d.width_curve.clear_points()
	
	if points.empty():
		return
	
	# FIXME: eraser color !!!
	_line2d.default_color = color
	_line2d.width = size
	
	var p_idx := 0
	var curve_step: float = 1.0 / pressures.size()
	for point in points:
		_line2d.add_point(point)
		var pressure: float = pressures[p_idx]
		_line2d.width_curve.add_point(Vector2(curve_step*p_idx, pressure / max_pressure))
		p_idx += 1
	
	_line2d.width_curve.bake()
	
	# TODO: calculate bounding box for the visibility notifier and move the correct position

# -------------------------------------------------------------------------------------------------
func set_color(c: Color) -> void:
	color = c
	if _line2d != null:
		_line2d.default_color = color

# -------------------------------------------------------------------------------------------------
func get_color() -> Color:
	return color

# -------------------------------------------------------------------------------------------------
func clear() -> void:
	points.clear()
	pressures.clear()
	_line2d.clear_points()
	_line2d.width_curve.clear_points()
