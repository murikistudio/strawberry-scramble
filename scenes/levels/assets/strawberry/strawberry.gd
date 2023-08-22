extends Area


# Variables
var _touched := false

onready var _visual: Spatial = $Visual
onready var _animation_player: AnimationPlayer = $AnimationPlayer


# Built-in overrides
func _ready() -> void:
	_animation_player.play("idle_loop")
	GameState.items_available += 1
	GameEvents.emit_signal("player_item_available")


func _process(_delta: float) -> void:
	if not _touched and not monitorable:
		_touched = true
		_animation_player.play("collected", -1, 2.0)


# Event handlers
func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "collected":
		queue_free()
