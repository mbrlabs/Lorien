class_name TextBox extends Control

@onready var _textEdit : TextEdit = $VBoxContainer/PanelContainer/TextEdit
@onready var _label : Label = $VBoxContainer/PanelContainer/Label
@onready var _btn_ok : Button = $VBoxContainer/HBoxContainer/btn_ok
@onready var _btn_cancel : Button = $VBoxContainer/HBoxContainer/btn_cancel
@onready var _panel : PanelContainer = $VBoxContainer/PanelContainer

signal label_created

#func _on_text_edit_focus_exited() -> void:
	#_label.text = _textEdit.text
	#_textEdit.hide()
	#_label.show()
	#_btn_cancel.hide()
	#_btn_ok.hide()
	#_textEdit.release_focus()
	#label_created.emit()
	## Find Infinit canvas and give focus back

func _on_btn_ok_button_up() -> void:
	_label.text = _textEdit.text
	_textEdit.hide()
	_btn_cancel.hide()
	_btn_ok.hide()
	_label.show()
	#_textEdit.release_focus()
	#_label.grab_focus()
	label_created.emit()


func _on_btn_cancel_button_up() -> void:
	#_textEdit.release_focus()
	call_deferred("queue_free")
	label_created.emit()


func _on_text_edit_mouse_exited() -> void:
	print("Mouse Exited Text Edit")


func _on_panel_container_mouse_exited() -> void:
	print("Mouse left container")


func _on_v_box_container_mouse_exited() -> void:
	print("Mouse left VBox")


func _on_label_focus_entered() -> void:
	print("label focus entered")


func _on_label_focus_exited() -> void:
	print("label focus exited")
