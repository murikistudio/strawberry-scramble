extends Control


# Constants
const MAX_LEVELS := 12


# Variables
var _button_level_pressed := false
export(Texture) var _texture_play: Texture
onready var _current_world := GameState.current_world if GameState.current_world else DatabaseLevels.WORLDS[0]
onready var _current_level := ""
onready var _button_back: BaseButton = find_node("ButtonBack")
onready var _button_world: Button = find_node("ButtonWorld")
onready var _grid_container_levels: GridContainer = find_node("GridContainerLevels")
onready var _texture_level_thumbnail: TextureRect = find_node("TextureLevelThumbnail")
onready var _texture_level_trophy: TextureRect = find_node("TextureLevelTrophy")
onready var _label_level_name: Label = find_node("LabelLevelName")
onready var _texture_level_time: TextureRect = find_node("TextureLevelTime")
onready var _label_level_time: Label = find_node("LabelLevelTime")
onready var _container_level_time: Container = find_node("ContainerLevelTime")


# Built-in overrides
func _ready() -> void:
	GameAudio.play_bgm(DatabaseAudio.BGM_MENU)
	_button_back.connect("focus_entered", self, "_unset_current_level")
	_button_world.connect("focus_entered", self, "_unset_current_level")
	_update_layout()


# Private methods
func _unset_current_level() -> void:
	_current_level = ""
	_update_level_panel()


func _update_layout() -> void:
	_button_world.text = _current_world
	_add_level_buttons()
	_update_level_panel()


func _add_level_buttons() -> void:
	for child in _grid_container_levels.get_children():
		child.queue_free()

	var level_defs := DatabaseLevels.get_levels(_current_world)

	for i in level_defs.size():
		var level_button := _create_level_button(i, level_defs[i])
		_grid_container_levels.add_child(level_button)

	if level_defs.size() < MAX_LEVELS:
		for i in MAX_LEVELS - level_defs.size():
			var control := Control.new()
			control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			control.size_flags_vertical = Control.SIZE_EXPAND_FILL
			_grid_container_levels.add_child(control)


func _create_level_button(i: int, level_def: Dictionary) -> Button:
	var level_button := Button.new()
	var text := str(i + 1)

	level_button.set_meta("level_def", level_def)
	level_button.text = text
	level_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	level_button.size_flags_vertical = Control.SIZE_EXPAND_FILL
	level_button.icon_align = Button.ALIGN_CENTER
	level_button.expand_icon = true
	level_button.connect("focus_entered", self, "_on_level_button_focus_entered", [level_button])
	level_button.connect("focus_exited", self, "_on_level_button_focus_exited", [level_button, text])
	level_button.connect("pressed", self, "_on_level_button_pressed", [level_button])

	var highlighter := ButtonHighlighter.new()
	level_button.add_child(highlighter)

	return level_button


func _update_level_panel(level_def := {}) -> void:
	var world_progress: Dictionary = GameState.levels_progress.get(level_def.get("world", ""), {})
	var score: Dictionary = world_progress.get(level_def.get("name", ""), {})

	if level_def.size():
		_label_level_name.text = tr(level_def["name"])
		_texture_level_trophy.visible = true
		_container_level_time.visible = true

	else:
		_label_level_name.text = tr(_current_world)
		_texture_level_trophy.visible = false
		_container_level_time.visible = false


	if score.size():
		_texture_level_time.modulate = Color.white
		_label_level_time.modulate = Color.white
		_label_level_time.text = str(score["time_elapsed"]) + "s"
		_texture_level_trophy.texture = load(DatabaseConstants.BASE_PATH_ICONS + score["current_trophy"] + ".svg")

	else:
		_label_level_time.modulate = DatabaseConstants.COLOR_PENALTY
		_texture_level_time.modulate = DatabaseConstants.COLOR_PENALTY
		_texture_level_trophy.texture = load(DatabaseConstants.BASE_PATH_ICONS + "no_trophy.svg")
		var cur_level_def := DatabaseLevels.get_level(level_def.get("world", ""), level_def.get("name", ""))

		if cur_level_def.get("time"):
			_label_level_time.text = str(cur_level_def["time"]) + "s"
		else:
			_label_level_time.text = "---"


# Event handlers
func _on_ButtonBack_pressed() -> void:
	GameTransition.change_scene_to(DatabaseScenes.GUI_MENU)


func _on_ButtonWorld_pressed() -> void:
	var i := wrapi(DatabaseLevels.WORLDS.find(_current_world) + 1, 0, DatabaseLevels.WORLDS.size())
	_current_world = DatabaseLevels.WORLDS[i]
	_current_level = ""
	_update_layout()
	_update_level_panel()


func _on_level_button_focus_entered(level_button: Button) -> void:
	if not level_button.disabled:
		level_button.icon = _texture_play
		level_button.text = ""

	var level_def: Dictionary = level_button.get_meta("level_def", {})
	_current_level = level_def.get("name", "")

	_update_level_panel(level_def)


func _on_level_button_focus_exited(level_button: Button, text: String) -> void:
	level_button.icon = null
	level_button.text = text


func _on_level_button_pressed(level_button: Button) -> void:
	var level_def: Dictionary = level_button.get_meta("level_def", {})

	if not level_def.get("path") or _button_level_pressed:
		return

	_button_level_pressed = true
	GameState.current_world = level_def["world"]
	GameState.current_level = level_def["name"]
	GameTransition.change_scene_to(level_def["path"])
