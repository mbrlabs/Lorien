extends Panel
class_name UIToolbar

signal new_file
signal open_file(filepath)
signal save_file(filepath)
signal clear_canvas
signal undo_action
signal redo_action
signal brush_color_changed(color)
signal brush_size_changed(size)
signal canvas_background_changed(color)

# -------------------------------------------------------------------------------------------------
const BUTTON_HOVER_COLOR = Color("50ffd6")
const BUTTON_CLICK_COLOR = Color("50ffd6")
const BUTTON_NORMAL_COLOR = Color.white

# -------------------------------------------------------------------------------------------------
export var file_dialog_path: NodePath
export var brush_color_picker_path: NodePath
export var background_color_picker_path: NodePath

onready var _new_button: TextureButton = $Left/NewFileButton
onready var _save_button: TextureButton = $Left/SaveFileButton
onready var _open_button: TextureButton = $Left/OpenFileButton
onready var _clear_canvas_button: TextureButton = $Left/ClearCanvasButton
onready var _undo_button: TextureButton = $Left/UndoButton
onready var _redo_button: TextureButton = $Left/RedoButton
onready var _color_button: Button = $Left/ColorButton
onready var _brush_size_label: Label = $Left/BrushSizeLabel
onready var _brush_size_slider: HSlider = $Left/BrushSizeSlider
onready var _brush_color_picker: ColorPicker = get_node(brush_color_picker_path)
onready var _brush_color_picker_popup: Popup = get_node(brush_color_picker_path).get_parent().get_parent() # meh...
onready var _background_color_picker: ColorPicker = get_node(background_color_picker_path)
onready var _background_color_picker_popup: Popup = get_node(background_color_picker_path).get_parent().get_parent() # meh...

# -------------------------------------------------------------------------------------------------
func _ready():
	_brush_color_picker.connect("color_changed", self, "_on_brush_color_changed")
	_background_color_picker.connect("color_changed", self, "_on_background_color_changed")
	_brush_size_label.text = str(Config.DEFAULT_BRUSH_SIZE)
	_brush_size_slider.value = Config.DEFAULT_BRUSH_SIZE
	_on_brush_color_changed(Config.DEFAULT_BRUSH_COLOR)

# Button clicked callbacks
# -------------------------------------------------------------------------------------------------
func _on_NewFileButton_pressed(): emit_signal("new_file")
func _on_ClearCanvasButton_pressed(): emit_signal("clear_canvas")
func _on_UndoButton_pressed(): emit_signal("undo_action")
func _on_RedoButton_pressed(): emit_signal("redo_action")

# -------------------------------------------------------------------------------------------------
func _on_OpenFileButton_pressed():
	var file_dialog: FileDialog = get_node(file_dialog_path)
	file_dialog.mode = FileDialog.MODE_OPEN_FILE
	file_dialog.connect("file_selected", self, "_on_file_selected_to_open")
	file_dialog.connect("popup_hide", self, "_on_file_dialog_closed")
	file_dialog.popup_centered()

# -------------------------------------------------------------------------------------------------
func _on_file_selected_to_open(filepath: String) -> void:
	emit_signal("open_file", filepath)

# -------------------------------------------------------------------------------------------------
func _on_SaveFileButton_pressed():
	var file_dialog: FileDialog = get_node(file_dialog_path)
	file_dialog.mode = FileDialog.MODE_SAVE_FILE
	file_dialog.connect("file_selected", self, "_on_file_selected_to_save")
	file_dialog.connect("popup_hide", self, "_on_file_dialog_closed")
	file_dialog.popup_centered()

# -------------------------------------------------------------------------------------------------
func _on_file_selected_to_save(filepath: String) -> void:
	emit_signal("save_file", filepath)

# -------------------------------------------------------------------------------------------------
func _on_file_dialog_closed() -> void:
	var file_dialog: FileDialog = get_node(file_dialog_path)
	Utils.remove_signal_connections(file_dialog, "file_selected")
	Utils.remove_signal_connections(file_dialog, "popup_hide")

# -------------------------------------------------------------------------------------------------
func _on_ColorButton_pressed():
	_brush_color_picker_popup.popup()

# -------------------------------------------------------------------------------------------------
func _on_brush_color_changed(color: Color) -> void:
	_color_button.get("custom_styles/normal").bg_color = color
	var text_color := color.inverted()
	_color_button.set("custom_colors/font_color", text_color)
	_color_button.set("custom_colors/font_color_hover", text_color)
	_color_button.set("custom_colors/font_color_pressed", text_color)
	_color_button.text = color.to_html(false)
	emit_signal("brush_color_changed", color)

# -------------------------------------------------------------------------------------------------
func _on_background_color_changed(color: Color) -> void:
	emit_signal("canvas_background_changed", color)

# -------------------------------------------------------------------------------------------------
func _on_BrushSizeSlider_value_changed(value: float):
	var new_size := int(value)
	_brush_size_label.text = "%d" % new_size
	emit_signal("brush_size_changed", new_size)

# -------------------------------------------------------------------------------------------------
func _on_BackgroundColorButton_pressed():
	_background_color_picker_popup.popup()

# -------------------------------------------------------------------------------------------------
func _on_GridButton_pressed():
	pass # Replace with function body.
