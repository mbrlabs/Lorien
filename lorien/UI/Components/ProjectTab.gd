extends PanelContainer
class_name ProjectTab

# -------------------------------------------------------------------------------------------------
const STYLE_ACTIVE = preload("res://UI/Themes/style_tab_active_dark.tres")
const STYLE_INACTIVE = preload("res://UI/Themes/style_tab_inactive_dark.tres")

# -------------------------------------------------------------------------------------------------
signal selected
signal close_requested

# -------------------------------------------------------------------------------------------------
@onready var _filename_button: Button = $HBoxContainer/FilenameButton
@onready var _close_button: TextureButton = $HBoxContainer/CloseButton

var is_active := false
var title: String: set = set_title
var project_id: int

# -------------------------------------------------------------------------------------------------
func _ready():
	set_active(false)
	_filename_button.text = title
	
	_filename_button.pressed.connect(_on_FilenameButton_pressed)
	_close_button.pressed.connect(_on_CloseButton_pressed)

# -------------------------------------------------------------------------------------------------
func set_title(t: String) -> void:
	title = t
	if _filename_button != null:
		_filename_button.text = title

# -------------------------------------------------------------------------------------------------
func _on_FilenameButton_pressed():
	emit_signal("selected", self)

# -------------------------------------------------------------------------------------------------
func _on_CloseButton_pressed():
	emit_signal("close_requested", self)

# -------------------------------------------------------------------------------------------------
func set_active(active: bool) -> void:
	is_active = active
	var new_style = STYLE_INACTIVE
	if is_active:
		new_style = STYLE_ACTIVE
	set("theme_override_styles/panel", new_style)
