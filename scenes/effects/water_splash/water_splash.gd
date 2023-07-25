extends Spatial


onready var _sprite: AnimatedSprite3D = find_node("AnimatedSprite3D")


func _ready() -> void:
	if not _sprite:
		return

	_set_animation_loop(false)
	_sprite.play()


func _set_animation_loop(value: bool):
	_sprite.frames.set_animation_loop("default", value)


func _on_AnimatedSprite3D_animation_finished() -> void:
	visible = false
	queue_free()
