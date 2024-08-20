class_name FlatTextureButton
extends TextureButton

# -------------------------------------------------------------------------------------------------
@export var hover_tint := Color.WHITE
@export var pressed_tint := Color.WHITE
var _normal_tint: Color

# -------------------------------------------------------------------------------------------------
func _ready() -> void:
	_normal_tint = self_modulate
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	pressed.connect(_on_pressed)

	if toggle_mode && button_pressed:
		self_modulate = pressed_tint

# -------------------------------------------------------------------------------------------------
func _exit_tree() -> void:
	mouse_entered.disconnect(_on_mouse_entered)
	mouse_exited.disconnect(_on_mouse_exited)
	pressed.disconnect(_on_pressed)

# -------------------------------------------------------------------------------------------------
func _on_mouse_entered() -> void:
	if !button_pressed:
		self_modulate = hover_tint

# -------------------------------------------------------------------------------------------------
func _on_mouse_exited() -> void:
	if !button_pressed:
		self_modulate = _normal_tint

# -------------------------------------------------------------------------------------------------
func toggle() -> void:
	if button_pressed:
		self_modulate = _normal_tint
	else:
		self_modulate = pressed_tint
	button_pressed = !button_pressed

# -------------------------------------------------------------------------------------------------
func _on_pressed() -> void:
	if toggle_mode:
		if button_pressed:
			self_modulate = pressed_tint
		else:
			self_modulate = _normal_tint
