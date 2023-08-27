extends KinematicBody


# Variables
export(float, 0.1, 10.0, 0.01) var duration := 4.0
export(Vector3) var target_position: Vector3


onready var _position_initial := global_translation
onready var _position_target := global_translation + target_position


func _ready() -> void:
	if not target_position.length() or duration <= 0.0:
		return

	var tween := create_tween().set_loops().set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "global_translation", _position_target, duration)
	tween.tween_property(self, "global_translation", _position_initial, duration)
