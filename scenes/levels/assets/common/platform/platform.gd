extends KinematicBody


# Variables
export var moving := true
export(float, 0.1, 10.0, 0.01) var duration := 4.0
export(Vector3) var target_position: Vector3


onready var _position_initial := global_translation
onready var _position_target := global_translation + target_position


func _ready() -> void:
	if moving:
		_move_platform()
	else:
		GameEvents.connect("level_lever_pushed", self, "_on_level_lever_pushed")


# Private methods
func _move_platform() -> void:
	if not target_position.length() or duration <= 0.0:
		return

	var tween := create_tween().set_loops().set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "global_translation", _position_target, duration)
	tween.tween_property(self, "global_translation", _position_initial, duration)


# Event handlers
func _on_level_lever_pushed(target: Node) -> void:
	if moving or target != self:
		return

	GameEvents.emit_signal("player_request_camera_focus", self)
	yield(get_tree().create_timer(0.5, false), "timeout")
	moving = true
	_move_platform()
	yield(get_tree().create_timer(1.5, false), "timeout")
	GameEvents.emit_signal("player_request_camera_focus", null)
