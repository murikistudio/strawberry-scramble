extends Spatial


# Variables
onready var _anim_player: AnimationPlayer = $AnimationPlayer
onready var _visual: Spatial = $Visual


# Built in overrides
func _ready() -> void:
	(_visual.get_child(0) as GeometryInstance).cast_shadow = false
	play()


# Public methods
func play() -> void:
	visible = true
	_anim_player.play("idle_loop", -1, 0.7)


func stop() -> void:
	visible = false
	_anim_player.stop()
