@icon("res://Assets/Icons/text-block.png")
class_name TextBox extends Label

@export
var test : String

func _gui_input(event: InputEvent) -> void:
	print("GUI INPUT TEXTBOX")
