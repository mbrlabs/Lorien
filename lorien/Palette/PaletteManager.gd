extends Node

# -------------------------------------------------------------------------------------------------
const BUILTIN_PALETTES := [
	preload("res://Palette/default_palette.tres"), 
]

const UUID_LENGTH := 32
const SECTION := "palettes"
const KEY_NAME := "name"
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
	_load_palettes()
	_sort()

# -------------------------------------------------------------------------------------------------
func save() -> bool:
	var file := ConfigFile.new()
	for p in palettes:
		if !p.builtin:
			file.set_value(p.uuid, KEY_NAME, p.name)
			file.set_value(p.uuid, KEY_COLORS, p.colors)
	return file.save(Config.PALETTES_PATH) == OK
	
# -------------------------------------------------------------------------------------------------
func create_custom_palette(palette_name: String) -> Palette:
	var palette := Palette.new()
	palette.name = palette_name
	palette.builtin = false
	palette.uuid = Utils.generate_uuid(UUID_LENGTH)
	palette.colors = PoolColorArray([Color.white, Color.black])
	palettes.append(palette)
	_sort()
	
	return palette

# -------------------------------------------------------------------------------------------------
func duplicate_palette(palette: Palette, new_palette_name: String) -> Palette:
	var new_palette := Palette.new()
	new_palette.name = new_palette_name
	new_palette.builtin = false
	new_palette.colors = palette.colors # TODO: make sure this is passed by-value
	palettes.append(new_palette)
	_sort()
	
	return new_palette
	
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
func _sort() -> void:
	palettes.sort_custom(PaletteSorter, "sort_descending")

# -------------------------------------------------------------------------------------------------
func _load_palettes() -> bool:
	# Built-in palettes
	palettes.append_array(BUILTIN_PALETTES)
	
	# Load file
	var file := ConfigFile.new()
	if file.load(Config.PALETTES_PATH) != OK:
		return false
	
	# Create palettes
	for uuid in file.get_sections():
		var palette := Palette.new()
		palette.builtin = false
		palette.uuid = uuid
		palette.name = file.get_value(uuid, KEY_NAME)
		palette.colors = file.get_value(uuid, KEY_COLORS)
		if palette.colors != null && palette.name != null:
			palettes.append(palette)
		
	print("Loaded palette file: %s" % Config.PALETTES_PATH)
	return true
