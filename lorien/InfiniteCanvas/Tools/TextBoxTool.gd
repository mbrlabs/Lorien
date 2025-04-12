class_name TextBoxTool 
extends CanvasTool

@export var _textBox: PackedScene
var textBoxInstance : TextBox2

signal text_box_tool_reset

enum State {
	CREATING,
	EDITING
}

@export
var _state = State.CREATING
@export
var _position : Vector2

func _ready() -> void:
	super()
	_state = State.CREATING

# -------------------------------------------------------------------------------------------------
func tool_event(event: InputEvent) -> void:
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed && _state == State.CREATING:
				_state = State.EDITING
				textBoxInstance = _textBox.instantiate()
				textBoxInstance.set_position(event.position)
				textBoxInstance.textBox_ok.connect(save_label)
				textBoxInstance.exclusive = true
				_position = _cursor.global_position
				add_child(textBoxInstance)
				var window_position : Vector2i = DisplayServer.window_get_position(0)
				textBoxInstance.get_window_id()
				print(DisplayServer.get_window_list()[1])
				DisplayServer.window_set_current_screen(DisplayServer.window_get_current_screen(0), DisplayServer.get_window_list()[1])

func save_label(value : String) -> void:
	var label : Label = Label.new()
	label.text = value
	label.set_position(_position)
	_canvas._create_textbox(label)
	_state = State.CREATING
	
# ------------------------------------------------------------------------------------------------
#func reset() -> void:
#	_state = State.CREATING
	#if textBoxInstance != null:
		#textBoxInstance.release_focus()
	#	textBoxInstance = null
#	print("Reset in TextBoxTool")
	
	
