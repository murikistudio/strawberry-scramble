extends Area
class_name EnemyJumper
# Base class of the jumper enemies, such as fish.


# Variables
export(float, 0.1, 10.0, 0.1) var anim_speed := 1.0
export(float, 0.0, 10.0, 0.1) var wait_at_start := 0.0
onready var _anim_player: AnimationPlayer = find_node("AnimationPlayer")
var dead := false


# Built-in overrides
func _ready() -> void:
	GameEvents.connect("enemy_killed", self, "_on_enemy_killed")

	if wait_at_start > 0.0:
		yield(get_tree().create_timer(wait_at_start, false), "timeout")

	_anim_player.play("jump_loop", -1, anim_speed)


func _process(_delta: float) -> void:
	if not dead:
		return

	rotate_y(0.5)
	var scale_factor := 0.025
	scale -= Vector3(scale_factor, scale_factor, scale_factor)

	if scale.x <= 0.05:
		queue_free()


# Event handlers
# Kill current enemy.
func _on_enemy_killed(enemy: Area) -> void:
	if dead or enemy != self:
		return

	_anim_player.stop(false)
	dead = true
	set_deferred("monitorable", false)
	GameAudio.play_sfx(DatabaseAudio.SFX_HIT, -10.0)
