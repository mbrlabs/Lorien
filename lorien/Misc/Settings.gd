extends Node

# -------------------------------------------------------------------------------------------------
const SETTINGS_SECTION 					:= "settings"
const KEYBINDINGS_SECTION				:= "keybindings"

# -------------------------------------------------------------------------------------------------
const GENERAL_PRESSURE_SENSITIVITY 		:= "general_pressure_sensitvity"
const GENERAL_CONSTANT_PRESSURE			:= "general_constant_pressure"
const GENERAL_STABILIZER_STRENGTH		:= "general_stabilizer_strength"
const GENERAL_DEFAULT_BRUSH_SIZE 		:= "general_default_brush_size"
const GENERAL_DEFAULT_PROJECT_DIR		:= "general_default_project_dir"
const GENERAL_LANGUAGE					:= "general_language"
const GENERAL_TOOL_PRESSURE				:= "general_tool_pressure"
const GENERAL_TABLET_DRIVER 			:= "general_tablet_driver"
const COLOR_PALETTE_UUID_LAST_USED		:= "general_color_palette_uuid_last_used" # TODO: move this to state.cfg

# -------------------------------------------------------------------------------------------------
const APPEARANCE_THEME 					:= "appearance_theme"
const APPEARANCE_UI_SCALE_MODE  		:= "appearance_ui_scale_mode"
const APPEARANCE_UI_SCALE				:= "appearance_ui_scale"
const APPEARANCE_GRID_PATTERN			:= "appearance_grid_pattern"
const APPEARANCE_GRID_SIZE				:= "appearance_grid_size"
const APPEARANCE_CANVAS_COLOR 			:= "appearance_canvas_color"

# -------------------------------------------------------------------------------------------------
const RENDERING_FOREGROUND_FPS			:= "rendering_foreground_fps"
const RENDERING_BACKGROUND_FPS			:= "rendering_background_fps"
const RENDERING_BRUSH_ROUNDING			:= "rendering_brush_rounding"

# -------------------------------------------------------------------------------------------------
var _config_file := ConfigFile.new()
var _i18n := I18nParser.new()
var locales: PackedStringArray
var language_names: PackedStringArray

#--------------------------------------------------------------------------------------------------
signal changed_theme(path: String)

# -------------------------------------------------------------------------------------------------
func _ready() -> void:
	_config_file = ConfigFile.new()
	_load_settings()
	reload_locales()

# -------------------------------------------------------------------------------------------------
func reload_locales() -> void:
	var parse_result := _i18n.reload_locales()
	TranslationServer.set_locale(get_value(GENERAL_LANGUAGE, "en"))
	locales = parse_result.locales
	language_names = parse_result.language_names

# -------------------------------------------------------------------------------------------------
func _load_settings() -> int:
	var err := _config_file.load(Config.CONFIG_PATH)
	if err == ERR_FILE_NOT_FOUND:
		pass
	elif err != OK:
		printerr("Failed to load settings file")
	
	return err

# -------------------------------------------------------------------------------------------------
func _save_settings() -> int:
	var err := _config_file.save(Config.CONFIG_PATH)
	if err == ERR_FILE_NOT_FOUND:
		pass
	elif err != OK:
		printerr("Failed to save settings file")
	
	return err

# -------------------------------------------------------------------------------------------------
func get_value(key: String, default_value: Variant = null) -> Variant:
	return _config_file.get_value(SETTINGS_SECTION, key, default_value)

# -------------------------------------------------------------------------------------------------
func set_value(key: String, value: Variant = null) -> void:
	_config_file.set_value(SETTINGS_SECTION, key, value)
	_save_settings()
	
# -------------------------------------------------------------------------------------------------
func get_keybinding(action_name: String, default_value: Variant = null) -> InputEventKey:
	return _config_file.get_value(KEYBINDINGS_SECTION, action_name, default_value)

# -------------------------------------------------------------------------------------------------
func set_keybinding(action_name: String, event: InputEventKey) -> void:
	_config_file.set_value(KEYBINDINGS_SECTION, action_name, event)
	_save_settings()
