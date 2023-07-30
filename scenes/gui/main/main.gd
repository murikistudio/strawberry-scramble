extends Node2D


# Event handlers
func _on_Intro_intro_finished() -> void:
	GameTransition.change_scene_to(DatabaseScenes.GUI_MENU)
