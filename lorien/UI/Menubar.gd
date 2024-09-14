class_name Menubar
extends Panel

# -------------------------------------------------------------------------------------------------
signal project_selected(project_id: int)
signal project_closed(project_id: int)
signal create_new_project

# -------------------------------------------------------------------------------------------------
@onready var _menu_button: TextureButton = $Left/MenuButton
@onready var _new_file_button: TextureButton = $Left/NewFileButton
@onready var _tab_bar: TabBar = $Left/TabBar

@export var _main_menu_path: NodePath

# -------------------------------------------------------------------------------------------------
func _ready() -> void:
	_menu_button.pressed.connect(_on_menu_button_pressed)
	
	_new_file_button.pressed.connect(func() -> void:
		create_new_project.emit()
	)
	
	_tab_bar.tab_close_pressed.connect(func(index: int) -> void:
		var project := _tab_bar.get_tab_metadata(index) as Project
		_tab_bar.remove_tab(index)
		project_closed.emit(project.id)
	)
	
	_tab_bar.tab_clicked.connect(func(index: int) -> void:
		var project := _tab_bar.get_tab_metadata(index) as Project
		project_selected.emit(project.id)
	)

# -------------------------------------------------------------------------------------------------
func make_tab(project: Project) -> void:
	_tab_bar.add_tab(project.get_scene_file_path())
	_tab_bar.set_tab_metadata(_tab_bar.tab_count - 1, project)
	_update_tabbar_size()
 
# ------------------------------------------------------------------------------------------------
func has_tab(project: Project) -> bool:
	for i: int in _tab_bar.tab_count:
		var p := _tab_bar.get_tab_metadata(i) as Project
		if project == p:
			return true
	return false

# ------------------------------------------------------------------------------------------------
func remove_tab(project: Project) -> void:
	for i: int in _tab_bar.tab_count:
		var p := _tab_bar.get_tab_metadata(i) as Project
		if project == p:
			_tab_bar.remove_tab(i)
			_update_tabbar_size()
			return


# ------------------------------------------------------------------------------------------------
func remove_all_tabs() -> void:
	_tab_bar.clear_tabs()
	_update_tabbar_size()

# ------------------------------------------------------------------------------------------------
func update_tab_title(project: Project) -> void:
	for i: int in _tab_bar.tab_count:
		var p := _tab_bar.get_tab_metadata(i) as Project
		if project == p:
			var new_title := project.get_scene_file_path()
			if project.dirty:
				new_title += " (*)"
			_tab_bar.set_tab_title(i, new_title)
			_update_tabbar_size()
			return

# ------------------------------------------------------------------------------------------------
func set_tab_active(project: Project) -> void:
	for i: int in _tab_bar.tab_count:
		var p := _tab_bar.get_tab_metadata(i) as Project
		if project == p:
			_tab_bar.current_tab = i
			return

# -------------------------------------------------------------------------------------------------
func _on_menu_button_pressed() -> void:
	var menu: MainMenu = get_node(_main_menu_path)
	menu.popup_on_parent(_menu_button.get_rect())

# -------------------------------------------------------------------------------------------------
func get_first_project_id() -> int:
	if _tab_bar.tab_count == 0:
		return -1
	else:
		var project := _tab_bar.get_tab_metadata(0) as Project
		return project.id

# -------------------------------------------------------------------------------------------------
func _update_tabbar_size() -> void:
	var width := 0
	for i: int in _tab_bar.tab_count:
		width += _tab_bar.get_tab_rect(i).size.x
		
	_tab_bar.custom_minimum_size.x = min(width, get_viewport_rect().size.x - 128)
