extends WindowDialog

# -------------------------------------------------------------------------------------------------
signal cancel
signal save_changes(project_ids)
signal discard_changes(project_ids)

# -------------------------------------------------------------------------------------------------
var project_ids: Array

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
