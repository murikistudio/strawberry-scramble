extends Reference
class_name DatabaseLevels
# Definições de fases do jogo.


# Constants
const BASE_PATH := "res://scenes/levels/"
const WORLDS := [
	"spring",
	"summer",
	"autumn",
	"winter",
]
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
	{
		"name": "level_05",
		"world": "spring",
		"time": 60,
		"bgm": DatabaseAudio.BGM_LEVEL,
	},
]


# Static methods
# Retorna as definições da fase em específico.
static func get_level(world: String, name: String) -> Dictionary:
	for level in LEVELS:
		if level["world"] == world and level["name"] == name:
			return level

	return {}


# Obtém informações de nomes e caminhos das cenas de fases na pasta levels.
static func get_levels(world: String) -> Array:
	var level_paths := []
	var dir := Directory.new()
	var base_path = BASE_PATH + world + "/"

	if dir.open(base_path) != OK:
		prints("An error occurred when trying to access the path:", base_path)
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

		if "test" in file_name.to_lower():
			file_path = dir.get_next()
			continue

		levels_raw[file_name] = base_path + file_path
		file_path = dir.get_next()

	var file_names := levels_raw.keys().duplicate()
	file_names.sort()

	for file_name in file_names:
		var data := {
			"name": file_name,
			"world": world,
			"path": levels_raw[file_name],
		}

		data.merge(get_level(data["world"], data["name"]))

		level_paths.push_back(data)

	return level_paths
