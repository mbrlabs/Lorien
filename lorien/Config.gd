class_name Config

const VERSION_MAJOR					:= 0
const VERSION_MINOR					:= 5
const VERSION_PATCH					:= 0
const VERSION_STATUS				:= "-dev"
const VERSION_STRING				:= "%d.%d.%d%s" % [VERSION_MAJOR, VERSION_MINOR, VERSION_PATCH, VERSION_STATUS]
const CONFIG_PATH 					:= "user://settings.cfg"
const PALETTES_PATH					:= "user://palettes.cfg"
const MAX_PALETTE_SIZE 				:= 40
const MIN_PALETTE_SIZE 				:= 1
const DEFAULT_CANVAS_COLOR 			:= Color("202124")
const DEFAULT_BRUSH_COLOR 			:= Color.white
const DEFAULT_BRUSH_SIZE			:= 12
const DEFAULT_PRESSURE_SENSITIVITY  := 1.0
const DEFAULT_AA_MODE				:= Types.AAMode.TEXTURE_FILL
const DEFAULT_SELECTION_COLOR 		:= Color("#2a967c")
const DEFAULT_FOREGROUND_FPS 		:= 144
const DEFAULT_BACKGROUND_FPS		:= 10
const DEFAULT_BRUSH_ROUNDING		:= Types.BrushRoundingType.FLAT
