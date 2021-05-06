extends Panel

# -------------------------------------------------------------------------------------------------
signal brush_size_changed(size)
signal brush_color_changed(color)
signal clear_canvas()
signal save_project(filepath) 
signal load_project(filepath)

# -------------------------------------------------------------------------------------------------
onready var _save_file_dialog: FileDialog = $SaveFileDialog
onready var _load_file_dialog: FileDialog = $LoadFileDialog
onready var _color_picker_button: ColorPickerButton = $MarginContainer/VBoxContainer/ColorPickerButton
onready var _color_label: Label = $MarginContainer/VBoxContainer/ColorLabel
onready var _size_label: Label = $MarginContainer/VBoxContainer/SizeLabel

# -------------------------------------------------------------------------------------------------
func _ready() -> void:
	_save_file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	_save_file_dialog.mode = FileDialog.MODE_SAVE_FILE
	_save_file_dialog.current_dir = Config.DEFAULT_FILE_DIALOG_FOLDER
	_save_file_dialog.filters = ["*.jabol", "*.jabolb"]
	
	_load_file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	_load_file_dialog.mode = FileDialog.MODE_OPEN_FILE
	_load_file_dialog.current_dir = Config.DEFAULT_FILE_DIALOG_FOLDER
	_load_file_dialog.filters = ["*.jabol", "*.jabolb"]

# -------------------------------------------------------------------------------------------------
func _on_ColorPickerButton_color_changed(color: Color) -> void:
	_color_label.text = "Color: #%s" % color.to_html(false)
	emit_signal("brush_color_changed", color)

# -------------------------------------------------------------------------------------------------
func _on_SizeSlider_value_changed(value: float) -> void:
	_size_label.text = "Size: %d" % int(value)
	emit_signal("brush_size_changed", value)

# -------------------------------------------------------------------------------------------------
func _on_SaveButton_pressed() -> void:
	_save_file_dialog.popup_centered()

# -------------------------------------------------------------------------------------------------
func _on_LoadButton_pressed() -> void:
	# TODO: ask user to save current project
	_load_file_dialog.popup_centered()

# -------------------------------------------------------------------------------------------------
func _on_ClearButton_pressed() -> void:
	emit_signal("clear_canvas")

# -------------------------------------------------------------------------------------------------
func _on_SaveFileDialog_file_selected(path: String) -> void:
	emit_signal("save_project", path)

# -------------------------------------------------------------------------------------------------
func _on_LoadFileDialog_file_selected(path: String) -> void:
	emit_signal("load_project", path)
