class_name Serializer

# TODO: !IMPORTANT! all of this needs validation

# -------------------------------------------------------------------------------------------------
const COMPRESSION_METHOD = File.COMPRESSION_DEFLATE
const POINT_ELEM_SIZE := 3

const VERSION_NUMBER := 0
const METADATA_CAMERA_ZOOM = "camera_zoom"
const METADATA_CAMERA_OFFSET_X := "camera_offset_x"
const METADATA_CAMERA_OFFSET_Y := "camera_offset_y"
const CANVAS_COLOR := "canvas_color"

# -------------------------------------------------------------------------------------------------
static func save_project(project: Project) -> void:
	var start_time := OS.get_ticks_msec()
	
	# Open file
	var file := File.new()
	var err = file.open_compressed(project.filepath, File.WRITE, COMPRESSION_METHOD)
	if err != OK:
		print_debug("Failed to open file for writing: %s" % project.filepath)
		return
	
	# Serialize meta data
	file.store_32(VERSION_NUMBER)
	file.store_pascal_string(_dict_to_metadata_str(project.meta_data))
	
	# Serialize eraser stroke indices
	file.store_32(project.eraser_stroke_indices.size())
	for stroke_index in project.eraser_stroke_indices:
		file.store_32(stroke_index)
	
	# Serialize stroke data
	for stroke in project.strokes:
		# color
		file.store_8(stroke.color.r8)
		file.store_8(stroke.color.g8)
		file.store_8(stroke.color.b8)
		
		# brush size
		file.store_16(int(stroke.size))
		
		# number of points
		file.store_16(stroke.points.size())
		
		# points
		var p_idx := 0
		for p in stroke.points:
			file.store_float(p.x)
			file.store_float(p.y)
			file.store_8(stroke.pressures[p_idx])
			p_idx += 1

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
	
	# Deserialize meta data
	var _version_number := file.get_32()
	var meta_data_str = file.get_pascal_string()
	project.meta_data = _metadata_str_to_dict(meta_data_str)
	
	# Deserialize eraser stroke indices
	var eraser_stroke_count := file.get_32()
	for i in eraser_stroke_count:
		project.eraser_stroke_indices.append(file.get_32())
	
	# Deserialize strokes
	while true:
		var brush_stroke := BrushStroke.new()
		
		# color
		var r := file.get_8()
		var g := file.get_8()
		var b := file.get_8()
		brush_stroke.color = Color(r/255.0, g/255.0, b/255.0, 1.0)
		
		# brush size
		brush_stroke.size = file.get_16()
			
		# number of points
		var point_count := file.get_16()

		# points
		for i in point_count:
			var x := file.get_float()
			var y := file.get_float()
			var pressure := file.get_8()
			brush_stroke.points.append(Vector2(x, y))
			brush_stroke.pressures.append(pressure)
		project.strokes.append(brush_stroke)
		
		# are we done yet?
		if file.get_position() >= file.get_len()-1 || file.eof_reached():
			break
	
	for eraser_index in project.eraser_stroke_indices:
		project.strokes[eraser_index].eraser = true
	
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
