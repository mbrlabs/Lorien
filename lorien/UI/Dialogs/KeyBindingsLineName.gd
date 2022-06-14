extends Label

signal modified_binding(bindings_data)

# Keybindings data: {"readable_name": "str", "keycodes": [...]}
func set_keybindings_data(_bindings_data):
	text = _bindings_data["readable_name"]
