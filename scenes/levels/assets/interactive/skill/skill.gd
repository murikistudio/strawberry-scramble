extends Area


# Constants
const ROTATE_SPEED := 5.0


# Variables
export(String, "double_jump", "slam", "slide") var skill := ""
onready var _sprite: Sprite3D = $Sprite3D


# Built-in overrides
func _ready() -> void:
	if not skill:
		queue_free()


func _process(delta: float) -> void:
	_sprite.rotate_y(ROTATE_SPEED * delta)


# Event handlers
func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return

	GameState.player_skills[skill] = true
	GameAudio.play_sfx(DatabaseAudio.SFX_COLLECT, -10.0)
	GameEvents.emit_signal("player_skill_obtained", skill)
	queue_free()
