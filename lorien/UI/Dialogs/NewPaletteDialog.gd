extends WindowDialog

# -------------------------------------------------------------------------------------------------
signal new_palette_created(palette)

# -------------------------------------------------------------------------------------------------
onready var _line_edit: LineEdit = $MarginContainer/Container/LineEdit

# -------------------------------------------------------------------------------------------------
func _on_SaveButton_pressed() -> void:
	var name := _line_edit.text
	if !name.empty():
		var palette := PaletteManager.create_custom_palette(name)
		if palette != null:
			PaletteManager.save()
			hide()
			emit_signal("new_palette_created", palette)

# -------------------------------------------------------------------------------------------------
func _on_CancelButton_pressed() -> void:
	hide()

# -------------------------------------------------------------------------------------------------
func _on_NewPaletteDialog_popup_hide() -> void:
	_line_edit.clear()
