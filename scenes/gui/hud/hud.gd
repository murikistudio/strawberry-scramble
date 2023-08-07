extends Control
# Interface de usuário durante a fase, incluindo contador de itens coletados.


# Variables
export(Texture) var texture_door_opened: Texture

onready var _texture_rect_collected: TextureRect = find_node("TextureRectCollected")
onready var _label_collected: Label = find_node("LabelCollected")
onready var _label_time: Label = find_node("LabelTime")
onready var _animation_player: AnimationPlayer = find_node("AnimationPlayer")
onready var _texture_rect_door: TextureRect = find_node("TextureRectDoor")


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
	_texture_rect_collected.rect_pivot_offset = _texture_rect_collected.rect_size / 2
	_label_collected.rect_pivot_offset = _label_collected.rect_size / 2

	var text := "{collected}/{available}".format({
		"collected": GameState.items_collected,
		"available": GameState.items_available,
	})

	if _label_collected.text != text:
		_label_collected.text = text
		_animation_player.play("item_updated")

	if GameState.current_trophy:
		_texture_rect_door.self_modulate.a = 1.0

		if _texture_rect_door.texture != texture_door_opened:
			_texture_rect_door.texture = texture_door_opened
			_animation_player.play("door_updated")

	else:
		_texture_rect_door.self_modulate.a = 0.6

	_label_time.text = str(GameState.time_elapsed) + "s"
