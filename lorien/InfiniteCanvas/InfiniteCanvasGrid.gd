class_name InfiniteCanvasGrid
extends Node2D

# -------------------------------------------------------------------------------------------------
const GRID_SIZE := 25.0
const COLOR := Color.red

# -------------------------------------------------------------------------------------------------
export var camera_path: NodePath
var _enabled: bool
var _camera: Camera2D

# -------------------------------------------------------------------------------------------------
func _ready():
	_camera = get_node(camera_path)
	_camera.connect("zoom_changed", self, "_on_zoom_changed")
	_camera.connect("position_changed", self, "_on_position_changed")
	get_viewport().connect("size_changed", self, "_on_viewport_size_changed")

# -------------------------------------------------------------------------------------------------
func enable(e: bool) -> void:
	set_process(e)
	visible = e

# -------------------------------------------------------------------------------------------------
func _on_zoom_changed(zoom: float) -> void: update()
func _on_position_changed(pos: Vector2) -> void: update()
func _on_viewport_size_changed() -> void: update()

# -------------------------------------------------------------------------------------------------
func set_canvas_color(c: Color) -> void:
	material.set_shader_param("canvas_color", c)

# -------------------------------------------------------------------------------------------------
func _draw() -> void:
	var size = get_viewport().size  * _camera.zoom
	var zoom = _camera.zoom.x
	var offset = _camera.offset
	
	var grid_size = GRID_SIZE
	if zoom > 50:
		grid_size *= 50
	elif zoom > 25:
		grid_size *= 25
	elif zoom > 10:
		grid_size *= 10
	elif zoom > 5:
		grid_size *= 5
	
	# Vertical lines
	var start_index := int((offset.x - size.x) / grid_size) - 1
	var end_index := int((size.x + offset.x) / grid_size) + 1
	for i in range(start_index, end_index):
		draw_line(Vector2(i * grid_size, offset.y + size.y), Vector2(i * grid_size, offset.y - size.y), COLOR)
	
	# Horizontal lines
	start_index = int((offset.y - size.y) / grid_size) - 1
	end_index = int((size.y + offset.y) / grid_size) + 1
	for i in range(start_index, end_index):
		draw_line(Vector2(offset.x + size.x, i * grid_size), Vector2(offset.x - size.x, i * grid_size), COLOR)
