class_name SelectTool
extends CanvasTool

var selecting: bool = false setget set_selecting, is_selecting
var multi: bool = false
var _selecting_start_pos: Vector2 = Vector2.ZERO
var _selecting_end_pos: Vector2 = Vector2.ZERO
var _cursor: Node2D

func _ready():
	_cursor = get_node(cursor_path)
	set_enabled(false)

func set_enabled(e: bool) -> void:
	.set_enabled(e)
	if e:
		_cursor.global_position = xform_vector2(get_viewport().get_mouse_position())
		_cursor.show()
	else:
		_cursor.hide()

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.scancode == KEY_SHIFT:
			multi = event.pressed
	
	if event is InputEventMouseMotion:
		_cursor.global_position = xform_vector2(event.global_position)
		if is_selecting():
			_selecting_end_pos = xform_vector2_relative(event.global_position)
			_canvas.compute_selection(_selecting_start_pos, _selecting_end_pos)
			_canvas.update()
	
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if not is_selecting():
				if event.pressed:
					_selecting_start_pos = xform_vector2_relative(event.global_position)
					set_selecting(true)
			if !event.pressed:
				if is_selecting():
					set_selecting(false)


func set_selecting(_selecting: bool, _multi: bool = false) -> void:
	selecting = _selecting
	if not _selecting:
		_canvas.update()
		_selecting_start_pos = Vector2.ZERO
		_selecting_end_pos = _selecting_start_pos
		_canvas.confirm_selections()
	else:
		if not multi:
			_canvas.deselect_all_strokes()



func is_selecting() -> bool:
	return selecting

