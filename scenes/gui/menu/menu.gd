extends Control
# Menu inicial do jogo.


onready var _button_play: BaseButton = find_node("ButtonPlay")


# Built-in overrides
func _ready() -> void:
	GameAudio.play_bgm(DatabaseAudio.BGM_MENU)
	_button_play.grab_focus()


# Event handlers
func _on_ButtonPlay_pressed() -> void:
	GameTransition.change_scene_to(DatabaseScenes.LEVEL_TEST)


func _on_ButtonQuit_pressed() -> void:
	GuiTransitions.hide()
	GameTransition.show()
	yield(GameTransition, "show_completed")
	yield(get_tree().create_timer(0.3), "timeout")
	get_tree().quit()


func _on_ButtonOptions_pressed() -> void:
	GameTransition.change_scene_to(DatabaseScenes.GUI_OPTIONS)


func _on_ButtonLogo_pressed() -> void:
	GameTransition.change_scene_to(DatabaseScenes.GUI_CREDITS)
