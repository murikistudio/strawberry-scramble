extends Control


# Constants
const BASE_PATH_ICONS := "res://textures/icons/"


# Variables
onready var _label_percent: Label = find_node("LabelPercent")
onready var _label_deaths: Label = find_node("LabelDeaths")
onready var _label_time: Label = find_node("LabelTime")
onready var _texture_rect_trophy: TextureRect = find_node("TextureRectTrophy")
onready var _label_trophy: Label = find_node("LabelTrophy")
onready var _label_collected: Label = find_node("LabelCollected")
onready var _button_next: TextureButton = find_node("ButtonNext")
onready var _level_def := DatabaseLevels.get_level(GameState.current_world, GameState.current_level)


# Built-in overrides
func _ready() -> void:
	GameEvents.connect("level_complete", self, "_update_interface")
	GuiTransitions.connect("show_completed", self, "_on_show_completed")


# Private methods
func _update_interface() -> void:
	_label_percent.text = tr("level_complete_percent").format({
		"level": tr(GameState.current_world + "_" + GameState.current_level),
		"percent": GameState.current_progress,
	})

	# Trophy
	_texture_rect_trophy.texture = load(BASE_PATH_ICONS + GameState.current_trophy + ".svg")
	_label_trophy.text = tr(GameState.current_trophy)
	_label_trophy.modulate = DatabaseConstants.COLOR_COMPLETE

	# Items collected
	_label_collected.text = "{collected}/{available}".format({
		"collected": str(GameState.items_collected),
		"available": str(GameState.items_available),
	})

	if GameState.items_collected < GameState.items_available:
		_label_collected.modulate = DatabaseConstants.COLOR_PENALTY
	else:
		_label_collected.modulate = DatabaseConstants.COLOR_COMPLETE

	# Time
	_label_time.text = str(GameState.time_elapsed)
	var time_goal: int = _level_def.get("time", 0)

	if time_goal > 0:
		_label_time.text += " / " + str(time_goal) + "s"

		if GameState.time_elapsed > time_goal:
			_label_time.modulate = DatabaseConstants.COLOR_PENALTY
		else:
			_label_time.modulate = DatabaseConstants.COLOR_COMPLETE
	else:
		_label_time.text += "s"

	# Deaths
	_label_deaths.text = "x" + str(GameState.times_died)

	if GameState.times_died > 0:
		_label_deaths.modulate = DatabaseConstants.COLOR_PENALTY
	else:
		_label_deaths.modulate = DatabaseConstants.COLOR_COMPLETE


# Event handlers
func _on_show_completed() -> void:
	if not GuiTransitions.is_shown(name):
		return

	_button_next.grab_focus()


func _on_ButtonQuit_pressed() -> void:
	GameTransition.change_scene_to(DatabaseScenes.GUI_LEVEL_SELECT)


func _on_ButtonNext_pressed() -> void:
	var has_next := false

	for level_def in DatabaseLevels.get_levels(GameState.current_world):
		if level_def["name"] == GameState.current_level:
			has_next = true
			continue

		if has_next:
			GameState.current_level = level_def["name"]
			GameTransition.change_scene_to(level_def["path"])
			return

	GameTransition.change_scene_to(DatabaseScenes.GUI_LEVEL_SELECT)


func _on_ButtonRestart_pressed() -> void:
	GameEvents.emit_signal("level_restarted")
