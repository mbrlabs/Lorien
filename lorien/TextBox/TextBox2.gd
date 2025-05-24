class_name TextBox2 extends PanelContainer

@onready
var textEdit : TextEdit = $Panel/VBoxContainer/TextEdit
@onready
var saveButton : Button = $Panel/VBoxContainer/HBoxContainer/SaveButton

signal textBox_ok
signal textBox_cancel
var label_position : Vector2

func _on_save_button_pressed() -> void:
	textBox_ok.emit(textEdit.text, label_position)
	textEdit.text = ""
	visible = false

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		textEdit.text = ""
		visible = false

func _on_close_requested() -> void:
	textBox_cancel.emit()
	textEdit.text = ""
	visible = false

func _on_cancel_button_pressed() -> void:
	textBox_cancel.emit()
	textEdit.text = ""
	visible = false


func _on_panel_close_click() -> void:
	textBox_cancel.emit()
	textEdit.text = ""
	visible = false


func _on_visibility_changed() -> void:
	if visible:
		textEdit.grab_focus()
		
