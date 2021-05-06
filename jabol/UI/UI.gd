extends Control
class_name UI

# -------------------------------------------------------------------------------------------------
signal window_borders_entered
signal window_borders_exited

signal ui_entered
signal ui_exited

# -------------------------------------------------------------------------------------------------
onready var statusbar: UIStatusbar = $UIStatusBar
onready var tools: UITools = $UITools
onready var titlebar: UITitlebar = $UITitlebar

onready var _border_top: Control = $WindowBorders/TopWindowBorder
onready var _border_bottom: Control = $WindowBorders/BottomWindowBorder
onready var _border_left: Control = $WindowBorders/LeftWindowBorder
onready var _border_right: Control = $WindowBorders/RightWindowBorder

var _mouse_in_tools := false
var _mouse_in_titlebar := false
var _mouse_in_statusbar := false
var _mouse_in_window_border := false

# -------------------------------------------------------------------------------------------------
func _ready():
	# Window borders: mouse enter/exit events
	_border_top.connect("mouse_entered", self, "_on_mouse_entered_window_border")
	_border_top.connect("mouse_exited", self, "_on_mouse_exited_window_border")
	_border_bottom.connect("mouse_entered", self, "_on_mouse_entered_window_border")
	_border_bottom.connect("mouse_exited", self, "_on_mouse_exited_window_border")
	_border_left.connect("mouse_entered", self, "_on_mouse_entered_window_border")
	_border_left.connect("mouse_exited", self, "_on_mouse_exited_window_border")
	_border_right.connect("mouse_entered", self, "_on_mouse_entered_window_border")
	_border_right.connect("mouse_exited", self, "_on_mouse_exited_window_border")
	
	# Window borders: gui events (like click and drag)
	_border_top.connect("gui_input", self, "_on_top_window_border_gui_input")
	_border_bottom.connect("gui_input", self, "_on_bottom_window_border_gui_input")
	_border_left.connect("gui_input", self, "_on_left_window_border_gui_input")
	_border_right.connect("gui_input", self, "_on_right_window_border_gui_input")
	
	# Titlebar: mouse enter/exit events
	titlebar.connect("mouse_entered", self, "_on_titlebar_mouse_entered")
	titlebar.connect("mouse_exited", self, "_on_titlebar_mouse_exited")
	
	# Tools: mouse enter/exit events
	tools.connect("mouse_entered", self, "_on_tools_mouse_entered")
	tools.connect("mouse_exited", self, "_on_tools_mouse_exited")
	
	# Statusbar: mouse enter/exit events
	statusbar.connect("mouse_entered", self, "_on_statusbar_mouse_entered")
	statusbar.connect("mouse_exited", self, "_on_statusbar_mouse_exited")

# -------------------------------------------------------------------------------------------------
func _notify_about_mouse_state() -> void:
	if _mouse_in_statusbar || _mouse_in_titlebar || _mouse_in_tools || _mouse_in_window_border:
		emit_signal("ui_entered")
	else:
		emit_signal("ui_exited")

# -------------------------------------------------------------------------------------------------
func _on_top_window_border_gui_input(event: InputEvent):
	if Input.is_mouse_button_pressed(BUTTON_LEFT) && event is InputEventMouseMotion:
		OS.window_position.y += event.relative.y
		OS.window_size.y -= event.relative.y

# -------------------------------------------------------------------------------------------------
func _on_bottom_window_border_gui_input(event: InputEvent):
	if Input.is_mouse_button_pressed(BUTTON_LEFT) && event is InputEventMouseMotion:
		OS.window_size.y += event.relative.y

# -------------------------------------------------------------------------------------------------
func _on_left_window_border_gui_input(event: InputEvent):
	if Input.is_mouse_button_pressed(BUTTON_LEFT) && event is InputEventMouseMotion:
		OS.window_position.x += event.relative.x
		OS.window_size.x -= event.relative.x

# -------------------------------------------------------------------------------------------------
func _on_right_window_border_gui_input(event: InputEvent):
	if Input.is_mouse_button_pressed(BUTTON_LEFT) && event is InputEventMouseMotion:
		OS.window_size.x += event.relative.x

# -------------------------------------------------------------------------------------------------
func _on_mouse_entered_window_border() -> void:
	_mouse_in_window_border = true
	emit_signal("window_borders_entered")
	_notify_about_mouse_state()

# -------------------------------------------------------------------------------------------------
func _on_mouse_exited_window_border() -> void:
	_mouse_in_window_border = false
	emit_signal("window_borders_exited")
	_notify_about_mouse_state()

# -------------------------------------------------------------------------------------------------
func _on_titlebar_mouse_entered() -> void:
	_mouse_in_titlebar = true
	_notify_about_mouse_state()

# -------------------------------------------------------------------------------------------------
func _on_titlebar_mouse_exited():
	_mouse_in_titlebar = false
	_notify_about_mouse_state()

# -------------------------------------------------------------------------------------------------
func _on_tools_mouse_entered() -> void:
	_mouse_in_tools = true
	_notify_about_mouse_state()

# -------------------------------------------------------------------------------------------------
func _on_tools_mouse_exited() -> void:
	_mouse_in_tools = false
	_notify_about_mouse_state()

# -------------------------------------------------------------------------------------------------	
func _on_statusbar_mouse_entered() -> void:
	_mouse_in_statusbar = true
	_notify_about_mouse_state()

# -------------------------------------------------------------------------------------------------	
func _on_statusbar_mouse_exited() -> void:
	_mouse_in_statusbar = false
	_notify_about_mouse_state()

