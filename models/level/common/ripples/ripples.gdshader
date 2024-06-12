shader_type spatial;

uniform sampler2D texture_1: hint_albedo;
uniform sampler2D texture_2: hint_albedo;
uniform float speed: hint_range(0.1, 10.0, 0.01) = 0.3;
uniform float opacity: hint_range(0.0, 2.0, 0.01) = 1.0;

void fragment() {
	vec4 color_1 = texture(texture_1, UV);
	vec4 color_2 = texture(texture_2, UV);
	color_1.a *= abs(sin(TIME * speed));
	color_2.a *= abs(cos(TIME * speed));
	ALBEDO = (color_1 + color_2).rgb;
	ALPHA = (color_1.a + color_2.a) * opacity;
}
