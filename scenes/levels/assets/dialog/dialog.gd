extends Area


# Variables
export var at_start := true
export var once_per_level := false
export(String, "mom", "man", "player") var character := "mom"
export var line := "start"
export(String, "", "mom", "man", "player") var fallback_character := ""
export var fallback_line := ""
var _character := ""
var _line := ""


# Built-in overrides
func _ready() -> void:
	if not line:
		queue_free()
		return

	_character = character
	_line = line

	if once_per_level and GameState.current_level in GameState.levels_progress.keys():
		if not fallback_character or not fallback_line:
			queue_free()
			return

		_character = fallback_character
		_line = fallback_line

	if at_start:
		_show_dialog()
		return

	connect("body_entered", self, "_show_dialog")


# Private methods
func _show_dialog(body = null) -> void:
	if body and not "player" in body.name.to_lower():
		return

	GameEvents.emit_signal("level_dialog", _character, _line)
	queue_free()
