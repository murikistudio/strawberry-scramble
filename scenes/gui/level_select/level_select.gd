extends Control


# Variables
export(PackedScene) var scene_level_card: PackedScene
onready var _container_levels: GridContainer = find_node("GridContainerLevels")


# Built-in overrides
func _ready() -> void:
	_add_level_cards()
	GameAudio.play_bgm(DatabaseAudio.BGM_MENU)


# Private methods
# Adiciona na interface de usuário os cards de fases.
func _add_level_cards() -> void:
	var first_button_focused := false

	for level_def in DatabaseLevels.get_levels():
		var level_card: Control = scene_level_card.instance()
		level_card.level_def = level_def

		if not first_button_focused:
			level_card.focus_button = true
			first_button_focused = true

		_container_levels.add_child(level_card)


# Event handlers
func _on_ButtonBack_pressed() -> void:
	GameTransition.change_scene_to(DatabaseScenes.GUI_MENU)
