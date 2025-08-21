class_name UnsavedChangesDialog
extends PanelContainer

# -------------------------------------------------------------------------------------------------
signal save_changes
signal discard_changes

@onready var _save_button: Button = %SaveButton
@onready var _discard_button: Button = %DiscardButton

# -------------------------------------------------------------------------------------------------
func _ready() -> void:
	get_parent().close_requested.connect(get_parent().hide)
	
	_save_button.pressed.connect(save)
	_discard_button.pressed.connect(discard)
# -------------------------------------------------------------------------------------------------
func save() ->void:
	get_parent().hide()
	save_changes.emit()
# -------------------------------------------------------------------------------------------------
func discard()->void:
	get_parent().hide()
	discard_changes.emit()
# -------------------------------------------------------------------------------------------------
func set_text(text: String) -> void:
	$Label.text = text
# -------------------------------------------------------------------------------------------------
func cancel()->void:
	get_parent().hide()
# -------------------------------------------------------------------------------------------------
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_ESCAPE:
			cancel()
# -------------------------------------------------------------------------------------------------
func on_unhide():
	# The save button is focused by default
	_save_button.grab_focus()
	pass
# -------------------------------------------------------------------------------------------------
func _notification(what: int) -> void:
	if what ==NOTIFICATION_VISIBILITY_CHANGED and is_visible_in_tree():
			#runs when visibility changes and is_visible
			on_unhide()
