class_name DeletePaletteDialog
extends MarginContainer

# -------------------------------------------------------------------------------------------------
signal palette_deleted

# -------------------------------------------------------------------------------------------------
@onready var _text: Label = $Container/Label
@onready var _delete_button: Button = $Container/HBoxContainer/DeleteButton
@onready var _cancel_button: Button = $Container/HBoxContainer/CancelButton

# -------------------------------------------------------------------------------------------------
func _ready() -> void:
	get_parent().about_to_popup.connect(_on_about_to_popup)
	_delete_button.pressed.connect(_on_delete_pressed)
	_cancel_button.pressed.connect(_on_cancel_pressed)
	
# -------------------------------------------------------------------------------------------------
func _on_about_to_popup() -> void:
	var palette := PaletteManager.get_active_palette()
	_text.text = tr("DELETE_PALETTE_DIALOG_TEXT") + " " + palette.name
	get_parent().hide()

# -------------------------------------------------------------------------------------------------
func _on_delete_pressed() -> void:
	var palette := PaletteManager.get_active_palette()
	if !palette.builtin:
		PaletteManager.remove_palette(palette)
		PaletteManager.save()
		palette_deleted.emit()
		get_parent().hide()

# -------------------------------------------------------------------------------------------------
func _on_cancel_pressed() -> void:
	get_parent().hide()

# -------------------------------------------------------------------------------------------------
func _input(event):
	if event is InputEventKey:
		if event.keycode==KEY_D:
			_on_delete_pressed()
		elif event.keycode==KEY_C || event.keycode==KEY_ESCAPE:
			_on_cancel_pressed()
# -------------------------------------------------------------------------------------------------
func on_unhide():
	# The _cancel_button is focused by default
	_cancel_button.grab_focus()
	pass
# -------------------------------------------------------------------------------------------------
func _notification(what: int) -> void:
	if what ==NOTIFICATION_VISIBILITY_CHANGED and is_visible_in_tree():
			#runs when visibility changes and is_visible
			on_unhide()
