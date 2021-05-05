extends Node

const POINT_ELEM_SIZE = 3

# -------------------------------------------------------------------------------------------------
func save_file(file_path: String, lines: Array) -> void:
	var file := File.new()
	var err = file.open(file_path, File.WRITE)
	if err != OK:
		printerr("Failed to open file for writing: %s" % file_path)
		return
	
	var point_counter := 0
	for line in lines:
		if line is Line2D:
			var s: String = line.default_color.to_html() # brush stroke color
			s += ",%d" % line.width # brush stroke size 
			for p in line.points:
				s += ",%f,%f,%f" % [p.x, p.y, 1.0] # TODO: implement pressure value per point. right now it's just always a 1.0
			file.store_line(s)
			point_counter += line.points.size()
		else:
			printerr("wtf?!")
	
	file.close()
	print("Saved %d points in %d lines" % [point_counter, lines.size()])

# -------------------------------------------------------------------------------------------------
func load_file(file_path: String) -> Array:
	var result := []
	
	# Read file
	var file := File.new()
	var err = file.open(file_path, File.READ)
	var content: String
	if err == OK:
		content = file.get_as_text()
	else:
		printerr("Failed to load file: %s" % file_path)
		return []
	file.close()
	
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
