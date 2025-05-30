class_name SvgExporter
extends RefCounted

# TODOs
# - Stroke width / pressue data

# -------------------------------------------------------------------------------------------------
const EDGE_MARGIN := 0.025

# -------------------------------------------------------------------------------------------------
func export_svg(strokes: Array[BrushStroke], text_boxes: Array[TextBox], background: Color, path: String) -> void:
	var start_time := Time.get_ticks_msec()
	
	# Open file
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		printerr("Failed to open file for writing")
		return
	
	# Calculate total canvas dimensions
	var max_dim := BrushStroke.MIN_VECTOR2
	var min_dim := BrushStroke.MAX_VECTOR2
	for stroke: BrushStroke in strokes:
		min_dim.x = min(min_dim.x, stroke.top_left_pos.x + stroke.global_position.x)
		min_dim.y = min(min_dim.y, stroke.top_left_pos.y + stroke.global_position.y)
		max_dim.x = max(max_dim.x, stroke.bottom_right_pos.x + stroke.global_position.x)
		max_dim.y = max(max_dim.y, stroke.bottom_right_pos.y + stroke.global_position.y)
		print("Stroke min",min_dim.x," ",min_dim.y)
		print("Stroke max",max_dim.x," ",max_dim.y)
		
	for text_box: TextBox in text_boxes:
		min_dim.x = min(min_dim.x, text_box.get_rect().position.x)
		min_dim.y = min(min_dim.y, text_box.get_rect().position.y)
		max_dim.x = max(max_dim.x, text_box.get_rect().position.x+text_box.get_rect().size.x)
		max_dim.y = max(max_dim.y, text_box.get_rect().position.y+text_box.get_rect().size.y)
		print("Global Position X: ",text_box.global_position.x, " Rect Position x: ", text_box.get_rect().position.x, " Rect Size x: ", text_box.get_rect().size.x)
		print("Text Box min",min_dim.x," ",min_dim.y)
		print("Text Box max",max_dim.x," ",max_dim.y)
		
	var size := max_dim - min_dim
	var margin_size := size * EDGE_MARGIN
	size += margin_size*2.0
	var origin := min_dim - margin_size
	
	# Write svg to file
	_svg_start(file, origin, size)
	_svg_rect(file, origin, size, background)
	for stroke: BrushStroke in strokes:
		_svg_polyline(file, stroke)
	for text_box: TextBox in text_boxes:
		_svg_text(file, text_box)
	_svg_end(file)
	
	# Flush and close the file
	file.flush()
	file.close()
	print("Exported %s in %d ms" % [path, (Time.get_ticks_msec() - start_time)])

# -------------------------------------------------------------------------------------------------
func _svg_start(file: FileAccess, origin: Vector2, size: Vector2) -> void:
	var params := [origin.x, origin.y, size.x, size.y]
	var svg := "<svg version=\"1.1\" xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"%.1f %.1f %.1f %.1f\">\n" % params
	file.store_string(svg)

# -------------------------------------------------------------------------------------------------
func _svg_end(file: FileAccess) -> void:
	file.store_string("</svg>") 

# -------------------------------------------------------------------------------------------------
func _svg_rect(file: FileAccess, origin: Vector2, size: Vector2, color: Color) -> void:
	var params := [origin.x, origin.y, size.x, size.y, color.to_html(false)]
	var rect := "<rect x=\"%.1f\" y=\"%.1f\" width=\"%.1f\" height=\"%.1f\" fill=\"#%s\" />\n" % params
	file.store_string(rect)

# -------------------------------------------------------------------------------------------------
func _svg_polyline(file: FileAccess, stroke: BrushStroke) -> void:
	file.store_string("<polyline points=\"")
	var idx := 0
	var point_count := stroke.points.size()
	for point: Vector2 in stroke.points:
		point += stroke.global_position
		if idx < point_count-1:
			file.store_string("%.1f %.1f," % [point.x, point.y])
		else:
			file.store_string("%.1f %.1f" % [point.x, point.y])
		idx += 1
	file.store_string("\" style=\"fill:none;stroke:#%s;stroke-width:2\"/>\n" % stroke.color.to_html(false))
	
# -------------------------------------------------------------------------------------------------
func _svg_text(file: FileAccess, text_box: TextBox) -> void:
	file.store_string("<text x=\"")
	file.store_string("%.1f" % [text_box.get_rect().position.x])
	file.store_string("\" y=\"")
	file.store_string("%.1f" % [text_box.get_rect().position.y])
	file.store_string("\" fill = \"#")
	var textBoxColor : Color = text_box.get("theme_override_colors/font_color")
	file.store_string(textBoxColor.to_html(false))
	file.store_string("\" font-family=\"Verdana\" >")
	file.store_string(text_box.text)
	file.store_string("</text>\n")
	
