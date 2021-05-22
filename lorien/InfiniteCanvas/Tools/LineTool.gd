class_name LineTool
extends CanvasTool

# -------------------------------------------------------------------------------------------------
export var brush_cursor_path: NodePath
var _brush_cursor: Node2D

# -------------------------------------------------------------------------------------------------
func _ready():
	_brush_cursor = get_node(brush_cursor_path)

# -------------------------------------------------------------------------------------------------
func _on_brush_size_changed(size: int) -> void:
	_brush_cursor.change_size(size)

# -------------------------------------------------------------------------------------------------
func set_enabled(e: bool) -> void:
	.set_enabled(e)
	if e:
		_brush_cursor.global_position = xform_vector2(get_viewport().get_mouse_position())
		_brush_cursor.show()
	else:
		_brush_cursor.hide()

# -------------------------------------------------------------------------------------------------
func _input(event: InputEvent) -> void:
	_brush_cursor.set_pressure(1.0)
	
	if event is InputEventMouseMotion:
		_brush_cursor.global_position = xform_vector2(event.global_position)
		if performing_stroke:
			_brush_cursor.set_pressure(event.pressure)
			remove_last_stroke_point()
			_add_point_at_current_mouse_pos(0.5)

	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.pressed:
				start_stroke(false)
				_add_point_at_current_mouse_pos(0.5)
				_add_point_at_current_mouse_pos(0.5)
			elif !event.pressed:
				end_stroke()

# -------------------------------------------------------------------------------------------------
func _add_point_at_current_mouse_pos(pressure: float) -> void:
	var brush_position: Vector2 = _brush_cursor.global_position
	pressure = pressure_curve.interpolate(pressure)
	add_stroke_point(brush_position, pressure)
