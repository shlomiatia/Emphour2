shader_type canvas_item;

uniform bool is_colored;
uniform vec4 original_0: source_color;
uniform vec4 original_1: source_color;
uniform vec4 original_2: source_color;
uniform vec4 replace_0: source_color;
uniform vec4 replace_1: source_color;
uniform vec4 replace_2: source_color;
uniform vec4 modulate: source_color = vec4(1, 1, 1, 1);

const float precision = 0.21;

vec4 swap_color(vec4 color) {
	vec4 original_colors[3] = vec4[3](original_0, original_1, original_2);
	vec4 replace_colors[3] = vec4[3](replace_0, replace_1, replace_2);
	for (int index = 0; index < 3; index++) {
		if (distance(color, original_colors[index]) <= precision) {
			vec3 delta = color.rgb - original_colors[index].rgb;
			vec3 result_rgb = clamp(replace_colors[index].rgb + delta, 0.0, 1.0);
			return vec4(result_rgb, color.a);
		}
	}
	return color;
}

void fragment() {
	if (is_colored) {
		vec4 swapped_color = swap_color(texture(TEXTURE, UV));
		COLOR = swapped_color * modulate;
	}
}
