class_name Config

# Nice colors:
# 50ffd6
#

const VERSION_MAJOR					:= 0
const VERSION_MINOR					:= 1
const VERSION_PATCH					:= 0
const VERSION_STRING				:= "%d.%d.%d" % [VERSION_MAJOR, VERSION_MINOR, VERSION_PATCH]
const CONFIG_PATH 					:= "user://settings.cfg"
const DEFAULT_CANVAS_COLOR 			:= Color("202124")
const DEFAULT_BRUSH_COLOR 			:= Color.white
const DEFAULT_BRUSH_SIZE			:= 12
const DEFAULT_AA_MODE				:= Types.AAMode.TEXTURE_FILL
