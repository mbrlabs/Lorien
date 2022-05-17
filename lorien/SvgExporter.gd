class_name SvgExporter
extends Reference

# TODOs
# - Stroke width / pressue data
# - UI: Proper export dialog

# -------------------------------------------------------------------------------------------------
func export_svg(strokes: Array, margin: float = 0.025) -> void:
	# Open file
	var file := File.new()
	var path := OS.get_user_data_dir() + "/lorien.svg"
	var err := file.open(path, File.WRITE)
	if err != OK:
		printerr("Failed to open file for writing")
		return
	
	# Clac dimensions
	var max_dim := BrushStroke.MIN_VECTOR2
	var min_dim := BrushStroke.MAX_VECTOR2
	for stroke in strokes:
		min_dim.x = min(min_dim.x, stroke.top_left_pos.x)
		min_dim.y = min(min_dim.y, stroke.top_left_pos.y)
		max_dim.x = max(max_dim.x, stroke.bottom_right_pos.x)
		max_dim.y = max(max_dim.y, stroke.bottom_right_pos.y)
	var size := max_dim - min_dim
	var margin_size := size * margin
	size += margin_size*2.0
	var origin := min_dim - margin_size
	
	# Write svg to file
	var dims := [origin.x, origin.y, size.x, size.y]
	var svg := "<svg version=\"1.1\" xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"%.1f %.1f %.1f %.1f\">\n" % dims
	svg += "<rect x=\"%.1f\" y=\"%.1f\" width=\"%.1f\" height=\"%.1f\" fill=\"#202124\" />\n" % dims
	file.store_string(svg)
	for stroke in strokes:
		_render_polyline(file, stroke)
	file.store_string("</svg>")
	
	# Flush and close the file
	file.flush()
	file.close()
	print("Exported svg to %s" % path)

# -------------------------------------------------------------------------------------------------
func _render_polyline(file: File, stroke: BrushStroke) -> void:
	file.store_string("<polyline points=\"")
	var idx := 0
	var point_count := stroke.points.size()
	for point in stroke.points:
		if idx < point_count-1:
			file.store_string("%.1f %.1f," % [point.x, point.y])
		else:
			file.store_string("%.1f %.1f" % [point.x, point.y])
		idx += 1
	file.store_string("\" style=\"fill:none;stroke:#%s;stroke-width:2\"/>\n" % stroke.color.to_html(false))
