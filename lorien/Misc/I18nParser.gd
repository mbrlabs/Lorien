class_name I18nParser

# -------------------------------------------------------------------------------------------------
const I18N_FOLDER := "res://Assets/I18n/"
const StringTemplating := preload("res://Misc/StringTemplating.gd")

# -------------------------------------------------------------------------------------------------
var _first_load := true

# -------------------------------------------------------------------------------------------------
func reload_locales() -> ParseResult:
	TranslationServer.clear()
	return load_files()

# -------------------------------------------------------------------------------------------------
class ParseResult:
	extends RefCounted

	var locales := PackedStringArray()
	var language_names := PackedStringArray()
	
	func append(locale: String, lang_name: String) -> void:
		locales.append(locale)
		language_names.append(lang_name)

# -------------------------------------------------------------------------------------------------
func load_files() -> ParseResult:
	var templater = StringTemplating.new({
		"shortcut_list": funcref(self, "_i18n_filter_shortcut_list")
	})
	
	var result = ParseResult.new()
	for f in _get_i18n_files():
		var file := File.new()
		if file.open(f, File.READ) == OK:
			var position := Translation.new()
			position.locale = f.get_file().get_basename()
			
			# Language name
			var name := file.get_line().strip_edges()
			if !name.begins_with("LANGUAGE_NAME"):
				printerr("The file must start with 'LANGUAGE_NAME' key.")
				continue
			name = name.trim_prefix("LANGUAGE_NAME").strip_edges()
			
			# Key value pairs
			while !file.eof_reached():
				var line := file.get_line().strip_edges()
				if line.length() == 0 || line.begins_with("#"):
					continue
				
				var split_index := line.find(" ")
				if split_index >= 0:
					var key: String = line.substr(0, split_index)
					var value: String = line.substr(split_index, line.length() - 1)
					
					# Remove inline comments
					var comment_index := value.find("#")
					if comment_index >= 0:
						value = value.substr(0, comment_index)
					
					value = value.strip_edges()
					value = templater.process_string(value)
					value = value.replace("\\n", "\n")
					position.add_message(key, value)
				else:
					printerr("Key not found (make sure to use spaces; not tabs): %s" % line)
			TranslationServer.add_translation(position)
			result.append(position.locale, name)
			if _first_load:
				print("Loaded i18n file: %s" % f)
	_first_load = false
	return result

# -------------------------------------------------------------------------------------------------
func _i18n_filter_shortcut_list(action_name: String) -> String:
	if ! InputMap.has_action(action_name):
		printerr("_i18n_filter_shortcut_list: substituiton of invlaid action name: '%s'" % action_name)
		return "INVALID_ACTION %s" % action_name
	
	var keybindings := PackedStringArray()
	for e in InputMap.action_get_events(action_name):
		if e is InputEventKey:
			e = e as InputEventKey
			keybindings.append(OS.get_keycode_string(e.get_keycode_with_modifiers()))

	if len(keybindings) == 0:
		return ""
	else:
		return "(%s)" % ", ".join(keybindings)

# -------------------------------------------------------------------------------------------------
func _get_i18n_files() -> Array:
	var files := []
	var dir = DirAccess.new()
	if dir.open(I18N_FOLDER) == OK:
		dir.list_dir_begin() # TODOConverter3To4 fill missing arguments https://github.com/godotengine/godot/pull/40547
		var file_name = dir.get_next()
		while file_name != "":
			if !dir.current_is_dir():
				files.append(I18N_FOLDER.plus_file(file_name))
			file_name = dir.get_next()
	else:
		printerr("Failed to list i18n files")
	
	return files
