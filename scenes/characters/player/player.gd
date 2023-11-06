extends KinematicBody
class_name Player
# Classe principal do jogador.
# A lógica de suas ações é delegada aos seus respectivos estados.


# Signals
signal animation_changed(name, speed)
signal sfx_stepped
signal sfx_jumped
signal sfx_swinged


# Variables
export(int, 1, 5, 1) var jump_times := 1
export(float, 0.0, 2.0, 0.01) var gravity_force := 0.5
export(float, 0.0, 10.0, 0.1) var move_speed := 5.0
export(float, 0.0, 1.0, 0.01) var intertia_factor := 0.15
export(float, 0.5, 2.0, 0.01) var view_forward_multiplier := 1.0
export(PackedScene) var scene_water_splash: PackedScene
export(PackedScene) var scene_balloon_pop: PackedScene
export(Array, ShaderMaterial) var shaders_to_update: Array

var jumps_left := jump_times setget _set_jumps_left
var move_axis := Vector2.ZERO
var move_weight := Vector2.ZERO
var move_gravity := 0.0
var move_snap := Vector3.ZERO
var dead := false
var ground_type := "grass"
var respawn_position: Vector3
var raycast_object: Spatial

onready var _state_manager: BaseStateManager = find_node("StateManager")
onready var _state_stop: BaseState = _state_manager.get_node("Stop")
onready var _state_idle: BaseState = _state_manager.get_node("Idle")
onready var _visual: Spatial = find_node("Visual")
onready var _mesh_direction: MeshInstance = find_node("MeshDirection")
onready var _directional_light: DirectionalLight = find_node("DirectionalLight")
onready var _area: Area = find_node("Area")
onready var _ray_cast_ground: RayCast = find_node("RayCastGround")


# Setters and getters
func _set_jumps_left(value: int) -> void:
	jumps_left = int(max(value, 0))


# Built-in overrides
func _init() -> void:
	GameState.reset_level()


func _ready() -> void:
	respawn_position = global_translation
	_directional_light.set_as_toplevel(true)
	_mesh_direction.set_as_toplevel(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	GameEvents.emit_signal("player_emitted", self)
	GameEvents.connect("player_request_camera_focus", self, "_on_player_request_camera_focus")
	GameEvents.connect("level_cannon_entered", self, "_on_level_cannon_entered")
	GameEvents.connect("level_checkpoint_touched", self, "_on_level_checkpoint_touched")
	GameEvents.connect("player_enabled", self, "_on_player_enabled")

	for material in shaders_to_update:
		if not material:
			continue

		GameCore.register_global_shader_param("player_world_position", material)


func _physics_process(delta: float) -> void:
	if dead:
		return

	_directional_light.global_translation = global_translation

	_process_move(delta)
	_process_visual(delta)

	if move_gravity < -50.0:
		get_tree().reload_current_scene()


func _process(_delta: float) -> void:
	GameCore.set_global_shader_param("player_world_position", global_translation)

	if (
		not dead
		and not GameState.completed
		and not get_tree().paused
		and Input.is_action_just_pressed("pause")
	):
		GameEvents.emit_signal("level_paused")
		get_tree().paused = true


# Private methods
# Atualiza as malhas visuais de acordo com o estado.
func _process_visual(_delta: float) -> void:
	var target_vec: Vector3 = global_translation + _get_axis_offset(move_weight) * view_forward_multiplier
	var interp_vec: Vector3 = lerp(global_translation, target_vec, 0.01)

	if move_weight.length() > 0.1:
		look_at(interp_vec, Vector3.UP)

	_mesh_direction.global_translation = target_vec


# Processa a gravidade e movimentação do jogador seguindo os eixos do controle.
func _process_move(_delta: float) -> void:
	var move_vec: Vector2 = move_weight * move_speed
	var translation_vec := Vector3(-move_vec.x, move_gravity, move_vec.y)

	move_and_slide_with_snap(translation_vec, move_snap, Vector3.UP, true)

	move_snap = -get_floor_normal() if is_on_floor() else Vector3.ZERO
	move_weight = lerp(move_weight, move_axis, intertia_factor)

	if _ray_cast_ground.is_colliding():
		_process_ray_cast(_ray_cast_ground.get_collider())

	if is_on_floor():
		jumps_left = jump_times
		move_gravity = 0.0
	else:
		move_gravity = move_gravity - gravity_force

	if is_on_ceiling() and move_gravity > 0.0:
		move_gravity = -1.0


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
			ground_type = "grass"

		elif "bridge" in body_name or "fence" in body_name or "tree" in body_name:
			ground_type = "wood"

		else:
			ground_type = "rock"

		return

	var root := body.find_parent("Visual")

	if not root:
		return

	root = root.get_parent()

	if root.is_in_group("ground"):
		if root.is_in_group("grass"):
			ground_type = "grass"

		elif root.is_in_group("rock"):
			ground_type = "rock"

		elif root.is_in_group("wood"):
			ground_type = "wood"


# Processar lógica de quando o jogador morrer.
func _process_death(node: Spatial) -> void:
	dead = true
	_visual.visible = false
	GameState.add_times_died()

	# Spawnar efeito de água
	if node.is_in_group("water"):
		var water_splash: Spatial = scene_water_splash.instance()
		add_child(water_splash)
		water_splash.global_translation = global_translation
		water_splash.global_translation.y += 1.5
		GameAudio.play_sfx(DatabaseAudio.SFX_WATER)

	# Spawnar efeito de água
	elif node.is_in_group("thorns"):
		var balloon_pop: Spatial = scene_balloon_pop.instance()
		add_child(balloon_pop)
		balloon_pop.global_translation = global_translation
		balloon_pop.global_translation.y += -1.0

	yield(get_tree().create_timer(1.0, false), "timeout")
	global_translation = respawn_position + Vector3(0, 0, -1)
	dead = false
	_visual.visible = true
	move_weight = Vector2.ZERO


# Helper methods
# Converte o Vector2 de entrada de controle para a direção alvo em Vector3.
static func _get_axis_offset(axis_vec: Vector2) -> Vector3:
	return Vector3(-axis_vec.x, 0.0, axis_vec.y)


# Event handlers
# Tratar colisão do jogador com inimigos e coletáveis.
func _on_Area_area_entered(area: Area) -> void:
	if dead:
		return

	if area.is_in_group("death"):
		_process_death(area)
		return


# Tratar colisão do jogador com obstáculos do cenário.
func _on_Area_body_entered(body: Spatial) -> void:
	if dead:
		return

	if body.is_in_group("death"):
		_process_death(body)
		return


# Avançar tempo no jogo.
func _on_Timer_timeout() -> void:
	if GameState.completed:
		return

	GameState.add_time_elapsed()


# Habilita ou desabilita o controle do jogador.
func _on_player_enabled(enabled: bool) -> void:
	_state_manager.transition_to(_state_idle if enabled else _state_stop)


# Alterar objeto de foco da câmera.
func _on_player_request_camera_focus(target: Spatial) -> void:
	if not target:
		_state_manager.transition_to(_state_manager.get_node("Idle"))
	else:
		_state_manager.transition_to(_state_stop)


# Tratar colisão do jogador com o canhão.
func _on_level_cannon_entered(target: Spatial) -> void:
	_state_manager.transition_to(_state_stop)
	_visual.visible = false
	yield(get_tree().create_timer(3.0, false), "timeout")
	GameEvents.emit_signal("player_request_camera_focus", null)
	global_translation = target.global_translation + Vector3(0, 5, 0)
	_visual.visible = true
	_state_manager.transition_to(_state_idle)


# Definir posição de respawn a partir do checkpoint.
func _on_level_checkpoint_touched(checkpoint: Spatial) -> void:
	respawn_position = checkpoint.global_translation
