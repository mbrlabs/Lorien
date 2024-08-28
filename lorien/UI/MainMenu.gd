class_name MainMenu
extends PopupMenu

# -------------------------------------------------------------------------------------------------
signal open_about_dialog
signal open_settings_dialog
signal open_url(url: String)
signal open_project(filepath: String)
signal save_project
signal save_project_as
signal export_svg

# -------------------------------------------------------------------------------------------------
const ITEM_OPEN 		:= 0
const ITEM_SAVE 		:= 1
const ITEM_SAVE_AS 		:= 2
const ITEM_EXPORT 		:= 3
const ITEM_SETTINGS 	:= 4
const ITEM_MANUAL 		:= 5
const ITEM_BUG_TRACKER 	:= 6
const ITEM_ABOUT 		:= 7

# -------------------------------------------------------------------------------------------------
@export var file_dialog_path: NodePath

# -------------------------------------------------------------------------------------------------
func _ready() -> void:
	_set_items()
	
	id_pressed.connect(_on_item_pressed)
	GlobalSignals.language_changed.connect(_set_items)
	GlobalSignals.keybinding_changed.connect(func(action): _set_items())

# -------------------------------------------------------------------------------------------------
func _set_items() -> void:
	clear()
	
	var open_action := KeybindingsManager.get_action("shortcut_open_project")
	var save_action := KeybindingsManager.get_action("shortcut_save_project")
	var export_action := KeybindingsManager.get_action("shortcut_export_project")
	
	add_item(tr("MENU_OPEN"), ITEM_OPEN, open_action.event.get_keycode_with_modifiers())
	add_item(tr("MENU_SAVE"), ITEM_SAVE, save_action.event.get_keycode_with_modifiers())
	add_item(tr("MENU_SAVE_AS"), ITEM_SAVE_AS)
	add_item(tr("MENU_EXPORT"), ITEM_EXPORT, export_action.event.get_keycode_with_modifiers())
	add_item(tr("MENU_SETTINGS"), ITEM_SETTINGS)
	add_separator()
	add_item(tr("MENU_MANUAL"), ITEM_MANUAL)
	add_item(tr("MENU_BUG_TRACKER"), ITEM_BUG_TRACKER)
	add_item(tr("MENU_ABOUT"), ITEM_ABOUT)

# -------------------------------------------------------------------------------------------------
func _on_item_pressed(id: int):
	match id:
		ITEM_OPEN: _on_open_project()
		ITEM_SAVE: save_project.emit()
		ITEM_SAVE_AS: save_project_as.emit()
		ITEM_EXPORT: export_svg.emit()
		ITEM_SETTINGS: open_settings_dialog.emit()
		ITEM_MANUAL: open_url.emit("https://github.com/mbrlabs/lorien/blob/main/docs/manuals/manual_v0.6.0.md")
		ITEM_BUG_TRACKER: open_url.emit("https://github.com/mbrlabs/lorien/issues")
		ITEM_ABOUT: open_about_dialog.emit()

# -------------------------------------------------------------------------------------------------
func _on_open_project():
	var file_dialog: FileDialog = get_node(file_dialog_path)
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.file_selected.connect(_on_project_selected_to_open)
	file_dialog.close_requested.connect(_on_file_dialog_closed)
	file_dialog.invalidate()
	file_dialog.popup_centered()

# -------------------------------------------------------------------------------------------------
func _on_project_selected_to_open(filepath: String) -> void:
	open_project.emit(filepath)

# -------------------------------------------------------------------------------------------------
func _on_file_dialog_closed() -> void:
	var file_dialog: FileDialog = get_node(file_dialog_path)
	Utils.remove_signal_connections(file_dialog, "file_selected")
	Utils.remove_signal_connections(file_dialog, "close_requested")
