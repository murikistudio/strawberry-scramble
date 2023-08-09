extends Control
# Interface de usuário durante a fase, incluindo contador de itens coletados.


# Constants
const BASE_PATH_ICONS := "res://textures/icons/"


# Variables
export(Texture) var texture_door_opened: Texture

var _current_trophy := ""

onready var _texture_rect_time: TextureRect = find_node("TextureRectTime")
onready var _texture_rect_trophy: TextureRect = find_node("TextureRectTrophy")
onready var _texture_rect_door: TextureRect = find_node("TextureRectDoor")
onready var _texture_rect_collected: TextureRect = find_node("TextureRectCollected")
onready var _label_time: Label = find_node("LabelTime")
onready var _label_collected: Label = find_node("LabelCollected")


# Built-in overrides
func _ready() -> void:
	GameEvents.connect("player_item_collected", self, "update_hud")
	GameEvents.connect("player_item_available", self, "update_hud")
	GameEvents.connect("level_can_complete", self, "update_hud")
	GameEvents.connect("level_time_updated", self, "update_hud")
	update_hud()


# Public methods
# Atualiza valores mostrados na interface de usuário.
func update_hud() -> void:
	# Tempo
	var time := str(GameState.time_elapsed) + "s"

	if _label_time.text != time:
		GameCore.highlight_control_scale(_texture_rect_time)
		GameCore.highlight_control_scale(_label_time)
		_label_time.text = time

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

		if _texture_rect_door.texture != texture_door_opened:
			_texture_rect_door.texture = texture_door_opened
			GameCore.highlight_control_scale(_texture_rect_door)

	else:
		_texture_rect_door.self_modulate.a = 0.6
