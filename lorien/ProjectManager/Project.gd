class_name Project


signal new_action_committed()

var id: int # this is used at runtime only and will not be persisted; project ids are not garanteed to be the same between restarts
var undo_redo: UndoRedo

var dirty := false setget set_is_dirty
var loaded := false

var filepath: String
var meta_data: Dictionary
var strokes: Array # Array<BrushStroke>

# -------------------------------------------------------------------------------------------------
func _init():
	undo_redo = UndoRedo.new()

# -------------------------------------------------------------------------------------------------
func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		if undo_redo != null:
			undo_redo.free()

# -------------------------------------------------------------------------------------------------
func set_is_dirty(new_value: bool) -> void:
	dirty = new_value
	emit_signal("new_action_committed")

# -------------------------------------------------------------------------------------------------
func clear() -> void:
	undo_redo.free()
	undo_redo = null
	meta_data.clear()
	strokes.clear()

# -------------------------------------------------------------------------------------------------
func add_stroke(stroke: BrushStroke) -> void:
	strokes.append(stroke)
	set_is_dirty(true)

# -------------------------------------------------------------------------------------------------
func remove_last_stroke() -> void:
	if !strokes.empty():
		strokes.pop_back()

# -------------------------------------------------------------------------------------------------
func get_filename() -> String:
	if filepath.empty():
		return "Untitled"
	return filepath.get_file()

# -------------------------------------------------------------------------------------------------
func _to_string() -> String:
	return "%s: id: %d, loaded: %s, dirty: %s" % [filepath, id, loaded, dirty]
