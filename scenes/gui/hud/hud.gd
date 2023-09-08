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
onready var _texture_no_trophy: Texture = _texture_rect_trophy.texture
onready var _level_def := DatabaseLevels.get_level(GameState.current_level)


# Built-in overrides
func _ready() -> void:
	GameEvents.connect("player_died", self, "update_hud")
	GameEvents.connect("player_item_collected", self, "update_hud")
	GameEvents.connect("player_item_available", self, "update_hud")
	GameEvents.connect("level_can_complete", self, "update_hud")
	GameEvents.connect("level_time_updated", self, "update_hud")
	update_hud()


# Public methods
# Atualiza valores mostrados na interface de usuário.
func update_hud() -> void:
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
	var time := str(GameState.time_elapsed)
	var time_goal: int = _level_def.get("time", 0)

	if _label_time.text != time:
		GameCore.highlight_control_scale(_texture_rect_time)
		GameCore.highlight_control_scale(_label_time)
		_label_time.text = time

		if time_goal > 0:
			if GameState.time_elapsed <= time_goal:
				_label_time_goal.text = " / " + str(time_goal) + "s"
				_label_time.modulate = Color.white
			else:
				_label_time.text += "s"
				_label_time_goal.text = ""
				_label_time.modulate = DatabaseConstants.COLOR_PENALTY

		else:
			_label_time.text += "s"
			_label_time_goal.text = ""
			_label_time.modulate = Color.white

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
