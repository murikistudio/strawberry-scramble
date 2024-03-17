extends PlayerBaseComponent


# Variables
onready var _ray_cast_ground: RayCast = player.find_node("RayCastGround")
onready var _visual: Spatial = player.find_node("Visual")
var raycast_object: Spatial


# Built-in overrides
func _ready() -> void:
	GameEvents.connect("level_cannon_entered", self, "_on_level_cannon_entered")
	GameEvents.connect("level_checkpoint_touched", self, "_on_level_checkpoint_touched")


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

		if body.is_in_group("grass"):
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
	if player.dead:
		return

	player.dead = true
	GameState.add_times_died()

	# Spawnar efeito de água
	if node.is_in_group("water"):
		player.emit_signal("died", "death_water")

	# Spawnar efeito de água
	elif node.is_in_group("thorns"):
		player.emit_signal("died", "death_balloon")

	else:
		player.emit_signal("died", "death_generic")


# Processar colisão do jogador com inimigos.
func _kill_enemy(area: Area, jump := true) -> void:
	if player.dead or not area.is_in_group("enemy"):
		return

	if area.get("dead"):
		return

	if jump:
		player.reset_jumps_left()
		player.state_manager.transition_to(player.state_manager.get_node("Jump"))

	GameEvents.emit_signal("enemy_killed", area)


# Event handlers
# Tratar colisão do jogador com inimigos e coletáveis.
func _on_Area_area_entered(area: Area) -> void:
	if player.dead:
		return

	if area.is_in_group("death"):
		if area.is_in_group("enemy"):
			if area.get("dead"):
				return

			if player.state_manager.current_state.name == "Slide":
				_kill_enemy(area, false)
				return

		_process_death(area)


# Tratar colisão do jogador ao pular em inimigos.
func _on_AreaJump_area_entered(area: Area) -> void:
	_kill_enemy(area)


# Tratar colisão do jogador com obstáculos do cenário.
func _on_Area_body_entered(body: Spatial) -> void:
	if player.dead:
		return

	if body.is_in_group("death"):
		_process_death(body)
		return


# Tratar colisão do jogador com o canhão.
func _on_level_cannon_entered(target: Spatial) -> void:
	player.state_manager.transition_to(player.state_stop)
	_visual.visible = false
	yield(get_tree().create_timer(3.0, false), "timeout")
	GameEvents.emit_signal("player_request_camera_focus", null)
	player.global_translation = target.global_translation + Vector3(0, 5, 0)
	_visual.visible = true
	player.state_manager.transition_to(player.state_idle)


# Definir posição de respawn a partir do checkpoint.
func _on_level_checkpoint_touched(checkpoint: Spatial) -> void:
	player.respawn_position = checkpoint.global_translation
