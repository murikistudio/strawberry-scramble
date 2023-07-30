extends Node
# Event bus central contendo sinais úteis em locais fragmentados no jogo.


# Level signals
signal level_paused
signal level_resumed
signal level_game_over
signal level_restarted

# Player signals
signal player_item_available
signal player_item_collected
