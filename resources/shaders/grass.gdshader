shader_type spatial;
render_mode shadows_disabled, specular_disabled;

uniform float offset: hint_range(0.0, 1.0, 0.01) = 0.2;
uniform float alpha_scissor: hint_range(-0.01, 1.0, 0.01) = 0.5;
uniform float speed: hint_range(0.0, 10.0, 0.01) = 1.0;
uniform sampler2D texture_: hint_albedo;

void vertex() {
	VERTEX.x += sin(TIME * speed) * VERTEX.y * offset;
	VERTEX.z += cos(TIME * 0.5 * speed) * VERTEX.y * offset;
}

void fragment() {
	vec4 color = texture(texture_, UV);
	ALBEDO = color.rgb;
	
	if (alpha_scissor > 0.0) {
		ALPHA_SCISSOR = alpha_scissor;
		ALPHA = color.a;
	}
}