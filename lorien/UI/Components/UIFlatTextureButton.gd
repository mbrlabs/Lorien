extends TextureButton

# -------------------------------------------------------------------------------------------------
export var hover_tint := Color.white
var _normal_tint: Color

# -------------------------------------------------------------------------------------------------
func _ready() -> void:
	_normal_tint = self_modulate
	connect("mouse_entered", self, "_on_mouse_entered")
	connect("mouse_exited", self, "_on_mouse_exited")
	
# -------------------------------------------------------------------------------------------------
func _exit_tree() -> void:
	disconnect("mouse_entered", self, "_on_mouse_entered")
	disconnect("mouse_exited", self, "_on_mouse_exited")

# -------------------------------------------------------------------------------------------------
func _on_mouse_entered() -> void:
	self_modulate = hover_tint

# -------------------------------------------------------------------------------------------------
func _on_mouse_exited() -> void:
	self_modulate = _normal_tint
