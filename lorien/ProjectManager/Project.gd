class_name Project

var id: int # this is used at runtime only and will not be persisted; project ids are not garanteed to be the same between restarts
var undo_redo: UndoRedo

var dirty := false
var loaded := false

var filepath: String
var meta_data: Dictionary
var strokes: Array # Array<BrushStroke>

# -------------------------------------------------------------------------------------------------
func _init():
	undo_redo = UndoRedo.new()

# -------------------------------------------------------------------------------------------------
func clear() -> void:
	undo_redo.free()
	undo_redo = null
	meta_data.clear()
	strokes.clear()

# -------------------------------------------------------------------------------------------------
func add_stroke(stroke: BrushStroke) -> void:
	strokes.append(stroke)
	dirty = true

# -------------------------------------------------------------------------------------------------
func get_filename() -> String:
	if filepath.empty():
		return "Untitled"
	return filepath.get_file()

# -------------------------------------------------------------------------------------------------
func _to_string() -> String:
	return "%s: id: %d, loaded: %s, dirty: %s" % [filepath, id, loaded, dirty]
