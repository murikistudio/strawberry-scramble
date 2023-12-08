extends Control


# Variables
export(PackedScene) var scene_level_card: PackedScene


# Built-in overrides
func _ready() -> void:
	GameAudio.play_bgm(DatabaseAudio.BGM_MENU)


# Event handlers
func _on_ButtonBack_pressed() -> void:
	GameTransition.change_scene_to(DatabaseScenes.GUI_MENU)
