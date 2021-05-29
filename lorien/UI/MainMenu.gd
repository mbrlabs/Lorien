extends PopupMenu
class_name MainMenu

# -------------------------------------------------------------------------------------------------
signal open_about_dialog
signal open_settings_dialog
signal open_url(url)
signal export_as(type)

# -------------------------------------------------------------------------------------------------
const ITEM_SAVE 		:= 0
const ITEM_SAVE_AS 		:= 1
const ITEM_SETTINGS 	:= 2
const ITEM_MANUAL 		:= 3
const ITEM_BUG_TRACKER 	:= 4
const ITEM_ABOUT 		:= 5

const ITEM_VIEW_1 		:= 100
const ITEM_VIEW_2 		:= 101
const ITEM_VIEW_3 		:= 102

const ITEM_EXPORT_PNG	:= 200

# -------------------------------------------------------------------------------------------------
onready var _submenu_views: PopupMenu = $ViewsMenu
onready var _submenu_export: PopupMenu = $ExportMenu

# -------------------------------------------------------------------------------------------------
func _ready():
	# Views submenu
	_submenu_views.name = "Views"
	_submenu_views.add_item("View 1", ITEM_VIEW_1)
	_submenu_views.add_item("View 2", ITEM_VIEW_2)
	
	# Export submenu
	_submenu_export.name = tr("MENU_EXPORT")
	_submenu_export.add_item(tr("MENU_EXPORT_PNG"), ITEM_EXPORT_PNG)
	
	# main menu
	add_item(tr("MENU_SAVE"), ITEM_SAVE)
	add_item(tr("MENU_SAVE_AS"), ITEM_SAVE_AS)
	add_submenu_item(_submenu_export.name, tr("MENU_EXPORT"))
	add_separator()
	add_item(tr("MENU_SETTINGS"), ITEM_SETTINGS)
	add_separator()
	add_item(tr("MENU_MANUAL"), ITEM_MANUAL)
	add_item(tr("MENU_BUG_TRACKER"), ITEM_BUG_TRACKER)
	add_item(tr("MENU_ABOUT"), ITEM_ABOUT)

# -------------------------------------------------------------------------------------------------
func _on_MainMenu_id_pressed(id: int):
	match id:
		ITEM_SAVE: pass # TODO: implement
		ITEM_SAVE_AS: pass # TODO: implement
		ITEM_SETTINGS: emit_signal("open_settings_dialog")
		ITEM_MANUAL: emit_signal("open_url", "https://github.com/mbrlabs/lorien/blob/main/docs/manuals/manual_v0.2.0.md")
		ITEM_BUG_TRACKER: emit_signal("open_url", "https://github.com/mbrlabs/lorien/issues")
		ITEM_ABOUT: emit_signal("open_about_dialog")

# -------------------------------------------------------------------------------------------------
func _on_SaveAsMenu_id_pressed(id: int):
	match id:
		ITEM_EXPORT_PNG: emit_signal("export_as", Types.ExportType.PNG)

# -------------------------------------------------------------------------------------------------
func add_item_with_shortcut(target: PopupMenu, name: String, id: int, shortcut_action: String) -> void:
	var shortcut = InputMap.get_action_list(shortcut_action)[0].get_scancode_with_modifiers()
	target.add_item(name, id, shortcut)
