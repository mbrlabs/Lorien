extends Node
class_name Types

# -------------------------------------------------------------------------------------------------
enum Tool {
	BRUSH,
	HIGHLIGHTER,
	RECTANGLE,
	CIRCLE,
	LINE,
	ERASER,
	SELECT,
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
enum BrushRoundingType {
	FLAT = 0,
	ROUNDED = 1
}

# -------------------------------------------------------------------------------------------------
enum UIScale {
	AUTO,
	CUSTOM
}

# -------------------------------------------------------------------------------------------------
class CanvasInfo:
	var point_count: int
	var stroke_count: int
	var current_pressure: float
	var selected_lines : int
