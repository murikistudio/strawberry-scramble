extends CPUParticles


func _ready() -> void:
	set_as_toplevel(true)
	one_shot = true
	var timer := get_tree().create_timer(1.5)
	timer.connect("timeout", self, "_on_timer_timeout")


func _on_timer_timeout() -> void:
	queue_free()
