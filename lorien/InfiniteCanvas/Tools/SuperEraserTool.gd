class_name SuperEraserTool
extends CanvasTool

# -------------------------------------------------------------------------------------------------
var _last_mouse_motion: InputEventMouseMotion
var _removed_strokes := [] # BrushStroke -> Vector2
var _bounding_box_cache = {} # BrushStroke -> Rect2

# -------------------------------------------------------------------------------------------------
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_last_mouse_motion = event
		_cursor.global_position = xform_vector2(event.global_position)

	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.pressed && _last_mouse_motion != null:
				if _bounding_box_cache.empty():
					_bounding_box_cache = Utils.calculte_bounding_boxes(_canvas.get_all_strokes(), _canvas.get_camera())
				_last_mouse_motion.global_position = event.global_position
				_last_mouse_motion.position = event.position
				performing_stroke = true
			elif !event.pressed:
				_bounding_box_cache.clear()
				performing_stroke = false

# -------------------------------------------------------------------------------------------------
func _process(delta: float) -> void:
	if performing_stroke && _last_mouse_motion != null:
		_remove_stroke(_last_mouse_motion.global_position)
		_add_undoredo_action_for_erased_strokes()
		_last_mouse_motion = null

# ------------------------------------------------------------------------------------------------
func _stroke_intersects_circle(stroke: BrushStroke, circle_position: Vector2) -> bool:
	# Check if the cursor is inside bounding box; if it's not, there is no way we are intersecting the stroke
	var bounding_box: Rect2 = _bounding_box_cache[stroke]
	if !bounding_box.has_point(_last_mouse_motion.global_position):
		return false
	
	# Check every segment of the brush stroke for an intersection with the curser
	var brush_size := float(_cursor._brush_size)
	for i in stroke.points.size() - 1:
		var radius: float = (float(stroke.pressures[i]) / 255.0) * brush_size
		var start = stroke.calculte_absolute_position_of_point(stroke.points[i], _canvas.get_camera())
		var end = stroke.calculte_absolute_position_of_point(stroke.points[i+1], _canvas.get_camera())
		if Geometry.segment_intersects_circle(start, end, circle_position, radius) >= 0:
			return true
	return false

# -------------------------------------------------------------------------------------------------
func _remove_stroke(brush_position: Vector2) -> void:
	for stroke in _canvas.get_strokes_in_camera_frustrum():
		if !_removed_strokes.has(stroke) && _stroke_intersects_circle(stroke, brush_position):
			_removed_strokes.append(stroke)
		
# ------------------------------------------------------------------------------------------------
func _add_undoredo_action_for_erased_strokes() -> void:
	var project: Project = ProjectManager.get_active_project()
	if _removed_strokes.size():
		project.undo_redo.create_action("Erase Stroke")
		for stroke in _removed_strokes:
			_removed_strokes.erase(stroke)
			project.undo_redo.add_do_method(_canvas, "_do_delete_stroke", stroke)
			project.undo_redo.add_undo_method(_canvas, "_undo_delete_stroke", stroke)
		project.undo_redo.commit_action()
		project.dirty = true

