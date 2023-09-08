extends Reference
class_name DatabaseLevels
# Definições de fases do jogo.


# Constants
const LEVELS := [
	{
		"name": "test",
		"time": 36,
	},
	{
		"name": "level_01",
		"time": 35,
	},
]


# Static methods
# Retorna as definições da fase em específico.
static func get_level(name: String) -> Dictionary:
	for level in LEVELS:
		if level["name"] == name:
			return level

	return {}
