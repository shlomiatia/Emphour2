shader_type canvas_item;

uniform bool enabled = false;
uniform vec4 regular: source_color = vec4(0.309804, 0.360784, 0.192157, 1.0);
uniform vec4 dark: source_color = vec4(0.145098, 0.192157, 0.105882, 1.0);
uniform vec4 light: source_color = vec4(0.619608, 0.709804, 0.529412, 1.0);
uniform vec4 mapped_regular: source_color = vec4(0.090196, 0.223529, 0.403922, 1.0);
uniform vec4 mapped_dark: source_color = vec4(0.050980, 0.125490, 0.227451, 1.0);
uniform vec4 mapped_light: source_color = vec4(0.352941, 0.552941, 0.839216, 1.0);

const float PRECISION = 0.1;

vec4 map_color(vec4 color) {
	vec4 originals[3] = vec4[3](regular, dark, light);
	vec4 replacements[3] = vec4[3](mapped_regular, mapped_dark, mapped_light);
	for (int index = 0; index < 3; index++) {
		if (distance(color.rgb, originals[index].rgb) <= PRECISION) {
			return vec4(clamp(replacements[index].rgb + color.rgb - originals[index].rgb, 0.0, 1.0), color.a);
		}
	}
	return color;
}

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	if (enabled) {
		color = map_color(color);
	}
	COLOR *= color;
}
