extends WindowDialog

# -------------------------------------------------------------------------------------------------
const ACTION_DISCARD := "discard_changes"

# -------------------------------------------------------------------------------------------------
signal cancel_exit
signal save_changes
signal discard_changes

# -------------------------------------------------------------------------------------------------
func _on_CancelButton_pressed(): emit_signal("cancel_exit")
func _on_SaveButton_pressed(): emit_signal("save_changes")
func _on_DiscardButton_pressed(): emit_signal("discard_changes")
