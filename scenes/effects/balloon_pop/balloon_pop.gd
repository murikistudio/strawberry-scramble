extends Spatial


onready var _anim_player: AnimationPlayer = find_node("AnimationPlayer")


func _ready() -> void:
	set_as_toplevel(true)
	_anim_player.play("balloon_pop", -1, 1.2)
	GameAudio.play_sfx(DatabaseAudio.SFX_BALLOON_POP)
	global_rotation = Vector3.ZERO
	yield(_anim_player, "animation_finished")
	queue_free()
