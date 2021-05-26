class_name CanvasTool, "res://Assets/Icons/tools.png"
extends Node

# -------------------------------------------------------------------------------------------------
export var pressure_curve: Curve
export var cursor_path: NodePath

var _cursor: Sprite # This is a BaseCursor. Can't type it.
var _canvas: Node # This is an InfinteCanvas. Can't type it though because of cyclic dependency bugs...
var enabled := false setget set_enabled, get_enabled
var performing_stroke := false

# -------------------------------------------------------------------------------------------------
func _ready():
	_cursor = get_node(cursor_path)
	_canvas = get_parent()
	set_enabled(false)

# -------------------------------------------------------------------------------------------------
func _on_brush_color_changed(color: Color) -> void:
	pass

# -------------------------------------------------------------------------------------------------
func _on_brush_size_changed(size: int) -> void:
	_cursor.change_size(size)

# -------------------------------------------------------------------------------------------------
func set_enabled(e: bool) -> void:
	enabled = e
	set_process(enabled)
	set_process_input(enabled)
	_cursor.set_visible(enabled)
	if enabled && _canvas:
		_cursor.global_position = xform_vector2(get_viewport().get_mouse_position())

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
# -------------------------------------------------------------------------------------------------
func xform_vector2_relative(v: Vector2) -> Vector2:
	return (_canvas.get_camera().xform(v) - _canvas.get_camera_offset()) / _canvas.get_camera().get_zoom()
