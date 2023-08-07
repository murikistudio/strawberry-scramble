extends Control


# Variables
onready var _button_resume: BaseButton = find_node("ButtonResume")


# Built-in overrides
func _ready() -> void:
	GuiTransitions.connect("show_completed", self, "_on_show_completed")


# Event handlers
func _on_show_completed() -> void:
	if not GuiTransitions.is_shown(name):
		return

	_button_resume.grab_focus()


func _on_ButtonResume_pressed() -> void:
	GameEvents.emit_signal("level_resumed")


func _on_ButtonQuit_pressed() -> void:
	GameTransition.change_scene_to(DatabaseScenes.GUI_LEVEL_SELECT)


func _on_ButtonRestart_pressed() -> void:
	GameEvents.emit_signal("level_restarted")


func _on_ButtonOptions_pressed() -> void:
	GuiTransitions.go_to("Options")
