extends Node
# Estado global do jogo contendo dados úteis em todo o ciclo do jogo.


# Variables
# Level
var completed: bool
var current_level: int
var times_died: int
var time_elapsed: int

# Session
var items_collected: int
var items_available: int
var current_trophy: String


# Built-in overrides
func _ready() -> void:
	reset_level()


# Public methods
# Reseta status da fase selecionada.
func reset_level() -> void:
	completed = false
	times_died = 0
	time_elapsed = 0
	items_collected = 0
	items_available = 0
	current_trophy = ""


# Avalia estado do jogo (nota do jogador).
func evaluate_game() -> void:
	var items_progress := int((float(items_collected) / float(items_available)) * 100)

	if items_progress == 100:
		if times_died == 0:
			current_trophy = "diamond"
		else:
			current_trophy = "gold"

	elif items_progress >= 66:
		current_trophy = "silver"

	elif items_progress >= 33:
		current_trophy = "bronze"

	else:
		current_trophy = ""

	if current_trophy:
		GameEvents.emit_signal("level_can_complete")

	prints(times_died, items_progress, current_trophy)


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

	evaluate_game()


# Adicionar tempo passado na fase.
func add_time_elapsed() -> void:
	time_elapsed += 1
	GameEvents.emit_signal("level_time_updated")
