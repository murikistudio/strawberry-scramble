extends AudioStreamPlayer
# Singleton que gerencia a reprodução da música e som do jogo.


# Constants
const FADE_SPEED := 0.25
const VOLUME_MIN := -80.0
const VOLUME_MAX := 0.0


# Variables
var _current_music := ""

onready var _tween: Tween = Tween.new()


# Built-in overrides
func _ready() -> void:
	bus = "BGM"
	pause_mode = Node.PAUSE_MODE_PROCESS
	add_child(_tween)


# Public methods
# Toca a música a partir do caminho de arquivo passado.
func play_bgm(file) -> void:
	if _tween.is_active():
		return

	if typeof(file) == TYPE_STRING and file == _current_music \
	or typeof(file) == TYPE_OBJECT and file == stream:
		return

	var _stream := _get_stream(file)

	if not _stream:
		return

	if stream:
		_tween.interpolate_property(self, "volume_db", VOLUME_MAX, VOLUME_MIN, FADE_SPEED)
		_tween.start()
		yield(_tween, "tween_all_completed")
		stream = null

	stream = _stream
	_current_music = _stream.resource_path
	play(0.0)
	_tween.interpolate_property(self, "volume_db", VOLUME_MIN, VOLUME_MAX, FADE_SPEED)
	_tween.start()


# Toca um efeito sonoro a partir de um AudioString ou caminho de arquivo.
func play_sfx(file, vol := 0.0, pitch := 1.0) -> void:
	var _stream := _get_stream(file)

	if not _stream:
		return

	var audio := AudioStreamPlayer.new()
	audio.stream = _stream
	audio.bus = "SFX"
	audio.volume_db = vol
	audio.pitch_scale = pitch
	audio.play()
	audio.connect("finished", self, "_on_audio_finished", [audio])
	add_child(audio)


# Private methods
func _get_stream(file) -> AudioStream:
	if not file:
		return null

	if typeof(file) == TYPE_STRING and ResourceLoader.exists(file):
		return load(file) as AudioStream

	if typeof(file) == TYPE_OBJECT and file.is_class("AudioStream"):
		return file

	return null


# Event handlers
func _on_audio_finished(audio: AudioStreamPlayer) -> void:
	audio.queue_free()
