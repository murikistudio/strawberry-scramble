extends PlayerBaseState
# Estado do jogador deslizando.


# Variables
export(NodePath) var state_idle: NodePath
export(NodePath) var state_jump: NodePath
export var slide_time := 0.3
export var slide_speed := 1.5
export var smoke_interval := 0.09

var _slide_time := 0.0
var _smoke_interval := 0.0


# State overrides
func enter() -> void:
	_slide_time = 0.0
	_smoke_interval = 0.0
	player.emit_signal("animation_changed", "slide_loop", 1.0)
	player.emit_signal("sfx_played", "slide")


func physics_process(delta: float) -> BaseState:
	player.move_weight = player.move_weight.normalized() * slide_speed
	_slide_time += delta
	_smoke_interval += delta

	if _smoke_interval >= smoke_interval and player.is_on_floor():
		player.emit_signal("smoke_spawned")
		_smoke_interval = 0.0

	if player.is_on_floor() and Input.is_action_just_pressed("jump"):
		return get_state(state_jump)

	if _slide_time >= slide_time:
		return get_state(state_idle)

	return null
