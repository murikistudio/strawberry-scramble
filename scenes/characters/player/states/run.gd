extends PlayerStateMove
# Estado do jogador correndo.


# Variables
export(NodePath) var state_coyote: NodePath
export(NodePath) var state_idle: NodePath
export(NodePath) var state_jump: NodePath
export(NodePath) var state_slide: NodePath
export var step_sound_interval := 0.25
export var slide_delay := 0.3

var _step_time := 0.0
var _slide_delay := 0.0


# State overrides
func enter() -> void:
	player.emit_signal("animation_changed", "run_loop", 1.32)
	_step_time = 0.0


func physics_process(delta: float) -> BaseState:
	.physics_process(delta)

	_step_time += delta
	_slide_delay += delta

	step_sound_interval = 0.3 / player.move_weight.length()

	if _step_time >= step_sound_interval:
		_step_time = 0.0
		player.emit_signal("sfx_played", "step")

	if not player.is_on_floor():
		return get_state(state_coyote)

	if not object.move_axis.length():
		return get_state(state_idle)

	if Input.is_action_just_pressed("jump"):
		return get_state(state_jump)

	if _slide_delay >= slide_delay and Input.is_action_just_pressed("slide"):
		_slide_delay = 0.0
		return get_state(state_slide)

	return null
