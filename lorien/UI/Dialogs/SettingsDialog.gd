extends WindowDialog

# -------------------------------------------------------------------------------------------------
const THEME_DARK_INDEX 	:= 0
const THEME_LIGHT_INDEX := 1

const GRID_PATTERN_DOTS_INDEX 	:= 0
const GRID_PATTERN_LINES_INDEX 	:= 1
const GRID_PATTERN_NONE_INDEX 	:= 2

const AA_NONE_INDEX 		:= 0
const AA_OPENGL_HINT_INDEX 	:= 1
const AA_TEXTURE_FILL_INDEX := 2

const UI_SCALE_AUTO_INDEX := 0
const UI_SCALE_CUSTOM_INDEX := 1

# -------------------------------------------------------------------------------------------------
signal ui_scale_changed
signal canvas_color_changed(color)
signal grid_size_changed(size)
signal grid_pattern_changed(pattern)

# -------------------------------------------------------------------------------------------------
onready var _tab_container: TabContainer = $MarginContainer/TabContainer
onready var _tab_general: Control = $MarginContainer/TabContainer/General
onready var _tab_appearance: Control = $MarginContainer/TabContainer/Appearance
onready var _tab_rendering: Control = $MarginContainer/TabContainer/Rendering
onready var _pressure_sensitivity: SpinBox = $MarginContainer/TabContainer/General/VBoxContainer/PressureSensitivity/PressureSensitivity
onready var _brush_size: SpinBox = $MarginContainer/TabContainer/General/VBoxContainer/DefaultBrushSize/DefaultBrushSize
onready var _canvas_color: ColorPickerButton = $MarginContainer/TabContainer/Appearance/VBoxContainer/CanvasColor/CanvasColor
onready var _project_dir: LineEdit = $MarginContainer/TabContainer/General/VBoxContainer/DefaultSaveDir/DefaultSaveDir
onready var _theme: OptionButton = $MarginContainer/TabContainer/Appearance/VBoxContainer/Theme/Theme
onready var _aa_mode: OptionButton = $MarginContainer/TabContainer/Rendering/VBoxContainer/AntiAliasing/AntiAliasing
onready var _foreground_fps: SpinBox = $MarginContainer/TabContainer/Rendering/VBoxContainer/TargetFramerate/TargetFramerate
onready var _background_fps: SpinBox = $MarginContainer/TabContainer/Rendering/VBoxContainer/BackgroundFramerate/BackgroundFramerate
onready var _general_restart_label: Label = $MarginContainer/TabContainer/General/VBoxContainer/RestartLabel
onready var _appearence_restart_label: Label = $MarginContainer/TabContainer/Appearance/VBoxContainer/RestartLabel
onready var _rendering_restart_label: Label = $MarginContainer/TabContainer/Rendering/VBoxContainer/RestartLabel
onready var _language_options: OptionButton = $MarginContainer/TabContainer/General/VBoxContainer/Language/OptionButton
onready var _brush_rounding_options: OptionButton = $MarginContainer/TabContainer/Rendering/VBoxContainer/BrushRounding/OptionButton
onready var _ui_scale_options: OptionButton = $MarginContainer/TabContainer/Appearance/VBoxContainer/UIScale/HBoxContainer/UIScaleOptions
onready var _ui_scale: SpinBox = $MarginContainer/TabContainer/Appearance/VBoxContainer/UIScale/HBoxContainer/UIScale
onready var _grid_size: SpinBox = $MarginContainer/TabContainer/Appearance/VBoxContainer/GridSize/GridSize
onready var _grid_pattern: OptionButton = $MarginContainer/TabContainer/Appearance/VBoxContainer/GridPattern/GridPattern
onready var _tool_pressure: SpinBox = $MarginContainer/TabContainer/General/VBoxContainer/DefaultToolPressure/DefaultToolPressure

# -------------------------------------------------------------------------------------------------
func _ready():
	_set_values()
	_apply_language()
	GlobalSignals.connect("language_changed", self, "_apply_language")

# -------------------------------------------------------------------------------------------------
func _apply_language() -> void:
	_tab_container.set_tab_title(0, tr("SETTINGS_GENERAL"))
	_tab_container.set_tab_title(1, tr("SETTINGS_APPEARANCE"))
	_tab_container.set_tab_title(2, tr("SETTINGS_RENDERING"))
	_tab_container.set_tab_title(3, tr("SETTINGS_KEYBINDINGS"))

# -------------------------------------------------------------------------------------------------
func _set_values() -> void:
	var brush_size = Settings.get_value(Settings.GENERAL_DEFAULT_BRUSH_SIZE, Config.DEFAULT_BRUSH_SIZE)
	var canvas_color = Settings.get_value(Settings.APPEARANCE_CANVAS_COLOR, Config.DEFAULT_CANVAS_COLOR)
	var project_dir = Settings.get_value(Settings.GENERAL_DEFAULT_PROJECT_DIR, "")
	var theme = Settings.get_value(Settings.APPEARANCE_THEME, Types.UITheme.DARK)
	var aa_mode = Settings.get_value(Settings.RENDERING_AA_MODE, Config.DEFAULT_AA_MODE)
	var locale = Settings.get_value(Settings.GENERAL_LANGUAGE, "en")
	var foreground_fps = Settings.get_value(Settings.RENDERING_FOREGROUND_FPS, Config.DEFAULT_FOREGROUND_FPS)
	var background_fps = Settings.get_value(Settings.RENDERING_BACKGROUND_FPS, Config.DEFAULT_BACKGROUND_FPS)
	var pressure_sensitivity = Settings.get_value(Settings.GENERAL_PRESSURE_SENSITIVITY, Config.DEFAULT_PRESSURE_SENSITIVITY)
	var ui_scale_mode = Settings.get_value(Settings.APPEARANCE_UI_SCALE_MODE, Config.DEFAULT_UI_SCALE_MODE)
	var ui_scale = Settings.get_value(Settings.APPEARANCE_UI_SCALE, Config.DEFAULT_UI_SCALE)
	var grid_pattern = Settings.get_value(Settings.APPEARANCE_GRID_PATTERN, Config.DEFAULT_GRID_PATTERN)
	var grid_size = Settings.get_value(Settings.APPEARANCE_GRID_SIZE, Config.DEFAULT_GRID_SIZE)
	var tool_pressure = Settings.get_value(Settings.GENERAL_TOOL_PRESSURE, Config.DEFAULT_TOOL_PRESSURE)
	
	match theme:
		Types.UITheme.DARK: _theme.selected = THEME_DARK_INDEX
		Types.UITheme.LIGHT: _theme.selected = THEME_LIGHT_INDEX
	match aa_mode:
		Types.AAMode.NONE: _aa_mode.selected = AA_NONE_INDEX
		Types.AAMode.OPENGL_HINT: _aa_mode.selected = AA_OPENGL_HINT_INDEX
		Types.AAMode.TEXTURE_FILL: _aa_mode.selected = AA_TEXTURE_FILL_INDEX
	match ui_scale_mode: 
		Types.UIScale.AUTO: 
			_ui_scale_options.selected = UI_SCALE_AUTO_INDEX
			_ui_scale.set_editable(false)
		Types.UIScale.CUSTOM: _ui_scale_options.selected = UI_SCALE_CUSTOM_INDEX
		
	_set_languages(locale)
	_set_rounding()
	_set_UIScale_range()
	
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
	_brush_rounding_options.selected = Settings.get_value(Settings.RENDERING_BRUSH_ROUNDING, Config.DEFAULT_BRUSH_ROUNDING)

# -------------------------------------------------------------------------------------------------
func _set_languages(current_locale: String) -> void:
	# Technically, Settings.language_names is useless from here on out, but I figure it's probably gonna come in handy in the future
	var sorted_languages := Array(Settings.language_names)
	var unsorted_languages := sorted_languages.duplicate()
	# English appears at the top, so it mustn't be sorted alphabetically with the rest
	sorted_languages.erase("English")
	sorted_languages.sort()
	
	# Add English before the rest + a separator so that it doesn't look weird for the alphabetical order to start after it
	_language_options.add_item("English", unsorted_languages.find("English"))
	_language_options.add_separator()
	for lang in sorted_languages:
		var id := unsorted_languages.find(lang)
		_language_options.add_item(lang, id)
	
	# Set selected
	var id := Array(Settings.locales).find(current_locale)
	_language_options.selected = _language_options.get_item_index(id)

#--------------------------------------------------------------------------------------------------
func _set_UIScale_range():
	var screen_scale_max: float = (OS.get_screen_size().x * OS.get_screen_size().y) / (ProjectSettings.get_setting("display/window/size/width") * ProjectSettings.get_setting("display/window/size/height"))
	var screen_scale_min: float = OS.get_screen_size().x / ProjectSettings.get_setting("display/window/size/width")
	_ui_scale.min_value = max(screen_scale_min / 2, 0.5)
	_ui_scale.max_value = screen_scale_max + 1.5

#--------------------------------------------------------------------------------------------------
func get_max_ui_scale() -> float:
	return _ui_scale.max_value

#--------------------------------------------------------------------------------------------------
func get_min_ui_scale() -> float:
	return _ui_scale.min_value

# -------------------------------------------------------------------------------------------------
func _on_DefaultBrushSize_value_changed(value: int) -> void:
	Settings.set_value(Settings.GENERAL_DEFAULT_BRUSH_SIZE, int(value))

# -------------------------------------------------------------------------------------------------
func _on_CanvasColor_color_changed(color: Color) -> void:
	Settings.set_value(Settings.APPEARANCE_CANVAS_COLOR, color)
	emit_signal("canvas_color_changed", color)

# -------------------------------------------------------------------------------------------------
func _on_GridSize_value_changed(value: int) -> void:
	Settings.set_value(Settings.APPEARANCE_GRID_SIZE, value)
	emit_signal("grid_size_changed", value)
	
# -------------------------------------------------------------------------------------------------
func _on_GridPattern_item_selected(index: int) -> void:
	var pattern: int = Types.GridPattern.NONE
	match index:
		GRID_PATTERN_DOTS_INDEX: 	pattern = Types.GridPattern.DOTS
		GRID_PATTERN_LINES_INDEX: 	pattern = Types.GridPattern.LINES
	Settings.set_value(Settings.APPEARANCE_GRID_PATTERN, pattern)
	emit_signal("grid_pattern_changed", pattern)

# -------------------------------------------------------------------------------------------------
func _on_PressureSensitivity_value_changed(value: float):
	Settings.set_value(Settings.GENERAL_PRESSURE_SENSITIVITY, value)

# -------------------------------------------------------------------------------------------------
func _on_DefaultSaveDir_text_changed(text: String) -> void:
	text = text.replace("\\", "/")
	
	var dir = Directory.new()
	if dir.dir_exists(text):
		Settings.set_value(Settings.GENERAL_DEFAULT_PROJECT_DIR, text)

# -------------------------------------------------------------------------------------------------
func _on_Target_Fps_Foreground_changed(value: int) -> void:
	Settings.set_value(Settings.RENDERING_FOREGROUND_FPS, value)

	# Settings FPS so user instantly Sees fps Change else fps only changes after unfocusing
	Engine.target_fps = value

# -------------------------------------------------------------------------------------------------
func _on_Target_Fps_Background_changed(value: int) -> void:
	# Background Fps need to be a minimum of 5 so you can smoothly reopen the window
	Settings.set_value(Settings.RENDERING_BACKGROUND_FPS, value)

# -------------------------------------------------------------------------------------------------
func _on_Theme_item_selected(index: int):
	var theme: int
	match index:
		THEME_DARK_INDEX: theme = Types.UITheme.DARK
		THEME_LIGHT_INDEX: theme = Types.UITheme.LIGHT
	
	Settings.set_value(Settings.APPEARANCE_THEME, theme)
	_appearence_restart_label.show()

# -------------------------------------------------------------------------------------------------
func _on_AntiAliasing_item_selected(index: int):
	var aa_mode: int
	match index:
		AA_NONE_INDEX: aa_mode = Types.AAMode.NONE
		AA_OPENGL_HINT_INDEX: aa_mode = Types.AAMode.OPENGL_HINT
		AA_TEXTURE_FILL_INDEX: aa_mode = Types.AAMode.TEXTURE_FILL
	
	Settings.set_value(Settings.RENDERING_AA_MODE, aa_mode)
	_rendering_restart_label.show()

# -------------------------------------------------------------------------------------------------
func _on_Brush_rounding_item_selected(index: int):
	match index:
		0:
			Settings.set_value(Settings.RENDERING_BRUSH_ROUNDING, Types.BrushRoundingType.FLAT)
		1:
			Settings.set_value(Settings.RENDERING_BRUSH_ROUNDING, Types.BrushRoundingType.ROUNDED)
	
	# The Changes do work even without restarting but if the user doesn't restart old strokes remain
	# the same (Don't wanna implement saving of the cap roundings per line since that would break file
	# Compatibility)
	_general_restart_label.show()

# -------------------------------------------------------------------------------------------------
func _on_OptionButton_item_selected(idx: int):
	var id := _language_options.get_item_id(idx)
	var locale: String = Settings.locales[id]
	
	Settings.set_value(Settings.GENERAL_LANGUAGE, locale)
	TranslationServer.set_locale(locale)
	GlobalSignals.emit_signal("language_changed")

# -------------------------------------------------------------------------------------------------
func _on_UIScaleOptions_item_selected(index: int):
	match index:
		UI_SCALE_AUTO_INDEX:
			_ui_scale.set_editable(false)
			Settings.set_value(Settings.APPEARANCE_UI_SCALE_MODE, Types.UIScale.AUTO)
		UI_SCALE_CUSTOM_INDEX:
			_ui_scale.set_editable(true)
			Settings.set_value(Settings.APPEARANCE_UI_SCALE_MODE, Types.UIScale.CUSTOM)
	emit_signal("ui_scale_changed")
	popup_centered()

# -------------------------------------------------------------------------------------------------
func _on_UIScale_value_changed(value: float):
	if Input.is_action_just_pressed("ui_accept") || _ui_scale.is_ready():
		Settings.set_value(Settings.APPEARANCE_UI_SCALE, value)
		emit_signal("ui_scale_changed")
		popup_centered()

# -------------------------------------------------------------------------------------------------
func _on_DefaultToolPressure_value_changed(value):
	Settings.set_value(Settings.GENERAL_TOOL_PRESSURE, value)
