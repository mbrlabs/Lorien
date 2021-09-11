extends Node

# -------------------------------------------------------------------------------------------------
const BUILTIN_PALETTES := [
	preload("res://Palette/default_palette.tres"), 
	preload("res://Palette/minimal_palette.tres")
]
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
var _active_palette_index: int

# -------------------------------------------------------------------------------------------------
func _ready() -> void:
	_ensure_builtin_palettes()
	_load_palettes()
	_sort()
	assert(palettes.size() > 0)
	_select_active_palette()

# -------------------------------------------------------------------------------------------------
func save() -> void:
	Settings.set_value(Settings.PALETTE_ACTIVE, palettes[_active_palette_index].name)
	for p in palettes:
		if p.dirty:
			_save_palette(p)
	
# -------------------------------------------------------------------------------------------------
func create_custom_palette(palette_name: String) -> Palette:
	if has_palette_name(palette_name):
		printerr("Palette names must be unique")
		return null
			
	var palette := Palette.new()
	palette.name = palette_name
	palette.builtin = false
	palette.dirty = true
	palette.colors = PoolColorArray([Color.white, Color.black])
	palettes.append(palette)
	_sort()
	
	return palette

# -------------------------------------------------------------------------------------------------
func set_active_palette_index(index: int) -> void:
	_active_palette_index = index

# -------------------------------------------------------------------------------------------------
func set_active_palette(palette: Palette) -> void:
	var index := 0
	var found := false
	for p in palettes:
		if p.name == palette.name:
			found = true
			break
		index += 1
	
	if found:
		_active_palette_index = index
	else:
		printerr("Cold not find palette: %s" % palette.name)

# -------------------------------------------------------------------------------------------------
func get_active_palette() -> Palette:
	return palettes[_active_palette_index]

# -------------------------------------------------------------------------------------------------
func get_active_palette_index() -> int:
	return _active_palette_index

# -------------------------------------------------------------------------------------------------
func has_palette_name(name: String) -> bool:
	for p in palettes:
		if p.name == name:
			return true
	return false

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
func _select_active_palette() -> void:
	var active_name = Settings.get_value(Settings.PALETTE_ACTIVE, "Default Palette")
	_active_palette_index = 0
	var index := 0
	for p in palettes:
		if p.name == active_name:
			_active_palette_index = index
			break
		index += 1
	print("Active palette: " + palettes[_active_palette_index].name)
	
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
