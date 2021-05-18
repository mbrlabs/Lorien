extends TextureButton

# -------------------------------------------------------------------------------------------------
export var hover_tint := Color.white
export var pressed_tint := Color.white
var _normal_tint: Color

# -------------------------------------------------------------------------------------------------
func _ready() -> void:
	_normal_tint = self_modulate
	connect("mouse_entered", self, "_on_mouse_entered")
	connect("mouse_exited", self, "_on_mouse_exited")
	connect("pressed", self, "_on_pressed")
	
	if toggle_mode && pressed:
		self_modulate = pressed_tint
	
# -------------------------------------------------------------------------------------------------
func _exit_tree() -> void:
	disconnect("mouse_entered", self, "_on_mouse_entered")
	disconnect("mouse_exited", self, "_on_mouse_exited")
	disconnect("pressed", self, "_on_pressed")

# -------------------------------------------------------------------------------------------------
func _on_mouse_entered() -> void:
	if !pressed:
		self_modulate = hover_tint

# -------------------------------------------------------------------------------------------------
func _on_mouse_exited() -> void:
	if !pressed:
		self_modulate = _normal_tint

# -------------------------------------------------------------------------------------------------
func untoggle() -> void:
	pressed = false
	self_modulate = _normal_tint

# -------------------------------------------------------------------------------------------------
func _on_pressed() -> void:
	if toggle_mode:
		if pressed:
			self_modulate = pressed_tint
		else:
			self_modulate = _normal_tint
