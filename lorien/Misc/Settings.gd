extends Node

const DEFAULT_SECTION 					:= "settings"
const GENERAL_DEFAULT_CANVAS_COLOR 		:= "general_default_canvas_color"
const GENERAL_DEFAULT_BRUSH_SIZE 		:= "general_default_brush_size"
const GENERAL_DEFAULT_BRUSH_COLOR 		:= "general_default_brush_color"
const GENERAL_DEFAULT_PROJECT_DIR		:= "general_default_project_dir"
const GENERAL_LANGUAGE					:= "general_language"
const APPEARANCE_THEME 					:= "appearance_theme"
const RENDERING_AA_MODE					:= "rendering_aa_mode"

# -------------------------------------------------------------------------------------------------
var _config_file := ConfigFile.new()
var locales: PoolStringArray
var language_names: PoolStringArray

# -------------------------------------------------------------------------------------------------
func _ready():
	_config_file = ConfigFile.new()
	_load_settings()

	var i18n := I18nParser.new()
	i18n.load_files()
	TranslationServer.set_locale(get_value(GENERAL_LANGUAGE, "en"))

# -------------------------------------------------------------------------------------------------
func _load_settings() -> int:
	var err = _config_file.load(Config.CONFIG_PATH)
	if err == ERR_FILE_NOT_FOUND:
		pass
	elif err != OK:
		printerr("Failed to load settings file")
	
	return err

# -------------------------------------------------------------------------------------------------
func _save_settings() -> int:
	var err = _config_file.save(Config.CONFIG_PATH)
	if err == ERR_FILE_NOT_FOUND:
		pass
	elif err != OK:
		printerr("Failed to load settings file")
	
	return err

# -------------------------------------------------------------------------------------------------
func get_value(key: String, default_value = null):
	return _config_file.get_value(DEFAULT_SECTION, key, default_value)

# -------------------------------------------------------------------------------------------------
func set_value(key: String, value = null):
	_config_file.set_value(DEFAULT_SECTION, key, value)
	_save_settings()
	

