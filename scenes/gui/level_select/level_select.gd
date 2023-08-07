extends Control


# Constants
const BASE_PATH := "res://scenes/levels/"


# Variables
export(PackedScene) var scene_level_card: PackedScene
var _level_paths := []
onready var _container_levels: GridContainer = find_node("GridContainerLevels")


# Built-in overrides
func _ready() -> void:
	_get_level_paths()
	_add_level_cards()


# Private methods
# Obtém os caminhos das cenas de fases na pasta levels.
func _get_level_paths() -> void:
	var dir := Directory.new()

	if dir.open(BASE_PATH) != OK:
		print("An error occurred when trying to access the path.")
		return

	dir.list_dir_begin(true, true)

	var file_name := dir.get_next()

	while file_name:
		if not dir.current_is_dir() and file_name.ends_with(".tscn"):
			_level_paths.push_back(BASE_PATH + file_name)

		file_name = dir.get_next()


# Adiciona na interface de usuário os cards de fases.
func _add_level_cards() -> void:
	for level_path in _level_paths:
		var level_card: Control = scene_level_card.instance()
		level_card.level_path = level_path
		_container_levels.add_child(level_card)


# Event handlers
func _on_ButtonBack_pressed() -> void:
	GameTransition.change_scene_to(DatabaseScenes.GUI_MENU)
