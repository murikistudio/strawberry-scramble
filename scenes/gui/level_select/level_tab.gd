extends Tabs


# Variables
export var scene_level_card: PackedScene
var _container_levels: Control


# Built-in overrides
func _ready() -> void:
	_add_container_levels()
	_add_level_cards()


func _add_container_levels() -> void:
	_container_levels = GridContainer.new()
	_container_levels.columns = 5
	_container_levels.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_container_levels.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	add_child(_container_levels)


# Adiciona na interface de usuário os cards de fases.
func _add_level_cards() -> void:
	var first_button_focused := false

	for level_def in DatabaseLevels.get_levels(name):
		var level_card: Control = scene_level_card.instance()
		level_card.level_def = level_def

		if not first_button_focused:
			level_card.focus_button = true
			first_button_focused = true

		_container_levels.add_child(level_card)
