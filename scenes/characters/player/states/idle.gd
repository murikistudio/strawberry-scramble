extends PlayerStateMove
# Estado do jogador parado.


# Variables
export(NodePath) var state_coyote: NodePath
export(NodePath) var state_run: NodePath
export(NodePath) var state_jump: NodePath


# State overrides
func enter() -> void:
	player.set_animation("idle_loop")
	player.play_sfx_step()


func physics_process(delta: float) -> BaseState:
	.physics_process(delta)

	if not player.is_on_floor():
		return get_state(state_coyote)

	if object.move_axis.length():
		return get_state(state_run)

	if Input.is_action_just_pressed("jump"):
		return get_state(state_jump)

	return null
