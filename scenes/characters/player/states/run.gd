extends PlayerStateMove
# Estado do jogador correndo.


# Variables
export(NodePath) var state_coyote: NodePath
export(NodePath) var state_idle: NodePath
export(NodePath) var state_jump: NodePath


# State overrides
func enter() -> void:
	player.set_animation("run_loop", 1.8)


func physics_process(delta: float) -> BaseState:
	.physics_process(delta)

	if not player.is_on_floor():
		return get_state(state_coyote)

	if not object.move_axis.length():
		return get_state(state_idle)

	if Input.is_action_just_pressed("jump"):
		return get_state(state_jump)

	return null

