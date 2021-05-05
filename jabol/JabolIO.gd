extends Node

const POINT_ELEM_SIZE = 2

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
			var s: String = line.default_color.to_html()
			for p in line.points:
				s += ",%f,%f" % [p.x, p.y]
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
		var line_data := LineData.new()
		
		var elems: PoolStringArray = file_line.split(",", false)
		
		if elems.size() < POINT_ELEM_SIZE+1:
			printerr("Line is pretty empty...")
			return []
		
		# line color
		var hex_color: String = elems[0].trim_prefix(" ").trim_suffix(" ")
		if hex_color.is_valid_html_color():
			line_data.color = Color(elems[0])
			elems.remove(0)
		else:
			printerr("Invlid line color")
			return []
		
		# line points
		if (elems.size() % POINT_ELEM_SIZE) > 0:
			printerr("Line contains incomplete point data")
			return []
		
		for i in range(0, elems.size(), POINT_ELEM_SIZE):
			var pos_x: String = elems[i].trim_prefix(" ").trim_suffix(" ")
			var pos_y: String = elems[i+1].trim_prefix(" ").trim_suffix(" ")
			if pos_x.is_valid_float() && pos_y.is_valid_float():
				line_data.points.append(Vector2(pos_x.to_float(), pos_y.to_float()))
			else:
				printerr("Invalid point data")
				return []
		
		# line done
		result.append(line_data)
		
	return result
