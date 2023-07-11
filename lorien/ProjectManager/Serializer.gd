class_name Serializer

# TODO: !IMPORTANT! all of this needs validation
# TODO: !IMPORTANT! all of this needs validation
# TODO: !IMPORTANT! all of this needs validation

# -------------------------------------------------------------------------------------------------
const BRUSH_STROKE = preload("res://BrushStroke/BrushStroke.tscn")
const COMPRESSION_METHOD = File.COMPRESSION_DEFLATE
const POINT_ELEM_SIZE := 3

const VERSION_NUMBER := 3
const TYPE_BRUSH_STROKE := 0
const TYPE_ERASER_STROKE_DEPRECATED := 1 # Deprecated since v0; will be ignored when read; structually the same as normal brush stroke

# -------------------------------------------------------------------------------------------------
static func save_project(project: Project) -> void:
	var start_time := OS.get_ticks_msec()
	
	# Open file
	var file := File.new()
	var err = file.open_compressed(project.filepath, File.WRITE, COMPRESSION_METHOD)
	if err != OK:
		print_debug("Failed to open file for writing: %s" % project.filepath)
		return
	
	# Meta data
	file.store_32(VERSION_NUMBER)
	file.store_pascal_string(_dict_to_metadata_str(project.meta_data))

	_save_strokes(file,project.strokes)	
	
	# Done
	file.close()
	print("Saved %s in %d ms" % [project.filepath, (OS.get_ticks_msec() - start_time)])

# -------------------------------------------------------------------------------------------------
static func load_project(project: Project) -> void:
	var start_time := OS.get_ticks_msec()

	# Open file
	var file := File.new()
	var err = file.open_compressed(project.filepath, File.READ, COMPRESSION_METHOD)
	if err != OK:
		print_debug("Failed to load file: %s" % project.filepath)
		return
	
	# Clear potential previous data
	project.strokes.clear()
	project.meta_data.clear()
	
	# Meta data
	var _version_number := file.get_32()
	var meta_data_str = file.get_pascal_string()
	project.meta_data = _metadata_str_to_dict(meta_data_str)
	
	# Brush strokes
	while true:
		
		var layer := 0
		if _version_number >= 2 :
			layer = 	file.get_8()
		
		# Type
		var type := file.get_8()
		
		match type:
			TYPE_BRUSH_STROKE, TYPE_ERASER_STROKE_DEPRECATED:
				var brush_stroke: BrushStroke = BRUSH_STROKE.instance()
				brush_stroke.layer = layer
				# Color
				var r := file.get_8()
				var g := file.get_8()
				var b := file.get_8()
				var a := 255.0
				if _version_number >= 3 :
					a = file.get_8()
					
				brush_stroke.color = Color(r/255.0, g/255.0, b/255.0, a/255.0)
				
				# Brush size
				brush_stroke.size = file.get_16()
					
				# Number of points
				var point_count := file.get_16()

				# Points
				for i in point_count:
					var x := file.get_float()
					var y := file.get_float()
					var pressure := file.get_8()
					brush_stroke.points.append(Vector2(x, y))
					brush_stroke.pressures.append(pressure)
				
				if type == TYPE_ERASER_STROKE_DEPRECATED:
					print("Skipped deprecated eraser stroke: %d points" % point_count)
				else:
					project.strokes.append(brush_stroke)
			_:
				printerr("Invalid type")
		
		# are we done yet?
		if file.get_position() >= file.get_len()-1 || file.eof_reached():
			break
	
	# Done
	file.close()
	print("Loaded %s in %d ms" % [project.filepath, (OS.get_ticks_msec() - start_time)])

# -------------------------------------------------------------------------------------------------
static func _dict_to_metadata_str(d: Dictionary) -> String:
	var meta_str := ""
	for k in d.keys():
		var v = d[k]
		if k is String && v is String:
			meta_str += "%s=%s," % [k, v]
		else:
			print_debug("Metadata should be String key-value pairs only!")
	return meta_str

# -------------------------------------------------------------------------------------------------
static func _metadata_str_to_dict(s: String) -> Dictionary:
	var meta_dict := {}
	for kv in s.split(",", false):
		var kv_split: PoolStringArray = kv.split("=", false)
		if kv_split.size() != 2:
			print_debug("Invalid metadata key-value pair: %s" % kv)
		else:
			meta_dict[kv_split[0]] = kv_split[1]
	return meta_dict

# -------------------------------------------------------------------------------------------------
static func _save_strokes(file: File, strokes: Array) -> void:
		# Stroke data
	for stroke in strokes:
		
		# Layer
		file.store_8(stroke.layer)
		
		# Type
		file.store_8(TYPE_BRUSH_STROKE)
		
		# Color
		file.store_8(stroke.color.r8)
		file.store_8(stroke.color.g8)
		file.store_8(stroke.color.b8)
		file.store_8(stroke.color.a8)
		
		# Brush size
		file.store_16(int(stroke.size))
		
		# Number of points
		file.store_16(stroke.points.size())
		
		# Points
		var p_idx := 0
		for p in stroke.points:
			# Add global_position offset which is != 0 when moved by move tool; but mostly it should just add 0
			file.store_float(p.x + stroke.global_position.x)
			file.store_float(p.y + stroke.global_position.y)
			file.store_8(stroke.pressures[p_idx])
			p_idx += 1
