extends Area


# Variables
export var target: NodePath
var _pushed := false
onready var _anim_player: AnimationPlayer = find_node("AnimationPlayer")


# Built-in overrides
func _ready() -> void:
	_anim_player.play("RESET")


# Event handlers
# Emite evento de alavanca puxada quando o jogador tocá-la.
func _on_BigFenceLever_body_entered(body: Spatial) -> void:
	if _pushed or not body.is_in_group("player"):
		return

	_pushed = true
	_anim_player.play("push")
	GameAudio.play_sfx(DatabaseAudio.SFX_LEVER)
	yield(get_tree().create_timer(1.0, false), "timeout")
	GameEvents.emit_signal("level_lever_pushed", get_node(target))
