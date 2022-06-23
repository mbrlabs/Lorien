extends WindowDialog

# -------------------------------------------------------------------------------------------------
export var action_name: String
export var readable_action_name: String

# -------------------------------------------------------------------------------------------------
func _process(delta):
	$VBoxContainer/EventText.text = "Action: %s" % readable_action_name

# -------------------------------------------------------------------------------------------------
func _action_for_event(event: InputEvent):
	for action in Utils.bindable_actions():
		for e in InputMap.get_action_list(action):
			if e.as_text() == event.as_text():
				return action
	return null

# -------------------------------------------------------------------------------------------------
func _input(event: InputEvent) -> void:
	if ! visible:
		return
	
	get_tree().set_input_as_handled()
	
	if event is InputEventKey && event.is_pressed():
		if KEY_MODIFIER_MASK & event.scancode != 0:
			return

		var event_type := InputEventKey.new()
		event_type.scancode = event.scancode
		event_type.alt = event.alt
		event_type.shift = event.shift
		event_type.control = event.control
		event_type.meta = event.meta
		event_type.command = event.command
		
		var _conflicting_action = _action_for_event(event_type)
		if _conflicting_action:
			print("SHOULD DO THIS: ", Utils.translate_action(_conflicting_action))
		
		InputMap.action_add_event(action_name, event_type)
		visible = false
