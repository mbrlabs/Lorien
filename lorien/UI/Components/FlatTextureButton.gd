extends TextureButton

# -------------------------------------------------------------------------------------------------
@export var hover_tint := Color.WHITE
@export var pressed_tint := Color.WHITE
var _normal_tint: Color

# -------------------------------------------------------------------------------------------------
func _ready() -> void:
	_normal_tint = self_modulate
	connect("mouse_entered", Callable(self, "_on_mouse_entered"))
	connect("mouse_exited", Callable(self, "_on_mouse_exited"))
	connect("pressed", Callable(self, "_on_pressed"))

	if toggle_mode && pressed:
		self_modulate = pressed_tint

# -------------------------------------------------------------------------------------------------
func _exit_tree() -> void:
	disconnect("mouse_entered", Callable(self, "_on_mouse_entered"))
	disconnect("mouse_exited", Callable(self, "_on_mouse_exited"))
	disconnect("pressed", Callable(self, "_on_pressed"))

# -------------------------------------------------------------------------------------------------
func _on_mouse_entered() -> void:
	if !pressed:
		self_modulate = hover_tint

# -------------------------------------------------------------------------------------------------
func _on_mouse_exited() -> void:
	if !pressed:
		self_modulate = _normal_tint

# -------------------------------------------------------------------------------------------------
func toggle() -> void:
	if pressed:
		self_modulate = _normal_tint
	else:
		self_modulate = pressed_tint
	button_pressed = !button_pressed

# TODO(gd4): they added set_pressed or something. Also pressed get renamed to button_pressed.
# this might not be nedded; or it might be. Keep an eye on the tool buttons!!! 
# -------------------------------------------------------------------------------------------------
#func set_pressed(is_pressed) -> void:
	#button_pressed = is_pressed
	#_on_pressed()

# -------------------------------------------------------------------------------------------------
func _on_pressed() -> void:
	if toggle_mode:
		if pressed:
			self_modulate = pressed_tint
		else:
			self_modulate = _normal_tint
