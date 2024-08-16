extends PopupMenu
class_name MainMenu

# -------------------------------------------------------------------------------------------------
signal open_about_dialog
signal open_settings_dialog
signal open_url(url)
signal open_project(filepath)
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

const ITEM_VIEW_1 		:= 100
const ITEM_VIEW_2 		:= 101
const ITEM_VIEW_3 		:= 102

# -------------------------------------------------------------------------------------------------
@export var file_dialog_path: NodePath
@onready var _submenu_views: PopupMenu = $ViewsMenu

# -------------------------------------------------------------------------------------------------
func _ready() -> void:
	connect("id_pressed", Callable(self, "_on_MainMenu_id_pressed"))
	
	# Views submenu
	_submenu_views.name = "Views"
	_submenu_views.add_item("View 1", ITEM_VIEW_1)
	_submenu_views.add_item("View 2", ITEM_VIEW_2)

	# main menu
	_apply_language()
	GlobalSignals.connect("language_changed", Callable(self, "_apply_language"))

# -------------------------------------------------------------------------------------------------
func _apply_language() -> void:
	clear()
	add_item(tr("MENU_OPEN"), ITEM_OPEN)
	add_item(tr("MENU_SAVE"), ITEM_SAVE)
	add_item(tr("MENU_SAVE_AS"), ITEM_SAVE_AS)
	add_item(tr("MENU_EXPORT"), ITEM_EXPORT)
	add_item(tr("MENU_SETTINGS"), ITEM_SETTINGS)
	add_separator()
	add_item(tr("MENU_MANUAL"), ITEM_MANUAL)
	add_item(tr("MENU_BUG_TRACKER"), ITEM_BUG_TRACKER)
	add_item(tr("MENU_ABOUT"), ITEM_ABOUT)

# -------------------------------------------------------------------------------------------------
func _on_MainMenu_id_pressed(id: int):
	match id:
		ITEM_OPEN: _on_open_project()
		ITEM_SAVE: emit_signal("save_project")
		ITEM_SAVE_AS: emit_signal("save_project_as")
		ITEM_EXPORT: emit_signal("export_svg")
		ITEM_SETTINGS: emit_signal("open_settings_dialog")
		ITEM_MANUAL: emit_signal("open_url", "https://github.com/mbrlabs/lorien/blob/main/docs/manuals/manual_v0.6.0.md")
		ITEM_BUG_TRACKER: emit_signal("open_url", "https://github.com/mbrlabs/lorien/issues")
		ITEM_ABOUT: emit_signal("open_about_dialog")

# -------------------------------------------------------------------------------------------------
func _on_open_project():
	var file_dialog: FileDialog = get_node(file_dialog_path)
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.connect("file_selected", Callable(self, "_on_project_selected_to_open"))
	file_dialog.connect("popup_hide", Callable(self, "_on_file_dialog_closed"))
	file_dialog.invalidate()
	file_dialog.popup_centered()

# -------------------------------------------------------------------------------------------------
func _on_project_selected_to_open(filepath: String) -> void:
	emit_signal("open_project", filepath)

# -------------------------------------------------------------------------------------------------
func _on_file_dialog_closed() -> void:
	var file_dialog: FileDialog = get_node(file_dialog_path)
	Utils.remove_signal_connections(file_dialog, "file_selected")
	Utils.remove_signal_connections(file_dialog, "popup_hide")

# -------------------------------------------------------------------------------------------------
func add_item_with_shortcut(target: PopupMenu, name: String, id: int, shortcut_action: String) -> void:
	var shortcut = InputMap.action_get_events(shortcut_action)[0].get_keycode_with_modifiers()
	target.add_item(name, id, shortcut)
