extends Node

# -------------------------------------------------------------------------------------------------
var _open_projects: Array # Array<Project>
var _active_project: Project

# -------------------------------------------------------------------------------------------------
func read_project_list() -> void:
	pass

# -------------------------------------------------------------------------------------------------
func make_project_active(project: Project) -> void:
	if !project.loaded:
		_load_project(project)
	_active_project = project

# -------------------------------------------------------------------------------------------------
func get_active_project() -> Project:
	return _active_project

# -------------------------------------------------------------------------------------------------
func add_project(filepath: String = "") -> Project:
	# Check if already open
	if !filepath.empty():
		var p := get_open_project_by_filepath(filepath)
		if p != null:
			print_debug("Project already in open project list")
			return p
	
	var project := Project.new()
	project.id = _open_projects.size()
	project.filepath = filepath
	project.loaded = project.filepath.empty() # empty/unsaved/new projects are loaded by definition
	_open_projects.append(project)
	return project
	
# -------------------------------------------------------------------------------------------------
func save_project(project: Project) -> void:
	Serializer.serialize(project)
	project.dirty = false

# -------------------------------------------------------------------------------------------------
func _load_project(project: Project) -> void:
	if !project.loaded:
		Serializer.deserialize(project)
		project.loaded = true
	else:
		print_debug("Trying to load already loaded project")

# -------------------------------------------------------------------------------------------------
func get_open_project_by_filepath(filepath: String) -> Project:
	for p in _open_projects:
		if p.filepath == filepath:
			return p
	return null

# -------------------------------------------------------------------------------------------------
func get_project_by_id(id: int) -> Project:
	for p in _open_projects:
		if p.id == id:
			return p
	return null
