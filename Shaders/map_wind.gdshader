shader_type canvas_item;

uniform float wind_dir_angle = 0.0;
uniform float wind_speed = 16.0;
uniform float patch_width_px = 240.0;
uniform float patch_height_px = 14.0;
uniform float band_spacing_px = 9.0;
uniform float pixel_size_px : hint_range(1.0, 64.0, 1.0) = 1.0;
uniform float rotation_degrees = -15.0;
uniform float threshold = 0.7;
uniform float opacity = 0.045;
uniform float corner_roundness = 0.18;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	float a = hash(i);
	float b = hash(i + vec2(1.0, 0.0));
	float c = hash(i + vec2(0.0, 1.0));
	float d = hash(i + vec2(1.0, 1.0));
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

vec2 rotate(vec2 p, float angle) {
	float c = cos(angle);
	float s = sin(angle);
	return vec2(p.x * c - p.y * s, p.x * s + p.y * c);
}

float band_value(vec2 p, float band) {
	float center_y = (band + 0.5) * band_spacing_px;
	float edge = abs(p.y - center_y) / (patch_height_px * 0.5);
	float n = noise(vec2(p.x / patch_width_px, band * 0.25)) * 0.8 + hash(vec2(band, 19.0)) * 0.2;
	return n - edge * edge * corner_roundness;
}

void fragment() {
	vec2 p = SCREEN_UV / SCREEN_PIXEL_SIZE;
	p -= vec2(cos(radians(wind_dir_angle)), sin(radians(wind_dir_angle))) * TIME * wind_speed;
	p = rotate(p, radians(rotation_degrees));
	p = floor(p / pixel_size_px) * pixel_size_px;
	float band = floor(p.y / band_spacing_px);
	float n = max(band_value(p, band - 1.0), band_value(p, band));
	n = max(n, band_value(p, band + 1.0));
	float land_alpha = texture(TEXTURE, UV).a;
	COLOR = vec4(COLOR.rgb, COLOR.a * land_alpha * step(threshold, n) * opacity);
}
