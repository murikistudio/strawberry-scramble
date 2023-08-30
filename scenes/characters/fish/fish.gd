extends Spatial


# Variables
export(float, 0.1, 10.0, 0.1) var anim_speed := 1.0
export(PackedScene) var scene_water_splash: PackedScene
onready var _anim_player: AnimationPlayer = find_node("AnimationPlayer")
onready var _fish: Spatial = find_node("Fish")


# Built-in overrides
func _ready() -> void:
	_anim_player.play("jump", -1, anim_speed)


# Public methods
func spawn_water_splash() -> void:
	if not scene_water_splash:
		return

	var water_splash: Spatial = scene_water_splash.instance()
	add_child(water_splash)
	water_splash.set_as_toplevel(true)
	water_splash.global_translation = _fish.global_translation
	water_splash.global_rotation = Vector3.ZERO
	GameAudio.play_sfx(DatabaseAudio.SFX_WATER, -12.0, rand_range(1.0, 1.2))
