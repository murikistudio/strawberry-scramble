shader_type spatial;
render_mode shadows_disabled, specular_disabled;

uniform float offset: hint_range(0.0, 1.0, 0.1) = 0.2;
uniform float speed: hint_range(0.0, 1.0, 0.1) = 1.0;

void vertex() {
	VERTEX.x += sin(TIME * speed) * VERTEX.y * offset;
	VERTEX.z += cos(TIME * 0.5 * speed) * VERTEX.y * offset;
}

void fragment() {
	ALBEDO = COLOR.rgb;
}