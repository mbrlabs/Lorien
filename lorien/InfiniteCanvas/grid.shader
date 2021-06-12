shader_type canvas_item;

uniform vec4 canvas_color : hint_color;

varying vec4 grid_color;

bool is_approx_equal(vec4 a, vec4 b) {
	return abs(a.r-b.r) <= 0.001 && abs(a.g-b.g) <= 0.001 && abs(a.b-b.b) <= 0.001;
}

void vertex() {
	vec3 c = clamp(canvas_color.rgb, vec3(0.05), vec3(0.6)) * 1.25;
	grid_color = vec4(c, 1.0);
}

void fragment() {
	vec4 background = texture(SCREEN_TEXTURE, SCREEN_UV);
	if (is_approx_equal(background, canvas_color)) {
		COLOR = grid_color;
	} else {
		COLOR = background;
	}
}