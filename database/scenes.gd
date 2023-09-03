extends Node
class_name DatabaseScenes
# Definições de caminhos de arquivos de cenas usadas no jogo.


# Constants
const BASE_PATH := "res://scenes/"
const BASE_PATH_LEVELS := BASE_PATH + "levels/"
const GUI_BASE := BASE_PATH + "gui/"
const GUI_MENU := GUI_BASE + "menu/menu.tscn"
const GUI_LEVEL_SELECT := GUI_BASE + "level_select/level_select.tscn"
const GUI_OPTIONS := GUI_BASE + "options/options.tscn"
const GUI_CREDITS := GUI_BASE + "credits/credits.tscn"
const LEVEL_BASE := "res://scenes/levels/"
const LEVEL_TEST := LEVEL_BASE + "test.tscn"


# Public methods
# Obtém informações de nomes e caminhos das cenas de fases na pasta levels.
static func get_levels() -> Array:
	var level_paths := []
	var dir := Directory.new()

	if dir.open(BASE_PATH_LEVELS) != OK:
		push_error("An error occurred when trying to access the path.")
		return level_paths

	dir.list_dir_begin(true, true)
	var file_path := dir.get_next()

	while file_path:
		if not file_path.ends_with(".tscn"):
			file_path = dir.get_next()
			continue

		var parts := file_path.split("/", false)
		var file_name: String = parts[-1]
		parts = file_name.split(".", false)

		if parts.size():
			file_name = parts[0]

		level_paths.push_back({
			"name": file_name,
			"path": LEVEL_BASE + file_path,
		})
		file_path = dir.get_next()

	return level_paths
