extends Node2D

#
# This is used to draw debug stuff like bounding boxes etc.
#

# -------------------------------------------------------------------------------------------------
var _bounding_boxes: Array

# -------------------------------------------------------------------------------------------------
func set_bounding_boxes(boxes: Array) -> void:
	_bounding_boxes = boxes
	update()

# -------------------------------------------------------------------------------------------------
func _draw() -> void:
	for box in _bounding_boxes:
		draw_rect(box, Color.RED, false)
