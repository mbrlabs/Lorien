extends Control

# -------------------------------------------------------------------------------------------------
const FILENAME = "C:/Users/mbrla/Desktop/lol.jabol"

onready var _jabol: JabolCanvas = $ViewportContainer/Viewport

# -------------------------------------------------------------------------------------------------
func _on_SaveButton_pressed():
	JabolIO.save_file(FILENAME, _jabol.lines)

# -------------------------------------------------------------------------------------------------
func _on_LoadButton_pressed():
	var result: Array = JabolIO.load_file(FILENAME)
	_jabol.clear()
	for line in result:
		_jabol.start_new_line(line.color)
		for point in line.points:
			_jabol.add_point(point)
		_jabol.end_line()
			
# -------------------------------------------------------------------------------------------------
func _on_ClearButton_pressed():
	_jabol.clear()
