extends Panel
class_name UITitlebar

# -------------------------------------------------------------------------------------------------
const UI_TAB = preload("res://UI/Components/UITab.tscn")

# -------------------------------------------------------------------------------------------------
signal project_selected(project_id)
signal project_closed(project_id)
signal create_new_project

# -------------------------------------------------------------------------------------------------
onready var _file_tabs_container: HBoxContainer = $Left/Tabs
export var _menu_popup_path: NodePath
var _active_file_tab: UITab
var _tabs_map: Dictionary # Dictonary<project_id, UITab>

# -------------------------------------------------------------------------------------------------
func make_tab(project: Project) -> void:
	var tab: UITab = UI_TAB.instance()
	tab.title = project.get_filename()
	tab.project_id = project.id
	tab.connect("close_requested", self, "_on_tab_close_requested")
	tab.connect("selected", self, "_on_tab_selected")
	_file_tabs_container.add_child(tab)
	_tabs_map[project.id] = tab

# ------------------------------------------------------------------------------------------------
func remove_tab(project: Project) -> void:
	if _tabs_map.has(project.id):
		var tab = _tabs_map[project.id]
		_file_tabs_container.remove_child(tab)
		_tabs_map.erase(project.id)

# ------------------------------------------------------------------------------------------------
func set_tab_active(project: Project) -> void:
	if _tabs_map.has(project.id):
		var tab: UITab = _tabs_map[project.id]
		_active_file_tab = tab
		for c in _file_tabs_container.get_children():
			c.set_active(false)
		tab.set_active(true)
	else:
		print_debug("Project tab not found")

# -------------------------------------------------------------------------------------------------
func _on_tab_close_requested(tab: UITab) -> void:
	emit_signal("project_closed", tab.project_id)

# -------------------------------------------------------------------------------------------------
func _on_tab_selected(tab: UITab) -> void:
	emit_signal("project_selected", tab.project_id)

# -------------------------------------------------------------------------------------------------
func _on_NewFileButton_pressed():
	 emit_signal("create_new_project")

# -------------------------------------------------------------------------------------------------
func _on_MenuButton_pressed():
	get_node(_menu_popup_path).popup()
