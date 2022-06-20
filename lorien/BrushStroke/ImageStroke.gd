extends Sprite
class_name ImageStroke

# ------------------------------------------------------------------------------------------------
const GROUP_ONSCREEN 		:= "onscreen_stroke"

# ------------------------------------------------------------------------------------------------
onready var _visibility_notifier: VisibilityNotifier2D = $VisibilityNotifier2D
var points: Array # Array<Vector2>
var top_left_pos: Vector2
var bottom_right_pos: Vector2

# ------------------------------------------------------------------------------------------------
func _ready():
	_visibility_notifier.rect = get_rect()
	top_left_pos = get_rect().position
	bottom_right_pos = get_rect().end
	points.append(position)
	points.append(top_left_pos)
	points.append(bottom_right_pos)

# ------------------------------------------------------------------------------------------------
func _on_VisibilityNotifier2D_viewport_entered(viewport: Viewport) -> void:
	add_to_group(GROUP_ONSCREEN)
	visible = true

# ------------------------------------------------------------------------------------------------
func _on_VisibilityNotifier2D_viewport_exited(viewport: Viewport) -> void:
	remove_from_group(GROUP_ONSCREEN)
	visible = false

# -------------------------------------------------------------------------------------------------
func enable_collider(enable: bool) -> void:
	pass
