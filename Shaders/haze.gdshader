shader_type canvas_item;

uniform float speed : hint_range(0.0, 2.0) = 0.25;
uniform float intensity : hint_range(0.0, 0.05) = 0.007;
uniform float blur_amount : hint_range(0.0, 0.01, 0.0001) = 0.003;
uniform vec4 modulate_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
	float t = TIME * speed;
	vec2 distortion = vec2(
		sin(UV.y * 9.0 + t * 1.4) * cos(UV.x * 5.0 + t * 0.6),
		cos(UV.x * 7.0 + t * 0.8) * sin(UV.y * 4.0 + t * 1.2)
	) * intensity;
	vec2 uv = UV + distortion;
	float blur = blur_amount * (0.5 - 0.5 * cos(TIME * 0.4));
	vec4 col = texture(TEXTURE, uv);
	col += texture(TEXTURE, uv + vec2(blur, 0.0));
	col += texture(TEXTURE, uv + vec2(-blur, 0.0));
	col += texture(TEXTURE, uv + vec2(0.0, blur));
	col += texture(TEXTURE, uv + vec2(0.0, -blur));
	col += texture(TEXTURE, uv + vec2(blur, blur) * 0.707);
	col += texture(TEXTURE, uv + vec2(-blur, blur) * 0.707);
	col += texture(TEXTURE, uv + vec2(blur, -blur) * 0.707);
	col += texture(TEXTURE, uv + vec2(-blur, -blur) * 0.707);
	COLOR = col / 9.0 * modulate_color;
}
