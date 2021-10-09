class_name PaletteButton
extends Control

# -------------------------------------------------------------------------------------------------
signal pressed

# -------------------------------------------------------------------------------------------------
onready var _color_texture: TextureRect = $Color
onready var _selection_texture: TextureRect = $Selection

var selected := false setget set_selected
var color := Color.white setget set_color

# -------------------------------------------------------------------------------------------------
func _ready() -> void:
	_color_texture.modulate.a = 0

# -------------------------------------------------------------------------------------------------
func set_selected(s: bool) -> void:
	selected = s
	_selection_texture.modulate = _get_selection_color() if selected else color

# -------------------------------------------------------------------------------------------------
func clear_hover_state() -> void:
	if !selected:
		_selection_texture.modulate = color

# -------------------------------------------------------------------------------------------------
func set_color(c: Color) -> void:
	color = c
	_color_texture.modulate = c
	if !selected:
		_selection_texture.modulate = c

# -------------------------------------------------------------------------------------------------
func _get_selection_color() -> Color:
	return Color.black

# -------------------------------------------------------------------------------------------------
func _get_hover_color() -> Color:
	return Color.black

# -------------------------------------------------------------------------------------------------
func _on_PaletteButton_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton && !event.pressed && event.button_index == BUTTON_LEFT:
		emit_signal("pressed")

# -------------------------------------------------------------------------------------------------
func _on_PaletteButton_mouse_entered() -> void:
	if !selected:
		_selection_texture.modulate = _get_hover_color()

# -------------------------------------------------------------------------------------------------
func _on_PaletteButton_mouse_exited() -> void:
	_selection_texture.modulate = _get_selection_color() if selected else color
