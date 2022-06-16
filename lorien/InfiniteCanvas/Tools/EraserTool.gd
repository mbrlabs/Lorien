class_name EraserTool
extends CanvasTool

# -------------------------------------------------------------------------------------------------
const OVERLAP_THRESHOLD := 0.95
const BOUNDING_BOX_MARGIN := 20.0

# -------------------------------------------------------------------------------------------------
var _last_mouse_position: Vector2
var _removed_strokes := [] # BrushStroke -> Vector2
var _bounding_box_cache = {} # BrushStroke -> Rect2

# -------------------------------------------------------------------------------------------------
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_last_mouse_position = xform_vector2(event.global_position)
		_cursor.global_position = _last_mouse_position
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.pressed:
				if _bounding_box_cache.empty():
					_update_bounding_boxes()
				performing_stroke = true
			elif !event.pressed:
				reset()

# -------------------------------------------------------------------------------------------------
func _process(delta: float) -> void:
	if performing_stroke:
		_remove_stroke(_last_mouse_position)
		_add_undoredo_action_for_erased_strokes()

# ------------------------------------------------------------------------------------------------
func _stroke_intersects_circle(stroke: BrushStroke, circle_position: Vector2) -> bool:
	# Check if the cursor is inside bounding box; if it's not, there is no way we are intersecting the stroke
	var bounding_box: Rect2 = _bounding_box_cache[stroke]
	if !bounding_box.has_point(_last_mouse_position):
		return false

	# Check every segment of the brush stroke for an intersection with the curser
	var eraser_brush_radius := float(_cursor._brush_size) * 0.5
	for i in stroke.points.size() - 1:
		var pressure: float = float(stroke.pressures[i] + stroke.pressures[i+1]) / 2.0
		var segment_radius: float = (pressure / float(BrushStroke.MAX_PRESSURE_VALUE)) * float(stroke.size) * 0.5
		var radius: float = segment_radius + eraser_brush_radius
		var start = stroke.position + stroke.points[i]
		var end = stroke.position + stroke.points[i+1]
		if Geometry.segment_intersects_circle(start, end, circle_position, radius*OVERLAP_THRESHOLD) >= 0:
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

# ------------------------------------------------------------------------------------------------
func _update_bounding_boxes() -> void:
	var strokes: Array = _canvas.get_all_strokes()
	_bounding_box_cache = Utils.calculte_bounding_boxes(strokes, BOUNDING_BOX_MARGIN)
	#$"../Viewport/DebugDraw".set_bounding_boxes(_bounding_box_cache.values())

# ------------------------------------------------------------------------------------------------
func reset() -> void:
	_bounding_box_cache.clear()
	performing_stroke = false
