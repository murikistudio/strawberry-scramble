extends PlayerBaseComponent


# Built-in overrides
func _ready() -> void:
	player.connect("sfx_played", self, "_play_sfx")


# Private methods
# Toca som aleatório de voz de pulo.
func _play_sfx_jump() -> void:
	if rand_range(0, 100) > 30:
		return

	var sfx := [
		DatabaseAudio.SFX_JUMP_1,
		DatabaseAudio.SFX_JUMP_2,
		DatabaseAudio.SFX_JUMP_3,
	]
	GameAudio.play_sfx(_get_random_item(sfx), -4.0)


# Toca som aleatório de deslizar.
func _play_sfx_slide() -> void:
	var sfx := [
		DatabaseAudio.SFX_SLIDE_1,
		DatabaseAudio.SFX_SLIDE_2,
		DatabaseAudio.SFX_SLIDE_3,
	]
	GameAudio.play_sfx(_get_random_item(sfx), -4.0, rand_range(0.9, 1.1))


# Toca som de acertar o chão.
func _play_sfx_slam() -> void:
	GameAudio.play_sfx(DatabaseAudio.SFX_SLAM, -4.0, rand_range(0.9, 1.1))


# Toca som aleatório de passo.
func _play_sfx_step() -> void:
	if not player.is_on_floor():
		return

	var step_volume := -22.0
	var sfx := {
		"grass": [
			DatabaseAudio.SFX_STEP_GRASS_1,
			DatabaseAudio.SFX_STEP_GRASS_2,
		],
		"rock": [
			DatabaseAudio.SFX_STEP_ROCK_1,
			DatabaseAudio.SFX_STEP_ROCK_2,
		],
		"wood": [
			DatabaseAudio.SFX_STEP_WOOD_1,
			DatabaseAudio.SFX_STEP_WOOD_2,
		],
	}

	GameAudio.play_sfx(
		_get_random_item(sfx[player.ground_type]),
		step_volume,
		rand_range(1.05, 1.15)
	)


# Toca som aleatório de movimento rápido do ar.
func _play_sfx_swing() -> void:
	var sfx := [
		DatabaseAudio.SFX_SWING_1,
		DatabaseAudio.SFX_SWING_2,
		DatabaseAudio.SFX_SWING_3,
	]
	GameAudio.play_sfx(_get_random_item(sfx), -12.0)


# Event handlers
# Toca efeito sonoro.
func _play_sfx(sfx: String) -> void:
	var method_name := "_play_sfx_" + sfx

	if has_method(method_name):
		call(method_name)


# Static methods
# Retorna um item aleatório da array.
static func _get_random_item(array: Array):
	return array[randi() % array.size()]
