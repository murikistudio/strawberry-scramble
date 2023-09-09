extends CPUParticles


# Variables
var time := 1.5


# Built-in overrides
func _ready() -> void:
	set_as_toplevel(true)
	one_shot = true
	var timer := get_tree().create_timer(time)
	timer.connect("timeout", self, "_on_timer_timeout")


# Event handlers
func _on_timer_timeout() -> void:
	queue_free()
