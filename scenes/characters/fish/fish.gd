extends EnemyJumper


# Variables
export(PackedScene) var scene_water_splash: PackedScene
onready var _visual: Spatial = find_node("Visual")


# Public methods
func spawn_water_splash() -> void:
	if not scene_water_splash:
		return

	var water_splash: Spatial = scene_water_splash.instance()
	add_child(water_splash)
	water_splash.global_translation = _visual.global_translation
	water_splash.global_rotation = Vector3.ZERO
	GameAudio.play_sfx_3d(water_splash, DatabaseAudio.SFX_WATER, 5.0, rand_range(1.0, 1.2))
