extends PlayerBaseComponent


# Variables
export(float, 0.0, 2.0, 0.01) var gravity_force := 0.5
export(float, 0.0, 10.0, 0.1) var move_speed := 4.0
export(float, 0.0, 1.0, 0.01) var intertia_factor := 0.18


# Built-in overrides
func _physics_process(delta: float) -> void:
	if player.dead:
		return

	_process_move(delta)


# Private methods
# Processa a gravidade e movimentação do jogador seguindo os eixos do controle.
func _process_move(_delta: float) -> void:
	var move_vec: Vector2 = player.move_weight * move_speed
	var translation_vec := Vector3(-move_vec.x, player.move_gravity, move_vec.y)

	player.move_and_slide_with_snap(translation_vec, player.move_snap, Vector3.UP, true)

	player.move_snap = -player.get_floor_normal() if player.is_on_floor() else Vector3.ZERO
	player.move_weight = lerp(player.move_weight, player.move_axis, intertia_factor)

	if player.is_on_floor():
		player.jumps_left = player.jump_times
		player.move_gravity = 0.0
	else:
		player.move_gravity = player.move_gravity - gravity_force

	if player.is_on_ceiling() and player.move_gravity > 0.0:
		player.move_gravity = -1.0