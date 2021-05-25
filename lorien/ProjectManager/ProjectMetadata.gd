extends Node

# -------------------------------------------------------------------------------------------------
const CAMERA_ZOOM = "camera_zoom"
const CAMERA_OFFSET_X := "camera_offset_x"
const CAMERA_OFFSET_Y := "camera_offset_y"
const CANVAS_COLOR := "canvas_color"

# -------------------------------------------------------------------------------------------------
func make_dict(canvas: InfiniteCanvas) -> Dictionary:
	var cam: Camera2D = canvas.get_camera()
	
	return {
		CAMERA_OFFSET_X: str(cam.offset.x),
		CAMERA_OFFSET_Y: str(cam.offset.y),
		CAMERA_ZOOM: str(cam.zoom.x),
		CANVAS_COLOR: canvas.get_background_color().to_html(false),
	}

# -------------------------------------------------------------------------------------------------
func apply_from_dict(meta_data: Dictionary, canvas: InfiniteCanvas) -> void:
	var cam: Camera2D = canvas.get_camera()
	
	var new_cam_zoom_str: String = meta_data.get(CAMERA_ZOOM, "1.0")
	var new_cam_offset_x_str: String = meta_data.get(CAMERA_OFFSET_X, "0.0")
	var new_cam_offset_y_str: String = meta_data.get(CAMERA_OFFSET_Y, "0.0")
	var new_canvas_color: String = meta_data.get(CANVAS_COLOR, Config.DEFAULT_CANVAS_COLOR.to_html())
	
	cam.set_zoom_level(float(new_cam_zoom_str))
	cam.offset = Vector2(float(new_cam_offset_x_str), float(new_cam_offset_y_str))
	canvas.set_background_color(Color(new_canvas_color))
