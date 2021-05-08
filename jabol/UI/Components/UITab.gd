extends PanelContainer

# -------------------------------------------------------------------------------------------------
const STYLE_ACTIVE = preload("res://UI/Themes/style_tab_active_dark.tres")
const STYLE_INACTIVE = preload("res://UI/Themes/style_tab_inactive_dark.tres")

# -------------------------------------------------------------------------------------------------
onready var _filename_button: Button = $HBoxContainer/FilenameButton
onready var _close_button: Button = $HBoxContainer/CloseButton

var _is_active := false

# -------------------------------------------------------------------------------------------------
func _ready():
	set_active(false)

# -------------------------------------------------------------------------------------------------
func set_title(title: String) -> void:
	_filename_button.text = title

# -------------------------------------------------------------------------------------------------
func set_active(active: bool) -> void:
	_is_active = active
	
	var new_style = STYLE_INACTIVE
	if _is_active:
		new_style = STYLE_ACTIVE
	set("custom_styles/panel", new_style)

