class_name InfiniteCanvasGrid
extends Node2D

# -------------------------------------------------------------------------------------------------
export var camera_path: NodePath
var _enabled: bool
var _pattern: int = Types.GridPattern.DOTS
var _camera: Camera2D
var _grid_size := Config.DEFAULT_GRID_SIZE
var _grid_color: Color

# -------------------------------------------------------------------------------------------------
func _ready():
	_grid_size = Settings.get_value(Settings.APPEARANCE_GRID_SIZE, Config.DEFAULT_GRID_SIZE)
	_pattern = Settings.get_value(Settings.APPEARANCE_GRID_PATTERN, Config.DEFAULT_GRID_PATTERN)
	
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
func set_grid_size(size: int) -> void:
	_grid_size = size
	update()

# -------------------------------------------------------------------------------------------------
func set_grid_pattern(pattern: int) -> void:
	_pattern = pattern
	update()

# -------------------------------------------------------------------------------------------------
func set_canvas_color(c: Color) -> void:
	_grid_color = c * 1.25
	update()

# -------------------------------------------------------------------------------------------------
func set_grid_scale(size: float):
	_grid_size *= size
	update()

# -------------------------------------------------------------------------------------------------
func _draw() -> void:
	var size = get_viewport().size  * _camera.zoom
	var zoom = _camera.zoom.x
	var offset = _camera.offset
	var grid_size := int(ceil((_grid_size * pow(zoom, 0.75))))
		
	match _pattern:
		Types.GridPattern.DOTS:
			var dot_size := int(ceil(grid_size * 0.12))
			var x_start := int(offset.x / grid_size) - 1
			var x_end := int((size.x + offset.x) / grid_size) + 1
			var y_start := int(offset.y / grid_size) - 1
			var y_end = int((size.y + offset.y) / grid_size) + 1
			
			for x in range(x_start, x_end):
				for y in range(y_start, y_end):
					var pos := Vector2(x, y) * grid_size
					draw_rect(Rect2(pos.x, pos.y, dot_size, dot_size), _grid_color)
		Types.GridPattern.LINES:
			# Vertical lines
			var start_index := int(offset.x / grid_size) - 1
			var end_index := int((size.x + offset.x) / grid_size) + 1
			for i in range(start_index, end_index):
				draw_line(Vector2(i * grid_size, offset.y + size.y), Vector2(i * grid_size, offset.y - size.y), _grid_color)

			# Horizontal lines
			start_index = int(offset.y / grid_size) - 1
			end_index = int((size.y + offset.y) / grid_size) + 1
			for i in range(start_index, end_index):
				draw_line(Vector2(offset.x + size.x, i * grid_size), Vector2(offset.x - size.x, i * grid_size), _grid_color)
