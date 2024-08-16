extends Panel
class_name Menubar

# -------------------------------------------------------------------------------------------------
const PROJECT_TAB = preload("res://UI/Components/ProjectTab.tscn")

# -------------------------------------------------------------------------------------------------
signal project_selected(project_id)
signal project_closed(project_id)
signal create_new_project

# -------------------------------------------------------------------------------------------------
@onready var _menu_button: TextureButton = $Left/MenuButton
@onready var _new_file_button: Button = $Left/NewFileButton
@onready var _file_tabs_container: HBoxContainer = $Left/TabBar

@export var _main_menu_path: NodePath
var _active_file_tab: ProjectTab
var _tabs_map: Dictionary # Dictonary<project_id, ProjectTab>

# -------------------------------------------------------------------------------------------------
func _ready() -> void:
	_menu_button.connect("pressed", Callable(self, "_on_MenuButton_pressed"))
	_new_file_button.connect("pressed", Callable(self, "_on_NewFileButton_pressed"))

# -------------------------------------------------------------------------------------------------
func make_tab(project: Project) -> void:
	var tab: ProjectTab = PROJECT_TAB.instantiate()
	tab.title = project.get_scene_file_path()
	tab.project_id = project.id
	tab.connect("close_requested", Callable(self, "_on_tab_close_requested"))
	tab.connect("selected", Callable(self, "_on_tab_selected"))
	_file_tabs_container.add_child(tab)
	_tabs_map[project.id] = tab

# ------------------------------------------------------------------------------------------------
func has_tab(project: Project) -> bool:
	return _tabs_map.has(project.id)

# ------------------------------------------------------------------------------------------------
func remove_tab(project: Project) -> void:
	if _tabs_map.has(project.id):
		var tab = _tabs_map[project.id]
		tab.disconnect("close_requested", Callable(self, "_on_tab_close_requested"))
		tab.disconnect("selected", Callable(self, "_on_tab_selected"))
		_file_tabs_container.remove_child(tab)
		_tabs_map.erase(project.id)
		tab.call_deferred("free")

# ------------------------------------------------------------------------------------------------
func remove_all_tabs() -> void:
	for project_id in _tabs_map.keys():
		var project: Project = ProjectManager.get_project_by_id(project_id)
		remove_tab(project)
	_tabs_map.clear()
	_active_file_tab = null

# ------------------------------------------------------------------------------------------------
func update_tab_title(project: Project) -> void:
	if _tabs_map.has(project.id):
		var name = project.get_scene_file_path()
		if project.dirty:
			name += " (*)"
		_tabs_map[project.id].title = name

# ------------------------------------------------------------------------------------------------
func set_tab_active(project: Project) -> void:
	if _tabs_map.has(project.id):
		var tab: ProjectTab = _tabs_map[project.id]
		_active_file_tab = tab
		for c in _file_tabs_container.get_children():
			c.set_active(false)
		tab.set_active(true)
	else:
		print_debug("Project tab not found")

# -------------------------------------------------------------------------------------------------
func _on_tab_close_requested(tab: ProjectTab) -> void:
	emit_signal("project_closed", tab.project_id)

# -------------------------------------------------------------------------------------------------
func _on_tab_selected(tab: ProjectTab) -> void:
	emit_signal("project_selected", tab.project_id)

# -------------------------------------------------------------------------------------------------
func _on_NewFileButton_pressed() -> void:
	emit_signal("create_new_project")

# -------------------------------------------------------------------------------------------------
func _on_MenuButton_pressed():
	get_node(_main_menu_path).popup()

# -------------------------------------------------------------------------------------------------
func get_first_project_id() -> int:
	if _file_tabs_container.get_child_count() == 0:
		return -1
	return _file_tabs_container.get_child(0).project_id
