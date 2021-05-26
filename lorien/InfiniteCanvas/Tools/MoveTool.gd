class_name MoveTool
extends CanvasTool

# ----------------------------------------------------------------------
var moving: bool = false setget set_moving, is_moving
var offset: Vector2

# ----------------------------------------------------------------------
func _ready():
	_cursor = get_node(cursor_path)
	set_enabled(false)

# ----------------------------------------------------------------------
func set_enabled(e: bool) -> void:
	.set_enabled(e)
	if e:
		_cursor.global_position = xform_vector2(get_viewport().get_mouse_position())
		_cursor.show()
	else:
		_cursor.hide()

# ----------------------------------------------------------------------
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_cursor.global_position = xform_vector2(event.global_position)
	
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			var selected_strokes : Array = get_tree().get_nodes_in_group("selected_strokes")
			if selected_strokes.size():
				for stroke in selected_strokes:
					stroke.set_meta("offset", stroke.position - _cursor.global_position)
			set_moving(event.is_pressed())

# ----------------------------------------------------------------------
func _process(delta):
	if is_moving():
		var selected_strokes : Array = get_tree().get_nodes_in_group("selected_strokes")
		if selected_strokes.size():
			for stroke in selected_strokes:
				stroke.global_position = stroke.get_meta("offset") + _cursor.global_position

# ----------------------------------------------------------------------
func set_moving(_moving: bool) -> void:
	moving = _moving

# ----------------------------------------------------------------------
func is_moving() -> bool:
	return moving
