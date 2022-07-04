extends Node

# -------------------------------------------------------------------------------------------------
const DEFAULT_SECTION 					:= "settings"
const GENERAL_PRESSURE_SENSITIVITY 		:= "general_pressure_sensitvity"
const GENERAL_DEFAULT_CANVAS_COLOR 		:= "general_default_canvas_color"
const GENERAL_DEFAULT_BRUSH_SIZE 		:= "general_default_brush_size"
const GENERAL_DEFAULT_PROJECT_DIR		:= "general_default_project_dir"
const GENERAL_LANGUAGE					:= "general_language"
const APPEARANCE_THEME 					:= "appearance_theme"
const APPEARANCE_UI_SCALE_MODE  		:= "appearance_ui_scale_mode"
const APPEARANCE_UI_SCALE				:= "appearance_ui_scale"
const RENDERING_AA_MODE					:= "rendering_aa_mode"
const RENDERING_FOREGROUND_FPS			:= "rendering_foreground_fps"
const RENDERING_BACKGROUND_FPS			:= "rendering_background_fps"
const RENDERING_BRUSH_ROUNDING			:= "rendering_brush_rounding"
const COLOR_PALETTE_UUID_LAST_USED		:= "color_palette_uuid_last_used"

# -------------------------------------------------------------------------------------------------
var _config_file := ConfigFile.new()
var _i18n := I18nParser.new()
var locales: PoolStringArray
var language_names: PoolStringArray

# -------------------------------------------------------------------------------------------------
func _ready():
	_config_file = ConfigFile.new()
	_load_settings()
	reload_locales()
	_setup_shortcuts()
	_load_shortcuts()

# -------------------------------------------------------------------------------------------------
func reload_locales():
	var parse_result := _i18n.reload_locales()
	TranslationServer.set_locale(get_value(GENERAL_LANGUAGE, "en"))
	locales = parse_result.locales
	language_names = parse_result.language_names

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
		printerr("Failed to save settings file")
	
	return err

# -------------------------------------------------------------------------------------------------
func get_value(key: String, default_value = null):
	return _config_file.get_value(DEFAULT_SECTION, key, default_value)

# -------------------------------------------------------------------------------------------------
func set_value(key: String, value = null):
	_config_file.set_value(DEFAULT_SECTION, key, value)
	_save_settings()
	
# -------------------------------------------------------------------------------------------------
func _setup_shortcuts(override = false) -> void:
	for action_name in InputMap.get_actions():
		if !override && _config_file.has_section_key("shortcuts", action_name):
			continue

		set_default_shortcut(action_name)
	_save_settings()

# -------------------------------------------------------------------------------------------------
func set_default_shortcut(action_name: String, save = false) -> void:
	var shortcuts = []
	for event in InputMap.get_action_list(action_name):
		shortcuts.append(event)

	_config_file.set_value("shortcuts", action_name, shortcuts)
	if save:
		_save_settings()

# -------------------------------------------------------------------------------------------------
func _load_shortcuts() -> void:	
	for action_name in InputMap.get_actions():
		if !_config_file.has_section_key("shortcuts", action_name):
			continue
		var shortcuts = _config_file.get_value("shortcuts", action_name)
		InputMap.action_erase_events(action_name)

		for shortcut in shortcuts:
			InputMap.action_add_event(action_name, shortcut)
