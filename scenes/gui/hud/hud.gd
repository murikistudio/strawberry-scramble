extends Control


onready var _texture_rect_collected: TextureRect = find_node("TextureRectCollected")
onready var _label_collected: Label = find_node("LabelCollected")
onready var _animation_player: AnimationPlayer = find_node("AnimationPlayer")


func _ready() -> void:
	GameEvents.connect("player_item_collected", self, "update_hud")
	GameEvents.connect("player_item_available", self, "update_hud")
	update_hud()


func update_hud() -> void:
	var text := "{collected}/{available}".format({
		"collected": GameState.items_collected,
		"available": GameState.items_available,
	})

	if _label_collected.text != text:
		_label_collected.text = text
		_animation_player.play("item_updated")
