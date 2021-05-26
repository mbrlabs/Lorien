extends Node
class_name Types

# -------------------------------------------------------------------------------------------------
enum Tool {
	BRUSH,
	LINE,
	ERASER,
	COLOR_PICKER,
	SELECT,
	MOVE
}

# -------------------------------------------------------------------------------------------------
enum AAMode {
	NONE,
	OPENGL_HINT,
	TEXTURE_FILL
}

# -------------------------------------------------------------------------------------------------
enum UITheme {
	DARK,
	LIGHT
}

# -------------------------------------------------------------------------------------------------
class CanvasInfo:
	var point_count: int
	var stroke_count: int
	var current_pressure: float
	var selected_lines : int

# -------------------------------------------------------------------------------------------------
class CanvasGroups:
	const SELECTED_LINES : String = "selected_lines"
