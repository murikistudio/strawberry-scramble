extends PlayerBaseState
# Estado do jogador parado sem possibilidade de se mover.


# Variables
export(NodePath) var state_coyote: NodePath
export(NodePath) var state_run: NodePath
export(NodePath) var state_jump: NodePath


# State overrides
func enter() -> void:
	player.emit_signal("animation_changed", "idle_loop", 1.0)
	player.move_axis = Vector2.ZERO
