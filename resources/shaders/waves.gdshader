shader_type spatial;
render_mode unshaded, blend_mix, depth_draw_always;

uniform float alpha = 1.0;
uniform vec4 color_1: hint_color;
uniform vec4 color_2: hint_color;
uniform float color_limit = 0.6;
uniform float color_variation_speed = 1.0;
uniform float color_variation_amount = 0.05;
uniform float wave_height = 0.0;
uniform float wave_speed = 0.0;
uniform float speed_x = 0.0;
uniform float speed_y = 0.0;
uniform sampler2D noise_1: hint_albedo;
uniform sampler2D noise_2: hint_albedo;

vec2 get_uv_offset(vec2 uv) {
	return vec2(
		uv.x + TIME * speed_x,
		uv.y + TIME * speed_y
	);
}

void vertex() {
	vec2 offset = get_uv_offset(UV);
	vec4 tex = texture(noise_1, UV);
	VERTEX.y = sin(tex.x * TIME * wave_speed) * wave_height;
}

void fragment() {
	vec2 noise_1_offset = get_uv_offset(UV);
	vec3 noise_1_color = texture(noise_1, noise_1_offset).rgb;
	vec2 noise_2_offset = -1.0 * get_uv_offset(UV);
	vec3 noise_2_color = texture(noise_2, noise_2_offset).rgb;
	vec3 color = noise_1_color.rgb;
	float noise_1_color_limit = color_limit + abs(sin(TIME * color_variation_speed)) * color_variation_amount;
	float noise_2_color_limit = color_limit + abs(cos(TIME * color_variation_speed)) * color_variation_amount;
	
	if (noise_1_color.r > noise_1_color_limit || noise_2_color.r > noise_2_color_limit) {
		color = color_1.rgb;
	} else {
		color = color_2.rgb;
	}
	
	ALBEDO = color;
	ALPHA = alpha;
}
