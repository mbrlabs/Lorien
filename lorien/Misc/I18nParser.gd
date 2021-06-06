class_name I18nParser

# -------------------------------------------------------------------------------------------------
const I18N_FOLDER := "res://Assets/I18n/"

# -------------------------------------------------------------------------------------------------

class ParseResult:
	var locales := PoolStringArray()
	var language_names := PoolStringArray()

# -------------------------------------------------------------------------------------------------
func load_files() -> ParseResult:
	var result = ParseResult.new()
	for f in _get_i18n_files():
		var file := File.new()
		print("Loading i18n file: %s" % f)
		if file.open(f, File.READ) == OK:
			var translation := Translation.new()
			translation.locale = f.get_file().get_basename()
			var name := file.get_line().strip_edges()
			if !name.begins_with("LANGUAGE_NAME"):
				printerr("The file must start with 'LANGUAGE_NAME' key.")
				continue
			name = name.trim_prefix("LANGUAGE_NAME").strip_edges()
			while !file.eof_reached():
				var line := file.get_line().strip_edges()
				if line.length() == 0 || line.begins_with("#"):
					continue
				
				var split_index := line.find(" ")
				if split_index >= 0:
					var key: String = line.substr(0, split_index)
					var value: String = line.substr(split_index, line.length() - 1)
					value = value.strip_edges()
					translation.add_message(key, value)
				else:
					printerr("Key not found (make sure to use spaces; not tabs): %s" % line)
			TranslationServer.add_translation(translation)
			result.locales.append(translation.locale)
			result.language_names.append(name)
	return result

# -------------------------------------------------------------------------------------------------
func _get_i18n_files() -> Array:
	var files := []
	var dir = Directory.new()
	if dir.open(I18N_FOLDER) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if !dir.current_is_dir():
				files.append(I18N_FOLDER.plus_file(file_name))
			file_name = dir.get_next()
	else:
		printerr("Failed to list i18n files")
	
	return files
