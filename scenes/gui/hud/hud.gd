extends Control
# Interface de usuário durante a fase, incluindo contador de itens coletados.


# Constants
const BASE_PATH_ICONS := "res://textures/icons/"


# Variables
export(Texture) var texture_house_opened: Texture

var _current_trophy := ""

onready var _texture_rect_deaths: TextureRect = find_node("TextureRectDeaths")
onready var _texture_rect_time: TextureRect = find_node("TextureRectTime")
onready var _texture_rect_trophy: TextureRect = find_node("TextureRectTrophy")
onready var _texture_rect_door: TextureRect = find_node("TextureRectDoor")
onready var _texture_rect_collected: TextureRect = find_node("TextureRectCollected")
onready var _label_deaths: Label = find_node("LabelDeaths")
onready var _label_time: Label = find_node("LabelTime")
onready var _label_time_goal: Label = find_node("LabelTimeGoal")
onready var _label_collected: Label = find_node("LabelCollected")
onready var _label_level_name: Label = find_node("LabelLevelName")
onready var _texture_no_trophy: Texture = _texture_rect_trophy.texture
onready var _level_def := DatabaseLevels.get_level(GameState.current_world, GameState.current_level)
onready var _time_goal := stepify(float(_level_def.get("time", 0)), 0.1)


# Built-in overrides
func _ready() -> void:
	GameEvents.connect("player_died", self, "_update_hud")
	GameEvents.connect("player_item_collected", self, "_update_hud")
	GameEvents.connect("player_item_available", self, "_update_hud")
	GameEvents.connect("level_can_complete", self, "_update_hud")
	GameEvents.connect("level_time_updated", self, "_update_time")
	_update_hud()

	if _level_def.get("bgm"):
		GameAudio.play_bgm(_level_def["bgm"])

	if not ProjectSettings.get_setting("application/run/show_hud"):
		$PanelLower.modulate.a = 0.0
		$PanelUpper.modulate.a = 0.0

	_label_level_name.get_node("AnimationPlayer").play("fade_out")


# Public methods
# Atualiza valores mostrados na interface de usuário.
func _update_hud() -> void:
	if _level_def.get("world") and _level_def.get("name"):
		_label_level_name.text = _level_def["world"] + "_" + _level_def["name"]
	else:
		_label_level_name.text = ""

	# Mortes
	var deaths := "x" + str(GameState.times_died)

	if _label_deaths.text != deaths:
		GameCore.highlight_control_scale(_texture_rect_deaths)
		GameCore.highlight_control_scale(_label_deaths)
		_label_deaths.text = deaths

		if GameState.times_died == 0:
			_label_deaths.modulate = Color.white
		else:
			_label_deaths.modulate = DatabaseConstants.COLOR_PENALTY

	# Tempo
	_update_time()

	# Itens coletados
	var collected_text := "{collected}/{available}".format({
		"collected": GameState.items_collected,
		"available": GameState.items_available,
	})

	if _label_collected.text != collected_text:
		_label_collected.text = collected_text
		GameCore.highlight_control_scale(_texture_rect_collected)
		GameCore.highlight_control_scale(_label_collected)

	# Troféu e porta
	if GameState.current_trophy:
		_texture_rect_door.self_modulate.a = 1.0

		if _current_trophy != GameState.current_trophy:
			_texture_rect_trophy.texture = load(BASE_PATH_ICONS + GameState.current_trophy + ".svg")
			_current_trophy = GameState.current_trophy
			GameCore.highlight_control_scale(_texture_rect_trophy)

		if _texture_rect_door.texture != texture_house_opened:
			_texture_rect_door.texture = texture_house_opened
			GameCore.highlight_control_scale(_texture_rect_door)

	else:
		_texture_rect_trophy.texture = _texture_no_trophy
		_texture_rect_door.self_modulate.a = 0.6


# Private methods
# Atualiza label de tempo da fase.
func _update_time() -> void:
	_label_time.text = DatabaseLevels.format_level_time(GameState.time_elapsed, 0.1)

	if _time_goal > 0:
		if GameState.time_elapsed <= _time_goal:
			_label_time_goal.text = " / " + str(_time_goal) + "s"
			_label_time.modulate = Color.white
		else:
			_label_time.text += "s"
			_label_time_goal.text = ""
			_label_time.modulate = DatabaseConstants.COLOR_PENALTY

	else:
		_label_time.text += "s"
		_label_time_goal.text = ""
		_label_time.modulate = Color.white
