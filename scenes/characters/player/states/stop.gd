extends PlayerBaseState
# Estado do jogador parado sem possibilidade de se mover.


# Variables
export(NodePath) var state_coyote: NodePath
export(NodePath) var state_run: NodePath
export(NodePath) var state_jump: NodePath


# State overrides
func enter() -> void:
	player.set_animation("idle_loop")
	player.move_axis = Vector2.ZERO
	player.input_move_axis = Vector2.ZERO
