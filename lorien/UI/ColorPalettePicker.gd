class_name ColorPalettePicker
extends PanelContainer

# -------------------------------------------------------------------------------------------------
const PALETTE_BUTTON = preload("res://UI/Components/PaletteButton.tscn")

# -------------------------------------------------------------------------------------------------
signal color_changed(color: Color)
signal closed

# -------------------------------------------------------------------------------------------------
@export var add_new_palette_dialog_path: NodePath
@export var edit_palette_dialog: NodePath
@export var delete_palette_dialog: NodePath
@export var toolbar_path: NodePath
@export var file_dialog_path: NodePath

@onready var _toolbar: Toolbar = get_node(toolbar_path)
@onready var _palette_selection_button: OptionButton = $MarginContainer/VBoxContainer/Buttons/PaletteSelectionButton
@onready var _color_grid: GridContainer = $MarginContainer/VBoxContainer/ColorGrid
@onready var _edit_button: TextureButton = $MarginContainer/VBoxContainer/Buttons/EditColorButton
@onready var _new_button: TextureButton = $MarginContainer/VBoxContainer/Buttons/AddPaletteButton
@onready var _duplicate_button: TextureButton = $MarginContainer/VBoxContainer/Buttons/DuplicatePaletteButton
@onready var _delete_button: TextureButton = $MarginContainer/VBoxContainer/Buttons/DeletePaletteButton
@onready var _import_button: TextureButton = $MarginContainer/VBoxContainer/Buttons/ImportPaletteButton

var _active_palette_button: PaletteButton
var _active_color_index := -1

# -------------------------------------------------------------------------------------------------
func _ready() -> void:
	update_palettes()
	
	_palette_selection_button.item_selected.connect(_on_PaletteSelectionButton_item_selected)
	_new_button.pressed.connect(_on_AddPaletteButton_pressed)
	_edit_button.pressed.connect(_on_EditColorButton_pressed)
	_duplicate_button.pressed.connect(_on_DuplicatePaletteButton_pressed)
	_delete_button.pressed.connect(_on_DeletePaletteButton_pressed)
	_import_button.pressed.connect(_on_ImportPaletteButton_pressed)
	
# -------------------------------------------------------------------------------------------------
func _input(event: InputEvent) -> void:
	if !visible:
		return
		
	if event is InputEventMouseButton && event.pressed:
		var should_hide := !Utils.is_mouse_in_control(self)
		should_hide = should_hide && !Utils.is_mouse_in_control(_toolbar.get_brush_color_button())
		should_hide = should_hide && !get_parent().is_dialog_open()
		should_hide = should_hide && !_palette_selection_button.get_popup().visible
		should_hide = should_hide && !AlertDialog.visible
		if should_hide:
			_close()
	elif event is InputEventKey && event.pressed && event.keycode == KEY_ESCAPE:
		_close()

# -------------------------------------------------------------------------------------------------
func get_active_color() -> Color:
	if _active_palette_button != null:
		return _active_palette_button.color
	return Color.WHITE

# -------------------------------------------------------------------------------------------------
func get_active_color_index() -> int:
	return _active_color_index

# -------------------------------------------------------------------------------------------------
func update_palettes(color_index: int = 0) -> void:
	# Add palettes to the dropdown
	_palette_selection_button.clear()
	for palette in PaletteManager.palettes:
		_palette_selection_button.add_item(palette.name)
	
	# Load the active palette
	var active_palette := PaletteManager.get_active_palette()
	_palette_selection_button.selected = PaletteManager.get_active_palette_index()
	_create_buttons(active_palette)
	_activate_palette_button(_color_grid.get_child(color_index), color_index)

# -------------------------------------------------------------------------------------------------
func _close() -> void:
	for btn in _color_grid.get_children():
		btn.clear_hover_state()
	hide()
	closed.emit()

# -------------------------------------------------------------------------------------------------
func _create_buttons(palette: Palette) -> void:
	# Remove old buttons
	_active_palette_button = null
	for c in _color_grid.get_children():
		_color_grid.remove_child(c)
		c.queue_free()
	
	# Add new ones
	var index := 0
	for color in palette.colors:
		var button: PaletteButton = PALETTE_BUTTON.instantiate()
		_color_grid.add_child(button)
		button.color = color
		button.pressed.connect(_on_platte_button_pressed.bind(button, index))
		index += 1
	
	# Adjust ui size
	size = get_combined_minimum_size()
	
# -------------------------------------------------------------------------------------------------
func _activate_palette_button(button: PaletteButton, color_index: int) -> void:
	if _active_palette_button != null:
		_active_palette_button.selected = false
	_active_palette_button = button
	_active_color_index = color_index
	_active_palette_button.selected = true

# -------------------------------------------------------------------------------------------------
func _on_platte_button_pressed(button: PaletteButton, index: int) -> void:
	_activate_palette_button(button, index)
	color_changed.emit(button.color)

# -------------------------------------------------------------------------------------------------
func _on_PaletteSelectionButton_item_selected(index: int) -> void:
	PaletteManager.set_active_palette_by_index(index)
	PaletteManager.save()
	
	var palette := PaletteManager.get_active_palette()
	_create_buttons(palette)
	_activate_palette_button(_color_grid.get_child(0), 0)
	_adjust_position()

# -------------------------------------------------------------------------------------------------
func _on_AddPaletteButton_pressed() -> void:
	var dialog: NewPaletteDialog = get_node(add_new_palette_dialog_path)
	dialog.duplicate_current_palette = false
	dialog.get_parent().popup_centered()

# -------------------------------------------------------------------------------------------------
func _on_EditColorButton_pressed() -> void:
	var palette := PaletteManager.get_active_palette()
	if palette.builtin:
		AlertDialog.dialog_text = tr("ALERT_EDITING_BUILTIN_PALETTE")
		AlertDialog.popup_centered()
	else:#
		hide()
		var edit_popup: EditPaletteDialog = get_node(edit_palette_dialog)
		edit_popup.setup(PaletteManager.get_active_palette(), _active_color_index)
		edit_popup.get_parent().popup_centered()

# -------------------------------------------------------------------------------------------------
func _on_DuplicatePaletteButton_pressed() -> void:
	var dialog: NewPaletteDialog = get_node(add_new_palette_dialog_path)
	dialog.duplicate_current_palette = true
	dialog.get_parent().popup_centered()

# -------------------------------------------------------------------------------------------------
func _on_DeletePaletteButton_pressed() -> void:
	if PaletteManager.get_active_palette().builtin:
		AlertDialog.dialog_text = tr("ALERT_DELETING_BUILTIN_PALETTE")
		AlertDialog.popup_centered()
	else:
		var dialog: DeletePaletteDialog = get_node(delete_palette_dialog)
		dialog.get_parent().popup_centered()

# -------------------------------------------------------------------------------------------------
func _on_ImportPaletteButton_pressed() -> void:
	var file_dialog: FileDialog = get_node(file_dialog_path)
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.file_selected.connect(_on_palette_selected_to_import)
	file_dialog.close_requested.connect(_on_file_dialog_closed)
	file_dialog.invalidate()
	file_dialog.popup_centered()

# -------------------------------------------------------------------------------------------------
func _on_palette_selected_to_import(filepath: String) -> void:
	var palette : Palette
	var palette_name: String
	var palette_colors: PackedColorArray
	var palette_string: String
	var file := FileAccess.open(filepath, FileAccess.READ)
	palette_string = file.get_as_text(true)
	file.close()
	match filepath.get_extension():
		"gpl":
			if !is_valid_gpl(palette_string):
				return
			palette_name = get_gpl_palette_name(palette_string)
			if !palette_name:
				palette_name = filepath.get_file().trim_suffix(".gpl")
			palette_colors = parse_gpl_palette(palette_string)
		"pal":
			if !is_valid_pal(palette_string):
				return
			palette_name = filepath.get_file().trim_suffix(".pal")
			palette_colors = parse_pal_palette(palette_string)
		_:
			return
	
	palette = PaletteManager.create_custom_palette(palette_name)
	if palette != null:
		palette.colors = palette_colors
		PaletteManager.save()
		PaletteManager.set_active_palette(palette)
		update_palettes()

# -------------------------------------------------------------------------------------------------
func is_valid_gpl(gpl_palette: String) -> bool:
	return gpl_palette.begins_with("GIMP Palette")

# -------------------------------------------------------------------------------------------------
func get_gpl_palette_name(gpl_palette: String) -> String:
	var name_line: String
	name_line = gpl_palette.get_slice("\n", 1)
	if name_line.begins_with("Name: "):
		return name_line.right(-6).strip_edges()
	else:
		return ""

# -------------------------------------------------------------------------------------------------
func parse_gpl_palette(gpl_palette: String) -> PackedColorArray:
	var color_array: PackedColorArray
	for line in gpl_palette.split("\n"):
		if !line or line.begins_with("#") or line == "GIMP Palette":
			continue
		var values: Array
		if line.contains("\t"):
			values = line.split("\t")
		else:
			values = line.split(" ")
		color_array.append(
			Color(
				float(values[0])/255,
				float(values[1])/255,
				float(values[2])/255
				)
			)
	return color_array

# -------------------------------------------------------------------------------------------------
func is_valid_pal(pal_palette: String) -> bool:
	return pal_palette.begins_with("JASC-PAL")

# -------------------------------------------------------------------------------------------------
func parse_pal_palette(pal_palette: String) -> PackedColorArray:
	var color_array: PackedColorArray
	var n_colors: int
	n_colors = int(pal_palette.split("\n")[2])
	for i in range(3,n_colors+3):
		var values: Array
		values = pal_palette.split("\n")[i].split(" ")
		color_array.append(
			Color(
				float(values[0])/255,
				float(values[1])/255,
				float(values[2])/255
				)
			)
	return color_array

# -------------------------------------------------------------------------------------------------
func _on_file_dialog_closed() -> void:
	var file_dialog: FileDialog = get_node(file_dialog_path)
	Utils.remove_signal_connections(file_dialog, "file_selected")
	Utils.remove_signal_connections(file_dialog, "close_requested")

# -------------------------------------------------------------------------------------------------
func toggle() -> void:
	visible = !visible
	_adjust_position()

# -------------------------------------------------------------------------------------------------
func _adjust_position() -> void:
	var color_button_position: float = _toolbar.get_brush_color_button().position.x
	# If palette extends beyond the window
	if color_button_position + size.x > _toolbar.size.x:
		var size_offset: int = _toolbar.size.x - size.x
		# If window size is big enough to show the entire palette (horizontally)
		if size_offset >= 0:
			position.x = size_offset
		elif _color_grid.get_combined_minimum_size().x < _toolbar.size.x:
			position.x = 0
		else:
			var color_button_size: float = _toolbar.get_brush_color_button().size.x
			# Brackets = Distance of window center from left side of color button
			# Distance / size = ratio where (0 <= ratio <= 1) scrolls through color picker
			# (ratio < 0) clamps to left side of color picker, (ratio > 1) clamps to right side
			var interval_position: float = (_toolbar.scroll_horizontal + _toolbar.size.x / 2 - color_button_position) / color_button_size * size_offset
			position.x = clamp(interval_position, size_offset, 0)
	elif position.x != color_button_position:
		position.x = color_button_position - _toolbar.scroll_horizontal
