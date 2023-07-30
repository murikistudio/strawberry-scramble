extends Node
# Estado global do jogo contendo dados úteis em todo o ciclo do jogo.


# Variables
var game_over: bool
var items_collected: int
var items_available: int


# Built-in overrides
func _ready() -> void:
	reset_state()


# Public methods
func reset_state() -> void:
	game_over = false
	items_collected = 0
	items_available = 0
