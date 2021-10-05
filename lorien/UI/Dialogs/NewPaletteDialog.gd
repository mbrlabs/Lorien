class_name NewPaletteDialog
extends WindowDialog

# -------------------------------------------------------------------------------------------------
signal new_palette_created(palette)

# -------------------------------------------------------------------------------------------------
onready var _line_edit: LineEdit = $MarginContainer/Container/LineEdit

var duplicate_current_palette := false

# -------------------------------------------------------------------------------------------------
func _on_SaveButton_pressed() -> void:
	var name := _line_edit.text
	if !name.empty():
		var palette: Palette
		if duplicate_current_palette:
			palette = PaletteManager.duplicate_palette(PaletteManager.get_active_palette(), name)
		else:
			palette = PaletteManager.create_custom_palette(name)
		
		if palette != null:
			PaletteManager.save()
			hide()
			emit_signal("new_palette_created", palette)
			duplicate_current_palette = false
			
# -------------------------------------------------------------------------------------------------
func _on_CancelButton_pressed() -> void:
	hide()

# -------------------------------------------------------------------------------------------------
func _on_NewPaletteDialog_popup_hide() -> void:
	_line_edit.clear()

# -------------------------------------------------------------------------------------------------
func _on_NewPaletteDialog_about_to_show() -> void:
	if duplicate_current_palette:
		window_title = "Duplicate Palette" # TODO: i18n
	else:
		window_title = tr("NEW_PALETTE_DIALOG_TITLE")
