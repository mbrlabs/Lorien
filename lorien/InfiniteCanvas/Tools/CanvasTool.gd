class_name CanvasTool
extends Node

# -------------------------------------------------------------------------------------------------
export var pressure_curve: Curve
export (NodePath) var cursor_path : NodePath

# This is an InfinteCanvas. Can't type it though because of cyclic dependency bugs...
onready var _canvas: Node = get_parent()
var enabled := false setget set_enabled, get_enabled
var performing_stroke := false

# -------------------------------------------------------------------------------------------------
func _ready():
	set_process(false)
	set_process_input(false)

# -------------------------------------------------------------------------------------------------
func _on_brush_color_changed(color: Color) -> void:
	pass

# -------------------------------------------------------------------------------------------------
func _on_brush_size_changed(size: int) -> void:
	pass

# -------------------------------------------------------------------------------------------------
func set_enabled(e: bool) -> void:
	enabled = e
	set_process(enabled)
	set_process_input(enabled)

# -------------------------------------------------------------------------------------------------
func get_enabled() -> bool:
	return enabled

# -------------------------------------------------------------------------------------------------
func start_stroke(eraser: bool = false) -> void:
	_canvas.start_stroke(eraser)
	performing_stroke = true

# -------------------------------------------------------------------------------------------------
func add_stroke_point(point: Vector2, pressure: float = 1.0) -> void:
	_canvas.add_stroke_point(point, pressure)

# -------------------------------------------------------------------------------------------------
func remove_last_stroke_point() -> void:
	_canvas.remove_last_stroke_point()

# -------------------------------------------------------------------------------------------------
func end_stroke() -> void:
	_canvas.end_stroke()
	performing_stroke = false

# -------------------------------------------------------------------------------------------------
func xform_vector2(v: Vector2) -> Vector2:
	return _canvas.get_camera().xform(v)

# Returns the input Vector translated by the camera offset and zoom, giving always the absolute position
func xform_vector2_relative(v : Vector2) -> Vector2:
	return (_canvas.get_camera().xform(v) - _canvas.get_camera_offset()) / _canvas.get_camera().get_zoom()
