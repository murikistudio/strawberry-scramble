extends Area


# Variables
var _active := false

onready var _flag_on_mesh: Spatial = find_node("FlagOnMesh")
onready var _flag_off_mesh: Spatial = find_node("FlagOffMesh")
onready var _animation_player: AnimationPlayer = find_node("AnimationPlayer")


# Built-in overrides
func _ready() -> void:
	GameEvents.connect("level_checkpoint_touched", self, "_on_level_checkpoint_touched")
	_update_visual()


# Private methods
func _update_visual() -> void:
	if _flag_on_mesh.visible != _active:
		_animation_player.play("checkpoint_touched")
		GameAudio.play_sfx(DatabaseAudio.SFX_CHECKPOINT)

	_flag_on_mesh.visible = _active
	_flag_off_mesh.visible = not _active


# Event handlers
func _on_level_checkpoint_touched(checkpoint: Area) -> void:
	_active = checkpoint == self
	_update_visual()
