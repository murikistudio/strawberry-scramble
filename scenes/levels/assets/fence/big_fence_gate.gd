extends Spatial


# Variables
var _opened := false
onready var _anim_player: AnimationPlayer = find_node("AnimationPlayer")


# Built-in overrides
func _ready() -> void:
	GameEvents.connect("level_lever_pushed", self, "_on_level_lever_pushed")


# Event handlers
func _on_level_lever_pushed(target: Node) -> void:
	if _opened or target != self:
		return

	_opened = true
	_anim_player.play("open")
	GameAudio.play_sfx(DatabaseAudio.SFX_GATE)
