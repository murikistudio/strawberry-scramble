extends PlayerBaseState
# Estado do jogador deslizando.


# Variables
export(NodePath) var state_idle: NodePath
export var speed := 15.0
export(PackedScene) var scene_shockwave: PackedScene


# State overrides
func enter() -> void:
	player.emit_signal("sfx_played", "swing")
	player.emit_signal("animation_changed", "slam_loop", 1.0)


func physics_process(delta: float) -> BaseState:
	player.move_weight = Vector2.ZERO
	player.move_gravity -= speed * delta

	if player.is_on_floor():
		_spawn_shockwave()
		return get_state(state_idle)

	return null


func _spawn_shockwave() -> void:
	player.emit_signal("sfx_played", "slam")
	var shockwave: Spatial = scene_shockwave.instance()
	player.add_child(shockwave)
	shockwave.set_as_toplevel(true)
	shockwave.global_translation = player.global_translation + Vector3(0.0, -0.6, 0.0)
