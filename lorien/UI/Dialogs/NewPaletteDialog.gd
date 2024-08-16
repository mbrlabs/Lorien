class_name NewPaletteDialog
extends Window

# -------------------------------------------------------------------------------------------------
signal new_palette_created(palette)

# -------------------------------------------------------------------------------------------------
@onready var _line_edit: LineEdit = $MarginContainer/Container/LineEdit
@onready var _save_button: Button = $MarginContainer/Container/HBoxContainer/SaveButton
@onready var _cancel_button: Button = $MarginContainer/Container/HBoxContainer/CancelButton

var duplicate_current_palette := false

# -------------------------------------------------------------------------------------------------
func _ready() -> void:
	_save_button.pressed.connect(_on_SaveButton_pressed)
	_cancel_button.pressed.connect(_on_CancelButton_pressed)
	
	about_to_popup.connect(_on_NewPaletteDialog_about_to_show)
	close_requested.connect(_on_NewPaletteDialog_close_requested)
	
# -------------------------------------------------------------------------------------------------
func _on_SaveButton_pressed() -> void:
	var pallete_name := _line_edit.text
	if !pallete_name.is_empty():
		var palette: Palette
		if duplicate_current_palette:
			palette = PaletteManager.duplicate_palette(PaletteManager.get_active_palette(), pallete_name)
		else:
			palette = PaletteManager.create_custom_palette(pallete_name)
		
		if palette != null:
			PaletteManager.save()
			hide()
			emit_signal("new_palette_created", palette)
			duplicate_current_palette = false
			
# -------------------------------------------------------------------------------------------------
func _on_CancelButton_pressed() -> void:
	hide()

# -------------------------------------------------------------------------------------------------
func _on_NewPaletteDialog_close_requested() -> void:
	_line_edit.clear()

# -------------------------------------------------------------------------------------------------
func _on_NewPaletteDialog_about_to_show() -> void:
	# Set title
	if duplicate_current_palette:
		title = tr("NEW_PALETTE_DIALOG_DUPLICATE_TITLE")
	else:
		title = tr("NEW_PALETTE_DIALOG_CREATE_TITLE")
	
	# Grab focus
	await get_tree().idle_frame
	_line_edit.grab_focus()
