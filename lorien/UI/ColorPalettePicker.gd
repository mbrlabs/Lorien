class_name ColorPalettePicker
extends PanelContainer

# -------------------------------------------------------------------------------------------------
const PALETTE_BUTTON = preload("res://UI/Components/PaletteButton.tscn")

# -------------------------------------------------------------------------------------------------
signal color_changed(color)

# -------------------------------------------------------------------------------------------------
export var add_new_palette_dialog_path: NodePath
export var toolbar_path: NodePath

onready var _toolbar = get_node(toolbar_path)
onready var _palette_selection_button: OptionButton = $MarginContainer/VBoxContainer/Buttons/PaletteSelectionButton
onready var _color_grid: GridContainer = $MarginContainer/VBoxContainer/ColorGrid

var _active_palette_button: PaletteButton

# -------------------------------------------------------------------------------------------------
func _ready() -> void:
	update_palettes()

# -------------------------------------------------------------------------------------------------
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton && event.pressed:
		var should_hide := !Utils.is_mouse_in_control(self)
		should_hide = should_hide && !Utils.is_mouse_in_control(_toolbar.get_brush_color_button())
		should_hide = should_hide && !get_parent().is_dialog_open()
		should_hide = should_hide && !_palette_selection_button.get_popup().visible
		if visible && should_hide:
			hide()
	
	if event is InputEventKey && event.pressed && event.scancode == KEY_ESCAPE:
		hide()

# -------------------------------------------------------------------------------------------------
func update_palettes() -> void:
	# Add palettes to the dropdown
	_palette_selection_button.clear()
	for palette in PaletteManager.palettes:
		_palette_selection_button.add_item(palette.name)
	
	# Load the active palette
	var active_palette := PaletteManager.get_active_palette()
	_palette_selection_button.selected = PaletteManager.get_active_palette_index()
	_create_buttons(active_palette)
	_activate_palette_button(_color_grid.get_child(0))

# -------------------------------------------------------------------------------------------------
func _create_buttons(palette: Palette) -> void:
	# Remove old buttons
	_active_palette_button = null
	for c in _color_grid.get_children():
		_color_grid.remove_child(c)
		c.queue_free()
	
	# Add new ones
	for color in palette.colors:
		var button: PaletteButton = PALETTE_BUTTON.instance()
		_color_grid.add_child(button)
		button.color = color
		button.connect("pressed", self, "_on_platte_button_pressed", [button])
	
	# Adjust ui size
	rect_size = get_combined_minimum_size()
	
# -------------------------------------------------------------------------------------------------
func _activate_palette_button(button: PaletteButton) -> void:
	if _active_palette_button != null:
		_active_palette_button.selected = false
	_active_palette_button = button
	_active_palette_button.selected = true

# -------------------------------------------------------------------------------------------------
func _on_platte_button_pressed(button: PaletteButton) -> void:
	_activate_palette_button(button)
	emit_signal("color_changed", button.color)

# -------------------------------------------------------------------------------------------------
func _on_PaletteSelectionButton_item_selected(index: int) -> void:
	PaletteManager.set_active_palette_index(index)
	PaletteManager.save()
	_create_buttons(PaletteManager.get_active_palette())
	_activate_palette_button(_color_grid.get_child(0))

# -------------------------------------------------------------------------------------------------
func _on_AddPaletteButton_pressed() -> void:
	get_node(add_new_palette_dialog_path).popup_centered()
