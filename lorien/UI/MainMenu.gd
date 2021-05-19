extends PopupMenu

# -------------------------------------------------------------------------------------------------
func _ready():
	add_item("Debug Stuff")
	add_item("Settings")
	add_item("About")

# -------------------------------------------------------------------------------------------------
func _on_UIMenuPopup_index_pressed(index: int):
	printerr("Not implemented yet")
