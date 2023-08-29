extends Area


# Variables
export(float, 0.5, 10.0, 0.1) var move_time := 5.0
export var target_x: float
export var target_z: float
export(float, 0.0, 10.0, 0.1) var follow_distance := 2.0
onready var _anim_player: AnimationPlayer = $AnimationPlayer
onready var _initial_position := global_translation
onready var _target_position := Vector3()


# Built-in overrides
func _ready() -> void:
	_loop_movement()


# Private methods
func _loop_movement() -> void:
	# Animação
	_anim_player.play("walk_loop", -1, 1.25)

	# Movimentar apenas um eixo
	if target_x:
		target_z = 0.0

	elif target_z:
		target_x = 0.0

	_target_position = _initial_position + Vector3(target_x, 0.0, target_z)

	# Ciclo de movimento e rotação
	var tween := create_tween().set_loops().set_trans(Tween.TRANS_SINE)
	var rot_loop := 12
	var rot_degrees := 15.0
	var rot_interval := 0.015

	tween.tween_callback(self, "look_at", [_target_position, Vector3.UP])
	tween.tween_property(self, "global_translation", _target_position, move_time)

	for i in rot_loop:
		tween.tween_callback(self, "rotate_y", [deg2rad(rot_degrees)]).set_delay(rot_interval)

	tween.tween_callback(self, "look_at", [_initial_position, Vector3.UP])
	tween.tween_property(self, "global_translation", _initial_position, move_time)

	for i in rot_loop:
		tween.tween_callback(self, "rotate_y", [deg2rad(-rot_degrees)]).set_delay(rot_interval)
