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


# Event handlers
func _on_Strawberry_body_entered(body: Spatial) -> void:
	if _touched or not body.is_in_group("player"):
		return

	_touched = true
	GameState.add_item_collected()
	GameAudio.play_sfx(DatabaseAudio.SFX_COLLECT, -10.0)
	_animation_player.play("collected", -1, 2.0)


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "collected":
		queue_free()
