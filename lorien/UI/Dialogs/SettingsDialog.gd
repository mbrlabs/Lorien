class_name SettingsDialog
extends PanelContainer

# -------------------------------------------------------------------------------------------------
const KEYBIND_ITEM = preload("res://UI/Components/KeybindItem.tscn")

# -------------------------------------------------------------------------------------------------
const THEME_DARK_INDEX 	:= 0
const THEME_LIGHT_INDEX := 1

const GRID_PATTERN_DOTS_INDEX 	:= 0
const GRID_PATTERN_LINES_INDEX 	:= 1
const GRID_PATTERN_NONE_INDEX 	:= 2

const UI_SCALE_AUTO_INDEX := 0
const UI_SCALE_CUSTOM_INDEX := 1

const BRUSH_STROKE_CAP_FLAT 	:= 0
const BRUSH_STROKE_CAP_ROUND 	:= 1

# -------------------------------------------------------------------------------------------------
signal ui_scale_changed
signal canvas_color_changed(color)
signal grid_size_changed(size)
signal grid_pattern_changed(pattern)
signal constant_pressure_changed(state)

# -------------------------------------------------------------------------------------------------
@onready var _general_tab: Button = %GeneralTab
@onready var _appearance_tab: Button = %AppearanceTab
@onready var _rendering_tab: Button = %RenderingTab
@onready var _keybindings_tab: Button = %KeybindingsTab
@onready var _general_container: ScrollContainer = %GeneralContainer
@onready var _appearance_container: ScrollContainer = %AppearanceContainer
@onready var _rendering_container: ScrollContainer = %RenderingContainer
@onready var _keybindings_container: ScrollContainer = %KeybindingsContainer

@onready var _pressure_sensitivity: SpinBox = %PressureSensitivity
@onready var _constant_pressure: CheckBox = %ConstantPressure
@onready var _brush_size: SpinBox = %DefaultBrushSize
@onready var _tool_pressure: SpinBox = %DefaultToolPressure
@onready var _project_dir: LineEdit = %DefaultProjectDir
@onready var _language: OptionButton = %Language
@onready var _theme: OptionButton = %Theme
@onready var _canvas_color: ColorPickerButton= %CanvasColor
@onready var _ui_scale_mode: OptionButton = %UIScaleOptions
@onready var _ui_scale: SpinBox = %UIScale
@onready var _grid_size: SpinBox = %GridSize
@onready var _grid_pattern: OptionButton = %GridPattern
@onready var _foreground_fps: SpinBox = %ForgroundFramerate
@onready var _background_fps: SpinBox = %BackgroundFramerate
@onready var _brush_rounding: OptionButton = %BrushRounding
@onready var _keybind_item_list: VBoxContainer = %KeybindItemList
@onready var _restart_label: Label = %RestartLabel

# -------------------------------------------------------------------------------------------------
func _ready():
	_set_values()
	get_parent().close_requested.connect(get_parent().hide)
	_enable_tab(_general_tab, _general_container)
	
	_pressure_sensitivity.value_changed.connect(_on_pressure_sensitivity_changed)
	_constant_pressure.toggled.connect(_on_constant_pressure_toggled)
	_brush_size.value_changed.connect(_on_default_brush_size_changed)
	_tool_pressure.value_changed.connect(_on_default_tool_pressure_changed)
	_project_dir.text_changed.connect(_on_default_project_dir_changed)
	_language.item_selected.connect(_on_language_selected)
	_theme.item_selected.connect(_on_theme_selected)
	_ui_scale_mode.item_selected.connect(_on_ui_scale_mode_selected)
	_ui_scale.value_changed.connect(_on_ui_scale_changed)
	_canvas_color.color_changed.connect(_on_canvas_color_changed)
	_grid_pattern.item_selected.connect(_on_grid_pattern_selected)
	_grid_size.value_changed.connect(_on_grid_size_changed)
	_brush_rounding.item_selected.connect(_on_brush_rounding_selected)
	_foreground_fps.value_changed.connect(_on_foreground_fps_changed)
	_background_fps.value_changed.connect(_on_background_fps_changed)
	
	_general_tab.pressed.connect(func(): _enable_tab(_general_tab, _general_container))
	_appearance_tab.pressed.connect(func(): _enable_tab(_appearance_tab, _appearance_container))
	_rendering_tab.pressed.connect(func(): _enable_tab(_rendering_tab, _rendering_container))
	_keybindings_tab.pressed.connect(func(): _enable_tab(_keybindings_tab, _keybindings_container))

# -------------------------------------------------------------------------------------------------
func _set_values() -> void:
	var brush_size = Settings.get_general_value(Settings.GENERAL_DEFAULT_BRUSH_SIZE, Config.DEFAULT_BRUSH_SIZE)
	var project_dir = Settings.get_general_value(Settings.GENERAL_DEFAULT_PROJECT_DIR, "")
	var locale = Settings.get_general_value(Settings.GENERAL_LANGUAGE, "en")
	var tool_pressure = Settings.get_general_value(Settings.GENERAL_TOOL_PRESSURE, Config.DEFAULT_TOOL_PRESSURE)
	var pressure_sensitivity = Settings.get_general_value(Settings.GENERAL_PRESSURE_SENSITIVITY, Config.DEFAULT_PRESSURE_SENSITIVITY)
	var constant_pressure = Settings.get_general_value(Settings.GENERAL_CONSTANT_PRESSURE, Config.DEFAULT_CONSTANT_PRESSURE)
	
	var canvas_color = Settings.get_appearance_value(Settings.APPEARANCE_CANVAS_COLOR, Config.DEFAULT_CANVAS_COLOR)
	var ui_theme = Settings.get_appearance_value(Settings.APPEARANCE_THEME, Types.UITheme.DARK)
	var ui_scale = Settings.get_appearance_value(Settings.APPEARANCE_UI_SCALE, Config.DEFAULT_UI_SCALE)
	var ui_scale_mode = Settings.get_appearance_value(Settings.APPEARANCE_UI_SCALE_MODE, Config.DEFAULT_UI_SCALE_MODE)
	var grid_pattern = Settings.get_appearance_value(Settings.APPEARANCE_GRID_PATTERN, Config.DEFAULT_GRID_PATTERN)
	var grid_size = Settings.get_appearance_value(Settings.APPEARANCE_GRID_SIZE, Config.DEFAULT_GRID_SIZE)
	
	var foreground_fps = Settings.get_rendering_value(Settings.RENDERING_FOREGROUND_FPS, Config.DEFAULT_FOREGROUND_FPS)
	var background_fps = Settings.get_rendering_value(Settings.RENDERING_BACKGROUND_FPS, Config.DEFAULT_BACKGROUND_FPS)
	
	match ui_theme:
		Types.UITheme.DARK: _theme.selected = THEME_DARK_INDEX
		Types.UITheme.LIGHT: _theme.selected = THEME_LIGHT_INDEX
	match ui_scale_mode: 
		Types.UIScale.AUTO: 
			_ui_scale_mode.selected = UI_SCALE_AUTO_INDEX
			_ui_scale.set_editable(false)
		Types.UIScale.CUSTOM: 
			_ui_scale_mode.selected = UI_SCALE_CUSTOM_INDEX
			_ui_scale.set_editable(true)
		
	_set_languages(locale)
	_set_rounding()
	_set_keybindings()
	_set_ui_scale_range()
	
	_constant_pressure.button_pressed = constant_pressure
	_pressure_sensitivity.value = pressure_sensitivity
	_brush_size.value = brush_size
	_tool_pressure.value = tool_pressure
	_canvas_color.color = canvas_color
	_grid_size.value = grid_size
	match grid_pattern:
		Types.GridPattern.DOTS: _grid_pattern.selected = GRID_PATTERN_DOTS_INDEX
		Types.GridPattern.LINES: _grid_pattern.selected = GRID_PATTERN_LINES_INDEX
		Types.GridPattern.NONE: _grid_pattern.selected = GRID_PATTERN_NONE_INDEX
	_project_dir.text = project_dir
	_foreground_fps.value = foreground_fps
	_background_fps.value = background_fps
	_ui_scale.value = ui_scale
	
# -------------------------------------------------------------------------------------------------
func _set_rounding():
	_brush_rounding.selected = Settings.get_rendering_value(
		Settings.RENDERING_BRUSH_ROUNDING, 
		Config.DEFAULT_BRUSH_ROUNDING
	)

# -------------------------------------------------------------------------------------------------
func _enable_tab(tab: Button, container: Control) -> void:
	_general_tab.modulate = Color.WHITE
	_appearance_tab.modulate = Color.WHITE
	_rendering_tab.modulate = Color.WHITE
	_keybindings_tab.modulate = Color.WHITE
	tab.modulate = Color("92ffe4")
	
	_general_container.hide()
	_appearance_container.hide()
	_rendering_container.hide()
	_keybindings_container.hide()
	container.show()

# -------------------------------------------------------------------------------------------------
func _set_languages(current_locale: String) -> void:
	# Technically, Settings.language_names is useless from here on out, but I figure it's probably
	# gonna come in handy in the future
	var sorted_languages := Array(Settings.language_names)
	var unsorted_languages := sorted_languages.duplicate()
	# English appears at the top, so it mustn't be sorted alphabetically with the rest
	sorted_languages.erase("English")
	sorted_languages.sort()
	
	# Add English before the rest + a separator so that it doesn't look weird for the alphabetical 
	# order to start after it
	_language.add_item("English", unsorted_languages.find("English"))
	_language.add_separator()
	for lang in sorted_languages:
		_language.add_item(lang, unsorted_languages.find(lang))
	
	# Set selected
	var id := Array(Settings.locales).find(current_locale)
	_language.selected = _language.get_item_index(id)

#--------------------------------------------------------------------------------------------------
func _set_keybindings() -> void:
	for action: KeybindingsManager.Action in KeybindingsManager.get_actions():
		var item: KeybindItem = KEYBIND_ITEM.instantiate()
		item.action_rebind_requested.connect(_on_action_keybinding_changed)
		_keybind_item_list.add_child(item)
		item.set_action(action)

#--------------------------------------------------------------------------------------------------
func _set_ui_scale_range():
	var ss := DisplayServer.screen_get_size()
	var viewport_width: float = ProjectSettings.get_setting("display/window/size/viewport_width")
	var viewport_height: float = ProjectSettings.get_setting("display/window/size/viewport_height")
	var screen_scale_max: float = (ss.x * ss.y) / (viewport_width * viewport_height)
	var screen_scale_min: float = ss.x / viewport_width
	_ui_scale.min_value = max(screen_scale_min / 2, 0.5)
	_ui_scale.max_value = screen_scale_max + 1.5

#--------------------------------------------------------------------------------------------------
func get_max_ui_scale() -> float:
	return _ui_scale.max_value

#--------------------------------------------------------------------------------------------------
func get_min_ui_scale() -> float:
	return _ui_scale.min_value

# -------------------------------------------------------------------------------------------------
func _on_default_brush_size_changed(value: int) -> void:
	Settings.set_general_value(Settings.GENERAL_DEFAULT_BRUSH_SIZE, int(value))

# -------------------------------------------------------------------------------------------------
func _on_canvas_color_changed(color: Color) -> void:
	Settings.set_appearance_value(Settings.APPEARANCE_CANVAS_COLOR, color)
	emit_signal("canvas_color_changed", color)

# -------------------------------------------------------------------------------------------------
func _on_grid_size_changed(value: int) -> void:
	Settings.set_appearance_value(Settings.APPEARANCE_GRID_SIZE, value)
	emit_signal("grid_size_changed", value)
	
# -------------------------------------------------------------------------------------------------
func _on_grid_pattern_selected(index: int) -> void:
	var pattern: int = Types.GridPattern.NONE
	match index:
		GRID_PATTERN_DOTS_INDEX: 	pattern = Types.GridPattern.DOTS
		GRID_PATTERN_LINES_INDEX: 	pattern = Types.GridPattern.LINES
	Settings.set_appearance_value(Settings.APPEARANCE_GRID_PATTERN, pattern)
	emit_signal("grid_pattern_changed", pattern)

# -------------------------------------------------------------------------------------------------
func _on_pressure_sensitivity_changed(value: float):
	Settings.set_general_value(Settings.GENERAL_PRESSURE_SENSITIVITY, value)

# -------------------------------------------------------------------------------------------------
func _on_default_project_dir_changed(text: String) -> void:
	text = text.replace("\\", "/")
	
	if DirAccess.dir_exists_absolute(text):
		Settings.set_general_value(Settings.GENERAL_DEFAULT_PROJECT_DIR, text)

# -------------------------------------------------------------------------------------------------
func _on_foreground_fps_changed(value: int) -> void:
	Settings.set_rendering_value(Settings.RENDERING_FOREGROUND_FPS, value)

	# Settings FPS so user instantly Sees fps Change else fps only changes after unfocusing
	Engine.max_fps = value

# -------------------------------------------------------------------------------------------------
func _on_background_fps_changed(value: int) -> void:
	# Background Fps need to be a minimum of 5 so you can smoothly reopen the window
	Settings.set_rendering_value(Settings.RENDERING_BACKGROUND_FPS, value)

# -------------------------------------------------------------------------------------------------
func _on_theme_selected(index: int):
	var ui_theme: Types.UITheme
	match index:
		THEME_DARK_INDEX: ui_theme = Types.UITheme.DARK
		THEME_LIGHT_INDEX: ui_theme = Types.UITheme.LIGHT
	
	Settings.set_appearance_value(Settings.APPEARANCE_THEME, ui_theme)
	_restart_label.show()

# -------------------------------------------------------------------------------------------------
func _on_brush_rounding_selected(index: int):
	match index:
		BRUSH_STROKE_CAP_FLAT:
			Settings.set_rendering_value(Settings.RENDERING_BRUSH_ROUNDING, Types.BrushRoundingType.FLAT)
		BRUSH_STROKE_CAP_ROUND:
			Settings.set_rendering_value(Settings.RENDERING_BRUSH_ROUNDING, Types.BrushRoundingType.ROUNDED)
	_restart_label.show()

# -------------------------------------------------------------------------------------------------
func _on_language_selected(idx: int):
	var id := _language.get_item_id(idx)
	var locale: String = Settings.locales[id]
	
	Settings.set_general_value(Settings.GENERAL_LANGUAGE, locale)
	TranslationServer.set_locale(locale)
	GlobalSignals.emit_signal("language_changed")
	_restart_label.show()

# -------------------------------------------------------------------------------------------------
func _on_ui_scale_mode_selected(index: int):
	match index:
		UI_SCALE_AUTO_INDEX:
			_ui_scale.set_editable(false)
			Settings.set_appearance_value(Settings.APPEARANCE_UI_SCALE_MODE, Types.UIScale.AUTO)
		UI_SCALE_CUSTOM_INDEX:
			_ui_scale.set_editable(true)
			Settings.set_appearance_value(Settings.APPEARANCE_UI_SCALE_MODE, Types.UIScale.CUSTOM)
	emit_signal("ui_scale_changed")

# -------------------------------------------------------------------------------------------------
func _on_ui_scale_changed(value: float):
	print("UI scale changed")
	Settings.set_appearance_value(Settings.APPEARANCE_UI_SCALE, value)
	emit_signal("ui_scale_changed")
	_restart_label.show()

# -------------------------------------------------------------------------------------------------
func _on_default_tool_pressure_changed(value):
	Settings.set_general_value(Settings.GENERAL_TOOL_PRESSURE, value)

# -------------------------------------------------------------------------------------------------
func _on_constant_pressure_toggled(button_pressed: bool):
	Settings.set_general_value(Settings.GENERAL_CONSTANT_PRESSURE, button_pressed)
	emit_signal("constant_pressure_changed", button_pressed)

# -------------------------------------------------------------------------------------------------
func _on_action_keybinding_changed(action: KeybindingsManager.Action, event: InputEventKey) -> void:
	KeybindingsManager.rebind_action(action, event)
	Settings.set_keybind_value(action.name, action.event)
	print("Rebind done")
