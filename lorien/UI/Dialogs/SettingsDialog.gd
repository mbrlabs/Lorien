extends WindowDialog

# -------------------------------------------------------------------------------------------------
const THEME_DARK_INDEX 	:= 0
const THEME_LIGHT_INDEX := 1

const AA_NONE_INDEX 		:= 0
const AA_OPENGL_HINT_INDEX 	:= 1
const AA_TEXTURE_FILL_INDEX := 2

# -------------------------------------------------------------------------------------------------
onready var _tab_general: Control = $MarginContainer/TabContainer/General
onready var _tab_appearance: Control = $MarginContainer/TabContainer/Appearance
onready var _tab_rendering: Control = $MarginContainer/TabContainer/Rendering
onready var _pressure_sensitivity: SpinBox = $MarginContainer/TabContainer/General/VBoxContainer/PressureSensitivity/PressureSensitivity
onready var _brush_size: SpinBox = $MarginContainer/TabContainer/General/VBoxContainer/DefaultBrushSize/DefaultBrushSize
onready var _brush_color: ColorPickerButton = $MarginContainer/TabContainer/General/VBoxContainer/DefaultBrushColor/DefaultBrushColor
onready var _canvas_color: ColorPickerButton = $MarginContainer/TabContainer/General/VBoxContainer/DefaultCanvasColor/DefaultCanvasColor
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

# -------------------------------------------------------------------------------------------------
func _ready():
	_tab_general.name = tr("SETTINGS_GENERAL")
	_tab_appearance.name = tr("SETTINGS_APPEARANCE")
	_tab_rendering.name = tr("SETTINGS_RENDERING")
	_set_values()

# -------------------------------------------------------------------------------------------------
func _set_values() -> void:
	var brush_size = Settings.get_value(Settings.GENERAL_DEFAULT_BRUSH_SIZE, Config.DEFAULT_BRUSH_SIZE)
	var brush_color = Settings.get_value(Settings.GENERAL_DEFAULT_BRUSH_COLOR, Config.DEFAULT_BRUSH_COLOR)
	var canvas_color = Settings.get_value(Settings.GENERAL_DEFAULT_CANVAS_COLOR, Config.DEFAULT_CANVAS_COLOR)
	var project_dir = Settings.get_value(Settings.GENERAL_DEFAULT_PROJECT_DIR, "")
	var theme = Settings.get_value(Settings.APPEARANCE_THEME, Types.UITheme.DARK)
	var aa_mode = Settings.get_value(Settings.RENDERING_AA_MODE, Config.DEFAULT_AA_MODE)
	var locale = Settings.get_value(Settings.GENERAL_LANGUAGE, "en")
	var foreground_fps = Settings.get_value(Settings.RENDERING_FOREGROUND_FPS, Config.DEFAULT_FOREGROUND_FPS)
	var background_fps = Settings.get_value(Settings.RENDERING_BACKGROUND_FPS, Config.DEFAULT_BACKGROUND_FPS)
	var pressure_sensitivity = Settings.get_value(Settings.GENERAL_PRESSURE_SENSITIVITY, Config.DEFAULT_PRESSURE_SENSITIVITY)
	
	match theme:
		Types.UITheme.DARK: _theme.selected = THEME_DARK_INDEX
		Types.UITheme.LIGHT: _theme.selected = THEME_LIGHT_INDEX
	match aa_mode:
		Types.AAMode.NONE: _aa_mode.selected = AA_NONE_INDEX
		Types.AAMode.OPENGL_HINT: _aa_mode.selected = AA_OPENGL_HINT_INDEX
		Types.AAMode.TEXTURE_FILL: _aa_mode.selected = AA_TEXTURE_FILL_INDEX
	
	_set_languages(locale)
	_set_rounding()
	
	_pressure_sensitivity.value = pressure_sensitivity
	_brush_size.value = brush_size
	_brush_color.color = brush_color
	_canvas_color.color = canvas_color
	_project_dir.text = project_dir
	_foreground_fps.value = foreground_fps
	_background_fps.value = background_fps

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

# -------------------------------------------------------------------------------------------------
func _on_DefaultBrushSize_value_changed(value: int) -> void:
	Settings.set_value(Settings.GENERAL_DEFAULT_BRUSH_SIZE, int(value))

# -------------------------------------------------------------------------------------------------
func _on_DefaultBrushColor_color_changed(color: Color) -> void:
	Settings.set_value(Settings.GENERAL_DEFAULT_BRUSH_COLOR, color)

# -------------------------------------------------------------------------------------------------
func _on_DefaultCanvasColor_color_changed(color: Color) -> void:
	Settings.set_value(Settings.GENERAL_DEFAULT_CANVAS_COLOR, color)

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
	_general_restart_label.show()
