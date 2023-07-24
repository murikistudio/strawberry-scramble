extends Node


# Event handlers
func _on_Intro_intro_finished() -> void:
	GameCore.change_scene_to("res://scenes/levels/test.tscn")
