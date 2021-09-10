class_name PaletteButton
extends Control

# -------------------------------------------------------------------------------------------------
const OUTLINE_COLOR := Config.DEFAULT_SELECTION_COLOR

# -------------------------------------------------------------------------------------------------
signal pressed

# -------------------------------------------------------------------------------------------------
onready var _color_texture: TextureRect = $Color
onready var _outline_texture: TextureRect = $Outline

var selected := false setget set_selected
var color := Color.white setget set_color

# -------------------------------------------------------------------------------------------------
func _ready() -> void:
	_color_texture.modulate.a = 0

# -------------------------------------------------------------------------------------------------
func set_selected(s: bool) -> void:
	selected = s
	_outline_texture.modulate = OUTLINE_COLOR if selected else color

# -------------------------------------------------------------------------------------------------
func set_color(c: Color) -> void:
	color = c
	_color_texture.modulate = c
	if !selected:
		_outline_texture.modulate = c

# -------------------------------------------------------------------------------------------------
func _on_PaletteButton_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton && !event.pressed && event.button_index == BUTTON_LEFT:
		emit_signal("pressed")
