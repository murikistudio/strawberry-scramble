extends PlayerBaseState
# Estado do jogador deslizando.


# Variables
export(NodePath) var state_idle: NodePath
export(NodePath) var state_jump: NodePath
export var slide_time := 0.3
export var slide_speed := 1.5

var _slide_time := 0.0


# State overrides
func enter() -> void:
	_slide_time = 0.0
	player.emit_signal("animation_changed", "slide_loop", 1.0)
	player.emit_signal("sfx_played", "slide")


func physics_process(delta: float) -> BaseState:
	player.move_weight = player.move_weight.normalized() * slide_speed
	_slide_time += delta

	if player.is_on_floor() and Input.is_action_just_pressed("jump"):
		return get_state(state_jump)

	if _slide_time >= slide_time:
		return get_state(state_idle)

	return null
