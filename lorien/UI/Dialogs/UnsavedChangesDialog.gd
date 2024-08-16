extends Window

# -------------------------------------------------------------------------------------------------
signal cancel
signal save_changes(project_ids)
signal discard_changes(project_ids)

@onready var _save_button: Button = $HBoxContainer/SaveButton
@onready var _discard_button: Button = $HBoxContainer/DiscardButton
@onready var _cancel_button: Button = $HBoxContainer/CancelButton

# -------------------------------------------------------------------------------------------------
var project_ids: Array

# -------------------------------------------------------------------------------------------------
func _ready() -> void:
	_save_button.connect("pressed", Callable(self, "_on_SaveButton_pressed"))
	_discard_button.connect("pressed", Callable(self, "_on_DiscardButton_pressed"))
	_cancel_button.connect("pressed", Callable(self, "_on_CancelButton_pressed"))

# -------------------------------------------------------------------------------------------------
func set_text(text: String) -> void:
	$Label.text = text

# -------------------------------------------------------------------------------------------------
func _on_CancelButton_pressed(): 
	hide()
	emit_signal("cancel")

# -------------------------------------------------------------------------------------------------
func _on_SaveButton_pressed(): 
	emit_signal("save_changes", project_ids)

# -------------------------------------------------------------------------------------------------	
func _on_DiscardButton_pressed(): 
	emit_signal("discard_changes", project_ids)
