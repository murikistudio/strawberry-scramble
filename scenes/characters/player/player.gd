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

var jumps_left := jump_times setget _set_jumps_left
var move_axis := Vector2.ZERO
var move_weight := Vector2.ZERO
var move_gravity := 0.0
var move_snap := Vector3.ZERO
var dead := false
var ground_type := "grass"
var respawn_position: Vector3

onready var state_manager: BaseStateManager = find_node("StateManager")
onready var state_stop: BaseState = state_manager.get_node("Stop")
onready var state_idle: BaseState = state_manager.get_node("Idle")
onready var _area: Area = find_node("Area")


# Setters and getters
func _set_jumps_left(value: int) -> void:
	jumps_left = int(max(value, 0))


# Built-in overrides
func _init() -> void:
	GameState.reset_level()


func _ready() -> void:
	respawn_position = global_translation
	GameEvents.emit_signal("player_emitted", self)
	GameEvents.connect("player_request_camera_focus", self, "_on_player_request_camera_focus")
	GameEvents.connect("player_enabled", self, "_on_player_enabled")


func _process(_delta: float) -> void:
	var can_pause := not get_tree().paused and Input.is_action_just_pressed("pause")

	if not dead and not GameState.completed and can_pause:
		GameEvents.emit_signal("level_paused")
		get_tree().paused = true


# Event handlers
# Avançar tempo no jogo.
func _on_Timer_timeout() -> void:
	if GameState.completed:
		return

	GameState.add_time_elapsed()


# Habilita ou desabilita o controle do jogador.
func _on_player_enabled(enabled: bool) -> void:
	state_manager.transition_to(state_idle if enabled else state_stop)


# Alterar objeto de foco da câmera.
func _on_player_request_camera_focus(target: Spatial) -> void:
	if not target:
		state_manager.transition_to(state_idle)
	else:
		state_manager.transition_to(state_stop)
