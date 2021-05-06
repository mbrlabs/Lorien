extends Panel
class_name UITitlebar

# -------------------------------------------------------------------------------------------------
signal close_requested

# -------------------------------------------------------------------------------------------------
func _on_CloseButton_pressed():
	emit_signal("close_requested")

# -------------------------------------------------------------------------------------------------
func _on_MaximizeButton_pressed():
	OS.window_maximized = !OS.window_maximized

# -------------------------------------------------------------------------------------------------
func _on_MinimizeButton_pressed():
	OS.window_minimized = true

func _on_UITitlebar_gui_input(event):
	print(event)
