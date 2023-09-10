extends Area


# Variables
export(NodePath) var target: NodePath
var _target: Spatial
onready var _particles_wick: CPUParticles = find_node("ParticlesWick")
onready var _particles_shot: CPUParticles = find_node("ParticlesShot")
onready var _audio_wick: AudioStreamPlayer3D = find_node("AudioWick")
onready var _audio_shot: AudioStreamPlayer3D = find_node("AudioShot")


# Built-in overrides
func _ready() -> void:
	if not target:
		push_warning("Cannon target must be set on " + get_path())
		return

	_target = get_node(target)
	look_at(_target.global_translation, Vector3.UP)
	_particles_wick.emitting = false
	_particles_shot.emitting = false
	_particles_shot.one_shot = true


# Event handlers
func _on_Cannon_body_entered(body: Spatial) -> void:
	if not _target or not body.is_in_group("player"):
		return

	GameEvents.emit_signal("level_cannon_entered", _target)
	set_deferred("monitoring", false)
	_particles_wick.emitting = true
	_audio_wick.play()
	get_tree().create_timer(2.0, false).connect(
		"timeout", self, "_on_Timer_timeout", [], CONNECT_ONESHOT
	)


func _on_Timer_timeout() -> void:
	set_deferred("monitoring", true)
	_particles_wick.emitting = false
	_audio_wick.stop()
	_particles_shot.emitting = true
	_audio_shot.play()
