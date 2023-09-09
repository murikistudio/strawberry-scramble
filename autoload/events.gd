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
signal level_time_updated
signal level_lever_touched(lever)
signal level_lever_pushed(target)
signal level_boulder_triggered(spawner, mode)

# Player signals
signal player_died
signal player_item_available
signal player_item_collected
signal player_request_camera_focus(target)
signal player_emitted(player)
