extends HBoxContainer

signal modified_binding(bindings_data)

var bindings_data := {}

# Keybindings data: {"readable_name": "str", "keycodes": [...]}
func set_keybindings_data(_bindings_data):
	for child in get_children():
		remove_child(child)

	bindings_data = _bindings_data
	for keycode in bindings_data["keycodes"]:
		var remove_button = Button.new()
		remove_button.text = OS.get_scancode_string(keycode)
		remove_button.connect("pressed", self, "_remove_pressed", [keycode])
		add_child(remove_button)

func _remove_pressed(keycode):
	bindings_data["keycodes"].remove(keycode)
	emit_signal("modified_binding", bindings_data)
