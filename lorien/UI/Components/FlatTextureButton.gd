class_name FlatTextureButton
extends TextureButton

# -------------------------------------------------------------------------------------------------
@export var hover_tint := Color.WHITE
@export var pressed_tint := Color.WHITE
@export var disabled_tint := Color(0.4, 0.4, 0.4)
var _normal_tint: Color

# -------------------------------------------------------------------------------------------------
func _ready() -> void:
	_normal_tint = self_modulate
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	toggled.connect(_on_toggled)
	_update_tint()
	Settings.changed_theme.connect(_on_theme_changed)

# -------------------------------------------------------------------------------------------------
func _exit_tree() -> void:
	mouse_entered.disconnect(_on_mouse_entered)
	mouse_exited.disconnect(_on_mouse_exited)
	toggled.disconnect(_on_toggled)

# -------------------------------------------------------------------------------------------------
func _on_mouse_entered() -> void:
	call_deferred("_update_tint")

# -------------------------------------------------------------------------------------------------
func _on_mouse_exited() -> void:
	call_deferred("_update_tint")

# -------------------------------------------------------------------------------------------------
func toggle() -> void:
	button_pressed = !button_pressed

# -------------------------------------------------------------------------------------------------
func _on_toggled(_toggled_on: bool) -> void:
	_update_tint()

# -------------------------------------------------------------------------------------------------
func set_is_disabled(value: bool) -> void:
	disabled = value
	_update_tint()

# -------------------------------------------------------------------------------------------------
func _update_tint() -> void:
	if disabled:
		self_modulate = disabled_tint
	elif button_pressed:
		self_modulate = pressed_tint
	elif is_hovered():
		self_modulate = hover_tint
	else:
		self_modulate = _normal_tint
		
func _on_theme_changed(path : String) -> void:
	if path == "dark":
		_normal_tint = Color.WHITE
	else:
		_normal_tint = Color.BLACK
	self_modulate = _normal_tint
