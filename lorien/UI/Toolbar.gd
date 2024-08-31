extends ScrollContainer
class_name Toolbar

signal new_project
signal open_project(filepath: String)
signal save_project
signal clear_canvas
signal undo_action
signal redo_action
signal toggle_brush_color_picker
signal brush_size_changed(size: float)
signal tool_changed(t: Types.Tool)

# -------------------------------------------------------------------------------------------------
const BUTTON_HOVER_COLOR = Color("50ffd6")
const BUTTON_CLICK_COLOR = Color("50ffd6")
const BUTTON_NORMAL_COLOR = Color.WHITE

# -------------------------------------------------------------------------------------------------
@export var file_dialog_path: NodePath

@onready var _new_button: FlatTextureButton = $Console/Left/NewFileButton
@onready var _save_button: FlatTextureButton = $Console/Left/SaveFileButton
@onready var _open_button: FlatTextureButton = $Console/Left/OpenFileButton
@onready var _undo_button: FlatTextureButton = $Console/Left/UndoButton
@onready var _redo_button: FlatTextureButton = $Console/Left/RedoButton
@onready var _color_button: Button = $Console/Left/ColorButton
@onready var _brush_size_label: Label = $Console/Left/BrushSizeLabel
@onready var _brush_size_slider: HSlider = $Console/Left/BrushSizeSlider
@onready var _tool_btn_brush: FlatTextureButton = $Console/Left/BrushToolButton
@onready var _tool_btn_rectangle: FlatTextureButton = $Console/Left/RectangleToolButton
@onready var _tool_btn_circle: FlatTextureButton = $Console/Left/CircleToolButton
@onready var _tool_btn_line: FlatTextureButton = $Console/Left/LineToolButton
@onready var _tool_btn_eraser: FlatTextureButton = $Console/Left/EraserToolButton
@onready var _tool_btn_selection: FlatTextureButton = $Console/Left/SelectionToolButton

var _last_active_tool_button: FlatTextureButton

# -------------------------------------------------------------------------------------------------
func _ready() -> void:
	# Set inintial values
	var brush_size: int = Settings.get_value(Settings.GENERAL_DEFAULT_BRUSH_SIZE, Config.DEFAULT_BRUSH_SIZE)
	_brush_size_label.text = str(brush_size)
	_brush_size_slider.value = brush_size
	_last_active_tool_button = _tool_btn_brush
	
	# Tooltips (dynamic because they include keybindings)
	for action: KeybindingsManager.Action in KeybindingsManager.get_actions():
		_on_keybinding_changed(action)
	
	# Signals
	ProjectManager.active_project_changed.connect(_on_active_project_changed)
	GlobalSignals.keybinding_changed.connect(_on_keybinding_changed)
	
	_new_button.pressed.connect(func() -> void: new_project.emit())
	_undo_button.pressed.connect(func() -> void: undo_action.emit())
	_redo_button.pressed.connect(func() -> void: redo_action.emit())
	_open_button.pressed.connect(_on_open_project_pressed)
	_save_button.pressed.connect(func() -> void: save_project.emit())
	_color_button.pressed.connect(func() -> void: toggle_brush_color_picker.emit())
	_brush_size_slider.value_changed.connect(_on_brush_size_changed)
	_tool_btn_brush.pressed.connect(_on_brush_tool_pressed)
	_tool_btn_rectangle.pressed.connect(_on_rectangle_tool_pressed)
	_tool_btn_circle.pressed.connect(_on_circle_tool_pressed)
	_tool_btn_line.pressed.connect(_on_line_tool_pressed)
	_tool_btn_eraser.pressed.connect(_on_eraser_tool_pressed)
	_tool_btn_selection.pressed.connect(_on_select_tool_pressed)
	
# -------------------------------------------------------------------------------------------------
func enable_tool(tool_type: Types.Tool) -> void:
	var btn: TextureButton
	match tool_type:
		Types.Tool.BRUSH: btn = _tool_btn_brush
		Types.Tool.LINE: btn = _tool_btn_line
		Types.Tool.ERASER: btn = _tool_btn_eraser
		Types.Tool.SELECT: btn = _tool_btn_selection
		Types.Tool.RECTANGLE: btn = _tool_btn_rectangle
		Types.Tool.CIRCLE: btn = _tool_btn_circle
	
	btn.toggle()
	_change_active_tool_button(btn)
	tool_changed.emit(tool_type)

# -------------------------------------------------------------------------------------------------
func set_brush_color(color: Color) -> void:
	_color_button.get("theme_override_styles/normal").bg_color = color
	var lum := color.r * 0.2126 + color.g * 0.7152 + color.b * 0.0722
	var text_color := Color.BLACK if lum > 0.4 else Color.WHITE	
	_color_button.set("theme_override_colors/font_color", text_color)
	_color_button.set("theme_override_colors/font_hover_color", text_color)
	_color_button.set("theme_override_colors/font_pressed_color", text_color)
	_color_button.set("theme_override_colors/font_focus_color", text_color)
	_color_button.text = "#" + color.to_html(false)

# -------------------------------------------------------------------------------------------------
func get_brush_color_button() -> Control:
	return _color_button

# -------------------------------------------------------------------------------------------------
func _on_keybinding_changed(action: KeybindingsManager.Action) -> void:
	var label := action.event_label()
	var fmt := "%s (%s)"
	match action.name:
		"shortcut_new_project": _new_button.tooltip_text = fmt % [tr("TOOLBAR_TOOLTIP_NEW_FILE"), label]
		"shortcut_open_project": _open_button.tooltip_text = fmt % [tr("TOOLBAR_TOOLTIP_OPEN_FILE"), label]
		"shortcut_save_project": _save_button.tooltip_text = fmt % [tr("TOOLBAR_TOOLTIP_SAVE_FILE"), label]
		"shortcut_undo": _undo_button.tooltip_text = fmt % [tr("TOOLBAR_TOOLTIP_UNDO"), label]
		"shortcut_redo": _redo_button.tooltip_text = fmt % [tr("TOOLBAR_TOOLTIP_REDO"), label]
		"shortcut_brush_tool": _tool_btn_brush.tooltip_text = fmt % [tr("TOOLBAR_TOOLTIP_BRUSH_TOOL"), label]
		"shortcut_rectangle_tool": _tool_btn_rectangle.tooltip_text = fmt % [tr("TOOLBAR_TOOLTIP_RECTANGLE_TOOL"), label]
		"shortcut_circle_tool": _tool_btn_circle.tooltip_text = fmt % [tr("TOOLBAR_TOOLTIP_CIRCLE_TOOL"), label]
		"shortcut_line_tool": _tool_btn_line.tooltip_text = fmt % [tr("TOOLBAR_TOOLTIP_LINE_TOOL"), label]
		"shortcut_eraser_tool": _tool_btn_eraser.tooltip_text = fmt % [tr("TOOLBAR_TOOLTIP_ERASER_TOOL"), label]
		"shortcut_select_tool": _tool_btn_selection.tooltip_text = fmt % [tr("TOOLBAR_TOOLTIP_SELECT_TOOL"), label]

# -------------------------------------------------------------------------------------------------
func _on_open_project_pressed() -> void:
	var file_dialog: FileDialog = get_node(file_dialog_path)
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.file_selected.connect(_on_project_selected_to_open)
	file_dialog.close_requested.connect(_on_file_dialog_closed)
	file_dialog.invalidate()
	file_dialog.popup_centered()

# -------------------------------------------------------------------------------------------------
func _on_project_selected_to_open(filepath: String) -> void:
	open_project.emit(filepath)

# -------------------------------------------------------------------------------------------------
func _on_file_dialog_closed() -> void:
	var file_dialog: FileDialog = get_node(file_dialog_path)
	Utils.remove_signal_connections(file_dialog, "file_selected")
	Utils.remove_signal_connections(file_dialog, "close_requested")

# -------------------------------------------------------------------------------------------------
func _on_brush_size_changed(value: float) -> void:
	var new_size := int(value)
	_brush_size_label.text = "%d" % new_size
	brush_size_changed.emit(new_size)

# -------------------------------------------------------------------------------------------------
func _on_brush_tool_pressed() -> void:
	_change_active_tool_button(_tool_btn_brush)
	tool_changed.emit(Types.Tool.BRUSH)

# -------------------------------------------------------------------------------------------------
func _on_rectangle_tool_pressed() -> void:
	_change_active_tool_button(_tool_btn_rectangle)
	tool_changed.emit(Types.Tool.RECTANGLE)

# -------------------------------------------------------------------------------------------------
func _on_circle_tool_pressed() -> void:
	_change_active_tool_button(_tool_btn_circle)
	tool_changed.emit(Types.Tool.CIRCLE)	
	
# -------------------------------------------------------------------------------------------------
func _on_line_tool_pressed() -> void:
	_change_active_tool_button(_tool_btn_line)
	tool_changed.emit(Types.Tool.LINE)

# -------------------------------------------------------------------------------------------------
func _on_eraser_tool_pressed() -> void:
	_change_active_tool_button(_tool_btn_eraser)
	tool_changed.emit(Types.Tool.ERASER)

# -------------------------------------------------------------------------------------------------
func _on_select_tool_pressed() -> void:
	_change_active_tool_button(_tool_btn_selection)
	tool_changed.emit(Types.Tool.SELECT)

# -------------------------------------------------------------------------------------------------
func _change_active_tool_button(btn: TextureButton) -> void:
	if _last_active_tool_button != null:
		_last_active_tool_button.toggle()
	_last_active_tool_button = btn

# -------------------------------------------------------------------------------------------------
func _on_active_project_changed(previous_project: Project, current_project: Project) -> void:
	_update_undo_redo_buttons()
	
	if previous_project != null:
		previous_project.dirtied.disconnect(_on_project_dirtied)
		previous_project.undo_redo.version_changed.disconnect(_on_undo_or_redo_occured)
	
	if current_project != null:
		current_project.dirtied.connect(_on_project_dirtied)
		current_project.undo_redo.version_changed.connect(_on_undo_or_redo_occured)

# -------------------------------------------------------------------------------------------------
func _on_project_dirtied() -> void:
	_update_undo_redo_buttons()

# -------------------------------------------------------------------------------------------------
func _on_undo_or_redo_occured() -> void:
	_update_undo_redo_buttons()

# -------------------------------------------------------------------------------------------------
func _update_undo_redo_buttons() -> void:
	var active_project: Project = ProjectManager.get_active_project()
	if active_project == null:
		_undo_button.set_is_disabled(true)
		_redo_button.set_is_disabled(true)
		return
	
	_undo_button.set_is_disabled(!active_project.undo_redo.has_undo())
	_redo_button.set_is_disabled(!active_project.undo_redo.has_redo())
