class_name Project

# Emitted whenever something marks the project as dirty, even if it's already dirty.
signal dirtied

var id: int # this is used at runtime only and will not be persisted; project ids are not garanteed to be the same between restarts
var undo_redo: UndoRedo

var dirty := false:
	set(value):
		dirty = value
		if value == true:
			dirtied.emit()

var loaded := false

var filepath: String
var meta_data: Dictionary
var strokes: Array[BrushStroke]
var textBoxes : Array[TextBox]

# -------------------------------------------------------------------------------------------------
func _init() -> void:
	undo_redo = UndoRedo.new()

# -------------------------------------------------------------------------------------------------
func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		if undo_redo != null:
			undo_redo.free()

# -------------------------------------------------------------------------------------------------
func clear() -> void:
	undo_redo.free()
	undo_redo = null
	meta_data.clear()
	strokes.clear()
	textBoxes.clear()

# -------------------------------------------------------------------------------------------------
func add_stroke(stroke: BrushStroke) -> void:
	strokes.append(stroke)
	dirty = true

# -------------------------------------------------------------------------------------------------
func remove_last_stroke() -> void:
	if !strokes.is_empty():
		strokes.pop_back()

#-------------------------------------------------------------------------------------------------
func add_text_box(textBox : TextBox) -> void:
	textBoxes.append(textBox)
	dirty = true

# -------------------------------------------------------------------------------------------------
func get_scene_file_path() -> String:
	if filepath.is_empty():
		return "PROJECT_NAME_UNTITLED"
	return filepath.get_file()

# -------------------------------------------------------------------------------------------------
func _to_string() -> String:
	return "%s: id: %d, loaded: %s, dirty: %s" % [filepath, id, loaded, dirty]
