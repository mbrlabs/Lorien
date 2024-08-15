class_name ColorPalettePicker
extends PanelContainer

# -------------------------------------------------------------------------------------------------
const PALETTE_BUTTON = preload("res://UI/Components/PaletteButton.tscn")

# -------------------------------------------------------------------------------------------------
signal color_changed(color)
signal closed

# -------------------------------------------------------------------------------------------------
export var add_new_palette_dialog_path: NodePath
export var edit_palette_dialog: NodePath
export var delete_palette_dialog: NodePath
export var toolbar_path: NodePath

onready var _toolbar = get_node(toolbar_path)
onready var _palette_selection_button: OptionButton = $MarginContainer/VBoxContainer/Buttons/PaletteSelectionButton
onready var _color_grid: GridContainer = $MarginContainer/VBoxContainer/ColorGrid
onready var _edit_button: TextureButton = $MarginContainer/VBoxContainer/Buttons/EditColorButton
onready var _new_button: TextureButton = $MarginContainer/VBoxContainer/Buttons/AddPaletteButton
onready var _duplicate_button: TextureButton = $MarginContainer/VBoxContainer/Buttons/DuplicatePaletteButton
onready var _delete_button: TextureButton = $MarginContainer/VBoxContainer/Buttons/DeletePaletteButton

var _active_palette_button: PaletteButton
var _active_color_index := -1

# -------------------------------------------------------------------------------------------------
func _ready() -> void:
	update_palettes()

# -------------------------------------------------------------------------------------------------
func _input(event: InputEvent) -> void:
	if !visible:
		return
	elif event is InputEventMouseButton && event.pressed:
		var should_hide := !Utils.is_mouse_in_control(self)
		should_hide = should_hide && !Utils.is_mouse_in_control(_toolbar.get_brush_color_button())
		should_hide = should_hide && !get_parent().is_dialog_open()
		should_hide = should_hide && !_palette_selection_button.get_popup().visible
		should_hide = should_hide && !AlertDialog.visible
		if should_hide:
			_close()

	elif event is InputEventKey && event.pressed && event.scancode == KEY_ESCAPE:
		_close()

# -------------------------------------------------------------------------------------------------
func get_active_color() -> Color:
	if _active_palette_button != null:
		return _active_palette_button.color
	return Color.white

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
	emit_signal("closed")

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
		var button: PaletteButton = PALETTE_BUTTON.instance()
		_color_grid.add_child(button)
		button.color = color
		button.connect("pressed", self, "_on_platte_button_pressed", [button, index])
		index += 1
	
	# Adjust ui size
	rect_size = get_combined_minimum_size()
	
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
	emit_signal("color_changed", button.color)

# -------------------------------------------------------------------------------------------------
func _change_brush_color(color_index: int) -> void:
	color_index = min(color_index, PaletteManager.get_active_palette().colors.size()-1)
	_on_platte_button_pressed(_color_grid.get_child(color_index), color_index)

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
	dialog.popup_centered()

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
		edit_popup.popup_centered()

# -------------------------------------------------------------------------------------------------
func _on_DuplicatePaletteButton_pressed() -> void:
	var dialog: NewPaletteDialog = get_node(add_new_palette_dialog_path)
	dialog.duplicate_current_palette = true
	dialog.popup_centered()

# -------------------------------------------------------------------------------------------------
func _on_DeletePaletteButton_pressed() -> void:
	if PaletteManager.get_active_palette().builtin:
		AlertDialog.dialog_text = tr("ALERT_DELETING_BUILTIN_PALETTE")
		AlertDialog.popup_centered()
	else:
		var dialog: DeletePaletteDialog = get_node(delete_palette_dialog)
		dialog.popup_centered()

# -------------------------------------------------------------------------------------------------
func toggle() -> void:
	visible = !visible
	_adjust_position()

# -------------------------------------------------------------------------------------------------
func _adjust_position() -> void:
	var color_button_position: float = _toolbar.get_brush_color_button().rect_position.x
	# If palette extends beyond the window
	if color_button_position + rect_size.x > _toolbar.rect_size.x:
		var size_offset: int = _toolbar.rect_size.x - rect_size.x
		# If window size is big enough to show the entire palette (horizontally)
		if size_offset >= 0:
			rect_position.x = size_offset
		elif _color_grid.get_combined_minimum_size().x < _toolbar.rect_size.x:
			rect_position.x = 0
		else:
			var color_button_size: float = _toolbar.get_brush_color_button().rect_size.x
			# Brackets = Distance of window center from left side of color button
			# Distance / size = ratio where (0 <= ratio <= 1) scrolls through color picker
			# (ratio < 0) clamps to left side of color picker, (ratio > 1) clamps to right side
			var interval_position: float = (_toolbar.scroll_horizontal + _toolbar.rect_size.x / 2 - color_button_position) / color_button_size * size_offset
			rect_position.x = clamp(interval_position, size_offset, 0)
	elif rect_position.x != color_button_position:
		rect_position.x = color_button_position - _toolbar.scroll_horizontal
