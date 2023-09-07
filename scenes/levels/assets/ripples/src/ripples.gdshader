shader_type spatial;

render_mode unshaded, blend_add, depth_draw_always;

uniform sampler2D texture_1: hint_albedo;
uniform sampler2D texture_2: hint_albedo;
uniform sampler2D texture_3: hint_albedo;
uniform float speed: hint_range(0.1, 10.0, 0.01) = 0.3;
uniform float speed_offset: hint_range(0.0, 10.0, 0.01) = 0.9;
uniform float opacity: hint_range(0.0, 2.0, 0.01) = 1.0;

void fragment() {
	vec3 color_1 = texture(texture_1, UV).rgb * abs(sin(TIME * speed));
	vec3 color_2 = texture(texture_2, UV).rgb * abs(cos((TIME + speed_offset * 2.0) * speed));
	vec3 color_3 = texture(texture_3, UV).rgb * abs(cos((TIME + speed_offset) * speed));
	ALBEDO = (color_1 + color_2 + color_3) * opacity;
}
