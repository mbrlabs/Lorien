class_name CanvasTool, "res://Assets/Icons/tools.png"
extends Node

# -------------------------------------------------------------------------------------------------
const SUBDIVISION_PERCENT := 0.16
const SUBDIVISION_THRESHHOLD := 50.0 # min length in pixels for when subdivision is required 

# -------------------------------------------------------------------------------------------------
@export var cursor_path: NodePath

var _cursor: Sprite2D # This is a BaseCursor. Can't type it.
var _canvas: Node # This is an InfinteCanvas. Can't type it though because of cyclic dependency bugs...
var enabled := false: get = get_enabled, set = set_enabled
var performing_stroke := false

# -------------------------------------------------------------------------------------------------
func _ready():
	_cursor = get_node(cursor_path)
	_canvas = get_parent()
	set_enabled(false)

# -------------------------------------------------------------------------------------------------
func tool_event(event: InputEvent) -> void:
	pass

# -------------------------------------------------------------------------------------------------
func _on_brush_color_changed(color: Color) -> void:
	pass

# -------------------------------------------------------------------------------------------------
func _on_brush_size_changed(size: int) -> void:
	_cursor.change_size(size)

# -------------------------------------------------------------------------------------------------
func get_cursor():
	return _cursor

# -------------------------------------------------------------------------------------------------
func set_enabled(e: bool) -> void:
	enabled = e
	set_process(enabled)
	set_process_input(enabled)
	_cursor.set_visible(enabled)

# -------------------------------------------------------------------------------------------------
func get_enabled() -> bool:
	return enabled

# -------------------------------------------------------------------------------------------------
func start_stroke() -> void:
	_canvas.start_stroke()
	performing_stroke = true

# -------------------------------------------------------------------------------------------------
func add_stroke_point(point: Vector2, pressure: float = 1.0) -> void:
	_canvas.add_stroke_point(point, pressure)

# -------------------------------------------------------------------------------------------------
func remove_last_stroke_point() -> void:
	_canvas.remove_last_stroke_point()

# -------------------------------------------------------------------------------------------------
func add_subdivided_line(from: Vector2, to: Vector2, pressure: float) -> void:
	var dist := from.distance_to(to)
	var dir := from.direction_to(to).normalized()
	var do_subdiv := dist > SUBDIVISION_THRESHHOLD
	if do_subdiv:
		var subdiv_length := dist * SUBDIVISION_PERCENT
		var subdiv_count := int(dist / subdiv_length)
		for i in subdiv_count:
			var point: Vector2 = from + dir*subdiv_length*i
			add_stroke_point(point, pressure)
		
	if !do_subdiv:
		add_stroke_point(from, pressure)
	add_stroke_point(to, pressure)

# -------------------------------------------------------------------------------------------------
func remove_all_stroke_points() -> void:
	_canvas.remove_all_stroke_points()

# -------------------------------------------------------------------------------------------------
func get_current_brush_stroke() -> BrushStroke:
	return _canvas._current_stroke

# -------------------------------------------------------------------------------------------------
func end_stroke() -> void:
	_canvas.end_stroke()
	performing_stroke = false

# -------------------------------------------------------------------------------------------------
func xform_vector2(v: Vector2) -> Vector2:
	return _canvas.get_camera_3d() * (v * _canvas.get_canvas_scale())

# -------------------------------------------------------------------------------------------------
func reset() -> void:
	end_stroke()
