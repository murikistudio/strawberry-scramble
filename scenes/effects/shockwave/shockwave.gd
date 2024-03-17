extends Spatial


# Variables
export var duration := 0.35
onready var _shockwave: MeshInstance = $Visual/Shockwave


# Built-in overrides
func _ready() -> void:
	_shockwave.cast_shadow = false
	var material = _shockwave.mesh.get("surface_1/material") as SpatialMaterial
	material.albedo_color.a = 1.0
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_LINEAR).tween_property(_shockwave, "blend_shapes/shockwave", 1.0, duration)
	tween.parallel().set_trans(Tween.TRANS_QUAD).tween_property(material, "albedo_color:a", 0.0, duration)
	tween.tween_callback(self, "queue_free")
