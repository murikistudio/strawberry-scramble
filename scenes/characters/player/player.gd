extends KinematicBody
class_name Player
# Classe principal do jogador.
# A lógica de suas ações é delegada aos seus respectivos estados.


# Signals
signal animation_changed(name, speed)
signal sfx_played(name)
signal smoke_spawned


# Variables
export(int, 1, 5, 1) var jump_times := 1

var jumps_left := jump_times setget _set_jumps_left
var input_axis := Vector2.ZERO
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


# Setters and getters
func _set_jumps_left(value: int) -> void:
	jumps_left = int(max(value, 0))


# Built-in overrides
func _init() -> void:
	GameState.reset_level()


func _ready() -> void:
	respawn_position = global_translation
	GameEvents.emit_signal("player_emitted", self)
	GameEvents.connect("player_enabled", self, "_on_player_enabled")


func _process(delta: float) -> void:
	var can_pause := not get_tree().paused and Input.is_action_just_pressed("pause")

	if not GameState.completed:
		GameState.add_time_elapsed(delta)

	if not dead and not GameState.completed and can_pause:
		GameEvents.emit_signal("level_paused")
		get_tree().paused = true


# Event handlers
# Habilita ou desabilita o controle do jogador.
func _on_player_enabled(enabled: bool) -> void:
	state_manager.transition_to(state_idle if enabled else state_stop)


# Helper methods
# Converte o Vector2 de entrada de controle para a direção alvo em Vector3.
static func get_axis_offset(axis_vec: Vector2) -> Vector3:
	return Vector3(-axis_vec.x, 0.0, axis_vec.y)
