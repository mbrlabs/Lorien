extends Node

# -------------------------------------------------------------------------------------------------
class Action:
	var name: String
	var display_name: String
	var event: InputEventKey

# -------------------------------------------------------------------------------------------------
func get_actions() -> Array[Action]:
	var actions: Array[Action]
	for action_name: String in InputMap.get_actions():
		if !action_name.begins_with("ui_") && !action_name.begins_with("player_"):
			var events := InputMap.action_get_events(action_name)
			if events.size() > 0:
				var action := Action.new()
				action.event = events[0]
				action.name = action_name
				action.display_name = tr("ACTION_" + action_name)
				actions.append(action)
	return actions

# -------------------------------------------------------------------------------------------------
func rebind_action(action: Action, event: InputEventKey) -> void:
	action.event = event
	InputMap.action_erase_events(action.name)
	InputMap.action_add_event(action.name, event)
