class_name Config

const VERSION_MAJOR					:= 0
const VERSION_MINOR					:= 7
const VERSION_PATCH					:= 0
const VERSION_STATUS				:= "-dev"
static var VERSION_STRING			:= "%d.%d.%d%s" % [VERSION_MAJOR, VERSION_MINOR, VERSION_PATCH, VERSION_STATUS]
const CONFIG_PATH 					:= "user://settings.cfg"
const PALETTES_PATH					:= "user://palettes.cfg"
const STATE_PATH					:= "user://state.cfg"
const MAX_PALETTE_SIZE 				:= 40
const MIN_PALETTE_SIZE 				:= 1
const MIN_WINDOW_SIZE				:= Vector2(320, 256)
const DEFAULT_CANVAS_COLOR 			:= Color("202124")
const DEFAULT_BRUSH_COLOR 			:= Color.WHITE
const DEFAULT_BRUSH_SIZE			:= 12
const DEFAULT_PRESSURE_SENSITIVITY  := 1.5
const DEFAULT_CONSTANT_PRESSURE		:= false
const DEFAULT_SELECTION_COLOR 		:= Color("#2a967c")
const DEFAULT_FOREGROUND_FPS 		:= 144
const DEFAULT_BACKGROUND_FPS		:= 10
const DEFAULT_BRUSH_ROUNDING		:= Types.BrushRoundingType.ROUNDED
const DEFAULT_UI_SCALE_MODE 		:= Types.UIScale.AUTO
const DEFAULT_UI_SCALE  			:= 1.0
const DEFAULT_GRID_PATTERN 			:= Types.GridPattern.DOTS
const DEFAULT_GRID_SIZE 			:= 25.0
const DEFAULT_TOOL_PRESSURE			:= 0.5
