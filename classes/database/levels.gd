extends Reference
class_name DatabaseLevels
# Definições de fases do jogo.


# Constants
const BASE_PATH := "res://scenes/levels/"
const LEVELS := [
	{
		"name": "level_01",
		"world": "spring",
		"time": 12,
		"bgm": DatabaseAudio.BGM_LEVEL,
	},
	{
		"name": "level_02",
		"world": "spring",
		"time": 32,
		"bgm": DatabaseAudio.BGM_LEVEL,
	},
	{
		"name": "level_03",
		"world": "spring",
		"time": 36,
		"bgm": DatabaseAudio.BGM_LEVEL,
	},
	{
		"name": "level_04",
		"world": "spring",
		"time": 22,
		"bgm": DatabaseAudio.BGM_LEVEL,
	},
]


# Static methods
# Retorna as definições da fase em específico.
static func get_level(name: String) -> Dictionary:
	for level in LEVELS:
		if level["name"] == name:
			return level

	return {}


# Obtém informações de nomes e caminhos das cenas de fases na pasta levels.
static func get_levels() -> Array:
	var level_paths := []
	var dir := Directory.new()

	if dir.open(BASE_PATH) != OK:
		push_error("An error occurred when trying to access the path.")
		return level_paths

	dir.list_dir_begin(true, true)
	var levels_raw := {}
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

		if "test" in file_name.to_lower() and not OS.is_debug_build():
			file_path = dir.get_next()
			continue

		levels_raw[file_name] = BASE_PATH + file_path
		file_path = dir.get_next()

	var file_names := levels_raw.keys().duplicate()
	file_names.sort()

	for file_name in file_names:
		level_paths.push_back({
			"name": file_name,
			"path": levels_raw[file_name],
		})

	return level_paths
