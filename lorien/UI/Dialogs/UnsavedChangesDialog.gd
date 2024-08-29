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
	
	_save_button.pressed.connect(func() -> void:
		get_parent().hide()
		save_changes.emit()
	)
	
	_discard_button.pressed.connect(func() -> void: 
		get_parent().hide()
		discard_changes.emit()
	)

# -------------------------------------------------------------------------------------------------
func set_text(text: String) -> void:
	$Label.text = text
