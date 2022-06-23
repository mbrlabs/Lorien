extends Button

# -------------------------------------------------------------------------------------------------
signal modified_binding(bindings_data)
signal bind_new_key

# -------------------------------------------------------------------------------------------------
var bindings_data := {}

# -------------------------------------------------------------------------------------------------
# Keybindings data: {"action": "str", "readable_name": "str", "events": [...]}
func set_keybindings_data(_bindings_data):
	bindings_data = _bindings_data

# -------------------------------------------------------------------------------------------------
func _on_AddButton_pressed():
	emit_signal("bind_new_key")
