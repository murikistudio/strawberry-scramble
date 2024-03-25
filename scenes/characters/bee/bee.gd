extends KinematicBody


onready var _anim_player: AnimationPlayer = find_node("AnimationPlayer")


func _ready() -> void:
	_anim_player.play("idle_loop")
