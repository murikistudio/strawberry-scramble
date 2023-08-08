extends Control


# Constants
const BASE_PATH := "res://textures/icons/"


# Variables
onready var _label_time: Label = find_node("LabelTime")
onready var _texture_rect_trophy: TextureRect = find_node("TextureRectTrophy")
onready var _label_trophy: Label = find_node("LabelTrophy")
onready var _label_collected: Label = find_node("LabelCollected")
onready var _button_next: TextureButton = find_node("ButtonNext")


# Built-in overrides
func _ready() -> void:
	GameEvents.connect("level_complete", self, "_update_interface")
	GuiTransitions.connect("show_completed", self, "_on_show_completed")


# Private methods
func _update_interface() -> void:
	_texture_rect_trophy.texture = load(BASE_PATH + GameState.current_trophy + ".svg")
	_label_time.text = str(GameState.time_elapsed) + "s"
	_label_trophy.text = tr(GameState.current_trophy)
	_label_collected.text = "{collected}/{available}".format({
		"collected": str(GameState.items_collected),
		"available": str(GameState.items_available),
	})


# Event handlers
func _on_show_completed() -> void:
	if not GuiTransitions.is_shown(name):
		return

	_button_next.grab_focus()


func _on_ButtonQuit_pressed() -> void:
	GameTransition.change_scene_to(DatabaseScenes.GUI_LEVEL_SELECT)


func _on_ButtonNext_pressed() -> void:
	GameTransition.change_scene_to(DatabaseScenes.GUI_LEVEL_SELECT)


func _on_ButtonRestart_pressed() -> void:
	GameEvents.emit_signal("level_restarted")
