extends Label

# -------------------------------------------------------------------------------------------------
signal modified_binding(bindings_data)

# -------------------------------------------------------------------------------------------------
# Keybindings data: {"action": "str", "readable_name": "str", "events": [...]}
func set_keybindings_data(_bindings_data: Dictionary) -> void:
	text = _bindings_data["readable_name"]
