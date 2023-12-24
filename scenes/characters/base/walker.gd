extends Area
class_name EnemyWalker


# Variables
export(float, 0.5, 10.0, 0.1) var move_time := 5.0
export var target_x: float
export var target_z: float
export(float, 0.0, 10.0, 0.1) var follow_distance := 5.0
export(float, 0.0, 10.0, 0.1) var follow_limit := 1.0
onready var _anim_player: AnimationPlayer = find_node("AnimationPlayer")
onready var _initial_position := global_translation
onready var _target_position := Vector3.ZERO
onready var _player: Spatial


# Built-in overrides
func _init() -> void:
	GameEvents.connect("player_emitted", self, "_on_player_emitted")


func _ready() -> void:
	_loop_movement()


func _process(_delta: float) -> void:
	_follow_player()


# Private methods
# Loop de movimentação e rotação.
func _loop_movement() -> void:
	if _anim_player:
		_anim_player.play("walk_loop", -1, 1.25)

	# Movimentar apenas um eixo
	if target_x:
		target_z = 0.0

	elif target_z:
		target_x = 0.0

	if not target_x and not target_z:
		return

	_target_position = _initial_position + Vector3(target_x, 0.0, target_z)

	# Ciclo de movimento e rotação
	var tween := create_tween().set_loops().set_trans(Tween.TRANS_SINE)
	var rot_loop := 12
	var rot_degrees := 15.0
	var rot_interval := 0.015

	if not target_x:
		tween.tween_property(self, "global_translation:z", _target_position.z, move_time)
	elif not target_z:
		tween.tween_property(self, "global_translation:x", _target_position.x, move_time)

	for i in rot_loop:
		tween.tween_callback(self, "rotate_y", [deg2rad(rot_degrees)]).set_delay(rot_interval)

	if not target_x:
		tween.tween_property(self, "global_translation:z", _initial_position.z, move_time)
	elif not target_z:
		tween.tween_property(self, "global_translation:x", _initial_position.x, move_time)

	for i in rot_loop:
		tween.tween_callback(self, "rotate_y", [deg2rad(-rot_degrees)]).set_delay(rot_interval)


# Seguir o jogador em um dos eixos de acordo com a distância limite.
func _follow_player() -> void:
	if not _player or not follow_distance:
		return

	var distance := global_translation.distance_to(_player.global_translation)
	var follow_interpolation := 0.025

	if distance <= follow_distance:
		if not target_x:
			global_translation.x = lerp(
				global_translation.x,
				clamp(
					_player.global_translation.x,
					_initial_position.x - follow_limit,
					_initial_position.x + follow_limit
				),
				follow_interpolation
			)

		elif not target_z:
			global_translation.z = lerp(
				global_translation.z,
				clamp(
					_player.global_translation.z,
					_initial_position.z - follow_limit,
					_initial_position.z + follow_limit
				),
				follow_interpolation
			)

	else:
		if not target_x:
			global_translation.x = lerp(global_translation.x, _initial_position.x, follow_interpolation)

		elif not target_z:
			global_translation.z = lerp(global_translation.z, _initial_position.z, follow_interpolation)


# Event handlers
func _on_player_emitted(player: Spatial) -> void:
	_player = player
