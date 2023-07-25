extends Area


# Variables
onready var _visual: Spatial = $Visual


# Built-in overrides
func _process(delta: float) -> void:
	if monitorable:
		_visual.rotate_y(deg2rad(45.0) * delta)
	else:
		if _visual.scale.length() < 0.05:
			queue_free()
			return

		_visual.scale *= 0.9
		_visual.global_translate(Vector3(0.0, 0.05, 0.0))
		_visual.rotate_y(deg2rad(360.0) * delta)
