extends PlayerBaseComponent


# Variables
export(PackedScene) var scene_water_splash: PackedScene
export(PackedScene) var scene_balloon_pop: PackedScene
onready var _ray_cast_ground: RayCast = player.find_node("RayCastGround")
var raycast_object: Spatial


# Built-in overrides
func _physics_process(_delta: float) -> void:
	if _ray_cast_ground.is_colliding():
		_process_ray_cast(_ray_cast_ground.get_collider())


# Private methods
# Processa a colisão do ray cast.
func _process_ray_cast(body: Spatial) -> void:
	if body == raycast_object:
		return

	raycast_object = body

	if body is GridMap:
		var body_name := body.name.to_lower()

		if body.is_in_group("death"):
			_process_death(body)

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


# Processar lógica de quando o jogador morrer.
func _process_death(node: Spatial) -> void:
	player.dead = true
	player._visual.visible = false
	GameState.add_times_died()

	# Spawnar efeito de água
	if node.is_in_group("water"):
		var water_splash: Spatial = scene_water_splash.instance()
		add_child(water_splash)
		water_splash.global_translation = player.global_translation
		water_splash.global_translation.y += 1.5
		GameAudio.play_sfx(DatabaseAudio.SFX_WATER)

	# Spawnar efeito de água
	elif node.is_in_group("thorns"):
		var balloon_pop: Spatial = scene_balloon_pop.instance()
		add_child(balloon_pop)
		balloon_pop.global_translation = player.global_translation
		balloon_pop.global_translation.y += -1.0

	yield(get_tree().create_timer(1.0, false), "timeout")
	player.global_translation = player.respawn_position + Vector3(0, 0, -1)
	player.dead = false
	player._visual.visible = true
	player.move_weight = Vector2.ZERO


# Event handlers
# Tratar colisão do jogador com inimigos e coletáveis.
func _on_Area_area_entered(area: Area) -> void:
	if player.dead:
		return

	if area.is_in_group("death"):
		_process_death(area)
		return


# Tratar colisão do jogador com obstáculos do cenário.
func _on_Area_body_entered(body: Spatial) -> void:
	if player.dead:
		return

	if body.is_in_group("death"):
		_process_death(body)
		return
