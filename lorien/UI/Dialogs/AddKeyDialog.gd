extends Window

# -------------------------------------------------------------------------------------------------
var _MODIFIER_KEYS := [KEY_CTRL, KEY_SHIFT, KEY_META, KEY_ALT]

# -------------------------------------------------------------------------------------------------
@export var action_name := ""
@export var readable_action_name := "": set = _set_readable_action_name

@onready var _confirm_rebind_dialog := $ConfirmRebind

var _pending_bind_event = null

# -------------------------------------------------------------------------------------------------
func _ready() -> void:
	_update_event_text()
	GlobalSignals.connect("language_changed", Callable(self, "_update_event_text"))

# -------------------------------------------------------------------------------------------------
func _set_readable_action_name(s: String):
	readable_action_name = s
	_update_event_text()

# -------------------------------------------------------------------------------------------------
func _update_event_text() -> void:
	$VBoxContainer/EventText.text = tr(
		"KEYBINDING_DIALOG_BIND_ACTION"
	).format({"action": readable_action_name})

# -------------------------------------------------------------------------------------------------
func _action_for_event(event: InputEvent):
	for action in Utils.bindable_actions():
		if InputMap.action_has_event(action, event):
			return action
	return null

# -------------------------------------------------------------------------------------------------
func _input(event: InputEvent) -> void:
	if ! visible || _confirm_rebind_dialog.visible:
		return
	if event is InputEventKey && event.is_pressed():
		get_viewport().set_input_as_handled()
		
		if event.keycode in _MODIFIER_KEYS:
			return

		var event_type := InputEventKey.new()
		event_type.keycode = event.keycode
		event_type.alt = event.alt
		event_type.shift = event.shift
		event_type.control = event.control
		event_type.meta = event.meta
		event_type.command = event.command
		
		var _conflicting_action = _action_for_event(event_type)
		
		_pending_bind_event = event_type
		if _conflicting_action is String && _conflicting_action != action_name:
			_confirm_rebind_dialog.dialog_text = tr("KEYBINDING_DIALOG_REBIND_MESSAGE").format({
				"event": OS.get_keycode_string(event_type.get_keycode_with_modifiers()),
				"action": Utils.translate_action(_conflicting_action)
			})
			_confirm_rebind_dialog.popup_centered()
		else:
			_finish_rebind()

# -------------------------------------------------------------------------------------------------
func _on_ConfirmRebind_confirmed() -> void:
	_finish_rebind()

# -------------------------------------------------------------------------------------------------
func _finish_rebind() -> void:
	for action in Utils.bindable_actions():
		if InputMap.action_has_event(action, _pending_bind_event):
			InputMap.action_erase_event(action, _pending_bind_event)
	InputMap.action_add_event(action_name, _pending_bind_event)
	visible = false
