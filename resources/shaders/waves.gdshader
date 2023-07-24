shader_type spatial;
render_mode unshaded, blend_mix, depth_draw_always;

uniform float alpha = 1.0;
uniform vec4 color_1: hint_color;
uniform vec4 color_2: hint_color;
uniform float color_limit = 0.6;
uniform float wave_height = 0.0;
uniform float wave_speed = 0.0;
uniform float speed_x = 0.0;
uniform float speed_y = 0.0;
uniform sampler2D noise: hint_albedo;

vec2 get_uv_offset(vec2 uv) {
	return vec2(
		uv.x + TIME * speed_x,
		uv.y + TIME * speed_y
	);
}

void vertex() {
	vec2 offset = get_uv_offset(UV);
	vec4 tex = texture(noise, UV);
	VERTEX.y = sin(tex.x * TIME * wave_speed) * wave_height;
}

void fragment() {
	vec2 offset = get_uv_offset(UV);
	vec3 tex_color = texture(noise, offset).rgb;
	vec3 color = tex_color;
	float current_color_limit = color_limit + abs(sin(TIME * 0.75)) * 0.03;
	
	if (tex_color.r > current_color_limit) {
		color = color_1.rgb;
	} else {
		color = color_2.rgb;
	}
	
	ALBEDO = color;
	ALPHA = alpha;
}
