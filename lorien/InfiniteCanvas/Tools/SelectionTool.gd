class_name SelectionTool
extends CanvasTool

# -------------------------------------------------------------------------------------------------
const BRUSH_STROKE = preload("res://BrushStroke/BrushStroke.tscn")

const META_OFFSET := "offset"
const GROUP_SELECTED_STROKES := "selected_strokes" # selected strokes
const GROUP_STROKES_IN_SELECTION_RECTANGLE := "strokes_in_selection_rectangle" # strokes that are in selection rectangle but not commit (i.e. the user is still selecting)
const GROUP_MARKED_FOR_DESELECTION := "strokes_marked_for_deselection" # strokes that need to be deslected once LMB is released
const GROUP_COPIED_STROKES := "strokes_copied"

enum State {
	NONE,
	SELECTING,
	MOVING
}

# -------------------------------------------------------------------------------------------------
export var selection_rectangle_path: NodePath
var _selection_rectangle: SelectionRectangle
var _state = State.NONE
var _selecting_start_pos: Vector2 = Vector2.ZERO
var _selecting_end_pos: Vector2 = Vector2.ZERO
var _multi_selecting: bool
var _mouse_moved_during_pressed := false
var _stroke_positions_before_move := {} # BrushStroke -> Vector2
var _bounding_box_cache = {} # BrushStroke -> Rect2

# ------------------------------------------------------------------------------------------------
func _ready():
	_selection_rectangle = get_node(selection_rectangle_path)

# ------------------------------------------------------------------------------------------------
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			# LMB down - decide if we should select/multiselect or move the selection
			if event.pressed:
				_selecting_start_pos = xform_vector2_relative(event.global_position)
				if event.shift:
					_state = State.SELECTING
					_multi_selecting = true
					_build_bounding_boxes()
				elif get_selected_strokes().size() == 0:
					_state = State.SELECTING
					_multi_selecting = false
					_build_bounding_boxes()
				else:
					_state = State.MOVING
					_mouse_moved_during_pressed = false
					_offset_selected_strokes(_cursor.global_position)
					for s in get_selected_strokes():
						_stroke_positions_before_move[s] = s.global_position
			# LMB up - stop selection or movement
			else:
				if _state == State.SELECTING:
					_state = State.NONE
					_selection_rectangle.reset()
					_selection_rectangle.update()
					_commit_strokes_under_selection_rectangle()
					_deselect_marked_strokes()
					if get_selected_strokes().size() > 0:
						_cursor.mode = SelectionCursor.Mode.MOVE
				elif _state == State.MOVING:
					_state = State.NONE
					if _mouse_moved_during_pressed:
						_add_undoredo_action_for_moved_strokes()
						_stroke_positions_before_move.clear()
					else:
						deselect_all_strokes()
					_mouse_moved_during_pressed = false
						
		# RMB down - just deselect
		elif event.button_index == BUTTON_RIGHT && event.pressed && _state == State.NONE:
			deselect_all_strokes()
	
	# Mouse movement: move the selection
	elif event is InputEventMouseMotion:
		_cursor.global_position = xform_vector2(event.global_position)
		if _state == State.SELECTING:
			_selecting_end_pos = xform_vector2_relative(event.global_position)
			compute_selection(_selecting_start_pos, _selecting_end_pos)
			_selection_rectangle.start_position = _selecting_start_pos
			_selection_rectangle.end_position = _selecting_end_pos
			_selection_rectangle.update()
		elif _state == State.MOVING:
			_mouse_moved_during_pressed = true
			_move_selected_strokes()
	
	# Shift click - switch between move/select cursor mode
	elif event is InputEventKey:
		if event.scancode == KEY_SHIFT:
			if event.pressed:
				_cursor.mode = SelectionCursor.Mode.SELECT
			elif get_selected_strokes().size() > 0:
				_cursor.mode = SelectionCursor.Mode.MOVE

# ------------------------------------------------------------------------------------------------
func _process(delta: float) -> void:
	# Copy selected strokes
	if Input.is_action_just_pressed("copy_strokes") || Input.is_action_just_pressed("duplicate_strokes"):
		var strokes := get_selected_strokes()
		if strokes.size() > 0:
			Utils.remove_group_from_all_nodes(GROUP_COPIED_STROKES)
			for stroke in strokes:
				stroke.add_to_group(GROUP_COPIED_STROKES)
			print("Copied %d strokes" % strokes.size())
	
	# Paste strokes
	if Input.is_action_just_pressed("paste_strokes") || Input.is_action_just_pressed("duplicate_strokes"):
		var strokes := get_tree().get_nodes_in_group(GROUP_COPIED_STROKES)
		if !strokes.empty():
			deselect_all_strokes()
			_cursor.mode = SelectionCursor.Mode.MOVE
			_paste_strokes(strokes)

# ------------------------------------------------------------------------------------------------
func compute_selection(start_pos: Vector2, end_pos: Vector2) -> void:
	var selection_rect : Rect2 = Utils.calculate_rect(start_pos, end_pos)
	for stroke in _canvas.get_strokes_in_camera_frustrum():
		var bounding_box: Rect2 = _bounding_box_cache[stroke]
		var is_inside_selection_rect := false
		if selection_rect.intersects(bounding_box):
			for point in stroke.points:
				if selection_rect.has_point(_calc_abs_stroke_point(point, stroke)):
					is_inside_selection_rect = true
					break
		_set_stroke_selected(stroke, is_inside_selection_rect)
	_canvas.info.selected_lines = get_selected_strokes().size()

# ------------------------------------------------------------------------------------------------
func _paste_strokes(strokes: Array) -> void:
	# Calculate offset at center
	var top_left := Vector2(100000000, 100000000)
	var bottom_right := Vector2(-100000000, -100000000)
	
	for stroke in strokes:
		top_left.x = min(top_left.x, stroke.top_left_pos.x)
		top_left.y = min(top_left.y, stroke.top_left_pos.y)
		bottom_right.x = max(bottom_right.x, stroke.bottom_right_pos.x)
		bottom_right.y = max(bottom_right.y, stroke.bottom_right_pos.y)
	var offset := _cursor.global_position - (top_left + (bottom_right - top_left) / 2.0)
	
	# Duplicate the strokes 
	var duplicates := []
	for stroke in strokes:
		var dup := _duplicate_stroke(stroke, offset)
		dup.add_to_group(GROUP_SELECTED_STROKES)
		dup.modulate = Config.DEFAULT_SELECTION_COLOR
		duplicates.append(dup)
	
	_canvas.add_strokes(duplicates)
	print("Pasted %d strokes (offset: %s)" % [strokes.size(), offset])

# ------------------------------------------------------------------------------------------------
func _duplicate_stroke(stroke: BrushStroke, offset: Vector2) -> BrushStroke:	
	var dup: BrushStroke = BRUSH_STROKE.instance()
	dup.global_position = stroke.global_position
	dup.eraser = stroke.eraser
	dup.size = stroke.size
	dup.color = stroke.color
	dup.pressures = stroke.pressures.duplicate()
	for point in stroke.points:
		dup.points.append(point + offset)
	return dup

# ------------------------------------------------------------------------------------------------
func _build_bounding_boxes() -> void:
	_bounding_box_cache.clear()
	for stroke in _canvas.get_all_strokes():
		var top_left := _calc_abs_stroke_point(stroke.top_left_pos, stroke)
		var bottom_right := _calc_abs_stroke_point(stroke.bottom_right_pos, stroke)
		var bounding_box := Utils.calculate_rect(top_left, bottom_right)
		_bounding_box_cache[stroke] = bounding_box

# ------------------------------------------------------------------------------------------------
func _calc_abs_stroke_point(p: Vector2, stroke: BrushStroke) -> Vector2:
	return (p + stroke.position - _canvas.get_camera_offset()) / _canvas.get_camera_zoom()

# ------------------------------------------------------------------------------------------------
func _set_stroke_selected(stroke: BrushStroke, is_inside_rect: bool = true) -> void:
	if is_inside_rect:
		if stroke.is_in_group(GROUP_SELECTED_STROKES):
			stroke.modulate = Color.white
			stroke.add_to_group(GROUP_MARKED_FOR_DESELECTION)
		else:
			stroke.modulate = Config.DEFAULT_SELECTION_COLOR
			stroke.add_to_group(GROUP_STROKES_IN_SELECTION_RECTANGLE)
	else:
		if stroke.is_in_group(GROUP_MARKED_FOR_DESELECTION):
			stroke.modulate = Config.DEFAULT_SELECTION_COLOR
			stroke.remove_from_group(GROUP_MARKED_FOR_DESELECTION)
		
		if stroke.is_in_group(GROUP_STROKES_IN_SELECTION_RECTANGLE) && !stroke.is_in_group(GROUP_SELECTED_STROKES):
			stroke.remove_from_group(GROUP_STROKES_IN_SELECTION_RECTANGLE)
			stroke.modulate = Color.white

# ------------------------------------------------------------------------------------------------
func _add_undoredo_action_for_moved_strokes() -> void:
	var project: Project = ProjectManager.get_active_project()
	project.undo_redo.create_action("Move Strokes")
	for stroke in _stroke_positions_before_move.keys():
		project.undo_redo.add_do_property(stroke, "global_position", stroke.global_position)
		project.undo_redo.add_undo_property(stroke, "global_position", _stroke_positions_before_move[stroke])
	project.undo_redo.commit_action()
	project.dirty = true

# -------------------------------------------------------------------------------------------------
func _offset_selected_strokes(offset: Vector2) -> void:
	for stroke in get_selected_strokes():
		stroke.set_meta(META_OFFSET, stroke.position - offset)

# -------------------------------------------------------------------------------------------------
func _move_selected_strokes() -> void:
	for stroke in get_selected_strokes():
		stroke.global_position = stroke.get_meta(META_OFFSET) + _cursor.global_position

# ------------------------------------------------------------------------------------------------
func _commit_strokes_under_selection_rectangle() -> void:
	for stroke in get_tree().get_nodes_in_group(GROUP_STROKES_IN_SELECTION_RECTANGLE):
		stroke.remove_from_group(GROUP_STROKES_IN_SELECTION_RECTANGLE)
		stroke.add_to_group(GROUP_SELECTED_STROKES)

# ------------------------------------------------------------------------------------------------
func _deselect_marked_strokes() -> void:
	for s in get_tree().get_nodes_in_group(GROUP_MARKED_FOR_DESELECTION):
		s.remove_from_group(GROUP_MARKED_FOR_DESELECTION)
		s.remove_from_group(GROUP_SELECTED_STROKES)
		s.modulate = Color.white

# ------------------------------------------------------------------------------------------------
func deselect_all_strokes() -> void:
	var selected_strokes: Array = get_selected_strokes()
	if selected_strokes.size():
		get_tree().set_group(GROUP_SELECTED_STROKES, "modulate", Color.white)
		get_tree().set_group(GROUP_STROKES_IN_SELECTION_RECTANGLE, "modulate", Color.white)
		Utils.remove_group_from_all_nodes(GROUP_SELECTED_STROKES)
		Utils.remove_group_from_all_nodes(GROUP_MARKED_FOR_DESELECTION)
		Utils.remove_group_from_all_nodes(GROUP_STROKES_IN_SELECTION_RECTANGLE)
		
	_canvas.info.selected_lines = 0
	_cursor.mode = SelectionCursor.Mode.SELECT

# ------------------------------------------------------------------------------------------------
func is_selecting() -> bool:
	return _state == State.SELECTING

# ------------------------------------------------------------------------------------------------
func get_selected_strokes() -> Array:
	return get_tree().get_nodes_in_group(GROUP_SELECTED_STROKES)
