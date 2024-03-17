extends PlayerBaseState
# Estado do jogador parado enquanto a animação de morte é reproduzida.


# Variables
export var wait_time := 1.0
export(NodePath) var state_idle: NodePath
export(PackedScene) var scene_water_splash: PackedScene
export var animation := "death_generic"
var _wait_time := 0.0


# State overrides
func enter() -> void:
	_wait_time = 0.0
	player.dead = true
	player.move_axis = Vector2.ZERO
	player.emit_signal("animation_changed", animation)

	if animation == "death_water":
		var water_splash: Spatial = scene_water_splash.instance()
		add_child(water_splash)
		water_splash.global_translation = player.global_translation
		water_splash.global_translation.y -= 0.5
		GameAudio.play_sfx(DatabaseAudio.SFX_WATER)

	elif animation == "death_balloon":
		GameAudio.play_sfx(DatabaseAudio.SFX_BALLOON_POP, -10.0)

	else:
		GameAudio.play_sfx(DatabaseAudio.SFX_HIT, -10.0)


func exit() -> void:
	player.dead = false
	player.global_translation = player.respawn_position + Vector3(0, 0, -1)
	player.move_weight = Vector2.ZERO
	player.move_gravity = 0.0
	player.anim_player.stop()


func physics_process(delta: float) -> BaseState:
	_wait_time += delta

	if _wait_time > wait_time:
		return get_state(state_idle)

	return null
