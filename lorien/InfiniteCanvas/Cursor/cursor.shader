shader_type canvas_item;

void fragment(){
	vec4 background_color = texture(SCREEN_TEXTURE, SCREEN_UV);
	vec4 color = texture(TEXTURE, UV);
	COLOR = vec4(color.rgb - background_color.rgb, color.a);
}