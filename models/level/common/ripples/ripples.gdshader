shader_type spatial;

render_mode blend_add, depth_draw_always;

uniform sampler2D texture_1: hint_albedo;
uniform sampler2D texture_2: hint_albedo;
uniform float speed: hint_range(0.1, 10.0, 0.01) = 0.3;
uniform float opacity: hint_range(0.0, 2.0, 0.01) = 1.0;

void fragment() {
	vec3 color = vec3(0.0);
	color += texture(texture_1, UV).rgb * abs(sin(TIME * speed));
	color += texture(texture_2, UV).rgb * abs(cos(TIME * speed));
	ALBEDO = color * opacity;
}
