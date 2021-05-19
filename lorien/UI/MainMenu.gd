extends PopupMenu
class_name MainMenu

signal open_about_dialog
signal open_settings_dialog

# -------------------------------------------------------------------------------------------------
func _ready():
	add_item("Debug Stuff")		# 0
	add_item("Settings")		# 1
	add_item("About")			# 2

# -------------------------------------------------------------------------------------------------
func _on_UIMenuPopup_index_pressed(index: int):
	match index:
		1: emit_signal("open_settings_dialog")
		2: emit_signal("open_about_dialog")
