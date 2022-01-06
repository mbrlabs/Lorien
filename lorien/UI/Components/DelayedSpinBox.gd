# Delays changing value until spinbox dragging has stopped
# Necessary to not lose cursor when changing gui scale
extends SpinBox

# -------------------------------------------------------------------------------------------------
var _pressed := false
var _ready   := false 

# -------------------------------------------------------------------------------------------------
func _on_GuiScaleValue_gui_input(event: InputEvent):
	if !event is InputEventMouseButton:
		return
	elif event.is_pressed():
		_pressed = true
	elif !event.is_pressed() && _pressed:
		_ready = true
		emit_signal("value_changed", value)
		_pressed = false
		_ready = false
