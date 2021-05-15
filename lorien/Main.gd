extends Control

# -------------------------------------------------------------------------------------------------
export var default_canvas_color := Color.black

onready var _canvas: InfiniteCanvas = $InfiniteCanvas
onready var _ui_statusbar: UIStatusbar = $UIStatusBar
onready var _ui_titlebar: UITitlebar = $UITitlebar
onready var _ui_toolbar: UIToolbar = $UIToolbar

onready var _file_dialog: FileDialog = $FileDialog

# -------------------------------------------------------------------------------------------------
func _ready():
	_canvas.set_background_color(default_canvas_color)
	_file_dialog.current_dir = Config.DEFAULT_FILE_DIALOG_PATH
	
	# UI Signals
	_ui_toolbar.connect("undo_action", self, "_on_undo_action")
	_ui_toolbar.connect("redo_action", self, "_on_redo_action")
	_ui_toolbar.connect("clear_canvas", self, "_on_clear_canvas")
	_ui_toolbar.connect("open_project", self, "_on_open_project")
	_ui_toolbar.connect("new_project", self, "_on_create_new_project")
	_ui_toolbar.connect("save_project", self, "_on_save_project")
	_ui_toolbar.connect("brush_color_changed", self, "_on_brush_color_changed")
	_ui_toolbar.connect("brush_size_changed", self, "_on_brush_size_changed")
	_ui_toolbar.connect("canvas_background_changed", self, "_on_canvas_background_changed")
	
	_ui_titlebar.connect("create_new_project", self, "_on_create_new_project")
	_ui_titlebar.connect("project_selected", self, "_on_project_selected")
	_ui_titlebar.connect("project_closed", self, "_on_project_closed")
	
	# Create the default project
	# TODO: once project managament is fully implemented, this should be replaced with last open (at exit) files
	_create_default_project()

# -------------------------------------------------------------------------------------------------
func _physics_process(delta):
	_handle_shortcut_actions()
	_ui_statusbar.set_stroke_count(_canvas.info.stroke_count)
	_ui_statusbar.set_point_count(_canvas.info.point_count)
	_ui_statusbar.set_pressure(_canvas.info.current_pressure)
	_ui_statusbar.set_brush_position(_canvas.info.current_brush_position)
	_ui_statusbar.set_camera_zoom(_canvas.get_camera_zoom())
	_ui_statusbar.set_fps(Engine.get_frames_per_second())
	
	# FIXME: i put this here to update dirty tabs; shuld only be called once
	var active_project: Project = ProjectManager.get_active_project()
	if active_project != null:
		_ui_titlebar.update_tab_title(active_project)

# -------------------------------------------------------------------------------------------------
func _handle_shortcut_actions() -> void:
	if Input.is_action_just_pressed("shortcut_new_project"):
		_on_create_new_project()
	if Input.is_action_just_pressed("shortcut_open_project"):
		_ui_toolbar._on_OpenFileButton_pressed() # FIXME
	if Input.is_action_just_pressed("shortcut_save_project"):
		_on_save_project()
	if Input.is_action_just_pressed("shortcut_undo"):
		_on_undo_action()
	if Input.is_action_just_pressed("shortcut_redo"):
		_on_redo_action()
	if Input.is_action_just_pressed("shortcut_brush_tool"):
		print("Brush Tool") # TODO
	if Input.is_action_just_pressed("shortcut_line_tool"):
		print("Line Tool!") # TODO
	if Input.is_action_just_pressed("shortcut_eraser_tool"):
		print("Eraser Tool!") # TODO

# -------------------------------------------------------------------------------------------------
func _create_default_project() -> void:
	var default_project: Project = ProjectManager.add_project()
	ProjectManager.make_project_active(default_project)
	_canvas.use_project(default_project)
	_ui_titlebar.make_tab(default_project)
	_ui_titlebar.set_tab_active(default_project)

# -------------------------------------------------------------------------------------------------
func _save_project(project: Project) -> void:
	var cam: Camera2D = _canvas.get_camera()
	var meta_data = { # FIXME: the parsing code is done in InfiniteCanvas. Not pretty...need to rework this eventually
		Serializer.METADATA_CAMERA_OFFSET_X: str(cam.offset.x),
		Serializer.METADATA_CAMERA_OFFSET_Y: str(cam.offset.y),
		Serializer.METADATA_CAMERA_ZOOM: str(cam.zoom.x),
		Serializer.CANVAS_COLOR: _canvas.get_background_color().to_html(false),
	}
	project.meta_data = meta_data
	ProjectManager.save_project(project)
	_ui_titlebar.update_tab_title(project)

# -------------------------------------------------------------------------------------------------
func _on_create_new_project() -> void:
	var project: Project = ProjectManager.add_project()
	ProjectManager.make_project_active(project)
	_canvas.use_project(project)
	_ui_titlebar.make_tab(project)
	_ui_titlebar.set_tab_active(project)

# -------------------------------------------------------------------------------------------------
func _on_project_selected(project_id: int) -> void:
	var project: Project = ProjectManager.get_project_by_id(project_id)
	ProjectManager.make_project_active(project)
	_ui_titlebar.set_tab_active(project)
	_canvas.use_project(project)

# -------------------------------------------------------------------------------------------------
func _on_project_closed(project_id: int) -> void:
	var project: Project = ProjectManager.get_project_by_id(project_id)
	
	if project.dirty:
		# TODO
		printerr("Trying close project with unsaved changes. Not possible right now")
		return
	
	# don't remove the default project
	if ProjectManager.get_project_count() == 1 && project.filepath.empty():
		return
	
	# Remove project
	ProjectManager.remove_project(project)
	_ui_titlebar.remove_tab(project)
	
	# choose new project
	if ProjectManager.get_project_count() == 0:
		_create_default_project()
	else:
		# TODO: i should choose the tab closest to the one closed; not just the first/last
		var new_project_id: int = _ui_titlebar.get_first_project_id()
		var new_project: Project = ProjectManager.get_project_by_id(new_project_id)
		
		ProjectManager.make_project_active(new_project)
		_ui_titlebar.set_tab_active(new_project)
		_canvas.use_project(new_project)

# -------------------------------------------------------------------------------------------------
func _on_brush_color_changed(color: Color) -> void:
	_canvas.brush_color = color

# -------------------------------------------------------------------------------------------------
func _on_brush_size_changed(size: int) -> void:
	_canvas.set_brush_size(size)

# -------------------------------------------------------------------------------------------------
func _on_clear_canvas() -> void:
	_canvas.clear() 

# -------------------------------------------------------------------------------------------------
func _on_open_project(filepath: String) -> void:
	var project: Project = ProjectManager.get_open_project_by_filepath(filepath)
	var active_project: Project = ProjectManager.get_active_project()
	
	# Project already open. Just switch to tab
	if project != null:
		if project != active_project:
			ProjectManager.make_project_active(project)
			_ui_titlebar.set_tab_active(project)
			_canvas.use_project(project)
		return
	
	# Remove/Replace active project if not changed and unsaved (default project)
	if active_project.filepath.empty() && !active_project.dirty:
		ProjectManager.remove_project(active_project)
		_ui_titlebar.remove_tab(active_project)
	
	# Create and open it
	project = ProjectManager.add_project(filepath)
	ProjectManager.make_project_active(project)
	_ui_titlebar.make_tab(project)
	_ui_titlebar.set_tab_active(project)
	_canvas.use_project(project)

# -------------------------------------------------------------------------------------------------
func _on_save_project() -> void:
	var active_project: Project = ProjectManager.get_active_project()
	if active_project.filepath.empty():
		_file_dialog.mode = FileDialog.MODE_SAVE_FILE
		_file_dialog.connect("file_selected", self, "_on_file_selected_to_save_project")
		_file_dialog.connect("popup_hide", self, "_on_file_dialog_closed")
		_file_dialog.popup_centered()
	else:
		_save_project(active_project)

# -------------------------------------------------------------------------------------------------
func _on_file_dialog_closed() -> void:
	_file_dialog.disconnect("file_selected", self, "_on_file_selected_to_save_project")
	_file_dialog.disconnect("popup_hide", self, "_on_file_dialog_closed")

# -------------------------------------------------------------------------------------------------
func _on_file_selected_to_save_project(filepath: String) -> void:
	var active_project: Project = ProjectManager.get_active_project()
	active_project.filepath = filepath
	_save_project(active_project)

# -------------------------------------------------------------------------------------------------
func _on_canvas_background_changed(color: Color) -> void:
	_canvas.set_background_color(color)

# -------------------------------------------------------------------------------------------------
func _on_undo_action() -> void:
	var project: Project = ProjectManager.get_active_project()
	if project.undo_redo.has_undo():
		project.undo_redo.undo()
		
# -------------------------------------------------------------------------------------------------
func _on_redo_action() -> void:
	var project: Project = ProjectManager.get_active_project()
	if project.undo_redo.has_redo():
		project.undo_redo.redo()

# -------------------------------------------------------------------------------------------------
func _on_InfiniteCanvas_mouse_entered():
	_canvas.enable()

# -------------------------------------------------------------------------------------------------
func _on_InfiniteCanvas_mouse_exited():
	_canvas.disable()
