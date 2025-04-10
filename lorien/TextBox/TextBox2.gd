class_name TextBox2 extends PopupPanel

@onready
var textEdit : TextEdit = $Control/VBoxContainer/TextEdit

signal textBox_ok
signal textBox_cancel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_save_button_pressed() -> void:
	textBox_ok.emit(textEdit.text)
	queue_free()
