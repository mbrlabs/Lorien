extends TextureButton

# -------------------------------------------------------------------------------------------------
export var hover_tint := Color.white
export var pressed_tint := Color.white
var disabled_tint := Color(0.4, 0.4, 0.4)
var _normal_tint: Color

var is_disabled: bool = false setget set_is_disabled

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
	if !(is_disabled || pressed):
		self_modulate = hover_tint

# -------------------------------------------------------------------------------------------------
func _on_mouse_exited() -> void:
	if !(is_disabled || pressed):
		self_modulate = _normal_tint

# -------------------------------------------------------------------------------------------------
func toggle() -> void:
	if is_disabled:
		return
	
	if pressed:
		self_modulate = _normal_tint
	else:
		self_modulate = pressed_tint
	pressed = !pressed

# -------------------------------------------------------------------------------------------------
func set_pressed(is_pressed) -> void:
	pressed = is_pressed
	_on_pressed()

# -------------------------------------------------------------------------------------------------
func _on_pressed() -> void:
	if toggle_mode:
		if pressed:
			self_modulate = pressed_tint
		else:
			self_modulate = _normal_tint

# -------------------------------------------------------------------------------------------------
func set_is_disabled(value: bool) -> void:
	is_disabled = value
	
	# Prevent this function from overriding the "normal tint"
	if !is_inside_tree():
		return
	
	if is_disabled:
		self_modulate = disabled_tint
	else:
		self_modulate = _normal_tint

