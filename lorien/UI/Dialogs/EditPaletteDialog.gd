class_name EditPaletteDialog
extends MarginContainer

# -------------------------------------------------------------------------------------------------
const PALETTE_BUTTON = preload("res://UI/Components/PaletteButton.tscn")

# -------------------------------------------------------------------------------------------------
signal palette_changed

# -------------------------------------------------------------------------------------------------
@onready var _name_line_edit: LineEdit = $HBoxContainer/VBoxContainer/NameLineEdit
@onready var _color_picker: ColorPicker = $HBoxContainer/ColorPicker
@onready var _color_grid: GridContainer = $HBoxContainer/VBoxContainer/ColorGrid
@onready var _add_color_button: Button = $HBoxContainer/VBoxContainer/AddColorButton
@onready var _remove_color_button: Button = $HBoxContainer/VBoxContainer/RemoveColorButton

var _palette: Palette
var _active_button: PaletteButton = null
var _active_button_index := -1
var _disable_color_picker_callback := false
var _palette_edited := false

# -------------------------------------------------------------------------------------------------
func _ready() -> void:
	get_parent().close_requested.connect(_on_EditPaletteDialog_close_requested)
	_color_picker.color_changed.connect(_on_ColorPicker_color_changed)
	_name_line_edit.text_changed.connect(_on_NameLineEdit_text_changed)
	_add_color_button.pressed.connect(_on_AddColorButton_pressed)
	_remove_color_button.pressed.connect(_on_RemoveColorButton_pressed)

# -------------------------------------------------------------------------------------------------
func setup(palette: Palette, color_index: int) -> void:
	# Reset internal stuff
	_palette = palette
	_palette_edited = false
	_disable_color_picker_callback = false
	
	# Clear color grid
	for c in _color_grid.get_children():
		_color_grid.remove_child(c)
		c.queue_free()
	
	# Fill color grid
	var index := 0
	for color: Color in palette.colors:
		var button: PaletteButton = PALETTE_BUTTON.instantiate()
		_color_grid.add_child(button)
		button.color = color
		button.pressed.connect(_on_platte_button_pressed.bind(button, index))
		index += 1
	
	# Set name
	_name_line_edit.text = palette.name
	
	# Select active color
	_active_button_index = color_index
	_active_button = _color_grid.get_child(_active_button_index)
	_active_button.selected = true
	_color_picker.color = _active_button.color
	
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
		_palette.colors[_active_button_index] = color
		
# -------------------------------------------------------------------------------------------------
func _on_EditPaletteDialog_close_requested() -> void:
	if _palette_edited:
		PaletteManager.save()
		emit_signal("palette_changed")
	get_parent().hide()

# -------------------------------------------------------------------------------------------------
func _on_NameLineEdit_text_changed(new_text: String) -> void:
	_palette_edited = true
	_palette.name = new_text

# -------------------------------------------------------------------------------------------------
func _on_AddColorButton_pressed() -> void:
	if _palette.colors.size() < Config.MAX_PALETTE_SIZE:
		_palette_edited = true
		var new_color := _palette.colors[_active_button_index]
		
		# Create a new color array with the new color
		var arr := []
		for c in _palette.colors:
			arr.append(c)
		arr.append(new_color)
		_palette.colors = PackedColorArray(arr)
		
		# Add the color button
		var button: PaletteButton = PALETTE_BUTTON.instantiate()
		_color_grid.add_child(button)
		button.color = new_color
		button.pressed.connect(_on_platte_button_pressed.bind(button, _color_grid.get_child_count() - 1))
		_on_platte_button_pressed(button, _color_grid.get_child_count() - 1)
	
# -------------------------------------------------------------------------------------------------
func _on_RemoveColorButton_pressed() -> void:
	if _palette.colors.size() > Config.MIN_PALETTE_SIZE:
		_palette_edited = true
		
		# Create a new color array with the color removed
		var arr: Array[Color]
		var index := 0
		for c: Color in _palette.colors:
			if index != _active_button_index:
				arr.append(c)
			index += 1
		_palette.colors = PackedColorArray(arr)

		_color_grid.remove_child(_active_button)
		_active_button_index = min(_active_button_index, _color_grid.get_child_count() - 1)
		_active_button = _color_grid.get_child(_active_button_index)
		_on_platte_button_pressed(_active_button, _color_grid.get_child_count() - 1)
