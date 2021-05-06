extends Node

const POINT_ELEM_SIZE = 3
const COMPRESSION_METHOD = File.COMPRESSION_DEFLATE

# -------------------------------------------------------------------------------------------------
func save_file(file_path: String, line_2d_array: Array) -> void:
	var start_time := OS.get_ticks_msec()
	
	# open file
	var file := File.new()
	var err
	if _is_binary(file_path):
		err = file.open_compressed(file_path, File.WRITE, COMPRESSION_METHOD)
	else:
		err = file.open(file_path, File.WRITE)
	if err != OK:
		printerr("Failed to open file for writing: %s" % file_path)
		return
	
	# write
	if _is_binary(file_path):
		_write_to_binary_file(file, line_2d_array)
	else:
		_write_to_text_file(file, line_2d_array)
	file.close()
	
	print("File saved in %d ms" % (OS.get_ticks_msec() - start_time))
	
# -------------------------------------------------------------------------------------------------
func load_file(file_path: String) -> Array:
	var start_time := OS.get_ticks_msec()
		
	# open file
	var file := File.new()
	var err
	if _is_binary(file_path):
		err = file.open_compressed(file_path, File.READ, COMPRESSION_METHOD)
	else:
		err = file.open(file_path, File.READ)
	if err != OK:
		printerr("Failed to load file: %s" % file_path)
		return []
	
	# parse
	var result: Array
	if _is_binary(file_path):
		result = _read_from_binary_file(file)
	else:
		result = _read_from_text_file(file)
	file.close()
	
	print("Loaded %s in %d ms" % [file_path, (OS.get_ticks_msec() - start_time)])
	return result

# -------------------------------------------------------------------------------------------------
func _write_to_text_file(file: File, line_2d_array: Array) -> void:
	for line in line_2d_array:
		if line is Line2D:
			var s: String = line.default_color.to_html() # brush stroke color
			s += ",%d" % line.width # brush stroke size 
			for p in line.points:
				s += ",%f,%f,%f" % [p.x, p.y, 1.0] # TODO: implement pressure value per point. right now it's just always a 1.0
			file.store_line(s)
		else:
			printerr("wtf?!")

# -------------------------------------------------------------------------------------------------
func _read_from_text_file(file: File) -> Array:
	var result = []
	var content := file.get_as_text()
	
	# Parse line-by-line
	for file_line in content.split("\n", false):
		var stroke_data := BrushStrokeData.new()
		
		var elems: PoolStringArray = file_line.split(",", false)
		
		if elems.size() < POINT_ELEM_SIZE+1:
			printerr("Line is pretty empty...")
			return []
		
		# brush color
		var hex_color: String = elems[0].trim_prefix(" ").trim_suffix(" ")
		if hex_color.is_valid_html_color():
			stroke_data.color = Color(elems[0])
			elems.remove(0)
		else:
			printerr("Invlid stroke color")
			return []
			
		# brush size
		var brush_size_str: String = elems[0].trim_prefix(" ").trim_suffix(" ")
		if brush_size_str.is_valid_integer():
			stroke_data.size = brush_size_str.to_int()
			elems.remove(0)
		else:
			printerr("Invlid stroke size")
			return []
		
		# brush stroke points
		if (elems.size() % POINT_ELEM_SIZE) > 0:
			printerr("Brush stroke contains incomplete point data")
			return []
		
		for i in range(0, elems.size(), POINT_ELEM_SIZE):
			var pos_x: String = elems[i].trim_prefix(" ").trim_suffix(" ")
			var pos_y: String = elems[i+1].trim_prefix(" ").trim_suffix(" ")
			var pressure: String = elems[i+2].trim_prefix(" ").trim_suffix(" ")
			if pos_x.is_valid_float() && pos_y.is_valid_float() && pressure.is_valid_float():
				stroke_data.points.append(Vector2(pos_x.to_float(), pos_y.to_float()))
				stroke_data.point_pressures.append(pressure.to_float())
			else:
				printerr("Invalid point data")
				return []
		
		# brush stroke done
		result.append(stroke_data)
	
	return result

# -------------------------------------------------------------------------------------------------
func _write_to_binary_file(file: File, line_2d_array: Array) -> void:
	for line in line_2d_array:
		if line is Line2D:
			# color
			file.store_8(line.default_color.r8)
			file.store_8(line.default_color.g8)
			file.store_8(line.default_color.b8)
			
			# brush size
			file.store_16(line.width)
			
			# number of points
			file.store_32(line.points.size())
			
			# points
			var s: String = line.default_color.to_html() # brush stroke color
			s += ",%d" % line.width # brush stroke size 
			for p in line.points:
				file.store_float(p.x)
				file.store_float(p.y)
				file.store_float(1.0) # TODO: implement pressure value per point. right now it's just always a 1.0
		else:
			printerr("wtf?!")

# -------------------------------------------------------------------------------------------------
# TODO: this needs some error handling!
func _read_from_binary_file(file: File) -> Array:
	var result := []
	
	while true:
		var stroke_data := BrushStrokeData.new()
		
		# color
		var r := file.get_8()
		var g := file.get_8()
		var b := file.get_8()
		stroke_data.color = Color(r/255.0, g/255.0, b/255.0, 1.0)
		
		# brush size
		stroke_data.size = file.get_16()
		
		# number of points
		var point_count := file.get_32()

		# points
		for i in point_count:
			var x := file.get_float()
			var y := file.get_float()
			var pressure := file.get_float()
			stroke_data.points.append(Vector2(x, y))
			stroke_data.point_pressures.append(pressure)
		
		result.append(stroke_data)
		
		# are we done yet?
		if file.get_position() >= file.get_len()-1 || file.eof_reached():
			break
		
	return result

# -------------------------------------------------------------------------------------------------
func _is_binary(file_path: String) -> bool:
	return file_path.ends_with(".jabolb")
