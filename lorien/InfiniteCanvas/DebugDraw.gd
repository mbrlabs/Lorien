extends Node2D

#
# This is used to draw debug stuff like bounding boxes etc.
#

# -------------------------------------------------------------------------------------------------
var _bounding_boxes: Array[Rect2]

# -------------------------------------------------------------------------------------------------
func set_bounding_boxes(boxes: Array[Rect2]) -> void:
	_bounding_boxes = boxes
	queue_redraw()

# -------------------------------------------------------------------------------------------------
func _draw() -> void:
	for box in _bounding_boxes:
		draw_rect(box, Color.RED, false)
