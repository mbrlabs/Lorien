extends Node2D
class_name BrushStroke

# ------------------------------------------------------------------------------------------------
const MAX_POINTS 			:= 1000
const MAX_PRESSURE_VALUE 	:= 255
const MIN_PRESSURE_VALUE 	:= 30
const MAX_PRESSURE_DIFF 	:= 20
const GROUP_ONSCREEN 		:= "onscreen_stroke"

const MAX_VECTOR2 := Vector2(2147483647, 2147483647)
const MIN_VECTOR2 := -MAX_VECTOR2

# ------------------------------------------------------------------------------------------------
@onready var _line2d: Line2D = $Line2D
@onready var _visibility_notifier: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D

var color: Color: get = get_color, set = set_color
var size: int
var points: Array # Array<Vector2>
var pressures: Array # Array<float>
var top_left_pos: Vector2
var bottom_right_pos: Vector2

# ------------------------------------------------------------------------------------------------
func _ready():
	_line2d.width_curve = Curve.new()
	_line2d.joint_mode = Line2D.LINE_JOINT_ROUND
	
	_visibility_notifier.connect("screen_entered", _on_VisibilityNotifier2D_screen_entered)
	_visibility_notifier.connect("screen_exited", _on_VisibilityNotifier2D_screen_exited)
	
	# Anti aliasing
	_line2d.texture = BrushStrokeTexture.texture
	_line2d.texture_mode = Line2D.LINE_TEXTURE_TILE
	_line2d.texture_filter = TextureFilter.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	
	var rounding_mode: int = Settings.get_value(Settings.RENDERING_BRUSH_ROUNDING, Config.DEFAULT_BRUSH_ROUNDING)
	match rounding_mode:
		Types.BrushRoundingType.FLAT:
			_line2d.end_cap_mode = Line2D.LINE_CAP_NONE
			_line2d.begin_cap_mode = Line2D.LINE_CAP_NONE
		Types.BrushRoundingType.ROUNDED:
			_line2d.end_cap_mode = Line2D.LINE_CAP_ROUND
			_line2d.begin_cap_mode = Line2D.LINE_CAP_ROUND
	
	refresh()

# ------------------------------------------------------------------------------------------------
func _on_VisibilityNotifier2D_screen_entered() -> void: 
	add_to_group(GROUP_ONSCREEN)
	visible = true
	
# ------------------------------------------------------------------------------------------------
func _on_VisibilityNotifier2D_screen_exited() -> void:
	remove_from_group(GROUP_ONSCREEN)
	visible = false

# -------------------------------------------------------------------------------------------------
func _to_string() -> String:
	return "Color: %s, Size: %d, Points: %s" % [color, size, points]

# -------------------------------------------------------------------------------------------------
func add_point(point: Vector2, pressure: float) -> void:
	var converted_pressure := int(floor(pressure * MAX_PRESSURE_VALUE))
	
	# Smooth out pressure values (on Linux i sometimes get really high pressure spikes)
	if !pressures.is_empty():
		var last_pressure: int = pressures.back()
		var pressure_diff := converted_pressure - last_pressure
		if abs(pressure_diff) > MAX_PRESSURE_DIFF:
			converted_pressure = last_pressure + sign(pressure_diff) * MAX_PRESSURE_DIFF
	converted_pressure = clamp(converted_pressure, MIN_PRESSURE_VALUE, MAX_PRESSURE_VALUE)
	
	points.append(point)
	pressures.append(converted_pressure)

# ------------------------------------------------------------------------------------------------
func remove_last_point() -> void:
	if !points.is_empty():
		points.pop_back()
		pressures.pop_back()
		_line2d.points.remove_at(_line2d.points.size() - 1)
		_line2d.width_curve.remove_point(_line2d.width_curve.get_point_count() - 1)

# ------------------------------------------------------------------------------------------------
func remove_all_points() -> void:
	if !points.is_empty():
		points.clear()
		pressures.clear()
		_line2d.points = PackedVector2Array()
		_line2d.width_curve.clear_points()

# ------------------------------------------------------------------------------------------------
func refresh() -> void:
	var max_pressure := float(MAX_PRESSURE_VALUE)
	
	_line2d.clear_points()
	_line2d.width_curve.clear_points()
	
	if points.is_empty():
		return
	
	_line2d.default_color = color
	_line2d.width = size
	
	var p_idx := 0
	var top_left := MAX_VECTOR2
	var bottom_right := MIN_VECTOR2
	var curve_step: float = 1.0 / pressures.size()
	for point in points:
		# Add the point
		_line2d.add_point(point)
		var pressure: float = pressures[p_idx]
		_line2d.width_curve.add_point(Vector2(curve_step*p_idx, pressure / max_pressure))
		p_idx += 1
			
		# Update the extreme values
		top_left.x = min(top_left.x, point.x)
		top_left.y = min(top_left.y, point.y)
		bottom_right.x = max(bottom_right.x, point.x)
		bottom_right.y = max(bottom_right.y, point.y)
		
	_line2d.width_curve.bake()
	top_left_pos = top_left
	bottom_right_pos = bottom_right
	_visibility_notifier.rect = Utils.calculate_rect(top_left, bottom_right)

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
