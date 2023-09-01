extends MarginContainer


const BASE_PATH_ICONS = "res://textures/icons/"


# Variables
export var level_path := ""
export var focus_button := false

var _level_name := ""
var _pressed := false

onready var _label_level_name: Label = find_node("LabelLevelName")
onready var _texture_rect_thumbnail: TextureRect = find_node("TextureRectThumbnail")
onready var _button_level: Button = find_node("ButtonLevel")
onready var _texture_rect_trophy: TextureRect = find_node("TextureRectTrophy")
onready var _label_time: Label = find_node("LabelTime")


# Built-in overrides
func _ready() -> void:
	var parts := level_path.split("/", false)

	if not parts.size():
		return

	var file_name: String = parts[-1]
	parts = file_name.split(".", false)

	if parts.size():
		_level_name = parts[0]
		file_name = tr(_level_name)

	_label_level_name.text = file_name
	_update_card()

	if focus_button:
		yield(GuiTransitions, "show_completed")
		_button_level.grab_focus()


func _update_card() -> void:
	var score: Dictionary = GameState.levels_progress.get(_level_name, {})

	if not score.size():
		return

	_label_time.text = str(score["time_elapsed"]) + "s"
	_texture_rect_trophy.texture = load(BASE_PATH_ICONS + score["current_trophy"] + ".svg")


# Event handlers
func _on_ButtonLevel_pressed() -> void:
	if not level_path or _pressed:
		return

	_pressed = true
	GameState.current_level = _level_name
	GameTransition.change_scene_to(level_path)
