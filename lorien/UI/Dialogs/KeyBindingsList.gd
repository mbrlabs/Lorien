extends GridContainer

const KEYBINDINGS_LINE_SCENE = preload("res://UI/Dialogs/KeyBindingsLine.tscn")

var lines := []

func _new_keybinding_entry(action_name: String, readable_name: String, keycodes: Array):
	var new_line: Node = KEYBINDINGS_LINE_SCENE.instance()

	lines.append({"action_name": action_name})
	for child in new_line.get_children():
		child.set_keybindings_data({
			"readable_name": readable_name,
			"keycodes": keycodes,
		})
		new_line.remove_child(child)
		add_child(child)

	# OS.get_scancode_string(

func _ready():
	for action in InputMap.get_actions():
		# Suppress default keybindings for using menus etc and EFF TWELVE
		if action.begins_with("ui_") or action.begins_with("player_"):
			continue

		var translated_action = TranslationServer.translate("ACTION_" + action)
		if translated_action.begins_with("ACTION_"):
			print(translated_action)
		var shortcuts = []
		for _event in InputMap.get_action_list(action):
			if _event is InputEventKey:
				var event = _event as InputEventKey
				shortcuts.append(event.get_scancode_with_modifiers())

		_new_keybinding_entry(action, translated_action, shortcuts)

