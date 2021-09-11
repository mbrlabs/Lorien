extends Node

# -------------------------------------------------------------------------------------------------
const BUILTIN_PALETTES := [preload("res://Palettes/default_palette.tres")]
const FILE_EXTENSION := "txt"
const SECTION := "palette"
const KEY_NAME := "name"
const KEY_BUILTIN := "builtin"
const KEY_COLORS := "colors"

# -------------------------------------------------------------------------------------------------
class PaletteSorter:
	static func sort_descending(a: Palette, b: Palette) -> bool:
		return a.name < b.name

# -------------------------------------------------------------------------------------------------
var palettes: Array # Array<Palette>

# -------------------------------------------------------------------------------------------------
func _ready() -> void:
	_ensure_builtin_palettes()
	_load_palettes()
	_sort()

# -------------------------------------------------------------------------------------------------
func save() -> void:
	for p in palettes:
		if p.dirty:
			_save_palette(p)

# -------------------------------------------------------------------------------------------------
func create_palette(palette_name: String, builtin: bool) -> Palette:
	for p in palettes:
		if p.name == name:
			printerr("Palette names must be unique")
			return null
			
	var palette := Palette.new()
	palette.name = palette_name
	palette.builtin = builtin
	palette.dirty = true
	palettes.append(palette)
	_sort()
	
	return palette

# -------------------------------------------------------------------------------------------------
func _sort() -> void:
	palettes.sort_custom(PaletteSorter, "sort_descending")

# -------------------------------------------------------------------------------------------------
func _save_palette(palette: Palette) -> bool:
	if !_ensure_palette_folder():
		return false
	
	var file := ConfigFile.new()
	file.set_value(SECTION, KEY_NAME, palette.name)
	file.set_value(SECTION, KEY_BUILTIN, palette.builtin)
	file.set_value(SECTION, KEY_COLORS, palette.colors)
	
	var path := _get_palette_path(palette)
	if file.save(path) != OK:
		printerr("Failed to save palette file: %s" % path)
		return false
	
	print("Saved palette file: %s" % path)
	return true

# -------------------------------------------------------------------------------------------------
func _load_palettes() -> void:
	_ensure_palette_folder()
	
	var dir := Directory.new()
	if dir.open(Config.PALETTE_FOLDER) != OK:
		printerr("Failed to open palette folder")
		return
	
	if dir.list_dir_begin(true, true) != OK:
		printerr("Failed to enumerate palette files")
		return
	
	var filename := dir.get_next()
	while !filename.empty():
		var palette := _load_palette(Config.PALETTE_FOLDER + filename)
		if palette != null:
			palettes.append(palette)
		filename = dir.get_next()

# -------------------------------------------------------------------------------------------------
func _load_palette(path: String) -> Palette:
	var file := ConfigFile.new()
	if file.load(path) != OK:
		printerr("Failed to load palette file: %s" % path)
		return null
	
	if !file.has_section_key(SECTION, KEY_NAME) || !file.has_section_key(SECTION, KEY_BUILTIN) || !file.has_section_key(SECTION, KEY_COLORS):
		printerr("Invalid palette file: %s" % path)
		return null
		
	var palette_name = file.get_value(SECTION, KEY_NAME)
	if !(palette_name is String):
		printerr("Invalid palette file: %s" % path)
		return null
	
	var palette_builtin = file.get_value(SECTION, KEY_BUILTIN)
	if !(palette_builtin is bool):
		printerr("Invalid palette file: %s" % path)
		return null
	
	var palette_colors = file.get_value(SECTION, KEY_COLORS)
	if !(palette_colors is PoolColorArray):
		printerr("Invalid palette file: %s" % palette_colors)
		return null
		
	var palette := Palette.new()
	palette.name = palette_name
	palette.builtin = palette_builtin
	palette.colors = palette_colors
	print("Loaded palette file: %s" % path)
	
	return palette

# -------------------------------------------------------------------------------------------------
func _ensure_palette_folder() -> bool:
	var dir := Directory.new()
	if !dir.dir_exists(Config.PALETTE_FOLDER):
		if dir.make_dir(Config.PALETTE_FOLDER) != OK:
			printerr("Failed to create palette folder")
			return false
	return true

# -------------------------------------------------------------------------------------------------
func _ensure_builtin_palettes() -> void:
	for p in BUILTIN_PALETTES:
		var path := _get_palette_path(p)
		var file := File.new()
		if !file.file_exists(path):
			_save_palette(p)

# -------------------------------------------------------------------------------------------------
func _get_palette_path(palette: Palette) -> String:
	var path := Config.PALETTE_FOLDER
	var filename := palette.name.to_lower().replace(" ", "_")
	filename += "." + FILE_EXTENSION
	return path + filename
