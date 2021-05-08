extends Panel
class_name UITitlebar

# -------------------------------------------------------------------------------------------------
signal close_requested
signal window_maximized
signal window_demaximized
signal window_minimized

# -------------------------------------------------------------------------------------------------

var _mouse_pressed := false
var _mouse_draging := false
var _drag_offset: Vector2

# -------------------------------------------------------------------------------------------------
func _ready() -> void:
	$Left/Tabs.get_child(0).set_title("Tab 1")
	$Left/Tabs.get_child(1).set_active(true)
	$Left/Tabs.get_child(1).set_title("Very long tab title")
	$Left/Tabs.get_child(2).set_title("* Tab 3") 
	$Left/Tabs.get_child(3).set_title("Tab 4 with a long name as well")

# -------------------------------------------------------------------------------------------------
func _process(delta: float) -> void:
	if _mouse_pressed && _mouse_draging:
		if OS.window_maximized && Utils.get_native_mouse_position_on_screen().y > 100:
			OS.window_maximized = false
			emit_signal("window_demaximized")
		else:
			var mouse_pos := get_tree().root.get_viewport().get_mouse_position()
			var win_pos :=  OS.window_position
			OS.window_position = mouse_pos + win_pos + _drag_offset

# -------------------------------------------------------------------------------------------------
func _on_CloseButton_pressed():
	emit_signal("close_requested")

# -------------------------------------------------------------------------------------------------
func _on_MaximizeButton_pressed() -> void:
	if OS.window_maximized:
		OS.window_maximized = false
		emit_signal("window_demaximized")
	else:
		OS.window_maximized = true
		emit_signal("window_maximized")

# -------------------------------------------------------------------------------------------------
func _on_MinimizeButton_pressed() -> void:
	OS.window_minimized = true
	emit_signal("window_minimized")

# -------------------------------------------------------------------------------------------------
func _on_UITitlebar_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if !event.pressed:
			_mouse_draging = false
		
		if event.button_index == BUTTON_LEFT:
			if event.doubleclick:
				_on_MaximizeButton_pressed()
			else:
				_drag_offset = OS.window_position - (event.global_position + OS.window_position)
				_mouse_pressed = event.pressed
	elif event is InputEventMouseMotion:
		if _mouse_pressed:
			_mouse_draging = true
