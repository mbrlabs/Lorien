extends Panel
class_name UIStatusbar

# -------------------------------------------------------------------------------------------------
onready var _strokes_label: Label = $MarginContainer/HBoxContainer/Right/StrokesLabel
onready var _points_label: Label = $MarginContainer/HBoxContainer/Right/PointsLabel
onready var _pressure_label: Label = $MarginContainer/HBoxContainer/Left/PressureLabel
onready var _position_label: Label = $MarginContainer/HBoxContainer/Left/PositionLabel
onready var _zoom_label: Label = $MarginContainer/HBoxContainer/Left/ZoomLabel
onready var _fps_label: Label = $MarginContainer/HBoxContainer/Left/FpsLabel

# -------------------------------------------------------------------------------------------------
func set_stroke_count(brush_stroke_count: int) -> void:
	_strokes_label.text = "Strokes: %d" % brush_stroke_count

# -------------------------------------------------------------------------------------------------
func set_point_count(point_count: int) -> void:
	_points_label.text = "Points: %d" % point_count

# -------------------------------------------------------------------------------------------------
func set_pressure(pressure: float) -> void:
	if pressure >= 0.01:
		_pressure_label.text = "Pressure: %.3f" % pressure
	else:
		_pressure_label.text = "Pressure: -"

# -------------------------------------------------------------------------------------------------
func set_fps(fps: int) -> void:
	_fps_label.text = "FPS: %d" % Engine.get_frames_per_second()

# -------------------------------------------------------------------------------------------------
func set_camera_position(pos: Vector2) -> void:
	_position_label.text = "Position: %d, %d" % [pos.x, pos.y]

# -------------------------------------------------------------------------------------------------
func set_camera_zoom(zoom: float) -> void:
	_zoom_label.text = "Zoom: %.1f" % zoom
