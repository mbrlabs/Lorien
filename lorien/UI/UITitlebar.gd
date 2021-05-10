extends Panel
class_name UITitlebar

# -------------------------------------------------------------------------------------------------
const UI_TAB = preload("res://UI/Components/UITab.tscn")

# -------------------------------------------------------------------------------------------------
signal close_requested
signal window_maximized
signal window_demaximized
signal window_minimized
signal file_tab_selected
signal file_tab_close_requested

# -------------------------------------------------------------------------------------------------
onready var _file_tabs: HBoxContainer = $Left/Tabs
export var _menu_popup_path: NodePath
var _mouse_pressed := false
var _mouse_draging := false
var _drag_offset: Vector2
var _active_file_tab: UITab

# -------------------------------------------------------------------------------------------------
func _ready() -> void:
	var tab := add_tab("Untitled", "")
	set_tab_active(tab)

# -------------------------------------------------------------------------------------------------
func _process(delta: float) -> void:
	if _mouse_pressed && _mouse_draging:
		if OS.window_maximized && Utils.get_native_mouse_position_on_screen().y > 100:
			OS.window_maximized = false
			emit_signal("window_demaximized")
		else:
			var mouse_pos := get_tree().root.get_viewport().get_mouse_position()
			var win_pos :=  OS.window_position
			OS.window_position = mouse_pos + win_pos + _drag_offset

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
func _on_CloseButton_pressed():
	emit_signal("close_requested")

# -------------------------------------------------------------------------------------------------
func _on_MaximizeButton_pressed() -> void:
	if OS.window_maximized:
		OS.window_maximized = false
		emit_signal("window_demaximized")
	else:
		OS.window_maximized = true
		emit_signal("window_maximized")

# -------------------------------------------------------------------------------------------------
func _on_MinimizeButton_pressed() -> void:
	OS.window_minimized = true
	emit_signal("window_minimized")

# -------------------------------------------------------------------------------------------------
func _on_UITitlebar_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if !event.pressed:
			_mouse_draging = false
		
		if event.button_index == BUTTON_LEFT:
			if event.doubleclick:
				_on_MaximizeButton_pressed()
			else:
				_drag_offset = OS.window_position - (event.global_position + OS.window_position)
				_mouse_pressed = event.pressed
	elif event is InputEventMouseMotion:
		if _mouse_pressed:
			_mouse_draging = true

# -------------------------------------------------------------------------------------------------
func _on_Logo_pressed():
	var popup_panel: PopupMenu = get_node(_menu_popup_path)
	popup_panel.popup()
