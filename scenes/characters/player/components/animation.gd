extends Node


# Variables
export(NodePath) var player: NodePath
var _animation := {
	"name": "idle_loop",
	"speed": 1.0,
	"blend": 0.2,
}
onready var _player: Player = get_node(player)
onready var _anim_player: AnimationPlayer = _player.get_node("Visual").find_node("AnimationPlayer")


# Built-in overrides
func _ready() -> void:
	_player.connect("animation_changed", self, "_set_animation")


func _process(_delta: float) -> void:
	if _animation["name"] == "run_loop":
		_anim_player.playback_speed = _player.move_weight.length()
	else:
		_anim_player.playback_speed = _animation["speed"]


# Private methods
# Define a animação atual do jogador.
func _set_animation(anim_name: String, speed := 1.0) -> void:
	_animation["name"] = anim_name
	_animation["speed"] = speed


# Executado quando o jogador entra em um novo estado.
func _on_StateManager_state_entered(_state: BaseState) -> void:
	_anim_player.play(
		_animation["name"],
		_animation["blend"],
		_animation["speed"]
	)
