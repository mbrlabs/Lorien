extends Panel
class_name UITitlebar

# -------------------------------------------------------------------------------------------------
const UI_TAB = preload("res://UI/Components/UITab.tscn")

# -------------------------------------------------------------------------------------------------
signal file_tab_selected
signal file_tab_close_requested

# -------------------------------------------------------------------------------------------------
onready var _file_tabs: HBoxContainer = $Left/Tabs
export var _menu_popup_path: NodePath
var _active_file_tab: UITab

# -------------------------------------------------------------------------------------------------
func _ready() -> void:
	var tab := add_tab("Untitled", "")
	set_tab_active(tab)

# -------------------------------------------------------------------------------------------------
func add_tab(name: String, filepath: String) -> UITab:
	var tab: UITab = UI_TAB.instance()
	tab.connect("close_requested", self, "_on_tab_close_requested")
	tab.connect("selected", self, "_on_tab_selected")
	tab.title = name
	tab.filepath = filepath
	_file_tabs.add_child(tab)
	return tab

# ------------------------------------------------------------------------------------------------
func remove_tab(tab: UITab) -> void:
	_file_tabs.remove_child(tab)

# ------------------------------------------------------------------------------------------------
func set_tab_active(tab: UITab) -> void:
	_active_file_tab = tab
	for c in _file_tabs.get_children():
		c.set_active(false)
	tab.set_active(true)

# -------------------------------------------------------------------------------------------------
func _on_tab_close_requested(tab: UITab) -> void:
	remove_tab(tab) # TODO; dont do this here. this should be handled in Main.gd or somewehre with business logic
	emit_signal("file_tab_close_requested", tab)

# -------------------------------------------------------------------------------------------------
func _on_tab_selected(tab: UITab) -> void:
	set_tab_active(tab)  # TODO; dont do this here. this should be handled in Main.gd or somewehre with business logic
	emit_signal("file_tab_selected", tab)

# -------------------------------------------------------------------------------------------------
func _on_NewFileButton_pressed():
	 # TODO; dont do this here. this should be handled in Main.gd or somewehre with business logic
	var tab := add_tab("Untitled %s" % _file_tabs.get_child_count(), "")
	set_tab_active(tab)

# -------------------------------------------------------------------------------------------------
func _on_MenuButton_pressed():
	get_node(_menu_popup_path).popup()
