extends Node
class_name Types

# -------------------------------------------------------------------------------------------------
const LOCALE_ENGLISH := "en"
const LOCALE_GERMAN := "de"
const LOCALE_ITALIAN := "it"
const LOCALE_SPANISH := "es"

# -------------------------------------------------------------------------------------------------
enum Tool {
	BRUSH,
	LINE,
	ERASER,
	COLOR_PICKER,
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
enum ExportType {
	PNG
}

# -------------------------------------------------------------------------------------------------
class CanvasInfo:
	var point_count: int
	var stroke_count: int
	var current_pressure: float
	var selected_lines : int
