extends Area


# Variables
export var target: NodePath
var _pushed := false
onready var _anim_player: AnimationPlayer = find_node("AnimationPlayer")


# Built-in overrides
func _ready() -> void:
	_anim_player.play("RESET")
	GameEvents.connect("level_lever_touched", self, "_on_level_lever_touched")


# Event handlers
func _on_level_lever_touched(lever: Node) -> void:
	if _pushed or not target or lever != self:
		return

	var target_node := get_node(target)

	GameEvents.emit_signal("level_lever_pushed", target_node)
	_anim_player.play("push")
	_pushed = true
