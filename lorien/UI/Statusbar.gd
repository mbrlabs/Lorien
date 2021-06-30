extends Panel
class_name Statusbar

# -------------------------------------------------------------------------------------------------
onready var _strokes_label: Label = $MarginContainer/HBoxContainer/Right/StrokesLabel
onready var _selected_strokes_label: Label = $MarginContainer/HBoxContainer/Right/SelectedLabel
onready var _points_label: Label = $MarginContainer/HBoxContainer/Right/PointsLabel
onready var _pressure_label: Label = $MarginContainer/HBoxContainer/Left/PressureLabel
onready var _position_label: Label = $MarginContainer/HBoxContainer/Left/PositionLabel
onready var _zoom_label: Label = $MarginContainer/HBoxContainer/Left/ZoomLabel
onready var _fps_label: Label = $MarginContainer/HBoxContainer/Left/FpsLabel

onready var _str_position = tr("STATUSBAR_POSITION")
onready var _str_zoom = tr("STATUSBAR_ZOOM")
onready var _str_pressure = tr("STATUSBAR_PRESSURE")
onready var _str_fps = tr("STATUSBAR_FPS")
onready var _str_stroke_count = tr("STATUSBAR_STROKES")
onready var _str_point_count = tr("STATUSBAR_POINTS")
onready var _str_selected_stroke_count = tr("STATUSBAR_SELECTED_STROKES")

# -------------------------------------------------------------------------------------------------
func set_camera_position(pos: Vector2) -> void:
	_position_label.text = "%s: %d, %d" % [_str_position, pos.x, pos.y]

# -------------------------------------------------------------------------------------------------
func set_camera_zoom(zoom: float) -> void:
	_zoom_label.text = "%s: %.1f" % [_str_zoom, zoom]

# -------------------------------------------------------------------------------------------------
func set_fps(fps: int) -> void:
	_fps_label.text = "%s: %d" % [_str_fps, Engine.get_frames_per_second()]

# -------------------------------------------------------------------------------------------------
func set_pressure(pressure: float) -> void:
	if pressure >= 0.01:
		_pressure_label.text = "%s: %.2f" % [_str_pressure, pressure]
	else:
		_pressure_label.text = "%s: -" % _str_pressure

# -------------------------------------------------------------------------------------------------
func set_stroke_count(brush_stroke_count: int) -> void:
	_strokes_label.text = "%s: %d" % [_str_stroke_count, brush_stroke_count]

# -------------------------------------------------------------------------------------------------
func set_selected_strokes_count(selected: int) -> void:
	_selected_strokes_label.text = "%s: %d" % [_str_selected_stroke_count, selected]

# -------------------------------------------------------------------------------------------------
func set_point_count(point_count: int) -> void:
	_points_label.text = "%s: %d" % [_str_point_count, point_count]
