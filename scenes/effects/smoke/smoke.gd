extends Spatial


# Variables
export var duration := 0.7
onready var _smoke: MeshInstance = $Visual/Smoke


# Built-in overrides
func _ready() -> void:
	_smoke.cast_shadow = false
	_smoke.mesh = _smoke.mesh.duplicate()
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(_smoke, "blend_shapes/smoke", 1.0, duration)
	tween.tween_callback(self, "queue_free")
