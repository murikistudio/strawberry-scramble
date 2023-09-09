extends Area


# Variables
export(float, 0.0, 10.0, 0.01) var rotation_speed := 1.0
export var direction := Vector3.ZERO
export(PackedScene) var scene_water_splash: PackedScene
onready var _visual: Spatial = find_node("Visual")
onready var _mesh: Spatial = _visual.get_children()[0]
onready var _ray_cast: RayCast = find_node("RayCast")
onready var _animation_player: AnimationPlayer = find_node("AnimationPlayer")
onready var _audio_roll: AudioStreamPlayer3D = find_node("AudioRoll")
onready var _audio_hit: AudioStreamPlayer3D = find_node("AudioHit")
var _gravity_factor := 0.0
var _collider: Node


# Built-in overrides
func _ready() -> void:
	direction.y = 0.0

	if direction.x != 0.0:
		direction.z = 0.0

	elif direction.z != 0.0:
		direction.x = 0.0

	if direction.length() == 0.0:
		set_physics_process(false)
		queue_free()
		return


func _physics_process(delta: float) -> void:
	var rot_factor := 120.0
	var gravity_factor := 0.1

	if direction.x != 0.0:
		_mesh.rotate_z(deg2rad(rot_factor * delta * rotation_speed))
		global_translation.x += direction.x * delta

	elif direction.z != 0.0:
		_mesh.rotate_x(deg2rad(-rot_factor * delta * rotation_speed))
		global_translation.z += direction.z * delta

	if _ray_cast.is_colliding():
		_gravity_factor = 0.0

		if not _animation_player.is_playing():
			_roll_start()

		var collider: Node = _ray_cast.get_collider()

		if collider == _collider:
			return

		_collider = collider

		if _collider.is_in_group("death") and _collider.is_in_group("water"):
			var water_splash: Spatial = scene_water_splash.instance()
			water_splash.time = 3.0
			get_parent().add_child(water_splash)
			water_splash.global_translation = global_translation
			water_splash.global_translation.y += 0.5
			GameAudio.play_sfx_3d(water_splash, DatabaseAudio.SFX_WATER, 10.0, 0.6)
			_roll_stop()
			queue_free()

	else:
		if _animation_player.is_playing():
			_roll_stop()

		_collider = null

		_gravity_factor += gravity_factor
		global_translation.y -= _gravity_factor * delta

		if _gravity_factor >= 100.0:
			queue_free()


# Private methods
func _roll_start() -> void:
	_animation_player.play("roll")
	_audio_roll.play()
	_audio_hit.play()
	get_viewport().get_camera().set_meta("shake", self)


func _roll_stop() -> void:
	get_viewport().get_camera().set_meta("shake", null)
	_animation_player.stop(true)
	_audio_roll.playing = false
