extends WindowDialog

# -------------------------------------------------------------------------------------------------
const PALETTE_BUTTON = preload("res://UI/Components/PaletteButton.tscn")

# -------------------------------------------------------------------------------------------------
signal palette_changed

# -------------------------------------------------------------------------------------------------
onready var _name_line_edit: LineEdit = $MarginContainer/HBoxContainer/VBoxContainer/NameLineEdit
onready var _color_picker: ColorPicker = $MarginContainer/HBoxContainer/ColorPicker
onready var _color_grid: GridContainer = $MarginContainer/HBoxContainer/VBoxContainer/ColorGrid

var _active_button: PaletteButton = null
var _active_button_index := -1
var _disable_color_picker_callback := false
var _palette_edited := false

# -------------------------------------------------------------------------------------------------
func _setup() -> void:
	_palette_edited = false
	
	var palette := PaletteManager.get_active_palette()
	_name_line_edit.text = palette.name
	
	# Clear color grid
	for c in _color_grid.get_children():
		_color_grid.remove_child(c)
		c.queue_free()
	
	# Fill color grid
	var index := 0
	for color in palette.colors:
		var button: PaletteButton = PALETTE_BUTTON.instance()
		_color_grid.add_child(button)
		button.color = color
		button.connect("pressed", self, "_on_platte_button_pressed", [button, index])
		index += 1
		
# -------------------------------------------------------------------------------------------------
func _on_platte_button_pressed(button: PaletteButton, index: int) -> void:
	if _active_button != null:
		_active_button.selected = false
	button.selected = true
	_active_button = button
	_color_picker.color = button.color
	_active_button_index = index
	_disable_color_picker_callback = true
	
# -------------------------------------------------------------------------------------------------
func _on_ColorPicker_color_changed(color: Color) -> void:
	if _disable_color_picker_callback:
		_disable_color_picker_callback = false
	elif _active_button != null:
		_palette_edited = true
		_active_button.color = color
		var palette := PaletteManager.get_active_palette()
		palette.colors[_active_button_index] = color
		
# -------------------------------------------------------------------------------------------------
func _on_EditPaletteDialog_about_to_show() -> void:
	_setup()

# -------------------------------------------------------------------------------------------------
func _on_EditPaletteDialog_popup_hide() -> void:
	if _palette_edited:
		emit_signal("palette_changed")
