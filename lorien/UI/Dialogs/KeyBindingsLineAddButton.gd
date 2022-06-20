extends Button

signal modified_binding(bindings_data)

var bindings_data := {}

# Keybindings data: {"readable_name": "str", "events": [...]}
func set_keybindings_data(_bindings_data):
	bindings_data = _bindings_data
