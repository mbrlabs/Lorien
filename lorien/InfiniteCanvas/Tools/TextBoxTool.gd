class_name TextBoxTool 
extends CanvasTool

@export var _textBox: PackedScene
var textBoxInstance : TextBox2

signal text_box_tool_reset
signal show_textBoxDialog

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
				show_textBoxDialog.emit(_cursor.global_position)
