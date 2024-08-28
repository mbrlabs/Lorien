extends Node

# -------------------------------------------------------------------------------------------------
const DEFAULT_SECTION 					:= "states"
const WINDOW_SIZE 						:= "window_size"
const WINDOW_MAXIMIZED 					:= "window_maximized"
const OPEN_PROJECTS 					:= "open_projects"
const ACTIVE_PROJECT 					:= "active_project"

# -------------------------------------------------------------------------------------------------
var _config_file := ConfigFile.new()

# -------------------------------------------------------------------------------------------------
func _ready():
	_config_file = ConfigFile.new()
	_load_state()

# -------------------------------------------------------------------------------------------------
func _load_state() -> int:
	var err := _config_file.load(Config.STATE_PATH)
	if err == ERR_FILE_NOT_FOUND:
		pass
	elif err != OK:
		printerr("Failed to load state file")
	
	return err

# -------------------------------------------------------------------------------------------------
func _save_state() -> int:
	var err := _config_file.save(Config.STATE_PATH)
	if err == ERR_FILE_NOT_FOUND:
		pass
	elif err != OK:
		printerr("Failed to load state file")
	
	return err

# -------------------------------------------------------------------------------------------------
func get_value(key: String, default_value = null):
	return _config_file.get_value(DEFAULT_SECTION, key, default_value)

# -------------------------------------------------------------------------------------------------
func set_value(key: String, value = null):
	_config_file.set_value(DEFAULT_SECTION, key, value)
	_save_state()
