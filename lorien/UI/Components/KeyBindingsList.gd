extends Node

# -------------------------------------------------------------------------------------------------
const KEYBINDINGS_LINE_SCENE = preload("res://UI/Components/KeyBindingsLine.tscn")

# -------------------------------------------------------------------------------------------------
@onready var _grid := $ScrollContainer/KeyBindingsList
@onready var _add_key_dialog := $AddKeyDialog

# -------------------------------------------------------------------------------------------------
func _ready() -> void:
	_populate_input_list()
	_add_key_dialog.close_requested.connect(_bind_key_dialog_close_requested)
	GlobalSignals.language_changed.connect(_populate_input_list)

# -------------------------------------------------------------------------------------------------
func _compare_second_element(a: Array, b: Array) -> bool:
	return a[1] < b[1] 

# -------------------------------------------------------------------------------------------------
func _populate_input_list() -> void:
	for c in _grid.get_children():
		_grid.remove_child(c)
		c.queue_free()
	
	var collected_keybinding_args := []
	for action in Utils.bindable_actions():
		var translated_action = Utils.translate_action(action)
		var shortcuts = []
		for _event in InputMap.action_get_events(action):
			if _event is InputEventKey:
				var event = _event as InputEventKey
				shortcuts.append(event)
		
		collected_keybinding_args.append([action, translated_action, shortcuts])

	collected_keybinding_args.sort_custom(_compare_second_element)
	for args in collected_keybinding_args:
		callv("_new_keybinding_entry", args)

# -------------------------------------------------------------------------------------------------
func _new_keybinding_entry(action_name: String, readable_name: String, events: Array) -> void:
	var new_line: Node = KEYBINDINGS_LINE_SCENE.instantiate()

	for child in new_line.get_children():
		child = child as Node
		
		child.set_keybindings_data({
			"action": action_name,
			"readable_name": readable_name,
			"events": events,
		})
		new_line.remove_child(child)
		_grid.add_child(child)
		
		if child.has_signal("modified_binding"):
			child.modified_binding.connect(_modify_keybinding.bind(action_name))
		if child.has_signal("bind_new_key"):
			child.bind_new_key.connect(_bind_new_key.bind(action_name))

# -------------------------------------------------------------------------------------------------
func _modify_keybinding(bindings_data: Dictionary, action_name: String) -> void:
	InputMap.action_erase_events(action_name)
	for e in bindings_data["events"]:
		InputMap.action_add_event(action_name, e)
	_populate_input_list()
	Settings.store_shortcuts()
	Settings.reload_locales()

# -------------------------------------------------------------------------------------------------
func _bind_new_key(action_name: String) -> void:
	_add_key_dialog.action_name = action_name
	_add_key_dialog.readable_action_name = Utils.translate_action(action_name)
	_add_key_dialog.popup_centered()

# -------------------------------------------------------------------------------------------------
func _bind_key_dialog_close_requested() -> void:
	_populate_input_list()
	Settings.store_shortcuts()
	Settings.reload_locales()
