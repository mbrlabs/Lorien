shader_type canvas_item;

uniform vec4 background_color;

void fragment() {
	vec3 inverted = vec3(1.0) - background_color.rgb;
	float grayscale = (inverted.r + inverted.g + inverted.b) / 3.0;
	grayscale = min(1.0, grayscale*1.25);
	
	COLOR = vec4(grayscale, grayscale, grayscale, COLOR.a);
}