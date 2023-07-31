extends TextureRect


# Built-in overrides
func _ready() -> void:
	modulate.a = 0.0
	GameEvents.connect("level_paused", self, "show_vignette", [true])
	GameEvents.connect("level_resumed", self, "show_vignette", [false])


# Public methods
# Mostra ou oculta a vinheta com uma transição de fade.
func show_vignette(show: bool) -> void:
	var alpha := 1.0 if show else 0.0
	create_tween().tween_property(self, "modulate:a", alpha, 0.275)
