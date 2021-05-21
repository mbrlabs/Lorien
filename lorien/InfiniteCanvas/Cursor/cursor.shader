shader_type canvas_item;

void fragment() {
	vec3 background_color = texture(SCREEN_TEXTURE, SCREEN_UV).rgb;
	COLOR = vec4(vec3(1.0) - background_color, 1.0);
}