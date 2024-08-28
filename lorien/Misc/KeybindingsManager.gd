extends Node

# -------------------------------------------------------------------------------------------------
class Action:
	var name: String
	var display_name: String
	var event: InputEventKey
	
	func event_label() -> String:
		return event.as_text_keycode()

# -------------------------------------------------------------------------------------------------
var _actions: Array[Action]

# -------------------------------------------------------------------------------------------------
func _ready() -> void:
	for action in get_actions():
		var event := Settings.get_keybind_value(action.name, action.event)
		rebind_action(action, event)

# -------------------------------------------------------------------------------------------------
func get_actions() -> Array[Action]:
	if _actions.is_empty():
		for action_name: String in InputMap.get_actions():
			if !action_name.begins_with("ui_") && !action_name.begins_with("player_"):
				var events := InputMap.action_get_events(action_name)
				if events.size() > 0:
					var event := events[0]
					event = Settings.get_keybind_value(action_name, event)
					
					var action := Action.new()
					action.event = event
					action.name = action_name
					action.display_name = tr("ACTION_" + action_name)
					_actions.append(action)
		
	return _actions

# -------------------------------------------------------------------------------------------------
func get_action(name: String) -> Action:
	for action: Action in _actions:
		if action.name == name:
			return action
	return null

# -------------------------------------------------------------------------------------------------
func get_action_map() -> Dictionary:
	var dict: Dictionary
	for action: Action in _actions:
		dict[action.name] = action
	
	return dict

# -------------------------------------------------------------------------------------------------
func rebind_action(action: Action, event: InputEventKey) -> void:
	action.event = event
	InputMap.action_erase_events(action.name)
	InputMap.action_add_event(action.name, event)
