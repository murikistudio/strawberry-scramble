extends KinematicBody
class_name Player
# Classe principal do jogador.
# A lógica de suas ações é delegada aos seus respectivos estados.


# Variables
export var debug := false
export(int, 1, 5, 1) var jump_times := 1
export(float, 0.0, 2.0, 0.01) var gravity_force := 0.5
export(float, 0.0, 10.0, 0.1) var move_speed := 5.0
export(float, 0.0, 1.0, 0.01) var intertia_factor := 0.15
export(PackedScene) var scene_water_splash: PackedScene
export(PackedScene) var scene_balloon_pop: PackedScene

var input_move_axis := Vector2.ZERO
var jumps_left := jump_times setget _set_jumps_left
var direction_axis := Vector2.UP
var move_axis := Vector2.ZERO
var move_speed_multiplier := 1.0
var move_weight := Vector2.ZERO
var move_gravity := 0.0
var move_snap := Vector3.ZERO
var dead := false
var ground_type := "grass"
var respawn_position: Vector3
var raycast_object: Spatial
var animation := {
	"name": "idle_loop",
	"speed": 1.0,
	"blend": 0.2,
}

onready var _state_manager: BaseStateManager = find_node("StateManager")
onready var _visual: Spatial = find_node("Visual")
onready var _camera: Camera = find_node("Camera")
onready var _camera_axis: Position3D = find_node("CameraAxis")
onready var _mesh_direction: MeshInstance = find_node("MeshDirection")
onready var _label_debug: Label3D = find_node("LabelDebug")
onready var _directional_light: DirectionalLight = find_node("DirectionalLight")
onready var _anim_player: AnimationPlayer = $Visual.find_node("AnimationPlayer")
onready var _area: Area = find_node("Area")
onready var _ray_cast: RayCast = find_node("RayCast")


# Setters and getters
func _set_jumps_left(value: int) -> void:
	jumps_left = int(max(value, 0))


# Built-in overrides
func _init() -> void:
	GameState.reset_level()


func _ready() -> void:
	respawn_position = global_translation
	_label_debug.visible = debug
	_directional_light.set_as_toplevel(true)
	_camera_axis.set_as_toplevel(true)
	_mesh_direction.set_as_toplevel(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	GameEvents.emit_signal("level_dialog", "mom", "start")


func _physics_process(delta: float) -> void:
	if dead:
		return

	_directional_light.global_translation = global_translation

	_process_move(delta)
	_process_visual(delta)
	_process_camera(delta)

	if move_gravity < -50.0:
		get_tree().reload_current_scene()


func _process(_delta: float) -> void:
	if (
		not dead
		and not GameState.completed
		and not get_tree().paused
		and Input.is_action_just_pressed("pause")
	):
		GameEvents.emit_signal("level_paused")
		get_tree().paused = true


# Public methods
# Define a animação atual do jogador.
func set_animation(anim_name: String, speed := 1.0, blend := 0.2) -> void:
	animation["name"] = anim_name
	animation["speed"] = speed
	animation["blend"] = blend


# Toca som aleatório de voz de passo.
func play_sfx_step() -> void:
	var step_volume := -22.0
	var sfx := {
		"grass": [
			DatabaseAudio.SFX_STEP_GRASS_1,
			DatabaseAudio.SFX_STEP_GRASS_2,
		],
		"rock": [
			DatabaseAudio.SFX_STEP_ROCK_1,
			DatabaseAudio.SFX_STEP_ROCK_2,
		],
		"wood": [
			DatabaseAudio.SFX_STEP_WOOD_1,
			DatabaseAudio.SFX_STEP_WOOD_2,
		],
	}

	GameAudio.play_sfx(
		_get_random_item(sfx[ground_type]),
		step_volume,
		rand_range(1.05, 1.15)
	)


# Toca som aleatório de voz de pulo.
func play_sfx_jump(pitch := 1.2) -> void:
	if rand_range(0, 100) > 30:
		return

	var sfx := [
		DatabaseAudio.SFX_JUMP_1,
		DatabaseAudio.SFX_JUMP_2,
		DatabaseAudio.SFX_JUMP_3,
	]
	GameAudio.play_sfx(_get_random_item(sfx), -4.0, pitch)


# Toca som aleatório de movimento rápido do ar.
func play_sfx_swing(pitch := 1.0) -> void:
	var sfx := [
		DatabaseAudio.SFX_SWING_1,
		DatabaseAudio.SFX_SWING_2,
		DatabaseAudio.SFX_SWING_3,
	]
	GameAudio.play_sfx(_get_random_item(sfx), -12.0, pitch)


# Private methods
# Atualiza as malhas visuais de acordo com o estado.
func _process_visual(_delta: float) -> void:
	var target_vec: Vector3 = global_translation + _get_axis_offset(move_weight)
	var interp_vec: Vector3 = lerp(global_translation, target_vec, 0.01)

	_anim_player.playback_speed = move_weight.length() if animation["name"] == "run_loop" else animation["speed"]

	if move_weight.length() > 0.1:
		look_at(interp_vec, Vector3.UP)

	_mesh_direction.global_translation = target_vec


# Processa a gravidade e movimentação do jogador seguindo os eixos do controle.
func _process_move(_delta: float) -> void:
	var move_vec: Vector2 = move_weight * move_speed * move_speed_multiplier
	var translation_vec := Vector3(-move_vec.x, move_gravity, move_vec.y)

	move_and_slide_with_snap(translation_vec, move_snap, Vector3.UP, true)

	move_snap = -get_floor_normal() if is_on_floor() else Vector3.ZERO
	move_weight = lerp(move_weight, move_axis, intertia_factor)

	if _ray_cast.is_colliding():
		_process_ray_cast(_ray_cast.get_collider())

	if move_axis.length():
		direction_axis = move_axis.normalized()

	if is_on_floor():
		jumps_left = jump_times
		move_gravity = 0.0
	else:
		move_gravity = move_gravity - gravity_force

	if is_on_ceiling() and move_gravity > 0.0:
		move_gravity = -1.0


# Processa a movimentação e suavização da câmera.
func _process_camera(_delta: float) -> void:
	if dead:
		return

	_camera_axis.global_translation = _camera_axis.global_translation.linear_interpolate(_mesh_direction.global_translation, 0.1)


# Processa a colisão do ray cast.
func _process_ray_cast(body: Spatial) -> void:
	if body == raycast_object:
		return

	raycast_object = body

	if body is GridMap:
		var body_name := body.name.to_lower()

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


# Helper methods
# Converte o Vector2 de entrada de controle para a direção alvo em Vector3.
static func _get_axis_offset(axis_vec: Vector2) -> Vector3:
	return Vector3(-axis_vec.x, 0.0, axis_vec.y)


# Retorna um item aleatório da array.
static func _get_random_item(array: Array):
	return array[randi() % array.size()]


# Event handlers
# Executado quando o jogador entra em um novo estado.
func _on_StateManager_state_entered(state: BaseState) -> void:
	if debug and _label_debug:
		_label_debug.text = state.name

	if _anim_player:
		_anim_player.play(
			animation["name"],
			animation["blend"],
			animation["speed"]
		)


# Tratar colisão do jogador com obstáculos do cenário e coletáveis.
func _on_Area_area_entered(area: Area) -> void:
	if dead:
		return

	if area.is_in_group("death"):
		dead = true
		_visual.visible = false
		GameState.add_times_died()

		# Spawnar efeito de água
		if area.is_in_group("water"):
			var water_splash: Spatial = scene_water_splash.instance()
			add_child(water_splash)
			water_splash.set_as_toplevel(true)
			water_splash.global_translation = global_translation
			water_splash.global_translation.y += 2.0
			GameAudio.play_sfx(DatabaseAudio.SFX_WATER)

		# Spawnar efeito de água
		elif area.is_in_group("thorns"):
			var balloon_pop: Spatial = scene_balloon_pop.instance()
			add_child(balloon_pop)
			balloon_pop.set_as_toplevel(true)
			balloon_pop.global_translation = global_translation
			balloon_pop.global_translation.y += -1.0
			GameAudio.play_sfx(DatabaseAudio.SFX_BALLOON_POP)

		yield(get_tree().create_timer(1.0, false), "timeout")
		global_translation = respawn_position
		dead = false
		_visual.visible = true
		move_weight = Vector2.ZERO
		return

	if area.is_in_group("collectable"):
		GameState.add_item_collected()
		GameAudio.play_sfx(DatabaseAudio.SFX_COLLECT)
		area.monitorable = false

	if area.is_in_group("checkpoint"):
		if area.global_translation != respawn_position:
			GameAudio.play_sfx(DatabaseAudio.SFX_CHECKPOINT)

		respawn_position = area.global_translation
		GameEvents.emit_signal("level_checkpoint_touched", area)

	if area.is_in_group("house"):
		if GameState.current_trophy:
			GameEvents.emit_signal("level_dialog", "man", "complete")
			area.monitorable = false
			GameState.completed = true
			_state_manager.transition_to(_state_manager.get_node("Stop"))
			yield(get_tree().create_timer(2.0, false), "timeout")
			GameState.add_score()
			GameEvents.emit_signal("level_complete")
			prints("Level complete!")
		else:
			GameEvents.emit_signal("level_dialog", "mom", "incomplete")
			prints("Level incomplete...")

	if area.is_in_group("lever"):
		GameEvents.emit_signal("level_lever_touched", area)


# Avançar tempo no jogo.
func _on_Timer_timeout() -> void:
	if GameState.completed:
		return

	GameState.add_time_elapsed()
