extends Area


onready var _anim_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	_anim_player.play("walk_loop", -1, 1.25)
