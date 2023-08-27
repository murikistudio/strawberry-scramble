extends CPUParticles


func _ready() -> void:
	one_shot = true
	yield(get_tree().create_timer(1.5), "timeout")
	queue_free()
