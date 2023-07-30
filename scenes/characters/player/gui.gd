extends CanvasLayer
# Gerenciador de todos os layouts de interface de usuário durante a fase.


# Built-in overrides
func _ready() -> void:
	show_mouse_cursor(false)
	GameEvents.connect("level_paused", self, "_on_level_paused")
	GameEvents.connect("level_game_over", self, "_on_level_game_over")
	GameEvents.connect("level_resumed", self, "_on_level_resumed")
	GameEvents.connect("level_restarted", self, "_on_level_restarted")


# Public methods
# Mostrar ou ocultar cursor do mouse.
func show_mouse_cursor(show: bool) -> void:
	Input.set_mouse_mode(
		Input.MOUSE_MODE_VISIBLE if show else Input.MOUSE_MODE_HIDDEN
	)


# Event handlers
# Ocultar hud e mostrar menu de pausa quando jogo for pausado.
func _on_level_paused() -> void:
	show_mouse_cursor(true)
	GuiTransitions.hide("Hud")
	GuiTransitions.show("Pause")


# Ocultar hud e mostrar menu de game over quando o jogador morrer.
func _on_level_game_over() -> void:
	show_mouse_cursor(true)
	GuiTransitions.hide("Hud")
	GuiTransitions.show("GameOver")


# Ocultar menu de pausa e mostrar hud quando jogo for resumido.
func _on_level_resumed() -> void:
	show_mouse_cursor(false)
	GuiTransitions.hide("Pause")
	GuiTransitions.show("Hud")
	yield(GuiTransitions, "show_completed")
	get_tree().paused = false


# Ocultar Hud e mostrar menu de pausa quando jogo for pausado.
func _on_level_restarted() -> void:
	GuiTransitions.hide()
	GameTransition.show()
	yield(GameTransition, "show_completed")
	get_tree().reload_current_scene()
	GameTransition.hide()
	get_tree().paused = false


func _on_Options_options_exited() -> void:
	GuiTransitions.go_to("GameOver" if GameState.game_over else "Pause")
