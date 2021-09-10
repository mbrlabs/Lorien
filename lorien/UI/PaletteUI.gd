class_name PaletteUI
extends Control

signal color_changed

# -------------------------------------------------------------------------------------------------
const PALETTE_BUTTON = preload("res://UI/Components/PaletteButton.tscn")

# -------------------------------------------------------------------------------------------------
export var default_button_number: int
export var color_picker_path: NodePath 
export(String, "Lorien-Default","Ice-Cream") var default_palette: String 

var palettes: Dictionary = {"Lorien-Default": ["#ffffff", "#000000", "#ff5959", "#ff78ed", "#c86cff", "#5784ff", "#5ec2ff", "#58daff", "#54ffec", "#52ffb2", "#61ff6f", "#a1ff62", "#e4ff69", "#ffe051", "#ffa651"], 
"Ice-Cream": ["#6B3E26","#FFC5D9","#C2F2D0","#FFFFFF","#FDF5C9","#FFCB85"]}

onready var _button_grid: GridContainer = $ScrollContainer/GridContainer
onready var _color_picker: ColorPicker = get_node(color_picker_path)
var _selected_button: PaletteButton

# -------------------------------------------------------------------------------------------------
func _ready():
	_instance_buttons(default_button_number)
	_color_picker.connect("color_changed", self, "_on_color_picker_changed")
	_set_palette_style(default_palette)

# -------------------------------------------------------------------------------------------------
func _instance_buttons(num: int) -> void:
	for _i in num:
		var button: PaletteButton = PALETTE_BUTTON.instance()
		_button_grid.add_child(button)
		button.connect("pressed", self, "_on_button_pressed", [button])

# -------------------------------------------------------------------------------------------------
func _set_palette_style(palette: String):
	for i in min(default_button_number, palettes[palette].size()):
		var button: PaletteButton = _button_grid.get_child(i)
		button.color = palettes[palette][i]

# -------------------------------------------------------------------------------------------------
func _on_button_pressed(button: PaletteButton) -> void: 
	if _selected_button != null && button != _selected_button:
		_selected_button.selected = false
		
	_selected_button = button
	_set_active_color(_selected_button)

# -------------------------------------------------------------------------------------------------
func _set_active_color(button: PaletteButton) -> void:
	button.selected = true
	_color_picker.set_pick_color(button.color)
	emit_signal("color_changed", button.color)

# -------------------------------------------------------------------------------------------------
func _on_color_picker_changed(color: Color) -> void:
	if _selected_button != null:
		_selected_button.color = color
