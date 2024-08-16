# Delays changing value until spinbox dragging has stopped
# Necessary to not lose cursor when changing ui scale
extends SpinBox

# -------------------------------------------------------------------------------------------------
var _pressed := false
var _ready   := false 

# -------------------------------------------------------------------------------------------------
func _ready() -> void:
	connect("gui_input", Callable(self, "_on_UIScale_gui_input"))

# -------------------------------------------------------------------------------------------------
func _on_UIScale_gui_input(event: InputEvent):
	if !event is InputEventMouseButton:
		return
	elif event.is_pressed():
		_pressed = true
	elif !event.is_pressed() && _pressed:
		_ready = true
		emit_signal("value_changed", value)
		_pressed = false
		_ready = false

# -------------------------------------------------------------------------------------------------
func is_ready() -> bool:
	return _ready
