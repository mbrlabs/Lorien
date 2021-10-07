class_name DeletePaletteDialog
extends WindowDialog

# -------------------------------------------------------------------------------------------------
signal palette_deleted

# -------------------------------------------------------------------------------------------------
onready var _text: Label = $MarginContainer/Container/Label

# -------------------------------------------------------------------------------------------------
func _on_DeletePaletteDialog_about_to_show() -> void:
	var palette := PaletteManager.get_active_palette()
	_text.text = tr("DELETE_PALETTE_DIALOG_TEXT") + " " + palette.name

# -------------------------------------------------------------------------------------------------
func _on_DeletePaletteDialog_popup_hide() -> void:
	pass # Replace with function body.

# -------------------------------------------------------------------------------------------------
func _on_DeleteButton_pressed() -> void:
	var palette := PaletteManager.get_active_palette()
	if !palette.builtin:
		PaletteManager.remove_palette(palette)
		PaletteManager.save()
		hide()
		emit_signal("palette_deleted")

# -------------------------------------------------------------------------------------------------
func _on_CancelButton_pressed() -> void:
	hide()
