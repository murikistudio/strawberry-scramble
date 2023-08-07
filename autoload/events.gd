extends Node
# Event bus central contendo sinais úteis em locais fragmentados no jogo.


# Level signals
signal level_paused
signal level_resumed
signal level_restarted
signal level_checkpoint_touched(checkpoint)
signal level_can_complete
signal level_complete
signal level_dialog(character, dialog)

# Player signals
signal player_item_available
signal player_item_collected
