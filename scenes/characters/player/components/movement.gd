extends PlayerBaseComponent


# Variables
onready var _ray_cast_ground: RayCast = player.find_node("RayCastGround")
var raycast_object: Spatial


# Built-in overrides
func _ready() -> void:
	pass


func _physics_process(delta: float) -> void:
	if player.dead:
		return

	_process_move(delta)


# Private methods
# Processa a gravidade e movimentação do jogador seguindo os eixos do controle.
func _process_move(_delta: float) -> void:
	var move_vec: Vector2 = player.move_weight * player.move_speed
	var translation_vec := Vector3(-move_vec.x, player.move_gravity, move_vec.y)

	player.move_and_slide_with_snap(translation_vec, player.move_snap, Vector3.UP, true)

	player.move_snap = -player.get_floor_normal() if player.is_on_floor() else Vector3.ZERO
	player.move_weight = lerp(player.move_weight, player.move_axis, player.intertia_factor)

	if _ray_cast_ground.is_colliding():
		_process_ray_cast(_ray_cast_ground.get_collider())

	if player.is_on_floor():
		player.jumps_left = player.jump_times
		player.move_gravity = 0.0
	else:
		player.move_gravity = player.move_gravity - player.gravity_force

	if player.is_on_ceiling() and player.move_gravity > 0.0:
		player.move_gravity = -1.0


# Processa a colisão do ray cast.
func _process_ray_cast(body: Spatial) -> void:
	if body == raycast_object:
		return

	raycast_object = body

	if body is GridMap:
		var body_name := body.name.to_lower()

		if body.is_in_group("death"):
			player._process_death(body)

		if "grass" in body_name:
			player.ground_type = "grass"

		elif "bridge" in body_name or "fence" in body_name or "tree" in body_name:
			player.ground_type = "wood"

		else:
			player.ground_type = "rock"

		return

	var root := body.find_parent("Visual")

	if not root:
		return

	root = root.get_parent()

	if root.is_in_group("ground"):
		if root.is_in_group("grass"):
			player.ground_type = "grass"

		elif root.is_in_group("rock"):
			player.ground_type = "rock"

		elif root.is_in_group("wood"):
			player.ground_type = "wood"
