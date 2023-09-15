extends Area


# Variables
var _activated := false
onready var _animation_player: AnimationPlayer = $AnimationPlayer


# Built-in overrides
func _ready() -> void:
	GameEvents.connect("level_can_complete", self, "_on_level_can_complete")


# Event handlers
# Abre a porta caso se possa finalizar a fase.
func _on_level_can_complete() -> void:
	if _activated:
		return

	_activated = true
	_animation_player.play("door_open")


# Finalização de fase caso o jogador colidir com a casa.
func _on_House_body_entered(_body: Spatial) -> void:
	if GameState.current_trophy:
		GameState.completed = true
		GameEvents.emit_signal("level_dialog", "man", "complete")
		GameEvents.emit_signal("player_enabled", false)
		yield(get_tree().create_timer(2.0, false), "timeout")
		GameState.add_score()
		GameEvents.emit_signal("level_complete")
		prints("Level complete!")
	else:
		GameEvents.emit_signal("level_dialog", "mom", "incomplete")
		prints("Level incomplete...")
