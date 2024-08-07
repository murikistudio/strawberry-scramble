extends PlayerStateMove
class_name PlayerStateFall
# Estado do jogador caindo.


# Variables
export(NodePath) var state_idle: NodePath
export(NodePath) var state_run: NodePath
export(NodePath) var state_jump: NodePath
export(NodePath) var state_slam: NodePath


# State overrides
func enter() -> void:
	player.emit_signal("animation_changed", "fall_loop", 1.0)


func physics_process(delta: float) -> BaseState:
	.physics_process(delta)

	if player.jumps_left and Input.is_action_just_pressed("jump"):
		return get_state(state_jump)

	if GameState.player_skills.get("slam") and Input.is_action_just_pressed("action"):
		return get_state(state_slam)

	if not player.is_on_floor():
		return null

	if player.move_axis.length():
		player.emit_signal("sfx_played", "step")
		player.emit_signal("smoke_spawned")
		return get_state(state_run)

	return get_state(state_idle)
