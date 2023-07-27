extends KinematicBody
class_name Player
# Classe principal do jogador.
# A lógica de suas ações é delegada aos seus respectivos estados.


# Constants
const SFX_BASE := "res://scenes/characters/player/sfx/"
const SFX_JUMP_01 := SFX_BASE + "jump_01.wav"
const SFX_JUMP_02 := SFX_BASE + "jump_02.wav"
const SFX_JUMP_03 := SFX_BASE + "jump_03.wav"
const SFX_SWING_01 := SFX_BASE + "swing_01.wav"
const SFX_SWING_02 := SFX_BASE + "swing_02.wav"
const SFX_SWING_03 := SFX_BASE + "swing_03.wav"
const SFX_SWING_04 := SFX_BASE + "swing_04.wav"
const SFX_SWING_05 := SFX_BASE + "swing_05.wav"


# Variables
export var debug := false
export(int, 1, 5, 1) var jump_times := 1
export(float, 0.0, 2.0, 0.01) var gravity_force := 0.5
export(float, 0.0, 10.0, 0.1) var move_speed := 5.0
export(float, 0.0, 1.0, 0.01) var intertia_factor := 0.15
export(PackedScene) var scene_water_splash: PackedScene

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
onready var _anim_player: AnimationPlayer = find_node("AnimationPlayer")
onready var _area: Area = find_node("Area")
onready var _ray_cast: RayCast = find_node("RayCast")


# Setters and getters
func _set_jumps_left(value: int) -> void:
	jumps_left = int(max(value, 0))


# Built-in overrides
func _ready() -> void:
	_label_debug.visible = debug
	_directional_light.set_as_toplevel(true)
	_camera_axis.set_as_toplevel(true)
	_mesh_direction.set_as_toplevel(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)


func _physics_process(delta: float) -> void:
	if dead:
		return

	_directional_light.global_translation = global_translation

	_process_move(delta)
	_process_visual(delta)
	_process_camera(delta)

	if move_gravity < -50.0:
		get_tree().reload_current_scene()


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
			DatabaseSounds.SFX_STEP_GRASS_1,
			DatabaseSounds.SFX_STEP_GRASS_2,
		],
		"rock": [
			DatabaseSounds.SFX_STEP_ROCK_1,
			DatabaseSounds.SFX_STEP_ROCK_2,
		],
		"wood": [
			DatabaseSounds.SFX_STEP_WOOD_1,
			DatabaseSounds.SFX_STEP_WOOD_2,
		],
	}

	GameSounds.play_sfx(
		_get_random_item(sfx[ground_type]),
		step_volume,
		rand_range(1.05, 1.15)
	)


# Toca som aleatório de voz de pulo.
func play_sfx_jump(pitch := 1.0) -> void:
	if rand_range(0, 100) > 30:
		return

	var sfx := [
		SFX_JUMP_01,
		SFX_JUMP_02,
		SFX_JUMP_03,
	]
	GameSounds.play_sfx(_get_random_item(sfx), -4.0, pitch)


# Toca som aleatório de movimento rápido do ar.
func play_sfx_swing(pitch := 1.0) -> void:
	var sfx := [
		SFX_SWING_01,
		SFX_SWING_02,
		SFX_SWING_03,
		SFX_SWING_04,
		SFX_SWING_05,
	]
	GameSounds.play_sfx(_get_random_item(sfx), -4.0, pitch)


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
		GameSounds.play_sfx(DatabaseSounds.SFX_WATER)
		var water_splash: Spatial = scene_water_splash.instance()
		add_child(water_splash)
		water_splash.global_translation = global_translation
		water_splash.global_translation.y += 1.0
		yield(get_tree().create_timer(1.5, false), "timeout")
		get_tree().reload_current_scene()
		return

	if area.is_in_group("collectable"):
		GameSounds.play_sfx(DatabaseSounds.SFX_COLLECT)
		area.monitorable = false
