class_name ColorPalettePicker
extends PanelContainer

# -------------------------------------------------------------------------------------------------
const PALETTE_BUTTON = preload("res://UI/Components/PaletteButton.tscn")

# -------------------------------------------------------------------------------------------------
signal color_changed(color)

# -------------------------------------------------------------------------------------------------
export var color_picker_path: NodePath
export var palette: Resource

onready var _palette_selection_button: OptionButton = $MarginContainer/VBoxContainer/Buttons/PaletteSelectionButton
onready var _color_grid: GridContainer = $MarginContainer/VBoxContainer/ColorGrid

var _active_palette_button: PaletteButton

# -------------------------------------------------------------------------------------------------
func _ready() -> void:
	assert(palette != null && palette is Palette)
	_palette_selection_button.add_item(palette.name, 0)
	_create_buttons()
	_activate_palette_button(_color_grid.get_child(0))

# -------------------------------------------------------------------------------------------------
func _input(event: InputEvent) -> void:
	if event is InputEventKey && event.pressed && event.scancode == KEY_ESCAPE:
		visible = false

# -------------------------------------------------------------------------------------------------
func _create_buttons() -> void:
	for color in palette.colors:
		var button: PaletteButton = PALETTE_BUTTON.instance()
		_color_grid.add_child(button)
		button.color = color
		button.connect("pressed", self, "_on_platte_button_pressed", [button])

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
