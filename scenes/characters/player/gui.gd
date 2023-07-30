extends CanvasLayer


func _ready() -> void:
	show_mouse_cursor(false)
	GameEvents.connect("level_paused", self, "_on_level_paused")
	GameEvents.connect("level_game_over", self, "_on_level_game_over")
	GameEvents.connect("level_resumed", self, "_on_level_resumed")
	GameEvents.connect("level_restarted", self, "_on_level_restarted")


func show_mouse_cursor(show: bool) -> void:
	Input.set_mouse_mode(
		Input.MOUSE_MODE_VISIBLE if show else Input.MOUSE_MODE_HIDDEN
	)


# Event handlers
func _on_level_paused() -> void:
	show_mouse_cursor(true)
	GuiTransitions.go_to("Pause")


func _on_level_game_over() -> void:
	show_mouse_cursor(true)
	GuiTransitions.hide("Hud")
	GuiTransitions.show("GameOver")


func _on_level_resumed() -> void:
	show_mouse_cursor(false)
	GuiTransitions.go_to("Hud")
	yield(GuiTransitions, "hide_completed")
	get_tree().paused = false


func _on_level_restarted() -> void:
	GuiTransitions.hide()
	GameTransition.show()
	yield(GameTransition, "show_completed")
	get_tree().reload_current_scene()
	GameTransition.hide()
	get_tree().paused = false


func _on_Options_options_exited() -> void:
	GuiTransitions.go_to("GameOver" if GameState.game_over else "Pause")
