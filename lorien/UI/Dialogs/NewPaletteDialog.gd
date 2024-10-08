class_name NewPaletteDialog
extends MarginContainer

# -------------------------------------------------------------------------------------------------
signal new_palette_created(palette: Palette)

# -------------------------------------------------------------------------------------------------
@onready var _line_edit: LineEdit = $Container/LineEdit
@onready var _save_button: Button = $Container/HBoxContainer/SaveButton
@onready var _cancel_button: Button = $Container/HBoxContainer/CancelButton

var duplicate_current_palette := false

# -------------------------------------------------------------------------------------------------
func _ready() -> void:
	_save_button.pressed.connect(_on_SaveButton_pressed)
	_cancel_button.pressed.connect(_on_CancelButton_pressed)
	
	get_parent().about_to_popup.connect(_on_about_to_popup)
	get_parent().close_requested.connect(_on_close_requested)
	
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
			new_palette_created.emit(palette)
			duplicate_current_palette = false
			get_parent().hide()
			
# -------------------------------------------------------------------------------------------------
func _on_CancelButton_pressed() -> void:
	_line_edit.clear()
	get_parent().hide()

# -------------------------------------------------------------------------------------------------
func _on_close_requested() -> void:
	_line_edit.clear()
	get_parent().hide()

# -------------------------------------------------------------------------------------------------
func _on_about_to_popup() -> void:
	# Set title
	if duplicate_current_palette:
		get_parent().title = tr("NEW_PALETTE_DIALOG_DUPLICATE_TITLE")
	else:
		get_parent().title = tr("NEW_PALETTE_DIALOG_CREATE_TITLE")
	
	# TODO: Grab focus
