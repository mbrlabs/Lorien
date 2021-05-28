class_name MoveTool
extends CanvasTool

# ------------------------------------------------------------------------------------------------
const META_OFFSET := "offset"

# ------------------------------------------------------------------------------------------------
var _moving := false
var _initial_positions := {} # BrushStroke -> Vector2

# ------------------------------------------------------------------------------------------------
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_cursor.global_position = xform_vector2(event.global_position)
	
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT && !_get_strokes().empty():
			if event.pressed:
				_moving = true
				for s in _get_strokes():
					_initial_positions[s] = s.global_position
			
				if event.pressed:
					_offset_selected_strokes(_cursor.global_position)
			else:
				_moving = false
				_add_undoredo_action()
				_initial_positions.clear()

# ------------------------------------------------------------------------------------------------
func _add_undoredo_action() -> void:
	var project: Project = ProjectManager.get_active_project()
	project.undo_redo.create_action("Move Strokes")
	for stroke in _initial_positions.keys():
		project.undo_redo.add_do_property(stroke, "global_position", stroke.global_position)
		project.undo_redo.add_undo_property(stroke, "global_position", _initial_positions[stroke])
	project.undo_redo.commit_action()

# ------------------------------------------------------------------------------------------------
func _process(delta: float) -> void:
	if _moving:
		_move_selected_strokes()

# -------------------------------------------------------------------------------------------------
func _offset_selected_strokes(offset: Vector2) -> void:
	for stroke in _get_strokes():
		stroke.set_meta(META_OFFSET, stroke.position - offset)

# -------------------------------------------------------------------------------------------------
func _move_selected_strokes() -> void:
	for stroke in _get_strokes():
		stroke.global_position = stroke.get_meta(META_OFFSET) + _cursor.global_position

# -------------------------------------------------------------------------------------------------
func _get_strokes() -> Array:
	return get_tree().get_nodes_in_group(Types.CANVAS_GROUP_SELECTED_STROKES)
