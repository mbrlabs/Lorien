extends AcceptDialog

# ------------------------------------------------------------------------------------------------
func _ready() -> void:
	close_requested.connect(hide)
