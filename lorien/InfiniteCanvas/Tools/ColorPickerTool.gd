class_name ColorPickerTool
extends CanvasTool

var _toolbar: Toolbar
var _viewport: Viewport

# -------------------------------------------------------------------------------------------------
func _ready():
	_toolbar = get_tree().root.find_node("Toolbar", true, false)
	_viewport = get_node("../Viewport")

# -------------------------------------------------------------------------------------------------
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_cursor.global_position = xform_vector2(event.global_position)

	elif event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT && event.pressed:
			var color = _pick_color()
			_toolbar.set_brush_color(color)
	
# -------------------------------------------------------------------------------------------------
func _pick_color() -> Color:
	var img: Image = _canvas.take_screenshot()

	var uv_coords := _viewport.get_mouse_position() / _viewport.size
	uv_coords += Vector2(-0.006, 0.006)
	uv_coords.y = 1.0 - uv_coords.y
	print(uv_coords)
	
	var coords := img.get_size() * uv_coords
	coords = Vector2(min(coords.x, img.get_width()-1), min(coords.y, img.get_height()-1))
	
	img.lock()
	var color := img.get_pixel(coords.x, coords.y)
	img.unlock()
		
	return color
