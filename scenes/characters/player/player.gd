extends KinematicBody
class_name Player
# Classe principal do jogador.
# A lógica de suas ações é delegada aos seus respectivos estados.


# Signals
signal animation_changed(name, speed)
signal sfx_played(name)


# Variables
export(int, 1, 5, 1) var jump_times := 1
export(float, 0.0, 2.0, 0.01) var gravity_force := 0.5
export(float, 0.0, 10.0, 0.1) var move_speed := 5.0
export(float, 0.0, 1.0, 0.01) var intertia_factor := 0.15
export(float, 0.5, 2.0, 0.01) var view_forward_multiplier := 1.0
export(Array, ShaderMaterial) var shaders_to_update: Array

var jumps_left := jump_times setget _set_jumps_left
var move_axis := Vector2.ZERO
var move_weight := Vector2.ZERO
var move_gravity := 0.0
var move_snap := Vector3.ZERO
var dead := false
var ground_type := "grass"
var respawn_position: Vector3

onready var _state_manager: BaseStateManager = find_node("StateManager")
onready var _state_stop: BaseState = _state_manager.get_node("Stop")
onready var _state_idle: BaseState = _state_manager.get_node("Idle")
onready var _visual: Spatial = find_node("Visual")
onready var _mesh_direction: MeshInstance = find_node("MeshDirection")
onready var _directional_light: DirectionalLight = find_node("DirectionalLight")
onready var _area: Area = find_node("Area")


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

	_process_visual(delta)


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


# Helper methods
# Converte o Vector2 de entrada de controle para a direção alvo em Vector3.
static func _get_axis_offset(axis_vec: Vector2) -> Vector3:
	return Vector3(-axis_vec.x, 0.0, axis_vec.y)


# Event handlers
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
