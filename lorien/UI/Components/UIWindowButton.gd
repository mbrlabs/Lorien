tool
extends Control
class_name UIWindowButton

signal pressed

# -------------------------------------------------------------------------------------------------
export var hover_background: Color
export var hover_texture: Color
export var texture: Texture

onready var _background: ColorRect = $ColorRect
onready var _texture_button: TextureButton = $TextureButton

var _original_background_color: Color
var _original_texture_color: Color

# -------------------------------------------------------------------------------------------------
func _ready():
	_original_background_color = _background.color
	_original_texture_color = _texture_button.self_modulate
	_texture_button.texture_normal = texture

# -------------------------------------------------------------------------------------------------
func _on_TextureButton_mouse_entered():
	_texture_button.self_modulate = hover_texture
	_background.color = hover_background

# -------------------------------------------------------------------------------------------------
func _on_TextureButton_mouse_exited():
	_texture_button.self_modulate = _original_texture_color
	_background.color = _original_background_color

# -------------------------------------------------------------------------------------------------
func _on_TextureButton_pressed():
	emit_signal("pressed")
