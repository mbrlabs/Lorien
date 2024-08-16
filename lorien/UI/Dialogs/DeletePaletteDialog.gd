class_name DeletePaletteDialog
extends Window

# -------------------------------------------------------------------------------------------------
signal palette_deleted

# -------------------------------------------------------------------------------------------------
@onready var _text: Label = $MarginContainer/Container/Label
@onready var _delete_button: Button = $MarginContainer/Container/HBoxContainer/DeleteButton
@onready var _cancel_button: Button = $MarginContainer/Container/HBoxContainer/CancelButton

# -------------------------------------------------------------------------------------------------
func _ready() -> void:
	connect("about_to_popup", Callable(self, "_on_DeletePaletteDialog_about_to_show"))
	_delete_button.connect("pressed", Callable(self, "_on_DeleteButton_pressed"))
	_cancel_button.connect("pressed", Callable(self, "_on_CancelButton_pressed"))
	
# -------------------------------------------------------------------------------------------------
func _on_DeletePaletteDialog_about_to_show() -> void:
	var palette := PaletteManager.get_active_palette()
	_text.text = tr("DELETE_PALETTE_DIALOG_TEXT") + " " + palette.name

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
