extends CanvasLayer


# Signals
signal show_completed
signal hide_completed


# Variables
export var fade_speed := 0.3

onready var _texture_rect: TextureRect = $TextureRect


# Built-in overrides
func _ready() -> void:
	_texture_rect.self_modulate.a = 0.0
	visible = false


# Mostrar overlay no jogo.
func show() -> void:
	var tween := create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(_texture_rect, "self_modulate:a", 1.0, fade_speed)
	visible = true
	yield(tween, "finished")
	emit_signal("show_completed")


# Esconder overlay no jogo.
func hide() -> void:
	var tween := create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(_texture_rect, "self_modulate:a", 0.0, fade_speed)
	yield(tween, "finished")
	emit_signal("hide_completed")
	visible = false
