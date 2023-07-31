extends Area


# Variables
var _activated := false

onready var _animation_player: AnimationPlayer = $AnimationPlayer


# Built-in overrides
func _ready() -> void:
	GameEvents.connect("level_can_complete", self, "_on_level_can_complete")


# Event handlers
func _on_level_can_complete() -> void:
	if _activated:
		return

	_animation_player.play("door_open")
	_activated = true
