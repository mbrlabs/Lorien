class_name BrushStrokeOptimizer

# NOTE: this implementation is currently too aggressive and has a negative effect on user experience.
# Until it is visually undetectable by the user that the strokes were optimized, this will stay disabled.

# -------------------------------------------------------------------------------------------------
const ENABLED := false
const ANGLE_THRESHOLD := 0.5
const DISTANCE_THRESHOLD := 1.0

# -------------------------------------------------------------------------------------------------
var points_removed := 0

# -------------------------------------------------------------------------------------------------
func reset() -> void:
	points_removed = 0

# -------------------------------------------------------------------------------------------------
func optimize(s: BrushStroke) -> void:
	if !ENABLED:
		return
	
	if s.points.size() < 8:
		return
	
	var max_angle_diff := ANGLE_THRESHOLD
	var max_distance := DISTANCE_THRESHOLD
	
	var filtered_points: Array[Vector2]
	var filtered_pressures: Array[float]
	
	filtered_points.append(s.points.front())
	filtered_pressures.append(s.pressures.front())
	
	var previous_angle := 0.0
	for i: int in range(1, s.points.size()):
		var prev_point := s.points[i-1]
		var point := s.points[i]
		var pressure := s.pressures[i]
		
		# Distance between 2 points must be greater than x
		var distance := prev_point.distance_to(point)
		var distance_cond := distance > max_distance # TODO: make dependent on zoom level
	
		# Angle between points must be beigger than x deg
		var angle := rad_to_deg(prev_point.angle_to_point(point))
		var angle_diff: float = abs(abs(angle) - abs(previous_angle))
		var angle_cond := angle_diff >= max_angle_diff
		previous_angle = angle
		
		var point_too_far_away := distance > 100
		
		if point_too_far_away || (distance_cond && angle_cond):
			filtered_points.append(point)
			filtered_pressures.append(pressure)
		else:
			points_removed += 1

	# add back last point
	if !filtered_points.back().is_equal_approx(s.points.back()):
		filtered_points.append(s.points.back())
		filtered_pressures.append(s.pressures.back())

	s.points = filtered_points
	s.pressures = filtered_pressures
