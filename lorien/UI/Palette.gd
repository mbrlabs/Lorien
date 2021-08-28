extends Control

class_name Palette
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

const DefaultButtonNumber: int = 18
export var _palette_button: PackedScene = preload("res://UI/Components/PaletteButton.tscn")
export var _empty_palette_style: StyleBoxFlat = preload("res://UI/Themes/PaletteButton.tres")
onready var _button_grid: GridContainer = $ScrollContainer/GridContainer
#add default color array for palette

func _ready():
	for i in range(0, DefaultButtonNumber):
		_button_grid.add_child(_palette_button.instance())

	for i in range(0, DefaultButtonNumber):
		var _current_button: Button = _button_grid.get_child(i).get_child(0)
		#print(_current_button.get_path())
		_current_button.connect("pressed", self, "_on_button_press", [_current_button])	
	
	#add default colors
func _on_button_press(var _pressed_button: Node): 
	if (_pressed_button.get("custom_styles/normal") == _empty_palette_style):
		print("Hello")
		#replace empty style with new style, set color to brush color
	else: 
		print("Goodbye")
		#set color picker and brush color to style color 


	#var _new_button_style = _empty_palette_style.duplicate()
	#_new_button_style.set_bg_color("#4287f5")
	#_button_grid.get_child(0).get_child(0).set("custom_styles/normal", _new_button_style)
# Called when the node enters the scene tree for the first time.
#func _ready():
	#for i in range(0,18):
	#	var _palette_button = PaletteButton.instance()
	#	_button_grid.add_child(_palette_button)
	#var _new_button_style = _palette_button_style.duplicate()
	#_new_button_style.set_bg_color("#bada55")
	#var _new_button_focus = _new_button_style.duplicate()
	#_new_button_focus.set_shadow_color("#dee8cf")
	#_new_button_focus.set_shadow_size(2)
	#print((_button_grid.get_child(1)).get_child(0).get_path())
	#((_button_grid.get_child(1)).get_child(0))["custom_styles/normal"].bg_color = Color("#bada55")
	#((_button_grid.get_child(1)).get_child(0)).set("custom_styles/normal", _new_button_style)
	#((_button_grid.get_child(1)).get_child(0)).set("custom_styles/hover", _new_button_style)
	#((_button_grid.get_child(1)).get_child(0)).set("custom_styles/pressed", _new_button_style)
	#((_button_grid.get_child(1)).get_child(0)).set("custom_styles/focus", _new_button_focus)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
