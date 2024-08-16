extends HBoxContainer

# -------------------------------------------------------------------------------------------------
signal modified_binding(bindings_data)

# -------------------------------------------------------------------------------------------------
var _bindings_data := {}
var _preloaded_image := preload("res://Assets/Icons/delete.png")

# -------------------------------------------------------------------------------------------------
# Keybindings data: {"action": "str", "readable_name": "str", "events": [...]}
func set_keybindings_data(bindings_data: Dictionary) -> void:
	for child in get_children():
		remove_child(child)

	_bindings_data = bindings_data
	for event in bindings_data["events"]:
		if event is InputEventKey:
			var remove_button = Button.new()
			remove_button.text = OS.get_keycode_string(event.get_keycode_with_modifiers())
			remove_button.icon = _preloaded_image
	
			remove_button.add_theme_constant_override("h_separation", 6)
	
			remove_button.connect("pressed", Callable(self, "_remove_pressed").bind(event))
			add_child(remove_button)

# -------------------------------------------------------------------------------------------------
func _remove_pressed(event: InputEvent) -> void:
	_bindings_data["events"].erase(event)
	emit_signal("modified_binding", _bindings_data)
