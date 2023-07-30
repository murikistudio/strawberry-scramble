extends Control
# Interface de usuário durante a fase, incluindo contador de itens coletados.


# Variables
onready var _texture_rect_collected: TextureRect = find_node("TextureRectCollected")
onready var _label_collected: Label = find_node("LabelCollected")
onready var _animation_player: AnimationPlayer = find_node("AnimationPlayer")


# Built-in overrides
func _ready() -> void:
	GameEvents.connect("player_item_collected", self, "update_hud")
	GameEvents.connect("player_item_available", self, "update_hud")
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
