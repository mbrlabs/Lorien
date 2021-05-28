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

const ITEM_TOOL_1 		:= 100
const ITEM_TOOL_2 		:= 101
const ITEM_TOOL_3 		:= 102

const ITEM_EXPORT_PNG	:= 200

# -------------------------------------------------------------------------------------------------
onready var _submenu_tools: PopupMenu = $ToolsMenu
onready var _submenu_export: PopupMenu = $ExportMenu

# -------------------------------------------------------------------------------------------------
func _ready():
	# Tool submenu
	_submenu_tools.name = "Tools"
	_submenu_tools.add_item("Tool 1", ITEM_TOOL_1)
	_submenu_tools.add_item("Tool 2", ITEM_TOOL_2)
	
	# Export submenu
	_submenu_export.name = "Export"
	_submenu_export.add_item("Export Canvas as PNG", ITEM_EXPORT_PNG)
	
	# main menu
	add_item("Save", ITEM_SAVE)
	add_item("Save as", ITEM_SAVE_AS)
	add_submenu_item(_submenu_export.name, "Export")
	add_separator()
	add_submenu_item(_submenu_tools.name, "Tools")
	add_item("Settings", ITEM_SETTINGS)
	add_separator()
	add_item("Online Manual", ITEM_MANUAL)
	add_item("Bug Tracker", ITEM_BUG_TRACKER)
	add_item("About", ITEM_ABOUT)

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
