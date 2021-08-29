extends Control
class_name Palette

signal color_changed

# -------------------------------------------------------------------------------------------------
#add const DEFAULT_COLORS array

# -------------------------------------------------------------------------------------------------
export var _default_button_number: int
export var _palette_theme: Theme 

onready var _button_grid: GridContainer = $ScrollContainer/GridContainer
onready var _color_picker: ColorPicker = get_node("../../PanelContainer/ColorPicker")
onready var _focused_button: Button

var _palette_button: PackedScene = preload("res://UI/Components/PaletteButton.tscn")

# -------------------------------------------------------------------------------------------------
func _ready():
	for btn in range(0, _default_button_number):
		_button_grid.add_child(_palette_button.instance())
		
		var _current_button: Button = _button_grid.get_child(btn).get_child(0)
		_current_button.connect("button_down", self, "_on_button_press", [_current_button])
	
	_color_picker.connect("color_changed", self, "_on_color_picker_change")
	_focused_button = _button_grid.get_child(0).get_child(0)
	
	#add default colors

# -------------------------------------------------------------------------------------------------
func _on_button_press(var _pressed_button: Button) -> void: 
	_focused_button = _pressed_button
	if (_pressed_button.get("custom_styles/normal") == _palette_theme.get("custom_styles/normal")):
		var normal_style: StyleBoxFlat = _palette_theme.get_stylebox("normal", "Button").duplicate()
		var focus_style: StyleBoxFlat = _palette_theme.get_stylebox("focus", "Button").duplicate()
		normal_style.set("bg_color", _color_picker.color)
		focus_style.set("bg_color", _color_picker.color)
		_pressed_button.set("custom_styles/normal", normal_style)
		_pressed_button.set("custom_styles/pressed", normal_style)
		_pressed_button.set("custom_styles/focus", focus_style)
		_pressed_button.set("custom_styles/hover", focus_style)
		
	else:
		_set_active_color(_pressed_button)	

# -------------------------------------------------------------------------------------------------
func _set_active_color(node: Node) -> void:
	_color_picker.set_pick_color(node.get("custom_styles/normal").bg_color)
	emit_signal("color_changed", node.get("custom_styles/normal").bg_color)
	
# -------------------------------------------------------------------------------------------------
func _on_color_picker_change(color: Color) -> void:
	var normal_style: StyleBoxFlat = _focused_button.get_stylebox("normal", "Button")
	var focus_style: StyleBoxFlat = _focused_button.get_stylebox("normal", "Button")
	normal_style.set("bg_color", color)
	focus_style.set("bg_color", color)
	_focused_button.set("custom_styles/normal", normal_style)
	_focused_button.set("custom_styles/pressed", normal_style)
	_focused_button.set("custom_styles/focus", focus_style)
	_focused_button.set("custom_styles/hover", focus_style)
