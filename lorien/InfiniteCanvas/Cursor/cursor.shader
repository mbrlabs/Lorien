shader_type canvas_item;

void fragment() {
	vec4 background_color = texture(SCREEN_TEXTURE, SCREEN_UV);
	vec4 texture_color = texture(TEXTURE, UV);
	
	vec3 inverted = vec3(texture_color.rgb - background_color.rgb);
	float grayscale = (inverted.r + inverted.g + inverted.b) / 3.0;
	grayscale = clamp(grayscale*0.75, 0.0, 1.0);
	
	COLOR = vec4(grayscale, grayscale, grayscale, texture_color.a);
}