extends Area


# Variables
var _activated := false

onready var _flag_on_mesh: Spatial = find_node("FlagOnMesh")
onready var _flag_off_mesh: Spatial = find_node("FlagOffMesh")
onready var _animation_player: AnimationPlayer = find_node("AnimationPlayer")


# Built-in overrides
func _ready() -> void:
	GameEvents.connect("level_checkpoint_touched", self, "_on_level_checkpoint_touched")
	_update_visual()


# Private methods
# Tocar animação, som e mostrar respectiva bandeira.
func _update_visual() -> void:
	if _flag_on_mesh.visible != _activated:
		_animation_player.play("checkpoint_touched")
		GameAudio.play_sfx(DatabaseAudio.SFX_CHECKPOINT)

	_flag_on_mesh.visible = _activated
	_flag_off_mesh.visible = not _activated


# Event handlers
# Emitir evento deste checkpoint quando o jogador encostá-lo.
func _on_Checkpoint_body_entered(body: Node) -> void:
	if _activated or not body.is_in_group("player"):
		return

	GameEvents.emit_signal("level_checkpoint_touched", self)


# Definir se este é o checkpoint ativo quando o evento for recebido.
func _on_level_checkpoint_touched(checkpoint: Area) -> void:
	_activated = checkpoint == self
	_update_visual()
