extends PlayerStateMove
# Estado do jogador pulando.


# Variables
export(float, 0.0, 100.0, 0.1) var jump_force := 10.0
export(NodePath) var state_fall: NodePath
export(NodePath) var state_slam: NodePath


# State overrides
func enter() -> void:
	player.move_gravity = jump_force
	player.move_snap = Vector3.ZERO
	player.jumps_left -= 1
	player.emit_signal("sfx_played", "jump")
	player.emit_signal("sfx_played", "swing")
	player.emit_signal("animation_changed", "jump_loop", 1.0)


func physics_process(delta: float) -> BaseState:
	.physics_process(delta)

	if player.jumps_left and Input.is_action_just_pressed("jump"):
		return self

	if GameState.player_skills.get("slam") and Input.is_action_just_pressed("action"):
		return get_state(state_slam)

	if player.move_gravity > 0.0:
		return null

	return get_state(state_fall)
