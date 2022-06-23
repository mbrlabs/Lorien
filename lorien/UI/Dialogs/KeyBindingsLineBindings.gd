extends HBoxContainer

# -------------------------------------------------------------------------------------------------
signal modified_binding(bindings_data)

# -------------------------------------------------------------------------------------------------
var bindings_data := {}

# -------------------------------------------------------------------------------------------------
# Keybindings data: {"action": "str", "readable_name": "str", "events": [...]}
func set_keybindings_data(_bindings_data):
	for child in get_children():
		remove_child(child)

	var ref_stylebox: StyleBox = Button.new().get_stylebox("normal").duplicate(true)
	var bg_stylebox: StyleBox = StyleBoxFlat.new()
	bg_stylebox.content_margin_top = ref_stylebox.content_margin_top
	bg_stylebox.content_margin_bottom = ref_stylebox.content_margin_bottom
	bg_stylebox.content_margin_left = ref_stylebox.content_margin_left
	bg_stylebox.content_margin_right = ref_stylebox.content_margin_right
	
	var red_bg := bg_stylebox.duplicate(false)
	red_bg.bg_color = Color.red
	var lightred_bg := bg_stylebox.duplicate(false)
	lightred_bg.bg_color = Color.lightcoral

	bindings_data = _bindings_data
	for event in bindings_data["events"]:
		if event is InputEventKey:
			var remove_button = Button.new()
			remove_button.text = OS.get_scancode_string(event.get_scancode_with_modifiers())
			
			remove_button.add_stylebox_override("normal", red_bg)
			remove_button.add_stylebox_override("pressed", red_bg)
			remove_button.add_stylebox_override("hover", red_bg)
			remove_button.add_stylebox_override("focus", lightred_bg)
			remove_button.connect("pressed", self, "_remove_pressed", [event])
			add_child(remove_button)

# -------------------------------------------------------------------------------------------------
func _remove_pressed(event):
	bindings_data["events"].erase(event)
	print("BBB ", get_signal_connection_list("modified_binding"))
	
	
	emit_signal("modified_binding", bindings_data)
