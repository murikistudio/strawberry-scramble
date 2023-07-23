extends Node
# Tela inicial contendo a animação do logo do estúdio.


# Signals
signal intro_finished


# Variables
var skip := false

onready var _anim_player: AnimationPlayer = find_node("AnimationPlayer")
onready var _screen_center: Node2D = find_node("ScreenCenter")


# Built-in overrides
func _ready() -> void:
	_anim_player.play("logo")
	$ColorRect.grab_focus()


func _process(_delta: float) -> void:
	_screen_center.position = get_viewport().get_visible_rect().size / 2


# Public methods
# Emitir sinal de finalização da intro.
func emit_intro_finished() -> void:
	if not skip:
		skip = true
		emit_signal("intro_finished")


# Event handlers
# Emitir sinal de finalização ao terminar animação da intro.
func _on_AnimationPlayer_animation_finished(_anim_name: String) -> void:
	emit_intro_finished()


# Pular introdução ao pressionar tocar ou clicar na tela
func _on_ColorRect_gui_input(event: InputEvent) -> void:
	if not event is InputEventMouseMotion:
		emit_intro_finished()
