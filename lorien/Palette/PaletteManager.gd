extends Node

# -------------------------------------------------------------------------------------------------
const DEAFULT_PALETTE := preload("res://Palette/default_palette.tres")
const UUID_LENGTH := 32
const UUID_DEFAULT_PALETTE := "defaultpalette"
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
	
	# Activate last used palette
	var active_palette_uuid: String = Settings.get_value(Settings.COLOR_PALETTE_UUID_LAST_USED, UUID_DEFAULT_PALETTE)
	var index := _find_palette_index_by_uuid(active_palette_uuid)
	if index < 0:
		index = _find_palette_index_by_uuid(UUID_DEFAULT_PALETTE)
	set_active_palette_by_index(index)

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
	palette.colors = PackedColorArray([Color.WHITE, Color.BLACK])
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
func remove_palette(palette: Palette) -> bool:
	if !palette.builtin:
		var index := _find_palette_index_by_uuid(palette.uuid)
		if index >= 0:
			if index == _active_palette_index:
				_active_palette_index = 0
			palettes.remove_at(index)
			return true
	return false
		
# -------------------------------------------------------------------------------------------------
func set_active_palette_by_index(index: int) -> void:
	if index < palettes.size():
		Settings.set_value(Settings.COLOR_PALETTE_UUID_LAST_USED, palettes[index].uuid)
		_active_palette_index = index
	else:
		printerr("Invalid palette index: %d" % index)
		
# -------------------------------------------------------------------------------------------------
func set_active_palette(palette: Palette) -> void:
	var index := _find_palette_index_by_uuid(palette.uuid)
	if index >= 0:
		Settings.set_value(Settings.COLOR_PALETTE_UUID_LAST_USED, palette.uuid)
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
	palettes.sort_custom(Callable(PaletteSorter, "sort_descending"))

# -------------------------------------------------------------------------------------------------
func _find_palette_index_by_uuid(uuid: String) -> int:
	var index := 0
	for p in palettes:
		if p.uuid == uuid:
			return index
		index += 1
	return -1

# -------------------------------------------------------------------------------------------------
func _load_palettes() -> bool:
	# Built-in palette
	palettes.append(DEAFULT_PALETTE)
	
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
			
	return true
