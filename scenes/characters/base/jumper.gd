extends Area
class_name EnemyJumper


# Variables
export(float, 0.1, 10.0, 0.1) var anim_speed := 1.0
onready var _anim_player: AnimationPlayer = find_node("AnimationPlayer")


# Built-in overrides
func _ready() -> void:
	_anim_player.play("jump_loop", -1, anim_speed)
