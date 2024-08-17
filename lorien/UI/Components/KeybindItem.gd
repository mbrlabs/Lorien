class_name KeybindItem
extends HBoxContainer

# -------------------------------------------------------------------------------------------------
signal action_rebind_requested(action: KeybindingsManager.Action, event: InputEventKey)

# -------------------------------------------------------------------------------------------------
@onready var _label: Label = $Label
@onready var _button: Button = $Button

var _action: KeybindingsManager.Action = null
var _rebinding := false
var _pressed_key_counter := 0
var _last_event: InputEventKey = null

# -------------------------------------------------------------------------------------------------
func _ready() -> void:
	_button.pressed.connect(func() -> void:
		_last_event = null
		_rebinding = true
		_button.text = "Press buttons to rebind..."
	)

# -------------------------------------------------------------------------------------------------
func set_action(action: KeybindingsManager.Action) -> void:
	_label.text = action.display_name
	_button.text = OS.get_keycode_string(action.event.get_keycode_with_modifiers())
	_action = action

# -------------------------------------------------------------------------------------------------
func _update_button_text() -> void:
	var code := _last_event.get_key_label_with_modifiers()
	_button.text = OS.get_keycode_string(code)

# -------------------------------------------------------------------------------------------------
func _do_rebind() -> void:
	_update_button_text()
	action_rebind_requested.emit(_action, _last_event)

# -------------------------------------------------------------------------------------------------
func _input(event: InputEvent) -> void:
	if _rebinding && event is InputEventKey:
		if event.is_pressed():
			_pressed_key_counter += 1
			_last_event = event
			_update_button_text()
		else:
			_pressed_key_counter -= 1
		
		if _pressed_key_counter == 0:
			_rebinding = false
			_do_rebind()
