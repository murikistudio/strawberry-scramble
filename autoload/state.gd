extends Node
# Estado global do jogo contendo dados úteis em todo o ciclo do jogo.


# Constants
const SAVE_PATH := "user://save"
const TROPHIES := {
	"": 0,
	"bronze": 1,
	"silver": 2,
	"gold": 3,
	"diamond": 4,
}


# Variables
# Global
var levels_progress := {}
var player_skills := {
	"slide": false,
	"double_jump": false,
	"slam": false,
}

# Level
var completed: bool
var current_world: String
var current_level: String
var times_died: int
var time_elapsed: float
var time_elapsed_rounded: int

# Session
var items_collected: int
var items_available: int
var current_progress: int
var current_trophy: String

onready var _compress_data := not OS.is_debug_build()


# Built-in overrides
func _ready() -> void:
	reset_level()
	load_game()


# Public methods
# Salva as informações persistentes do, como pontuações.
func save_game() -> void:
	var save_data := {
		"player_skills": player_skills,
		"levels_progress": levels_progress,
	}

	var path = SAVE_PATH + ".dat" if _compress_data else SAVE_PATH + ".json"
	var file := File.new()

	if _compress_data:
		file.open_compressed(path, File.WRITE, File.COMPRESSION_DEFLATE)
	else:
		file.open(path, File.WRITE)

	file.store_string(JSON.print(save_data, "  " if not _compress_data else ""))

	print("Saved game to ", path)


# Carrega save existente ou cria arquivo de save caso não exista.
func load_game() -> void:
	var path = SAVE_PATH + ".dat" if _compress_data else SAVE_PATH + ".json"
	var file := File.new()

	if not file.file_exists(path):
		save_game()

	if _compress_data:
		file.open_compressed(path, File.READ, File.COMPRESSION_DEFLATE)
	else:
		file.open(path, File.READ)

	var result = JSON.parse(file.get_as_text()).result
	file.close()

	var loaded_data: Dictionary = result if result else {}

	if not loaded_data.size():
		prints("Could not load game data from", path)
		return

	player_skills.merge(loaded_data.get("player_skills", {}), true)
	levels_progress = loaded_data.get("levels_progress", levels_progress)

	prints("Loaded game data from", path)


# Reseta status da fase selecionada.
func reset_level() -> void:
	completed = false
	times_died = 0
	time_elapsed = 0.0
	time_elapsed_rounded = 0
	items_collected = 0
	items_available = 0
	current_progress = 0
	current_trophy = ""


# Avalia estado do jogo (nota do jogador).
func evaluate_game() -> void:
	if not items_available:
		return

	var penalty := 20
	var level_def := DatabaseLevels.get_level(current_world, current_level)
	var level_time := float(level_def.get("time", 0))
	current_progress = int((float(items_collected) / float(items_available)) * 100)

	if level_time > 0 and time_elapsed > level_time:
		current_progress = int(max(current_progress - penalty, 0))

	if times_died > 0:
		current_progress = int(max(current_progress - penalty, 0))

	if current_progress == 100:
		current_trophy = "diamond"

	elif current_progress >= 80:
		current_trophy = "gold"

	elif current_progress >= 60:
		current_trophy = "silver"

	elif current_progress >= 40:
		current_trophy = "bronze"

	else:
		current_trophy = ""

	if current_trophy:
		GameEvents.emit_signal("level_can_complete")
	else:
		GameEvents.emit_signal("level_cannot_complete")


# Adiciona item coletado ao contador.
func add_item_collected() -> void:
	items_collected += 1
	GameEvents.emit_signal("player_item_collected")
	evaluate_game()


# Adiciona morte do jogador ao contador.
func add_times_died() -> void:
	times_died += 1

	if times_died % 5 == 0:
		GameEvents.emit_signal("level_dialog", "man", "death")

	GameEvents.emit_signal("player_died")
	evaluate_game()


# Adiciona pontuação final ao estado.
func add_score() -> void:
	if not current_world or not current_level:
		return

	var score := {
		"current_trophy": current_trophy,
		"items_collected": items_collected,
		"items_available": items_available,
		"times_died": times_died,
		"time_elapsed": time_elapsed,
	}

	var score_added := false
	var existing_score: Dictionary = levels_progress.get(current_world, {}).get(current_level, {})
	var existing_trophy_int: int = TROPHIES.get(existing_score.get("current_trophy", ""))
	var current_trophy_int: int = TROPHIES.get(current_trophy)

	if current_trophy_int < existing_trophy_int:
		prints("Score not added, a better score already exists!")
		return

	if not current_world in levels_progress.keys():
		levels_progress[current_world] = {}

	if current_trophy_int > existing_trophy_int:
		levels_progress[current_world][current_level] = score
		score_added = true

	elif current_trophy_int == existing_trophy_int:
		var existing_time := float(existing_score.get("time_elapsed", -1))

		if existing_time >= 0.0 and time_elapsed < existing_time:
			levels_progress[current_world][current_level] = score
			score_added = true

	if score_added:
		prints("Score added:", score)
		save_game()


# Adicionar tempo passado na fase.
func add_time_elapsed(value: float) -> void:
	time_elapsed += value

	var time_rounded := int(time_elapsed)

	if time_rounded != time_elapsed_rounded:
		time_elapsed_rounded = time_rounded
		evaluate_game()

	GameEvents.emit_signal("level_time_updated")
