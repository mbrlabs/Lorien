shader_type canvas_item;

void fragment() {
	vec4 background_color = texture(SCREEN_TEXTURE, SCREEN_UV);
	vec4 texture_color = texture(TEXTURE, UV);
	
	vec3 inverted = vec3(texture_color.rgb - background_color.rgb);
	float grayscale = (inverted.r + inverted.g + inverted.b) / 3.0;
	grayscale = min(1.0, grayscale*1.25);
	
	COLOR = vec4(grayscale, grayscale, grayscale, texture_color.a);
}