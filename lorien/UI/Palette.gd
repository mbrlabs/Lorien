extends Control
class_name Palette

signal color_changed
# -------------------------------------------------------------------------------------------------
const PALETTE_BUTTON = preload("res://UI/Components/PaletteButton.tscn")

# -------------------------------------------------------------------------------------------------
export var default_button_number: int
export var palette_theme: Theme
export var color_picker_path: NodePath 
export(String, "Lorien-Default","Ice-Cream") var default_palette: String 

onready var _button_grid: GridContainer = $ScrollContainer/GridContainer
onready var _color_picker: ColorPicker = get_node(color_picker_path)
onready var _palette_button_theme_normal: StyleBoxFlat = palette_theme.get_stylebox("normal", "Button")
onready var _palette_button_theme_focus: StyleBoxFlat = palette_theme.get_stylebox("focus", "Button")

var palettes: Dictionary = {"Lorien-Default": ["#FFFFFF","#808080","#000000","#31F776","#3E43F7","#BD332F","#DB6507","#CBF731","#9507DB"], 
"Ice-Cream": ["#6B3E26","#FFC5D9","#C2F2D0","#FFFFFF","#FDF5C9","#FFCB85"]}
var _focused_button: Button

# -------------------------------------------------------------------------------------------------
func _ready():
	_instance_buttons(0, default_button_number)
	_color_picker.connect("color_changed", self, "_on_color_picker_changed")
	_set_palette_style(default_palette)

# -------------------------------------------------------------------------------------------------
func _instance_buttons(min_range: int, max_range: int) -> void:
	for btn in range(min_range, max_range):
		_button_grid.add_child(PALETTE_BUTTON.instance())
		var _current_button: Button = _button_grid.get_child(btn).get_child(0)
		_current_button.connect("pressed", self, "_on_button_pressed", [_current_button])
		_current_button["custom_styles/normal"] = _palette_button_theme_normal.duplicate()
		_current_button["custom_styles/focus"] = _palette_button_theme_focus.duplicate()
		_current_button["custom_styles/hover"] = _current_button["custom_styles/focus"]

# -------------------------------------------------------------------------------------------------
func _set_palette_style(palette: String):
	for btn in min(default_button_number, palettes[palette].size()):
		var current_button: Button = _button_grid.get_child(btn).get_child(0)
		_set_button_color(current_button, palettes[palette][btn])

# -------------------------------------------------------------------------------------------------
func _on_button_pressed(var pressed_button: Button) -> void: 
	_focused_button = pressed_button
	var button_color = pressed_button["custom_styles/normal"].bg_color
	if (button_color != _palette_button_theme_normal.bg_color):
		_set_active_color(pressed_button, button_color)

# -------------------------------------------------------------------------------------------------
func _set_active_color(button: Button, color: Color) -> void:
	_color_picker.set_pick_color(color)
	emit_signal("color_changed", color)

# -------------------------------------------------------------------------------------------------
func _on_color_picker_changed(color: Color) -> void:
	if (_focused_button != null):
		_set_button_color(_focused_button, color)

# -------------------------------------------------------------------------------------------------
func _set_button_color(button: Button, color: Color) -> void:
	button["custom_styles/normal"].bg_color = color
	button["custom_styles/focus"].bg_color = color
