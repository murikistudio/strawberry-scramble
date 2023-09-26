shader_type spatial;
render_mode specular_disabled;

uniform sampler2D texture_: hint_albedo;
uniform float alpha_scissor: hint_range(-0.01, 1.0, 0.01) = 0.5;
uniform float offset: hint_range(0.0, 1.0, 0.01) = 0.2;
uniform float speed: hint_range(0.0, 10.0, 0.01) = 1.0;
uniform vec3 player_world_position;
uniform float deform_strength: hint_range(0.0, 1.0, 0.01) = 1.0;
uniform float active_distance = 1.0;

void vertex() {
	vec4 world_position = WORLD_MATRIX * vec4(VERTEX, 1.0);
	float distance_to_player = distance(world_position.xyz, player_world_position);

	if (distance_to_player > 0.0 && distance_to_player <= active_distance) {
		float outward_movement = smoothstep(active_distance, 0.0, distance_to_player) * deform_strength;
		vec3 direction_to_player = normalize(world_position.xyz - player_world_position);
		vec3 movement_offset = direction_to_player * outward_movement;
		world_position.xyz += vec3(movement_offset.x, -abs(movement_offset.y), movement_offset.z);
		VERTEX = (inverse(WORLD_MATRIX) * world_position).xyz;
	}

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