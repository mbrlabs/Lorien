extends Node

# -------------------------------------------------------------------------------------------------
const DEFAULT_SECTION 					:= "settings"
const SHORTCUTS_SECTION 				:= "shortcuts"
const GENERAL_PRESSURE_SENSITIVITY 		:= "general_pressure_sensitvity"
const GENERAL_DEFAULT_CANVAS_COLOR 		:= "general_default_canvas_color"
const GENERAL_DEFAULT_BRUSH_SIZE 		:= "general_default_brush_size"
const GENERAL_DEFAULT_PROJECT_DIR		:= "general_default_project_dir"
const GENERAL_LANGUAGE					:= "general_language"
const APPEARANCE_THEME 					:= "appearance_theme"
const APPEARANCE_UI_SCALE_MODE  		:= "appearance_ui_scale_mode"
const APPEARANCE_UI_SCALE				:= "appearance_ui_scale"
const APPEARANCE_GRID_PATTERN			:= "appearance_grid_pattern"
const APPEARANCE_GRID_SIZE				:= "appearance_grid_size"
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
	_load_shortcuts()
	_setup_default_shortcuts()
	reload_locales()

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
func _setup_default_shortcuts() -> void:
	var new_actions := []
	for action_name in Utils.bindable_actions():
		if ! _config_file.has_section_key(SHORTCUTS_SECTION, action_name):
			new_actions.append(action_name)
	
	if len(new_actions) > 0:
		var old_actions := []
		for action_name in Utils.bindable_actions():
			if ! action_name in new_actions:
				old_actions.append(action_name)

		for new_action in new_actions:
			var event_list := InputMap.get_action_list(new_action)
			for event in event_list:
				for old_action in old_actions:
					if InputMap.action_has_event(old_action, event):
						event_list.erase(event)
						break
			_config_file.set_value(SHORTCUTS_SECTION, new_action, event_list)
		_save_settings()
		_load_shortcuts()

# -------------------------------------------------------------------------------------------------
func _load_shortcuts() -> void:	
	for action_name in Utils.bindable_actions():
		if !_config_file.has_section_key(SHORTCUTS_SECTION, action_name):
			continue

		var shortcuts = _config_file.get_value(SHORTCUTS_SECTION, action_name)
		InputMap.action_erase_events(action_name)
		for shortcut in shortcuts:
			InputMap.action_add_event(action_name, shortcut)

# -------------------------------------------------------------------------------------------------
func store_shortcuts() -> void:	
	for action_name in Utils.bindable_actions():
		_config_file.set_value(SHORTCUTS_SECTION, action_name, InputMap.get_action_list(action_name))
	_save_settings()
