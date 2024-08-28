extends Node

# -------------------------------------------------------------------------------------------------
const GENERAL_SECTION 					:= "general"
const GENERAL_PRESSURE_SENSITIVITY 		:= "pressure_sensitvity"
const GENERAL_CONSTANT_PRESSURE			:= "constant_pressure"
const GENERAL_DEFAULT_BRUSH_SIZE 		:= "default_brush_size"
const GENERAL_DEFAULT_PROJECT_DIR		:= "default_project_dir"
const GENERAL_LANGUAGE					:= "language"
const GENERAL_TOOL_PRESSURE				:= "tool_pressure"

# -------------------------------------------------------------------------------------------------
const APPEARANCE_SECTION 				:= "appearance"
const APPEARANCE_THEME 					:= "theme"
const APPEARANCE_UI_SCALE_MODE  		:= "ui_scale_mode"
const APPEARANCE_UI_SCALE				:= "ui_scale"
const APPEARANCE_GRID_PATTERN			:= "grid_pattern"
const APPEARANCE_GRID_SIZE				:= "grid_size"
const APPEARANCE_CANVAS_COLOR 			:= "canvas_color"

# -------------------------------------------------------------------------------------------------
const RENDERING_SECTION 				:= "rendering"
const RENDERING_FOREGROUND_FPS			:= "foreground_fps"
const RENDERING_BACKGROUND_FPS			:= "background_fps"
const RENDERING_BRUSH_ROUNDING			:= "brush_rounding"

# -------------------------------------------------------------------------------------------------
const KEYBINDINGS_SECTION				:= "keybindings"

# TODO: move this to state.cfg
const COLOR_PALETTE_UUID_LAST_USED		:= "color_palette_uuid_last_used"

# -------------------------------------------------------------------------------------------------
var _config_file := ConfigFile.new()
var _i18n := I18nParser.new()
var locales: PackedStringArray
var language_names: PackedStringArray

# -------------------------------------------------------------------------------------------------
func _ready():
	_config_file = ConfigFile.new()
	_load_settings()
	reload_locales()

# -------------------------------------------------------------------------------------------------
func reload_locales():
	var parse_result := _i18n.reload_locales()
	TranslationServer.set_locale(get_general_value(GENERAL_LANGUAGE, "en"))
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
func get_general_value(key: String, default_value = null):
	return _config_file.get_value(GENERAL_SECTION, key, default_value)

# -------------------------------------------------------------------------------------------------
func set_general_value(key: String, value = null):
	_config_file.set_value(GENERAL_SECTION, key, value)
	_save_settings()
	
# -------------------------------------------------------------------------------------------------
func get_appearance_value(key: String, default_value = null):
	return _config_file.get_value(APPEARANCE_SECTION, key, default_value)

# -------------------------------------------------------------------------------------------------
func set_appearance_value(key: String, value = null):
	_config_file.set_value(APPEARANCE_SECTION, key, value)
	_save_settings()
	
# -------------------------------------------------------------------------------------------------
func get_rendering_value(key: String, default_value = null):
	return _config_file.get_value(RENDERING_SECTION, key, default_value)

# -------------------------------------------------------------------------------------------------
func set_rendering_value(key: String, value = null):
	_config_file.set_value(RENDERING_SECTION, key, value)
	_save_settings()
	
# -------------------------------------------------------------------------------------------------
func get_keybind_value(action_name: String, default_value = null) -> InputEventKey:
	return _config_file.get_value(KEYBINDINGS_SECTION, action_name, default_value)

# -------------------------------------------------------------------------------------------------
func set_keybind_value(action_name: String, event: InputEventKey) -> void:
	_config_file.set_value(KEYBINDINGS_SECTION, action_name, event)
	_save_settings()
