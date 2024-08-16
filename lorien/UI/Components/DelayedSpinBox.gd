# Delays changing value until spinbox dragging has stopped
# Necessary to not lose cursor when changing ui scale
extends SpinBox

# -------------------------------------------------------------------------------------------------
var _pressed 	:= false
var _is_ready	:= false 

# -------------------------------------------------------------------------------------------------
func _ready() -> void:
	gui_input.connect(_on_UIScale_gui_input)

# -------------------------------------------------------------------------------------------------
func _on_UIScale_gui_input(event: InputEvent):
	if !event is InputEventMouseButton:
		return
	elif event.is_pressed():
		_pressed = true
	elif !event.is_pressed() && _pressed:
		_is_ready = true
		emit_signal("value_changed", value)
		_pressed = false
		_is_ready = false

# -------------------------------------------------------------------------------------------------
func is_ready() -> bool:
	return _is_ready
