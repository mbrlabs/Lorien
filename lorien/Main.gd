extends Control

# -------------------------------------------------------------------------------------------------
onready var _canvas: InfiniteCanvas = $InfiniteCanvas
onready var _statusbar: Statusbar = $Statusbar
onready var _menubar: Menubar = $Menubar
onready var _toolbar: Toolbar = $Toolbar
onready var _file_dialog: FileDialog = $FileDialog
onready var _save_as_dialog : FileDialog = $SaveAsDialog
onready var _about_dialog: WindowDialog = $AboutDialog
onready var _settings_dialog: WindowDialog = $SettingsDialog
onready var _main_menu: MainMenu = $MainMenu
onready var _generic_alert_dialog: AcceptDialog = $GenericAlertDialog
onready var _unsaved_changes_on_exit_dialog: WindowDialog = $UnsavedChangesOnExitDialog
onready var _background_color_picker: ColorPicker = $BackgroundColorPickerPopup/PanelContainer/ColorPicker

# -------------------------------------------------------------------------------------------------
func _ready():
	get_tree().set_auto_accept_quit(false)
	OS.set_window_title("Lorien v%s" % Config.VERSION_STRING)
	_canvas.set_background_color(Config.DEFAULT_CANVAS_COLOR)
	var docs_folder = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)
	_file_dialog.current_dir = Settings.get_value(Settings.GENERAL_DEFAULT_PROJECT_DIR, docs_folder)
	_save_as_dialog.current_dir = Settings.get_value(Settings.GENERAL_DEFAULT_PROJECT_DIR, docs_folder)
	
	# UI Signals
	_toolbar.connect("undo_action", self, "_on_undo_action")
	_toolbar.connect("redo_action", self, "_on_redo_action")
	_toolbar.connect("clear_canvas", self, "_on_clear_canvas")
	_toolbar.connect("open_project", self, "_on_open_project")
	_toolbar.connect("new_project", self, "_on_create_new_project")
	_toolbar.connect("save_project", self, "_on_save_project")
	_toolbar.connect("brush_color_changed", self, "_on_brush_color_changed")
	_toolbar.connect("brush_size_changed", self, "_on_brush_size_changed")
	_toolbar.connect("canvas_background_changed", self, "_on_canvas_background_changed")
	_toolbar.connect("tool_changed", self, "_on_tool_changed")
	
	_menubar.connect("create_new_project", self, "_on_create_new_project")
	_menubar.connect("project_selected", self, "_on_project_selected")
	_menubar.connect("project_closed", self, "_on_project_closed")
	
	_main_menu.connect("open_about_dialog", self, "_on_open_about_dialog")
	_main_menu.connect("open_settings_dialog", self, "_on_open_settings_dialog")
	_main_menu.connect("open_url", self, "_on_open_url")
	_main_menu.connect("save_as", self, "_save_as")
	
	_unsaved_changes_on_exit_dialog.connect("save_changes", self, "_on_exit_with_changes_saved")
	_unsaved_changes_on_exit_dialog.connect("discard_changes", self, "_on_exit_with_changes_discarded")
	_unsaved_changes_on_exit_dialog.connect("cancel_exit", self, "_on_exit_cancled")
	
	_save_as_dialog.connect("file_selected", self, "_on_save_as_confirmed")
	
	# Create the default project
	# TODO: once project managament is fully implemented, this should be replaced with last open (at exit) files
	_create_active_default_project()

# -------------------------------------------------------------------------------------------------
func _notification(what):
	if NOTIFICATION_WM_QUIT_REQUEST == what:
		if !_unsaved_changes_on_exit_dialog.visible:
			if ProjectManager.has_unsaved_changes():
				_unsaved_changes_on_exit_dialog.call_deferred("popup")
			else:
				get_tree().quit()

	elif NOTIFICATION_WM_FOCUS_IN == what && _canvas != null:
		if !_is_mouse_on_ui():
			yield(get_tree().create_timer(0.12), "timeout")
			_canvas.enable()
	elif NOTIFICATION_WM_FOCUS_OUT == what && _canvas != null:
		_canvas.disable()
		
# -------------------------------------------------------------------------------------------------
func _process(delta):
	_handle_shortcut_actions()
	_statusbar.set_stroke_count(_canvas.info.stroke_count)
	_statusbar.set_selected_strokes_count(_canvas.info.selected_lines)
	_statusbar.set_point_count(_canvas.info.point_count)
	_statusbar.set_pressure(_canvas.info.current_pressure)
	_statusbar.set_camera_position(_canvas.get_camera_offset())
	_statusbar.set_camera_zoom(_canvas.get_camera_zoom())
	_statusbar.set_fps(Engine.get_frames_per_second())
	
	# FIXME: i put this here to update dirty tabs; shuld only be called once
	var active_project: Project = ProjectManager.get_active_project()
	if active_project != null:
		_menubar.update_tab_title(active_project)

# -------------------------------------------------------------------------------------------------
func _handle_shortcut_actions() -> void:
	if !_is_dialog_open():
		if Input.is_action_just_pressed("shortcut_new_project"):
			_on_create_new_project()
		if Input.is_action_just_pressed("shortcut_open_project"):
			_toolbar._on_OpenFileButton_pressed() # FIXME that's pretty ugly
		if Input.is_action_just_pressed("shortcut_save_project"):
			_on_save_project()
		if Input.is_action_just_pressed("shortcut_undo"):
			_on_undo_action()
		if Input.is_action_just_pressed("shortcut_redo"):
			_on_redo_action()
		if Input.is_action_just_pressed("shortcut_brush_tool"):
			_toolbar.enable_tool(Types.Tool.BRUSH)
		if Input.is_action_just_pressed("shortcut_line_tool"):
			_toolbar.enable_tool(Types.Tool.LINE)
		if Input.is_action_just_pressed("shortcut_eraser_tool"):
			_toolbar.enable_tool(Types.Tool.ERASER)
		if Input.is_action_just_pressed("shortcut_colorpicker"):
			_toolbar.enable_tool(Types.Tool.COLOR_PICKER)
		if Input.is_action_just_pressed("shortcut_select_tool"):
			_toolbar.enable_tool(Types.Tool.SELECT)
		if Input.is_action_just_pressed("shortcut_move_tool"):
			_toolbar.enable_tool(Types.Tool.MOVE)

# -------------------------------------------------------------------------------------------------
func _make_project_active(project: Project) -> void:
	ProjectManager.make_project_active(project)
	_canvas.use_project(project)
	
	if !_menubar.has_tab(project):
		_menubar.make_tab(project)
	_menubar.set_tab_active(project)
	
	var default_canvas_color = Config.DEFAULT_CANVAS_COLOR.to_html()
	_background_color_picker.color = Color(project.meta_data.get(Serializer.CANVAS_COLOR, default_canvas_color))

# -------------------------------------------------------------------------------------------------
func _is_mouse_on_ui() -> bool:
	# FIXME: this is really long line.... It's also pretty hacky, so replace with something better sometime
	return Utils.is_mouse_in_control(_menubar) || Utils.is_mouse_in_control(_toolbar) || Utils.is_mouse_in_control(_statusbar)  || Utils.is_mouse_in_control(_file_dialog) || Utils.is_mouse_in_control(_about_dialog) || Utils.is_mouse_in_control(_settings_dialog)

# -------------------------------------------------------------------------------------------------
func _is_dialog_open() -> bool:
	return _file_dialog.visible || _about_dialog.visible || _settings_dialog.visible || _generic_alert_dialog.visible

# -------------------------------------------------------------------------------------------------
func _create_active_default_project() -> void:
	var default_project: Project = ProjectManager.add_project()
	_make_project_active(default_project)

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
	_menubar.update_tab_title(project)

# -------------------------------------------------------------------------------------------------
func _on_create_new_project() -> void:
	_create_active_default_project()

# -------------------------------------------------------------------------------------------------
func _on_project_selected(project_id: int) -> void:
	var project: Project = ProjectManager.get_project_by_id(project_id)
	_make_project_active(project)

# -------------------------------------------------------------------------------------------------
func _on_project_closed(project_id: int) -> void:
	var project: Project = ProjectManager.get_project_by_id(project_id)
	
	if project.dirty:
		# TODO
		_generic_alert_dialog.dialog_text = "Closing files with unsaved changes is not possible right now."
		_generic_alert_dialog.popup_centered()
		return
	
	# don't remove the default project
	if ProjectManager.get_project_count() == 1 && project.filepath.empty():
		return
	
	# Remove project
	ProjectManager.remove_project(project)
	_menubar.remove_tab(project)
	
	# choose new project
	if ProjectManager.get_project_count() == 0:
		_create_active_default_project()
	else:
		# TODO: i should choose the tab closest to the one closed; not just the first/last
		var new_project_id: int = _menubar.get_first_project_id()
		var new_project: Project = ProjectManager.get_project_by_id(new_project_id)
		_make_project_active(new_project)

# -------------------------------------------------------------------------------------------------
func _on_brush_color_changed(color: Color) -> void:
	_canvas.set_brush_color(color)

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
			_make_project_active(project)
		return
	
	# Remove/Replace active project if not changed and unsaved (default project)
	if active_project.filepath.empty() && !active_project.dirty:
		ProjectManager.remove_project(active_project)
		_menubar.remove_tab(active_project)
	
	# Create and open it
	project = ProjectManager.add_project(filepath)
	_make_project_active(project)

# -------------------------------------------------------------------------------------------------
func _on_save_project() -> void:
	var active_project: Project = ProjectManager.get_active_project()
	if active_project.filepath.empty():
		_file_dialog.invalidate()
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
func _on_tool_changed(tool_type: int) -> void:
	match tool_type:
		Types.Tool.BRUSH, Types.Tool.ERASER, Types.Tool.LINE, Types.Tool.SELECT, Types.Tool.MOVE: _canvas.use_tool(tool_type)
		_:
			_generic_alert_dialog.dialog_text = "Not implemented yet."
			_generic_alert_dialog.popup_centered()

# -------------------------------------------------------------------------------------------------
func _on_exit_with_changes_saved() -> void:
	if ProjectManager.has_unsaved_projects():
		_generic_alert_dialog.dialog_text = "Auto-saving not yet implemented for file \"Untitled\".\nPlease save it manually."
		_generic_alert_dialog.popup_centered()
	else:
		ProjectManager.save_all_projects()
		get_tree().quit()

# -------------------------------------------------------------------------------------------------
func _on_exit_with_changes_discarded() -> void:
	get_tree().quit()
	
# -------------------------------------------------------------------------------------------------
func _on_exit_cancled() -> void:
	_unsaved_changes_on_exit_dialog.hide()

# -------------------------------------------------------------------------------------------------
func _on_open_about_dialog() -> void:
	_about_dialog.popup()

# -------------------------------------------------------------------------------------------------
func _on_open_settings_dialog() -> void:
	_settings_dialog.popup()

# -------------------------------------------------------------------------------------------------
func _on_open_url(url: String) -> void:
	OS.shell_open(url)
	yield(get_tree().create_timer(0.1), "timeout")
	_canvas.disable()

# -------------------------------------------------------------------------------------------------
func _on_InfiniteCanvas_mouse_entered():
	_canvas.enable()

# -------------------------------------------------------------------------------------------------
func _on_InfiniteCanvas_mouse_exited():
	_canvas.disable()

# --------------------------------------------------------------------------------------------------
func _on_save_as_confirmed(path: String):
	match path.get_extension():
		"png":
			var image : Image = _canvas._viewport.get_texture().get_data()
			image.flip_y()
			image.save_png(path)

# --------------------------------------------------------------------------------------------------
func _save_as(format: String) -> void:
	match format:
		"png":
			_save_as_dialog.filters = ["*.png ; Portable Network Graphics"]
	_save_as_dialog.current_file = Utils.return_timestamp_string() + "." + format
	_save_as_dialog.popup()
