extends SpinBox

# -------------------------------------------------------------------------------------------------
var _pressed := false setget set_pressed 

# -------------------------------------------------------------------------------------------------
func _on_GuiScaleValue_gui_input(event: InputEvent):
	
	if !event is InputEventMouseButton:
		return
	elif event.is_pressed():
		_pressed = true
		print(_pressed)
	elif !event.is_pressed() && _pressed:
		Input.action_press("ui_accept")
		emit_signal("value_changed", value)
		_pressed = false

# -------------------------------------------------------------------------------------------------
#func _on_GuiScale_value_changed(value: float):
	#if Input.is_action_just_pressed("ui_accept"):
		#_pressed = false
		#print(_pressed)

# -------------------------------------------------------------------------------------------------
func set_pressed(pressed: bool):
	_pressed = pressed
