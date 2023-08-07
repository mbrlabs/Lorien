extends Control

# -------------------------------------------------------------------------------------------------
onready var _canvas: InfiniteCanvas = $InfiniteCanvas
onready var _canvas_grid: InfiniteCanvasGrid = $InfiniteCanvas/Viewport/Grid
onready var _statusbar: Statusbar = $Statusbar
onready var _menubar: Menubar = $Topbar/Menubar
onready var _toolbar: Toolbar = $Topbar/Toolbar
onready var _file_dialog: FileDialog = $FileDialog
onready var _export_dialog : FileDialog = $ExportDialog
onready var _about_dialog: WindowDialog = $AboutDialog
onready var _settings_dialog: WindowDialog = $SettingsDialog
onready var _brush_color_picker: ColorPalettePicker = $BrushColorPicker
onready var _main_menu: MainMenu = $MainMenu
onready var _generic_alert_dialog: AcceptDialog = $GenericAlertDialog
onready var _exit_dialog: WindowDialog = $ExitDialog
onready var _unsaved_changes_dialog: WindowDialog = $UnsavedChangesDialog
onready var _background_color_picker: ColorPicker = $BackgroundColorPickerPopup/PanelContainer/ColorPicker
onready var _new_palette_dialog: NewPaletteDialog = $NewPaletteDialog
onready var _delete_palette_dialog: DeletePaletteDialog = $DeletePaletteDialog
onready var _edit_palette_dialog: EditPaletteDialog = $EditPaletteDialog

var _ui_visible := true 
var _player_enabled := false

# -------------------------------------------------------------------------------------------------
func _ready():
	# Init stuff
	randomize()
	Engine.target_fps = Settings.get_value(Settings.RENDERING_FOREGROUND_FPS, Config.DEFAULT_FOREGROUND_FPS)
	OS.set_window_title("Lorien v%s" % Config.VERSION_STRING)
	get_tree().set_auto_accept_quit(false)

	_canvas.set_background_color(Config.DEFAULT_CANVAS_COLOR)
	var docs_folder = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)
	_file_dialog.current_dir = Settings.get_value(Settings.GENERAL_DEFAULT_PROJECT_DIR, docs_folder)
	_export_dialog.current_dir = Settings.get_value(Settings.GENERAL_DEFAULT_PROJECT_DIR, docs_folder)
	
	# Signals
	get_tree().connect("files_dropped", self, "_on_files_dropped")
	
	_toolbar.connect("undo_action", self, "_on_undo_action")
	_toolbar.connect("redo_action", self, "_on_redo_action")
	_toolbar.connect("clear_canvas", self, "_on_clear_canvas")
	_toolbar.connect("open_project", self, "_on_open_project")
	_toolbar.connect("toggle_brush_color_picker", self, "_on_toggle_brush_color_picker")
	_toolbar.connect("new_project", self, "_on_create_new_project")
	_toolbar.connect("save_project", self, "_on_save_project")
	_toolbar.connect("brush_size_changed", self, "_on_brush_size_changed")
	_toolbar.connect("canvas_background_changed", self, "_on_canvas_background_changed")
	_toolbar.connect("tool_changed", self, "_on_tool_changed")
	_toolbar.connect("grid_enabled", self, "_on_grid_enabled")
	
	_menubar.connect("create_new_project", self, "_on_create_new_project")
	_menubar.connect("project_selected", self, "_on_project_selected")
	_menubar.connect("project_closed", self, "_on_project_closed")
	
	_main_menu.connect("open_about_dialog", self, "_on_open_about_dialog")
	_main_menu.connect("open_settings_dialog", self, "_on_open_settings_dialog")
	_main_menu.connect("open_url", self, "_on_open_url")
	_main_menu.connect("export_svg", self, "_export_svg")
	_main_menu.connect("open_project", self, "_on_open_project")
	_main_menu.connect("save_project", self, "_on_save_project")
	_main_menu.connect("save_project_as", self, "_on_save_project_as")
	
	_exit_dialog.connect("save_changes", self, "_on_exit_with_changes_saved")
	_exit_dialog.connect("discard_changes", self, "_on_exit_with_changes_discarded")
	_unsaved_changes_dialog.connect("save_changes", self, "_on_close_file_with_changes_saved")
	_unsaved_changes_dialog.connect("discard_changes", self, "_on_close_file_with_changes_discarded")
	
	_export_dialog.connect("file_selected", self, "_on_export_confirmed")
	
	_settings_dialog.connect("ui_scale_changed", self, "_on_scale_changed")
	_settings_dialog.connect("grid_size_changed", self, "_on_grid_size_changed")
	
	
	# Initialize scale
	_on_scale_changed()
	
	# Create the default project
	_create_active_default_project()
	
	# Open project passed as CLI argument
	for arg in OS.get_cmdline_args():
		if Utils.is_valid_lorien_file(arg):
			_on_open_project(arg)
	
	# Apply state from previous session
	_apply_state()

# -------------------------------------------------------------------------------------------------
func _notification(what):
	if NOTIFICATION_WM_QUIT_REQUEST == what:
		if !_exit_dialog.visible:
			if ProjectManager.has_unsaved_changes():
				_exit_dialog.call_deferred("popup")
			else:
				_save_state()
				 # we have to wait a bit before exiting; otherwise the changes might not be persisted correctly.
				yield(get_tree().create_timer(0.12), "timeout")
				get_tree().quit()

	elif NOTIFICATION_WM_FOCUS_IN == what:
		Engine.target_fps = Settings.get_value(Settings.RENDERING_FOREGROUND_FPS, Config.DEFAULT_FOREGROUND_FPS)
		if !_is_mouse_on_ui() && _canvas != null && !is_dialog_open():
			yield(get_tree().create_timer(0.12), "timeout")
			_canvas.enable()
	elif NOTIFICATION_WM_FOCUS_OUT == what:
		Engine.target_fps = Settings.get_value(Settings.RENDERING_BACKGROUND_FPS, Config.DEFAULT_BACKGROUND_FPS)
		if _canvas != null:
			_canvas.disable()

# -------------------------------------------------------------------------------------------------
func _exit_tree():
	_menubar.remove_all_tabs()
	ProjectManager.remove_all_projects()

# -------------------------------------------------------------------------------------------------
func _process(delta):
	_statusbar.set_stroke_count(_canvas.info.stroke_count)
	_statusbar.set_point_count(_canvas.info.point_count)
	_statusbar.set_pressure(_canvas.info.current_pressure)
	_statusbar.set_camera_position(_canvas.get_camera_offset())
	_statusbar.set_camera_zoom(_canvas.get_camera_zoom())
	_statusbar.set_fps(Engine.get_frames_per_second())
	
	# Update tab title
	var active_project: Project = ProjectManager.get_active_project()
	if active_project != null:
		_menubar.update_tab_title(active_project)

# -------------------------------------------------------------------------------------------------
func _unhandled_input(event):
	if ! is_dialog_open():
		if Utils.event_pressed_bug_workaround("toggle_player", event):
			_toggle_player()
		
		if !_player_enabled:
			if Utils.event_pressed_bug_workaround("shortcut_new_project", event):
				_on_create_new_project()
			elif Utils.event_pressed_bug_workaround("shortcut_open_project", event):
				_toolbar._on_OpenFileButton_pressed()
			elif Utils.event_pressed_bug_workaround("shortcut_save_project", event):
				_on_save_project()
			elif Utils.event_pressed_bug_workaround("shortcut_export_project", event):
				_export_svg()
			elif Utils.event_pressed_bug_workaround("shortcut_undo", event):
				_on_undo_action()
			elif Utils.event_pressed_bug_workaround("shortcut_redo", event):
				_on_redo_action()
			elif Utils.event_pressed_bug_workaround("center_canvas_to_mouse", event):
				_canvas.center_to_mouse()
			elif Utils.event_pressed_bug_workaround("shortcut_brush_tool", event):
				_toolbar.enable_tool(Types.Tool.BRUSH)
			elif Utils.event_pressed_bug_workaround("shortcut_rectangle_tool", event):
				_toolbar.enable_tool(Types.Tool.RECTANGLE)
			elif Utils.event_pressed_bug_workaround("shortcut_circle_tool", event):
				_toolbar.enable_tool(Types.Tool.CIRCLE)
			elif Utils.event_pressed_bug_workaround("shortcut_line_tool", event):
				_toolbar.enable_tool(Types.Tool.LINE)
			elif Utils.event_pressed_bug_workaround("shortcut_eraser_tool", event):
				_toolbar.enable_tool(Types.Tool.ERASER)
			elif Utils.event_pressed_bug_workaround("shortcut_select_tool", event):
				_toolbar.enable_tool(Types.Tool.SELECT)
			elif Utils.event_pressed_bug_workaround("toggle_distraction_free_mode", event):
				_toggle_distraction_free_mode()
			elif Utils.event_pressed_bug_workaround("toggle_fullscreen", event):
				_toggle_fullscreen()

# -------------------------------------------------------------------------------------------------
func _toggle_player() -> void:
	_player_enabled = !_player_enabled
	_canvas.enable_colliders(_player_enabled)
	_canvas.enable_player(_player_enabled)

# -------------------------------------------------------------------------------------------------
func _save_state() -> void:
	# Open projects
	var open_projects := Array()
	for project in ProjectManager.get_open_projects():
		open_projects.append(project.filepath)
	StatePersistence.set_value(StatePersistence.OPEN_PROJECTS, open_projects)
	
	# Active project
	var active_project_path := ProjectManager.get_active_project().filepath
	StatePersistence.set_value(StatePersistence.ACTIVE_PROJECT, active_project_path)
	
	# Window related stuff
	StatePersistence.set_value(StatePersistence.WINDOW_SIZE, OS.window_size)
	StatePersistence.set_value(StatePersistence.WINDOW_MAXIMIZED, OS.window_maximized)

# -------------------------------------------------------------------------------------------------
func _apply_state() -> void:
	# Window related stuff
	var is_maximized: bool = StatePersistence.get_value(StatePersistence.WINDOW_MAXIMIZED, false)
	var default_win_size := Vector2(1440, 810)
	var win_size: Vector2 = StatePersistence.get_value(StatePersistence.WINDOW_SIZE, default_win_size)
	
	if is_maximized:
		OS.window_maximized = true
	else:
		OS.window_size = win_size
		OS.center_window()
	yield(get_tree().create_timer(0.12), "timeout")
	
	# Open projects
	var open_projects: Array = StatePersistence.get_value(StatePersistence.OPEN_PROJECTS, Array())
	for path in open_projects:
		if path is String:
			_on_open_project(path)
			
	# Active project
	var active_project_path: String = StatePersistence.get_value(StatePersistence.ACTIVE_PROJECT, "")
	var active_project := ProjectManager.get_open_project_by_filepath(active_project_path)
	if active_project != null:
		_make_project_active(active_project)

# -------------------------------------------------------------------------------------------------
func _toggle_distraction_free_mode() -> void:
	_ui_visible = !_ui_visible
	_menubar.get_parent().visible = _ui_visible
	_menubar.visible = _ui_visible
	_statusbar.visible = _ui_visible
	_toolbar.visible = _ui_visible

# -------------------------------------------------------------------------------------------------
func _on_files_dropped(files: PoolStringArray, screen: int) -> void:
	for file in files:
		if Utils.is_valid_lorien_file(file):
			_on_open_project(file)

# -------------------------------------------------------------------------------------------------
func _make_project_active(project: Project) -> void:
	ProjectManager.make_project_active(project)
	_canvas.use_project(project)
	
	if !_menubar.has_tab(project):
		_menubar.make_tab(project)
	_menubar.set_tab_active(project)
	
	# TODO: find a better way to apply the color to the picker
	var default_canvas_color = Config.DEFAULT_CANVAS_COLOR.to_html()
	_background_color_picker.color = Color(project.meta_data.get(ProjectMetadata.CANVAS_COLOR, default_canvas_color))

# -------------------------------------------------------------------------------------------------
func _is_mouse_on_ui() -> bool:
	var on_ui := Utils.is_mouse_in_control(_menubar)
	on_ui = on_ui || Utils.is_mouse_in_control(_toolbar)
	on_ui = on_ui || Utils.is_mouse_in_control(_statusbar)
	on_ui = on_ui || Utils.is_mouse_in_control(_file_dialog)
	on_ui = on_ui || Utils.is_mouse_in_control(_about_dialog)
	on_ui = on_ui || Utils.is_mouse_in_control(_settings_dialog)
	on_ui = on_ui || Utils.is_mouse_in_control(_brush_color_picker)
	on_ui = on_ui || Utils.is_mouse_in_control(_new_palette_dialog)
	on_ui = on_ui || Utils.is_mouse_in_control(_edit_palette_dialog)
	on_ui = on_ui || Utils.is_mouse_in_control(_delete_palette_dialog)
	return on_ui

# -------------------------------------------------------------------------------------------------
func is_dialog_open() -> bool:
	var open := _file_dialog.visible || _about_dialog.visible
	open = open || (_settings_dialog.visible || _generic_alert_dialog.visible)
	open = open || (_new_palette_dialog.visible || _edit_palette_dialog.visible || _delete_palette_dialog.visible)
	return open

# -------------------------------------------------------------------------------------------------
func _create_active_default_project() -> void:
	var default_project: Project = ProjectManager.add_project()
	_make_project_active(default_project)

# -------------------------------------------------------------------------------------------------
func _save_project(project: Project) -> void:
	var meta_data = ProjectMetadata.make_dict(_canvas)
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
	# Ask the user to save changes
	var project: Project = ProjectManager.get_project_by_id(project_id)
	if project.dirty:
		_unsaved_changes_dialog.project_ids.clear()
		_unsaved_changes_dialog.project_ids.append(project_id)
		_unsaved_changes_dialog.popup_centered()
	else:
		_close_project(project_id)

# -------------------------------------------------------------------------------------------------
func _close_project(project_id: int) -> void:
	var active_project: Project = ProjectManager.get_active_project()
	var project: Project = ProjectManager.get_project_by_id(project_id)
	var active_project_closed := active_project.id == project.id
	
	# Remove project
	ProjectManager.remove_project(project)
	_menubar.remove_tab(project)
	
	# Choose new project if active tab was closed
	if active_project_closed:
		if ProjectManager.get_project_count() == 0:
			_create_active_default_project()
		else:
			var new_project_id: int = _menubar.get_first_project_id()
			var new_project: Project = ProjectManager.get_project_by_id(new_project_id)
			_make_project_active(new_project)

# -------------------------------------------------------------------------------------------------
func _show_autosave_not_implemented_alert() -> void:
	_generic_alert_dialog.dialog_text = tr("ERROR_AUTOSAVE_NOT_IMPLEMENTED")
	_generic_alert_dialog.popup_centered()

# -------------------------------------------------------------------------------------------------
func _toggle_fullscreen():
	OS.set_window_fullscreen(!OS.window_fullscreen)
	_toolbar.set_fullscreen_toggle(OS.window_fullscreen)

# -------------------------------------------------------------------------------------------------
func _on_brush_color_changed(color: Color) -> void:
	_canvas.set_brush_color(color)

# -------------------------------------------------------------------------------------------------
func _on_brush_size_changed(size: int) -> void:
	_canvas.set_brush_size(size)

# -------------------------------------------------------------------------------------------------
func _on_grid_size_changed(size: int) -> void:
	_canvas_grid.set_grid_size(size)

# -------------------------------------------------------------------------------------------------
func _on_clear_canvas() -> void:
	_canvas.clear() 

# -------------------------------------------------------------------------------------------------
func _on_open_project(filepath: String) -> bool:
	# Check if file exists
	var file := File.new()
	if !file.file_exists(filepath):
		return false
	
	var project: Project = ProjectManager.get_open_project_by_filepath(filepath)
	var active_project: Project = ProjectManager.get_active_project()
	
	# Project already open. Just switch to tab
	if project != null:
		if project != active_project:
			_make_project_active(project)
		return true
	
	# Remove/Replace active project if not changed and unsaved (default project)
	if active_project.filepath.empty() && !active_project.dirty:
		ProjectManager.remove_project(active_project)
		_menubar.remove_tab(active_project)
	
	# Create and open it
	project = ProjectManager.add_project(filepath)
	_make_project_active(project)
	
	return true
	
# -------------------------------------------------------------------------------------------------
func _on_save_project_as() -> void:
	var active_project: Project = ProjectManager.get_active_project()
	_canvas.disable()
	_file_dialog.mode = FileDialog.MODE_SAVE_FILE
	_file_dialog.invalidate()
	_file_dialog.current_file = active_project.filepath.get_file()
	_file_dialog.connect("file_selected", self, "_on_file_selected_to_save_project")
	_file_dialog.connect("popup_hide", self, "_on_file_dialog_closed")
	_file_dialog.popup_centered()

# -------------------------------------------------------------------------------------------------
func _on_save_project() -> void:
	var active_project: Project = ProjectManager.get_active_project()
	if active_project.filepath.empty():
		_canvas.disable()
		_file_dialog.mode = FileDialog.MODE_SAVE_FILE
		_file_dialog.invalidate()
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
	var project: Project = ProjectManager.get_active_project()
	if project != null:
		project.meta_data[ProjectMetadata.CANVAS_COLOR] = color.to_html()
		project.dirty = true

# -------------------------------------------------------------------------------------------------
func _on_grid_enabled(enabled: bool) -> void:
	_canvas.enable_grid(enabled)

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
	_canvas.use_tool(tool_type)

# -------------------------------------------------------------------------------------------------
func _on_exit_with_changes_saved(project_ids: Array) -> void:
	if ProjectManager.has_unsaved_projects():
		_show_autosave_not_implemented_alert()
	else:
		ProjectManager.save_all_projects()
		get_tree().quit()

# -------------------------------------------------------------------------------------------------
func _on_exit_with_changes_discarded(project_ids: Array) -> void:
	get_tree().quit()

# -------------------------------------------------------------------------------------------------
func _on_close_file_with_changes_saved(project_ids: Array) -> void:
	for id in project_ids:
		var project: Project = ProjectManager.get_project_by_id(id)
		if project.filepath.empty():
			_show_autosave_not_implemented_alert()
		else:
			ProjectManager.save_project(project)
			_close_project(id)
	_unsaved_changes_dialog.hide()

# -------------------------------------------------------------------------------------------------
func _on_close_file_with_changes_discarded(project_ids: Array) -> void:
	for id in project_ids:
		_close_project(id)
	_unsaved_changes_dialog.hide()

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
func _on_export_confirmed(path: String):
	match path.get_extension():
		"svg":
			var project: Project = ProjectManager.get_active_project()
			if project != null:
				var background := _canvas.get_background_color()
				var svg := SvgExporter.new()
				svg.export_svg(project.strokes, background, path)
		_:
			printerr("Unsupported format")

# --------------------------------------------------------------------------------------------------
func _export_svg() -> void:
	_export_dialog.filters = ["*.svg ; Scalable Vector graphics"]
	_export_dialog.current_file = "lorien.svg"
	_export_dialog.popup()

# --------------------------------------------------------------------------------------------------
func _on_toggle_brush_color_picker() -> void:
	_brush_color_picker.toggle()

# --------------------------------------------------------------------------------------------------
func _on_BrushColorPicker_color_changed(color: Color) -> void:
	_toolbar.set_brush_color(color)
	_canvas.set_brush_color(color)

# --------------------------------------------------------------------------------------------------
func _on_BrushColorPicker_closed() -> void:
	if !_is_mouse_on_ui():
		_canvas.enable()

# --------------------------------------------------------------------------------------------------
func _on_NewPaletteDialog_new_palette_created(palette: Palette) -> void:
	PaletteManager.set_active_palette(palette)
	_brush_color_picker.update_palettes()

# --------------------------------------------------------------------------------------------------
func _update_brush_color() -> void:
	var color_index := min(_brush_color_picker.get_active_color_index(), PaletteManager.get_active_palette().colors.size()-1)
	_brush_color_picker.update_palettes(color_index)
	_toolbar.set_brush_color(_brush_color_picker.get_active_color())
	_canvas.set_brush_color(_brush_color_picker.get_active_color())

# --------------------------------------------------------------------------------------------------
func _on_EditPaletteDialog_palette_changed() -> void:
	_update_brush_color()

# --------------------------------------------------------------------------------------------------
func _on_DeletePaletteDialog_palette_deleted() -> void:
	_update_brush_color()

# --------------------------------------------------------------------------------------------------
func _on_scale_changed() -> void:
	var auto_scale: int = Settings.get_value(Settings.APPEARANCE_UI_SCALE_MODE, Config.DEFAULT_UI_SCALE_MODE)
	var scale: float
	match auto_scale:
		Types.UIScale.AUTO:   scale = _get_platform_ui_scale()
		Types.UIScale.CUSTOM: scale = Settings.get_value(Settings.APPEARANCE_UI_SCALE, Config.DEFAULT_UI_SCALE)
	scale = clamp(scale, _settings_dialog.get_min_ui_scale(), _settings_dialog.get_max_ui_scale())

	_canvas.set_canvas_scale(scale)
	get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_DISABLED, SceneTree.STRETCH_ASPECT_IGNORE, Vector2(0,0), scale)
	OS.min_window_size = Config.MIN_WINDOW_SIZE * scale

# --------------------------------------------------------------------------------------------------
func _get_platform_ui_scale() -> float:
	var platform: String = OS.get_name()
	var scale: float
	match platform:
		"OSX":     scale = OS.get_screen_scale()
		"Windows": scale = OS.get_screen_dpi() / 96.0
		_:         scale = _get_general_ui_scale()
	return scale

# --------------------------------------------------------------------------------------------------
func _get_general_ui_scale() -> float:
	# Adapted from Godot EditorSettings::get_auto_display_scale()
	# https://github.com/godotengine/godot/blob/3.x/editor/editor_settings.cpp
	var smallest_dimension: int = min(OS.get_screen_size().x, OS.get_screen_size().y)
	if OS.get_screen_dpi() >= 192 && smallest_dimension >= 1400:
		return Config.DEFAULT_UI_SCALE * 2
	elif smallest_dimension >= 1700:
		return Config.DEFAULT_UI_SCALE * 1.5
	return Config.DEFAULT_UI_SCALE
