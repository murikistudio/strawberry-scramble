extends MarginContainer


# Constants
const BASE_PATH_ICONS = "res://textures/icons/"


# Variables
export var level_def: Dictionary
export var focus_button := false

var _pressed := false

onready var _label_level_name: Label = find_node("LabelLevelName")
onready var _texture_rect_thumbnail: TextureRect = find_node("TextureRectThumbnail")
onready var _button_level: Button = find_node("ButtonLevel")
onready var _texture_rect_trophy: TextureRect = find_node("TextureRectTrophy")
onready var _label_time: Label = find_node("LabelTime")
onready var _texture_rect_time: TextureRect = find_node("TextureRectTime")
onready var _level_def := DatabaseLevels.get_level(level_def.get("name", ""))


# Built-in overrides
func _ready() -> void:
	_update_card()

	if focus_button:
		yield(GuiTransitions, "show_completed")
		_button_level.grab_focus()


# Private methods
func _update_card() -> void:
	var score: Dictionary = GameState.levels_progress.get(level_def["name"], {})
	_label_level_name.text = tr(level_def.get("name", ""))

	if not score.size():
		_label_time.modulate = DatabaseConstants.COLOR_PENALTY
		_texture_rect_time.modulate = DatabaseConstants.COLOR_PENALTY

		if _level_def.get("time"):
			_label_time.text = str(_level_def["time"]) + "s"

		return

	_label_time.text = str(score["time_elapsed"]) + "s"
	_texture_rect_trophy.texture = load(BASE_PATH_ICONS + score["current_trophy"] + ".svg")


# Event handlers
func _on_ButtonLevel_pressed() -> void:
	if not level_def.get("path") or _pressed:
		return

	_pressed = true
	GameState.current_level = level_def["name"]
	GameTransition.change_scene_to(level_def["path"])
